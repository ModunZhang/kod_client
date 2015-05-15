local UpgradeBuilding = import(".UpgradeBuilding")
local TowerEntity = class("TowerEntity", UpgradeBuilding)
local abs = math.abs
function TowerEntity:ctor(building_info)
    TowerEntity.super.ctor(self, building_info)
end
function TowerEntity:UniqueKey()
    return string.format("%s", self:GetType())
end
function TowerEntity:OnUserDataChanged(user_data, current_time, deltaData)
    local is_fully_update = not deltaData or deltaData.buildingEvents
    local is_delta_update = not is_fully_update and deltaData and deltaData.buildings
    if is_delta_update then
        if not deltaData.buildings["location_22"] then
            return
        end
    end

    local event = self:GetBuildingEventFromUserDataByLocation(user_data, 22)
    self:OnEvent(event)
    local level, finished_time = self:GetBuildingInfoByEventAndLocation(user_data, event, 22)
    if level and finished_time then
        self:OnHandle(level, finished_time)
    end
end
-- 获取对各兵种攻击力
function TowerEntity:GetAtk()
    local config = self.config_building_function[self:GetType()]
    local level = self.level
    local c = config[level]
    return c.infantry,c.archer,c.cavalry,c.siege,c.defencePower
end
function TowerEntity:GetTowerConfig()
    return self.config_building_function[self:GetType()][self:GetLevel()]
end
function TowerEntity:GetTowerNextLevelConfig()
    return self.config_building_function[self:GetType()][self:GetNextLevel()]
end
return TowerEntity





