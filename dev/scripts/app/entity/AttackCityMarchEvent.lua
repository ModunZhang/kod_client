--
-- Author: Danny He
-- Date: 2014-12-08 17:19:01
--

local MarchEventBase = import(".MarchEventBase")
local AttackCityMarchEvent = class("AttackCityMarchEvent",MarchEventBase)
local property = import("..utils.property")

function AttackCityMarchEvent:OnPropertyChange()
end

function AttackCityMarchEvent:ctor()
	AttackCityMarchEvent.super.ctor(self)
	property(self,"id","")
	property(self,"startTime","")
	property(self,"arriveTime","")
	property(self,"attackPlayerData","")
	property(self,"defencePlayerData","")
end

function AttackCityMarchEvent:Update(json_data)
	self:SetId(json_data.id)
	self:SetStartTime(json_data.startTime)
	self:SetArriveTime(json_data.arriveTime)
	self:SetAttackPlayerData(json_data.attackPlayerData)
	self:SetDefencePlayerData(json_data.defencePlayerData)
end

function AttackCityMarchEvent:OnTimer(current_time)
	self.times = math.ceil(self:ArriveTime() - current_time)
	if self.times >= 0 then
		self:NotifyObservers(function(listener)
			listener:OnAttackCityMarchEventTimer(self)
		end)
	end
end

function AttackCityMarchEvent:GetTime()
	return self.times or 0
end

function AttackCityMarchEvent:GetMarchPlayerInfo(player_id)
	if self:DefencePlayerData().id == player_id then
		return self.MARCH_EVENT_WITH_PLAYER.RECEIVER
	end
	if self:AttackPlayerData().id == player_id then
		return self.MARCH_EVENT_WITH_PLAYER.SENDER
	end
	return self.MARCH_EVENT_WITH_PLAYER.NOTHING
end


function AttackCityMarchEvent:SetLocationInfo(from,target)
	self:SetFromLocation(from)
	self:SetTargetLocation(target)
end

function AttackCityMarchEvent:SetFromLocation( from )
	self.fromLocation = from
end

function AttackCityMarchEvent:FromLocation()
	return self.fromLocation
end

function AttackCityMarchEvent:SetTargetLocation( target )
	self.targetLocation = target
end

function AttackCityMarchEvent:TargetLocation()
	return self.targetLocation
end


return AttackCityMarchEvent