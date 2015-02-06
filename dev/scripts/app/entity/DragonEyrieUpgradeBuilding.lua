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
-- function DragonEyrieUpgradeBuilding:GetProductionPerHour()
--     return 3600 / self:GetTimePerEnergy()
-- end

-- function DragonEyrieUpgradeBuilding:GetTimePerEnergy()
--     return config_function[self:GetLevel()].perEnergyTime
-- end

-- function DragonEyrieUpgradeBuilding:GetUpdateResourceType()
--     return ResourceManager.RESOURCE_TYPE.ENERGY
-- end

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
--withBuff 
function DragonEyrieUpgradeBuilding:GetHPRecoveryPerHour(withBuff)
    local hprecoveryperhour = config_function[self:GetLevel()].hpRecoveryPerHour
    if withBuff == false then return hprecoveryperhour end
    if ItemManager:IsBuffActived("dragonHpBonus") then
        hprecoveryperhour = math.floor(hprecoveryperhour * (1 + ItemManager:GetBuffEffect("dragonHpBonus")))
    end
    return hprecoveryperhour
end

--TODO:龙巢已经不再恢复活力，记得删除
function DragonEyrieUpgradeBuilding:GetNextLevelVitalityRecoveryPerHour()
    return config_function[self:GetNextLevel()].hpRecoveryPerHour
end
--Fix bug KOD-175
function DragonEyrieUpgradeBuilding:ResetAllListeners()
    DragonEyrieUpgradeBuilding.super.ResetAllListeners(self)
    self:GetDragonManager():ClearAllListener()
end

return DragonEyrieUpgradeBuilding


