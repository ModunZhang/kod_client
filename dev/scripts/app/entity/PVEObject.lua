local pve_normal = GameDatas.ClientInitGame.pve_normal
local pve_elite = GameDatas.ClientInitGame.pve_elite
local pve_boss = GameDatas.ClientInitGame.pve_boss
local pve_npc = GameDatas.ClientInitGame.pve_npc
local PVEDefine = import(".PVEDefine")
local PVEObject = class("PVEObject")
local random = math.random
local randomseed = math.randomseed
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

local normal_map = {
    [PVEDefine.WOODCUTTER] = true,
    [PVEDefine.QUARRIER] = true,
    [PVEDefine.MINER] = true,
    [PVEDefine.FARMER] = true,
}
local elite_map = {
    [PVEDefine.CAMP] = true,
    [PVEDefine.CRASHED_AIRSHIP] = true,
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
    local unique = self.x * self.y * (index + self.type)
    if normal_map[self.type] then
        return self:DecodeToEnemy(pve_normal[unique % #pve_normal + 1])
    elseif elite_map[self.type] then
        return self:DecodeToEnemy(elite_map[unique % #elite_map + 1])
    end
    return {}
end
function PVEObject:DecodeToEnemy(raw_data)
    return raw_data
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
    return self:TotalByType(self.type)
end
function PVEObject:TotalByType(type)
    return TOTAL[type]
end
function PVEObject:Dump()
    return string.format("{%d,%d,%d}", self.x, self.y, self.searched)
end

return PVEObject







