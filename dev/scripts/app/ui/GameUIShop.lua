--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
local GameUIShop = UIKit:createUIClass("GameUIShop", "GameUIWithCommonHeader")
function GameUIShop:ctor(city)
    GameUIShop.super.ctor(self, city, _("商城"))
end
function GameUIShop:onEnter()
    GameUIShop.super.onEnter(self)
end
function GameUIShop:onExit()
    GameUIShop.super.onExit(self)
end


return GameUIShop











































