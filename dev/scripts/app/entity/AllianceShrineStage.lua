--
-- Author: Danny He
-- Date: 2014-11-07 17:09:04
--
-- 联盟圣地关卡
local AllianceShrineStage = class("AllianceShrineStage")
local property = import("..utils.property")


function AllianceShrineStage:ctor(config)
	property(self,"isLocked",true)
	self:loadProperty(config)
end

function AllianceShrineStage:loadProperty(config)
	property(self,"stageName",config.stageName)
	property(self,"stage",config.stage)
	property(self,"maxStar",3) -- 最大3星
	property(self,"subStage",config.subStage)
	property(self,"enemyPower",config.enemyPower)
	property(self,"index",config.index)
	property(self,"needPerception",config.needPerception)
	property(self,"suggestPlayer",config.suggestPlayer)
	property(self,"suggestPower",config.suggestPower)
	self:formatTroops(config.troops)
	property(self,"star2DeathPopulation",config.star2DeathPopulation)
	property(self,"star1Honour",config.star1Honour)
	property(self,"star2Honour",config.star2Honour)
	property(self,"star3Honour",config.star3Honour)
	property(self,"bronzeKill",config.bronzeKill)
	property(self,"silverKill",config.silverKill)
	property(self,"goldKill",config.goldKill)
	self:formatRewards("bronzeRewards",config.bronzeRewards)
	self:formatRewards("silverRewards",config.silverRewards)
	self:formatRewards("goldRewards",config.goldRewards)
end

function AllianceShrineStage:OnPropertyChange()
end

function AllianceShrineStage:GetDescStageName()
	return string.gsub(self:StageName(),'_','-') .. " 本地化缺失"
end

function AllianceShrineStage:GetStageDesc()
	return "关卡描述" .. self:StageName() .. "本地化缺失"
end

function AllianceShrineStage:Reset()
	self:SetIsLocked(true)
	self:SetStar(0)
end

--兵数量上下浮动20%
function AllianceShrineStage:formatTroops(str)
	local r = {}
	local troops_temp = string.split(str,",")
	for i,suntroops in ipairs(troops_temp) do
		local troops = string.split(suntroops,"_")
		-- for _,v in ipairs(troops) do
		-- 	local desc,count = unpack(string.split(v,":"))
		-- 	local troop_type,star =  unpack(string.split(desc,"_"))
		-- 	count = checknumber(count)
		-- 	local count_str = math.ceil(count*0.8) .. "-" .. math.ceil(count*1.2)
		-- 	table.insert(r,{type = troop_type,count = count_str,star = star})
		-- end
		local troop_type,star = troops[1],troops[2]
		local count =  checknumber(troops[3])
		local count_str = math.ceil(count*0.8) .. "-" .. math.ceil(count*1.2)
		table.insert(r,{type = troop_type,count = count_str,star = star})
	end
	property(self,"troops",r)
end

function AllianceShrineStage:formatRewards(name,rewards)
	local r = {}
	local reward_list = string.split(rewards,",")
	for i,v in ipairs(reward_list) do
		local reward_type,sub_type,count = unpack(string.split(v,":"))
		table.insert(r,{type = reward_type,count = count})
	end
	property(self,name,r)
end

function AllianceShrineStage:SetStar(star)
	if star >= 0 and  self:MaxStar() >= star then
		self.star_ = star
	end
end

function AllianceShrineStage:Star()
	return self.star_ or 0
end

return AllianceShrineStage