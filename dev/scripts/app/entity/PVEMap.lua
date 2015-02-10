local PVEDefine = import(".PVEDefine")
local PVEObject = import(".PVEObject")
local Observer = import(".Observer")
local PVEMap = class("PVEMap", Observer)

function PVEMap:ctor(database, index)
    PVEMap.super.ctor(self)
    self.index = index
    self.searched_fogs = {}
    self.searched_objects = {}
    self.database = database
end
function PVEMap:LoadProperty()
    local file_name = self:GetFileName()
    local pve_layer = cc.TMXTiledMap:create(file_name):getLayer("layer1")
    local size = pve_layer:getLayerSize()
    local total_objects = 0
    for x = 0, size.width - 1 do
        for y = 0, size.height - 1 do
            local ccp = cc.p(x, y)
            local gid = (pve_layer:getTileGIDAt(ccp))
            if gid > 0 then
                total_objects = total_objects + PVEObject:TotalByType(gid)
                if gid == PVEDefine.START_AIRSHIP then
                    self.start_point = ccp
                elseif gid == PVEDefine.ENTRANCE_DOOR then
                    self.end_point = ccp
                end
            end
        end
    end
    pve_layer:removeFromParent()
    self.width = size.width
    self.height = size.height
    self.total_objects = total_objects
    return self
end
function PVEMap:GetFileName()
    return string.format("tmxmaps/pve_%d_info.tmx", self.index)
end
function PVEMap:GetDatabase()
    return self.database
end
function PVEMap:GetIndex()
    return self.index
end
function PVEMap:ExploreDegree()
    return (self:SearchedFogsCount() + self:SearchedObjectsCount()) / (self:TotalFogs() + self:TotalObjects())
end
function PVEMap:TotalFogs()
    local w, h = self:GetSize()
    return (w - 1) * (h - 1)
end
function PVEMap:TotalObjects()
    return self.total_objects
end
function PVEMap:GetStartPoint()
    assert(self.start_point)
    return self.start_point
end
function PVEMap:GetEndPoint()
    assert(self.end_point)
    return self.end_point
end
function PVEMap:GetSize()
    return self.width, self.height
end
function PVEMap:SearchedFogsCount()
    return #self.searched_fogs * 0.5
end
function PVEMap:SearchedObjectsCount()
    local count = 0
    for _, v in ipairs(self.searched_objects) do
        count = count + v:Searched()
    end
    return count
end
function PVEMap:IteratorFogs(func)
    local searched_fogs = self.searched_fogs
    for i = 1, #searched_fogs, 2 do
        func(searched_fogs[i], searched_fogs[i + 1])
    end
end
function PVEMap:InsertFog(x, y)
    local searched_fogs = self.searched_fogs
    for i = 1, #searched_fogs, 2 do
        if x == searched_fogs[i] and y == searched_fogs[i + 1] then
            return
        end
    end
    searched_fogs[#searched_fogs + 1] = x
    searched_fogs[#searched_fogs + 1] = y
    return self
end
function PVEMap:IteratorObjects(func)
    for _, v in ipairs(self.searched_objects) do
        func(v)
    end
end
function PVEMap:GetObject(x, y)
    for _, v in ipairs(self.searched_objects) do
        if v.x == x and v.y == y then
            return v
        end
    end
end
function PVEMap:ModifyObject(x, y, searched, type)
    for _, v in ipairs(self.searched_objects) do
        if v.x == x and v.y == y then
            if v.searched ~= searched then
                v.searched = searched
                self:NotifyObservers(function(lisenter)
                    lisenter:OnObjectChanged(v)
                end)
            end
            return
        end
    end
    table.insert(self.searched_objects, PVEObject.new(x, y, searched, type))
    self:NotifyObservers(function(lisenter)
        lisenter:OnObjectChanged(self.searched_objects[#self.searched_objects])
    end)
end
function PVEMap:IsComplete()
    local complete = false
    self:IteratorObjects(function(object)
        if object:IsEntranceDoor() then
            complete = object:IsSearched()
        end
    end)
    return complete
end
function PVEMap:IsHead()
    local nxt = self.database:GetMapByIndex(self.index + 1)
    return self:IsAvailable() and (nxt == nil and true or not nxt:IsAvailable())
end
function PVEMap:IsAvailable()
    local pre = self.database:GetMapByIndex(self.index - 1)
    return pre == nil and true or pre:IsComplete()
end
function PVEMap:IsSearched()
    return #self.searched_fogs > 0 or #self.searched_objects > 0
end
function PVEMap:Load(floor)
    assert(floor.fogs)
    assert(floor.objects)
    local f = loadstring(string.format("return {fogs=%s, objects=%s}", floor.fogs, floor.objects))
    local data = assert(f)()
    self.searched_fogs = data.fogs
    local end_point = self:GetEndPoint()
    for _, v in ipairs(data.objects) do
        local x, y, searched = unpack(v)
        self:ModifyObject(x, y, searched, (x == end_point.x and y == end_point.y) and PVEDefine.ENTRANCE_DOOR)
    end
end
function PVEMap:EncodeMap()
    return {
        level = self.index,
        fogs = self:DumpFogs(),
        objects = self:DumpObjects()
    }
end
function PVEMap:DumpFogs()
    local fogs = {}
    for _, v in ipairs(self.searched_fogs) do
        fogs[#fogs + 1] = string.format("%d", v)
    end
    return string.format("{%s}", table.concat(fogs, ","))
end
function PVEMap:DumpObjects()
    local objects = {}
    for _, v in ipairs(self.searched_objects) do
        if v:Searched() > 0 then
            objects[#objects + 1] = v:Dump()
        end
    end
    return string.format("{%s}", table.concat(objects, ","))
end

return PVEMap





