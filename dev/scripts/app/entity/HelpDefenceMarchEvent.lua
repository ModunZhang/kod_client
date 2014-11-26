--
-- Author: Danny He
-- Date: 2014-11-25 16:05:13
--
local Observer = import(".Observer")
local HelpDefenceMarchEvent = class("HelpDefenceMarchEvent",Observer)
local property = import("..utils.property")

function HelpDefenceMarchEvent:ctor()
	property(self,"id","")
	property(self,"playerData","")
	property(self,"targetPlayerData","")
	property(self,"startTime","")
	property(self,"arriveTime","")
	property(self,"targetLocation","") -- set from outsider
	property(self,"fromLocation","") -- set from outsider

end

function HelpDefenceMarchEvent:OnPropertyChange()
end

function HelpDefenceMarchEvent:Update(json_data)
	self:SetId(json_data.id)
	self:SetPlayerData(json_data.playerData)
	self:SetTargetPlayerData(json_data.targetPlayerData)
	self:SetStartTime(json_data.startTime)
	self:SetArriveTime(json_data.arriveTime)
end

function HelpDefenceMarchEvent:OnTimer(current_time)
	self.times = math.ceil(self:ArriveTime() - current_time)
	if self.times >= 0 then
		self:NotifyObservers(function(listener)
			listener:OnHelpDefenceMarchEventTimer(self)
		end)
	end
end

function HelpDefenceMarchEvent:Reset()
	self:RemoveAllObserver()
end

function HelpDefenceMarchEvent:GetTime()
	return self.times or 0
end


return HelpDefenceMarchEvent