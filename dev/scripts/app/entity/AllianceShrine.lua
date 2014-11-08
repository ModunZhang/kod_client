--
-- Author: Danny He
-- Date: 2014-11-07 15:21:22
--
local config_shrineStage = GameDatas.AllianceShrine.shrineStage
local AllianceShrineStage = import(".AllianceShrineStage")
local MultiObserver = import(".MultiObserver")
local property = import("..utils.property")
local AllianceShrine = class("AllianceShrine",MultiObserver)

function AllianceShrine:ctor(alliance)
	self.alliance = alliance
	property(self,"PassStateName","1_1")
end

function AllianceShrine:loadStages()
	local stages_ = {}
	table.foreach(config_shrineStage,function(key,config)
		local stage = AllianceShrineStage.new(key > self:PassStateName(),config) 
		stages_[key] = state
	end)
	property(self,"stages",stages_)
	dump(self:Stages())
end

function AllianceShrine:OnPropertyChange(property_name, old_value, value)
end

--联盟危机
function AllianceShrine:GetStatgeByName(state_name)
	return self:States()[state_name]
end

-- state is number
function AllianceShrine:GetStateByMainState(state_index)
	local tempStages = {}
	for key,state in pairs(self:States()) do
		if tonumber(string.sub(key,1,1)) == state_index then
			table.insert(tempStages,state)
		end
	end
	return tempStages
end

function AllianceShrine:DecodeObjectsFromJsonMapObjects(alliance_data)
	self:SetpassStateName("1_1")
end

function AllianceShrine:OnAllianceDataChanged(alliance_data)
	self:DecodeObjectsFromJsonMapObjects(alliance_data)
	dump(alliance_data)
end

return AllianceShrine