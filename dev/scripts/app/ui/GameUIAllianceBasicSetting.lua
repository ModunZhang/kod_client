--
-- Author: Danny He
-- Date: 2014-10-13 10:35:06
--
local window = import('..utils.window')
local UIScrollView = import(".UIScrollView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIAllianceBasicSetting = UIKit:createUIClass('GameUIAllianceBasicSetting')
local WidgetAllianceCreateOrEdit = import("..widget.WidgetAllianceCreateOrEdit")

function GameUIAllianceBasicSetting:onMoveInStage()
	assert(not self.isCreateAction_)
	GameUIAllianceBasicSetting.super.onMoveInStage(self)
	self:BuildModifyUI()
end

function GameUIAllianceBasicSetting:BuildModifyUI()
	local modify_height = window.height - 60
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local bg = WidgetUIBackGround.new({height=modify_height}):addTo(shadowLayer):pos(window.left+10,window.bottom)
	local titleBar = display.newSprite("title_blue_600x52.png"):align(display.LEFT_BOTTOM,3,modify_height-15):addTo(bg)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(titleBar,2)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+20,0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	UIKit:ttfLabel({
		text = _("联盟设置"),
		size = 22,
		shadow = true,
		color = 0xffedae
	}):addTo(titleBar):align(display.CENTER,300,titleBar:getContentSize().height/2)

	local scrollView = UIScrollView.new({viewRect = cc.rect(0,10,bg:getContentSize().width,titleBar:getPositionY() - 10)})
        :addScrollNode(WidgetAllianceCreateOrEdit.new(true):pos(35,0))
        :setDirection(UIScrollView.DIRECTION_VERTICAL)
        :addTo(bg)
	scrollView:fixResetPostion(-50)
	self.createScrollView = scrollView
end

-----------------------------------------------------------------------

return GameUIAllianceBasicSetting