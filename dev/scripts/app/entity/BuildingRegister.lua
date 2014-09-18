local UpgradeBuilding = import("..entity.UpgradeBuilding")
local BuildingRegister = {
	keep 			= import("..entity.KeepUpgradeBuilding"),
    warehouse 		= import("..entity.WarehouseUpgradeBuilding"),
    toolShop 		= import("..entity.ToolShopUpgradeBuilding"),
    woodcutter 		= import("..entity.WoodResourceUpgradeBuilding"),
    farmer 			= import("..entity.FoodResourceUpgradeBuilding"),
    miner 			= import("..entity.IronResourceUpgradeBuilding"),
    quarrier 		= import("..entity.StoneResourceUpgradeBuilding"),
    dwelling 		= import("..entity.PopulationResourceUpgradeBuilding"),
    dragonEyrie     = import("..entity.DragonEyrieUpgradeBuilding"),
}
setmetatable(BuildingRegister, {__index = function(t, k, v)
	return UpgradeBuilding
end})
return BuildingRegister