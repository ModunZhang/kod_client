--
-- Author: Danny He
-- Date: 2014-09-17 09:22:12
--
local config_function = GameDatas.BuildingFunction.dragonEyrie
local config_levelup = GameDatas.BuildingLevelUp.dragonEyrie
local ResourceManager = import(".ResourceManager")
local UpgradeBuilding = import(".UpgradeBuilding")
local DragonEyrieUpgradeBuilding = class("DragonEyrieUpgradeBuilding", UpgradeBuilding)
local DragonManager = import(".DragonManager")


function DragonEyrieUpgradeBuilding:ctor(building_info)
    DragonEyrieUpgradeBuilding.super.ctor(self,building_info)
    self:SetDragonManager(DragonManager.new())
end


function DragonEyrieUpgradeBuilding:OnTimer(current_time)
    DragonEyrieUpgradeBuilding.super.OnTimer(self,current_time)
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
    self:GetDragonManager():OnUserDataChanged(user_data, current_time, location_id, sub_location_id,self:GetHPRecoveryPerHour())
end


function DragonEyrieUpgradeBuilding:SetDragonManager(manager)
    self.dragon_manger_ = manager
end

function DragonEyrieUpgradeBuilding:GetDragonManager()
    return self.dragon_manger_ 
end


-- TODO:这里其实是每小时恢复的血 暂时使用以前活力的恢复速率(vitalityRecoveryPerHour会改)
function DragonEyrieUpgradeBuilding:GetHPRecoveryPerHour()
    return config_function[self:GetLevel()].hpRecoveryPerHour
end
function DragonEyrieUpgradeBuilding:GetNextLevelVitalityRecoveryPerHour()
    return config_function[self:GetNextLevel()].hpRecoveryPerHour
end

return DragonEyrieUpgradeBuilding


