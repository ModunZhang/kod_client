
local NORMAL = GameDatas.UnitsConfig.normal
local config_function = GameDatas.BuildingFunction.hospital
local Observer = import(".Observer")
local Enum = import("..utils.Enum")
local UpgradeBuilding = import(".UpgradeBuilding")
local HospitalUpgradeBuilding = class("HospitalUpgradeBuilding", UpgradeBuilding)
HospitalUpgradeBuilding.CAN_NOT_TREAT = Enum("TREATING","LACK_RESOURCE","TREATING_AND_LACK_RESOURCE")

function HospitalUpgradeBuilding:ctor(building_info)
    self.hospital_building_observer = Observer.new()
    self.soldier_star = 1
    self.treat_event = self:CreateEvent()
    HospitalUpgradeBuilding.super.ctor(self, building_info)
end
function HospitalUpgradeBuilding:CreateEvent()
    local hospital = self
    local event = {}
    function event:Init()
        self:Reset()
    end
    function event:Reset()
        self.soldiers = nil
        self.finished_time = 0
    end
    function event:SetTreatInfo(soldiers, finish_time)
        self.soldiers = soldiers
        self.finished_time = finish_time
    end
    function event:StartTime()
        return self.finished_time - self:GetTreatingTime()
    end
    function event:GetTreatingTime()
        return hospital:GetTreatingTimeByTypeWithCount(self.soldiers)
    end
    function event:ElapseTime(current_time)
        return current_time - self:StartTime()
    end
    function event:LeftTime(current_time)
        return self.finished_time - current_time
    end
    function event:Percent(current_time)
        local start_time = self:StartTime()
        local elapse_time = current_time - start_time
        local total_time = self.finished_time - start_time
        return elapse_time * 100.0 / total_time
    end
    function event:FinishTime()
        return self.finished_time
    end
    function event:SetFinishTime(current_time)
        self.finished_time = current_time
    end
    function event:IsEmpty()
        return self.soldiers == nil
    end
    function event:IsTreating()
        return not not self.soldiers
    end
    function event:GetTreatInfo()
        return self.soldiers
    end
    event:Init()
    return event
end
function HospitalUpgradeBuilding:AddHospitalListener(listener)
    assert(listener.OnBeginTreat)
    assert(listener.OnTreating)
    assert(listener.OnEndTreat)
    self.hospital_building_observer:AddObserver(listener)
end
function HospitalUpgradeBuilding:RemoveHospitalListener(listener)
    self.hospital_building_observer:RemoveObserver(listener)
end
function HospitalUpgradeBuilding:GetTreatEvent()
    return self.treat_event
end
function HospitalUpgradeBuilding:IsTreatEventEmpty()
    return self.treat_event:IsEmpty()
end
function HospitalUpgradeBuilding:IsTreating()
    return not self.treat_event:IsEmpty()
end
function HospitalUpgradeBuilding:TreatSoldiersWithFinishTime(soldiers, finish_time)
    local event = self.treat_event
    event:SetTreatInfo(soldiers, finish_time)
    self.hospital_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginTreat(self, event)
    end)
end
function HospitalUpgradeBuilding:EndTreatSoldiersWithCurrentTime(current_time)
    local event = self.treat_event
    local soldiers = self.treat_event.soldiers
    event:SetTreatInfo(nil, 0)
    self.hospital_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndTreat(self, event, soldiers, current_time)
    end)
end
-- 获取治疗士兵时间
function HospitalUpgradeBuilding:GetTreatingTimeByTypeWithCount(soldiers)
    local treat_time = 0
    for k,v in pairs(soldiers) do
        local soldier_type = v.name
        local count = v.count
        local soldier_config = self:GetSoldierConfigByType(soldier_type)
        treat_time = treat_time + soldier_config["treatTime"] * count
    end
    return treat_time
end
function HospitalUpgradeBuilding:GetSoldierConfigByType(soldier_type)
    local soldier_name = string.format("%s_%d", soldier_type, self.soldier_star)
    return NORMAL[soldier_name]
end
function HospitalUpgradeBuilding:OnTimer(current_time)
    local event = self.treat_event
    if event:IsTreating() then
        self.hospital_building_observer:NotifyObservers(function(lisenter)
            lisenter:OnTreating(self, event, current_time)
        end)
    end
    HospitalUpgradeBuilding.super.OnTimer(self, current_time)
end

function HospitalUpgradeBuilding:OnUserDataChanged(...)
    HospitalUpgradeBuilding.super.OnUserDataChanged(self, ...)

    local arg = {...}
    local current_time = arg[2]
    if arg[1].treatSoldierEvents then
        local soldierEvent = arg[1].treatSoldierEvents[1]
        -- LuaUtils:outputTable("arg[1]arg[1]arg[1]arg[1]arg[1]====", arg[1])
        -- LuaUtils:outputTable("soldierEvent[1]====", soldierEvent)
        if soldierEvent then
            local finished_time = soldierEvent.finishTime / 1000
            if self.treat_event:IsEmpty() then
                self:TreatSoldiersWithFinishTime(soldierEvent.soldiers, finished_time)
            else
                self.treat_event:SetTreatInfo(soldierEvent.soldiers, finished_time)
            end
        else
            if self.treat_event:IsTreating() then
                self:EndTreatSoldiersWithCurrentTime(current_time)
            end
        end
    end
end

function HospitalUpgradeBuilding:IsAbleToTreat(soldiers)
    local total_iron,total_stone,total_wood,total_food = City:GetSoldierManager():GetTreatResource(soldiers)
    local resource_state =  City:GetResourceManager():GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_wood
        or City:GetResourceManager():GetFoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_food
        or City:GetResourceManager():GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_iron
        or City:GetResourceManager():GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_stone

    if self:IsTreating() and resource_state then
        return HospitalUpgradeBuilding.CAN_NOT_TREAT.TREATING_AND_LACK_RESOURCE
    elseif self:IsTreating() then
        return HospitalUpgradeBuilding.CAN_NOT_TREAT.TREATING
    elseif resource_state then
        return HospitalUpgradeBuilding.CAN_NOT_TREAT.LACK_RESOURCE
    end
end
-- 普通治疗需要的宝石
function HospitalUpgradeBuilding:GetTreatGems(soldiers)
    local total_iron,total_stone,total_wood,total_food = City:GetSoldierManager():GetTreatResource(soldiers)
    local resource_state =  City:GetResourceManager():GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_wood
        or City:GetResourceManager():GetFoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_food
        or City:GetResourceManager():GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_iron
        or City:GetResourceManager():GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())<total_stone

    local need_gems = 0
    if resource_state then
        need_gems = DataUtils:buyResource({wood=total_wood,
            stone=total_stone,
            iron=total_iron,
            food=total_food},{wood=City:GetResourceManager():GetWoodResource(),
            stone=City:GetResourceManager():GetStoneResource(),
            iron=City:GetResourceManager():GetIronResource(),
            food=City:GetResourceManager():GetFoodResource()})
    end
    if self:IsTreating() then
        need_gems = need_gems +DataUtils:getGemByTimeInterval(self:GetTreatEvent():LeftTime(app.timer:GetServerTime()))
    end
    return need_gems
end
--  立即治疗需要宝石
function HospitalUpgradeBuilding:GetTreatNowGems(soldiers)
    local total_time = City:GetSoldierManager():GetTreatTime(soldiers)
    need_gems = DataUtils:getGemByTimeInterval(total_time)
    local total_iron,total_stone,total_wood,total_food = City:GetSoldierManager():GetTreatResource(soldiers)
    need_gems = need_gems + DataUtils:buyResource({wood=total_wood,
        stone=total_stone,
        iron=total_iron,
        food=total_food},{})
    return need_gems
end

--获取下一级伤病最大上限
function HospitalUpgradeBuilding:GetNextLevelMaxCasualty()
    return config_function[self:GetNextLevel()].maxCasualty
end
--获取伤病最大上限
function HospitalUpgradeBuilding:GetMaxCasualty()
    return config_function[self:GetLevel()].maxCasualty
end
--获取战斗伤病比例
function HospitalUpgradeBuilding:GetCasualtyRate()
    return config_function[self:GetLevel()].casualtyRate
end

return HospitalUpgradeBuilding









