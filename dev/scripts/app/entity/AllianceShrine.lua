--
-- Author: Danny He
-- Date: 2014-11-07 15:21:22
--
local config_shrineStage = GameDatas.AllianceShrine.shrineStage
local AllianceShrineStage = import(".AllianceShrineStage")
local AllianceShrine = class("AllianceShrine")
local property = import("..utils.property")

function AllianceShrine:ctor()
end

function AllianceShrine:loadStages()
	local states_ = {}
	table.foreach(config_shrineStage,function(key,config)
		if string.sub(key,1,1) == tostring(state) then 
			local state = AllianceShrineStage.new(false) 
			state:loadProperty(config)
			states_[key] = state
		end 
	end)
	property(self,"states",states_)
	dump(self:States(),"states--->")
end

function AllianceShrine:OnPropertyChange()
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

return AllianceShrine