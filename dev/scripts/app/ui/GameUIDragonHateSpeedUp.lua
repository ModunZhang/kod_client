--
-- Author: Danny He
-- Date: 2015-02-14 09:49:58
--

local GameUtils = GameUtils
local Localize = import("..utils.Localize")
local WidgetSpeedUp = import("..widget.WidgetSpeedUp")
local GameUIDragonHateSpeedUp = class("GameUIDragonHateSpeedUp", WidgetSpeedUp)

function GameUIDragonHateSpeedUp:ctor(hateEvent)
	GameUIDragonHateSpeedUp.super.ctor(self)
	self.hateEvent = hateEvent
	self:SetAccBtnsGroup(self:GetEventType(),hateEvent:Id())
    self:SetAccTips(_("龙的孵化没有免费加速"))
    self:SetUpgradeTip(Localize.dragon[hateEvent:DragonType()] .. _("正在孵化"))
end

function GameUIDragonHateSpeedUp:GetEventType()
	return "dragonHatchEvents"
end

function GameUIDragonHateSpeedUp:onEnter()
	GameUIDragonHateSpeedUp.super.onEnter(self)
	self.hateEvent:AddObserver(self)
end


function GameUIDragonHateSpeedUp:CheckCanSpeedUpFree()
	return false
end


function GameUIDragonHateSpeedUp:OnDragonEventTimer(event)
	if event:GetTime() >= 0 then
	 	self:SetProgressInfo(GameUtils:formatTimeStyle1(event:GetTime()),event:GetPercent())
	end
end

function GameUIDragonHateSpeedUp:onCleanup()
    self.hateEvent:RemoveObserver(self)
    GameUIDragonHateSpeedUp.super.onCleanup(self)
end

return GameUIDragonHateSpeedUp