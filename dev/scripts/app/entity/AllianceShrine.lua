--
-- Author: Danny He
-- Date: 2014-11-07 15:21:22
--
local config_shrineStage = GameDatas.AllianceShrine.shrineStage
local AllianceShrineStage = import(".AllianceShrineStage")
local MultiObserver = import(".MultiObserver")
local property = import("..utils.property")
local AllianceShrine = class("AllianceShrine",MultiObserver)
local AutomaticUpdateResource = import(".AutomaticUpdateResource")

function AllianceShrine:ctor(alliance)
	self.alliance = alliance
	property(self,"passStage","1_1")
end

function AllianceShrine:loadStages()
	if self.stages then return end
	local stages_ = {}
	local large_key = "1_1"
	table.foreach(config_shrineStage,function(key,config)
		local stage = AllianceShrineStage.new(key > self:PassStage(),config) 
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

function AllianceShrine:DecodeObjectsFromJsonMapObjects(alliance_data)
	self:SetPassStage(alliance_data.passStage or self:PassStage())
	self:loadStages()
	if not self.perception then
		--TODO:
	end
end

function AllianceShrine:OnAllianceDataChanged(alliance_data)
	self:DecodeObjectsFromJsonMapObjects(alliance_data)
end
--TODO:
function AllianceShrine:OnTimer(current_time)
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