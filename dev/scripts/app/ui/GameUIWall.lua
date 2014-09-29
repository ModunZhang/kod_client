
local Localize = import("..utils.Localize")
local GameUIWall = UIKit:createUIClass('GameUIWall',"GameUIUpgradeBuilding")

function GameUIWall:ctor(city,building)
    local bn = Localize.building_name
    GameUIWall.super.ctor(self,city,bn[building:GetType()],building)
end

return GameUIWall