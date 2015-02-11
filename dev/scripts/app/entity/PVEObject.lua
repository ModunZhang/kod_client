local Localize_item = import("..utils.Localize_item")
local Localize = import("..utils.Localize")
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
local m = {
    __add = function(a, b)
        local r = {}
        for _, v in ipairs(a) do
            r[v.type] = v
        end
        for _, v in ipairs(b) do
            local av = r[v.type]
            if av then
                av.count = av.count + v.count
            else
                r[v.type] = v
            end
        end
        local r1 = {}
        for _, v in pairs(r) do
            r1[#r1 + 1] = v
        end
        setmetatable(r1, getmetatable(a))
        return r1
    end,
    __tostring = function(a)
        return table.concat(LuaUtils:table_map(a, function(k, v)
            local txt
            if v.type == "items" then
                txt = string.format("%s x%d", Localize_item.item_name[v.name], v.count)
            elseif v.type == "resources" then
                txt = string.format("%s x%d", Localize.fight_reward[v.name], v.count)
            end
            return k, txt
        end), ",")
    end,
    __concat = function(a, b)
        return string.format("%s%s", tostring(a), tostring(b))
    end,
}
function PVEObject:GetRewards(select)
    for k, v in pairs(PVEDefine) do
        if v == self.type then
            local rewards = self:DecodeToRewards(pve_npc[k].rewards)
            if pve_npc[k].rewards_type == "all" then
                return rewards
            elseif pve_npc[k].rewards_type == "select" then
                assert(rewards[select], "选择不存在")
                local r = {rewards[select]}
                setmetatable(r, m)
                return r
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
                        local r = {reward}
                        setmetatable(r, m)
                        return r
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
            count = count,
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















