--
-- Author: Danny He
-- Date: 2014-09-17 09:22:12
--
local config_function = GameDatas.BuildingFunction.dragonEyrie
local config_levelup = GameDatas.BuildingLevelUp.dragonEyrie
local ResourceManager = import(".ResourceManager")
local ResourceUpgradeBuilding = import(".ResourceUpgradeBuilding")
local DragonEyrieUpgradeBuilding = class("DragonEyrieUpgradeBuilding", ResourceUpgradeBuilding)


function DragonEyrieUpgradeBuilding:EnergyMax()
	return config_function[self:GetLevel()].energyMax
end
function DragonEyrieUpgradeBuilding:GetProductionPerHour()
	return 3600 / self:GetTimePerEnergy()
end
function DragonEyrieUpgradeBuilding:GetTimePerEnergy()
	return config_function[self:GetLevel()].perEnergyTime
end
function DragonEyrieUpgradeBuilding:GetUpdateResourceType()
	return ResourceManager.RESOURCE_TYPE.ENERGY
end


function DragonEyrieUpgradeBuilding:OnUserDataChanged(user_data, current_time, location_id, sub_location_id)
	DragonEyrieUpgradeBuilding.super.OnUserDataChanged(self,user_data, current_time, location_id, sub_location_id) -- handle upgrade event
	print(current_time,"DragonEyrieUpgradeBuilding---->")
end

return DragonEyrieUpgradeBuilding