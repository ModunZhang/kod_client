--
-- Author: Danny He
-- Date: 2014-12-30 15:10:58
--
-- local BelvedereEvent = class("BelvedereEvent")

-- function BelvedereEvent:ctor(state)

-- end
----end of BelvedereEvent
local Observer = import(".Observer")
local AllianceBelvedere = class("AllianceBelvedere")
function AllianceBelvedere:ctor(alliance)
	-- AllianceBelvedere.super.ctor(self)
	self.alliance = alliance

end

-- read limt or somethiong
function AllianceBelvedere:OnAllianceDataChanged(alliance_data)
	self.limit = 3 -- 3支部队
end


function AllianceBelvedere:GetMarchLimit()
	return self.limit
end

function AllianceBelvedere:GetAlliance()
	return self.alliance
end
--其他人对于我的事件
function AllianceBelvedere:GetOtherEvents()

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
end

function AllianceBelvedere:OnAttackMarchEventTimerChanged(attackMarchEvent)
	print("AllianceBelvedere:OnAttackMarchEventTimerChanged--->")
end
function AllianceBelvedere:OnAttackMarchReturnEventDataChanged(changed_map)
	print("AllianceBelvedere:OnAttackMarchReturnEventDataChanged--->")
end
function AllianceBelvedere:OnStrikeMarchEventDataChanged(changed_map)
	print("AllianceBelvedere:OnStrikeMarchEventDataChanged--->")
end
function AllianceBelvedere:OnStrikeMarchReturnEventDataChanged(changed_map)
	print("AllianceBelvedere:OnStrikeMarchReturnEventDataChanged--->")
end
function AllianceBelvedere:OnVillageEventsDataChanged(changed_map)
	print("AllianceBelvedere:OnVillageEventsDataChanged--->")
end
function AllianceBelvedere:OnVillageEventTimer(villageEvent,left_resource)
	print("AllianceBelvedere:OnVillageEventTimer--->")
end
function AllianceBelvedere:OnAttackMarchEventDataChanged(changed_map)
	print("AllianceBelvedere:OnAttackMarchEventDataChanged--->")
end

return AllianceBelvedere