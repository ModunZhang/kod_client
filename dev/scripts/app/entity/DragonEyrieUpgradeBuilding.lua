--
-- Author: Danny He
-- Date: 2014-09-17 09:22:12
--
local config_function = GameDatas.BuildingFunction.dragonEyrie
local config_levelup = GameDatas.BuildingLevelUp.dragonEyrie
local config_dragonAttribute = GameDatas.DragonEyrie.dragonAttribute
local config_equipments = GameDatas.SmithConfig.equipments
local ResourceManager = import(".ResourceManager")
local ResourceUpgradeBuilding = import(".ResourceUpgradeBuilding")
local DragonEyrieUpgradeBuilding = class("DragonEyrieUpgradeBuilding", ResourceUpgradeBuilding)
local DragonVitalityManager = import('.DragonVitalityManager')

function DragonEyrieUpgradeBuilding:ctor(building_info)
	DragonEyrieUpgradeBuilding.super.ctor(self,building_info)
	self.drgaon_vitality_manager = DragonVitalityManager.new()
end


function DragonEyrieUpgradeBuilding:OnTimer(current_time)
	DragonEyrieUpgradeBuilding.super.OnTimer(self,current_time)
	self.drgaon_vitality_manager:OnTimer(current_time)
end

function DragonEyrieUpgradeBuilding:EnergyMax()
	return config_function[self:GetLevel()].energyMax
end
-- 能量生产
function DragonEyrieUpgradeBuilding:GetProductionPerHour()
	return 3600 / self:GetTimePerEnergy()
end

function DragonEyrieUpgradeBuilding:GetTimePerEnergy()
	return config_function[self:GetLevel()].perEnergyTime
end

function DragonEyrieUpgradeBuilding:GetUpdateResourceType()
	return ResourceManager.RESOURCE_TYPE.ENERGY
end

function DragonEyrieUpgradeBuilding:OnUserDataChanged(user_data, current_time, location_id, sub_location_id)
	DragonEyrieUpgradeBuilding.super.OnUserDataChanged(self,user_data, current_time, location_id, sub_location_id)
	self:RefreshDragonData(user_data.dragons)
	self.drgaon_vitality_manager:UpdateDragonResource(user_data,self:GetVitalityRecoveryPerHour())
end

function DragonEyrieUpgradeBuilding:RefreshDragonData(dragons)
	self.dragons = dragons
	if self.listener and self.listener.DragonDataChanged then
		self.listener.DragonDataChanged(self.listener)
	end
end
-- 注意 这里将服务器的key进行排序 分页显示龙
function DragonEyrieUpgradeBuilding:GetDragonEntity(index)
	local drgons = {"blueDragon","greenDragon","redDragon"}
	return self.dragons[drgons[index]] or nil
end

function DragonEyrieUpgradeBuilding:SetListener(listener)
	self.listener = listener
end

function DragonEyrieUpgradeBuilding:RemoveListener()
	self.listener = nil
end
--最高等级
function DragonEyrieUpgradeBuilding:GetLevelMaxWithStar(star)
	return config_dragonAttribute[star].levelMax
end
--龙升级需要的经验值
function DragonEyrieUpgradeBuilding:GetNextLevelMaxExp(dragon)
	return tonumber(config_dragonAttribute[dragon.star].perLevelExp) * math.pow(dragon.level,2)
end

function DragonEyrieUpgradeBuilding:GetVitalityRecoveryPerHour()
	return config_function[self:GetLevel()].vitalityRecoveryPerHour
end

function DragonEyrieUpgradeBuilding:GetMaxVitalityCurrentLevel(dragon)
	-- self.drgaon_vitality_manager:GetVitalityLimitValue(dragon)
	return config_dragonAttribute[dragon.star].initVitality + dragon.level * config_dragonAttribute[dragon.star].perLevelVitality
end

--方便以后拓展 所以函数取这个名字
function DragonEyrieUpgradeBuilding:GetDragonDataManager()
	return self.drgaon_vitality_manager
end
---------------------------------------------------------------------------------------------------------------------
-- 配置表
function DragonEyrieUpgradeBuilding:GetEquipmentByName(name)
	return config_equipments[name]
end

-- 如果是Armguard类型的装备 一次是装两个
function DragonEyrieUpgradeBuilding:GetEquipmentsByStarAndType(dragonStar,dragonType)
	local r = {}
	for name,equipment in pairs(config_equipments) do
		if equipment.maxStar == dragonStar and dragonType == equipment.usedFor then
			if equipment["category"] == "armguardLeft,armguardRight" then
				r["armguardLeft"]  = equipment
				r["armguardRight"] = equipment
			else
				r[equipment["category"]] = equipment
			end
		end
	end
	LuaUtils:outputTable("GetEquipmentsByStarAndType----->", r)
	return r
end

function DragonEyrieUpgradeBuilding:GetEquipmentCategorys()
	return {"armguardLeft","crown","armguardRight","orb","chest","sting"}
end

return DragonEyrieUpgradeBuilding