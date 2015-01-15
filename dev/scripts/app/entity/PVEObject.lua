local PVEDefine = import(".PVEDefine")
local PVEObject = class("PVEObject")


local TOTAL = {
    [PVEDefine.START_AIRSHIP] = 0,
    [PVEDefine.WOODCUTTER] = 3,
    [PVEDefine.QUARRIER] = 3,
    [PVEDefine.MINER] = 3,
    [PVEDefine.FARMER] = 3,
    [PVEDefine.CAMP] = 2,
    [PVEDefine.CRASHED_AIRSHIP] = 2,
    [PVEDefine.CONSTRUCTION_RUINS] = 1,
    [PVEDefine.KEEL] = 1,
    [PVEDefine.WARRIORS_TOMB] = 1,
    [PVEDefine.OBELISK] = 1,
    [PVEDefine.ANCIENT_RUINS] = 1,
    [PVEDefine.ENTRANCE_DOOR] = 1,
    [PVEDefine.TREE] = 0,
    [PVEDefine.HILL] = 0,
    [PVEDefine.LAKE] = 0,
}

function PVEObject:ctor(x, y, searched, type)
    self.x = x
    self.y = y
    self.searched = searched or 0
    self.type = type
end
function PVEObject:SetType(type)
    self.type = type
end
function PVEObject:Type()
    return self.type
end
function PVEObject:Position()
    return self.x, self.y
end
function PVEObject:GetNextEnemy()
    return self:GetEnemyByIndex(self.searched + 1)
end
function PVEObject:GetEnemyByIndex(index)
    return {}
end
function PVEObject:IsUnSearched()
    return self:Searched() == 0
end
function PVEObject:IsSearched()
    return self:Searched() >= self:Total()
end
function PVEObject:SearchNext()
    self.searched = self.searched + 1
end
function PVEObject:Left()
    return self:Total() - self:Searched()
end
function PVEObject:Searched()
    return self.searched
end
function PVEObject:Total()
    return TOTAL[self.type]
end
function PVEObject:Dump()
    return string.format("{%d,%d,%d}", self.x, self.y, self.searched)
end

return PVEObject







