local NORMAL = GameDatas.UnitsConfig.normal
local SPECIAL = GameDatas.UnitsConfig.special
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local SoldierManager = class("SoldierManager", MultiObserver)

SoldierManager.LISTEN_TYPE = Enum("SOLDIER_CHANGED","TREAT_SOLDIER_CHANGED")

function SoldierManager:ctor()
    SoldierManager.super.ctor(self)
    self.soldier_map = {}
    self.treatSoldiers_map = {}
end
function SoldierManager:IteratorSoldiers(func)
    for k, v in pairs(self:GetSoldierMap()) do
        if func(k, v) then
            return
        end
    end
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
-- 获取派兵上限
function SoldierManager:GetTroopPopulation()
    local armyCamps = City:GetBuildingByType("armyCamp")
    local troopPopulation = 0
    for k,v in pairs(armyCamps) do
        troopPopulation = troopPopulation + v:GetTroopPopulation()
    end
    return troopPopulation
end
function SoldierManager:GetTotalUpkeep()
    local total = 0
    for k, v in pairs(self.soldier_map) do
        if NORMAL[k.."_"..self:GetStarBySoldierType()] then
            total = total + NORMAL[k.."_"..self:GetStarBySoldierType()].consumeFood * v
        elseif SPECIAL[k] then
            total = total + SPECIAL[k].consumeFood * v
        end
    end
    return total
end
function SoldierManager:GetTreatResource(soldiers)
    local total_iron,total_stone,total_wood,total_food = 0,0,0,0
    for k, v in pairs(soldiers) do
        total_iron = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType()].treatIron*v.count
        total_stone = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType()].treatStone*v.count
        total_wood = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType()].treatWood*v.count
        total_food = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType()].treatFood*v.count
    end
    return total_iron,total_stone,total_wood,total_food
end
function SoldierManager:GetTreatTime(soldiers)
    local treat_time = 0
    for k, v in pairs(soldiers) do
        total_iron = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType()].treatTime*v.count
    end
    return treat_time
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
    if user_data.soldiers then
        local soldiers = user_data.soldiers
        local changed = {}
        local soldier_map = self.soldier_map
        for k, new in pairs(soldiers) do
            if soldier_map[k] ~= new then
                soldier_map[k] = new
                table.insert(changed, k)
            end
        end
        if #changed > 0 then
            self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED,function(listener)
                listener:OnSoliderCountChanged(self, changed)
            end)
        end
    end
    if user_data.treatSoldiers then
        -- 伤兵列表
        local treatSoldiers = user_data.treatSoldiers
        local treat_soldier_changed = {}
        local treatSoldiers_map = self.treatSoldiers_map
        for k, new in pairs(treatSoldiers) do
            if treatSoldiers_map[k] ~= new then
                treatSoldiers_map[k] = new
                table.insert(treat_soldier_changed, k)
            end
        end
        if #treat_soldier_changed > 0 then
            self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.TREAT_SOLDIER_CHANGED,function(listener)
                listener:OnTreatSoliderCountChanged(self, treat_soldier_changed)
            end)
        end
    end
end


return SoldierManager




