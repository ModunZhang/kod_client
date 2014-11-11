--
-- Author: Danny He
-- Date: 2014-11-11 11:39:41
--
local GameUIAllianceShrineDetail = UIKit:createUIClass("GameUIAllianceShrineDetail")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local HEIGHT = 738
local WidgetPushButton = import("..widget.WidgetPushButton")

function GameUIAllianceShrineDetail:ctor(shrineStage)
	GameUIAllianceShrineDetail.super.ctor(self)
	self.shrineStage_ = shrineStage
	dump(shrineStage)
end


function GameUIAllianceShrineDetail:onEnter()
	GameUIAllianceShrineDetail.super.onEnter(self)
	self:BuildUI()
end

function GameUIAllianceShrineDetail:BuildUI()
	local layer = UIKit:shadowLayer():addTo(self)
	local background = WidgetUIBackGround.new({height = HEIGHT})
		:addTo(layer)
		:pos(window.left+22,window.top - 101 - HEIGHT)
	local title_bar = display.newSprite("red_title_600x42.png"):align(display.LEFT_BOTTOM, 0,HEIGHT - 15):addTo(background)
	UIKit:ttfLabel({
		text = "关卡名",
		size = 22,
		color = 0xffedae
	}):align(display.CENTER,300,21):addTo(title_bar)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width+10, 0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	--ui
	local desc_label = UIKit:ttfLabel({
		text = _("注:一场战斗中,每名玩家只能派出一支部队"),
		size = 20,
		color = 0x980101
	}):align(display.BOTTOM_CENTER,304,20):addTo(background)
	local event_button = WidgetPushButton.new({
		normal = "yellow_btn_up_185x65.png",
		pressed = "yellow_btn_down_185x65.png",
	},{scale9 = false},{disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}})
		:align(display.RIGHT_BOTTOM, 570,desc_label:getPositionY() + 50)
		:addTo(background)
		:setButtonLabel("normal", UIKit:commonButtonLable({
			text = _("激活事件"),
			color = 0xfff3c7
		}))
	local insight_icon = display.newSprite("insight_icon_45x45.png")
		:align(display.RIGHT_BOTTOM,570 - event_button:getCascadeBoundingBox().width - 100,desc_label:getPositionY() + 60)
		:addTo(background)
	-- display.newScale9Sprite("box_bg_546x214.png"):alig
	local need_insight_title_label = UIKit:ttfLabel({
		text = _("需要感知力"),
		size = 18,
		color = 0x6d6651
	})

	local need_insight_val_title = UIKit:ttfLabel({
		text = string.formatnumberthousands(4000),
		color = 0x403c2f,
		size  = 24
	}):addTo(insight_icon):align(display.LEFT_BOTTOM,insight_icon:getContentSize().width, 0)

	UIKit:CreateBoxPanel(172):addTo(background):pos(25,event_button:getPositionY()+event_button:getCascadeBoundingBox().height+20)
end

function GameUIAllianceShrineDetail:GetShrineStage()
	return self.shrineStage_
end


return GameUIAllianceShrineDetail