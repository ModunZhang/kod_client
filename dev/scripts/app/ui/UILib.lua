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
        "animations/liaowangta.ExportJson"
    },
    barracks = {
        "animations/bingyin.ExportJson",
        "animations/bingyin_1.ExportJson"
    },
    tradeGuild = {
        "animations/maoyihanghui.ExportJson",
    },
    mill = {
        "animations/mofang.ExportJson",
    },
    townHall = {
        "animations/shizhenting.ExportJson",
    },
    academy = {
        "animations/xueyuan.ExportJson",
    },
    hospital = {
        "animations/yiyuan.ExportJson",
    },
    warehouse = {
        "animations/ziyuancangku.ExportJson",
    },
    smoke = {
        "animations/yan.ExportJson",
    },
    hammer = {
        "animations/chuizi.ExportJson",
    },
    airShip = {
        "animations/feiting.ExportJson",
    },
    citizen = {
        "animations/caodi_nan.ExportJson",
        "animations/caodi_nv.ExportJson",
        "animations/xuedi_nan.ExportJson",
        "animations/xuedi_nv.ExportJson",
        "animations/shadi_nan.ExportJson",
        "animations/shadi_nv.ExportJson",
    },
    bird = {
        "animations/gezi.ExportJson",
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
    wallHp = "gate_1.png",
}
local MATERIALS = {
    blueprints = "blueprints_128x128.png",
    tools =  "tools_128x128.png",
    tiles = "tiles_128x128.png",
    pulley = "pulley_128x128.png",
    trainingFigure = "trainingFigure_128x128.png",
    bowTarget = "bowTarget_128x128.png",
    saddle = "saddle_128x128.png",
    ironPart = "ironPart_128x128.png",
}
local DRAGON_MATERIAL_PIC_MAP = {
    ["ingo_1"] = "ironIngot_128x128.png",
    ["ingo_2"] = "steelIngot_128x128.png",
    ["ingo_3"] = "mithrilIngot_128x128.png",
    ["ingo_4"] = "blackIronIngot_128x128.png",
    ["redSoul_2"] = "arcaniteIngot_92x92.png",
    ["redSoul_3"] = "wispOfFire_92x92.png",
    ["redSoul_4"] = "wispOfCold_92x92.png",
    ["blueSoul_2"] = "wispOfWind_92x92.png",
    ["blueSoul_3"] = "lavaSoul_92x92.png",
    ["blueSoul_4"] = "iceSoul_92x92.png",
    ["greenSoul_2"] = "forestSoul_92x92.png",
    ["greenSoul_3"] = "infernoSoul_92x92.png",
    ["greenSoul_4"] = "blizzardSoul_92x92.png",
    ["redCrystal_1"] = "flawedRedCrystal_128x128.png",
    ["redCrystal_2"] = "redCrystal_128x128.png",
    ["redCrystal_3"] = "flawlessRedCrystal_128x128.png",
    ["redCrystal_4"] = "perfectRedCrystal_128x128.png",
    ["blueCrystal_1"] = "flawedBlueCrystal_128x128.png",
    ["blueCrystal_2"] = "blueCrystal_128x128.png",
    ["blueCrystal_3"] = "flawlessBlueCrystal_128x128.png",
    ["blueCrystal_4"] = "perfectBlueCrystal_128x128.png",
    ["greenCrystal_1"] = "flawedGreenCrystal_128x128.png",
    ["greenCrystal_2"] = "greenCrystal_128x128.png",
    ["greenCrystal_3"] = "flawlessGreenCrystal_128x128.png",
    ["greenCrystal_4"] = "perfectGreenCrystal_128x128.png",
    ["runes_1"] = "ancientRunes_128x128.png",
    ["runes_2"] = "elementalRunes_128x128.png",
    ["runes_3"] = "pureRunes_128x128.png",
    ["runes_4"] = "titanRunes_128x128.png",
}
local SOLDIER_METARIAL = {
    ["heroBones"] = "heroBones_128x128.png",
    ["magicBox"] = "magicBox_128x128.png",
    ["holyBook"] = "insight_icon_45x45.png",
    ["brightAlloy"] = "insight_icon_45x45.png",
    ["soulStone"] = "soulStone_128x128.png",
    ["deathHand"] = "deathHand_128x128.png",
    ["confessionHood"] = "insight_icon_45x45.png",
    ["brightRing"] = "insight_icon_45x45.png",
}
local EQUIPMENT = {
    ["redCrown_s1"] = "redCrown_s1_128x128.png",
    ["redCrown_s2"] = "redCrown_s2_128x128.png",
    ["redCrown_s3"] = "redCrown_s3_128x128.png",
    ["redCrown_s4"] = "redCrown_s4_128x128.png",
    ["blueCrown_s1"] = "blueCrown_s1_128x128.png",
    ["blueCrown_s2"] = "blueCrown_s2_128x128.png",
    ["blueCrown_s3"] = "blueCrown_s3_128x128.png",
    ["blueCrown_s4"] = "blueCrown_s4_128x128.png",
    ["greenCrown_s1"] = "greenCrown_s1_128x128.png",
    ["greenCrown_s2"] = "greenCrown_s2_128x128.png",
    ["greenCrown_s3"] = "greenCrown_s3_128x128.png",
    ["greenCrown_s4"] = "greenCrown_s4_128x128.png",
    ["redChest_s2"] = "redChest_s2_128x128.png",
    ["redChest_s3"] = "redChest_s3_128x128.png",
    ["redChest_s4"] = "redChest_s4_128x128.png",
    ["blueChest_s2"] = "blueChest_s2_128x128.png",
    ["blueChest_s3"] = "blueChest_s3_128x128.png",
    ["blueChest_s4"] = "blueChest_s4_128x128.png",
    ["greenChest_s2"] = "greenChest_s2_128x128.png",
    ["greenChest_s3"] = "greenChest_s3_128x128.png",
    ["greenChest_s4"] = "greenChest_s4_128x128.png",
    ["redSting_s2"] = "redSting_s2_128x128.png",
    ["redSting_s3"] = "redSting_s3_128x128.png",
    ["redSting_s4"] = "redSting_s4_128x128.png",
    ["blueSting_s2"] = "blueSting_s2_128x128.png",
    ["blueSting_s3"] = "blueSting_s3_128x128.png",
    ["blueSting_s4"] = "blueSting_s4_128x128.png",
    ["greenSting_s2"] = "greenSting_s2_128x128.png",
    ["greenSting_s3"] = "greenSting_s3_128x128.png",
    ["greenSting_s4"] = "greenSting_s4_128x128.png",
    ["redOrd_s2"] = "redOrd_s2_128x128.png",
    ["redOrd_s3"] = "redOrd_s3_128x128.png",
    ["redOrd_s4"] = "redOrd_s4_128x128.png",
    ["blueOrd_s2"] = "blueOrd_s2_128x128.png",
    ["blueOrd_s3"] = "blueOrd_s3_128x128.png",
    ["blueOrd_s4"] = "blueOrd_s4_128x128.png",
    ["greenOrd_s2"] = "greenOrd_s2_128x128.png",
    ["greenOrd_s3"] = "greenOrd_s3_128x128.png",
    ["greenOrd_s4"] = "greenOrd_s4_128x128.png",
    ["redArmguard_s1"] = "redArmguard_s1_128x128.png",
    ["redArmguard_s2"] = "redArmguard_s2_128x128.png",
    ["redArmguard_s3"] = "redArmguard_s3_128x128.png",
    ["redArmguard_s4"] = "redArmguard_s4_128x128.png",
    ["blueArmguard_s1"] = "blueArmguard_s1_128x128.png",
    ["blueArmguard_s2"] = "blueArmguard_s2_128x128.png",
    ["blueArmguard_s3"] = "blueArmguard_s3_128x128.png",
    ["blueArmguard_s4"] = "blueArmguard_s4_128x128.png",
    ["greenArmguard_s1"] = "greenArmguard_s1_128x128.png",
    ["greenArmguard_s2"] = "greenArmguard_s2_128x128.png",
    ["greenArmguard_s3"] = "greenArmguard_s3_128x128.png",
    ["greenArmguard_s4"] = "greenArmguard_s4_128x128.png",
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
        "animations/gongjianshou_1.ExportJson",
        "animations/gongjianshou_2.ExportJson",
        "animations/gongjianshou_3.ExportJson",
    },
    crossbowman = {
        "animations/nugongshou_1.ExportJson",
        "animations/nugongshou_2.ExportJson",
        "animations/nugongshou_3.ExportJson",
    },
    catapult = {
        "animations/toushiche.ExportJson",
        "animations/toushiche_2.ExportJson",
        "animations/toushiche_3.ExportJson",
    },
    ballista = {
        "animations/nuche_1.ExportJson",
        "animations/nuche_2.ExportJson",
        "animations/nuche_3.ExportJson",
    },
    lancer = {
        "animations/qibing_1.ExportJson",
        "animations/qibing_2.ExportJson",
        "animations/qibing_3.ExportJson",
    },
    horseArcher = {
        "animations/youqibing_1.ExportJson",
        "animations/youqibing_2.ExportJson",
        "animations/youqibing_3.ExportJson",
    },
    swordsman = {
        "animations/bubing_1.ExportJson",
        "animations/bubing_2.ExportJson",
        "animations/bubing_3.ExportJson",
    },
    sentinel = {
        "animations/shaobing_1.ExportJson",
        "animations/shaobing_2.ExportJson",
        "animations/shaobing_3.ExportJson",
    },
    skeletonWarrior = {
        "animations/kulouyongshi.ExportJson",
    },
    skeletonArcher = {
        "animations/kulousheshou.ExportJson",
    },
    deathKnight = {
        "animations/siwangqishi.ExportJson",
    },
    meatWagon = {
        "animations/jiaorouche.ExportJson",
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
        "skeletonWarrior.png",
        "skeletonWarrior.png",
        "skeletonWarrior.png",
    },
    skeletonArcher = {
        "skeletonArcher.png",
        "skeletonArcher.png",
        "skeletonArcher.png",
    },
    deathKnight = {
        "deathKnight.png",
        "deathKnight.png",
        "deathKnight.png",
    },
    meatWagon = {
        "meatWagon.png",
        "meatWagon.png",
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
        "ranger_1.png",
        "b_ranger_1.png",
        "b_ranger_2.png",
    },
    catapult = {
        "catapult_1.png",
        "b_catapult_1.png",
        "b_catapult_2.png",
    },
    lancer = {
        "lancer_1.png",
        "b_lancer_1.png",
        "b_lancer_2.png",
    },
    swordsman = {
        "swordsman_1.png",
        "b_swordsman_1.png",
        "b_swordsman_2.png",
    },
    sentinel = {
        "sentinel_1.png",
        "b_sentinel_1.png",
        "b_sentinel_2.png",
    },
    crossbowman = {
        "crossbowman_1.png",
        "b_crossbowman_1.png",
        "b_crossbowman_2.png",
    },
    horseArcher = {
        "horseArcher_1.png",
        "b_horseArcher_1.png",
        "b_horseArcher_2.png",
    },
    ballista = {
        "ballista_1.png",
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
        "animations/red_long.ExportJson"
    },
    blueDragon = {
        "animations/blue_long.ExportJson"
    },
    greenDragon = {
        "animations/green_long.ExportJson"
    }
}
local DECORATOR_IMAGE = {
    grassLand = {
        decorate_lake_1 = "lake_1_grassLand.png",
        decorate_lake_2 =  "lake_2_grassLand.png",
        decorate_mountain_1 =  "hill_1_grassLand.png",
        decorate_mountain_2 =  "hill_2_grassLand.png",
        decorate_tree_1 =  "tree_1_grassLand.png",
        decorate_tree_2 =  "tree_2_grassLand.png",
        decorate_tree_3 =  "tree_3_grassLand.png",
        decorate_tree_4 =  "tree_4_grassLand.png",
        stone_mountain  = "grass_stone_mountain_80x58.png",
        farmland        = "grass_farmland_80x55.png"
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
        stone_mountain  = "ice_stone_mountain_80x58.png",
        farmland        = "ice_farmland_80x55.png"
    },
    desert = {
        decorate_lake_1 = "lake_1_desert.png",
        decorate_lake_2 =  "lake_2_desert.png",
        decorate_mountain_1 =  "hill_1_desert.png",
        decorate_mountain_2 =  "hill_2_desert.png",
        decorate_tree_1 =  "tree_1_desert.png",
        decorate_tree_2 =  "tree_2_desert.png",
        decorate_tree_3 =  "tree_3_desert.png",
        decorate_tree_4 =  "tree_4_desert.png",
        stone_mountain  = "desert_stone_mountain_80x58.png",
        farmland        = "desert_farmland_80x55.png"
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
local BUFF = {
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
    movingConstruction = "movingConstruction_128x128.png",
    torch = "torch_128x128.png",
    changePlayerName = "changePlayerName_128x128.png",
    changeCityName = "changeCityName_128x128.png",
    retreatTroop = "retreatTroop_128x128.png",
    moveTheCity = "moveTheCity_128x128.png",
    dragonExp_1 = "dragonExp_1_128x128.png",
    dragonExp_2 = "dragonExp_2_128x128.png",
    dragonExp_3 = "dragonExp_3_128x128.png",
    dragonHp_1 = "dragonHp_1_128x128.png",
    dragonHp_2 = "dragonHp_2_128x128.png",
    dragonHp_3 = "dragonHp_3_128x128.png",
    heroBlood_1 = "heroBlood_1_128x128.png",
    heroBlood_2 = "heroBlood_2_128x128.png",
    heroBlood_3 = "heroBlood_3_128x128.png",
    stamina_1 = "stamina_1_128x128.png",
    stamina_2 = "stamina_2_128x128.png",
    stamina_3 = "stamina_3_128x128.png",

    speedup_1 = "speedup_1_128x128.png",
    speedup_2 = "speedup_2_128x128.png",
    speedup_3 = "speedup_3_128x128.png",
    speedup_4 = "speedup_4_128x128.png",
    speedup_5 = "speedup_5_128x128.png",
    speedup_6 = "speedup_6_128x128.png",
    speedup_7 = "speedup_7_128x128.png",
    speedup_8 = "speedup_8_128x128.png",
    warSpeedupClass_1 = "warSpeedup_1_128x128.png",
    warSpeedupClass_2 = "warSpeedup_2_128x128.png",

    dragonChest_1 = "#root/lanse/a0000.png",
    dragonChest_2 = "#root/lvse/a0000.png",
    dragonChest_3 = "#root/zise/a0000.png",

    casinoTokenClass_1 = "casinoTokenClass_1_128x128.png",
    casinoTokenClass_2 = "casinoTokenClass_2_128x128.png",
    casinoTokenClass_3 = "casinoTokenClass_3_128x128.png",
    casinoTokenClass_4 = "casinoTokenClass_4_128x128.png",

    masterOfDefender_1 = "masterOfDefender_1_128x128.png",
    masterOfDefender_2 = "masterOfDefender_2_128x128.png",
    masterOfDefender_3 = "masterOfDefender_3_128x128.png",

    woodClass_1 = "woodClass_1_128x128.png",
    woodClass_2 = "woodClass_2_128x128.png",
    woodClass_3 = "woodClass_3_128x128.png",
    woodClass_4 = "woodClass_4_128x128.png",
    woodClass_5 = "woodClass_5_128x128.png",
    woodClass_6 = "woodClass_6_128x128.png",
    woodClass_7 = "woodClass_7_128x128.png",
    stoneClass_1 = "stoneClass_1_128x128.png",
    stoneClass_2 = "stoneClass_2_128x128.png",
    stoneClass_3 = "stoneClass_3_128x128.png",
    stoneClass_4 = "stoneClass_4_128x128.png",
    stoneClass_5 = "stoneClass_5_128x128.png",
    stoneClass_6 = "stoneClass_6_128x128.png",
    stoneClass_7 = "stoneClass_7_128x128.png",
    ironClass_1 = "ironClass_1_128x128.png",
    ironClass_2 = "ironClass_2_128x128.png",
    ironClass_3 = "ironClass_3_128x128.png",
    ironClass_4 = "ironClass_4_128x128.png",
    ironClass_5 = "ironClass_5_128x128.png",
    ironClass_6 = "ironClass_6_128x128.png",
    ironClass_7 = "ironClass_7_128x128.png",
    foodClass_1 = "foodClass_1_128x128.png",
    foodClass_2 = "foodClass_2_128x128.png",
    foodClass_3 = "foodClass_3_128x128.png",
    foodClass_4 = "foodClass_4_128x128.png",
    foodClass_5 = "foodClass_5_128x128.png",
    foodClass_6 = "foodClass_6_128x128.png",
    foodClass_7 = "foodClass_7_128x128.png",
    coinClass_1 = "coinClass_1_128x128.png",
    coinClass_2 = "coinClass_2_128x128.png",
    coinClass_3 = "coinClass_3_128x128.png",
    coinClass_4 = "coinClass_4_128x128.png",
    coinClass_5 = "coinClass_5_128x128.png",
    coinClass_6 = "coinClass_6_128x128.png",
    coinClass_7 = "coinClass_7_128x128.png",

    siegeAtkBonus_1 = "siegeAtkBonus_1_128x128.png",
    siegeAtkBonus_2 = "siegeAtkBonus_2_128x128.png",
    siegeAtkBonus_3 = "siegeAtkBonus_3_128x128.png",
    unitHpBonus_1 = "unitHpBonus_1_128x128.png",
    unitHpBonus_2 = "unitHpBonus_2_128x128.png",
    unitHpBonus_3 = "unitHpBonus_3_128x128.png",
    cavalryAtkBonus_1 = "cavalryAtkBonus_1_128x128.png",
    cavalryAtkBonus_2 = "cavalryAtkBonus_2_128x128.png",
    cavalryAtkBonus_3 = "cavalryAtkBonus_3_128x128.png",
    archerAtkBonus_1 = "archerAtkBonus_1_128x128.png",
    archerAtkBonus_2 = "archerAtkBonus_2_128x128.png",
    archerAtkBonus_3 = "archerAtkBonus_3_128x128.png",
    infantryAtkBonus_1 = "infantryAtkBonus_1_128x128.png",
    infantryAtkBonus_2 = "infantryAtkBonus_2_128x128.png",
    infantryAtkBonus_3 = "infantryAtkBonus_3_128x128.png",
    marchSpeedBonus_1 = "marchSpeedBonus_1_128x128.png",
    marchSpeedBonus_2 = "marchSpeedBonus_2_128x128.png",
    marchSpeedBonus_3 = "marchSpeedBonus_3_128x128.png",
    dragonHpBonus_1 = "dragonHpBonus_1_128x128.png",
    dragonHpBonus_2 = "dragonHpBonus_2_128x128.png",
    dragonHpBonus_3 = "dragonHpBonus_3_128x128.png",
    dragonExpBonus_1 = "dragonExpBonus_1_128x128.png",
    dragonExpBonus_2 = "dragonExpBonus_2_128x128.png",
    dragonExpBonus_3 = "dragonExpBonus_3_128x128.png",
    troopSizeBonus_1 = "troopSizeBonus_1_128x128.png",
    troopSizeBonus_2 = "troopSizeBonus_2_128x128.png",
    troopSizeBonus_3 = "troopSizeBonus_3_128x128.png",
    citizenBonus_1 = "citizenBonus_1_128x128.png",
    citizenBonus_2 = "citizenBonus_2_128x128.png",
    citizenBonus_3 = "citizenBonus_3_128x128.png",
    citizenClass_1 = "citizenClass_1_128x128.png",
    citizenClass_2 = "citizenClass_2_128x128.png",
    citizenClass_3 = "citizenClass_3_128x128.png",
    coinBonus_1 = "coinBonus_1_128x128.png",
    coinBonus_2 = "coinBonus_2_128x128.png",
    coinBonus_3 = "coinBonus_3_128x128.png",
    foodBonus_1 = "foodBonus_1_128x128.png",
    foodBonus_2 = "foodBonus_2_128x128.png",
    foodBonus_3 = "foodBonus_3_128x128.png",
    ironBonus_1 = "ironBonus_1_128x128.png",
    ironBonus_2 = "ironBonus_2_128x128.png",
    ironBonus_3 = "ironBonus_3_128x128.png",
    stoneBonus_1 = "stoneBonus_1_128x128.png",
    stoneBonus_2 = "stoneBonus_2_128x128.png",
    stoneBonus_3 = "stoneBonus_3_128x128.png",
    woodBonus_1 = "woodBonus_1_128x128.png",
    woodBonus_2 = "woodBonus_2_128x128.png",
    woodBonus_3 = "woodBonus_3_128x128.png",
    fogOfTrick_1 = "fogOfTrick_1_128x128.png",
    fogOfTrick_2 = "fogOfTrick_2_128x128.png",
    fogOfTrick_3 = "fogOfTrick_3_128x128.png",
    quarterMaster_1 = "quarterMaster_1_128x128.png",
    quarterMaster_2 = "quarterMaster_2_128x128.png",
    quarterMaster_3 = "quarterMaster_3_128x128.png",
    vipPoint_1 = "vipPoint_1_128x128.png",
    vipPoint_2 = "vipPoint_2_128x128.png",
    vipPoint_3 = "vipPoint_3_128x128.png",
    vipPoint_4 = "vipPoint_4_128x128.png",
    vipActive_1 = "vipActive_1_128x128.png",
    vipActive_2 = "vipActive_2_128x128.png",
    vipActive_3 = "vipActive_3_128x128.png",
    vipActive_4 = "vipActive_4_128x128.png",
    vipActive_5 = "vipActive_5_128x128.png",
    chestKey_2 = "chestKey_2_128x128.png",
    chestKey_3 = "chestKey_3_128x128.png",
    chestKey_4 = "chestKey_4_128x128.png",
    restoreWall_1 = "restoreWall_1_128x128.png",
    restoreWall_2 = "restoreWall_2_128x128.png",
    restoreWall_3 = "restoreWall_3_128x128.png",
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
    "animations/yewaiyindi.ExportJson",
    "animations/zhihuishi.ExportJson",

    "animations/heihua_bubing_2.ExportJson",
    "animations/heihua_bubing_3.ExportJson",
    "animations/heihua_gongjianshou_2.ExportJson",
    "animations/heihua_gongjianshou_3.ExportJson",
    "animations/heihua_nuche_2.ExportJson",
    "animations/heihua_nuche_3.ExportJson",
    "animations/heihua_nugongshou_2.ExportJson",
    "animations/heihua_nugongshou_3.ExportJson",
    "animations/heihua_qibing_2.ExportJson",
    "animations/heihua_qibing_3.ExportJson",
    "animations/heihua_shaobing_2.ExportJson",
    "animations/heihua_shaobing_3.ExportJson",
    "animations/heihua_toushiche_2.ExportJson",
    "animations/heihua_toushiche_3.ExportJson",
    "animations/heihua_youqibing_2.ExportJson",
    "animations/heihua_youqibing_3.ExportJson",
    "animations/heilong.ExportJson",
}

local function loadBuildingAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,all_files in pairs(BUILDING_ANIMATIONS_FILES) do
        for _,ani_file in pairs(all_files) do
            manager:addArmatureFileInfo(ani_file)
        end
    end
end
local function unLoadBuildingAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,all_files in pairs(BUILDING_ANIMATIONS_FILES) do
        for _,ani_file in pairs(all_files) do
            manager:removeArmatureFileInfo(ani_file)
        end
    end
end
--
local function loadSolidersAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,all_files in pairs(SOLDIER_ANIMATION_FILES) do
        for _,ani_file in pairs(all_files) do
            manager:addArmatureFileInfo(ani_file)
        end
    end
end
local function unLoadSolidersAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,all_files in pairs(SOLDIER_ANIMATION_FILES) do
        for _,ani_file in pairs(all_files) do
            manager:removeArmatureFileInfo(ani_file)
        end
    end
end

local function loadPveAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,ani_file in pairs(PVE_ANIMATION_FILES) do
        manager:addArmatureFileInfo(ani_file)
    end
end
local function unLoadPveAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _,all_files in pairs(PVE_ANIMATION_FILES) do
        manager:removeArmatureFileInfo(ani_file)
    end
end

local function loadDragonAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _, anis in pairs(DRAGON_ANIMATIONS_FILES) do
        for _, v in pairs(anis) do
            manager:addArmatureFileInfo(v)
        end
    end
end
local function unLoadDragonAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _, anis in pairs(DRAGON_ANIMATIONS_FILES) do
        for _, v in pairs(anis) do
            manager:removeArmatureFileInfo(v)
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

local PRODUC_TIONTECHS_IMAGE = {
    crane = "crane_128x128.png",
    stoneCarving = "stoneCarving_128x128.png",
    forestation = "forestation_128x128.png",
    fastFix = "fastFix_128x128.png",
    ironSmelting = "ironSmelting_128x128.png",
    cropResearch = "cropResearch_128x128.png",
    reinforcing = "reinforcing_128x128.png",
    seniorTower = "seniorTower_128x128.png",
    beerSupply = "beerSupply_128x128.png",
    rescueTent = "rescueTent_128x128.png",
    colonization = "colonization_128x128.png",
    negotiation = "negotiation_128x128.png",
    trap = "trap_128x128.png",
    hideout = "hideoud_128x128.png",
    logistics = "logistics_128x128.png",
    healingAgent = "healingAgent_128x128.png",
    sketching = "sketching_128x128.png",
    mintedCoin = "mintedcoin_128x128.png",

}


local GET_DRAGON_EQUIPMENT_IMAGE = function(dragon_name,body_name,star)
    local __,__,color_str = string.find(dragon_name, "(%a+)Dragon")
    local body_str = ""
    if "armguardLeft" == body_name or "armguardRight" == body_name then
        body_str = "Armguard"
    elseif "crown" == body_name then
        body_str  = "Crown"
    elseif "orb" == body_name then
        body_str  = "Orb"
    elseif "chest" ==  body_name then
        body_str  = "Chest"
    elseif "sting" == body_name then
        body_str  = "Sting"
    end
    assert(body_str ~= '',"body_name错误")
    local equipment_key = color_str .. body_str .. "_s" .. star
    return EQUIPMENT[equipment_key]
end

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
    loadBuildingAnimation = loadBuildingAnimation,
    unLoadBuildingAnimation = unLoadBuildingAnimation,
    loadSolidersAnimation = loadSolidersAnimation,
    unLoadSolidersAnimation = unLoadSolidersAnimation,
    loadPveAnimation = loadPveAnimation,
    unLoadPveAnimation = unLoadPveAnimation,
    loadDragonAnimation = loadDragonAnimation,
    unLoadDragonAnimation = unLoadDragonAnimation,
    iap_package_image = IAP_PACKAGE_IMAGE,
    produc_tiontechs_image = PRODUC_TIONTECHS_IMAGE,
    getDragonEquipmentImage = GET_DRAGON_EQUIPMENT_IMAGE,
}




