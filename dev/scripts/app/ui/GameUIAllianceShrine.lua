--
-- Author: Danny He
-- Date: 2014-11-08 15:13:13
--
local GameUIAllianceShrine = class("GameUIAllianceShrine","GameUIWithCommonHeader")

function GameUIAllianceShrine:ctor(city)
	GameUIAllianceShrine.super.ctor(self,city,_("联盟圣地"))
end


return GameUIAllianceShrine