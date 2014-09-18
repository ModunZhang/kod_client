--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIMaterialDepot = UIKit:createUIClass("GameUIMaterialDepot", "GameUIWithCommonHeader")
function GameUIMaterialDepot:ctor(city)
    GameUIMaterialDepot.super.ctor(self, city, _("材料库房"))
end
function GameUIMaterialDepot:onEnter()
    GameUIMaterialDepot.super.onEnter(self)
end
return GameUIMaterialDepot











