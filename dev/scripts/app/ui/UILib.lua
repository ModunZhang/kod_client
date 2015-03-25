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


local BUILDING_ANIMATIONS_FILES = {
    watchTower = {
        "animations/watchTower/liaowangta.ExportJson"
    },
    barracks = {
        "animations/bingyin/bingyin.ExportJson",
        "animations/bingyin_1/bingyin_1.ExportJson"
    },
    tradeGuild = {
        "animations/maoyihanghui/maoyihanghui.ExportJson",
    },
    mill = {
        "animations/mofang/mofang.ExportJson",
    },
    townHall = {
        "animations/shizhenting/shizhenting.ExportJson",
    },
    academy = {
        "animations/xueyuan/xueyuan.ExportJson",
    },
    hospital = {
        "animations/yiyuan/yiyuan.ExportJson",
    },
    warehouse = {
        "animations/ziyuancangku/ziyuancangku.ExportJson",
    },
    smoke = {
        "animations/yan/yan.ExportJson",
    },
    hammer = {
        "animations/chuizi/chuizi.ExportJson",
    },
    airShip = {
        "animations/feiting/feiting.ExportJson",
    },
    citizen = {
        "animations/caodi_nan/caodi_nan.ExportJson",
        "animations/caodi_nv/caodi_nv.ExportJson",
        "animations/xuedi_nan/xuedi_nan.ExportJson",
        "animations/xuedi_nv/xuedi_nv.ExportJson",
        "animations/shadi_nan/shadi_nan.ExportJson",
        "animations/shadi_nv/shadi_nv.ExportJson",
    }
}
local BUILDING_ANIMATIONS = getAniNameFromAnimationFiles(BUILDING_ANIMATIONS_FILES)
local RESOURCE = {
    blood = "dragonskill_blood_51x63.png",
    food = "res_food_114x100.png",
    wood = "res_wood_114x100.png",
    stone = "stone_icon.png",
    iron = "res_iron_114x100.png",
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
    ["ingo_1"] = "ironIngot_92x92.png",
    ["ingo_2"] = "steelIngot_92x92.png",
    ["ingo_3"] = "mithrilIngot_92x92.png",
    ["ingo_4"] = "blackIronIngot_92x92.png",
    ["redSoul_2"] = "arcaniteIngot_92x92.png",
    ["redSoul_3"] = "wispOfFire_92x92.png",
    ["redSoul_4"] = "wispOfCold_92x92.png",
    ["blueSoul_2"] = "wispOfWind_92x92.png",
    ["blueSoul_3"] = "lavaSoul_92x92.png",
    ["blueSoul_4"] = "iceSoul_92x92.png",
    ["greenSoul_2"] = "forestSoul_92x92.png",
    ["greenSoul_3"] = "infernoSoul_92x92.png",
    ["greenSoul_4"] = "blizzardSoul_92x92.png",
    ["redCrystal_1"] = "fairySoul_92x92.png",
    ["redCrystal_2"] = "moltenShard_92x92.png",
    ["redCrystal_3"] = "glacierShard_92x92.png",
    ["redCrystal_4"] = "chargedShard_92x92.png",
    ["blueCrystal_1"] = "moltenShiver_92x92.png",
    ["blueCrystal_2"] = "glacierShiver_92x92.png",
    ["blueCrystal_3"] = "chargedShiver_92x92.png",
    ["blueCrystal_4"] = "moltenCore_92x92.png",
    ["greenCrystal_1"] = "glacierCore_92x92.png",
    ["greenCrystal_2"] = "chargedCore_92x92.png",
    ["greenCrystal_3"] = "moltenMagnet_92x92.png",
    ["greenCrystal_4"] = "glacierMagnet_92x92.png",
    ["runes_1"] = "chargedMagnet_92x92.png",
    ["runes_2"] = "challengeRune_92x92.png",
    ["runes_3"] = "suppressRune_92x92.png",
    ["runes_4"] = "rageRune_92x92.png",
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
    ["greenArmguard_s4"] = "rageRune_92x92.png",
    ["redChest_s4"] = "rageRune_92x92.png",
    ["blueSting_s5"] = "rageRune_92x92.png",
    ["blueOrd_s3"] = "rageRune_92x92.png",
    ["greenArmguard_s2"] = "rageRune_92x92.png",
    ["greenCrown_s2"] = "rageRune_92x92.png",
    ["greenChest_s2"] = "rageRune_92x92.png",
    ["greenArmguard_s1"] = "rageRune_92x92.png",
    ["redCrown_s4"] = "rageRune_92x92.png",
    ["blueOrd_s4"] = "rageRune_92x92.png",
    ["redChest_s5"] = "rageRune_92x92.png",
    ["greenChest_s3"] = "rageRune_92x92.png",
    ["redChest_s2"] = "rageRune_92x92.png",
    ["redCrown_s5"] = "rageRune_92x92.png",
    ["blueOrd_s2"] = "rageRune_92x92.png",
    ["greenArmguard_s3"] = "rageRune_92x92.png",
    ["redArmguard_s1"] = "rageRune_92x92.png",
    ["blueSting_s4"] = "rageRune_92x92.png",
    ["redOrd_s3"] = "rageRune_92x92.png",
    ["redArmguard_s3"] = "rageRune_92x92.png",
    ["blueOrd_s5"] = "rageRune_92x92.png",
    ["blueArmguard_s4"] = "rageRune_92x92.png",
    ["redCrown_s1"] = "rageRune_92x92.png",
    ["greenSting_s4"] = "rageRune_92x92.png",
    ["blueChest_s5"] = "rageRune_92x92.png",
    ["redCrown_s3"] = "rageRune_92x92.png",
    ["blueCrown_s5"] = "rageRune_92x92.png",
    ["blueChest_s3"] = "rageRune_92x92.png",
    ["blueArmguard_s5"] = "rageRune_92x92.png",
    ["redSting_s3"] = "rageRune_92x92.png",
    ["blueChest_s2"] = "rageRune_92x92.png",
    ["redArmguard_s5"] = "rageRune_92x92.png",
    ["greenOrd_s2"] = "rageRune_92x92.png",
    ["blueCrown_s4"] = "rageRune_92x92.png",
    ["greenOrd_s5"] = "rageRune_92x92.png",
    ["redArmguard_s4"] = "rageRune_92x92.png",
    ["blueCrown_s3"] = "rageRune_92x92.png",
    ["redOrd_s4"] = "rageRune_92x92.png",
    ["greenSting_s2"] = "rageRune_92x92.png",
    ["redOrd_s2"] = "rageRune_92x92.png",
    ["greenOrd_s3"] = "rageRune_92x92.png",
    ["greenCrown_s1"] = "rageRune_92x92.png",
    ["redCrown_s2"] = "rageRune_92x92.png",
    ["blueArmguard_s2"] = "rageRune_92x92.png",
    ["greenChest_s5"] = "rageRune_92x92.png",
    ["greenArmguard_s5"] = "rageRune_92x92.png",
    ["greenOrd_s4"] = "rageRune_92x92.png",
    ["blueCrown_s1"] = "rageRune_92x92.png",
    ["redArmguard_s2"] = "rageRune_92x92.png",
    ["greenSting_s5"] = "rageRune_92x92.png",
    ["redSting_s4"] = "rageRune_92x92.png",
    ["redOrd_s5"] = "rageRune_92x92.png",
    ["redChest_s3"] = "rageRune_92x92.png",
    ["blueArmguard_s3"] = "rageRune_92x92.png",
    ["greenCrown_s5"] = "rageRune_92x92.png",
    ["blueCrown_s2"] = "rageRune_92x92.png",
    ["redSting_s5"] = "rageRune_92x92.png",
    ["greenCrown_s4"] = "rageRune_92x92.png",
    ["greenChest_s4"] = "rageRune_92x92.png",
    ["blueSting_s3"] = "rageRune_92x92.png",
    ["blueSting_s2"] = "rageRune_92x92.png",
    ["greenCrown_s3"] = "rageRune_92x92.png",
    ["redSting_s2"] = "rageRune_92x92.png",
    ["blueChest_s4"] = "rageRune_92x92.png",
    ["greenSting_s3"] = "rageRune_92x92.png",
    ["blueArmguard_s1"] = "rageRune_92x92.png",
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
    
    skeletonWarrior = {
        "skeletonWarrior.png",
    },
    skeletonArcher = {
        "skeletonArcher.png",
    },
    deathKnight = {
        "deathKnight.png",
    },
    meatWagon = {
        "meatWagon.png",
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
    decorate_lake_1 = "grass_lake_272x158.png",
    decorate_lake_2 =  "grass_lake_244x142.png",
    decorate_mountain_2 =  "grass_hill_160x106.png",
    decorate_mountain_1 =  "grass_hill_254x240.png",
    decorate_tree_1 =  "grass_tree_1_138x110.png",
    decorate_tree_2 =  "grass_tree_3_112x114.png",
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
    coinBonus =  "buff_8_128x128.png",
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

local ITEM = {
    movingConstruction = "icon_movingConstruction.png",
    torch = "icon_torch.png",
    changePlayerName = "icon_changePlayerName.png",
    changeCityName = "icon_changeCityName.png",
    retreatTroop = "icon_retreatTroop.png",
    moveTheCity = "icon_moveTheCity.png",
    dragonExp_1 = "icon_dragonExp_1.png",
    dragonExp_2 = "icon_dragonExp_2.png",
    dragonExp_3 = "icon_dragonExp_3.png",
    dragonHp_1 = "icon_dragonHp_1.png",
    dragonHp_2 = "icon_dragonHp_2.png",
    dragonHp_3 = "icon_dragonHp_3.png",
    heroBlood_1 = "icon_heroBlood_1.png",
    heroBlood_2 = "icon_heroBlood_2.png",
    stamina_1 = "icon_stamina_1.png",
    stamina_2 = "icon_stamina_2.png",

    speedup_1 = "wood_sandglass.png",
    speedup_2 = "copper_sandglass.png",
    speedup_3 = "silver_sandglass.png",
    speedup_4 = "gold_sandglass.png",
    speedup_5 = "platinum_sandglass.png",
    speedup_6 = "crystal_sandglass.png",
    speedup_7 = "drak_gold_sandglass.png",
    speedup_8 = "secret_power_sandglass.png",
    warSpeedupClass_1 = "normal_war_sandglass.png",
    warSpeedupClass_2 = "strengthen_war_sandglass.png",

    casinoTokenClass_1 = "casinoToken_1.png",
    casinoTokenClass_2 = "casinoToken_2.png",
    casinoTokenClass_3 = "casinoToken_3.png",
    casinoTokenClass_4 = "casinoToken_3.png",

    woodClass_1 = "item_wood_1.png",
    woodClass_2 = "item_wood_1.png",
    woodClass_3 = "item_wood_2.png",
    woodClass_4 = "item_wood_2.png",
    woodClass_5 = "item_wood_2.png",
    woodClass_6 = "item_wood_3.png",
    woodClass_7 = "item_wood_3.png",
    stoneClass_1 = "item_stone_1.png",
    stoneClass_2 = "item_stone_1.png",
    stoneClass_3 = "item_stone_2.png",
    stoneClass_4 = "item_stone_2.png",
    stoneClass_5 = "item_stone_2.png",
    stoneClass_6 = "item_stone_3.png",
    stoneClass_7 = "item_stone_3.png",
    ironClass_1 = "item_iron_1.png",
    ironClass_2 = "item_iron_1.png",
    ironClass_3 = "item_iron_2.png",
    ironClass_4 = "item_iron_2.png",
    ironClass_5 = "item_iron_2.png",
    ironClass_6 = "item_iron_3.png",
    ironClass_7 = "item_iron_3.png",
    foodClass_1 = "item_food_1.png",
    foodClass_2 = "item_food_1.png",
    foodClass_3 = "item_food_2.png",
    foodClass_4 = "item_food_2.png",
    foodClass_5 = "item_food_2.png",
    foodClass_6 = "item_food_3.png",
    foodClass_7 = "item_food_3.png",
    coinClass_1 = "item_coin_1.png",
    coinClass_2 = "item_coin_1.png",
    coinClass_3 = "item_coin_2.png",
    coinClass_4 = "item_coin_2.png",
    coinClass_5 = "item_coin_3.png",
    coinClass_6 = "item_coin_3.png",

    siegeAtkBonus_1 = "siegeAtkBonus_1.png",
    siegeAtkBonus_2 = "siegeAtkBonus_1.png",
    siegeAtkBonus_3 = "siegeAtkBonus_1.png",
    unitHpBonus_1 = "unitHpBonus_1.png",
    unitHpBonus_2 = "unitHpBonus_1.png",
    unitHpBonus_3 = "unitHpBonus_1.png",
    cavalryAtkBonus_1 = "cavalryAtkBonus_1.png",
    cavalryAtkBonus_2 = "cavalryAtkBonus_1.png",
    cavalryAtkBonus_3 = "cavalryAtkBonus_1.png",
    archerAtkBonus_1 = "archerAtkBonus_1.png",
    archerAtkBonus_2 = "archerAtkBonus_1.png",
    archerAtkBonus_3 = "archerAtkBonus_1.png",
    infantryAtkBonus_1 = "infantryAtkBonus_1.png",
    infantryAtkBonus_2 = "infantryAtkBonus_1.png",
    infantryAtkBonus_3 = "infantryAtkBonus_1.png",
    marchSpeedBonus_1 = "marchSpeedBonus_1.png",
    marchSpeedBonus_2 = "marchSpeedBonus_1.png",
    marchSpeedBonus_3 = "marchSpeedBonus_1.png",
    dragonHpBonus_1 = "dragonHpBonus_1.png",
    dragonHpBonus_2 = "dragonHpBonus_1.png",
    dragonHpBonus_3 = "dragonHpBonus_1.png",
    dragonExpBonus_1 = "dragonExpBonus_1.png",
    dragonExpBonus_2 = "dragonExpBonus_1.png",
    dragonExpBonus_3 = "dragonExpBonus_1.png",
    troopSizeBonus_1 = "troopSizeBonus_1.png",
    troopSizeBonus_2 = "troopSizeBonus_1.png",
    troopSizeBonus_3 = "troopSizeBonus_1.png",
    citizenBonus_1 = "citizenBonus_1.png",
    citizenBonus_2 = "citizenBonus_1.png",
    citizenBonus_3 = "citizenBonus_1.png",
    coinBonus_1 = "coinBonus_1.png",
    coinBonus_2 = "coinBonus_1.png",
    coinBonus_3 = "coinBonus_1.png",
    foodBonus_1 = "foodBonus_1.png",
    foodBonus_2 = "foodBonus_1.png",
    foodBonus_3 = "foodBonus_1.png",
    ironBonus_1 = "ironBonus_1.png",
    ironBonus_2 = "ironBonus_1.png",
    ironBonus_3 = "ironBonus_1.png",
    stoneBonus_1 = "stoneBonus_1.png",
    stoneBonus_2 = "stoneBonus_1.png",
    stoneBonus_3 = "stoneBonus_1.png",
    woodBonus_1 = "woodBonus_1.png",
    woodBonus_2 = "woodBonus_1.png",
    woodBonus_3 = "woodBonus_1.png",
    fogOfTrick_1 = "fogOfTrick_1.png",
    fogOfTrick_2 = "fogOfTrick_1.png",
    fogOfTrick_3 = "fogOfTrick_1.png",
    quarterMaster_1 = "quarterMaster_1.png",
    quarterMaster_2 = "quarterMaster_1.png",
    quarterMaster_3 = "quarterMaster_1.png",
    vipPoint_1 = "vipPoint_1.png",
    vipPoint_2 = "vipPoint_1.png",
    vipPoint_3 = "vipPoint_1.png",
    vipPoint_4 = "vipPoint_1.png",
    vipActive_1 = "vipActive_1.png",
    vipActive_2 = "vipActive_1.png",
    vipActive_3 = "vipActive_1.png",
    vipActive_4 = "vipActive_1.png",
    vipActive_5 = "vipActive_1.png",
    chestKey_2 = "chestKey_2.png",
    chestKey_3 = "chestKey_3.png",
    chestKey_4 = "chestKey_4.png",
    restoreWall_1 = "restoreWall_1.png",
    restoreWall_2 = "restoreWall_1.png",
    restoreWall_3 = "restoreWall_1.png",
    heroBlood_1 = "heroBlood_1.png",
    heroBlood_2 = "heroBlood_1.png",
    heroBlood_3 = "heroBlood_1.png",
    stamina_1 = "stamina_1.png",
    stamina_2 = "stamina_2.png",
    stamina_3 = "stamina_3.png",
    retreatTroop = "retreatTroop.png",
    torch = "torch.png",
    changePlayerName = "changePlayerName.png",
    changeCityName = "changeCityName.png",
}

local SOLDIER_ANIMATIONS = getAniNameFromAnimationFiles(SOLDIER_ANIMATION_FILES)
local SOLDIER_EFFECT_ANIMATIONS = getAniNameFromAnimationFiles(EFFECT_ANIMATION_FILES)
local DRAGON_ANIMATIONS = getAniNameFromAnimationFiles(DRAGON_ANIMATIONS_FILES)

local DAILY_TASK_ICON = {
    empireRise = "Icon_empireRise_91x117.png",
    conqueror = "Icon_conqueror_104x117.png",
    brotherClub = "Icon_brotherClub_122x124.png",
    growUp = "Icon_growUp_108x115.png"
}
local PVEDefine = import("..entity.PVEDefine")
local SpriteConfig = import("..sprites.SpriteConfig")
local PVE = {
    [PVEDefine.START_AIRSHIP] = {"image", "airship.png", 0.4},
    [PVEDefine.WOODCUTTER] = {"image", SpriteConfig["woodcutter"]:GetConfigByLevel(1).png},
    [PVEDefine.QUARRIER] = {"image", SpriteConfig["quarrier"]:GetConfigByLevel(1).png},
    [PVEDefine.MINER] = {"image", SpriteConfig["miner"]:GetConfigByLevel(1).png},
    [PVEDefine.FARMER] = {"image", SpriteConfig["farmer"]:GetConfigByLevel(1).png},
    [PVEDefine.CAMP] = {"animation", "yewaiyindi"},
    [PVEDefine.CRASHED_AIRSHIP] = {"image", "crashed_airship_80x70.png"},
    [PVEDefine.CONSTRUCTION_RUINS] = {"image", "ruin_1.png"},
    [PVEDefine.KEEL] = {"image", "keel_189x86.png"},
    [PVEDefine.WARRIORS_TOMB] = {"image", "warriors_tomb_80x72.png"},
    [PVEDefine.OBELISK] = {"animation", "zhihuishi"},
    [PVEDefine.ANCIENT_RUINS] = {"image", "ancient_ruins.png"},
    [PVEDefine.ENTRANCE_DOOR] = {"image", "entrance_door.png"},
    [PVEDefine.TREE] = {"image", "grass_tree_1_138x110.png"},
    [PVEDefine.HILL] = {"image", "hill_228x146.png"},
    [PVEDefine.LAKE] = {"image", "lake_220x174.png"},
}
local PVE_ANIMATION_FILES = {
    "animations/yewaiyindi/yewaiyindi.ExportJson",
    "animations/zhihuishi/zhihuishi.ExportJson",
}
-- local PVE_ANIMATIONS = getAniNameFromAnimationFiles(PVE_ANIMATION_FILES)
local function loadBuildingAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,animations in pairs(BUILDING_ANIMATIONS_FILES) do
        for _,ani_file in pairs(animations) do
            manager:addArmatureFileInfo(ani_file)
        end
    end
end
local function unLoadBuildingAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,animations in pairs(BUILDING_ANIMATIONS_FILES) do
        for _,ani_file in pairs(animations) do
            manager:removeArmatureFileInfo(ani_file)
        end
    end
end
--
local function loadSolidersAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,animations in pairs(SOLDIER_ANIMATION_FILES) do
        for _,ani_file in pairs(animations) do
            manager:addArmatureFileInfo(ani_file)
        end
    end
end
local function unLoadSolidersAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,animations in pairs(SOLDIER_ANIMATION_FILES) do
        for _,ani_file in pairs(animations) do
            manager:removeArmatureFileInfo(ani_file)
        end
    end
end

local IAP_PACKAGE_IMAGE = {
    product_1 = {
        content = "store_item_red_610x514.png",
        logo = "gem_logo_592x139_1.png",
        desc = "store_desc_black_335x92.png",
        npc  = "store_npc_1_109x130.png",
        more = {normal = "store_more_red_button_n_584x34.png",pressed = "store_more_red_button_l_584x34.png"},
        small_content = "store_item_content_red_s_588x186.png",
    },
    product_2 = {
        content = "store_item_black_610x514.png",
        logo = "gem_logo_592x139_2.png",
        desc = "store_desc_red_282x92.png",
        more = {normal = "store_more_black_button_n_584x34.png",pressed = "store_more_black_button_l_584x34.png"},
        small_content = "store_item_content_black_s_588x186.png",
    },
    product__3 = {
        content = "store_item_black_610x514.png",
        logo = "gem_logo_592x139_3.png",
        desc = "store_desc_red_282x92.png",
        more = {normal = "store_more_black_button_n_584x34.png",pressed = "store_more_black_button_l_584x34.png"},
        small_content = "store_item_content_black_s_588x186.png",
    },
    product_4 = {
        content = "store_item_black_610x514.png",
        logo = "gem_logo_592x139_4.png",
        desc = "store_desc_red_282x92.png",
        more = {normal = "store_more_black_button_n_584x34.png",pressed = "store_more_black_button_l_584x34.png"},
        small_content = "store_item_content_black_s_588x186.png",
    },
    product_5 = {
        content = "store_item_red_610x514.png",
        logo = "gem_logo_592x139_5.png",
        desc = "store_desc_black_335x92.png",
        npc  = "store_npc_2_171x130.png",
        more = {normal = "store_more_red_button_n_584x34.png",pressed = "store_more_red_button_l_584x34.png"},
        small_content = "store_item_content_red_s_588x186.png",
    },
}

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
    item = ITEM,
    daily_task_icon = DAILY_TASK_ICON,
    building_animations = BUILDING_ANIMATIONS,
    building_animations_files = BUILDING_ANIMATIONS_FILES,
    pve = PVE,
    pve_animation_files = PVE_ANIMATION_FILES,
    loadBuildingAnimation = loadBuildingAnimation,
    unLoadBuildingAnimation = unLoadBuildingAnimation,
    loadSolidersAnimation = loadSolidersAnimation,
    unLoadSolidersAnimation = unLoadSolidersAnimation,
    iap_package_image = IAP_PACKAGE_IMAGE,
}

