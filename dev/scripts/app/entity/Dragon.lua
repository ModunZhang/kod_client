--
-- Author: Danny He
-- Date: 2014-10-27 21:55:58
--
local property = import("app.utils.property")
local MultiObserver = import("app.entity.MultiObserver")
local Enum = import("app.utils.Enum")
local Dragon = class("Dragon",MultiObserver)
local DragonEquipment = class("DragonEquipment")
local DragonSkill =  class("DragonSkill")
local config_dragonAttribute = GameDatas.DragonEyrie.dragonAttribute
local config_equipments = GameDatas.SmithConfig.equipments
local config_dragonSkill = GameDatas.DragonEyrie.dragonSkill
local Localize = import("..utils.Localize")

--装备类别
Dragon.EQ_CATEGORY = Enum("armguardLeft","crown","armguardRight","orb","chest","sting")

--DragonSkill

function DragonSkill:ctor(dragon,key,name,level)
	property(self, "level", level)
	property(self, "name", name)
	property(self, "isLocked", isLocked)
	property(self, "dragon", dragon)
	property(self, "key", key)
	self:FitDefaultSkillConfig()
end

function DragonSkill:FitDefaultSkillConfig()
	for k,v in pairs(config_dragonSkill[self:Name()]) do
		property(self,k,v)
	end
end

--DragonEquipment
property(DragonEquipment, "exp", 0)
property(DragonEquipment, "star", 0)
function DragonEquipment:ctor( category,name,usedFor,maxStar,resolveLExp,resolveMExp,coin,makeTime)
	property(self, "category", category)
	property(self, "name", name)
	property(self, "usedFor", usedFor)
	property(self, "maxStar", maxStar)
	property(self, "resolveLExp", resolveLExp)
	property(self, "resolveMExp", resolveMExp)
	property(self, "resolveSExp", resolveSExp)
	property(self, "coin", coin)
	property(self, "makeTime", makeTime)
	self.buffs_ = {}
end

--TODO:buffers
function DragonEquipment:SetBuffData(json_data)

end

function DragonEquipment:IsReachMaxStar()
	return self:MaxStar() == self:Star()
end

--Dragon
function Dragon:ctor(drag_type,strength,vitality,status,star,level)
	property(self, "type", drag_type)
	property(self, "strength", strength)
	property(self, "vitality", vitality)
	property(self, "status", status)
	property(self, "star", star)
	property(self, "level", level)
	self.skills_ = {}
	self.equipments_ = self:FitDefaultEquipments()
end

--是否已孵化
function Dragon:Ishated()
	return self:Star() > 0
end

function Dragon:GetEquipmentByCategory( category )
	return self.equipments_[category]
end

function Dragon:Update(json_data)
	assert(self.equipments_)
	for k,v in pairs(json_data.equipments) do
		local eq = self:GetEquipmentByCategory(k)
		eq:setExp(v.exp or 0)
		eq:setStar(v.star or 0)
		eq:SetBuffData(v.buffs)
	end
	self.skills_ = {}
	for k,v in pairs(json_data.skills) do
		local skill = DragonSkill.new(self,k,v.name,v.level)
	end
end

--装备
function Dragon:Equipments()
	return self.equipments_
end

--装备默认装备 读配置表
function Dragon:FitDefaultEquipments()
	local r = {}
    for name,equipment in pairs(config_equipments) do
        if equipment.maxStar == self:Star() and self:Type() == equipment.usedFor then
            if equipment["category"] == "armguardLeft,armguardRight" then
                r[self.EQ_CATEGORY.armguardLeft]  = DragonEquipment.new(self.EQ_CATEGORY.armguardLeft,equipment.name,
                	equipment.usedFor,equipment.maxStar,equipment.resolveLExp,equipment.resolveMExp,equipment.resolveSExp,equipment.coin,equipment.makeTime)
                r[self.EQ_CATEGORY.armguardRight] = DragonEquipment.new(self.EQ_CATEGORY.armguardRight,equipment.name,
                	equipment.usedFor,equipment.maxStar,equipment.resolveLExp,equipment.resolveMExp,equipment.resolveSExp,equipment.coin,equipment.makeTime)
            else
                r[self.EQ_CATEGORY[equipment.category]] = DragonEquipment.new(self.EQ_CATEGORY[equipment["category"]],equipment.name,
                	equipment.usedFor,equipment.maxStar,equipment.resolveLExp,equipment.resolveMExp,equipment.resolveSExp,equipment.coin,equipment.makeTime)
            end
        end
    end
    return r
end

function Dragon:GetMaxVitalityCurrentLevel()
	 return config_dragonAttribute[self:Star()].initVitality + self:Level() * config_dragonAttribute[self:Star()].perLevelVitality
end

function Dragon:GetNextLevelMaxExp()
	return tonumber(config_dragonAttribute[self:Star()].perLevelExp) * math.pow(self:Level(),2)
end

function Dragon:GetMaxLevel()
	return config_dragonAttribute[self:Star()].levelMax
end
--TODO:获取所有buffers
function Dragon:GetAllBuffInfomation()

end

return Dragon