--
-- Author: Kenny Dai
-- Date: 2015-01-12 16:41:03
--


local config_function = GameDatas.BuildingFunction.tradeGuild
local config_levelup = GameDatas.BuildingLevelUp.tradeGuild
local UpgradeBuilding = import(".UpgradeBuilding")
local TradeGuildUpgradeBuilding = class("TradeGuildUpgradeBuilding", UpgradeBuilding)

function TradeGuildUpgradeBuilding:ctor(building_info)
    TradeGuildUpgradeBuilding.super.ctor(self, building_info)
end

function TradeGuildUpgradeBuilding:GetMaxCart()
	return config_function[self:GetEfficiencyLevel()].maxCart
end
function TradeGuildUpgradeBuilding:GetMaxSellQueue()
	return config_function[self:GetEfficiencyLevel()].maxSellQueue
end
function TradeGuildUpgradeBuilding:GetCartRecovery()
	return config_function[self:GetEfficiencyLevel()].cartRecovery
end
function TradeGuildUpgradeBuilding:GetUnlockSellQueueLevel(queueIndex)
    for k,v in pairs(config_function) do
        if v.maxSellQueue==queueIndex then
            return k
        end
    end
end

return TradeGuildUpgradeBuilding

