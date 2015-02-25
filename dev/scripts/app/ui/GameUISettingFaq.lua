--
-- Author: Danny He
-- Date: 2015-02-24 18:14:14
--
local GameUISettingFaq = UIKit:createUIClass("GameUISettingFaq")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local UIListView = import(".UIListView")

function GameUISettingFaq:onEnter()
	GameUISettingFaq.super.onEnter(self)
	self:CreateBackGround()
    self:CreateTitle(_("遇到问题"))
    self.home_btn = self:CreateHomeButton()
    local gem_button = cc.ui.UIPushButton.new({
    	normal = "contact_n_148x60.png", pressed = "contact_h_148x60.png"
    }):onButtonClicked(function(event)
       	UIKit:newGameUI("GameUISettingContactUs"):addToCurrentScene(true)
    end):addTo(self):setButtonLabel("normal", UIKit:commonButtonLable({
    	text = _("联系我们"),
    }))
    gem_button:align(display.RIGHT_TOP, window.cx+314, window.top-5)
end


return GameUISettingFaq