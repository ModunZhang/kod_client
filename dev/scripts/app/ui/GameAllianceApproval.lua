--
-- Author: Danny He
-- Date: 2014-10-24 11:41:10
--
local GameAllianceApproval = UIKit:createUIClass("GameAllianceApproval")
local window = import("..utils.window")
local UIListView = import(".UIListView")
local UIScrollView = import(".UIScrollView")
local WidgetPushButton = import("..widget.WidgetPushButton")

function GameAllianceApproval:onMoveInStage()
	GameAllianceApproval.super.onMoveInStage(self)
	local layer = UIKit:shadowLayer():addTo(self)
	local bg = self:CreatePopupBg(820):addTo(layer):pos(window.left+10,window.bottom+50)
	local title_bar = display.newSprite("alliance_blue_title_600x42.png")
		:addTo(bg)
		:align(display.LEFT_BOTTOM, 0, 820 - 15)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width+10, 0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	UIKit:ttfLabel({
		text = _("申请审批"),
		color = 0xffedae,
		size = 22,
	}):align(display.LEFT_BOTTOM, 50, 10):addTo(title_bar)
	self.listView = UIListView.new {
    	viewRect = cc.rect(15, 20,580,780),
        direction = UIScrollView.DIRECTION_VERTICAL,
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        alignment = UIListView.ALIGNMENT_LEFT,
    }:addTo(bg)
	self:RefreshListView()
end

function GameAllianceApproval:RefreshListView()
	for i=1,10 do
		local newItem = self:GetListItem()
		self.listView:addItem(newItem)
	end
	self.listView:reload()
end

function GameAllianceApproval:GetListItem(memberId)
	local item = self.listView:newItem()
	local node = display.newNode()
	local icon_box = display.newSprite("alliance_item_flag_box_126X126.png"):align(display.LEFT_BOTTOM, 0,0)
		:addTo(node)
	local content_box = display.newSprite("alliance_approval_box_450x126.png")
		:align(display.LEFT_BOTTOM,icon_box:getPositionX()+icon_box:getContentSize().width, icon_box:getPositionY())
		:addTo(node)
	local line = display.newScale9Sprite("dividing_line.png"):align(display.LEFT_CENTER,0,content_box:getContentSize().height/2):addTo(content_box)
		:size(450,2)
	UIKit:GetPlayerCommonIcon():addTo(icon_box):pos(icon_box:getContentSize().width/2,icon_box:getContentSize().height/2)
	--name
	UIKit:ttfLabel({
		text = "PlayerName",
		size = 22,
		color = 0x403c2f
	}):align(display.LEFT_TOP,20,110):addTo(content_box)
	--lv
	UIKit:ttfLabel({
		text = "LV 1",
		size = 20,
		color = 0x403c2f
	}):align(display.LEFT_TOP,170,105):addTo(content_box)
	--
	local icon = display.newSprite("upgrade_power_icon.png"):scale(0.5):align(display.LEFT_TOP,250,110):addTo(content_box)
	--power label
	UIKit:ttfLabel({
		text = string.formatnumberthousands(103231321),
		size = 22,
		color = 0x403c2f,
		align = cc.TEXT_ALIGNMENT_LEFT,
	}):align(display.LEFT_TOP,icon:getPositionX()+icon:getContentSize().width*0.5+10,110):addTo(content_box)
	local agreeButton = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
		:align(display.RIGHT_BOTTOM,430,10)
		:onButtonClicked(handler(self, self.OnAgreeButtonClicked))
		:setButtonLabel("normal", UIKit:ttfLabel({
			text = _("同意"),
			size = 22,
			color = 0xfff3c7,
			shadow = true
		}))
		:addTo(content_box)

	WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"})
		:align(display.RIGHT_BOTTOM,agreeButton:getPositionX() - 146 - 10,10)
		:onButtonClicked(handler(self, self.OnAgreeButtonClicked))
		:setButtonLabel("normal", UIKit:ttfLabel({
			text = _("拒绝"),
			size = 22,
			color = 0xfff3c7,
			shadow = true
		}))
		:addTo(content_box)

	item:addContent(node)
	item:setItemSize(580,node:getCascadeBoundingBox().height+10)
	return item
end

function GameAllianceApproval:OnAgreeButtonClicked(memberId)
	-- body
end

return GameAllianceApproval