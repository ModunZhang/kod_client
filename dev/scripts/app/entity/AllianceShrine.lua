--
-- Author: Danny He
-- Date: 2014-11-07 15:21:22
--
local config_shrineStage = GameDatas.AllianceShrine.shrineStage
local config_shrine = GameDatas.AllianceBuilding.shrine
local AllianceShrineStage = import(".AllianceShrineStage")
local MultiObserver = import(".MultiObserver")
local property = import("..utils.property")
local AllianceShrine = class("AllianceShrine",MultiObserver)
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local Enum = import("..utils.Enum")
local ShrineFightEvent = import(".ShrineFightEvent")
local ShrineMarchEvent = import(".ShrineMarchEvent")
local ShrineReport = import(".ShrineReport")

AllianceShrine.LISTEN_TYPE = Enum(
	"OnPerceotionChanged",
	"OnNewStageOpened",
	"OnFightEventTimerChanged",
	"OnShrineEventsChanged",
	"OnMarchEventsChanged",
	"OnMarchReturnEventsChanged",
	"OnMarchEventTimerChanged",
	"OnShrineReportsChanged"
)
-- 数据处理函数
--------------------------------------------------------------------------------
local Event_Handler_Func = function(events,add_func,edit_func,remove_func)
	local not_hanler = function(...)end
	add_func = add_func or not_hanler
	remove_func = remove_func or not_hanler
	edit_func = edit_func or not_hanler

	local added,edited,removed = {},{},{}
	for _,event in ipairs(events) do
		if event.type == 'add' then
			table.insert(added,add_func(event.data))
		elseif event.type == 'edit' then
			table.insert(edited,edit_func(event.data))
		elseif event.type == 'remove' then
			table.insert(removed,remove_func(event.data))
		end
	end
	return {added,edited,removed} -- each of return is a table
end

local pack_map = function(map)
	local ret = {}
	local added,edited,removed = unpack(map)
	if #added > 0 then ret.added = checktable(added) end
	if #edited > 0 then ret.edited = checktable(edited) end
	if #removed > 0 then ret.removed = checktable(removed) end
	return ret
end
--------------------------------------------------------------------------------

function AllianceShrine:ctor(alliance)
	AllianceShrine.super.ctor(self)
	self.alliance = alliance
	self.shrineEvents = {} -- 关卡事件
	self.shrineMarchEvents = {} -- 部队出征
	self.shrineMarchReturnEvents = {} -- 部队返回圣地
	self.shrineReports = {}
	self:loadStages()
end

function AllianceShrine:GetAlliance()
	return self.alliance
end

--配置表加载所有的关卡
function AllianceShrine:loadStages()
	if self.stages then return end
	local stages_ = {}
	local large_key = "1_1"
	table.foreach(config_shrineStage,function(key,config)
		local stage = AllianceShrineStage.new(config) 
		stages_[key] = stage
		if key > large_key then
			large_key = key
		end
	end)
	property(self,"stages",stages_)
	local s,_ = string.find(large_key,"_")
	local ret = string.sub(large_key,1,s-1)
	property(self,"maxCountOfStage",checknumber(ret))
end
-- 这里是否需要先监听者发送移除指令?
function AllianceShrine:Reset()
	table.foreach(self:Stages(),function(stage_name,stage)
		stage:Reset()
	end)
	table.foreach(self.shrineEvents,function(_,shrineEvent)
		shrineEvent:Reset()
	end)
	table.foreach(self.shrineMarchEvents,function(_,marchEvent)
		marchEvent:Reset()
	end)

	table.foreach(self.shrineMarchReturnEvents,function(_,marchEvent)
		marchEvent:Reset()
	end)

	self.shrineEvents = {}
	self.shrineMarchEvents = {}
	self.shrineMarchReturnEvents = {}
	self.shrineReports = {}
	self.maxCountOfStage = nil
	self.perception = nil

end

function AllianceShrine:OnPropertyChange(property_name, old_value, value)
end

function AllianceShrine:GetMaxStageFromServer(alliance_data)
	--默认第一关始终打开
	self:GetStatgeByName("1_1"):SetIsLocked(false)
	if alliance_data.shrineDatas then
		local large_key = ""
		for _,v in ipairs(alliance_data.shrineDatas) do
			if v.stageName > large_key then
				large_key = v.stageName
			end
			self:GetStatgeByName(v.stageName):SetIsLocked(false)
			self:GetStatgeByName(v.stageName):SetStar(v.maxStar)
		end
		if large_key ~= "" then
			local next_stage = self:GetStageByIndex(self:GetStatgeByName(large_key):Index() + 1)
			if next_stage then
				next_stage:SetIsLocked(false)
			end
		end
	end
	if alliance_data.__shrineDatas then
		local changed_map = {
			added = {},
			edited = {},
			removed = {}
		}

		local large_key = ""
		for _,v in ipairs(alliance_data.__shrineDatas) do
			if changed_map[v.type] then
				table.insert(changed_map[v.type],v.data)
			end
			if v.data.stageName > large_key then
				large_key = v.data.stageName
			end
			self:GetStatgeByName(v.data.stageName):SetIsLocked(false)
			self:GetStatgeByName(v.data.stageName):SetStar(v.data.maxStar)
		end
		if large_key ~= "" then
			local next_stage = self:GetStageByIndex(self:GetStatgeByName(large_key):Index() + 1)
			if next_stage then
				next_stage:SetIsLocked(false)
			end
		end
		self:OnNewStageOpened(changed_map)
	end
end

function  AllianceShrine:OnNewStageOpened(changed_map)
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnNewStageOpened,function(listener)
		listener.OnNewStageOpened(listener,changed_map)
	end)
end
-- 洞察力 TODO:升级后改变生产量(alliance_data.buildings.shrine.level)
function AllianceShrine:InitOrUpdatePerception(alliance_data)
	if not  alliance_data.basicInfo or not alliance_data.basicInfo.perceptionRefreshTime then return end
	if not self.perception then
		local resource_refresh_time = alliance_data.basicInfo.perceptionRefreshTime / 1000.0
		self.perception = AutomaticUpdateResource.new()
		self.perception:UpdateResource(resource_refresh_time,alliance_data.basicInfo.perception)
		local shire_building = config_shrine[alliance_data.buildings.shrine.level]
        self.perception:SetProductionPerHour(resource_refresh_time,shire_building.pRecovery)
        self.perception:SetValueLimit(shire_building.perception)
    else
    	if alliance_data.basicInfo and alliance_data.basicInfo.perception then
    		local resource_refresh_time = alliance_data.basicInfo.perceptionRefreshTime / 1000.0
    		self.perception:UpdateResource(resource_refresh_time,alliance_data.basicInfo.perception)
    	end
	end
end

function AllianceShrine:OnTimer(current_time)
	if self.perception then
		self.perception:OnTimer(current_time)
		self:OnPerceotionChanged()
	end
	for _,shrineEvent in pairs(self.shrineEvents) do
		shrineEvent:OnTimer(current_time)
	end
	for _,marchEvent in pairs(self.shrineMarchEvents) do
		marchEvent:OnTimer(current_time)
	end
end

function AllianceShrine:OnPerceotionChanged()
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnPerceotionChanged,function(listener)
		listener.OnPerceotionChanged(listener)
	end)
end

function AllianceShrine:GetPerceptionResource()
	return self.perception
end

--事件
function AllianceShrine:OnFightEventTimer(fightEvent)
	self:OnFightEventTimerChanged(fightEvent)
end

function AllianceShrine:OnFightEventTimerChanged(fightEvent)
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnFightEventTimerChanged,function(listener)
		listener.OnFightEventTimerChanged(listener,fightEvent)
	end)
end

function  AllianceShrine:OnMarchEventTimer(marchEvent)
	self:OnMarchEventTimerChanged(marchEvent)
end

function AllianceShrine:OnMarchEventTimerChanged(marchEvent)
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnMarchEventTimerChanged,function(listener)
		listener.OnMarchEventTimerChanged(listener,marchEvent)
	end)
end

function AllianceShrine:RefreshEvents(alliance_data)
	if alliance_data.shrineEvents then
		for _,v in ipairs(alliance_data.shrineEvents) do
			local fightEvent = ShrineFightEvent.new()
			fightEvent:Update(v)
			local palyerDatas = {}
			for _,playerData in ipairs(v.playerTroops) do
				playerData.location = self:GetPlayerLocation(playerData.id)
				table.insert(palyerDatas,playerData)
			end
			fightEvent:SetPlayerTroops(palyerDatas)
			fightEvent:SetStage(self:GetStatgeByName(fightEvent:StageName()))
			self.shrineEvents[fightEvent:Id()] = fightEvent
			fightEvent:AddObserver(self)
		end
	end
	self:RefreshShrineEvents(alliance_data.__shrineEvents)

	if alliance_data.shrineMarchEvents then
		for _,v in ipairs(alliance_data.shrineMarchEvents) do
			local marchEvent = ShrineMarchEvent.new()
			marchEvent:Update(v)
			local from = self:GetPlayerLocation(marchEvent:PlayerData().id)
			local shire_object = self:GetShireObjectFromMap()
			local to = {x = shire_object.location.x,y = shire_object.location.y}
			marchEvent:SetLocationInfo(from,to)
			self.shrineMarchEvents[marchEvent:Id()] = marchEvent
			marchEvent:AddObserver(self)
		end
	end
	self:RefreshMarchEvents(alliance_data.__shrineMarchEvents)

	if alliance_data.shrineMarchReturnEvents then
		for _,v in ipairs(alliance_data.shrineMarchReturnEvents) do
			local marchEvent = ShrineMarchEvent.new()
			marchEvent:Update(v)
			local shire_object = self:GetShireObjectFromMap()
			local to = self:GetPlayerLocation(marchEvent:PlayerData().id)
			local from = {x = shire_object.location.x,y = shire_object.location.y}
			marchEvent:SetLocationInfo(from,to)
			self.shrineMarchReturnEvents[marchEvent:Id()] = marchEvent
			marchEvent:AddObserver(self)
		end
	end
	self:RefreshMarchReturnEvents(alliance_data.__shrineMarchReturnEvents)

	if alliance_data.shrineReports then
		for _,v in ipairs(alliance_data.shrineReports) do
			local report = ShrineReport.new()
			report:Update(v)
			report:SetStage(self:GetStatgeByName(report:StageName()))
			table.insert(self.shrineReports,report)
		end
	end
	self:RefreshShrineReports(alliance_data.__shrineReports)
end


function AllianceShrine:RefreshShrineReports( __shrineReports )
	if not __shrineReports then return end
	local change_map = Event_Handler_Func(
		__shrineReports
		,function(event)
				local report = ShrineReport.new()
				report:Update(event)
				report:SetStage(self:GetStatgeByName(report:StageName()))
				table.insert(self.shrineReports,report)
				return report
		end
		,function(event) 
			--修改事件记录?
		end
		,function(event)
			table.remove(self.shrineReports,#self.shrineReports)
			local report = ShrineReport.new()
			report:Update(event)
			report:SetStage(self:GetStatgeByName(report:StageName()))
			return report
		end
	)
	self:OnShrineReportsChanged(pack_map(change_map))
end

function AllianceShrine:OnShrineReportsChanged(changed_map)
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnShrineReportsChanged,function(listener)
		listener.OnShrineReportsChanged(listener,changed_map)
	end)
end

function AllianceShrine:RefreshMarchReturnEvents(__shrineMarchReturnEvents)
	if not __shrineMarchReturnEvents then return end
	local change_map = Event_Handler_Func(
		__shrineMarchReturnEvents
		,function(event) --add
			if not self.shrineMarchReturnEvents[event.id] then
				local marchEvent = ShrineMarchEvent.new()
				marchEvent:Update(event)
				local shire_object = self:GetShireObjectFromMap()
				local to = self:GetPlayerLocation(marchEvent:PlayerData().id)
				local from = {x = shire_object.location.x,y = shire_object.location.y}
				marchEvent:SetLocationInfo(from,to)
				self.shrineMarchReturnEvents[marchEvent:Id()] = marchEvent
				marchEvent:AddObserver(self)
				return marchEvent
			end
		end
		,function(event) 
			--TODO:行军返回事件的修改 (加速道具？)
		end
		,function(event) --remove
			local marchEvent = self:GetMarchReturnEventById(event.id)
			if marchEvent then
				marchEvent:RemoveObserver(self)
				self.shrineMarchReturnEvents[event.id] = nil
				return marchEvent
			end
		end
	)
	self:OnMarchReturnEventsChanged(pack_map(change_map))
end

function AllianceShrine:OnMarchReturnEventsChanged(changed_map)
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnMarchReturnEventsChanged,function(listener)
		listener.OnMarchReturnEventsChanged(listener,changed_map)
	end)
end

function AllianceShrine:RefreshMarchEvents(__shrineMarchEvents)
	if not __shrineMarchEvents then return end
	local change_map = Event_Handler_Func(
		__shrineMarchEvents
		,function(event) --add
			if not self.shrineMarchEvents[event.id] then
				local marchEvent = ShrineMarchEvent.new()
				marchEvent:Update(event)
				local from = self:GetPlayerLocation(marchEvent:PlayerData().id)
				local shire_object = self:GetShireObjectFromMap()
				local to = {x = shire_object.location.x,y = shire_object.location.y}
				marchEvent:SetLocationInfo(from,to)
				self.shrineMarchEvents[marchEvent:Id()] = marchEvent
				marchEvent:AddObserver(self)
				return marchEvent
			end
		end
		,function(event) 
			--TODO:行军事件的修改 (加速道具？)
		end
		,function(event) --remove
			local marchEvent = self:GetMarchEventById(event.id)
			if marchEvent then
				marchEvent:RemoveObserver(self)
				self.shrineMarchEvents[event.id] = nil
				return marchEvent
			end
		end
	)
	self:OnMarchEventsChanged(pack_map(change_map))
end

function AllianceShrine:OnMarchEventsChanged( changed_map )
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnMarchEventsChanged,function(listener)
		listener.OnMarchEventsChanged(listener,changed_map)
	end)
end

function AllianceShrine:RefreshShrineEvents(__shrineEvents)
	if not __shrineEvents then return end
	local change_map = Event_Handler_Func(
		__shrineEvents
		,function(event) --add
			if not self.shrineEvents[event.id] then
				local fightEvent = ShrineFightEvent.new()
				fightEvent:Update(event)
				local palyerDatas = {}
				for _,playerData in ipairs(event.playerTroops) do
					playerData.location = self:GetPlayerLocation(playerData.id)
					table.insert(palyerDatas,playerData)
				end
				fightEvent:SetPlayerTroops(palyerDatas)
				fightEvent:SetStage(self:GetStatgeByName(fightEvent:StageName()))
				self.shrineEvents[fightEvent:Id()] = fightEvent
				fightEvent:AddObserver(self)
				return fightEvent
			end
		end
		,function(event) --edit
			local fightEvent = self:GetShrineEventById(event.id)
			if fightEvent then
				fightEvent:Update(event)
				local palyerDatas = {}
				for _,playerData in ipairs(event.playerTroops) do
					playerData.location = self:GetPlayerLocation(playerData.id)
					table.insert(palyerDatas,playerData)
				end
				fightEvent:SetPlayerTroops(palyerDatas)
			end
			return fightEvent
		end
		,function(event) --remove
			local fightEvent = self:GetShrineEventById(event.id)
			if fightEvent then
				fightEvent:RemoveObserver(self)
				self.shrineEvents[event.id] = nil
				return fightEvent
			end
		end
	)
	self:OnShrineEventsChanged(pack_map(change_map))
end

function AllianceShrine:OnShrineEventsChanged(changed_map)
	printInfo("%s","AllianceShrine:OnShrineEventsChanged---->")
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnShrineEventsChanged,function(listener)
		listener.OnShrineEventsChanged(listener,changed_map)
	end)

end

-- 数据
function AllianceShrine:OnAllianceDataChanged(alliance_data)
	self:DecodeObjectsFromJsonAlliance(alliance_data)
end

function AllianceShrine:DecodeObjectsFromJsonAlliance(alliance_data)
	self:GetMaxStageFromServer(alliance_data)
	self:InitOrUpdatePerception(alliance_data)
	self:RefreshEvents(alliance_data)
end

function AllianceShrine:GetShireObjectFromMap()
	return self:GetAlliance():GetAllianceMap():FindAllianceBuildingInfoByName("shrine")
end

function AllianceShrine:GetPlayerLocation(playerId)
	return self:GetAlliance():GetMemeberById(playerId).location
end

-- api
--------------------------------------------------------------------------------------
--联盟危机

function AllianceShrine:GetShrineReports()
	return self.shrineReports
end

function AllianceShrine:GetMarchReturnEventById(id)
	return self.shrineMarchReturnEvents[id]
end

function AllianceShrine:GetMarchReturnEvents()
	local r = {}
	for _,v in pairs(self.shrineMarchReturnEvents) do
		table.insert(r,v)
	end
	table.sort( r, function(a,b)
		return a:ArriveTime() < b:ArriveTime()
	end )
	return r
end

function AllianceShrine:GetMarchEventById(id)
	return self.shrineMarchEvents[id]
end

function AllianceShrine:GetMarchEvents()
	local r = {}
	for _,v in pairs(self.shrineMarchEvents) do
		table.insert(r,v)
	end
	table.sort( r, function(a,b)
		return a:ArriveTime() < b:ArriveTime()
	end )
	return r
end

function AllianceShrine:GetShrineEventById(id)
	return self.shrineEvents[id]
end

function AllianceShrine:GetShrineEventByStageName(stage_name)
	for k,event in pairs(self.shrineEvents) do
		if event:Stage():StageName() == stage_name then
			return event
		end
	end
end

function AllianceShrine:GetShrineEvents()
	local r = {}
	for _,v in pairs(self.shrineEvents) do
		table.insert(r,v)
	end
	table.sort( r, function(a,b)
		return a:StartTime() < b:StartTime()
	end)
	return r
end

function AllianceShrine:GetStageByIndex(index)
	for _,v in pairs(self:Stages()) do
		if v:Index() == index then
			return v
		end
	end
	return nil
end

function AllianceShrine:GetStatgeByName(state_name)
	return self:Stages()[state_name]
end


function AllianceShrine:GetStarInfoByMainStage(statge_index)
	local current_star,total_star = 0,0
	for key,stage in pairs(self:Stages()) do
		if tonumber(string.sub(key,1,1)) == statge_index then
			current_star = current_star + stage:Star()
			total_star = total_star + stage:MaxStar()
		end
	end
	return current_star,total_star
end

-- state is number 1~6
function AllianceShrine:GetSubStagesByMainStage(statge_index)
	local tempStages = {}
	for key,stage in pairs(self:Stages()) do
		if tonumber(string.sub(key,1,1)) == statge_index then
			table.insert(tempStages,stage)
		end
	end
	table.sort(tempStages,function(a,b) return a:StageName() < b:StageName() end)
	return tempStages
end

function AllianceShrine:GetMainStageDescName(statge_index)
	return statge_index .. ".章节名本地化缺失"
end

function AllianceShrine:CheckPlayerCanDispathSoldiers(playerId)
	--check 已经驻防的部队
	for _,shireEvent in ipairs(self:GetShrineEvents()) do
		for _,shireEventPlayer in ipairs(shireEvent:PlayerTroops()) do
			if shireEventPlayer.id == playerId then
				printInfo("%s","已经驻防的部队检查到玩家信息")
				return false
			end
		end
	end
	--check 正在行军的部队
	for _,marchEvent in ipairs(self:GetMarchEvents()) do
		if marchEvent:PlayerData().id == playerId then
			printInfo("%s","正在行军的部队检查到玩家信息")
			return false
		end
	end
	return true
end

function AllianceShrine:CheckSelfCanDispathSoldiers()
	return self:CheckPlayerCanDispathSoldiers(User:Id())
end

return AllianceShrine