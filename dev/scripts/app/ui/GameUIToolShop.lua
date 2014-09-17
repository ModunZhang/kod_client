--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIToolShop = UIKit:createUIClass("GameUIToolShop", "GameUIWithCommonHeader")
function GameUIToolShop:ctor(city)
    GameUIToolShop.super.ctor(self, city, _("工具作坊"))
end
function GameUIToolShop:onEnter()
    GameUIToolShop.super.onEnter(self)
    self.home_btn:onButtonClicked(function(event)
        NetManager:getBuildingMaterials(NOT_HANDLE)
    end)
end
return GameUIToolShop











