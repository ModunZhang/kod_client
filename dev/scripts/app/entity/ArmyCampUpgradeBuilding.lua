local config_function = GameDatas.BuildingFunction.armyCamp
local UpgradeBuilding = import(".UpgradeBuilding")
local ArmyCampUpgradeBuilding = class("ArmyCampUpgradeBuilding", UpgradeBuilding)

function ArmyCampUpgradeBuilding:ctor(building_info)
    ArmyCampUpgradeBuilding.super.ctor(self, building_info)
end

function ArmyCampUpgradeBuilding:GetTroopPopulation()
    local level = self:GetLevel()
    return config_function[level].troopPopulation
end

return ArmyCampUpgradeBuilding