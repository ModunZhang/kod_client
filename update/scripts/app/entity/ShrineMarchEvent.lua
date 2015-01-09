--
-- Author: Danny He
-- Date: 2014-11-13 22:06:58
--
local MarchEventBase = import(".MarchEventBase")
local ShrineMarchEvent = class("ShrineMarchEvent",MarchEventBase)
local property = import("..utils.property")

function ShrineMarchEvent:OnPropertyChange()
end

function ShrineMarchEvent:ctor()
	ShrineMarchEvent.super.ctor(self)
	property(self,"id","")
	property(self,"startTime","")
	property(self,"shrineEventId","")
	property(self,"arriveTime","")
	property(self,"playerData","")
end


function ShrineMarchEvent:Update(json_data)
	self:SetId(json_data.id)
	self:SetStartTime(json_data.startTime/1000.0)
	self:SetShrineEventId(json_data.shrineEventId)
	self:SetArriveTime(json_data.arriveTime/1000.0)
	self:SetPlayerData(json_data.playerData) -- playerData is table
end

function ShrineMarchEvent:OnTimer(current_time)
	self.times = math.ceil(self:ArriveTime() - current_time)
	if self.times >= 0 then
		self:NotifyObservers(function(listener)
			listener:OnMarchEventTimer(self)
		end)
	end
end

function ShrineMarchEvent:GetTime()
	return self.times or 0
end

function ShrineMarchEvent:SetLocationInfo(from,target)
	self:SetFromLocation(from)
	self:SetTargetLocation(target)
end

function ShrineMarchEvent:SetFromLocation( from )
	self.fromLocation = from
end

function ShrineMarchEvent:FromLocation()
	return self.fromLocation
end

function ShrineMarchEvent:SetTargetLocation( target )
	self.targetLocation = target
end

function ShrineMarchEvent:TargetLocation()
	return self.targetLocation
end

function ShrineMarchEvent:GetMarchPlayerInfo(player_id)
	if self:PlayerData().id == player_id then
		return self.MARCH_EVENT_WITH_PLAYER.SENDER
	end
	return self.MARCH_EVENT_WITH_PLAYER.NOTHING
end
return ShrineMarchEvent