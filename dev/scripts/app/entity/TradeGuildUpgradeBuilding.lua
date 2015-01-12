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
	local config = config_function[self:GetLevel()]
	return config.maxCart
end
function TradeGuildUpgradeBuilding:GetMaxSellQueue()
	local config = config_function[self:GetLevel()]
	return config.maxSellQueue
end
function TradeGuildUpgradeBuilding:GetCartRecovery()
	local config = config_function[self:GetLevel()]
	return config.cartRecovery
end

return TradeGuildUpgradeBuilding