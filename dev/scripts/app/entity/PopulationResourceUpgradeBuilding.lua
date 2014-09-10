local config_dwelling = GameDatas.HouseFunction.dwelling
local ResourceManager = import(".ResourceManager")
local ResourceUpgradeBuilding = import(".ResourceUpgradeBuilding")
local PopulationResourceUpgradeBuilding = class("PopulationResourceUpgradeBuilding", ResourceUpgradeBuilding)

function PopulationResourceUpgradeBuilding:ctor(building_info)
    PopulationResourceUpgradeBuilding.super.ctor(self, building_info)
end
function PopulationResourceUpgradeBuilding:GetProductionLimit()
	return config_dwelling[self:GetLevel()].population
end
function PopulationResourceUpgradeBuilding:GetProductionPerHour()
	return config_dwelling[self:GetLevel()].recoveryCitizen
end
function PopulationResourceUpgradeBuilding:GetUpdateResourceType()
	return ResourceManager.RESOURCE_TYPE.POPULATION
end
--

return PopulationResourceUpgradeBuilding