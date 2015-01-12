local Enum = import("..utils.Enum")
local Resource = import(".Resource")
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local PopulationAutomaticUpdateResource = import(".PopulationAutomaticUpdateResource")
local Observer = import(".Observer")
local ResourceManager = class("ResourceManager", Observer)



ResourceManager.RESOURCE_TYPE = Enum(
    "BLOOD",
    "ENERGY",
    "WOOD",
    "FOOD",
    "IRON",
    "STONE",
    "POPULATION",
    "COIN",
    "RUBY",             -- 红宝石
    "BERYL",            -- 绿宝石
    "SAPPHIRE",         -- 蓝宝石
    "TOPAZ",            -- 黄宝石
    -- "GEM",
    "WALLHP")              -- 玩家宝石

local ENERGY = ResourceManager.RESOURCE_TYPE.ENERGY
local WOOD = ResourceManager.RESOURCE_TYPE.WOOD
local FOOD = ResourceManager.RESOURCE_TYPE.FOOD
local IRON = ResourceManager.RESOURCE_TYPE.IRON
local STONE = ResourceManager.RESOURCE_TYPE.STONE
local POPULATION = ResourceManager.RESOURCE_TYPE.POPULATION
local COIN = ResourceManager.RESOURCE_TYPE.COIN
-- local GEM = ResourceManager.RESOURCE_TYPE.GEM
local BLOOD = ResourceManager.RESOURCE_TYPE.BLOOD
local WALLHP = ResourceManager.RESOURCE_TYPE.WALLHP

function ResourceManager:ctor()
    ResourceManager.super.ctor(self)
    self.resources = {
        [ENERGY] = AutomaticUpdateResource.new(),
        [WOOD] = AutomaticUpdateResource.new(),
        [FOOD] = AutomaticUpdateResource.new(),
        [IRON] = AutomaticUpdateResource.new(),
        [STONE] = AutomaticUpdateResource.new(),
        [POPULATION] = PopulationAutomaticUpdateResource.new(),
        [COIN] = Resource.new(),
        -- [GEM] = Resource.new(),
        [BLOOD] = Resource.new(),
        [WALLHP] = AutomaticUpdateResource.new(),
    }
    -- self:GetGemResource():SetValueLimit(math.huge) -- 会有人充值这么多的宝石吗？
    self:GetCoinResource():SetValueLimit(math.huge) -- 会有人充值这么多的宝石吗？

    self.resource_citizen = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
        [WALLHP] = 0,
    }
end
function ResourceManager:OnTimer(current_time)
    self:UpdateResourceByTime(current_time)
    self:OnResourceChanged()
end
function ResourceManager:UpdateResourceByTime(current_time)
    for _, v in pairs(self.resources) do
        v:OnTimer(current_time)
    end
end
function ResourceManager:GetWallHpResource()
    return self.resources[WALLHP]
end
function ResourceManager:GetEnergyResource()
    return self.resources[ENERGY]
end
function ResourceManager:GetWoodResource()
    return self.resources[WOOD]
end
function ResourceManager:GetFoodResource()
    return self.resources[FOOD]
end
function ResourceManager:GetIronResource()
    return self.resources[IRON]
end
function ResourceManager:GetStoneResource()
    return self.resources[STONE]
end
function ResourceManager:GetPopulationResource()
    return self.resources[POPULATION]
end
-- function ResourceManager:GetGemResource()
--     return self.resources[GEM]
-- end
function ResourceManager:GetCoinResource()
    return self.resources[COIN]
end
function ResourceManager:GetBloodResource()
    return self.resources[BLOOD]
end
function ResourceManager:GetResourceByType(RESOURCE_TYPE)
    return self.resources[RESOURCE_TYPE]
end
function ResourceManager:OnResourceChanged()
    self:NotifyObservers(function(listener)
        listener:OnResourceChanged(self)
    end)
end
function ResourceManager:OnBuildingChangedFromCity(city, current_time)
    local citizen_map = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
        [WALLHP] = 0,
    }
    local dragonEyrie = city:GetFirstBuildingByType("dragonEyrie")
    local wallBuilding = city:GetGate()
    local energy_production_per_hour = dragonEyrie:GetProductionPerHour()
    local wall_hp_production_per_hour = wallBuilding:GetWallConfig().wallRecovery

    local total_production_map = {
        [ENERGY] = energy_production_per_hour or 0,
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
        [WALLHP] = wall_hp_production_per_hour or 0,
    }

    local max_energy = dragonEyrie:EnergyMax()
    local max_wood, max_food, max_iron, max_stone = city:GetFirstBuildingByType("warehouse"):GetResourceValueLimit()
    local wall_max_hp = wallBuilding:GetWallConfig().wallHp
    local total_limit_map = {
        [ENERGY] = max_energy,
        [WOOD] = max_wood,
        [FOOD] = max_food,
        [IRON] = max_iron,
        [STONE] = max_stone,
        [POPULATION] = 0,
        [WALLHP] = wall_max_hp or 0,
    }

    local total_citizen = 0
    city:IteratorDecoratorBuildingsByFunc(function(key, decorator)
        if iskindof(decorator, 'ResourceUpgradeBuilding') then
            local resource_type = decorator:GetUpdateResourceType()
            if resource_type then
                local citizen = decorator:GetCitizen()
                total_citizen = total_citizen + citizen
                total_production_map[resource_type] = total_production_map[resource_type] + decorator:GetProductionPerHour()
                if citizen_map[resource_type] then
                    citizen_map[resource_type] = citizen_map[resource_type] + citizen
                end
                if POPULATION == resource_type then
                    total_limit_map[resource_type] = total_limit_map[resource_type] + decorator:GetProductionLimit()
                end
            end
        end
    end)
    self:GetPopulationResource():SetLowLimitResource(total_citizen)
    self.resource_citizen = citizen_map
    for resource_type, production in pairs(total_production_map) do
        local resource = self.resources[resource_type]
        resource:SetProductionPerHour(current_time, production)
        resource:SetValueLimit(total_limit_map[resource_type])
    end

    LuaUtils:outputTable("citizen_map", citizen_map)
    LuaUtils:outputTable("total_production_map", total_production_map)
    LuaUtils:outputTable("total_limit_map", total_limit_map)
end
function ResourceManager:GetCitizenAllocInfo()
    return self.resource_citizen
end
function ResourceManager:GetCitizenAllocated()
    local total_citizen = 0
    for k, v in pairs(self.resource_citizen) do
        total_citizen = total_citizen + v
    end
    return total_citizen
end


return ResourceManager



