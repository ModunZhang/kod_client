local barracks_config = GameDatas.BuildingFunction.barracks
local NORMAL = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special
local promise = import("..utils.promise")
local Observer = import(".Observer")
local UpgradeBuilding = import(".UpgradeBuilding")
local BarracksUpgradeBuilding = class("BarracksUpgradeBuilding", UpgradeBuilding)

function BarracksUpgradeBuilding:ctor(...)
    self.barracks_building_observer = Observer.new()
    self.soldier_star = 1
    self.recruit_event = self:CreateEvent()
    BarracksUpgradeBuilding.super.ctor(self, ...)


    self.recruit_soldier_callbacks = {}
    self.finish_soldier_callbacks = {}
end
function BarracksUpgradeBuilding:CreateEvent()
    local barracks = self
    local event = {}
    function event:Init()
        self:Reset()
    end
    function event:Reset()
        self.soldier_type = nil
        self.soldier_count = 0
        self.finished_time = 0
        self.id = nil
    end
    function event:SetRecruitInfo(soldier_type, count, finish_time ,id )
        self.soldier_type = soldier_type
        self.soldier_count = count
        self.finished_time = finish_time
        self.id = id
    end
    function event:Id()
        return self.id
    end
    function event:StartTime()
        return self.finished_time - self:GetRecruitingTime()
    end
    function event:GetRecruitingTime()
        return barracks:GetRecruitingTimeByTypeWithCount(self.soldier_type, self.soldier_count)
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
        return self.soldier_type == nil
    end
    function event:IsRecruting()
        return not not self.soldier_type
    end
    function event:GetRecruitInfo()
        return self.soldier_type, self.soldier_count
    end
    function event:Describe()
    -- local soldier_type, count = event:GetRecruitInfo()
    -- local soldier_name = barracks:GetSoldierConfigByType(soldier_type).description
    end
    event:Init()
    return event
end
function BarracksUpgradeBuilding:ResetAllListeners()
    BarracksUpgradeBuilding.super.ResetAllListeners(self)
    self.barracks_building_observer:RemoveAllObserver()
end
function BarracksUpgradeBuilding:AddBarracksListener(listener)
    assert(listener.OnBeginRecruit)
    assert(listener.OnRecruiting)
    assert(listener.OnEndRecruit)
    self.barracks_building_observer:AddObserver(listener)
end
function BarracksUpgradeBuilding:RemoveBarracksListener(listener)
    self.barracks_building_observer:RemoveObserver(listener)
end
function BarracksUpgradeBuilding:GetRecruitEvent()
    return self.recruit_event
end
function BarracksUpgradeBuilding:IsRecruitEventEmpty()
    return self.recruit_event:IsEmpty()
end
function BarracksUpgradeBuilding:IsRecruting()
    return not self.recruit_event:IsEmpty()
end
function BarracksUpgradeBuilding:RecruitSoldiersWithFinishTime(soldier_type, count, finish_time,id)
    local event = self.recruit_event
    event:SetRecruitInfo(soldier_type, count, finish_time,id)
    self.barracks_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginRecruit(self, event)
    end)

    self:CheckRecruit(soldier_type)
end
function BarracksUpgradeBuilding:EndRecruitSoldiersWithCurrentTime(current_time)
    local event = self.recruit_event
    local soldier_type = self.recruit_event.soldier_type
    local soldier_count = self.recruit_event.soldier_count
    event:SetRecruitInfo(nil, 0, 0,nil)
    self.barracks_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndRecruit(self, event, soldier_type, soldier_count, current_time)
    end)

    self:CheckFinish(soldier_type)
end
function BarracksUpgradeBuilding:GetRecruitingTimeByTypeWithCount(soldier_type, count)
    return self:GetSoldierConfigByType(soldier_type).recruitTime * count
end
function BarracksUpgradeBuilding:GetSoldierConfigByType(soldier_type)
    local soldier_name = string.format("%s_%d", soldier_type, self.soldier_star)
    return NORMAL[soldier_name] or SPECIAL[soldier_type]
end
function BarracksUpgradeBuilding:GetNextLevelMaxRecruitSoldierCount()
    return barracks_config[self:GetNextLevel()].maxRecruit
end
function BarracksUpgradeBuilding:GetMaxRecruitSoldierCount()
    return barracks_config[self:GetLevel()].maxRecruit
end
function BarracksUpgradeBuilding:OnTimer(current_time)
    local event = self.recruit_event
    if event:IsRecruting() then
        self.barracks_building_observer:NotifyObservers(function(lisenter)
            lisenter:OnRecruiting(self, event, current_time)
        end)
    end
    BarracksUpgradeBuilding.super.OnTimer(self, current_time)
end
function BarracksUpgradeBuilding:OnUserDataChanged(...)
    BarracksUpgradeBuilding.super.OnUserDataChanged(self, ...)
    local userData, current_time, location_id, sub_location_id, deltaData = ...
    local is_fully_update = deltaData == nil
    local is_delta_update = self:IsUnlocked() and deltaData and deltaData.soldierEvents
    if not is_fully_update and not is_delta_update then
        return 
    end

    print("BarracksUpgradeBuilding:OnUserDataChanged")
    local event = userData.soldierEvents[1]
    if event then
        local finished_time = event.finishTime / 1000
        if self.recruit_event:IsEmpty() then
            self:RecruitSoldiersWithFinishTime(event.name, event.count, finished_time,event.id)
        else
            self.recruit_event:SetRecruitInfo(event.name, event.count, finished_time,event.id)
        end
    else
        if self.recruit_event:IsRecruting() then
            self:EndRecruitSoldiersWithCurrentTime(current_time)
        end
    end
end

-- fte
local function promiseOfSoldier(callbacks, soldier_type)
    assert(soldier_type)
    assert(#callbacks == 0)
    local p = promise.new()
    table.insert(callbacks, function(type_)
        if soldier_type == type_ then
            return p:resolve(soldier_type)
        end
    end)
    return p
end
local function checkSoldier(callbacks, soldier_type)
    if #callbacks > 0 and callbacks[1](soldier_type) then
        table.remove(callbacks, 1)
    end
end
function BarracksUpgradeBuilding:CheckRecruit(soldier_type)
    checkSoldier(self.recruit_soldier_callbacks, soldier_type)
end
function BarracksUpgradeBuilding:PromiseOfRecruitSoldier(soldier_type)
    return promiseOfSoldier(self.recruit_soldier_callbacks, soldier_type)
end
function BarracksUpgradeBuilding:CheckFinish(soldier_type)
    checkSoldier(self.finish_soldier_callbacks, soldier_type)
end
function BarracksUpgradeBuilding:PromiseOfFinishSoldier(soldier_type)
    return promiseOfSoldier(self.finish_soldier_callbacks, soldier_type)
end

return BarracksUpgradeBuilding




