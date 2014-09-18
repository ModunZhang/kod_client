--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIBlackSmith = UIKit:createUIClass("GameUIBlackSmith", "GameUIWithCommonHeader")
function GameUIBlackSmith:ctor(city)
    GameUIBlackSmith.super.ctor(self, city, _("铁匠铺"))
end
function GameUIBlackSmith:onEnter()
    GameUIBlackSmith.super.onEnter(self)
    -- self.home_btn:onButtonClicked(function(event)
    --     NetManager:makeDragonEquipment("moltenCrown", NOT_HANDLE)
    -- end)
end
return GameUIBlackSmith











