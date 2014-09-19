--
-- Author: Danny He
-- Date: 2014-09-17 09:22:12
--
local UpgradeBuilding = import(".UpgradeBuilding")
local DragonEyrieUpgradeBuilding = class("DragonEyrieUpgradeBuilding",UpgradeBuilding)

function DragonEyrieUpgradeBuilding:OnUserDataChanged(user_data, current_time, location_id, sub_location_id)
	DragonEyrieUpgradeBuilding.super.OnUserDataChanged(self,user_data, current_time, location_id, sub_location_id) -- handle upgrade event
	print(current_time,"DragonEyrieUpgradeBuilding---->")
end

return DragonEyrieUpgradeBuilding