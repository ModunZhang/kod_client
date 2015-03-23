local NotifyItem = import(".NotifyItem")
local PVEDefine = import(".PVEDefine")
local PVEObject = class("PVEObject")
local pve_normal = GameDatas.ClientInitGame.pve_normal
local pve_elite = GameDatas.ClientInitGame.pve_elite
local pve_boss = GameDatas.ClientInitGame.pve_boss
local pve_npc = GameDatas.ClientInitGame.pve_npc
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
    [PVEDefine.TRAP] = 0,
}

local normal_map = {
    [PVEDefine.WOODCUTTER] = true,
    [PVEDefine.QUARRIER] = true,
    [PVEDefine.MINER] = true,
    [PVEDefine.FARMER] = true,
    [PVEDefine.TRAP] = true,
}
local elite_map = {
    [PVEDefine.CAMP] = true,
    [PVEDefine.CRASHED_AIRSHIP] = true,
}

function PVEObject:ctor(x, y, searched, type, map)
    self.x = x
    self.y = y
    self.searched = searched or 0
    self.type = type
    self.map = map
end
function PVEObject:NpcPower()
    return self.map:GetIndex()
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
    local unique = self.type ~= PVEDefine.TRAP and random(#pve_normal) or self.x * self.y * (index + self.type)
    if normal_map[self.type] then
        return self:DecodeToEnemy(pve_normal[unique % #pve_normal + 1])
    elseif elite_map[self.type] then
        return self:DecodeToEnemy(pve_elite[unique % #pve_elite + 1])
    elseif self.type == PVEDefine.ENTRANCE_DOOR then
        return self:DecodeToEnemy(pve_boss[1])
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
                power = GameUtils:GetSoldiersConfig(name, tonumber(star)).power,
                star = tonumber(star),
                morale = 100,
                currentCount = count * self:NpcPower(),
                totalCount = count * self:NpcPower(),
                woundedCount = 0,
                round = 0
            }
        end),
        rewards = self:DecodeToRewards(raw_data.rewards),
    }
end
local m = getmetatable(NotifyItem)
function PVEObject:GetRewards(select)
    for k, v in pairs(PVEDefine) do
        if v == self.type then
            local rewards = self:DecodeToRewards(pve_npc[k].rewards)
            if pve_npc[k].rewards_type == "all" then
                return rewards
            elseif pve_npc[k].rewards_type == "select" then
                return setmetatable({rewards[select]}, m)
            elseif pve_npc[k].rewards_type == "random" then
                local p = 0
                for _, reward in ipairs(rewards) do
                    p = p + reward.probability
                end
                local p = random(p)
                for _, reward in ipairs(rewards) do
                    if p > reward.probability then
                        p = p - reward.probability
                    else
                        return setmetatable({reward}, m)
                    end
                end
            else
                assert(false)
            end
        end
    end
end
function PVEObject:DecodeToRewards(raw)
    local rewards_raw = string.split(raw, ";")
    local r = LuaUtils:table_map(rewards_raw, function(k, v)
        local rtype, rname, count, probability = unpack(string.split(v, ","))
        count = tonumber(count)
        probability = probability or 100
        probability = tonumber(probability)
        return k, {
            type = rtype,
            name = rname,
            count = count * self:NpcPower(),
            probability = probability
        }
    end)
    setmetatable(r, m)
    return r
end
function PVEObject:IsUnSearched()
    return self:Searched() == 0
end
function PVEObject:IsSearched()
    return self:Searched() >= self:Total() and self:Searched() > 0
end
function PVEObject:SearchNext()
    self.searched = self.searched + 1
end
function PVEObject:IsLast()
    return self:Left() == 1
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
function PVEObject:IsEntranceDoor()
    return self.type == PVEDefine.ENTRANCE_DOOR
end
function PVEObject:Dump()
    return string.format("[%d,%d,%d]", self.x, self.y, self.searched)
end

return PVEObject















