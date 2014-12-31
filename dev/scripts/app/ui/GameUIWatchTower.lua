local Localize = import("..utils.Localize")
local GameUIWatchTower = UIKit:createUIClass('GameUIWatchTower',"GameUIUpgradeBuilding")

function GameUIWatchTower:ctor(city,building)
    local bn = Localize.building_name
    GameUIWatchTower.super.ctor(self,city,bn[building:GetType()],building)
end

function GameUIWatchTower:onEnter()
	GameUIWatchTower.super.onEnter(self)
	Alliance_Manager:GetMyAlliance():GetAllianceBelvedere():GetMyEvents()
end

return GameUIWatchTower