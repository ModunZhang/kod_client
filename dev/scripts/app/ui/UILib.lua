local function getAniNameFromAnimationFileName(file_name)
    local i, j = string.find(file_name, "[%w_]*%.")
    return string.sub(file_name, i, j - 1)
end
local function getAniNameFromAnimationFiles(animation_files)
    local anis = {}
    for i, v in pairs(animation_files) do
        anis[i] = LuaUtils:table_map(v, function(k, file_name)
            return k, getAniNameFromAnimationFileName(file_name)
        end)
    end
    return anis
end
local RESOURCE = {
    food = "food_icon.png",
    wood = "wood_icon.png",
    stone = "stone_icon.png",
    iron = "iron_icon.png",
    coin = "coin_icon_1.png",
}
local STAR_BG = {
    "star1_118x132.png",
    "star2_118x132.png",
    "star3_118x132.png",
    "star4_118x132.png",
    "star5_118x132.png",
}
local EFFECT_ANIMATION_FILES = {
    ranger = {
        "animations/swordsman_effect/Swordsman_effects.ExportJson",
    },
    crossbowman = {
        "animations/swordsman_effect/Swordsman_effects.ExportJson",
    },
    catapult = {
        "animations/catapult_effect/Catapult1effects.ExportJson",
    },
    ballista = {
        "animations/catapult_effect/Catapult1effects.ExportJson",
    },
    lancer = {
        "animations/lancer_effect/Lancer_effects.ExportJson",
    },
    horseArcher = {
        "animations/lancer_effect/Lancer_effects.ExportJson",
    },
    swordsman = {
        "animations/swordsman_effect/Swordsman_effects.ExportJson",
    },
    sentinel = {
        "animations/swordsman_effect/Swordsman_effects.ExportJson",
    },
    wall = {
        "animations/swordsman_effect/Swordsman_effects.ExportJson",
    }
}
local SOLDIER_ANIMATION_FILES = {
    ranger = {
        "animations/Archer_1_render.ExportJson",
        "animations/Archer_2_render.ExportJson",
        "animations/Archer_3_render.ExportJson",
    },
    crossbowman = {
        "animations/Archer_1_render.ExportJson",
        "animations/Archer_2_render.ExportJson",
        "animations/Archer_3_render.ExportJson",
    },
    catapult = {
        "animations/Catapult_1_render.ExportJson",
        "animations/Catapult_1_render.ExportJson",
        "animations/Catapult_1_render.ExportJson",
    },
    ballista = {
        "animations/Catapult_1_render.ExportJson",
        "animations/Catapult_1_render.ExportJson",
        "animations/Catapult_1_render.ExportJson",
    },
    lancer = {
        "animations/Cavalry_1_render.ExportJson",
        "animations/Cavalry_1_render.ExportJson",
        "animations/Cavalry_1_render.ExportJson",
    },
    horseArcher = {
        "animations/Cavalry_1_render.ExportJson",
        "animations/Cavalry_1_render.ExportJson",
        "animations/Cavalry_1_render.ExportJson",
    },
    swordsman = {
        "animations/Infantry_1_render.ExportJson",
        "animations/Infantry_1_render.ExportJson",
        "animations/Infantry_1_render.ExportJson",
    },
    sentinel = {
        "animations/Infantry_1_render.ExportJson",
        "animations/Infantry_1_render.ExportJson",
        "animations/Infantry_1_render.ExportJson",
    },
    wall = {
        "animations/chengqiang_1.ExportJson",
    }
}
local SOLDIER_IMAGES = {
    ranger = {
        "#Archer_1_render/idle/1/00000.png",
        "#Archer_1_render/idle/1/00000.png",
        "#Archer_1_render/idle/1/00000.png",
    },
    catapult = {
        "#Catapult_1_render/move/1/00000.png",
        "#Catapult_1_render/move/1/00000.png",
        "#Catapult_1_render/move/1/00000.png",
    },
    lancer = {
        "#Cavalry_1_render/idle/1/00000.png",
        "#Cavalry_1_render/idle/1/00000.png",
        "#Cavalry_1_render/idle/1/00000.png",
    },
    swordsman = {
        "#Infantry_1_render/idle/1/00000.png",
        "#Infantry_1_render/idle/1/00000.png",
        "#Infantry_1_render/idle/1/00000.png",
    },
    sentinel = {
        "soldier_sentinel_1.png",
        "soldier_sentinel_1.png",
        "soldier_sentinel_1.png",
    },
    crossbowman = {
        "soldier_crossbowman_1.png",
        "soldier_crossbowman_1.png",
        "soldier_crossbowman_1.png",
    },
    horseArcher = {
        "soldier_horseArcher_1.png",
        "soldier_horseArcher_1.png",
        "soldier_horseArcher_1.png",
    },
    ballista = {
        "soldier_ballista_1.png",
        "soldier_ballista_1.png",
        "soldier_ballista_1.png",
    },
    wall = {
        "soldier_ballista_1.png",
        "soldier_ballista_1.png",
        "soldier_ballista_1.png",
    }
}
local DRAGON_ANIMATIONS_FILES = {
    redDragon = {
        "animations/dragon_red/dragon_red.ExportJson"
    },
    blueDragon = {
        "animations/Blue_dragon.ExportJson"
    },
    greenDragon = {
        "animations/green_dragon.ExportJson"
    }
}
DECORATOR_IMAGE = {
    decorate_lake_1 = "lake_288x240.png",
    decorate_lake_2 =  "lake_220x174.png",
    decorate_mountain_2 =  "hill_228x146.png",
    decorate_mountain_1 =  "hill_312x296.png",
    decorate_tree_1 =  "tree_1_120x120.png",
    decorate_tree_2 =  "tree_2_120x120.png",
}
DRAGON_HEAD = {
    blueDragon = "Dragon_blue_113x128.png",
    redDragon = "Dragon_red_113x128.png",
    greenDragon = "Dragon_green_113x128.png"
}
local SOLDIER_ANIMATIONS = getAniNameFromAnimationFiles(SOLDIER_ANIMATION_FILES)
local SOLDIER_EFFECT_ANIMATIONS = getAniNameFromAnimationFiles(EFFECT_ANIMATION_FILES)
local DRAGON_ANIMATIONS = getAniNameFromAnimationFiles(DRAGON_ANIMATIONS_FILES)


return {
    resource = RESOURCE,
    soldier_bg = STAR_BG,
    soldier = SOLDIER_TYPE,
    soldier_effect = SOLDIER_EFFECT_ANIMATIONS,
    effect_animation_files = EFFECT_ANIMATION_FILES,
    soldier_animation_files = SOLDIER_ANIMATION_FILES,
    soldier_animation = SOLDIER_ANIMATIONS,
    soldier_image = SOLDIER_IMAGES,
    dragon_head  = DRAGON_HEAD,
    dragon_animations = DRAGON_ANIMATIONS,
    dragon_animations_files = DRAGON_ANIMATIONS_FILES,
    decorator_image = DECORATOR_IMAGE
}










