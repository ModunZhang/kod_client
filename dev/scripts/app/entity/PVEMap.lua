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
function PVEMap:GetDatabase()
    return self.database
end
function PVEMap:GetIndex()
    return self.index
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
function PVEMap:IsSearched()
    return #self.searched_fogs > 0 or #self.searched_objects > 0
end
function PVEMap:Load(str_code)
    print("str_code", str_code)
    str_code = str_code or ""
    str_code = #str_code == 0 and "{fog={},object={}}" or str_code
    local f = loadstring(string.format("return %s", str_code))
    local data = assert(f)()
    self.searched_fogs = data.fog
    for _, v in ipairs(data.object) do
        print(unpack(v))
        self:ModifyObject(unpack(v))
    end
end
function PVEMap:Dump()
    return string.format("{fog=%s,object=%s}", self:DumpFog(), self:DumpMap())
end
function PVEMap:DumpFog()
    local fogs = {}
    for _, v in ipairs(self.searched_fogs) do
        fogs[#fogs + 1] = string.format("%d", v)
    end
    return string.format("{%s}", table.concat(fogs, ","))
end
function PVEMap:DumpMap()
    local objects = {}
    for _, v in ipairs(self.searched_objects) do
        if v:Searched() > 0 then
            objects[#objects + 1] = v:Dump()
        end
    end
    return string.format("{%s}", table.concat(objects, ","))
end

return PVEMap


