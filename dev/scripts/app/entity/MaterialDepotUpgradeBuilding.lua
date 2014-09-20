local config_function = GameDatas.BuildingFunction.materialDepot
local config_levelup = GameDatas.BuildingLevelUp.materialDepot
local UpgradeBuilding = import(".UpgradeBuilding")
local MaterialDepotUpgradeBuilding = class("MaterialDepotUpgradeBuilding", UpgradeBuilding)

function MaterialDepotUpgradeBuilding:ctor(building_info)
    MaterialDepotUpgradeBuilding.super.ctor(self, building_info)
end

function MaterialDepotUpgradeBuilding:GetMaxMaterial()
    local level = self:GetLevel()
    return config_function[level].maxMaterial
end

return MaterialDepotUpgradeBuilding


