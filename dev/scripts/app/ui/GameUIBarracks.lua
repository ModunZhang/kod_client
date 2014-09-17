--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIBarracks = UIKit:createUIClass("GameUIBarracks", "GameUIWithCommonHeader")
function GameUIBarracks:ctor(city)
    GameUIBarracks.super.ctor(self, city, _("兵营"))
end
function GameUIBarracks:onEnter()
    GameUIBarracks.super.onEnter(self)
end
return GameUIBarracks
