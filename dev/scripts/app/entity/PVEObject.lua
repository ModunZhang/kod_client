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
function PVEObject:GetRewards()
    for k, v in pairs(PVEDefine) do
        if v == self.type then
            return self:DecodeToRewards(pve_npc[k].rewards)
        end
    end  
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
    local dragonType, hp, strength, vitality = unpack(string.split(raw_data.dragon_hp_strength_vitality, ","))
    hp, strength, vitality = tonumber(hp), tonumber(strength), tonumber(vitality)
    local soldiers_raw = string.split(raw_data.soldiers, ";")
    return {
        dragon = {
            dragonType = dragonType,
            currentHp = tonumber(hp),
            totalHp = hp,
            hpMax = hp,
            strength = strength,
            vitality = vitality,
        },
        soldiers = LuaUtils:table_map(soldiers_raw, function(k, v)
            local soldierType, count = unpack(string.split(v, ","))
            count = tonumber(count)
            local name, star = unpack(string.split(soldierType, "_"))
            return k, {
                name = name,
                star = tonumber(star),
                morale = 100,
                currentCount = count,
                totalCount = count,
                woundedCount = 0,
                round = 0
            }
        end),
        rewards = self:DecodeToRewards(raw_data.rewards),
    }
end
function PVEObject:DecodeToRewards(raw)
    local rewards_raw = string.split(raw, ";")
    return LuaUtils:table_map(rewards_raw, function(k, v)
        local rtype, rname, count = unpack(string.split(v, ","))
        count = tonumber(count)
        return k, {
            type = rtype,
            name = rname,
            count = count,
        }
    end)
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














