--
-- Author: Danny He
-- Date: 2014-12-30 15:10:58
--
-- local BelvedereEvent = class("BelvedereEvent")

-- function BelvedereEvent:ctor(state)

-- end
----end of BelvedereEvent
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local AllianceBelvedere = class("AllianceBelvedere",MultiObserver)

AllianceBelvedere.LISTEN_TYPE = Enum("OnAttackMarchEventDataChanged"
	,"OnAttackMarchEventTimerChanged"
	,"OnAttackMarchReturnEventDataChanged"
	,"OnStrikeMarchEventDataChanged"
	,"OnStrikeMarchReturnEventDataChanged"
	,"OnVillageEventsDataChanged"
	,"OnVillageEventTimer"
)
function AllianceBelvedere:ctor(alliance)
	AllianceBelvedere.super.ctor(self)
	self.alliance = alliance
end

-- read limt or somethiong
function AllianceBelvedere:OnAllianceDataChanged(alliance_data)
	self.limit = 3 -- 3支部队
end

function AllianceBelvedere:GetMarchLimit()
	return self.limit
end

function AllianceBelvedere:IsReachEventLimit()
	return self:GetMarchLimit() == 3
end

function AllianceBelvedere:GetEnemyAlliance()
	return Alliance_Manager:GetEnemyAlliance()
end

function AllianceBelvedere:GetAlliance()
	return self.alliance
end
--其他人对于我的事件
function AllianceBelvedere:GetOtherEvents()
	--敌方联盟
	local marching_in_events = LuaUtils:table_filteri(self:GetEnemyAlliance():GetAttackMarchEvents(),function(_,marchAttackEvent)
		return marchAttackEvent:GetPlayerRole() == marchAttackEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	dump(marching_in_events,"marching_in_events--->")
	--突袭
	local marching_strike_events = LuaUtils:table_filteri(self:GetEnemyAlliance():GetStrikeMarchEvents(),function(_,strikeMarchEvent)
		return strikeMarchEvent:GetPlayerRole() == strikeMarchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	dump(marching_strike_events,"marching_strike_events--->")
	return {}
end
--自己操作的所有事件
function AllianceBelvedere:GetMyEvents()
	--所有正在进行的出去行军
	local marching_out_events = LuaUtils:table_filteri(self:GetAlliance():GetAttackMarchEvents(),function(_,marchAttackEvent)
		return marchAttackEvent:GetPlayerRole() == marchAttackEvent.MARCH_EVENT_PLAYER_ROLE.SENDER 
	end)
	dump(marching_out_events,"marching_out_events-->")
	--已出去采集村落、协防、圣地打仗
	local village_ing = LuaUtils:table_filteri(self:GetAlliance():GetVillageEvent(),function(_,villageEvent)
		return villageEvent:GetPlayerRole() == villageEvent.EVENT_PLAYER_ROLE.Me
	end)
	dump(village_ing,"village_ing-->")
	local helpToTroops = City:GetHelpToTroops()
	dump(helpToTroops,"helpToTroops-->")
	
	local shrine_Event = self:GetAlliance():GetAllianceShrine():GetSelfJoinedShrineEvent()
	dump(shrine_Event,"shrine_Event-->")
	--所有正在进行的返回行军
	local marching_out_return_events = LuaUtils:table_filteri(self:GetAlliance():GetAttackMarchReturnEvents(),function(_,marchAttackEvent)
		return marchAttackEvent:GetPlayerRole() == marchAttackEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	dump(marching_out_return_events,"marching_out_return_events-->")
	--突袭
	local marching_strike_events = LuaUtils:table_filteri(self:GetAlliance():GetStrikeMarchEvents(),function(_,strikeMarchEvent)
		return strikeMarchEvent:GetPlayerRole() == strikeMarchEvent.MARCH_EVENT_PLAYER_ROLE.SENDER 
	end)
	dump(marching_strike_events,"marching_strike_events-->")
	local marching_strike_events_return = LuaUtils:table_filteri(self:GetAlliance():GetStrikeMarchReturnEvents(),function(_,strikeMarchReturnEvent)
		return strikeMarchReturnEvent:GetPlayerRole() == strikeMarchReturnEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	dump(marching_strike_events_return,"marching_strike_events_return-->")
	return {}
end

function AllianceBelvedere:Reset()
	self:ClearAllListener()
end

function AllianceBelvedere:OnAttackMarchEventTimerChanged(attackMarchEvent)
	if attackMarchEvent:GetPlayerRole() == attackMarchEvent.MARCH_EVENT_PLAYER_ROLE.NOTHING then return end
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged,{attackMarchEvent})
end
function AllianceBelvedere:OnAttackMarchReturnEventDataChanged(changed_map)
	-- local changed_map = self:FilterEvent(changed_map)
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged,{changed_map})
end
function AllianceBelvedere:OnStrikeMarchEventDataChanged(changed_map)
	-- local changed_map = self:FilterEvent(changed_map)
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnStrikeMarchEventDataChanged,{changed_map})
end
function AllianceBelvedere:OnStrikeMarchReturnEventDataChanged(changed_map)
	-- local changed_map = self:FilterEvent(changed_map)
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged,{changed_map})
end
function AllianceBelvedere:OnVillageEventsDataChanged(changed_map)
	-- local changed_map = self:FilterEvent(changed_map)
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnVillageEventsDataChanged,{changed_map})
end
function AllianceBelvedere:OnVillageEventTimer(villageEvent,left_resource)
	if villageEvent:GetPlayerRole() == villageEvent.EVENT_PLAYER_ROLE.NOTHING then return end
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnVillageEventTimer,{villageEvent,left_resource})
end
function AllianceBelvedere:OnAttackMarchEventDataChanged(changed_map)
	-- local changed_map = self:FilterEvent(changed_map)
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventDataChanged,{changed_map})
end
function AllianceBelvedere:CallEventsChangedListeners(LISTEN_TYPE,args)
    self:NotifyListeneOnType(LISTEN_TYPE, function(listener)
        listener[AllianceBelvedere.LISTEN_TYPE[LISTEN_TYPE]](listener,unpack(args))
    end)
end

function AllianceBelvedere:FilterEvent(changed_map)
	local changed_map_ = {}
	if changed_map.added then 
		local added = LuaUtils:table_filteri(changed_map.added,function(event)
			if event:GetPlayerRole() ~= event.MARCH_EVENT_PLAYER_ROLE.NOTHING then
				return true
			end
			return false
		end)
		changed_map_.added = added
	end

	if changed_map.edited then 
		local edited = LuaUtils:table_filteri(changed_map.edited,function(event)
			if event:GetPlayerRole() ~= event.MARCH_EVENT_PLAYER_ROLE.NOTHING then
				return true
			end
			return false
		end)
		changed_map_.edited = edited
	end

	if changed_map.removed then 
		local removed = LuaUtils:table_filteri(changed_map.removed,function(event)
			if event:GetPlayerRole() ~= event.MARCH_EVENT_PLAYER_ROLE.NOTHING then
				return true
			end
			return false
		end)
		changed_map_.removed = removed
	end

	return changed_map_
end

return AllianceBelvedere