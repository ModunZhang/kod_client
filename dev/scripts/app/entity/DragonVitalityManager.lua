--
-- Author: Danny He
-- Date: 2014-09-20 17:26:58
--
local Observer = import(".Observer")
local DragonVitalityManager = class("DragonVitalityManager",Observer)
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local config_function = GameDatas.BuildingFunction.dragonEyrie
local config_dragonAttribute = GameDatas.DragonEyrie.dragonAttribute

function DragonVitalityManager:ctor()
    DragonVitalityManager.super.ctor(self)
	self.resources  = {} 
end


function DragonVitalityManager:AddDragonEnergy(type)
    if self.resources[type] then return end
    self.resources[type] = AutomaticUpdateResource.new()
end


function DragonVitalityManager:OnTimer(current_time)
    self:UpdateResourceByTime(current_time)
    self:OnResourceChanged()
end
-- vitalityRecoveryPerHour 由龙巢等级决定
function DragonVitalityManager:UpdateDragonResource(user_data,vitalityRecoveryPerHour)
    local resource_refresh_time = user_data.basicInfo.resourceRefreshTime / 1000 -- 服务器刷新时间
    for k,v in pairs(user_data.dragons) do
        if v.star > 0 then
            if not self.resources[v.type] then
                self:AddDragonEnergy(v.type)
                local dragonResource = self.resources[v.type]
                dragonResource:UpdateResource(resource_refresh_time,v.vitality)
                dragonResource:SetProductionPerHour(resource_refresh_time,vitalityRecoveryPerHour)
                dragonResource:SetValueLimit(self:GetVitalityLimitValue(v))
            end
        end
    end
end


function DragonVitalityManager:GetVitalityLimitValue( dragon )
    return config_dragonAttribute[dragon.star].initVitality + dragon.level * config_dragonAttribute[dragon.star].perLevelVitality
end


function DragonVitalityManager:UpdateResourceByTime(current_time)
    for _, v in pairs(self.resources) do
        v:OnTimer(current_time)
    end
end

function DragonVitalityManager:OnResourceChanged()
    self:NotifyObservers(function(listener)
        listener:OnResourceChanged(self)
    end)
end

function DragonVitalityManager:GetResourceByDragonType(type)
	return self.resources[tostring(type)]
end

return DragonVitalityManager