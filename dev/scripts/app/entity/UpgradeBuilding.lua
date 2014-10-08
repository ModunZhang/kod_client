
local Observer = import(".Observer")
local Building = import(".Building")
local UpgradeBuilding = class("UpgradeBuilding", Building)
UpgradeBuilding.NOT_ABLE_TO_UPGRADE = {
    TILE_NOT_UNLOCKED = "地块未解锁",
    IS_MAX_LEVEL = "建筑已经达到最高等级",
    LEVEL_CAN_NOT_HIGHER_THAN_KEEP_LEVEL = "请首先提升城堡等级",
    RESOURCE_NOT_ENOUGH = "资源不足",
    BUILDINGLIST_NOT_ENOUGH = "建造队列不足",
    BUILDINGLIST_AND_RESOURCE_NOT_ENOUGH = "资源不足\n建造队列不足",
    GEM_NOT_ENOUGH = "宝石不足",
    LEVEL_NOT_ENOUGH = "等级小于0级",
    BUILDING_IS_UPGRADING = "建筑正在升级",
}
function UpgradeBuilding:ctor(building_info)
    UpgradeBuilding.super.ctor(self, building_info)
    self.config_building_levelup = GameDatas.BuildingLevelUp
    self.config_building_function = GameDatas.BuildingFunction
    self.level = building_info.level and building_info.level or 1
    self.upgrade_to_next_level_time = (building_info.finishTime == nil) and 0 or building_info.finishTime
    self.upgrade_building_observer = Observer.new()
    --building剩余升级时间小于5 min时可以免费加速  单位 seconds
    self.freeSpeedUpTime=300
end
function UpgradeBuilding:AddUpgradeListener(listener)
    assert(listener.OnBuildingUpgradingBegin)
    assert(listener.OnBuildingUpgradeFinished)
    assert(listener.OnBuildingUpgrading)
    self.upgrade_building_observer:AddObserver(listener)
end
function UpgradeBuilding:RemoveUpgradeListener(listener)
    self.upgrade_building_observer:RemoveObserver(listener)
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
    local config = self.config_building_levelup[self:GetType()]
    return #config == self.level and self.level or self.level + 1
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
        ext.localpush.cancelNotification(pushIdentity)
        local title = UIKit:getLocaliedKeyByType(self.building_type) .. _("升级完成")
        ext.localpush.addNotification("BUILDING_PUSH_UPGRADE", self.upgrade_to_next_level_time,title,pushIdentity)
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
function UpgradeBuilding:OnUserDataChanged(user_data, current_time, location_id, sub_location_id)
    -- 解析
    local building_events = user_data.buildingEvents
    local function get_building_event_by_location(loc_id)
        for k, v in pairs(building_events) do
            if v.location == loc_id then
                return v
            end
        end
    end

    local hosue_events = user_data.houseEvents
    local function get_house_event_by_location(building_location, sub_id)
        for k, v in pairs(hosue_events) do
            if v.buildingLocation == building_location and
                v.houseLocation == sub_id then
                return v
            end
        end
    end

    local finishTime
    local level
    local location = user_data.buildings["location_"..location_id]
    if sub_location_id then
        table.foreach(location.houses, function(key, building_info)
            if building_info.location == sub_location_id then
                local event = get_house_event_by_location(location_id, sub_location_id)
                finishTime = event == nil and 0 or event.finishTime / 1000
                level = building_info.level
                return true
            end
        end)
    else
        local event = get_building_event_by_location(location_id)
        finishTime = event == nil and 0 or event.finishTime / 1000
        level = location.level
    end

    -- 适配
    self:OnHandle(level, finishTime)
end
function UpgradeBuilding:OnHandle(level, finish_time)
    if self.level == level then
        if self.upgrade_to_next_level_time == 0 and finish_time ~= 0 then
            self:UpgradeByCurrentTime(finish_time - self:GetUpgradeTimeToNextLevel())
        elseif self.upgrade_to_next_level_time ~= 0 and finish_time ~= 0 then
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

function UpgradeBuilding:IsAbleToUpgrade(isUpgradeNow)
    local level = self.level
    --等级小于0级
    if level<0 then
        return NOT_ABLE_TO_UPGRADE.LEVEL_NOT_ENOUGH
    end
    --建筑正在升级
    if self:IsUpgrading() then
        return NOT_ABLE_TO_UPGRADE.BUILDING_IS_UPGRADING
    end
    local config = self.config_building_levelup[self:GetType()]
    -- 地块是否解锁
    -- local tile = City:GetTileWhichBuildingBelongs(self)
    -- if not City:IsUnLockedAtIndex(tile.x,tile.y) then
    --     return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.TILE_NOT_UNLOCKED
    -- end
    -- 除了keep以外，被升级建筑等级不能大于keep等级
    if self:GetType()~="keep" and City:GetBuildingByLocationId(1):GetLevel()==level then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.LEVEL_CAN_NOT_HIGHER_THAN_KEEP_LEVEL
    elseif #config == level then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.IS_MAX_LEVEL
    end
    local gem = City.resource_manager:GetGemResource():GetValue()
    if isUpgradeNow then
        if gem<self:getUpgradeNowNeedGems() then
            return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.GEM_NOT_ENOUGH
        end
        return
    end
    -- 还未管理道具，暂时从userdata中取
    local m = DataManager:getUserData().materials
    -- 升级所需资源不足
    local wood = City.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local iron = City.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local stone = City.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local population = City.resource_manager:GetPopulationResource():GetResourceValueByCurrentTime(app.timer:GetServerTime())
    local is_resource_enough = wood<config[self:GetNextLevel()].wood or population<config[self:GetNextLevel()].citizen
        or stone<config[self:GetNextLevel()].stone or iron<config[self:GetNextLevel()].iron
        or m.tiles<config[self:GetNextLevel()].tiles or m.tools<config[self:GetNextLevel()].tools
        or m.blueprints<config[self:GetNextLevel()].blueprints or m.pulley<config[self:GetNextLevel()].pulley
    local is_building_list_enough = #City:GetOnUpgradingBuildings()>0
    print("#City:GetOnUpgradingBuildings()",#City:GetOnUpgradingBuildings())
    if is_resource_enough and is_building_list_enough then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.BUILDINGLIST_AND_RESOURCE_NOT_ENOUGH
    end
    if is_resource_enough then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.RESOURCE_NOT_ENOUGH
    end
    if is_building_list_enough then
    print("当前建造的建筑",City:GetOnUpgradingBuildings()[1]:GetType())
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
    local required_gems = 0
    local has_resourcce = {
        wood = City.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        iron = City.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        stone = City.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        citizen = City.resource_manager:GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime()),
    }

    -- 还未管理道具，暂时从userdata中取
    local has_materials = DataManager:getUserData().materials

    local resource_config = DataUtils:getBuildingUpgradeRequired(self.building_type, self:GetNextLevel())
    required_gems = required_gems + DataUtils:buyResource(resource_config.resources, has_resourcce)
    required_gems = required_gems + DataUtils:buyMaterial(resource_config.materials, has_materials)
    --当升级队列不足时，立即完成正在升级的建筑中所剩升级时间最少的建筑
    if #City:GetOnUpgradingBuildings()>0 then
        local min_time = math.huge
        for k,v in pairs(City:GetOnUpgradingBuildings()) do
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









