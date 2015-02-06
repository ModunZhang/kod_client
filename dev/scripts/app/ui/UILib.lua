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
        "animations/Archer_1_render.ExportJson",
        "animations/Archer_1_render.ExportJson",
    },
    crossbowman = {
        "animations/Archer_1_render.ExportJson",
        "animations/Archer_1_render.ExportJson",
        "animations/Archer_1_render.ExportJson",
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
        "ranger_1.png",
        "ranger_2.png",
        "ranger_3.png",
    },
    catapult = {
        "catapult_1.png",
        "catapult_2.png",
        "catapult_3.png",
    },
    lancer = {
        "lancer_1.png",
        "lancer_2.png",
        "lancer_3.png",
    },
    swordsman = {
        "swordsman_1.png",
        "swordsman_2.png",
        "swordsman_3.png",
    },
    sentinel = {
        "sentinel_1.png",
        "sentinel_2.png",
        "sentinel_3.png",
    },
    crossbowman = {
        "crossbowman_1.png",
        "crossbowman_2.png",
        "crossbowman_3.png",
    },
    horseArcher = {
        "horseArcher_1.png",
        "horseArcher_2.png",
        "horseArcher_3.png",
    },
    ballista = {
        "ballista_1.png",
        "ballista_2.png",
        "ballista_3.png",
    },

    skeletonWarrior = {
        "",
        "skeletonWarrior.png",
        "",
    },
    skeletonArcher = {
        "",
        "skeletonArcher.png",
        "",
    },
    deathKnight = {
        "",
        "",
        "deathKnight.png",
    },
    meatWagon = {
        "",
        "",
        "meatWagon.png",
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
local BLACK_SOLDIER_IMAGES = {
    ranger = {
        "b_ranger_1.png",
        "b_ranger_2.png",
    },
    catapult = {
        "b_catapult_1.png",
        "b_catapult_2.png",
    },
    lancer = {
        "b_lancer_1.png",
        "b_lancer_2.png",
    },
    swordsman = {
        "b_swordsman_1.png",
        "b_swordsman_2.png",
    },
    sentinel = {
        "b_sentinel_1.png",
        "b_sentinel_2.png",
    },
    crossbowman = {
        "b_crossbowman_1.png",
        "b_crossbowman_2.png",
    },
    horseArcher = {
        "b_horseArcher_1.png",
        "b_horseArcher_2.png",
    },
    ballista = {
        "b_ballista_1.png",
        "b_ballista_2.png",
    },
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
local DECORATOR_IMAGE = {
    grassLand = {
        decorate_lake_1 = "grass_lake_272x158.png",
        decorate_lake_2 =  "grass_lake_244x142.png",
        decorate_mountain_2 =  "grass_hill_160x106.png",
        decorate_mountain_1 =  "grass_hill_254x240.png",
        decorate_tree_1 =  "grass_tree_1_138x110.png",
        decorate_tree_2 =  "grass_tree_2_124x122.png",
        decorate_tree_3 =  "grass_tree_3_112x114.png",
        decorate_tree_4 =  "grass_tree_4_100x106.png",
    },
    iceField = {
        decorate_lake_1 = "ice_lake_280x166.png",
        decorate_lake_2 =  "ice_lake_252x150.png",
        decorate_mountain_2 =  "ice_hill_230x150.png",
        decorate_mountain_1 =  "ice_hill_314x296.png",
        decorate_tree_1 =  "ice_tree_1_126x110.png",
        decorate_tree_2 =  "ice_tree_2_124x106.png",
        decorate_tree_3 =  "ice_tree_3_102x96.png",
        decorate_tree_4 =  "ice_tree_4_102x98.png",
    },
    desert = {
        decorate_lake_1 = "desert_lake_276x162.png",
        decorate_lake_2 =  "desert_lake_248x146.png",
        decorate_mountain_2 =  "desert_hill_226x148.png",
        decorate_mountain_1 =  "desert_hill_314x298.png",
        decorate_tree_1 =  "desert_tree_1_148x104.png",
        decorate_tree_2 =  "desert_tree_2_128x106.png",
        decorate_tree_3 =  "desert_tree_3_98x96.png",
        decorate_tree_4 =  "desert_tree_4_106x102.png",
    },
    decorate_lake_1 = "lake_272x158.png",
    decorate_lake_2 =  "lake_244x142.png",
    decorate_mountain_2 =  "hill_160x106.png",
    decorate_mountain_1 =  "hill_254x240.png",
    decorate_tree_1 =  "tree_2_138x110.png",
    decorate_tree_2 =  "tree_1_112x114.png",
}
local DRAGON_HEAD = {
    blueDragon = "Dragon_blue_113x128.png",
    redDragon = "Dragon_red_113x128.png",
    greenDragon = "Dragon_green_113x128.png"
}
BUFF = {
    masterOfDefender = "buff_1_128x128.png",
    quarterMaster =  "buff_2_128x128.png",
    fogOfTrick =  "buff_3_128x128.png",
    woodBonus =  "buff_4_128x128.png",
    stoneBonus =  "buff_5_128x128.png",
    ironBonus =  "buff_6_128x128.png",
    foodBonus = "buff_7_128x128.png",
    taxesBonus =  "buff_8_128x128.png",
    citizenBonus =  "buff_9_128x128.png",
    dragonExpBonus =  "buff_1_128x128.png",
    troopSizeBonus =  "buff_2_128x128.png",
    dragonHpBonus =  "buff_3_128x128.png",
    marchSpeedBonus = "buff_4_128x128.png",
    unitHpBonus =  "buff_5_128x128.png",
    infantryAtkBonus =  "buff_6_128x128.png",
    archerAtkBonus =  "buff_7_128x128.png",
    cavalryAtkBonus =  "buff_8_128x128.png",
    siegeAtkBonus =  "buff_9_128x128.png",
}

local ALLIANCE_TITLE_ICON = {
    general = "5_23x24.png",
    quartermaster = "4_32x24.png",
    supervisor = "3_35x24.png",
    elite = "2_23x24.png",
    member = "1_11x24.png",
    archon = "alliance_item_leader_39x39.png"
}
local VILLAGE = {
    woodVillage = "woodcutter_1_150x108.png",
    stoneVillage="woodcutter_1_150x108.png",
    ironVillage = "woodcutter_1_150x108.png",
    foodVillage = "woodcutter_1_150x108.png",
    coinVillage = "woodcutter_1_150x108.png",
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
    black_soldier_image = BLACK_SOLDIER_IMAGES,
    dragon_head  = DRAGON_HEAD,
    dragon_animations = DRAGON_ANIMATIONS,
    dragon_animations_files = DRAGON_ANIMATIONS_FILES,
    decorator_image = DECORATOR_IMAGE,
    materials = MATERIALS,
    dragon_material_pic_map = DRAGON_MATERIAL_PIC_MAP,
    soldier_metarial = SOLDIER_METARIAL,
    equipment =EQUIPMENT,
    alliance_title_icon =ALLIANCE_TITLE_ICON,
    buff = BUFF,
    village = VILLAGE,
}


















