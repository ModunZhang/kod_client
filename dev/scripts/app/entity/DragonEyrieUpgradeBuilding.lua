--
-- Author: Danny He
-- Date: 2014-09-17 09:22:12
--
local config_function = GameDatas.BuildingFunction.dragonEyrie
local config_levelup = GameDatas.BuildingLevelUp.dragonEyrie
-- local config_dragonAttribute = GameDatas.DragonEyrie.dragonAttribute
-- local config_equipments = GameDatas.SmithConfig.equipments
-- local config_equipment_buffs = GameDatas.DragonEyrie.equipmentBuff
-- local config_dragonSkill = GameDatas.DragonEyrie.dragonSkill
-- local Localize = import("..utils.Localize")

local ResourceManager = import(".ResourceManager")
local UpgradeBuilding = import(".UpgradeBuilding")
local DragonEyrieUpgradeBuilding = class("DragonEyrieUpgradeBuilding", UpgradeBuilding)
-- local DragonVitalityManager = import('.DragonVitalityManager')
local DragonManager = import(".DragonManager")


function DragonEyrieUpgradeBuilding:ctor(building_info)
    DragonEyrieUpgradeBuilding.super.ctor(self,building_info)
    -- self.drgaon_vitality_manager = DragonVitalityManager.new()
    self:SetDragonManager(DragonManager.new())
end


function DragonEyrieUpgradeBuilding:OnTimer(current_time)
    DragonEyrieUpgradeBuilding.super.OnTimer(self,current_time)
    -- self.drgaon_vitality_manager:OnTimer(current_time)
    self:GetDragonManager():OnTimer(current_time)
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
    self:GetDragonManager():OnUserDataChanged(user_data, current_time, location_id, sub_location_id,self:GetVitalityRecoveryPerHour())
    -- if user_data.dragons then
    --     self:RefreshDragonData(user_data.dragons)
    --     self.drgaon_vitality_manager:UpdateDragonResource(user_data,self:GetVitalityRecoveryPerHour())
    -- end
end

--DragonManager

function DragonEyrieUpgradeBuilding:SetDragonManager(manager)
    self.dragon_manger_ = manager
end

function DragonEyrieUpgradeBuilding:GetDragonManager()
    return self.dragon_manger_ 
end

-- function DragonEyrieUpgradeBuilding:RefreshDragonData(dragons)
--     if not self.dragons then
--         self.dragons = dragons
--     else
--         --遍历更新的龙信息
--         for k,v in pairs(dragons) do
--            self.dragons[k] = v
--         end
--     end
--     if self.listener and self.listener.DragonDataChanged then
--         self.listener.DragonDataChanged(self.listener)
--     end
-- end
-- 注意 这里将服务器的key进行排序 分页显示龙
-- function DragonEyrieUpgradeBuilding:GetDragonEntity(index)
--     local drgons = {"blueDragon","greenDragon","redDragon"}
--     return self.dragons[drgons[index]] or nil
-- end

-- function DragonEyrieUpgradeBuilding:SetListener(listener)
--     self.listener = listener
-- end

-- function DragonEyrieUpgradeBuilding:RemoveListener()
--     self.listener = nil
-- end
--最高等级
-- function DragonEyrieUpgradeBuilding:GetLevelMaxWithStar(star)
--     return config_dragonAttribute[star].levelMax
-- end
--龙是否可以晋级
-- function DragonEyrieUpgradeBuilding:DragonEquipmentIsReachPromotionLevel(dragon)
--     return dragon.level >= config_dragonAttribute[dragon.star].promotionLevel
-- end

-- function DragonEyrieUpgradeBuilding:DragonEquipmentsIsReachMaxStar(dragon)
--     for k,equipment in pairs(dragon.equipments) do
--         if equipment.star ~= dragon.star then return false end
--     end
--     return true
-- end

--龙升级需要的经验值
-- function DragonEyrieUpgradeBuilding:GetNextLevelMaxExp(dragon)
--     return tonumber(config_dragonAttribute[dragon.star].perLevelExp) * math.pow(dragon.level,2)
-- end

function DragonEyrieUpgradeBuilding:GetVitalityRecoveryPerHour()
    return config_function[self:GetLevel()].vitalityRecoveryPerHour
end
function DragonEyrieUpgradeBuilding:GetNextLevelVitalityRecoveryPerHour()
    return config_function[self:GetNextLevel()].vitalityRecoveryPerHour
end

-- function DragonEyrieUpgradeBuilding:GetMaxVitalityCurrentLevel(dragon)
--     return config_dragonAttribute[dragon.star].initVitality + dragon.level * config_dragonAttribute[dragon.star].perLevelVitality
-- end

--方便以后拓展 所以函数取这个名字
-- function DragonEyrieUpgradeBuilding:GetDragonDataManager()
--     return self.drgaon_vitality_manager
-- end
---------------------------------------------------------------------------------------------------------------------
-- 配置表
-- function DragonEyrieUpgradeBuilding:GetEquipmentByName(name)
--     return config_equipments[name]
-- end

--如果是Armguard类型的装备 一次是装两个
-- function DragonEyrieUpgradeBuilding:GetEquipmentsByStarAndType(dragonStar,dragonType)
--     local r = {}
--     for name,equipment in pairs(config_equipments) do
--         if equipment.maxStar == dragonStar and dragonType == equipment.usedFor then
--             if equipment["category"] == "armguardLeft,armguardRight" then
--                 r["armguardLeft"]  = equipment
--                 r["armguardRight"] = equipment
--             else
--                 r[equipment["category"]] = equipment
--             end
--         end
--     end
--     return r
-- end

-- function DragonEyrieUpgradeBuilding:GetEquipmentCategorys()
--     return {"armguardLeft","crown","armguardRight","orb","chest","sting"}
-- end

-- function DragonEyrieUpgradeBuilding:GetAllBuffInfomation(dragon)
--     local list = {}
--     local equipmentsbuffs = {}
--     --equipment
--     for k,equipment in pairs(dragon.equipments) do
--         for _,buff in ipairs(equipment.buffs) do
--             if not equipmentsbuffs[buff] then
--                 equipmentsbuffs[buff] = 1
--             else
--                 equipmentsbuffs[buff] = equipmentsbuffs[buff] + 1
--             end
--         end
--     end
--     for k,v in pairs(equipmentsbuffs) do
--         local valStr = string.format("%d%%",config_equipment_buffs[k].buffEffect*v*100)
--         table.insert(list,{Localize.dragon_buff_effection[k],valStr})
--     end
--     --skill
--     for k,skill in pairs(dragon.skills) do
--         if skill.level > 0 then
--             local valStr = string.format("%d%%",skill.level * config_dragonSkill[skill.name].effection*100)
--             table.insert(list,{Localize.dragon_skill_effection[skill.name],valStr})
--         end
--     end
--     return list
-- end

return DragonEyrieUpgradeBuilding


