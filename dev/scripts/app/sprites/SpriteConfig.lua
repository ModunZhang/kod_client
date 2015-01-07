

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
    ,create_config(MIN_LEVEL, level(1), "keep_1_420x390.png", offset(50, 200), scale(1), decorator("image", "keep_1_d_168x222.png", offset(124, -100)))
    ,create_config(level(2), level(5), "keep_2_436x436.png", offset(50, 220), scale(1), decorator("image", "keep_2_d_172x230.png", offset(126, -126)))
    ,create_config(level(6), MAX_LEVEL, "keep_3_480x526.png", offset(50, 260), scale(1), decorator("image", "keep_3_d_184x240.png", offset(121, -167)))
)
create_building_config(
    "watchTower"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "watchTower_230x348.png", offset(50, 180), scale(1))
)
create_building_config(
    "warehouse"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "warehouse_256x234.png", offset(20, 120), scale(1))
)
create_building_config(
    "dragonEyrie"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "dragonEyrie_350x288.png", offset(35, 133), scale(1))
)
create_building_config(
    "toolShop"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "toolShop_250x254.png", offset(20, 120), scale(1))
)
create_building_config(
    "materialDepot"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "materialDepot_220x262.png", offset(20, 120), scale(1))
)
create_building_config(
    "armyCamp"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "armyCamp_294x264.png", offset(20, 120), scale(1))
)
create_building_config(
    "barracks"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "barracks_252x240.png", offset(20, 120), scale(1))
)
create_building_config(
    "blackSmith"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "blackSmith_208x244.png", offset(20, 120), scale(1))
)
create_building_config(
    "foundry"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "foundry_272x268.png", offset(20, 120), scale(1))
)
create_building_config(
    "stoneMason"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "stoneMason_282x256.png", offset(20, 120), scale(1))
)
create_building_config(
    "lumbermill"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "lumbermill_269x232.png", offset(20, 120), scale(1))
)
create_building_config(
    "mill"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "mill_268x236.png", offset(20, 120), scale(1))
)
create_building_config(
    "hospital"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "hospital_294x263.png", offset(20, 120), scale(1))
)
create_building_config(
    "townHall"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "townHall_280x294.png", offset(20, 120), scale(1))
)
create_building_config(
    "tradeGuild"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "tradeGuild_270x190.png", offset(20, 120), scale(1))
)
create_building_config(
    "academy"
    ,create_config(MIN_LEVEL, MAX_LEVEL, "academy_240x244.png", offset(20, 120), scale(1))
)
-- 装饰小屋
create_building_config(
    "dwelling"
    ,create_config(MIN_LEVEL, level(1), "dwelling_1_110x136.png", offset(0, 60), scale(1))
    ,create_config(level(2), level(2), "dwelling_2_138x156.png", offset(0, 60), scale(1))
    ,create_config(level(3), MAX_LEVEL, "dwelling_3_124x142.png", offset(0, 60), scale(1))
)
create_building_config(
    "farmer"
    ,create_config(MIN_LEVEL, level(1), "farmer_1_142x121.png", offset(0, 60), scale(1))
    ,create_config(level(2), level(2), "farmer_2_126x122.png", offset(0, 60), scale(1))
    ,create_config(level(3), MAX_LEVEL, "farmer_3_128x132.png", offset(0, 60), scale(1))
)
create_building_config(
    "woodcutter"
    ,create_config(MIN_LEVEL, level(1), "woodcutter_1_132x94.png", offset(0, 60), scale(1))
    ,create_config(level(2), level(2), "woodcutter_2_138x128.png", offset(0, 60), scale(1))
    ,create_config(level(3), MAX_LEVEL, "woodcutter_3_146x144.png", offset(0, 60), scale(1))
)
create_building_config(
    "quarrier"
    ,create_config(MIN_LEVEL, level(1), "quarrier_1_118x112.png", offset(0, 60), scale(1))
    ,create_config(level(2), level(2), "quarrier_2_144x130.png", offset(0, 60), scale(1))
    ,create_config(level(3), MAX_LEVEL, "quarrier_3_150x158.png", offset(0, 60), scale(1))
)
create_building_config(
    "miner"
    ,create_config(MIN_LEVEL, level(1), "miner_1_124x118.png", offset(0, 60), scale(1))
    ,create_config(level(2), level(2), "miner_2_128x119.png", offset(0, 60), scale(1))
    ,create_config(level(3), MAX_LEVEL, "miner_3_130x126.png", offset(0, 60), scale(1))
)

-- walls
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



return SpriteConfig
























