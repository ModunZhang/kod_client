--
-- Author: Kenny Dai
-- Date: 2015-06-01 09:51:28
--
local WidgetAutoOrderGachaButton = class("WidgetAutoOrderGachaButton",cc.ui.UIPushButton)
local User = User

function WidgetAutoOrderGachaButton:ctor()
	WidgetAutoOrderGachaButton.super.ctor(self,{normal = "casinoTokenClass_2_128x128.png"})
	self:onButtonClicked(handler(self, self.OnGachaButtonClicked))
	self:scale(80/128)
end


function WidgetAutoOrderGachaButton:OnGachaButtonClicked(event)
    UIKit:newGameUI("GameUIGacha",City):AddToCurrentScene(true)
end


function WidgetAutoOrderGachaButton:refrshCallback()
	self:stopAllActions()
	self:runAction(self:GetShakeAction())
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
	return  User:GetOddFreeNormalGachaCount() > 0
end

function WidgetAutoOrderGachaButton:GetElementSize()
	return {width = 40,height = 40}
end

return WidgetAutoOrderGachaButton