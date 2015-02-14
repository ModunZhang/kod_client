--
-- Author: Danny He
-- Date: 2015-02-14 09:08:03
--
local WidgetSpeedUp = import("..widget.WidgetSpeedUp")
local GameUIDragonDeathSpeedUp = class("GameUIDragonDeathSpeedUp", WidgetSpeedUp)
local GameUtils = GameUtils
local Localize = import("..utils.Localize")

function GameUIDragonDeathSpeedUp:ctor(dragonDeathEvent)
	GameUIDragonDeathSpeedUp.super.ctor(self)
	self:SetAccBtnsGroup(self:GetEventType(),dragonDeathEvent:Id())
    self:SetAccTips(_("龙的复活没有免费加速"))
    self:SetUpgradeTip(Localize.dragon[dragonDeathEvent:DragonType()] .. _("正在复活"))
    self.dragonDeathEvent = dragonDeathEvent
end

function GameUIDragonDeathSpeedUp:CheckCanSpeedUpFree()
	return false
end

function GameUIDragonDeathSpeedUp:onEnter()
	GameUIDragonDeathSpeedUp.super.onEnter(self)
	self.dragonDeathEvent:AddObserver(self)
end

function GameUIDragonDeathSpeedUp:GetEventType()
	return "dragonDeathEvents"
end

function GameUIDragonDeathSpeedUp:onCleanup()
    self.dragonDeathEvent:RemoveObserver(self)
    GameUIDragonDeathSpeedUp.super.onCleanup(self)
end

function GameUIDragonDeathSpeedUp:OnDragonDeathEventTimer(event)
	if event:GetTime() >= 0 then
	 	self:SetProgressInfo(GameUtils:formatTimeStyle1(event:GetTime()),event:GetPercent())
	end
end

return GameUIDragonDeathSpeedUp