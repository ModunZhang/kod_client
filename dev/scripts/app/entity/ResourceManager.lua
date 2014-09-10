local Enum = import("..utils.Enum")
local Resource = import(".Resource")
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local PopulationAutomaticUpdateResource = import(".PopulationAutomaticUpdateResource")
local Observer = import(".Observer")
local ResourceManager = class("ResourceManager", Observer)



ResourceManager.RESOURCE_TYPE = Enum("WOOD",
    "FOOD",
    "IRON",
    "STONE",
    "POPULATION",
    "COIN",
    "RUBY",             -- 红宝石
    "BERYL",            -- 绿宝石
    "SAPPHIRE",         -- 蓝宝石
    "TOPAZ",            -- 黄宝石
    "GEM")              -- 玩家宝石

local WOOD = ResourceManager.RESOURCE_TYPE.WOOD
local FOOD = ResourceManager.RESOURCE_TYPE.FOOD
local IRON = ResourceManager.RESOURCE_TYPE.IRON
local STONE = ResourceManager.RESOURCE_TYPE.STONE
local POPULATION = ResourceManager.RESOURCE_TYPE.POPULATION
local COIN = ResourceManager.RESOURCE_TYPE.COIN
local GEM = ResourceManager.RESOURCE_TYPE.GEM

function ResourceManager:ctor()
    ResourceManager.super.ctor(self)
    self.resources = {
        [WOOD] = AutomaticUpdateResource.new(),
        [FOOD] = AutomaticUpdateResource.new(),
        [IRON] = AutomaticUpdateResource.new(),
        [STONE] = AutomaticUpdateResource.new(),
        [POPULATION] = PopulationAutomaticUpdateResource.new(),
        [COIN] = Resource.new(),
        [GEM] = Resource.new(),
    }
    self:GetGemResource():SetValueLimit(math.huge) -- 会有人充值这么多的宝石吗？
    self:GetCoinResource():SetValueLimit(math.huge) -- 会有人充值这么多的宝石吗？

    self.resource_citizen = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
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
function ResourceManager:GetWoodResource()
    return self:GetResourceByType(WOOD)
end
function ResourceManager:GetFoodResource()
    return self:GetResourceByType(FOOD)
end
function ResourceManager:GetIronResource()
    return self:GetResourceByType(IRON)
end
function ResourceManager:GetStoneResource()
    return self:GetResourceByType(STONE)
end
function ResourceManager:GetPopulationResource()
    return self:GetResourceByType(POPULATION)
end
function ResourceManager:GetGemResource()
    return self:GetResourceByType(GEM)
end
function ResourceManager:GetCoinResource()
    return self:GetResourceByType(COIN)
end
function ResourceManager:GetResourceByType(RESOURCE_TYPE)
    return self.resources[RESOURCE_TYPE]
end
function ResourceManager:OnResourceChanged()
    self:NotifyObservers(function(listener)
        listener:OnResourceChanged(self)
    end)
end
function ResourceManager:OnBuildingChangedFromCity(city, current_time, building)
    local citizen_map = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
    }
    local total_production_map = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [POPULATION] = 0,
    }
    local maxwood, maxfood, maxiron, maxstone = city:GetFirstBuildingByType("warehouse"):GetResourceValueLimit()
    print(maxwood, maxfood, maxiron, maxstone)
    local total_limit_map = {
        [WOOD] = maxwood,
        [FOOD] = maxfood,
        [IRON] = maxiron,
        [STONE] = maxstone,
        [POPULATION] = 0,
    }
    local total_citizen = 0
    city:IteratorDecoratorBuildingsByFunc(function(key, decorator)
        if iskindof(decorator, 'ResourceUpgradeBuilding') then
            local resource_type = decorator:GetUpdateResourceType()
            if resource_type then
                total_citizen = total_citizen + decorator:GetCitizen()
                citizen_map[resource_type] = citizen_map[resource_type] + decorator:GetCitizen()
                print(decorator:GetType(), decorator:GetProductionPerHour())
                total_production_map[resource_type] = total_production_map[resource_type] + decorator:GetProductionPerHour()
                if POPULATION == resource_type then
                    total_limit_map[resource_type] = total_limit_map[resource_type] + decorator:GetProductionLimit()
                end
            end
        end
    end)

    self.resource_citizen = citizen_map
    self:GetPopulationResource():SetLowLimitResource(total_citizen)

    LuaUtils:outputTable("citizen_map", citizen_map)
    LuaUtils:outputTable("total_production_map", total_production_map)
    LuaUtils:outputTable("total_limit_map", total_limit_map)

    for resource_type, production in pairs(total_production_map) do
        local resource = self.resources[resource_type]
        resource:SetProductionPerHour(current_time, production)
        resource:SetValueLimit(total_limit_map[resource_type])
    end
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





