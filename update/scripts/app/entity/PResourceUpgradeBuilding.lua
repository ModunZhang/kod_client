
-- 包括锻造坊，锯木工坊，磨坊，石匠作坊
local config_function = GameDatas.BuildingFunction
local UpgradeBuilding = import(".UpgradeBuilding")
local PResourceUpgradeBuilding = class("PResourceUpgradeBuilding", UpgradeBuilding)

-- 大资源建造对应小屋
local p_resource_building_to_house = {
	["townHall"] = "dwelling",
	["foundry"] = "miner",
	["stoneMason"] = "quarrier",
	["lumbermill"] = "woodcutter",
	["mill"] = "farmer",
}

function PResourceUpgradeBuilding:ctor(building_info)
    PResourceUpgradeBuilding.super.ctor(self, building_info)
end
-- 获取下一级可以建造的最大小屋数量
function PResourceUpgradeBuilding:GetNextLevelMaxHouseNum()
    local level = self:GetNextLevel() < 0 and 0 or self:GetNextLevel()
    return config_function[self:GetType()][level][p_resource_building_to_house[self:GetType()]]
end
-- 获取对应资源生产加速比
function PResourceUpgradeBuilding:GetNextLevelAddEfficency()
	local level = self:GetNextLevel()
    return config_function[self:GetType()][level].addEfficency
end
-- 获取当前等级可以建造的最大小屋数量
function PResourceUpgradeBuilding:GetMaxHouseNum()
    local level = self:GetLevel() < 0 and 0 or self:GetLevel()
    return config_function[self:GetType()][level][p_resource_building_to_house[self:GetType()]]
end
-- 获取对应资源生产加速比
function PResourceUpgradeBuilding:GetAddEfficency()
	local level = self:GetLevel()
    return config_function[self:GetType()][level].addEfficency
end
-- 获取对应小屋类型
function PResourceUpgradeBuilding:GetHouseType()
    local level = self:GetLevel()
    return p_resource_building_to_house[self:GetType()]
end
return PResourceUpgradeBuilding