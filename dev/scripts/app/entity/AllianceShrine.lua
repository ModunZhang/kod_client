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

AllianceShrine.LISTEN_TYPE = Enum("OnPerceotionChanged")

function AllianceShrine:ctor(alliance)
	AllianceShrine.super.ctor(self)
	self.alliance = alliance
	property(self,"passStage","1_1")
end

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

function AllianceShrine:OnPropertyChange(property_name, old_value, value)
end

function AllianceShrine:GetMaxStageFromServer(alliance_data)
	local large_key = "1_1"
	if alliance_data.shrineDatas then
		for _,v in ipairs(alliance_data.shrineDatas) do
			if key > v.stageName then
				large_key = v.stageName
			end
			self:GetStatgeByName(v.stageName):SetIsLocked(false)
		end
	end
	--解锁下一个Stage
	
end

function AllianceShrine:DecodeObjectsFromJsonAlliance(alliance_data)
	self:SetPassStage(alliance_data.passStage or self:PassStage())
	self:loadStages()
	
	if not self.perception then
		local resource_refresh_time = alliance_data.basicInfo.perceptionRefreshTime / 1000.0
		self.perception = AutomaticUpdateResource.new()
		self.perception:UpdateResource(resource_refresh_time,alliance_data.basicInfo.perception)
		local shire_building = config_shrine[alliance_data.buildings.shrine.level]
        self.perception:SetProductionPerHour(resource_refresh_time,shire_building.pRecovery)
        self.perception:SetValueLimit(shire_building.perception)
    else
    	if alliance_data.buildings and alliance_data.buildings.shrine.level then
    		self.perception:UpdateResource(resource_refresh_time,alliance_data.basicInfo.perception)
    		local shire_building = config_shrine[alliance_data.buildings.shrine.level]
        	self.perception:SetProductionPerHour(resource_refresh_time,shire_building.pRecovery)
        	self.perception:SetValueLimit(shire_building.perception)
    	end
	end
end

function AllianceShrine:OnAllianceDataChanged(alliance_data)
	self:DecodeObjectsFromJsonAlliance(alliance_data)
end

function AllianceShrine:GetPerceptionResource()
	return self.perception
end

function AllianceShrine:OnTimer(current_time)
	if self.perception then
		self.perception:OnTimer(current_time)
		self:OnPerceotionChanged()
	end
end

function AllianceShrine:OnPerceotionChanged()
	self:NotifyListeneOnType(self.LISTEN_TYPE.OnPerceotionChanged,function(lisenter)
		lisenter.OnPerceotionChanged(lisenter)
	end)
end

-- api
--------------------------------------------------------------------------------------
--联盟危机
function AllianceShrine:GetStatgeByName(state_name)
	return self:Stages()[state_name]
end

-- state is number
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

return AllianceShrine