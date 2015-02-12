local Localize_pve = import("..utils.Localize_pve")
local PVEDefine = import(".PVEDefine")
local PVEObject = import(".PVEObject")
local Observer = import(".Observer")
local BitBaseN = import("..utils.BitBaseN")
local PVEMap = class("PVEMap", Observer)
local floor = math.floor
function PVEMap:ctor(database, index)
    PVEMap.super.ctor(self)
    self.index = index
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
    self.fogs = BitBaseN.new(self.width * self.height)
    return self
end
function PVEMap:Name()
    return Localize_pve.stage_name[self.index]
end
function PVEMap:Desc()
    return Localize_pve.stage_desc[self.index]
end
function PVEMap:CompleteText()
    return Localize_pve.stage_complete[self.index]
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
    -- return self:SearchedFogsCount()/self:TotalFogs()
    return (self:SearchedObjectsCount()/self:TotalObjects() + self:SearchedFogsCount()/self:TotalFogs()) * 0.5
end
function PVEMap:TotalFogs()
    local w, h = self:GetSize()
    return (w - 2) * (h - 2)
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
    local count = 0
    local fogs = self.fogs
    for i = 1, fogs:length() do
        count = count + (fogs[i] and 1 or 0)
    end
    return count
end
function PVEMap:SearchedObjectsCount()
    local count = 0
    for _, v in ipairs(self.searched_objects) do
        count = count + v:Searched()
    end
    return count
end
function PVEMap:IteratorFogs(func)
    local w, h = self:GetSize()
    local fogs = self.fogs
    for i = 1, fogs:length() do
        if fogs[i] then
            func((i - 1) % w, floor((i - 1) / w))
        end
    end
end
function PVEMap:InsertFog(x, y)
    local w,h = self:GetSize()
    local index = y * w + x + 1
    if not self.fogs[index] then
        self.fogs[index] = true
    end
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
    if #self.searched_objects > 0 then
        return true
    end
    for i = 1, fogs:length() do
        if fogs[i] then
            return true
        end
    end
    return false
end
function PVEMap:Load(floor)
    assert(floor.fogs)
    assert(floor.objects)
    self.fogs:decode(floor.fogs)
    local end_point = self:GetEndPoint()
    for _, v in ipairs(json.decode(floor.objects)) do
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
    return self.fogs:encode()
end
function PVEMap:DumpObjects()
    local objects = {}
    for _, v in ipairs(self.searched_objects) do
        if v:Searched() > 0 then
            objects[#objects + 1] = v:Dump()
        end
    end
    return string.format("[%s]", table.concat(objects, ","))
end

return PVEMap







