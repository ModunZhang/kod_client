local Enum = import("..utils.Enum")
local Resource = import(".Resource")
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local PopulationAutomaticUpdateResource = import(".PopulationAutomaticUpdateResource")
local Observer = import(".Observer")
local ResourceManager = class("ResourceManager", Observer)



ResourceManager.RESOURCE_TYPE = Enum(
    "BLOOD",
    "WOOD",
    "FOOD",
    "IRON",
    "STONE",
    "CART",
    "POPULATION",
    "COIN",
    "RUBY",             -- 红宝石
    "BERYL",            -- 绿宝石
    "SAPPHIRE",         -- 蓝宝石
    "TOPAZ",            -- 黄宝石
    "WALLHP")              -- 玩家宝石

local ENERGY = ResourceManager.RESOURCE_TYPE.ENERGY
local WOOD = ResourceManager.RESOURCE_TYPE.WOOD
local FOOD = ResourceManager.RESOURCE_TYPE.FOOD
local IRON = ResourceManager.RESOURCE_TYPE.IRON
local STONE = ResourceManager.RESOURCE_TYPE.STONE
local CART = ResourceManager.RESOURCE_TYPE.CART
local POPULATION = ResourceManager.RESOURCE_TYPE.POPULATION
local COIN = ResourceManager.RESOURCE_TYPE.COIN
local BLOOD = ResourceManager.RESOURCE_TYPE.BLOOD
local WALLHP = ResourceManager.RESOURCE_TYPE.WALLHP

function ResourceManager:ctor()
    ResourceManager.super.ctor(self)
    self.resources = {
        [WOOD] = AutomaticUpdateResource.new(),
        [FOOD] = AutomaticUpdateResource.new(),
        [IRON] = AutomaticUpdateResource.new(),
        [STONE] = AutomaticUpdateResource.new(),
        [CART] = AutomaticUpdateResource.new(),
        [POPULATION] = PopulationAutomaticUpdateResource.new(),
        [COIN] = Resource.new(),
        [BLOOD] = Resource.new(),
        [WALLHP] = AutomaticUpdateResource.new(),
    }
    self:GetCoinResource():SetValueLimit(math.huge)

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
function ResourceManager:GetCartResource()
    return self.resources[CART]
end
function ResourceManager:GetPopulationResource()
    return self.resources[POPULATION]
end
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
function ResourceManager:UpdateByCity(city, current_time)
    -- 产量
    -- 资源小车
    local tradeGuild = city:GetFirstBuildingByType("tradeGuild")
    local cart_recovery, max_cart = 0, 0
    if tradeGuild:GetLevel() > 0 then
        cart_recovery = tradeGuild:GetCartRecovery()
        max_cart = tradeGuild:GetMaxCart()
    end

    -- 城墙
    local wallBuilding = city:GetGate()
    local wall_hp_production_per_hour = wallBuilding:GetWallConfig().wallRecovery

    local total_production_map = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
        [WALLHP] = wall_hp_production_per_hour or 0,
        [CART] = cart_recovery,
    }

    -- 上限
    local max_wood, max_food, max_iron, max_stone = city:GetFirstBuildingByType("warehouse"):GetResourceValueLimit()
    local wall_max_hp = wallBuilding:GetWallConfig().wallHp
    local total_limit_map = {
        [WOOD] = max_wood,
        [FOOD] = max_food,
        [IRON] = max_iron,
        [STONE] = max_stone,
        [POPULATION] = 0,
        [CART] = max_cart,
        [WALLHP] = wall_max_hp or 0,
    }

    local citizen_map = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
        [WALLHP] = 0,
        [CART] = 0,
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
    --
    self.resource_citizen = citizen_map
    self:GetPopulationResource():SetLowLimitResource(total_citizen)
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
function ResourceManager:UpdateFromUserDataByTime(resources, current_time)
    if resources.coin then
        self.resources[COIN]:SetValue(resources.coin)
    end
    if resources.blood then
        self.resources[BLOOD]:SetValue(resources.blood)
    end
    if not current_time then return end
    if resources.wood then
        self.resources[WOOD]:UpdateResource(current_time, resources.wood)
    end
    if resources.food then
        self.resources[FOOD]:UpdateResource(current_time, resources.food)
    end
    if resources.iron then
        self.resources[IRON]:UpdateResource(current_time, resources.iron)
    end
    if resources.stone then
        self.resources[STONE]:UpdateResource(current_time, resources.stone)
    end
    if resources.cart then
        self.resources[CART]:UpdateResource(current_time, resources.cart)
    end
    if resources.citizen then
        self.resources[POPULATION]:UpdateResource(current_time, resources.citizen)
    end
    if resources.wallHp then
        self.resources[WALLHP]:UpdateResource(current_time, resources.wallHp)
    end
end


return ResourceManager





