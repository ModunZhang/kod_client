

local offset = function(x, y)
    return {x = x, y = y}
end
local function create_flip_none()
    return {x = false, y = false}
end
local function create_flip_x()
    return {x = true, y= false}
end
local function create_flip_y()
    return {x = false, y= true}
end
local function create_flip_both()
    return {x = true, y= true}
end
local shadow = function(shadow_png, shadow_offset, shadow_scale)
    return {png = shadow_png, offset = shadow_offset, scale = shadow_scale}
end
local FLIP = true
local NOT_FLIP = false
local value_return = function(value)
    return value
end
local scale = value_return
local level = value_return


local decorator = function(deco_type, deco_name, offset)
    return {deco_type = deco_type, deco_name = deco_name, offset = offset}
end
local function create_config(b, e, png, offset, scale, ...)
    return {
        ["begin"] = b,
        ["ending"] = e,
        ["png"] = png,
        ["offset"] = offset == nil and offset(0, 0) or offset,
        ["scale"] = scale == nil and 1 or scale,
        ["decorator"] = {...}
    }
end



local MAX_LEVEL = math.huge
local MIN_LEVEL = - 9999999
local SpriteConfig = {}
local function create_building_config(building_type, ...)
    local config = {}
    for i, v in ipairs({...}) do
        table.insert(config, v)
    end
    assert(SpriteConfig[building_type] == nil, "重复初始化建筑配置表")

    function config:GetConfigByLevel(level)
        for i, v in ipairs(self) do
            if v.begin <= level and level <= v.ending then
                return v, i
            end
        end
        assert(false, "没有找到建筑配置表")
    end
    SpriteConfig[building_type] = config
end

create_building_config(
    "keep"
    ,create_config(MIN_LEVEL, level(1), "keep_1_748x692.png", offset(50, 350), scale(1), decorator("image", "keep_1_decorator_270x358.png", offset(576, 165)))
    ,create_config(level(2), level(2), "keep_2_739x734.png", offset(50, 350), scale(1), decorator("image", "keep_2_decorator_271x362.png", offset(590, 180)))
    ,create_config(level(3), MAX_LEVEL, "Keep_3_771x846.png", offset(50, 400), scale(1), decorator("image", "Keep_3_decorator_272x354.png", offset(590, 180)))
)
create_building_config(
    "watchTower"
    ,create_config(MIN_LEVEL, level(1), "watchTower_444x671.png", offset(50, 250), scale(1))
    ,create_config(level(2), level(2), "watchTower_444x671.png", offset(50, 250), scale(1))
    ,create_config(level(3), MAX_LEVEL, "watchTower_444x671.png", offset(50, 250), scale(1))
)
create_building_config(
    "warehouse"
    ,create_config(MIN_LEVEL, level(1), "warehouse_497x454.png", offset(30, 180), scale(1))
    ,create_config(level(2), level(2), "warehouse_497x454.png", offset(30, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "warehouse_497x454.png", offset(30, 180), scale(1))
)
create_building_config(
    "dragonEyrie"
    ,create_config(MIN_LEVEL, level(1), "dragonEyrie_665x545.png", offset(0, 300), scale(1))
    ,create_config(level(2), level(2), "dragonEyrie_665x545.png", offset(0, 300), scale(1))
    ,create_config(level(3), MAX_LEVEL, "dragonEyrie_665x545.png", offset(0, 300), scale(1))
)
create_building_config(
    "toolShop"
    ,create_config(MIN_LEVEL, level(1), "toolshop_516x526.png", offset(30, 200), scale(1))
    ,create_config(level(2), level(2), "toolshop_516x526.png", offset(30, 200), scale(1))
    ,create_config(level(3), MAX_LEVEL, "toolshop_516x526.png", offset(30, 200), scale(1))
)
create_building_config(
    "materialDepot"
    ,create_config(MIN_LEVEL, level(1), "materialDepot_436x521.png", offset(30, 200), scale(1))
    ,create_config(level(2), level(2), "materialDepot_436x521.png", offset(30, 200), scale(1))
    ,create_config(level(3), MAX_LEVEL, "materialDepot_436x521.png", offset(30, 200), scale(1))
)
create_building_config(
    "armyCamp"
    ,create_config(MIN_LEVEL, level(1), "armyCamp_483x434.png", offset(0, 180), scale(1))
    ,create_config(level(2), level(2), "armyCamp_483x434.png", offset(0, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "armyCamp_483x434.png", offset(0, 180), scale(1))
)
create_building_config(
    "barracks"
    ,create_config(MIN_LEVEL, level(1), "barracks_549x520.png", offset(50, 200), scale(1))
    ,create_config(level(2), level(2), "barracks_549x520.png", offset(50, 200), scale(1))
    ,create_config(level(3), MAX_LEVEL, "barracks_549x520.png", offset(50, 200), scale(1))
)
create_building_config(
    "blackSmith"
    ,create_config(MIN_LEVEL, level(1), "blackSmith_438x515.png", offset(30, 200), scale(1))
    ,create_config(level(2), level(2), "blackSmith_438x515.png", offset(30, 200), scale(1))
    ,create_config(level(3), MAX_LEVEL, "blackSmith_438x515.png", offset(30, 200), scale(1))
)
create_building_config(
    "foundry"
    ,create_config(MIN_LEVEL, level(1), "foundry_485x477.png", offset(30, 200), scale(1))
    ,create_config(level(2), level(2), "foundry_485x477.png", offset(30, 200), scale(1))
    ,create_config(level(3), MAX_LEVEL, "foundry_485x477.png", offset(30, 200), scale(1))
)
create_building_config(
    "stoneMason"
    ,create_config(MIN_LEVEL, level(1), "stoneMason_519x473.png", offset(0, 180), scale(1))
    ,create_config(level(2), level(2), "stoneMason_519x473.png", offset(0, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "stoneMason_519x473.png", offset(0, 180), scale(1))
)
create_building_config(
    "lumbermill"
    ,create_config(MIN_LEVEL, level(1), "lumbermill_491x423.png", offset(30, 180), scale(1))
    ,create_config(level(2), level(2), "lumbermill_491x423.png", offset(30, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "lumbermill_491x423.png", offset(30, 180), scale(1))
)
create_building_config(
    "mill"
    ,create_config(MIN_LEVEL, level(1), "mill_467x411.png", offset(30, 180), scale(1))
    ,create_config(level(2), level(2), "mill_467x411.png", offset(30, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "mill_467x411.png", offset(30, 180), scale(1))
)
create_building_config(
    "hospital"
    ,create_config(MIN_LEVEL, level(1), "hospital_458x447.png", offset(50, 180), scale(1))
    ,create_config(level(2), level(2), "hospital_458x447.png", offset(50, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "hospital_458x447.png", offset(50, 180), scale(1))
)
create_building_config(
    "townHall"
    ,create_config(MIN_LEVEL, level(1), "townHall_522x545.png", offset(50, 180), scale(1))
    ,create_config(level(2), level(2), "townHall_522x545.png", offset(50, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "townHall_522x545.png", offset(50, 180), scale(1))
)
create_building_config(
    "tradeGuild"
    ,create_config(MIN_LEVEL, level(1), "tradeGuild_554x390.png", offset(30, 180), scale(1))
    ,create_config(level(2), level(2), "tradeGuild_554x390.png", offset(30, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "tradeGuild_554x390.png", offset(30, 180), scale(1))
)
create_building_config(
    "academy"
    ,create_config(MIN_LEVEL, level(1), "academy_424x434.png", offset(30, 180), scale(1))
    ,create_config(level(2), level(2), "academy_424x434.png", offset(30, 180), scale(1))
    ,create_config(level(3), MAX_LEVEL, "academy_424x434.png", offset(30, 180), scale(1))
)
create_building_config(
    "wall"
    ,create_config(MIN_LEVEL, level(1), "gate_292x302.png", offset(0, 100), scale(1))
    ,create_config(level(2), level(2), "gate_292x302.png", offset(0, 100), scale(1))
    ,create_config(level(3), MAX_LEVEL, "gate_292x302.png", offset(0, 100), scale(1))
)
create_building_config(
    "tower"
    ,create_config(MIN_LEVEL, level(1), "tower_head_78x124.png", offset(0, 100), scale(1))
    ,create_config(level(2), level(2), "tower_head_78x124.png", offset(0, 100), scale(1))
    ,create_config(level(3), MAX_LEVEL, "tower_head_78x124.png", offset(0, 100), scale(1))
)
-- 装饰小屋
create_building_config(
    "dwelling"
    ,create_config(MIN_LEVEL, level(1), "dwelling_1_294x362.png", offset(10, 90), scale(1))
    ,create_config(level(2), level(2), "dwelling_2_356x396.png", offset(0, 100), scale(1))
    ,create_config(level(3), MAX_LEVEL, "dwelling_3_366x417.png", offset(0, 110), scale(1))
)
create_building_config(
    "farmer"
    ,create_config(MIN_LEVEL, level(1), "farmer_1_314x269.png", offset(10, 80), scale(1))
    ,create_config(level(2), level(2), "farmer_2_310x299.png", offset(0, 80), scale(1))
    ,create_config(level(3), MAX_LEVEL, "farmer_3_330x341.png", offset(10, 90), scale(1))
)
create_building_config(
    "woodcutter"
    ,create_config(MIN_LEVEL, level(1), "woodcutter_1_339x243.png", offset(5, 70), scale(1))
    ,create_config(level(2), level(2), "woodcutter_2_362x338.png", offset(10, 90), scale(1))
    ,create_config(level(3), MAX_LEVEL, "woodcutter_3_362x358.png", offset(15, 95), scale(1))
)
create_building_config(
    "quarrier"
    ,create_config(MIN_LEVEL, level(1), "quarrier_1_302x285.png", offset(5, 80), scale(1))
    ,create_config(level(2), level(2), "quarrier_2_347x314.png", offset(15, 85), scale(1))
    ,create_config(level(3), MAX_LEVEL, "quarrier_3_362x383.png", offset(20, 100), scale(1))
)
create_building_config(
    "miner"
    ,create_config(MIN_LEVEL, level(1), "miner_1_312x297.png", offset(15, 80), scale(1))
    ,create_config(level(2), level(2), "mine_2_337x313.png", offset(20, 90), scale(1))
    ,create_config(level(3), MAX_LEVEL, "miner_3_323x313.png", offset(20, 90), scale(1))
)




return SpriteConfig
























