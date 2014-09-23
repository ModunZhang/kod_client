local UpgradeBuilding = import("..entity.UpgradeBuilding")
local BuildingRegister = {
	keep 			= import("..entity.KeepUpgradeBuilding"),
    warehouse 		= import("..entity.WarehouseUpgradeBuilding"),
    toolShop 		= import("..entity.ToolShopUpgradeBuilding"),
    blackSmith 		= import("..entity.BlackSmithUpgradeBuilding"),
    woodcutter 		= import("..entity.WoodResourceUpgradeBuilding"),
    farmer 			= import("..entity.FoodResourceUpgradeBuilding"),
    miner 			= import("..entity.IronResourceUpgradeBuilding"),
    quarrier 		= import("..entity.StoneResourceUpgradeBuilding"),
    dwelling 		= import("..entity.PopulationResourceUpgradeBuilding"),
    dragonEyrie     = import("..entity.DragonEyrieUpgradeBuilding"),
    armyCamp        = import("..entity.ArmyCampUpgradeBuilding"),
    materialDepot   = import("..entity.MaterialDepotUpgradeBuilding"),
    foundry   = import("..entity.PResourceUpgradeBuilding"),
    stoneMason   = import("..entity.PResourceUpgradeBuilding"),
    lumbermill   = import("..entity.PResourceUpgradeBuilding"),
    mill 	= import("..entity.PResourceUpgradeBuilding"),
}
setmetatable(BuildingRegister, {__index = function(t, k)
	return UpgradeBuilding
end})
return BuildingRegister