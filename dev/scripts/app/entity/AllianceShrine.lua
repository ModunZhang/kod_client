--
-- Author: Danny He
-- Date: 2014-11-07 15:21:22
--
local config_shrineStage = GameDatas.AllianceShrine.shrineStage
local AllianceShrine = class("AllianceShrine")

function AllianceShrine:ctor()

end


--联盟危机
function AllianceShrine:GetStatgeByName(state_name)
	return config_shrineStage[state_name]
end


function AllianceShrine:GetState(state)
	local states = {}
	table.foreach(config_shrineStage,function(key,state)
		if string.sub(key,1,1) == tostring(state) then 
			table.insert(states,state)
		end 
	end)
	return states
end

return AllianceShrine