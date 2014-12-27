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
    blood = "dragonskill_blood_51x63.png",
    food = "food_icon.png",
    wood = "wood_icon.png",
    stone = "stone_icon.png",
    iron = "iron_icon.png",
    coin = "coin_icon_1.png",
    wallHp = "gate_292x302.png",
}
local MATERIALS = {
    blueprints = "blueprints_112x112.png",
    tools =  "tools_112x112.png",
    tiles = "tiles_112x112.png",
    pulley = "pulley_112x112.png",
    trainingFigure = "trainingFigure_112x112.png",
    bowTarget = "bowTarget_112x112.png",
    saddle = "saddle_112x112.png",
    ironPart = "ironPart_112x112.png",
}
local DRAGON_MATERIAL_PIC_MAP = {
    ["ironIngot"] = "ironIngot_92x92.png",
    ["steelIngot"] = "steelIngot_92x92.png",
    ["mithrilIngot"] = "mithrilIngot_92x92.png",
    ["blackIronIngot"] = "blackIronIngot_92x92.png",
    ["arcaniteIngot"] = "arcaniteIngot_92x92.png",
    ["wispOfFire"] = "wispOfFire_92x92.png",
    ["wispOfCold"] = "wispOfCold_92x92.png",
    ["wispOfWind"] = "wispOfWind_92x92.png",
    ["lavaSoul"] = "lavaSoul_92x92.png",
    ["iceSoul"] = "iceSoul_92x92.png",
    ["forestSoul"] = "forestSoul_92x92.png",
    ["infernoSoul"] = "infernoSoul_92x92.png",
    ["blizzardSoul"] = "blizzardSoul_92x92.png",
    ["fairySoul"] = "fairySoul_92x92.png",
    ["moltenShard"] = "moltenShard_92x92.png",
    ["glacierShard"] = "glacierShard_92x92.png",
    ["chargedShard"] = "chargedShard_92x92.png",
    ["moltenShiver"] = "moltenShiver_92x92.png",
    ["glacierShiver"] = "glacierShiver_92x92.png",
    ["chargedShiver"] = "chargedShiver_92x92.png",
    ["moltenCore"] = "moltenCore_92x92.png",
    ["glacierCore"] = "glacierCore_92x92.png",
    ["chargedCore"] = "chargedCore_92x92.png",
    ["moltenMagnet"] = "moltenMagnet_92x92.png",
    ["glacierMagnet"] = "glacierMagnet_92x92.png",
    ["chargedMagnet"] = "chargedMagnet_92x92.png",
    ["challengeRune"] = "challengeRune_92x92.png",
    ["suppressRune"] = "suppressRune_92x92.png",
    ["rageRune"] = "rageRune_92x92.png",
    ["guardRune"] = "guardRune_92x92.png",
    ["poisonRune"] = "poisonRune_92x92.png",
    ["giantRune"] = "giantRune_92x92.png",
    ["dolanRune"] = "dolanRune_92x92.png",
    ["warsongRune"] = "warsongRune_92x92.png",
    ["infernoRune"] = "infernoRune_92x92.png",
    ["arcanaRune"] = "arcanaRune_92x92.png",
    ["eternityRune"] = "eternityRune_92x92.png"
}
local SOLDIER_METARIAL = {
    ["heroBones"] = "insight_icon_45x45.png",
    ["magicBox"] = "insight_icon_45x45.png",
    ["holyBook"] = "insight_icon_45x45.png",
    ["brightAlloy"] = "insight_icon_45x45.png",
    ["soulStone"] = "insight_icon_45x45.png",
    ["deathHand"] = "insight_icon_45x45.png",
    ["confessionHood"] = "insight_icon_45x45.png",
    ["brightRing"] = "insight_icon_45x45.png",
}
local EQUIPMENT = {
    ["fireSuppressChest"] = "rageRune_92x92.png",
    ["rageSting"] = "rageRune_92x92.png",
    ["frostChest"] = "rageRune_92x92.png",
    ["moltenArmguard"] = "rageRune_92x92.png",
    ["eternitySting"] = "rageRune_92x92.png",
    ["rageArmguard"] = "rageRune_92x92.png",
    ["poisonChest"] = "rageRune_92x92.png",
    ["blizzardArmguard"] = "rageRune_92x92.png",
    ["infernoCrown"] = "rageRune_92x92.png",
    ["dolanSting"] = "rageRune_92x92.png",
    ["frostCrown"] = "rageRune_92x92.png",
    ["glacierCrown"] = "rageRune_92x92.png",
    ["windSuppressSting"] = "rageRune_92x92.png",
    ["warsongChest"] = "rageRune_92x92.png",
    ["frostOrb"] = "rageRune_92x92.png",
    ["poisonArmguard"] = "rageRune_92x92.png",
    ["coldSuppressArmguard"] = "rageRune_92x92.png",
    ["eternityOrb"] = "rageRune_92x92.png",
    ["rageChest"] = "rageRune_92x92.png",
    ["fireSuppressArmguard"] = "rageRune_92x92.png",
    ["windSuppressChest"] = "rageRune_92x92.png",
    ["windSuppressOrb"] = "rageRune_92x92.png",
    ["blizzardSting"] = "rageRune_92x92.png",
    ["giantSting"] = "rageRune_92x92.png",
    ["warsongSting"] = "rageRune_92x92.png",
    ["dolanChest"] = "rageRune_92x92.png",
    ["giantArmguard"] = "rageRune_92x92.png",
    ["poisonCrown"] = "rageRune_92x92.png",
    ["moltenCrown"] = "rageRune_92x92.png",
    ["dolanArmguard"] = "rageRune_92x92.png",
    ["dolanCrown"] = "rageRune_92x92.png",
    ["blizzardCrown"] = "rageRune_92x92.png",
    ["giantChest"] = "rageRune_92x92.png",
    ["fireSuppressOrb"] = "rageRune_92x92.png",
    ["eternityChest"] = "rageRune_92x92.png",
    ["infernoSting"] = "rageRune_92x92.png",
    ["giantCrown"] = "rageRune_92x92.png",
    ["warsongCrown"] = "rageRune_92x92.png",
    ["blizzardOrb"] = "rageRune_92x92.png",
    ["coldSuppressOrb"] = "rageRune_92x92.png",
    ["infernoOrb"] = "rageRune_92x92.png",
    ["fireSuppressCrown"] = "rageRune_92x92.png",
    ["dolanOrb"] = "rageRune_92x92.png",
    ["giantOrb"] = "rageRune_92x92.png",
    ["chargedCrown"] = "rageRune_92x92.png",
    ["eternityArmguard"] = "rageRune_92x92.png",
    ["rageOrb"] = "rageRune_92x92.png",
    ["frostArmguard"] = "rageRune_92x92.png",
    ["warsongOrb"] = "rageRune_92x92.png",
    ["warsongArmguard"] = "rageRune_92x92.png",
    ["glacierArmguard"] = "rageRune_92x92.png",
    ["coldSuppressCrown"] = "rageRune_92x92.png",
    ["windSuppressCrown"] = "rageRune_92x92.png",
    ["coldSuppressChest"] = "rageRune_92x92.png",
    ["fireSuppressSting"] = "rageRune_92x92.png",
    ["poisonOrb"] = "rageRune_92x92.png",
    ["infernoChest"] = "rageRune_92x92.png",
    ["coldSuppressSting"] = "rageRune_92x92.png",
    ["infernoArmguard"] = "rageRune_92x92.png",
    ["eternityCrown"] = "rageRune_92x92.png",
    ["chargedArmguard"] = "rageRune_92x92.png",
    ["frostSting"] = "rageRune_92x92.png",
    ["rageCrown"] = "rageRune_92x92.png",
    ["blizzardChest"] = "rageRune_92x92.png",
    ["windSuppressArmguard"] = "rageRune_92x92.png",
    ["poisonSting"] = "rageRune_92x92.png",
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

    skeletonWarrior = {
        "soldier_skeletonWarrior.png",
        "soldier_skeletonWarrior.png",
        "soldier_skeletonWarrior.png",
    },
    skeletonArcher = {
        "soldier_skeletonArcher.png",
        "soldier_skeletonArcher.png",
        "soldier_skeletonArcher.png",
    },
    deathKnight = {
        "soldier_deathKnight.png",
        "soldier_deathKnight.png",
        "soldier_deathKnight.png",
    },
    meatWagon = {
        "soldier_meatWagon.png",
        "soldier_meatWagon.png",
        "soldier_meatWagon.png",
    },
    priest = {
        "soldier_skeletonWarrior.png",
        "soldier_skeletonWarrior.png",
        "soldier_skeletonWarrior.png",
    },
    demonHunter = {
        "soldier_skeletonArcher.png",
        "soldier_skeletonArcher.png",
        "soldier_skeletonArcher.png",
    },
    paladin = {
        "soldier_deathKnight.png",
        "soldier_deathKnight.png",
        "soldier_deathKnight.png",
    },
    steamTank = {
        "soldier_meatWagon.png",
        "soldier_meatWagon.png",
        "soldier_meatWagon.png",
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
BUFF = {
    buff1 = "buff_1_128x128.png",
    buff2 =  "buff_2_128x128.png",
    buff3 =  "buff_3_128x128.png",
    buff4 =  "buff_4_128x128.png",
    buff5 =  "buff_5_128x128.png",
    buff6 =  "buff_6_128x128.png",
    buff7 = "buff_7_128x128.png",
    buff8 =  "buff_8_128x128.png",
    buff9 =  "buff_9_128x128.png",
    buff10 =  "buff_1_128x128.png",
    buff11 =  "buff_2_128x128.png",
    buff12 =  "buff_3_128x128.png",
    buff13 = "buff_4_128x128.png",
    buff14 =  "buff_5_128x128.png",
    buff15 =  "buff_6_128x128.png",
    buff16 =  "buff_7_128x128.png",
    buff17 =  "buff_8_128x128.png",
    buff18 =  "buff_9_128x128.png",
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
    decorator_image = DECORATOR_IMAGE,
    materials = MATERIALS,
    dragon_material_pic_map = DRAGON_MATERIAL_PIC_MAP,
    soldier_metarial = SOLDIER_METARIAL,
    equipment =EQUIPMENT,
    buff = BUFF,
}
















