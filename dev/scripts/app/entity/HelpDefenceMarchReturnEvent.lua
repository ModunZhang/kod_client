--
-- Author: Danny He
-- Date: 2014-11-26 09:49:34
--
local Observer = import(".Observer")
local HelpDefenceMarchReturnEvent = class("HelpDefenceMarchReturnEvent", Observer)
local property = import("..utils.property")

function HelpDefenceMarchReturnEvent:OnPropertyChange()
end

function HelpDefenceMarchReturnEvent:ctor()
	HelpDefenceMarchReturnEvent.super.ctor(self)
	property(self,"id","")
	property(self,"playerData","")
	property(self,"fromPlayerData","")
	property(self,"startTime","")
	property(self,"arriveTime","")
	property(self,"targetLocation","") -- set from outsider
	property(self,"fromLocation","") -- set from outsider
end

function HelpDefenceMarchReturnEvent:Update(json_data)
	self:SetId(json_data.id)
	self:SetPlayerData(json_data.playerData)
	self:SetFromPlayerData(json_data.fromPlayerData)
	self:SetStartTime(json_data.startTime)
	self:SetArriveTime(json_data.arriveTime)
end

function HelpDefenceMarchReturnEvent:OnTimer(current_time)
	self.times = math.ceil(self:ArriveTime() - current_time)
	if self.times >= 0 then
		self:NotifyObservers(function(listener)
			listener:OnHelpDefenceReturnMarchEventTimer(self)
		end)
	end
end

function HelpDefenceMarchReturnEvent:Reset()
	self:RemoveAllObserver()
end

function HelpDefenceMarchReturnEvent:GetTime()
	return self.times or 0
end

function HelpDefenceMarchReturnEvent:GetMarchPlayerInfo(player_id)
	if self:PlayerData().id == player_id then
		return self.MARCH_EVENT_WITH_PLAYER.RECEIVER
	end
	if self:FromPlayerData().id == player_id then
		return self.MARCH_EVENT_WITH_PLAYER.SENDER
	end
	return self.MARCH_EVENT_WITH_PLAYER.NOTHING
end

return HelpDefenceMarchReturnEvent