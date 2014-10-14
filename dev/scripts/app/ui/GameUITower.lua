local Localize = import("..utils.Localize")
local GameUITower = UIKit:createUIClass('GameUITower',"GameUIUpgradeBuilding")

function GameUITower:ctor(city,building)
    local bn = Localize.building_name
    GameUITower.super.ctor(self,city,bn[building:GetType()],building)
end

return GameUITower