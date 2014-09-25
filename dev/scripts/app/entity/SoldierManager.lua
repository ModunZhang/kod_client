local NORMAL = GameDatas.UnitsConfig.normal
local SPECIAL = GameDatas.UnitsConfig.special
local Observer = import(".Observer")
local SoldierManager = class("SoldierManager", Observer)

function SoldierManager:ctor()
    SoldierManager.super.ctor(self)
    self.soldier_map = {
        ["sentinel"] = 0,
        ["crossbowman"] = 0,
        ["lancer"] = 0,
        ["archer"] = 0,
        ["horseArcher"] = 0,
        ["steamTank"] = 0,
        ["meatWagon"] = 0,
        ["catapult"] = 0,
        ["ballista"] = 0,
        ["deathKnight"] = 0,
        ["swordsman"] = 0,
        ["skeletonArcher"] = 0,
        ["demonHunter"] = 0,
        ["paladin"] = 0,
        ["priest"] = 0,
        ["skeletonWarrior"] = 0,
    }
end
function SoldierManager:GetSoldierMap()
    return self.soldier_map
end
function SoldierManager:GetCountBySoldierType(soldier_type)
    return self.soldier_map[soldier_type]
end
function SoldierManager:GetMarchSoldierCount()
    return 0
end
function SoldierManager:GetStarBySoldierType(soldier_type)
    return 1
end
function SoldierManager:GetGarrisonSoldierCount()
    return self:GetTotalSoldierCount()
end
function SoldierManager:GetTotalUpkeep()
    local total_upkeep = 0
    for k, v in pairs(self.soldier_map) do
        if NORMAL[k.."_"..self:GetStarBySoldierType()] then
            total_upkeep = total_upkeep + NORMAL[k.."_"..self:GetStarBySoldierType()].upkeep*v
        elseif SPECIAL[k] then
            total_upkeep = total_upkeep + SPECIAL[k].upkeep*v
        end
    end
    return total_upkeep
end
function SoldierManager:GetTotalSoldierCount()
    local total_count = 0
    for k, v in pairs(self.soldier_map) do
        total_count = total_count + v
    end
    return total_count
end
function SoldierManager:OnUserDataChanged(user_data)
    local soldiers = user_data.soldiers
    local changed = {}
    for k, v in pairs(self.soldier_map) do
        if soldiers[k] ~= v then
            table.insert(changed, k)
        end
    end
    self.soldier_map = user_data.soldiers
    if #changed > 0 then
        self:NotifyObservers(function(listener)
            listener:OnSoliderCountChanged(self, changed)
        end)
    end
end


return SoldierManager

