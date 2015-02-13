
local Observer = import(".Observer")
local Building = import(".Building")
local MaterialManager = import("..entity.MaterialManager")
local UpgradeBuilding = class("UpgradeBuilding", Building)
local Localize = import("..utils.Localize")
UpgradeBuilding.NOT_ABLE_TO_UPGRADE = {
    TILE_NOT_UNLOCKED = "地块未解锁",
    IS_MAX_LEVEL = "建筑已经达到最高等级",
    LEVEL_CAN_NOT_HIGHER_THAN_KEEP_LEVEL = "请首先提升城堡等级",
    RESOURCE_NOT_ENOUGH = "资源不足",
    BUILDINGLIST_NOT_ENOUGH = "建造队列不足",
    BUILDINGLIST_AND_RESOURCE_NOT_ENOUGH = "资源不足.建造队列不足",
    GEM_NOT_ENOUGH = "宝石不足",
    LEVEL_NOT_ENOUGH = "等级小于0级",
    BUILDING_IS_UPGRADING = "建筑正在升级",
    FREE_CITIZEN_ERROR = "升级小屋会造成可用城民小于0",
}
local NOT_ABLE_TO_UPGRADE = UpgradeBuilding.NOT_ABLE_TO_UPGRADE
function UpgradeBuilding:ctor(building_info)
    UpgradeBuilding.super.ctor(self, building_info)
    self.config_building_levelup = GameDatas.BuildingLevelUp
    self.config_building_function = GameDatas.BuildingFunction
    self.level = building_info.level and building_info.level or 1
    self.upgrade_to_next_level_time = (building_info.finishTime == nil) and 0 or building_info.finishTime
    self.upgrade_building_observer = Observer.new()
    self.unique_upgrading_key = nil
end
function UpgradeBuilding:IsAbleToFreeSpeedUpByTime(time)
    return self:GetFreeSpeedupTime() >= self:GetUpgradingLeftTimeByCurrentTime(time)
end
function UpgradeBuilding:GetFreeSpeedupTime()
    return DataUtils:getFreeSpeedUpLimitTime()
end
function UpgradeBuilding:UniqueUpgradingKey()
    return self.unique_upgrading_key
end
function UpgradeBuilding:ResetAllListeners()
    UpgradeBuilding.super.ResetAllListeners(self)
    self:GetUpgradeObserver():RemoveAllObserver()
end
function UpgradeBuilding:CopyListenerFrom(building)
    UpgradeBuilding.super.CopyListenerFrom(self, building)
    self.upgrade_building_observer:CopyListenerFrom(building:GetUpgradeObserver())
end
function UpgradeBuilding:AddUpgradeListener(listener)
    assert(listener.OnBuildingUpgradingBegin)
    assert(listener.OnBuildingUpgradeFinished)
    assert(listener.OnBuildingUpgrading)
    self.upgrade_building_observer:AddObserver(listener)
    return self
end
function UpgradeBuilding:RemoveUpgradeListener(listener)
    self.upgrade_building_observer:RemoveObserver(listener)
end
function UpgradeBuilding:GetUpgradeObserver()
    return self.upgrade_building_observer
end
function UpgradeBuilding:GetElapsedTimeByCurrentTime(current_time)
    return self:GetUpgradeTimeToNextLevel() - self:GetUpgradingLeftTimeByCurrentTime(current_time)
end
function UpgradeBuilding:GetUpgradingLeftTimeByCurrentTime(current_time)
    return self.upgrade_to_next_level_time - current_time
end
function UpgradeBuilding:GetUpgradingPercentByCurrentTime(current_time)
    if self:IsUpgrading() then
        local total_time = self:GetUpgradeTimeToNextLevel()
        return (total_time + current_time - self.upgrade_to_next_level_time) / total_time * 100
    else
        return 0
    end
end
function UpgradeBuilding:CanUpgrade()
    local legal = self:IsBuildingUpgradeLegal()
    return type(legal) == "nil"
end
function UpgradeBuilding:IsUnlocking()
    return self:GetLevel() == 0 and self.upgrade_to_next_level_time ~= 0
end
function UpgradeBuilding:IsBuilding()
    return self:GetLevel() == 0 and self.upgrade_to_next_level_time ~= 0
end
function UpgradeBuilding:IsUnlocked()
    return self:GetLevel() > 0
end
function UpgradeBuilding:IsUpgrading()
    return self.upgrade_to_next_level_time ~= 0
end
function UpgradeBuilding:InstantUpgradeBy(level)
    self:InstantUpgradeTo(self.level + level)
end
function UpgradeBuilding:InstantUpgradeTo(level)
    local finished_time = self.upgrade_to_next_level_time
    self.level = level
    self.upgrade_to_next_level_time = 0
    self.upgrade_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBuildingUpgradeFinished(self, finished_time)
    end)
end
function UpgradeBuilding:UpgradeByCurrentTime(current_time)
    self.upgrade_to_next_level_time = current_time + self:GetUpgradeTimeToNextLevel()
    self:GeneralLocalPush()
    self.upgrade_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBuildingUpgradingBegin(self, current_time)
    end)
end
function UpgradeBuilding:GetUpgradeTimeToNextLevel()
    return self:GetNextLevelUpgradeTimeByLevel(self.level)
end
function UpgradeBuilding:GetNextLevelUpgradeTimeByLevel(level)
    local config = self.config_building_levelup[self:GetType()]
    if config then
        local is_max_level = #config == level
        return is_max_level and 0 or config[level + 1].buildTime
    end
    return 1
end
function UpgradeBuilding:GetNextLevel()
    return self:IsMaxLevel() and self.level or self.level + 1
end
function UpgradeBuilding:IsMaxLevel()
    local config = self.config_building_levelup[self:GetType()]
    return #config == self.level
end
function UpgradeBuilding:GetBeforeLevel()
    if self.level > 0 then
        return self.level - 1
    else
        return 0
    end
end
function UpgradeBuilding:GetLevel()
    return self.level
end

function UpgradeBuilding:GeneralLocalPush()
    if ext and ext.localpush then
        local pushIdentity = self.x .. self.y .. self.w .. self.h .. self.orient
        local title = Localize.getLocaliedKeyByType(self.building_type) .. _("升级完成")
        app:GetPushManager():AddLocalPush(self.upgrade_to_next_level_time,title,pushIdentity)
    end
end

function UpgradeBuilding:OnTimer(current_time)
    if self:IsUpgrading() then
        local is_upgrading = self:GetUpgradingLeftTimeByCurrentTime(current_time) >= 0
        if is_upgrading then
            self.upgrade_building_observer:NotifyObservers(function(lisenter)
                lisenter:OnBuildingUpgrading(self, current_time)
            end)
        end
    end
end
local function get_building_event_by_location(building_events, loc_id)
    for k, v in pairs(building_events) do
        if v.location == loc_id then
            return v
        end
    end
end
local function get_building_event_change_by_location(building_events, loc_id)
    for k, v in pairs(building_events) do
        if v.data.location == loc_id then
            return v.data
        end
    end
end
local function get_house_event_by_location(house_events, building_location, sub_id)
    for k, v in pairs(house_events) do
        if v.buildingLocation == building_location and
            v.houseLocation == sub_id then
            return v
        end
    end
end
local function get_house_event_change_by_location(house_events, building_location, sub_id)
    for k, v in pairs(house_events) do
        if v.data.buildingLocation == building_location and
            v.data.houseLocation == sub_id then
            return v.data
        end
    end
end
local function get_house_info_from_houses_by_id(houses, houses_id)
    for _, v in pairs(houses) do
        if v.location == houses_id then
            return v
        end
    end
    return nil
end
function UpgradeBuilding:OnUserDataChanged(user_data, current_time, location_id, sub_location_id)
    self:HandleAllEvents(user_data, current_time, location_id, sub_location_id)
    self:HandleEventChange(user_data, current_time, location_id, sub_location_id)
end
function UpgradeBuilding:HandleAllEvents( user_data, current_time, location_id, sub_location_id )
    -- 是否属于
    local house_events = user_data.houseEvents
    local building_events = user_data.buildingEvents
    local buildings = user_data.buildings
    local is_has_no_building = not (house_events or building_events or buildings)
    if is_has_no_building then return end
    --
    -- 解析
    local finishTime = self.upgrade_to_next_level_time
    local level = self:GetLevel()
    -- 先找小屋
    if sub_location_id then
        if house_events then
            local event = get_house_event_by_location(house_events, location_id, sub_location_id)
            self:OnEvent(event)
            finishTime = event == nil and 0 or event.finishTime / 1000
        end
        -- 再找功能建筑
    else
        if building_events then
            local event = get_building_event_by_location(building_events, location_id)
            self:OnEvent(event)
            finishTime = event == nil and 0 or event.finishTime / 1000
        end
    end

    -- 更新等级信息
    if user_data.buildings then
        print("location_id=",location_id)
        local location = user_data.buildings["location_"..location_id]
        if not location then
            return
        end
        if sub_location_id then
            level = get_house_info_from_houses_by_id(location.houses, sub_location_id).level
        else
            level = location.level
        end
    end
    -- 适配
    self:OnHandle(level, finishTime)
end
function UpgradeBuilding:HandleEventChange( user_data, current_time, location_id, sub_location_id )
    -- 是否属于
    local house_events = user_data.__houseEvents
    local building_events = user_data.__buildingEvents
    local is_has_no_building = not (house_events or building_events)
    if is_has_no_building then return end
    --
    -- 解析
    local finishTime = self.upgrade_to_next_level_time
    local level = self:GetLevel()
    -- 先找小屋
    if sub_location_id then
        if house_events then
            local event = get_house_event_change_by_location(house_events, location_id, sub_location_id)
            self:OnEvent(event)
            finishTime = event == nil and 0 or event.finishTime / 1000
        end
        -- 再找功能建筑
    else
        if building_events then
            local event = get_building_event_change_by_location(building_events, location_id)
            self:OnEvent(event)
            finishTime = event == nil and 0 or event.finishTime / 1000
        end
    end

    -- 适配
    self:OnHandle(level, finishTime)
end
function UpgradeBuilding:OnEvent(event)
    if event == nil then
        self.unique_upgrading_key = nil
    else
        self.unique_upgrading_key =  event.id
    end
end
function UpgradeBuilding:OnHandle(level, finish_time)
    if self.level == level then
        if self.upgrade_to_next_level_time == 0 and finish_time ~= 0 then
            print("请求升级的时间",finish_time,finish_time - self:GetUpgradeTimeToNextLevel())
            self:UpgradeByCurrentTime(finish_time - self:GetUpgradeTimeToNextLevel())
        elseif self.upgrade_to_next_level_time ~= 0 and finish_time ~= 0 then
            print("升级时间finish_time= ",finish_time*1000,app.timer:GetServerTime()*1000,finish_time*1000-app.timer:GetServerTime()*1000)
            self.upgrade_to_next_level_time = finish_time
            self:GeneralLocalPush()
        elseif self.upgrade_to_next_level_time ~= 0 and finish_time == 0 then
            self:InstantUpgradeTo(level)
        end
    else
        if finish_time == 0 then
            self:InstantUpgradeTo(level)
        else
            self.level = level
            self.upgrade_to_next_level_time = finish_time
            self:GeneralLocalPush()
        end
    end
end
----
function UpgradeBuilding:GetNextLevelPower()
    return self.config_building_function[self:GetType()][self:GetNextLevel()].power
end
function UpgradeBuilding:GetPower()
    return self.config_building_function[self:GetType()][self:GetLevel()].power
end
function UpgradeBuilding:GetLevelUpWood()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].wood
end

function UpgradeBuilding:GetLevelUpStone()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].stone
end

function UpgradeBuilding:GetLevelUpIron()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].iron
end

function UpgradeBuilding:GetLevelUpBlueprints()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].blueprints
end

function UpgradeBuilding:GetLevelUpTools()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].tools
end

function UpgradeBuilding:GetLevelUpTiles()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].tiles
end

function UpgradeBuilding:GetLevelUpPulley()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].pulley
end

function UpgradeBuilding:GetLevelUpBuildTime()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].buildTime
end

function UpgradeBuilding:GetLevelUpCitizen()
    local level = self.level
    return self.config_building_levelup[self:GetType()][self:GetNextLevel()].citizen
end
-- 升级前置条件
function UpgradeBuilding:IsBuildingUpgradeLegal()
    local city =  self:BelongCity()
    local level = self.level

    --等级小于0级
    if level<0 then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.LEVEL_NOT_ENOUGH
    end
    --建筑正在升级
    if self:IsUpgrading() then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDING_IS_UPGRADING
    end
    local level_up_config = self.config_building_levelup[self:GetType()]

    if #level_up_config == level then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.IS_MAX_LEVEL
    end

    local config
    if city:IsHouse(self) then
        config = GameDatas.Houses.houses[self:GetType()]
    else
        local location_id = city:GetLocationIdByBuildingType(self:GetType())
        config = GameDatas.Buildings.buildings[location_id]
    end
    local configParams = string.split(config.preCondition,"_")
    local preType = configParams[1]
    local preName = configParams[2]
    local preLevel = tonumber(configParams[3])
    local limit
    if preType == "building" then
        local find_buildings = city:GetBuildingByType(preName)
        for i,v in ipairs(find_buildings) do
            if v:GetLevel()>=self:GetLevel()+preLevel then
                limit = true
            end
        end
    else
        city:IteratorDecoratorBuildingsByFunc(function (index,house)
            if house:GetLevel()>=self:GetLevel()+preLevel then
                limit = true
            end
        end)
    end
    if not limit then
        return string.format(_("需要%s达到%d级"),Localize.building_name[preName],self:GetLevel()+preLevel)
    end
end
function UpgradeBuilding:IsAbleToUpgrade(isUpgradeNow)
    local city = self:BelongCity()
    
    local pre_limit = self:IsBuildingUpgradeLegal()
    if pre_limit then
        return pre_limit
    end

    local gem = city:GetUser():GetGemResource():GetValue()
    if isUpgradeNow then
        if gem<self:getUpgradeNowNeedGems() then
            return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.GEM_NOT_ENOUGH
        end
        return
    end
    -- 还未管理道具，暂时从userdata中取
    -- local m = DataManager:getUserData().materials
    local m =city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)

    -- 升级所需资源不足
    local wood = city.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local iron = city.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local stone = city.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local population = city.resource_manager:GetPopulationResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local is_resource_enough = wood<config[self:GetNextLevel()].wood or population<config[self:GetNextLevel()].citizen
        or stone<config[self:GetNextLevel()].stone or iron<config[self:GetNextLevel()].iron
        or m.tiles<config[self:GetNextLevel()].tiles or m.tools<config[self:GetNextLevel()].tools
        or m.blueprints<config[self:GetNextLevel()].blueprints or m.pulley<config[self:GetNextLevel()].pulley
    local max = city.build_queue
    local current = max - #city:GetUpgradingBuildings()

    if is_resource_enough and current <= 0 then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_AND_RESOURCE_NOT_ENOUGH
    end
    if is_resource_enough then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.RESOURCE_NOT_ENOUGH
    end
    if current <= 0 then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_NOT_ENOUGH
    end
end

function UpgradeBuilding:getUpgradeNowNeedGems()

    local resource_config = DataUtils:getBuildingUpgradeRequired(self.building_type, self:GetNextLevel())
    local required_gems = 0
    required_gems = required_gems + DataUtils:buyResource(resource_config.resources, {})
    required_gems = required_gems + DataUtils:buyMaterial(resource_config.materials, {})
    required_gems = required_gems + DataUtils:getGemByTimeInterval(resource_config.buildTime)

    return required_gems
end

function UpgradeBuilding:getUpgradeRequiredGems()
    local city = self:BelongCity()
    local required_gems = 0
    local has_resourcce = {
        wood = city.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        iron = city.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        stone = city.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        citizen = city.resource_manager:GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime()),
    }

    -- 还未管理道具，暂时从userdata中取
    local has_materials = DataManager:getUserData().materials

    local resource_config = DataUtils:getBuildingUpgradeRequired(self.building_type, self:GetNextLevel())
    required_gems = required_gems + DataUtils:buyResource(resource_config.resources, has_resourcce)
    required_gems = required_gems + DataUtils:buyMaterial(resource_config.materials, has_materials)
    --当升级队列不足时，立即完成正在升级的建筑中所剩升级时间最少的建筑
    if #city:GetUpgradingBuildings()>0 then
        local min_time = math.huge
        for k,v in pairs(city:GetUpgradingBuildings()) do
            local left_time = v:GetUpgradingLeftTimeByCurrentTime(app.timer:GetServerTime())
            if left_time<min_time then
                min_time=left_time
                print("完成上个升级的建筑",v:GetType())
            end
        end
        print("完成上个升级事件的时间",min_time)
        required_gems = required_gems + DataUtils:getGemByTimeInterval(min_time)
    end

    return required_gems
end

return UpgradeBuilding





















