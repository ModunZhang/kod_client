--
-- Author: Danny He
-- Date: 2014-12-02 09:26:02
--
local Observer = import(".Observer")
local MarchAttackEvent = class("MarchAttackEvent",Observer)
local Enum = import("..utils.Enum")
local property = import("..utils.property")

MarchAttackEvent.MARCH_EVENT_PLAYER_ROLE = Enum("SENDER","RECEIVER","NOTHING")

--判断该玩家是这个事件的发送者/接受者/无关
function MarchAttackEvent:GetPlayerRole()
	local Me_Id = DataManager:getUserData()._id
	if Me_Id == self:AttackPlayerData().id then
		return self.MARCH_EVENT_PLAYER_ROLE.SENDER 
	else
		return self.MARCH_EVENT_PLAYER_ROLE.NOTHING 
	end
end

function MarchAttackEvent:Reset()
	self:RemoveAllObserver()
end

function MarchAttackEvent:OnTimer(current_time)
	self.times_ = math.ceil(self:ArriveTime() - current_time)
	if self.times_ >= 0 then
		self:NotifyObservers(function(listener)
			listener:OnMarchEventTimer(self)
		end)
	end
end

function MarchAttackEvent:GetTime()
	return self.times_ or 0
end


function MarchAttackEvent:FromLocation()
	return self:AttackPlayerData().location
end
function MarchAttackEvent:TargetLocation()
	return self:GetDefenceData().location
end

function MarchAttackEvent:OnPropertyChange()
end

function MarchAttackEvent:ctor()
	MarchAttackEvent.super.ctor(self)
	property(self,"id","")
	property(self,"startTime","")
	property(self,"arriveTime","")
	property(self,"marchType","")
	property(self,"attackPlayerData",{})
	property(self,"defencePlayerData",{})
	property(self,"defenceVillageData",{})
	property(self,"defenceShrineData",{})
end

function MarchAttackEvent:GetDefenceData()
	if self:MarchType() == "village" then
		return self:DefenceVillageData()
	elseif self:MarchType() == "city" or  self:MarchType() == "helpDefence" then
		return self:DefencePlayerData()
	elseif self:MarchType() == "shrine" then
		return self:DefenceShrineData()
	else
		assert(false,"不支持此种行军事件 --> " .. self:MarchType())
	end
end

function MarchAttackEvent:UpdateData(json_data)
	self:SetId(json_data.id or "")
	self:SetStartTime(json_data.startTime and json_data.startTime/1000.0 or "")
	self:SetArriveTime(json_data.arriveTime and json_data.arriveTime/1000.0 or "")
	self:SetMarchType(json_data.marchType or "")
	self:SetAttackPlayerData(json_data.attackPlayerData or {})
	self:SetDefencePlayerData(json_data.defencePlayerData or {})
	self:SetDefenceVillageData(json_data.defenceVillageData or {})
	self:SetDefenceShrineData(json_data.defenceShrineData or {})
end

return MarchAttackEvent