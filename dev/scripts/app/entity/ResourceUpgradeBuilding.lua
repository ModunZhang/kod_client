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
--

function ResourceUpgradeBuilding:getUpgradeNowNeedGems()
    
    local resource_config = DataUtils:getHouseUpgradeRequired(self.building_type, self.level+1)
    local required_gems = 0
    required_gems = required_gems + DataUtils:buyResource(resource_config.resources, {})
    required_gems = required_gems + DataUtils:buyMaterial(resource_config.materials, {})
    required_gems = required_gems + DataUtils:getGemByTimeInterval(resource_config.buildTime)

    return required_gems
end

function ResourceUpgradeBuilding:getUpgradeRequiredGems()
    local required_gems = 0
    local has_resourcce = {
        wood = City.resource_manager:GetWoodResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        iron = City.resource_manager:GetIronResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        stone = City.resource_manager:GetStoneResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        citizen = City.resource_manager:GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime()),
    }

    
    local has_materials =City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.BUILD)

    local resource_config = DataUtils:getHouseUpgradeRequired(self.building_type, self.level+1)
    required_gems = required_gems + DataUtils:buyResource(resource_config.resources, has_resourcce)
    required_gems = required_gems + DataUtils:buyMaterial(resource_config.materials, has_materials)
    return required_gems
end
-- function ResourceUpgradeBuilding:GetLevelUpWood()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].wood
-- end

-- function ResourceUpgradeBuilding:GetLevelUpStone()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].stone
-- end

-- function ResourceUpgradeBuilding:GetLevelUpIron()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].iron
-- end

-- function ResourceUpgradeBuilding:GetLevelUpBlueprints()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].blueprints
-- end

-- function ResourceUpgradeBuilding:GetLevelUpTools()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].tools
-- end

-- function ResourceUpgradeBuilding:GetLevelUpTiles()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].tiles
-- end

-- function ResourceUpgradeBuilding:GetLevelUpPulley()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].pulley
-- end

-- function ResourceUpgradeBuilding:GetLevelUpBuildTime()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].buildTime
-- end

-- function ResourceUpgradeBuilding:GetLevelUpCitizen()
--     local level = self.level
--     return config_house_levelup[self:GetType()][level+1].citizen
-- end

-- function ResourceUpgradeBuilding:IsAbleToUpgrade()
--     local config = config_house_levelup[self:GetType()]
--     local level = self.level
--     -- 地块是否解锁
--     local tile = City:GetTileWhichBuildingBelongs(self)
--     if not City:IsUnLockedAtIndex(tile.x,tile.y) then
--         return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.TILE_NOT_UNLOCKED
--     end

--     if City:GetBuildingByLocationId(1):GetLevel()==level then
--         return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.LEVEL_CAN_NOT_HIGHER_THAN_KEEP_LEVEL
--     elseif #config == level then
--         return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.IS_MAX_LEVEL
--     end

--     local r = {
--         WOOD = City.resource_manager.RESOURCE_TYPE.WOOD,
--         IRON = City.resource_manager.RESOURCE_TYPE.IRON,
--         STONE = City.resource_manager.RESOURCE_TYPE.STONE,
--         POPULATION = City.resource_manager.RESOURCE_TYPE.POPULATION
--     }

--     local wood = City.resource_manager:GetResourceByType(r.WOOD):GetResourceValueByCurrentTime(app.timer:GetServerTime())
--     local iron = City.resource_manager:GetResourceByType(r.IRON):GetResourceValueByCurrentTime(app.timer:GetServerTime())
--     local stone = City.resource_manager:GetResourceByType(r.STONE):GetResourceValueByCurrentTime(app.timer:GetServerTime())
--     local population = City.resource_manager:GetResourceByType(r.POPULATION):GetResourceValueByCurrentTime(app.timer:GetServerTime())
    
--     -- 还未管理道具，暂时从userdata中取
--     local m = DataManager:getUserData().materials
--     -- print("wood ",wood,config[level+1].wood)
--     -- print("population ",population,config[level+1].citizen)
--     -- print("iron ",iron,config[level+1].iron)
--     -- print("stone ",stone,config[level+1].stone)
--     -- print("tiles ",m.tiles,config[level+1].tiles)
--     -- print("tools ",m.tools,config[level+1].tools)
--     -- print("blueprints ",m.blueprints,config[level+1].blueprints)
--     -- print("pulley ",m.pulley,config[level+1].pulley)

--     if wood<config[level+1].wood or population<config[level+1].citizen
--         or stone<config[level+1].stone or iron<config[level+1].iron
--         or m.tiles<config[level+1].tiles or m.tools<config[level+1].tools
--         or m.blueprints<config[level+1].blueprints or m.pulley<config[level+1].pulley
--     then
--         return UpgradeBuilding.NOT_ABLE_TO_UPGRADE.RESOURCE_NOT_ENOUGTH
--     end
-- end

return ResourceUpgradeBuilding