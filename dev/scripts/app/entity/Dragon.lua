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
local config_equipment_buffs = GameDatas.DragonEyrie.equipmentBuff
local config_dragoneyrie = GameDatas.DragonEyrie

--装备类别/身体部位:左护甲，头盔，右护甲，法球，胸甲，尾刺
Dragon.DRAGON_BODY = Enum("armguardLeft","crown","armguardRight","orb","chest","sting")

--DragonSkill
----------------------------------------------------------------------------------------------------
--dragon_star是当前龙的星级
function DragonSkill:ctor(key,name,level,dragon_star,dragon_type)
	property(self, "level", level)
	property(self, "name", name)
	property(self, "key", key)
	property(self, "star", dragon_star)
	property(self, "type", dragon_type)
	self:LoadConfig_()
end

--将配置表里的数据直接注入object
function DragonSkill:LoadConfig_()
	self.config_ = config_dragonSkill[self:Name()]
end

function DragonSkill:GetSkillConfig()
	return self.config_
end

function DragonSkill:IsLocked()
	return self:Star() < self:GetSkillConfig().unlockStar
end

--获取技能的效果
function DragonSkill:GetEffect()
	return self:Level() * self:GetSkillConfig().effection
end

function DragonSkill:OnPropertyChange( ... )
end

--DragonEquipment
----------------------------------------------------------------------------------------------------
function DragonEquipment:ctor( body,type)
	property(self, "exp", 0)
	property(self, "star", 0)
	property(self, "name", "")
	property(self, "isLocked", true) -- 是否锁住
	property(self, "body", body) -- 部位
	property(self, "type", type) -- 龙类型
	self.buffs_ = {}
end


function DragonEquipment:SetBuffData(json_data)
	self.buffs_ = json_data
end

function DragonEquipment:GetBuffData()
	return self.buffs_
end

function DragonEquipment:IsReachMaxStar()
	return self:MaxStar() == self:Star()
end

function DragonEquipment:IsLoaded()
	return self:Name() ~= ""
end

function DragonEquipment:MaxStar()
	return self.maxStar_
end

function DragonEquipment:SetMaxStar(maxStar)
	self.maxStar_ = maxStar
end

function DragonEquipment:GetCanLoadConfig()
	return self.config_
end

function DragonEquipment:SetCanLoadConfig(config)
	self.config_ = config
end

function DragonEquipment:GetDetailConfig()
	return config_dragoneyrie[self:Body()][self:MaxStar() .. "_" .. self:Star()]
end

function DragonEquipment:GetNextStarDetailConfig()
	assert((self:Star()+1)<=self:MaxStar())
	return config_dragoneyrie[self:Body()][self:MaxStar() .. "_" .. (self:Star()+1)]
end

function DragonEquipment:GetVitalityAndStrengh()
  	local config_category = self:GetDetailConfig()
  	return config_category.vitality,config_category.strength
end

function DragonEquipment:GetBufferAndEffect()
	local r = {}
  	for _,v in ipairs(self:GetBuffData()) do
    	table.insert(r,{v,config_equipment_buffs[v].buffEffect})
  	end
  return r
end

function DragonEquipment:OnPropertyChange( ... )
end

--Dragon
----------------------------------------------------------------------------------------------------
function Dragon:ctor(drag_type,strength,vitality,status,star,level,exp,hp)
	property(self, "type", drag_type)
	property(self, "totalStrength", strength)
	property(self, "totalVitality", vitality)
	property(self, "status", status)
	property(self, "star", star)
	property(self, "level", level)
	property(self, "exp", exp)
	property(self, "hp", hp)
	self.skills_ = {}
	self.equipments_ = self:DefaultEquipments()
	self:CheckEquipemtIfLocked_()
end
--自身的力量
function Dragon:Strength()
  	return config_dragonAttribute[self:Star()].initStrength + self:Level() * config_dragonAttribute[self:Star()].perLevelStrength 
end
--自身的活力
function Dragon:Vitality()
	return config_dragonAttribute[self:Star()].initVitality + self:Level() * config_dragonAttribute[self:Star()].perLevelVitality 
end

function Dragon:GetLocalizedStatus()
	return Localize.dragon_status[self:Status()]
end

function Dragon:UpdateEquipmetsAndSkills(json_data)
	for k,v in pairs(json_data.equipments) do
		local eq = self:GetEquipmentByBody(self.DRAGON_BODY[k])
		eq:SetName(v.name)
		eq:SetExp(v.exp or 0)
		eq:SetStar(v.star or 0)
		eq:SetBuffData(v.buffs)
	end
	for k,v in pairs(json_data.skills) do
		local skill = DragonSkill.new(k,v.name,v.level,self:Star(),self:Type())
		self.skills_[k] = skill
	end
end

function Dragon:OnPropertyChange( ... )
end

function Dragon:Skills()
	return self.skills_
end

function Dragon:GetSkillByKey(key) 
	return self.skills_[key]
end

function Dragon:Update(json_data)
	self:SetType(json_data.type)
	self:SetTotalStrength(json_data.strength)
	self:SetTotalVitality(json_data.vitality)
	self:SetStatus(json_data.status)

	local star = self:Star()
	self:SetStar(json_data.star)
	if json_data.star ~= star then
		self:CheckEquipemtIfLocked_()
	end
	self:SetExp(json_data.exp)
	self:SetHp(json_data.hp)
	self:SetLevel(json_data.level)
	self:UpdateEquipmetsAndSkills(json_data)
end

function Dragon:CheckEquipemtIfLocked_()
	 for name,equipment in pairs(config_equipments) do
        if equipment.maxStar == self:Star() and self:Type() == equipment.usedFor then
            if equipment["category"] == "armguardLeft,armguardRight" then --如果是护肩 初始化左右
            	self:GetEquipmentByBody(self.DRAGON_BODY.armguardLeft):SetIsLocked(false)
            	self:GetEquipmentByBody(self.DRAGON_BODY.armguardLeft):SetCanLoadConfig(equipment)
            	self:GetEquipmentByBody(self.DRAGON_BODY.armguardLeft):SetMaxStar(equipment.maxStar)
            	self:GetEquipmentByBody(self.DRAGON_BODY.armguardRight):SetIsLocked(false)
            	self:GetEquipmentByBody(self.DRAGON_BODY.armguardRight):SetCanLoadConfig(equipment)
            	self:GetEquipmentByBody(self.DRAGON_BODY.armguardRight):SetMaxStar(equipment.maxStar)
          	else
          		self:GetEquipmentByBody(self.DRAGON_BODY[equipment["category"]]):SetIsLocked(false)
          		self:GetEquipmentByBody(self.DRAGON_BODY[equipment["category"]]):SetCanLoadConfig(equipment)
          		self:GetEquipmentByBody(self.DRAGON_BODY[equipment["category"]]):SetMaxStar(equipment.maxStar)
            end
        end

    end
end

function Dragon:EquipmentsIsReachMaxStar()
	dump(self:Equipments())
	local isReach = true
	for i,equipment in ipairs(self:Equipments()) do
		if not equipment:IsReachMaxStar() and not equipment:IsLocked() then
			isReach = false
			break
		end
	end
	return isReach
end

function Dragon:GetLocalizedName()
	return Localize.dragon[self:Type()]
end

--龙的地表
function Dragon:GetTerrain()
	local terrains = 
	{
        redDragon = "desert",
        greenDragon = "grass",
        blueDragon = "icefield"
    }
    return terrains[self:Type()]
end

--是否已孵化
function Dragon:Ishated()
	return self:Star() > 0
end

function Dragon:GetEquipmentByBody( category )
	local arg_type = type(category)
	if arg_type == 'number' then
		return self.equipments_[category]
	elseif arg_type == 'string' then
		return self.equipments_[self.DRAGON_BODY[category]]
	else
		assert(false)
	end
end


--装备
function Dragon:Equipments()
	return self.equipments_
end

--装备默认装备 读配置表
function Dragon:DefaultEquipments()
	local r = {}
    r[self.DRAGON_BODY.armguardLeft] = DragonEquipment.new("armguardLeft",self:Type())
    r[self.DRAGON_BODY.crown] = DragonEquipment.new("crown",self:Type())
    r[self.DRAGON_BODY.armguardRight] = DragonEquipment.new("armguardRight",self:Type())
    r[self.DRAGON_BODY.orb] = DragonEquipment.new("orb",self:Type())
    r[self.DRAGON_BODY.chest] = DragonEquipment.new("chest",self:Type())
    r[self.DRAGON_BODY.sting] = DragonEquipment.new("sting",self:Type())
    return r
end

function Dragon:GetMaxHP()
	return self:TotalVitality() * 2
end


--该等级下的
-- function Dragon:GetMaxHP()
	 -- return config_dragonAttribute[self:Star()].initVitality + self:Level() * config_dragonAttribute[self:Star()].perLevelVitality 
-- end

--升级需要的经验值
function Dragon:GetMaxExp()
	return tonumber(config_dragonAttribute[self:Star()].perLevelExp) * math.pow(self:Level(),2)
end
--当前星级最大等级
function Dragon:GetMaxLevel()
	return config_dragonAttribute[self:Star()].levelMax
end

--是否达到晋级等级
function Dragon:IsReachPromotionLevel()
	 return self:Level() >= self:GetPromotionLevel()
end

function Dragon:MaxStar()
	return 4
end

function Dragon:GetPromotionLevel()
	local star = self:Star() + 1 > self:MaxStar() and self:MaxStar() or self:Star() + 1
	return config_dragonAttribute[star].promotionLevel
end

--获取所有装备的buffers信息
function Dragon:GetAllEquipmentBuffEffect()
	local equipmentsbuffs = {}
	local buffer_count = {}
	for _,equipment in pairs(self:Equipments()) do
		for i,v in ipairs(equipment:GetBuffData()) do
			if not buffer_count[v] then
				buffer_count[v] = 1
			else
				buffer_count[v] = buffer_count[v] + 1
			end
		end
	end
	for key,v in pairs(buffer_count) do
		table.insert(equipmentsbuffs,{key,config_equipment_buffs[key].buffEffect * v})
	end
	return equipmentsbuffs
end
--获取所有技能的Buffer
function Dragon:GetAllSkillBuffEffect()
	local r = {}
	table.foreach(self:Skills(),function(key,skill)
		if not skill:IsLocked() then
			table.insert(r,{skill:Name(),skill:GetEffect()})
		end
	end)
	return r
end
--算最强龙
function Dragon:GetWeight()
	if not self:Ishated() then
		return 0
	else 
		return self:TotalVitality() * self:TotalStrength()
	end
end

return Dragon