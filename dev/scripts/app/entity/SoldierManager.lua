local NORMAL = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local MilitaryTechnology = import(".MilitaryTechnology")
local SoldierManager = class("SoldierManager", MultiObserver)

SoldierManager.LISTEN_TYPE = Enum("SOLDIER_CHANGED",
    "TREAT_SOLDIER_CHANGED",
    "SOLDIER_STAR_CHANGED",
    "MILITARY_TECHS_EVENTS_CHANGED",
    "MILITARY_TECHS_DATA_CHANGED",
    "SOLDIER_STAR_EVENTS_CHANGED")

function SoldierManager:ctor()
    SoldierManager.super.ctor(self)
    self.soldier_map = {
        ["sentinel"] = 0,
        ["deathKnight"] = 0,
        ["lancer"] = 0,
        ["crossbowman"] = 0,
        ["horseArcher"] = 0,
        ["steamTank"] = 0,
        ["meatWagon"] = 0,
        ["catapult"] = 0,
        ["ballista"] = 0,
        ["ranger"] = 0,
        ["swordsman"] = 0,
        ["skeletonArcher"] = 0,
        ["demonHunter"] = 0,
        ["paladin"] = 0,
        ["priest"] = 0,
        ["skeletonWarrior"] = 0,
    }
    self.treatSoldiers_map = {
        ["ballista"] = 0,
        ["ranger"] = 0,
        ["catapult"] = 0,
        ["crossbowman"] = 0,
        ["horseArcher"] = 0,
        ["swordsman"] = 0,
        ["sentinel"] = 0,
        ["lancer"] = 0,
    }
    self.soldierStars = {
        ["ballista"]    = 1,
        ["catapult"]    = 1,
        ["crossbowman"] = 1,
        ["horseArcher"] = 1,
        ["lancer"]     = 1,
        ["ranger"]     = 1,
        ["sentinel"]    = 1,
        ["swordsman"]   = 1,
    }
    self.soldierStarEvents = {}
    self.militaryTechEvents = {}
    self.militaryTechs = {}
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
    return SPECIAL[soldier_type] and SPECIAL[soldier_type].star or self.soldierStars[soldier_type]
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
        local config_name = k.."_"..self:GetStarBySoldierType(k)
        local config = NORMAL[config_name] or SPECIAL[config_name]
        total = total + config.consumeFood * v
    end
    return total
end
function SoldierManager:GetTreatResource(soldiers)
    local total_iron,total_stone,total_wood,total_food = 0,0,0,0
    for k, v in pairs(soldiers) do
        total_iron = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType(v.name)].treatIron*v.count
        total_stone = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType(v.name)].treatStone*v.count
        total_wood = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType(v.name)].treatWood*v.count
        total_food = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType(v.name)].treatFood*v.count
    end
    return total_iron,total_stone,total_wood,total_food
end
function SoldierManager:GetTreatTime(soldiers)
    local treat_time = 0
    for k, v in pairs(soldiers) do
        total_iron = total_iron + NORMAL[v.name.."_"..self:GetStarBySoldierType(k)].treatTime*v.count
    end
    return treat_time
end
function SoldierManager:GetTreatAllTime()
    local total_time= 0
    for k, v in pairs(self.treatSoldiers_map) do
        total_time = total_time + NORMAL[k.."_"..self:GetStarBySoldierType(k)].treatTime*v
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
        for k, old in pairs(soldier_map) do
            local new = soldiers[k]
            if new and old ~= new then
                soldier_map[k] = new
                table.insert(changed, k)
            end
        end
        -- for k, new in pairs(soldiers) do
        --     if soldier_map[k] ~= new then
        --         soldier_map[k] = new
        --         table.insert(changed, k)
        --     end
        -- end
        if #changed > 0 then
            self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED,function(listener)
                listener:OnSoliderCountChanged(self, changed)
            end)
        end
    end
    if user_data.woundedSoldiers then
        -- 伤兵列表
        local treatSoldiers = user_data.woundedSoldiers
        local treat_soldier_changed = {}
        local treatSoldiers_map = self.treatSoldiers_map
        for k, old in pairs(treatSoldiers_map) do
            local new = treatSoldiers[k]
            if new and old ~= new then
                treatSoldiers_map[k] = new
                table.insert(treat_soldier_changed, k)
            end
        end
        -- for k, new in pairs(treatSoldiers) do
        --     if treatSoldiers_map[k] ~= new then
        --         treatSoldiers_map[k] = new
        --         table.insert(treat_soldier_changed, k)
        --     end
        -- end
        if #treat_soldier_changed > 0 then
            self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.TREAT_SOLDIER_CHANGED,function(listener)
                listener:OnTreatSoliderCountChanged(self, treat_soldier_changed)
            end)
        end
    end
    if user_data.soldierStars then
        local soldierStars = user_data.soldierStars
        local soldier_star_changed = {}
        for k,v in pairs(soldierStars) do
            self.soldierStars[k] = v
            table.insert(soldier_star_changed, k)
        end
        if #soldier_star_changed > 0 then
            self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.SOLDIER_STAR_CHANGED,function(listener)
                listener:OnSoliderStarCountChanged(self, soldier_star_changed)
            end)
        end
    end
    --军事科技
    self:OnMilitaryTechsDataChanged(user_data.militaryTechs)
    self:OnMilitaryTechEventsChanged(user_data.militaryTechEvents)
    self:__OnMilitaryTechEventsChanged(user_data.__militaryTechEvents)
    -- 士兵升星
    self:OnSoldierStarEventsChanged(user_data.soldierStarEvents)
    self:__OnSoldierStarEventsChanged(user_data.__soldierStarEvents)

end

function SoldierManager:OnMilitaryTechsDataChanged(militaryTechs)
    if not militaryTechs then return end
    local changed_map = {}
    for name,v in pairs(militaryTechs) do
        local militaryTechnology = MilitaryTechnology.new()
        militaryTechnology:UpdateData(name,v)
        self.militaryTechs[name] = militaryTechnology
        changed_map[name] = militaryTechnology
    end
    self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.MILITARY_TECHS_DATA_CHANGED, function(listener)
        listener:OnMilitaryTechsDataChanged(self,changed_map)
    end)
end
function SoldierManager:GetMilitaryTechsLevelByName(name)
    return self.militaryTechs[name]:Level()
end
function SoldierManager:IteratorMilitaryTechs(func)
    for name,v in pairs(self.militaryTechs) do
        func(name,v)
    end
end
function SoldierManager:FindMilitaryTechsByBuildingType(building_type)
    local techs = {}
    self:IteratorMilitaryTechs(function ( name,v )
        if building_type == v:Building() then
            techs[name] = v
        end
    end)
    return techs
end
function SoldierManager:GetTechPointsByType(building_type)
    local config = GameDatas.MilitaryTechs.militaryTechs
    local techs = self:FindMilitaryTechsByBuildingType(building_type)

    local tech_points = 0
    for k,v in pairs(techs) do
        tech_points = tech_points + config[k].techPointPerLevel * v:Level()
    end
    return tech_points
end
function SoldierManager:GetMilitaryTechEvents()
    return self.militaryTechEvents
end
function SoldierManager:GetLatestMilitaryTechEvents()
    return self.militaryTechEvents[#self.militaryTechEvents]
end
function SoldierManager:GetUpgradingMilitaryTechNum()
    return LuaUtils:table_size(self.militaryTechEvents)+LuaUtils:table_size(self.soldierStarEvents)
end
function SoldierManager:IsUpgradingMilitaryTech()
    return LuaUtils:table_size(self.militaryTechEvents)>0 or LuaUtils:table_size(self.soldierStarEvents)>0
end
function SoldierManager:GetSoldierMaxStar()
    return 3
end
function SoldierManager:GetUpgradingLeftTimeByCurrentTime(current_time)
    local  left_time = 0
    local military_tech_event = self:GetLatestMilitaryTechEvents()
    local soldier_star_event = self:GetLatestSoldierStarEvents()
    local tech_start_time = military_tech_event and military_tech_event.startTime or 0
    local soldier_star_start_time = soldier_star_event and soldier_star_event.startTime or 0
    local event = tech_start_time>soldier_star_start_time and military_tech_event or soldier_star_event
    if event then
        left_time = left_time + event.finishTime/1000 - current_time
    end
    return left_time
end
function SoldierManager:OnMilitaryTechEventsChanged(militaryTechEvents)
    if not militaryTechEvents then return end
    LuaUtils:outputTable("OnMilitaryTechEventsChanged", militaryTechEvents)
    self.militaryTechEvents = militaryTechEvents
end
function SoldierManager:__OnMilitaryTechEventsChanged(__militaryTechEvents)
    if not __militaryTechEvents then return end
    -- LuaUtils:outputTable("__militaryTechEvents", __militaryTechEvents)
    local changed_map = GameUtils:Event_Handler_Func(
        __militaryTechEvents
        ,function(data)
            table.insert(self.militaryTechEvents, data)
            return data
        end
        ,function(data)
            for i,v in ipairs(self.militaryTechEvents) do
                if v.id == data.id then
                    self.militaryTechEvents[i] = v
                end
            end
            return data
        end
        ,function(data)
            for i,v in ipairs(self.militaryTechEvents) do
                if v.id == data.id then
                    self.militaryTechEvents[i] = nil
                end
            end
            return data
        end
    )
    self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED, function(listener)
        listener:OnMilitaryTechEventsChanged(self,changed_map)
    end)
end

function SoldierManager:FindSoldierStarByBuildingType(building_type)
    local soldiers_star = {}
    if building_type=="trainingGround" then
        soldiers_star.sentinel = self:GetStarBySoldierType("sentinel")
        soldiers_star.swordsman = self:GetStarBySoldierType("swordsman")
    elseif building_type=="stable" then
        soldiers_star.horseArcher = self:GetStarBySoldierType("horseArcher")
        soldiers_star.lancer = self:GetStarBySoldierType("lancer")
    elseif building_type=="hunterHall" then
        soldiers_star.ranger = self:GetStarBySoldierType("ranger")
        soldiers_star.crossbowman = self:GetStarBySoldierType("crossbowman")
    elseif building_type=="workshop" then
        soldiers_star.ballista = self:GetStarBySoldierType("ballista")
        soldiers_star.catapult = self:GetStarBySoldierType("catapult")
    end
    return soldiers_star
end
function SoldierManager:GetSoldierStarEvents()
    return self.soldierStarEvents
end
function SoldierManager:GetLatestSoldierStarEvents()
    return self.soldierStarEvents[#self.soldierStarEvents]
end
function SoldierManager:OnSoldierStarEventsChanged(soldierStarEvents)
    if not soldierStarEvents then return end
    self.soldierStarEvents = soldierStarEvents
end
function SoldierManager:GetPromotingSoldierName()
    local soldierStarEvents = self.soldierStarEvents
    local event = self:GetLatestSoldierStarEvents()
    if event then
        return event.name
    end
end
function SoldierManager:__OnSoldierStarEventsChanged(__soldierStarEvents)
    if not __soldierStarEvents then return end
    -- LuaUtils:outputTable("__soldierStarEvents", __soldierStarEvents)
    local changed_map = GameUtils:Event_Handler_Func(
        __soldierStarEvents
        ,function(data)
            table.insert(self.soldierStarEvents, data)
            return data
        end
        ,function(data)
            for i,v in ipairs(self.soldierStarEvents) do
                if v.id == data.id then
                    self.soldierStarEvents[i] = v
                end
            end
            return data
        end
        ,function(data)
            for i,v in ipairs(self.soldierStarEvents) do
                if v.id == data.id then
                    self.soldierStarEvents[i] = nil
                end
            end
            return data
        end
    )
    self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED, function(listener)
        listener:OnSoldierStarEventsChanged(self,changed_map)
    end)
end
return SoldierManager











