local NORMAL = GameDatas.UnitsConfig.normal
local SPECIAL = GameDatas.UnitsConfig.special
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local SoldierManager = class("SoldierManager", MultiObserver)

SoldierManager.LISTEN_TYPE = Enum("SOLDIER_CHANGED","TREAT_SOLDIER_CHANGED")

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
    self.treatSoldiers_map = {
        ["ballista"] = 0,
        ["archer"] = 0,
        ["lancer"] = 0,
        ["crossbowman"] = 0,
        ["horseArcher"] = 0,
        ["swordsman"] = 0,
        ["sentinel"] = 0,
        ["catapult"] = 0,
    }
end
function SoldierManager:GetSoldierMap()
    return self.soldier_map
end
function SoldierManager:GetTreatSoldierMap()
    return self.treatSoldiers_map
end
function SoldierManager:GetCountBySoldierType(soldier_type)
    return self.soldier_map[soldier_type]
end
function SoldierManager:GetTreatCountBySoldierType(soldier_type)
    return self.treatSoldiers_map[soldier_type]
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
function SoldierManager:GetTreatResource()
    local total_iron,total_stone,total_wood,total_food = 0,0,0,0
    for k, v in pairs(self.treatSoldiers_map) do
        total_iron = total_iron + NORMAL[k.."_"..self:GetStarBySoldierType()].treatIron*v
        total_stone = total_iron + NORMAL[k.."_"..self:GetStarBySoldierType()].treatStone*v
        total_wood = total_iron + NORMAL[k.."_"..self:GetStarBySoldierType()].treatWood*v
        total_food = total_iron + NORMAL[k.."_"..self:GetStarBySoldierType()].treatFood*v
    end
    return total_iron,total_stone,total_wood,total_food
end
function SoldierManager:GetTreatAllTime()
    local total_time= 0
    for k, v in pairs(self.treatSoldiers_map) do
        total_time = total_time + NORMAL[k.."_"..self:GetStarBySoldierType()].treatTime*v
    end
    return total_time
end
function SoldierManager:GetTotalSoldierCount()
    local total_count = 0
    for k, v in pairs(self.soldier_map) do
        total_count = total_count + v
    end
    return total_count
end
function SoldierManager:GetTotalTreatSoldierCount()
    local total_count = 0
    for k, v in pairs(self.treatSoldiers_map) do
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
        self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED,function(listener)
            listener:OnSoliderCountChanged(self, changed)
        end)
    end
    -- 伤兵列表
    local treatSoldiers = user_data.treatSoldiers
    local treat_soldier_changed = {}
    for k,v in pairs(self.treatSoldiers_map) do
        if treatSoldiers[k] ~= v then
            table.insert(treat_soldier_changed,k)
        end
    end
    self.treatSoldiers_map = user_data.treatSoldiers
    if #treat_soldier_changed > 0 then
        self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.TREAT_SOLDIER_CHANGED,function(listener)
            listener:OnTreatSoliderCountChanged(self, treat_soldier_changed)
        end)
    end
end


return SoldierManager



