--
-- Author: Danny He
-- Date: 2014-10-19 20:00:50
--
local Enum = import("..utils.Enum")
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIAllianceNoticeOrDescEdit = UIKit:createUIClass("GameUIAllianceNoticeOrDescEdit")

GameUIAllianceNoticeOrDescEdit.EDIT_TYPE = Enum("ALLIANCE_NOTICE","ALLIANCE_DESC")

local content_height = 470

function GameUIAllianceNoticeOrDescEdit:ctor(edit_type)
	self.allianceManager = DataManager:GetManager("AllianceManager")
	GameUIAllianceNoticeOrDescEdit.super.ctor(self)
	self.isNotice_ = edit_type == self.EDIT_TYPE.ALLIANCE_NOTICE
end

function GameUIAllianceNoticeOrDescEdit:onMovieInStage()
	--base UI
	local shadowLayer = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
		:addTo(self)
	local bg_node = WidgetUIBackGround.new(content_height):addTo(shadowLayer):pos(window.left+20,window.bottom + 250)
	local titleBar = display.newScale9Sprite("alliance_blue_title_600x42.png")
		:size(bg_node:getCascadeBoundingBox().width,42)
		:align(display.LEFT_BOTTOM, -2,content_height - 15)
		:addTo(bg_node)
	local title = self.isNotice_ and _("联盟公告") or _("联盟描述")
	local titleLabel = UIKit:ttfLabel({
		text = title,
		size = 22,
		color = 0xffedae
	}):align(display.CENTER,300,21):addTo(titleBar,2)
	

	local textView = cc.DTextView:create(cc.size(584,364),display.newScale9Sprite("alliance_edit_bg_576x354.png"))
    textView:addTo(bg_node):align(display.LEFT_TOP,10, titleBar:getPositionY() - 20)
    textView:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)    
    textView:setFont(UIKit:getFontFilePath(), 24)
    textView:setPlaceHolder(_("最多输入600个字符"))
    textView:setFontColor(UIKit:hex2c3b(0x000000))
    textView:setText(self.allianceManager:GetMyAllianceData().notice or "")
    self.textView = textView
 	display.newSprite("alliance_edit_box_584x364.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(textView,2)

 -- 	local closeButton = cc.ui.UIPushButton.new({normal = "X_2.png",pressed = "X_1.png"}, {scale9 = false})
	--    	:addTo(titleBar,2)
	--    	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+10, -5)
	--    	:onButtonClicked(function ()
	--    		self:leftButtonClicked()
	--    	end)
	-- display.newSprite("X_3.png")
	--    	:addTo(closeButton)
	--    	:pos(-32,30)

	local cancelButton = WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"},{scale9 = true})
        :setButtonLabel(
        	UIKit:ttfLabel({
				text = _("取消"),
				size = 20,
				shadow = true,
				color = 0xfff3c7
			})
		)
		:onButtonClicked(function()
			self:leftButtonClicked()
		end)
		:setButtonSize(146,42)
		:addTo(bg_node)
		:align(display.LEFT_BOTTOM,25, 20)
	local okButton = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"},{scale9 = true})
        :setButtonLabel(
        	UIKit:ttfLabel({
				text = _("确认"),
				size = 20,
				shadow = true,
				color = 0xfff3c7
			})
		)
		:onButtonClicked(handler(self, self.onOkButtonClicked))
		:setButtonSize(146,42)
		:addTo(bg_node)
		:align(display.RIGHT_BOTTOM,bg_node:getCascadeBoundingBox().width - 120, 20)
end


function GameUIAllianceNoticeOrDescEdit:onOkButtonClicked()
	local content = self.textView:getText()
	if self.isNotice_ then
		PushService:editAllianceNotice(content,function(success)
			self:leftButtonClicked()
		end)
	else
		PushService:editAllianceNotice(content,function(success)
			self:leftButtonClicked()
		end)
	end
end

return GameUIAllianceNoticeOrDescEdit