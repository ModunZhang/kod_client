local NORMAL = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local MilitaryTechnology = import(".MilitaryTechnology")
local MilitaryTechEvents = import(".MilitaryTechEvents")
local SoldierStarEvents = import(".SoldierStarEvents")

local SoldierManager = class("SoldierManager", MultiObserver)

SoldierManager.LISTEN_TYPE = Enum("SOLDIER_CHANGED",
    "TREAT_SOLDIER_CHANGED",
    "SOLDIER_STAR_CHANGED",
    "MILITARY_TECHS_EVENTS_CHANGED",
    "MILITARY_TECHS_EVENTS_ALL_CHANGED",
    "MILITARY_TECHS_DATA_CHANGED",
    "SOLDIER_STAR_EVENTS_CHANGED",
    "OnSoldierStarEventsTimer",
    "OnMilitaryTechEventsTimer")

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

    app.timer:AddListener(self)
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
        local config = NORMAL[config_name] or SPECIAL[k]
        total = total + config.consumeFoodPerHour * v
    end
    if ItemManager:IsBuffActived("quarterMaster") then
        total = math.ceil(total * (1 - ItemManager:GetBuffEffect("quarterMaster")))
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
function SoldierManager:GetMilitaryTechsByName(name)
    return self.militaryTechs[name]
end
function SoldierManager:IteratorMilitaryTechs(func)
    for name,v in pairs(self.militaryTechs) do
        func(name,v)
    end
end

function SoldierManager:GetAllMilitaryBuffData()
    local all_military_buff = {}
    self:IteratorMilitaryTechs(function(name,tech)
        if tech:Level() > 0 then
            local effect_soldier,buff_field = unpack(string.split(name,"_"))
            table.insert(all_military_buff,{effect_soldier,buff_field,tech:GetAtkEff()})
        end
    end)
    return all_military_buff
end

function SoldierManager:GetMilitaryTechByName(name)
    return self.militaryTechs[name]
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
function SoldierManager:IteratorMilitaryTechEvents(func)
    for _,v in pairs(self.militaryTechEvents) do
        func(v)
    end
end
function SoldierManager:GetLatestMilitaryTechEvents(building_type)
    for _,event in pairs(self.militaryTechEvents) do
        if self.militaryTechs[event:Name()]:Building() == building_type then
            return event
        end
    end
end
function SoldierManager:GetUpgradingMilitaryTechNum(building_type)
    local count = 0
    for _,event in pairs(self.militaryTechEvents) do
        if self.militaryTechs[event:Name()]:Building() == building_type then
            count = count + 1
        end
    end
    for _,event in pairs(self.soldierStarEvents) do
        if self:FindSoldierBelongBuilding(event:Name()) == building_type then
            count = count + 1
        end
    end
    return count
end
function SoldierManager:GetTotalUpgradingMilitaryTechNum()
    local count = LuaUtils:table_size(self.militaryTechEvents) + LuaUtils:table_size(self.soldierStarEvents)
    return count >4 and 4 or count
end
-- 对应建筑可以升级对应军事科技和兵种星级
function SoldierManager:IsUpgradingMilitaryTech(building_type)
    for _,event in pairs(self.militaryTechEvents) do
        if self.militaryTechs[event:Name()]:Building() == building_type then
            return true
        end
    end
    for _,event in pairs(self.soldierStarEvents) do
        if self:FindSoldierBelongBuilding(event:Name()) == building_type then
            return true
        end
    end
end
function SoldierManager:GetUpgradingMilitaryTech(building_type)
    local military_tech_event = self:GetLatestMilitaryTechEvents(building_type)
    local soldier_star_event = self:GetLatestSoldierStarEvents(building_type)
    local tech_start_time = military_tech_event and military_tech_event.startTime or 0
    local soldier_star_start_time = soldier_star_event and soldier_star_event.startTime or 0
    return  tech_start_time>soldier_star_start_time and military_tech_event or soldier_star_event
end
function SoldierManager:GetSoldierMaxStar()
    return 3
end
function SoldierManager:GetUpgradingMitiTaryTechLeftTimeByCurrentTime(building_type)
    local left_time = 0
    local event = self:GetUpgradingMilitaryTech(building_type)
    if event then
        left_time = left_time + event:FinishTime()/1000 - app.timer:GetServerTime()
    end
    return left_time
end
function SoldierManager:OnMilitaryTechEventsChanged(militaryTechEvents)
    if not militaryTechEvents then return end
    self.militaryTechEvents = {}
    for i,v in ipairs(militaryTechEvents) do
        local event = MilitaryTechEvents.new()
        event:UpdateData(v)
        event:AddObserver(self)
        self.militaryTechEvents[event:Id()] = event
    end
    self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_ALL_CHANGED, function(listener)
        listener:OnMilitaryTechEventsAllChanged(self,self.militaryTechEvents)
    end)
end
function SoldierManager:__OnMilitaryTechEventsChanged(__militaryTechEvents)
    if not __militaryTechEvents then return end
    local changed_map = GameUtils:Event_Handler_Func(
        __militaryTechEvents
        ,function(data)
            local event = MilitaryTechEvents.new()
            event:UpdateData(data)
            self.militaryTechEvents[event:Id()] = event
            event:AddObserver(self)
            return event
        end
        ,function(data)
            local event = self.militaryTechEvents[data.id]
            event:UpdateData(data)
            return event
        end
        ,function(data)
            local event = self.militaryTechEvents[data.id]
            event:Reset()
            self.militaryTechEvents[data.id] = nil
            event = MilitaryTechEvents.new()
            event:UpdateData(data)
            return event
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
function SoldierManager:FindSoldierBelongBuilding(soldier_type)
    if soldier_type=="sentinel" or soldier_type=="swordsman" then
        return "trainingGround"
    elseif soldier_type=="horseArcher" or soldier_type=="lancer" then
        return "stable"
    elseif soldier_type=="ranger" or soldier_type=="crossbowman" then
        return "hunterHall"
    elseif soldier_type=="ballista" or soldier_type=="catapult"then
        return "workshop"
    end
end
function SoldierManager:GetSoldierStarEvents()
    return self.soldierStarEvents
end
function SoldierManager:IteratorSoldierStarEvents(func)
    for _,v in pairs(self.soldierStarEvents) do
        func(v)
    end
end
function SoldierManager:GetLatestSoldierStarEvents(building_type)
    for _,event in pairs(self.soldierStarEvents) do
        if self:FindSoldierBelongBuilding(event:Name()) == building_type then
            return event
        end
    end
end
function SoldierManager:OnSoldierStarEventsChanged(soldierStarEvents)
    if not soldierStarEvents then return end
    for i,v in ipairs(soldierStarEvents) do
        local event = SoldierStarEvents.new()
        event:UpdateData(v)
        event:AddObserver(self)
        self.soldierStarEvents[event:Id()] = event
    end
end
function SoldierManager:GetPromotingSoldierName(building_type)
    local event = self:GetLatestSoldierStarEvents(building_type)
    if event then
        return event:Name()
    end
end
function SoldierManager:__OnSoldierStarEventsChanged(__soldierStarEvents)
    if not __soldierStarEvents then return end
    -- LuaUtils:outputTable("__soldierStarEvents", __soldierStarEvents)
    local changed_map = GameUtils:Event_Handler_Func(
        __soldierStarEvents
        ,function(data)
            local event = SoldierStarEvents.new()
            event:UpdateData(data)
            event:AddObserver(self)
            self.soldierStarEvents[event:Id()] = event
            return event
        end
        ,function(data)
            local event = self.soldierStarEvents[data.id]
            event:UpdateData(data)
            return event
        end
        ,function(data)
            local event = self.soldierStarEvents[data.id]
            event:Reset()
            self.soldierStarEvents[data.id] = nil
            local event = SoldierStarEvents.new()
            event:UpdateData(data)
            return event
        end
    )
    self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED, function(listener)
        listener:OnSoldierStarEventsChanged(self,changed_map)
    end)
end

function SoldierManager:OnTimer(current_time)
    self:IteratorSoldierStarEvents(function(star_event)
        star_event:OnTimer(current_time)
    end)
    self:IteratorMilitaryTechEvents(function(tech_event)
        tech_event:OnTimer(current_time)
    end)
end
function SoldierManager:OnSoldierStarEventsTimer(star_event)
    self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.OnSoldierStarEventsTimer,function(lisenter)
        lisenter.OnSoldierStarEventsTimer(lisenter,star_event)
    end)
end
function SoldierManager:OnMilitaryTechEventsTimer(tech_event)
    self:NotifyListeneOnType(SoldierManager.LISTEN_TYPE.OnMilitaryTechEventsTimer,function(lisenter)
        lisenter.OnMilitaryTechEventsTimer(lisenter,tech_event)
    end)
end
return SoldierManager

















