--
-- Author: Danny He
-- Date: 2015-01-19 14:18:33
--
local WidgetSpeedUp = import("..widget.WidgetSpeedUp")
local GameUITechnologySpeedUp = class("GameUITechnologySpeedUp",WidgetSpeedUp)
local WidgetAccelerateGroup = import("..widget.WidgetAccelerateGroup")

function GameUITechnologySpeedUp:ctor()
	GameUITechnologySpeedUp.super.ctor(self)
	if City:HaveProductionTechEvent() then
		self.technologyEvent = City:GetProductionTechEventsArray()[1]
	end
	self:SetAccBtnsGroup(WidgetAccelerateGroup.SPEEDUP_TYPE.TECHNOLOGY,function()end)
	self:SetAccTips(_("小于5min时可以使用免费加速"))
	if not self.technologyEvent then
		self:removeFromParent()
	else
		local event = self.technologyEvent
		City:AddListenOnType(self,City.LISTEN_TYPE.PRODUCTION_EVENT_CHANGED)
	    City:AddListenOnType(self,City.LISTEN_TYPE.PRODUCTION_EVENT_TIMER)
		self:SetUpgradeTip(string.format(_("正在研发%s到 Level %d"),event:Entity():GetLocalizedName(),event:Entity():GetNextLevel()))
	    self:SetProgressInfo(GameUtils:formatTimeStyle1(event:GetTime()),event:GetPercent())
		self:CheckCanSpeedUpFree()
		self:OnFreeButtonClicked(handler(self, self.FreeSpeedUpAction))
	end
end

function GameUITechnologySpeedUp:FreeSpeedUpAction()
	NetManager:getFreeSpeedUpPromise("productionTechEvents",self:GetEvent():Id()):next(function()
		self:removeFromParent()
	end)
end

function GameUITechnologySpeedUp:onCleanup()
	City:RemoveListenerOnType(self,City.LISTEN_TYPE.PRODUCTION_EVENT_CHANGED)
	City:RemoveListenerOnType(self,City.LISTEN_TYPE.PRODUCTION_EVENT_TIMER)
end

function GameUITechnologySpeedUp:OnProductionTechnologyEventDataChanged(changed_map)

end

function GameUITechnologySpeedUp:OnProductionTechnologyEventTimer(event)
	if self.progress then
		self:SetProgressInfo(GameUtils:formatTimeStyle1(event:GetTime()),event:GetPercent())
		self:CheckCanSpeedUpFree()
	end
end

function GameUITechnologySpeedUp:GetEvent()
	return self.technologyEvent
end

function GameUITechnologySpeedUp:CheckCanSpeedUpFree()
	self:SetFreeButtonEnabled(self:GetEvent():GetTime() <= 60 * 5)
end

return GameUITechnologySpeedUp