

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
    ,create_config(
        MIN_LEVEL, level(1), "keep_616x855.png", offset(0, 450), scale(0.7),
        shadow(
            "keep_shadow_1_760x543.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "keep_616x855.png", offset(0, 450), scale(0.7),
        shadow(
            "keep_shadow_1_760x543.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "keep_616x855.png", offset(0, 450), scale(0.7),
        shadow(
            "keep_shadow_1_760x543.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "dragonEyrie"
    ,create_config(
        MIN_LEVEL, level(1), "dragonEyrie_564x558.png", offset(0, 350), scale(0.7),
        shadow(
            "dragonEyrie_shadow_1_581x400.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "dragonEyrie_564x558.png", offset(0, 350), scale(0.7),
        shadow(
            "dragonEyrie_shadow_1_581x400.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "dragonEyrie_564x558.png", offset(0, 350), scale(0.7),
        shadow(
            "dragonEyrie_shadow_1_581x400.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "warehouse"
    ,create_config(
        MIN_LEVEL, level(1), "warehouse_454x468.png", offset(0, 180), scale(0.7),
        shadow(
            "warehouse_shadow_1_488x360.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "warehouse_454x468.png", offset(0, 180), scale(0.7),
        shadow(
            "warehouse_shadow_1_488x360.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "warehouse_454x468.png", offset(0, 180), scale(0.7),
        shadow(
            "warehouse_shadow_1_488x360.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "watchTower"
    ,create_config(
        MIN_LEVEL, level(1), "watchTower_263x638.png", offset(0, 320), scale(0.7),
        shadow(
            "watchTower_shadow_1_409x291.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "watchTower_263x638.png", offset(0, 320), scale(0.7),
        shadow(
            "watchTower_shadow_1_409x291.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "watchTower_263x638.png", offset(0, 320), scale(0.7),
        shadow(
            "watchTower_shadow_1_409x291.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "toolShop"
    ,create_config(
        MIN_LEVEL, level(1), "toolShop_1_465x539.png", offset(0, 180), scale(0.7),
        shadow(
            "toolshop_shadow_1_520x389.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "toolShop_1_465x539.png", offset(0, 180), scale(0.7),
        shadow(
            "toolshop_shadow_1_520x389.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "toolShop_1_465x539.png", offset(0, 180), scale(0.7),
        shadow(
            "toolshop_shadow_1_520x389.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "materialDepot"
    ,create_config(
        MIN_LEVEL, level(1), "materialDepot_1_436x531.png", offset(0, 180), scale(0.7),
        shadow(
            "materialDepot_shadow_1_428x368.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "materialDepot_1_436x531.png", offset(0, 180), scale(0.7),
        shadow(
            "materialDepot_shadow_1_428x368.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "materialDepot_1_436x531.png", offset(0, 180), scale(0.7),
        shadow(
            "materialDepot_shadow_1_428x368.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "armyCamp"
    ,create_config(
        MIN_LEVEL, level(1), "armyCamp_458x444.png", offset(0, 180), scale(0.7),
        shadow(
            "armyCamp_shadow_1_480x310.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "armyCamp_458x444.png", offset(0, 180), scale(0.7),
        shadow(
            "armyCamp_shadow_1_480x310.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "armyCamp_458x444.png", offset(0, 180), scale(0.7),
        shadow(
            "armyCamp_shadow_1_480x310.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "barracks"
    ,create_config(
        MIN_LEVEL, level(1), "barracks_472x536.png", offset(0, 180), scale(0.7),
        shadow(
            "barracks_shadow_1_544x377.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "barracks_472x536.png", offset(0, 180), scale(0.7),
        shadow(
            "barracks_shadow_1_544x377.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "barracks_472x536.png", offset(0, 180), scale(0.7),
        shadow(
            "barracks_shadow_1_544x377.png", offset(100, 100), scale(0.7)
        )
    )
)

create_building_config(
    "blackSmith"
    ,create_config(
        MIN_LEVEL, level(1), "blackSmith_1_424x519.png", offset(0, 180), scale(0.7),
        shadow(
            "blackSmith_shadow_1_440x370.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "blackSmith_1_424x519.png", offset(0, 180), scale(0.7),
        shadow(
            "blackSmith_shadow_1_440x370.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "blackSmith_1_424x519.png", offset(0, 180), scale(0.7),
        shadow(
            "blackSmith_shadow_1_440x370.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "foundry"
    ,create_config(
        MIN_LEVEL, level(1), "foundry_1_475x479.png", offset(0, 180), scale(0.7),
        shadow(
            "foundry_shadow_1_469x331.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "foundry_1_475x479.png", offset(0, 180), scale(0.7),
        shadow(
            "foundry_shadow_1_469x331.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "foundry_1_475x479.png", offset(0, 180), scale(0.7),
        shadow(
            "foundry_shadow_1_469x331.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "stoneMason"
    ,create_config(
        MIN_LEVEL, level(1), "stoneMason_1_461x486.png", offset(0, 180), scale(0.7),
        shadow(
            "stonemason_shadow_1_523x351.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "stoneMason_1_461x486.png", offset(0, 180), scale(0.7),
        shadow(
            "stonemason_shadow_1_523x351.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "stoneMason_1_461x486.png", offset(0, 180), scale(0.7),
        shadow(
            "stonemason_shadow_1_523x351.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "lumbermill"
    ,create_config(
        MIN_LEVEL, level(1), "lumbermill_1_454x423.png", offset(0, 180), scale(0.7),
        shadow(
            "lumberMill_shadow_1_494x343.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "lumbermill_1_454x423.png", offset(0, 180), scale(0.7),
        shadow(
            "lumberMill_shadow_1_494x343.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "lumbermill_1_454x423.png", offset(0, 180), scale(0.7),
        shadow(
            "lumberMill_shadow_1_494x343.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "mill"
    ,create_config(
        MIN_LEVEL, level(1), "mill_1_432x405.png", offset(0, 180), scale(0.7),
        shadow(
            "mill_shadow_1_470x311.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "mill_1_432x405.png", offset(0, 180), scale(0.7),
        shadow(
            "mill_shadow_1_470x311.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "mill_1_432x405.png", offset(0, 180), scale(0.7),
        shadow(
            "mill_shadow_1_470x311.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "hospital"
    ,create_config(
        MIN_LEVEL, level(1), "hospital_1_367x458.png", offset(0, 180), scale(0.7),
        shadow(
            "hospital_shadow_1_458x314.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "hospital_1_367x458.png", offset(0, 180), scale(0.7),
        shadow(
            "hospital_shadow_1_458x314.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "hospital_1_367x458.png", offset(0, 180), scale(0.7),
        shadow(
            "hospital_shadow_1_458x314.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "townHall"
    ,create_config(
        MIN_LEVEL, level(1), "townHall_1_464x553.png", offset(0, 180), scale(0.7),
        shadow(
            "townHall_shadow_1_523x374.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "townHall_1_464x553.png", offset(0, 180), scale(0.7),
        shadow(
            "townHall_shadow_1_523x374.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "townHall_1_464x553.png", offset(0, 180), scale(0.7),
        shadow(
            "townHall_shadow_1_523x374.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "tradeGuild"
    ,create_config(
        MIN_LEVEL, level(1), "tradeGuild_1_493x403.png", offset(0, 180), scale(0.7),
        shadow(
            "tradeGuild_shadow_1_548x301.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "tradeGuild_1_493x403.png", offset(0, 180), scale(0.7),
        shadow(
            "tradeGuild_shadow_1_548x301.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "tradeGuild_1_493x403.png", offset(0, 180), scale(0.7),
        shadow(
            "tradeGuild_shadow_1_548x301.png", offset(100, 100), scale(0.7)
        )
    )
)
-- 装饰小屋
create_building_config(
    "dwelling"
    ,create_config(
        MIN_LEVEL, level(1), "dwelling_1_290x365.png", offset(0, 100), scale(0.7),
        shadow(
            "dwelling_shadow_1_291x237.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "dwelling_2_318x401.png", offset(0, 100), scale(0.7),
        shadow(
            "dwelling_shadow_2_341x260.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "dwelling_3_320x419.png", offset(0, 100), scale(0.7),
        shadow(
            "dwelling_shadow_3_342x261.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "woodcutter"
    ,create_config(
        MIN_LEVEL, level(1), "woodcutter_1_312x250.png", offset(0, 100), scale(0.7),
        shadow(
            "woodcutter_shadow_1_339x210.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "woodcutter_2_299x334.png", offset(0, 100), scale(0.7),
        shadow(
            "woodcutter_shadow_2_361x227.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "woodcutter_3_302x358.png", offset(0, 100), scale(0.7),
        shadow(
            "woodcutter_shadow_3_346x236.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "farmer"
    ,create_config(
        MIN_LEVEL, level(1), "farmer_1_306x280.png", offset(0, 100), scale(0.7),
        shadow(
            "farmer_shadow_1_309x217.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "farmer_2_303x305.png", offset(0, 100), scale(0.7),
        shadow(
            "farmer_shadow_2_306x223.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "farmer_3_314x345.png", offset(0, 100), scale(0.7),
        shadow(
            "farmer_shadow_3_325x230.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "quarrier"
    ,create_config(
        MIN_LEVEL, level(1), "quarrier_1_267x295.png", offset(0, 100), scale(0.7),
        shadow(
            "quarrier_shadow_1_303x227.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "quarrier_2_307x324.png", offset(0, 100), scale(0.7),
        shadow(
            "quarrier_shadow_2_347x237.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "quarrier_3_294x386.png", offset(0, 100), scale(0.7),
        shadow(
            "quarrier_shadow_3_363x253.png", offset(100, 100), scale(0.7)
        )
    )
)
create_building_config(
    "miner"
    ,create_config(
        MIN_LEVEL, level(1), "miner_1_258x309.png", offset(0, 100), scale(0.7),
        shadow(
            "miner_shadow_1_315x227.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(2), level(2), "miner_2_285x308.png", offset(0, 100), scale(0.7),
        shadow(
            "miner_shadow_2_340x227.png", offset(100, 100), scale(0.7)
        )
    )
    ,create_config(
        level(3), MAX_LEVEL, "miner_3_284x307.png", offset(0, 100), scale(0.7),
        shadow(
            "miner_shadow_3_326x226.png", offset(100, 100), scale(0.7)
        )
    )
)



return SpriteConfig
























