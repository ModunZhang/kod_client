local Localize = import("..utils.Localize")
local GameUITradeGuild = UIKit:createUIClass('GameUITradeGuild',"GameUIUpgradeBuilding")

function GameUITradeGuild:ctor(city,building)
    local bn = Localize.building_name
    GameUITradeGuild.super.ctor(self,city,bn[building:GetType()],building)
end

return GameUITradeGuild