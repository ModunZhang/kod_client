--
-- Author: Danny He
-- Date: 2014-12-30 15:10:58
--

local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local AllianceBelvedere = class("AllianceBelvedere",MultiObserver)
local BelvedereEntity = import(".BelvedereEntity")
AllianceBelvedere.LISTEN_TYPE = Enum("OnCommingDataChanged","OnMarchDataChanged","OnAttackMarchEventTimerChanged","OnVillageEventTimer","OnFightEventTimerChanged","OnStrikeMarchEventDataChanged","OnAttackMarchEventDataChanged")
function AllianceBelvedere:ctor(alliance)
	AllianceBelvedere.super.ctor(self)
	self.alliance = alliance
end

-- read limt or somethiong
function AllianceBelvedere:OnAllianceDataChanged(alliance_data)
	print("AllianceBelvedere:OnAllianceDataChanged--->")
	self.limit = 2 -- 自己部队的队列限制数
end

function AllianceBelvedere:GetMarchLimit()
	return self.limit
end

function AllianceBelvedere:IsReachEventLimit()
	return self:GetMarchLimit() >= #self:GetMyEvents()
end

function AllianceBelvedere:GetEnemyAlliance()
	return Alliance_Manager:GetMyAlliance():GetEnemyAlliance()
end

function AllianceBelvedere:GetAlliance()
	return self.alliance
end

function AllianceBelvedere:Handler2BelvedereEntity(dis,src,entity_type,filter_func)
	for _,v in ipairs(src) do
		if filter_func  and not filter_func(v) then 
		else
			local belvedereEntity = BelvedereEntity.new(v)
			belvedereEntity:SetType(entity_type)
			table.insert(dis, 1,belvedereEntity)
		end
	end
end

--其他人对于我的事件
function AllianceBelvedere:GetOtherEvents()
	local other_events = {}
	--敌方联盟
	local marching_in_events = LuaUtils:table_filteri(self:GetEnemyAlliance():GetAttackMarchEvents(),function(_,marchAttackEvent)
		return marchAttackEvent:GetPlayerRole() == marchAttackEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	self:Handler2BelvedereEntity(other_events,marching_in_events,BelvedereEntity.ENTITY_TYPE.MARCH_OUT)
	--突袭
	local marching_strike_events = LuaUtils:table_filteri(self:GetEnemyAlliance():GetStrikeMarchEvents(),function(_,strikeMarchEvent)
		return strikeMarchEvent:GetPlayerRole() == strikeMarchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	self:Handler2BelvedereEntity(other_events,marching_strike_events,BelvedereEntity.ENTITY_TYPE.STRIKE_OUT)
	dump(other_events,"other_events--->")
	return other_events
end
--自己操作的所有事件
function AllianceBelvedere:GetMyEvents()
	local my_events = {}
	--所有正在进行的出去行军
	local marching_out_events = LuaUtils:table_filteri(self:GetAlliance():GetAttackMarchEvents(),function(_,marchAttackEvent)
		return marchAttackEvent:GetPlayerRole() == marchAttackEvent.MARCH_EVENT_PLAYER_ROLE.SENDER 
	end)
	self:Handler2BelvedereEntity(my_events,marching_out_events,BelvedereEntity.ENTITY_TYPE.MARCH_OUT)
	--已出去采集村落、协防、圣地打仗
	local village_ing = LuaUtils:table_filteri(self:GetAlliance():GetVillageEvent(),function(_,villageEvent)
		return villageEvent:GetPlayerRole() == villageEvent.EVENT_PLAYER_ROLE.Me
	end)
	self:Handler2BelvedereEntity(my_events,village_ing,BelvedereEntity.ENTITY_TYPE.COLLECT)
	local helpToTroops = City:GetHelpToTroops()
	self:Handler2BelvedereEntity(my_events,helpToTroops,BelvedereEntity.ENTITY_TYPE.HELPTO)
	local shrine_Event = self:GetAlliance():GetAllianceShrine():GetSelfJoinedShrineEvent()
	self:Handler2BelvedereEntity(my_events,{shrine_Event},BelvedereEntity.ENTITY_TYPE.SHIRNE)
	--所有正在进行的返回行军
	local marching_out_return_events = LuaUtils:table_filteri(self:GetAlliance():GetAttackMarchReturnEvents(),function(_,marchAttackEvent)
		return marchAttackEvent:GetPlayerRole() == marchAttackEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	self:Handler2BelvedereEntity(my_events,marching_out_return_events,BelvedereEntity.ENTITY_TYPE.MARCH_RETURN)
	--突袭
	local marching_strike_events = LuaUtils:table_filteri(self:GetAlliance():GetStrikeMarchEvents(),function(_,strikeMarchEvent)
		return strikeMarchEvent:GetPlayerRole() == strikeMarchEvent.MARCH_EVENT_PLAYER_ROLE.SENDER 
	end)
	self:Handler2BelvedereEntity(my_events,marching_strike_events,BelvedereEntity.ENTITY_TYPE.STRIKE_OUT)
	local marching_strike_events_return = LuaUtils:table_filteri(self:GetAlliance():GetStrikeMarchReturnEvents(),function(_,strikeMarchReturnEvent)
		return strikeMarchReturnEvent:GetPlayerRole() == strikeMarchReturnEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER 
	end)
	self:Handler2BelvedereEntity(my_events,marching_strike_events_return,BelvedereEntity.ENTITY_TYPE.STRIKE_RETURN)
	return my_events
end

function AllianceBelvedere:Reset()
	self:ClearAllListener()
end

--TODO:返回是否有瞭望塔事件发生!
function AllianceBelvedere:HasEvent()
	if self:GetAlliance():IsDefault() then return false end

end

function AllianceBelvedere:OnAttackMarchEventTimerChanged(attackMarchEvent)
	if attackMarchEvent:GetPlayerRole() == attackMarchEvent.MARCH_EVENT_PLAYER_ROLE.NOTHING then return end
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged,{attackMarchEvent})
end
function AllianceBelvedere:OnAttackMarchReturnEventDataChanged(changed_map)
	local showMarch = false 
	for _,data in pairs(changed_map) do
		if showMarch then break end
		for _,marchReturnEvent in ipairs(data) do
			if marchReturnEvent:GetPlayerRole() == marchReturnEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
				showMarch = true
				break
			end
		end
	end
	if showMarch then
		self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged,{})
	end
end
function AllianceBelvedere:OnStrikeMarchEventDataChanged(changed_map)
	if self:GetAlliance():NeedUpdateEnemyAlliance() then --my alliance
		local showMarch,showComming = false,false
		for _,data in pairs(changed_map) do
			if showMarch or showComming then break end
			for _,strikeMarchEvent in ipairs(data) do
				if strikeMarchEvent:GetPlayerRole() == strikeMarchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
					showComming = true
					break
				end
				if strikeMarchEvent:GetPlayerRole() == strikeMarchEvent.MARCH_EVENT_PLAYER_ROLE.SENDER then
					showMarch = true
					break
				end
			end
		end
		if showMarch then
			self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged,{})
		end
		if showComming then
			self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnCommingDataChanged,{})
		end
	else
		self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnStrikeMarchEventDataChanged,{changed_map})
	end
end
function AllianceBelvedere:OnStrikeMarchReturnEventDataChanged(changed_map)
	local showMarch = false 
	for _,data in pairs(changed_map) do
		if showMarch then break end
		for _,strikeMarchReturnEvent in ipairs(data) do
			if strikeMarchReturnEvent:GetPlayerRole() == strikeMarchReturnEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
				showMarch = true
				break
			end
		end
	end
	if showMarch then
		self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged,{})
	end
end
function AllianceBelvedere:OnVillageEventsDataChanged(changed_map)
	local showMarch = false 
	for _,data in pairs(changed_map) do
		if showMarch then break end
		for _,villageEvent in ipairs(data) do
			if villageEvent:GetPlayerRole() == villageEvent.EVENT_PLAYER_ROLE.Me then
				showMarch = true
				break
			end
		end
	end
	if showMarch then
		self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged,{})
	end
end
function AllianceBelvedere:OnVillageEventTimer(villageEvent,left_resource)
	if villageEvent:GetPlayerRole() ~= villageEvent.EVENT_PLAYER_ROLE.Me then return end
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnVillageEventTimer,{villageEvent,left_resource})
end
function AllianceBelvedere:OnAttackMarchEventDataChanged(changed_map)
	if self:GetAlliance():NeedUpdateEnemyAlliance() then --my alliance
		local showMarch,showComming = false,false
		for _,data in pairs(changed_map) do
			if showMarch or showComming then break end
			for _,marchEvent in ipairs(data) do
				if marchEvent:GetPlayerRole() == marchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
					showComming = true
					break
				end
				if marchEvent:GetPlayerRole() == marchEvent.MARCH_EVENT_PLAYER_ROLE.SENDER then
					showMarch = true
					break
				end
			end
		end
		if showMarch then
			self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged,{})
		end
		if showComming then
			self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnCommingDataChanged,{})
		end
	else
		self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventDataChanged,{changed_map})
	end
end

function AllianceBelvedere:OnShrineEventsChanged(changed_map)
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged,{})
end

function AllianceBelvedere:OnFightEventTimerChanged(fightEvent)
	self:CallEventsChangedListeners(AllianceBelvedere.LISTEN_TYPE.OnFightEventTimerChanged,{fightEvent}) 
end

function AllianceBelvedere:CallEventsChangedListeners(LISTEN_TYPE,args)
	-- print("AllianceBelvedere:CallEventsChangedListeners--->",self:GetAlliance():Name(),AllianceBelvedere.LISTEN_TYPE[LISTEN_TYPE])
    self:NotifyListeneOnType(LISTEN_TYPE, function(listener)
        listener[AllianceBelvedere.LISTEN_TYPE[LISTEN_TYPE]](listener,unpack(args))
    end)
end

--- 瞭望塔功能函数
function AllianceBelvedere:DisplayMarchEventInMap()
	return City:GetWatchTowerLevel() > 1
end

function AllianceBelvedere:GetWarningTime()
	local level = City:GetWatchTowerLevel()
	
end

return AllianceBelvedere