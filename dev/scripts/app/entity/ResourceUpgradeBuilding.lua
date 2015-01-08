local config_house_function = GameDatas.HouseFunction
local config_house_levelup = GameDatas.HouseLevelUp
local MaterialManager = import("..entity.MaterialManager")
local UpgradeBuilding = import(".UpgradeBuilding")
local ResourceUpgradeBuilding = class("ResourceUpgradeBuilding", UpgradeBuilding)

function ResourceUpgradeBuilding:ctor(building_info)
    ResourceUpgradeBuilding.super.ctor(self, building_info)
    self.config_building_function = config_house_function
    self.config_building_levelup = config_house_levelup
end
function ResourceUpgradeBuilding:GetNextLevelUpgradeTimeByLevel(level)
    local config = config_house_levelup[self:GetType()]
    if config then
        local is_max_level = #config == level
        return is_max_level and 0 or config[level + 1].buildTime
    end
    return 1
end
function ResourceUpgradeBuilding:GetNextLevel()
    local config = config_house_levelup[self:GetType()]
    return #config == self.level and self.level or self.level + 1
end
function ResourceUpgradeBuilding:GetCitizen()
	local config = config_house_levelup[self:GetType()]
	local current_config = self:IsUpgrading() and config[self:GetNextLevel()] or config[self:GetLevel()]
	return current_config.citizen
end
function ResourceUpgradeBuilding:GetNextLevelCitizen()
    local config = config_house_levelup[self:GetType()]
    return config[self:GetNextLevel()].citizen
end
function ResourceUpgradeBuilding:GetProductionPerHour()
	local config = config_house_function[self:GetType()]
	local current_config = config[self:GetLevel()]
	return current_config.poduction
end
function ResourceUpgradeBuilding:GetNextLevelProductionPerHour()
    local config = config_house_function[self:GetType()]
    local current_config = config[self:GetNextLevel()]
    return current_config.poduction
end
function ResourceUpgradeBuilding:GetUpdateResourceType()
	return nil
end
function ResourceUpgradeBuilding:getUpgradeNowNeedGems()
    
    local resource_config = DataUtils:getHouseUpgradeRequired(self.building_type, self.level+1)
    local required_gems = 0
    required_gems = required_gems + DataUtils:buyResource(resource_config.resources, {})
    required_gems = required_gems + DataUtils:buyMaterial(resource_config.materials, {})
    required_gems = required_gems + DataUtils:getGemByTimeInterval(resource_config.buildTime)

    return required_gems
end

function ResourceUpgradeBuilding:getUpgradeRequiredGems()
    local city = self:BelongCity()
    local required_gems = 0
    local has_resourcce = {
        wood = city.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        iron = city.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        stone = city.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        citizen = city.resource_manager:GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime()),
    }

    
    local has_materials =city:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)

    local resource_config = DataUtils:getHouseUpgradeRequired(self.building_type, self.level+1)
    required_gems = required_gems + DataUtils:buyResource(resource_config.resources, has_resourcce)
    required_gems = required_gems + DataUtils:buyMaterial(resource_config.materials, has_materials)
    return required_gems
end

function ResourceUpgradeBuilding:IsAbleToUpgrade(isUpgradeNow)
    ResourceUpgradeBuilding.super.IsAbleToUpgrade(self,isUpgradeNow)
    -- 升级是否使空闲城民小于0
    local resource_manager = City:GetResourceManager()
    local free_citizen = resource_manager:GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime())
    if self:GetNextLevelCitizen()>free_citizen then
        return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.FREE_CITIZEN_ERROR
    end
end
return ResourceUpgradeBuilding