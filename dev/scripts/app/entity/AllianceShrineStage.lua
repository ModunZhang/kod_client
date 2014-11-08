--
-- Author: Danny He
-- Date: 2014-11-07 17:09:04
--
-- 联盟圣地关卡
local AllianceShrineStage = class("AllianceShrineStage")
local property = import("..utils.property")


function AllianceShrineStage:ctor(locked)
	property(self,"isLoacked",locked)
end

function AllianceShrineStage:loadProperty(config)
	property(self,"stageName",config.stageName)
	property(self,"stage",config.stage)
	property(self,"subStage",config.subStage)
	property(self,"enemyPower",config.enemyPower)
	property(self,"needPerception",config.needPerception)
	property(self,"suggestPlayer",config.suggestPlayer)
	property(self,"suggestPower",config.suggestPower)
	--TODO:troops
	property(self,"star2DeathPopulation",config.star2DeathPopulation)
	property(self,"star1Honour",config.star1Honour)
	property(self,"star2Honour",config.star2Honour)
	property(self,"star3Honour",config.star3Honour)
	property(self,"bronzeKill",config.bronzeKill)
	property(self,"silverKill",config.silverKill)
	property(self,"goldKill",config.goldKill)
	--TODO:rewards
end

function AllianceShrine:OnPropertyChange()
end


return AllianceShrineStage