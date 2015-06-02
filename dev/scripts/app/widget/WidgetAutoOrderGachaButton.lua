--
-- Author: Kenny Dai
-- Date: 2015-06-01 11:05:26
--
local WidgetAutoOrderGachaButton = class("WidgetAutoOrderGachaButton",cc.ui.UIPushButton)
local User = User

function WidgetAutoOrderGachaButton:ctor()
	WidgetAutoOrderGachaButton.super.ctor(self,{normal = "casinoTokenClass_2_128x128.png"})
	self:onButtonClicked(handler(self, self.OnGachaButtonClicked))
	self:scale(80/128)
end


function WidgetAutoOrderGachaButton:OnGachaButtonClicked(event)
    UIKit:newGameUI("GameUIGacha",City):AddToCurrentScene(true):DisableAutoClose()
end


function WidgetAutoOrderGachaButton:refrshCallback()
	self:stopAllActions()
	local result = User:GetOddFreeNormalGachaCount() > 0
	if result then
		self:runAction(self:GetShakeAction())
	end
end

function WidgetAutoOrderGachaButton:GetShakeAction()
   local sequence = transition.sequence({
        cc.MoveTo:create(0.1, cc.p(self:getPositionX(), self:getPositionY()+5)),
        cc.MoveTo:create(0.1, cc.p(self:getPositionX(), self:getPositionY())),
        cc.MoveTo:create(0.1, cc.p(self:getPositionX(), self:getPositionY()+5)),
        cc.MoveTo:create(0.1, cc.p(self:getPositionX(), self:getPositionY())),
        cc.MoveTo:create(0.1, cc.p(self:getPositionX(), self:getPositionY()+5)),
        cc.MoveTo:create(0.1, cc.p(self:getPositionX(), self:getPositionY())),
        cc.MoveTo:create(1, cc.p(self:getPositionX(), self:getPositionY())),
    })
    return cc.RepeatForever:create(sequence)
end

-- For WidgetAutoOrder
function WidgetAutoOrderGachaButton:CheckVisible()
	local result = User:GetOddFreeNormalGachaCount() > 0
	if not result then
		self:stopAllActions()
	end
	return result
end

function WidgetAutoOrderGachaButton:GetElementSize()
	return {width = 80,height = 70}
end

return WidgetAutoOrderGachaButton

