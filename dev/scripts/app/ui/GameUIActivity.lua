--
-- Author: Danny He
-- Date: 2015-02-10 17:09:36
--
local GameUIActivity = UIKit:createUIClass("GameUIActivity","GameUIWithCommonHeader")

function GameUIActivity:ctor(city)
	GameUIActivity.super.ctor(self,city, _("活动"))
end

return GameUIActivity