

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
local function create_config(b, e, png, offset, scale, shadow, flip)
    return {
        ["begin"] = b,
        ["ending"] = e,
        ["png"] = png,
        ["offset"] = offset == nil and offset(0, 0) or offset,
        ["scale"] = scale == nil and 1 or scale,
        ["shadow"] = shadow,
        ["flip"] = flip == nil and create_flip_none() or flip,
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
    ,create_config(MIN_LEVEL, level(1), "keep_760x855.png", offset(50, 350), scale(0.8))
    ,create_config(level(2), level(2), "keep_760x855.png", offset(50, 350), scale(0.8))
    ,create_config(level(3), MAX_LEVEL, "keep_760x855.png", offset(50, 350), scale(0.8))
)
create_building_config(
    "watchTower"
    ,create_config(MIN_LEVEL, level(1), "watchTower_445x638.png", offset(50, 250), scale(0.7))
    ,create_config(level(2), level(2), "watchTower_445x638.png", offset(50, 250), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "watchTower_445x638.png", offset(50, 250), scale(0.7))
)
create_building_config(
    "warehouse"
    ,create_config(MIN_LEVEL, level(1), "warehouse_498x468.png", offset(30, 180), scale(0.7))
    ,create_config(level(2), level(2), "warehouse_498x468.png", offset(30, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "warehouse_498x468.png", offset(30, 180), scale(0.7))
)
create_building_config(
    "dragonEyrie"
    ,create_config(MIN_LEVEL, level(1), "dragonEyrie_581x558.png", offset(30, 300), scale(0.9))
    ,create_config(level(2), level(2), "dragonEyrie_581x558.png", offset(30, 300), scale(0.9))
    ,create_config(level(3), MAX_LEVEL, "dragonEyrie_581x558.png", offset(30, 300), scale(0.9))
)
create_building_config(
    "toolShop"
    ,create_config(MIN_LEVEL, level(1), "toolShop_1_521x539.png", offset(30, 200), scale(0.7))
    ,create_config(level(2), level(2), "toolShop_1_521x539.png", offset(30, 200), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "toolShop_1_521x539.png", offset(30, 200), scale(0.7))
)
create_building_config(
    "materialDepot"
    ,create_config(MIN_LEVEL, level(1), "materialDepot_1_438x531.png", offset(30, 200), scale(0.7))
    ,create_config(level(2), level(2), "materialDepot_1_438x531.png", offset(30, 200), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "materialDepot_1_438x531.png", offset(30, 200), scale(0.7))
)
create_building_config(
    "armyCamp"
    ,create_config(MIN_LEVEL, level(1), "armyCamp_485x444.png", offset(0, 180), scale(0.7))
    ,create_config(level(2), level(2), "armyCamp_485x444.png", offset(0, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "armyCamp_485x444.png", offset(0, 180), scale(0.7))
)
create_building_config(
    "barracks"
    ,create_config(MIN_LEVEL, level(1), "barracks_553x536.png", offset(50, 200), scale(0.7))
    ,create_config(level(2), level(2), "barracks_553x536.png", offset(50, 200), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "barracks_553x536.png", offset(50, 200), scale(0.7))
)
create_building_config(
    "blackSmith"
    ,create_config(MIN_LEVEL, level(1), "blackSmith_1_442x519.png", offset(30, 200), scale(0.7))
    ,create_config(level(2), level(2), "blackSmith_1_442x519.png", offset(30, 200), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "blackSmith_1_442x519.png", offset(30, 200), scale(0.7))
)
create_building_config(
    "foundry"
    ,create_config(MIN_LEVEL, level(1), "foundry_1_487x479.png", offset(30, 200), scale(0.7))
    ,create_config(level(2), level(2), "foundry_1_487x479.png", offset(30, 200), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "foundry_1_487x479.png", offset(30, 200), scale(0.7))
)
create_building_config(
    "stoneMason"
    ,create_config(MIN_LEVEL, level(1), "stoneMason_1_423x486.png", offset(0, 180), scale(0.7))
    ,create_config(level(2), level(2), "stoneMason_1_423x486.png", offset(0, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "stoneMason_1_423x486.png", offset(0, 180), scale(0.7))
)
create_building_config(
    "lumbermill"
    ,create_config(MIN_LEVEL, level(1), "lumbermill_1_495x423.png", offset(30, 180), scale(0.7))
    ,create_config(level(2), level(2), "lumbermill_1_495x423.png", offset(30, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "lumbermill_1_495x423.png", offset(30, 180), scale(0.7))
)
create_building_config(
    "mill"
    ,create_config(MIN_LEVEL, level(1), "mill_1_470x405.png", offset(30, 180), scale(0.7))
    ,create_config(level(2), level(2), "mill_1_470x405.png", offset(30, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "mill_1_470x405.png", offset(30, 180), scale(0.7))
)
create_building_config(
    "hospital"
    ,create_config(MIN_LEVEL, level(1), "hospital_1_461x458.png", offset(50, 180), scale(0.7))
    ,create_config(level(2), level(2), "hospital_1_461x458.png", offset(50, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "hospital_1_461x458.png", offset(50, 180), scale(0.7))
)
create_building_config(
    "townHall"
    ,create_config(MIN_LEVEL, level(1), "townHall_1_524x553.png", offset(50, 180), scale(0.7))
    ,create_config(level(2), level(2), "townHall_1_524x553.png", offset(50, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "townHall_1_524x553.png", offset(50, 180), scale(0.7))
)
create_building_config(
    "tradeGuild"
    ,create_config(MIN_LEVEL, level(1), "tradeGuild_1_558x403.png", offset(30, 180), scale(0.7))
    ,create_config(level(2), level(2), "tradeGuild_1_558x403.png", offset(30, 180), scale(0.7))
    ,create_config(level(3), MAX_LEVEL, "tradeGuild_1_558x403.png", offset(30, 180), scale(0.7))
)
create_building_config(
    "wall"
    ,create_config(MIN_LEVEL, level(1), "gate_292x302.png", offset(0, 100), scale(0.5))
    ,create_config(level(2), level(2), "gate_292x302.png", offset(0, 100), scale(0.5))
    ,create_config(level(3), MAX_LEVEL, "gate_292x302.png", offset(0, 100), scale(0.5))
)
create_building_config(
    "tower"
    ,create_config(MIN_LEVEL, level(1), "tower_head_78x124.png", offset(0, 100), scale(0.5))
    ,create_config(level(2), level(2), "tower_head_78x124.png", offset(0, 100), scale(0.5))
    ,create_config(level(3), MAX_LEVEL, "tower_head_78x124.png", offset(0, 100), scale(0.5))
)
-- 装饰小屋
create_building_config(
    "dwelling"
    ,create_config(MIN_LEVEL, level(1), "dwelling_1_297x365.png", offset(10, 90), scale(0.6))
    ,create_config(level(2), level(2), "dwelling_2_357x401.png", offset(0, 100), scale(0.6))
    ,create_config(level(3), MAX_LEVEL, "dwelling_3_369x419.png", offset(0, 110), scale(0.6))
)
create_building_config(
    "farmer"
    ,create_config(MIN_LEVEL, level(1), "farmer_1_315x281.png", offset(10, 80), scale(0.6))
    ,create_config(level(2), level(2), "farmer_2_312x305.png", offset(0, 80), scale(0.6))
    ,create_config(level(3), MAX_LEVEL, "farmer_3_332x345.png", offset(10, 90), scale(0.6))
)
create_building_config(
    "woodcutter"
    ,create_config(MIN_LEVEL, level(1), "woodcutter_1_342x250.png", offset(5, 70), scale(0.6))
    ,create_config(level(2), level(2), "woodcutter_2_364x334.png", offset(10, 90), scale(0.6))
    ,create_config(level(3), MAX_LEVEL, "woodcutter_3_351x358.png", offset(15, 95), scale(0.6))
)
create_building_config(
    "quarrier"
    ,create_config(MIN_LEVEL, level(1), "quarrier_1_303x296.png", offset(5, 80), scale(0.6))
    ,create_config(level(2), level(2), "quarrier_2_347x324.png", offset(15, 85), scale(0.6))
    ,create_config(level(3), MAX_LEVEL, "quarrier_3_363x386.png", offset(20, 100), scale(0.6))
)
create_building_config(
    "miner"
    ,create_config(MIN_LEVEL, level(1), "miner_1_315x309.png", offset(15, 80), scale(0.6))
    ,create_config(level(2), level(2), "miner_2_340x308.png", offset(20, 90), scale(0.6))
    ,create_config(level(3), MAX_LEVEL, "miner_3_326x307.png", offset(20, 90), scale(0.6))
)




return SpriteConfig
























