local Enum = import("..utils.Enum")
local Resource = import(".Resource")
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local CitizenAutomaticUpdateResource = import(".CitizenAutomaticUpdateResource")
local Observer = import(".Observer")
local ResourceManager = class("ResourceManager", Observer)

local intInit = GameDatas.PlayerInitData.intInit
ResourceManager.RESOURCE_TYPE = Enum(
    "WOOD",
    "FOOD",
    "IRON",
    "STONE",
    "CART",
    "CITIZEN",
    "COIN",
    "WALLHP")

local WOOD          = ResourceManager.RESOURCE_TYPE.WOOD
local FOOD          = ResourceManager.RESOURCE_TYPE.FOOD
local IRON          = ResourceManager.RESOURCE_TYPE.IRON
local COIN          = ResourceManager.RESOURCE_TYPE.COIN
local STONE         = ResourceManager.RESOURCE_TYPE.STONE
local CITIZEN       = ResourceManager.RESOURCE_TYPE.CITIZEN
local CART          = ResourceManager.RESOURCE_TYPE.CART
local WALLHP        = ResourceManager.RESOURCE_TYPE.WALLHP

local str2enum = {
    cart = CART,
    coin = COIN,
    wood = WOOD,
    food = FOOD,
    iron = IRON,
    stone= STONE,
    wallHp = WALLHP,
    citizen = CITIZEN,
}

local RESOURCE_TYPE = ResourceManager.RESOURCE_TYPE
local dump_resources = function(...)
    local t, name = ...
    dump(LuaUtils:table_map(t, function(k, v)
        return RESOURCE_TYPE[k], v
    end), name)
end

local pairs = pairs
local ipairs = ipairs

function ResourceManager:ctor(city)
    self.city = city
    self.user = self.city:GetUser()
    ResourceManager.super.ctor(self)
end
function ResourceManager:UpdateByCity(city, current_time)
    -- 产量
    -- 资源小车
    local tradeGuild = city:GetFirstBuildingByType("tradeGuild")
    local cart_recovery, cart_max = 0, 0
    if tradeGuild:GetLevel() > 0 then
        cart_recovery = tradeGuild:GetCartRecovery()
        cart_max = tradeGuild:GetMaxCart()
    end

    -- 城墙
    local wall_config = city:GetGate():GetWallConfig()
    local total_production_map = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [COIN] = 0,
        [CITIZEN] = 0,
        [WALLHP] = wall_config.wallRecovery or 0,
        [CART] = cart_recovery,
    }

    -- 上限
    local limits = UtilsForBuilding:GetWarehouseLimit(city:GetUser())
    local total_limit_map = {
        [WOOD] = limits.wood,
        [FOOD] = limits.food,
        [IRON] = limits.iron,
        [STONE]= limits.stone,
        [COIN] = math.huge,
        [CITIZEN] = intInit.initCitizen.value,
        [CART] = cart_max,
        [WALLHP] = wall_config.wallHp or 0,
    }

    --小屋对资源的影响
    city:IteratorDecoratorBuildingsByFunc(function(_, decorator)
        if iskindof(decorator, 'ResourceUpgradeBuilding') then
            local resource_type = str2enum[decorator:GetResType()]
            if resource_type then
                total_production_map[resource_type] = total_production_map[resource_type] + decorator:GetProductionPerHour()
                if CITIZEN == resource_type then
                    total_production_map[COIN] = total_production_map[COIN] + decorator:GetProductionPerHour()
                    total_limit_map[CITIZEN] = total_limit_map[CITIZEN] + decorator:GetProductionLimit()
                end
            end
        end
    end)
    dump_resources(total_production_map, "小屋对资源的影响--->")
    -- buff对资源的影响
    -- 城民的计算是写死的，没有按照通用的规则
    local LIMIT_MAP = {}
    local PRODUCTION_MAP = {}
    local buff_production_map,buff_limt_map = self:GetTotalBuffData(city)
    for resource_type, production in pairs(total_production_map) do
        local buff_limit = 1 + buff_limt_map[resource_type]
        local resource_limit = math.floor(total_limit_map[resource_type] * buff_limit)
        LIMIT_MAP[resource_type] = resource_limit

        local buff_production = 1 + (buff_production_map[resource_type] or 0)
        if resource_type == CITIZEN then
            PRODUCTION_MAP[resource_type] = production * buff_production
        else
            local resource_production = math.floor(production * buff_production)
            if resource_type == FOOD then
                resource_production = resource_production - city:GetSoldierManager():GetTotalUpkeep()
            end
            PRODUCTION_MAP[resource_type] = resource_production
        end
    end
    local User = self.user
    local wallHp = User:GetResProduction("wallHp")
    wallHp.limit = LIMIT_MAP[WALLHP]
    wallHp.output = PRODUCTION_MAP[WALLHP]
    local cart = User:GetResProduction("cart")
    cart.limit = LIMIT_MAP[CART]
    cart.output = PRODUCTION_MAP[CART]
    local wood = User:GetResProduction("wood")
    wood.limit = LIMIT_MAP[WOOD]
    wood.output = PRODUCTION_MAP[WOOD]
    local food = User:GetResProduction("food")
    food.limit = LIMIT_MAP[FOOD]
    food.output = PRODUCTION_MAP[FOOD]
    local iron = User:GetResProduction("iron")
    iron.limit = LIMIT_MAP[IRON]
    iron.output = PRODUCTION_MAP[IRON]
    local stone = User:GetResProduction("stone")
    stone.limit = LIMIT_MAP[STONE]
    stone.output = PRODUCTION_MAP[STONE]
    local citizen = User:GetResProduction("citizen")
    citizen.limit = LIMIT_MAP[CITIZEN] - UtilsForBuilding:GetCitizenMap(city:GetUser()).total
    citizen.output = PRODUCTION_MAP[CITIZEN]
    local coin = User:GetResProduction("coin")
    coin.output = PRODUCTION_MAP[COIN]

    dump_resources(LIMIT_MAP, "LIMIT_MAP--->")
    dump_resources(PRODUCTION_MAP, "PRODUCTION_MAP--->")
    dump(self.user.resources, "self.user.resources_cache")
    dump(self.user.resources_cache, "self.user.resources_cache")
end
local resource_building_map = {
    mill = FOOD,
    lumbermill = WOOD,
    foundry = IRON,
    stoneMason = STONE,
    townHall = COIN,
}
function ResourceManager:GetTotalBuffData(city)
    local buff_production_map =
        {
            [WOOD] = 0,
            [FOOD] = 0,
            [IRON] = 0,
            [STONE] = 0,
            [COIN] = 0,
            [CITIZEN] = 0,
            [WALLHP] = 0,
        }
    local buff_limt_map =
        {
            [WOOD] = 0,
            [FOOD] = 0,
            [IRON] = 0,
            [STONE] = 0,
            [COIN] = 0,
            [CITIZEN] = 0,
            [WALLHP] = 0,
            [CART] = 0,
        }
    -- 建筑对资源的影响
    -- 以及小屋位置对资源的影响
    local houses = {}
    city:IteratorDecoratorBuildingsByFunc(function(_,v)houses[v] = v;end)
    city:IteratorFunctionBuildingsByFunc(function(_,resource_building)
        local resource_type = resource_building_map[resource_building:GetType()]
        if resource_building:IsUnlocked() and resource_type then
            local count = 0
            local house_type = resource_building:GetHouseType()
            for k,house in pairs(houses) do
                if house:GetType() == house_type and
                    resource_building:IsNearByBuildingWithLength(house, 2) then
                    count = count + 1
                    houses[k] = nil
                end
            end
            local house_buff = 0
            if count >= 6 then
                house_buff = 0.1
            elseif count >= 3 then
                house_buff = 0.05
            end
            buff_production_map[resource_type] = buff_production_map[resource_type] + house_buff
        end
    end)
    dump_resources(buff_production_map, "建筑对资源的影响--->")

    --学院科技
    city:IteratorTechs(function(__,tech)
        local res_type,buff_type,buff_value = tech:GetResourceBuffData()
        local resource_type = str2enum[res_type]
        if res_type then
            local target_map = buff_type == "product" and buff_production_map or buff_limt_map
            target_map[resource_type] = target_map[resource_type] + buff_value
        end
    end)
    dump_resources(buff_production_map, "学院科技对资源的影响--->")

    --道具buuff
    local item_buff_map = {
        [WOOD] = 0,
        [FOOD] = 0,
        [IRON] = 0,
        [STONE] = 0,
        [COIN] = 0,
        [CITIZEN] = 0,
        [WALLHP] = 0,
    }
    local item_buff = UtilsForItem:GetAllResourceBuffData(city:GetUser())
    for _,v in ipairs(item_buff) do
        local res_type,buff_type,buff_value = unpack(v)
        if res_type  then
            local target_map = buff_type == "product" and buff_production_map or buff_limt_map
            if type(res_type) == 'string' then
                local resource_type = str2enum[res_type]
                target_map[resource_type] = target_map[resource_type] + buff_value
                item_buff_map[resource_type] = item_buff_map[resource_type] + buff_value
            elseif type(res_type) == 'table' then
                for _,one_resource_type in ipairs(res_type) do
                    target_map[one_resource_type] = target_map[one_resource_type] + buff_value
                    item_buff_map[one_resource_type] = item_buff_map[one_resource_type] + buff_value
                end
            end
        end
    end
    dump_resources(item_buff_map, "道具对资源的影响--->")
    --vip buff
    local user = self.user
    local vip_buff_map = {
        [WOOD] = user:GetVIPWoodProductionAdd(),
        [FOOD] = user:GetVIPFoodProductionAdd(),
        [IRON] = user:GetVIPIronProductionAdd(),
        [STONE] = user:GetVIPStoneProductionAdd(),
        [CITIZEN] = user:GetVIPCitizenRecoveryAdd(),
        [WALLHP] = user:GetVIPWallHpRecoveryAdd(),
        [COIN] = 0,
    }
    dump_resources(vip_buff_map, "VIP对资源的影响--->")
    for resource_type,v in pairs(buff_production_map) do
        buff_production_map[resource_type] = v + vip_buff_map[resource_type]
    end
    --end
    buff_production_map.wood    = buff_production_map[WOOD]
    buff_production_map.food    = buff_production_map[FOOD]
    buff_production_map.iron    = buff_production_map[IRON]
    buff_production_map.stone   = buff_production_map[STONE]
    buff_production_map.coin    = buff_production_map[COIN]
    buff_production_map.citizen = buff_production_map[CITIZEN]
    buff_production_map.wallHp  = buff_production_map[WALLHP]


    buff_limt_map.wood    = buff_limt_map[WOOD]
    buff_limt_map.food    = buff_limt_map[FOOD]
    buff_limt_map.iron    = buff_limt_map[IRON]
    buff_limt_map.stone   = buff_limt_map[STONE]
    buff_limt_map.coin    = buff_limt_map[COIN]
    buff_limt_map.citizen = buff_limt_map[CITIZEN]
    buff_limt_map.wallHp  = buff_limt_map[WALLHP]
    buff_limt_map.cart    = buff_limt_map[CART]

    dump(buff_production_map,"buff_production_map--->")
    dump(buff_limt_map,"buff_limt_map--->")
    return buff_production_map,buff_limt_map
end


return ResourceManager





















