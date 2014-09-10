--需要有入场动画
local GameUICommonTips = UIKit:createUIClass('GameUICommonTips')

function GameUICommonTips:ctor(delegate,autoClose)
	GameUICommonTips.super.ctor(self)
    if nil == autoClose then autoClose = false end
    self.autoClose = autoClose
    self.delegate = delegate
end


function GameUICommonTips:onEnter()
	GameUICommonTips.super.onEnter(self)
	self:createUI()
	self:setTouchEnabled(true)
	self:setTouchSwallowEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "began" then
        	return true
        elseif event.name == 'ended' then
        	self:closeButtonPressed(nil,TOUCH_EVENT_ENDED)
    	end
	end)
end

function GameUICommonTips:createUI()

	local bgImage = display.newSprite("common_tips_bg.png"):addTo(self):align(display.LEFT_BOTTOM, display.left, display.bottom)
	local button = cc.ui.UIPushButton.new("common_tips_button.png", {scale9 = false})
		:onButtonClicked(function(event)
        	self:closeButtonPressed()
        end)


    local buttonLabel = ui.newTTFLabelWithShadow({
            text = _("点击关闭"),
            size = 18,
            color = UIKit:hex2c3b(0xFFF3C7),
            font = UIKit:getFontFilePath(),
            align = ui.TEXT_ALIGN_CENTER,
       	})

	button:setButtonLabel("normal",buttonLabel):addTo(self):align(display.RIGHT_BOTTOM, display.right, 10)
	button:setButtonLabelOffset(50,0)

	local titleLabel = ui.newTTFLabelWithShadow({
		text = "建筑升级完成",
        size = 20,
		color = UIKit:hex2c3b(0xf3f0b6),
        font = UIKit:getFontFilePath(),
        align = ui.TEXT_ALIGN_CENTER,
	}):addTo(bgImage)
	
	titleLabel.label:align(display.LEFT_BOTTOM, 0, 0)
	titleLabel.shadow1:align(display.LEFT_BOTTOM, 0, 0)
	titleLabel:align(display.LEFT_TOP,15, bgImage:getContentSize().height-35)
	-- UIKit:debugNode(button,"button")
	local contentLabel = ui.newTTFLabel({
		text = "小屋升级完成 (LV2) 00:01:23",
        size = 18,
		color = UIKit:hex2c3b(0xd1ca95),
        font = UIKit:getFontFilePath(),
        align = ui.TEXT_ALIGN_CENTER,
	}):align(display.TOP_LEFT, 15, bgImage:getContentSize().height - 30 - titleLabel:getContentSize().height):addTo(bgImage)
	self.titleLabel = titleLabel
	self.contentLabel = contentLabel
end


function GameUICommonTips:closeButtonPressed()
	if self:isVisible() and not self.isAnimation then
		self.isAnimation = true
		self:UIAnimationMoveOut()
	end
end

function GameUICommonTips:onMovieInStage()
	GameUICommonTips.super.onMovieInStage(self)
	self.isAnimation = false
	if self.autoClose and type(self.autoClose) == 'number' then
		--自动关闭
		self:performWithDelay(function()
			if self:isVisible() and not self.isAnimation then
				self:UIAnimationMoveOut()
				self.isAnimation = true
			end
		end,self.autoClose)
	end
end

function GameUICommonTips:showTips(title,content)
	if not self:isVisible() then
		self:setVisible(true)
	end
	self.titleLabel:setString(title)
	self.contentLabel:setString(content)
	print(title,content)
	self:UIAnimationMoveIn()
	self.isAnimation = true
end

function GameUICommonTips:onMovieOutStage()
	self:setVisible(false)
	self.isAnimation = false
	if self.delegate and self.delegate.onTipsMoveOut then
		self.delegate.onTipsMoveOut(self.delegate,self)
	end
	GameUICommonTips.super.onMovieOutStage(self)
end

function GameUICommonTips:onExit()
	self.delegate = nil
end


return GameUICommonTips