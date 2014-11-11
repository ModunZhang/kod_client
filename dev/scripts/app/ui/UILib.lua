local STAR_BG = {
    "star1_118x132.png",
    "star2_118x132.png",
    "star3_118x132.png",
    "star4_118x132.png",
    "star5_118x132.png",
}
local SOLDIER_EFFECT_ANIMATIONS = {
    ranger = {
        "Swordsman_effects",
        "Swordsman_effects",
        "Swordsman_effects",
    },
    catapult = {
        "Catapult1effects",
        "Catapult1effects",
        "Catapult1effects",
    },
    lancer = {
        "Lancer_effects",
        "Lancer_effects",
        "Lancer_effects",
    },
    swordsman = {
        "Swordsman_effects",
        "Swordsman_effects",
        "Swordsman_effects",
    },
    wall = {
        "Swordsman_effects",
        "Swordsman_effects",
        "Swordsman_effects",
    }
}
local SOLDIER_ANIMATIONS = {
    ranger = {
        "Archer_1_render",
        "Archer_1_render",
        "Archer_1_render",
    },
    catapult = {
        "Catapult_1_render",
        "Catapult_1_render",
        "Catapult_1_render",
    },
    lancer = {
        "Cavalry_1_render",
        "Cavalry_1_render",
        "Cavalry_1_render",
    },
    swordsman = {
        "Infantry_1_render",
        "Infantry_1_render",
        "Infantry_1_render",
    },
    wall = {
        "chengqiang_1",
        "chengqiang_1",
        "chengqiang_1",
    }
}
local EFFECT_ANIMATION_FILES = {
    ranger = {
        "animations/swordsman_effect/Swordsman_effects.ExportJson",
    },
    catapult = {
        "animations/catapult_effect/Catapult1effects.ExportJson",
    },
    lancer = {
        "animations/lancer_effect/Lancer_effects.ExportJson",
    },
    swordsman = {
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
    catapult = {
        "animations/Catapult_1_render.ExportJson",
        "animations/Catapult_1_render.ExportJson",
        "animations/Catapult_1_render.ExportJson",
    },
    lancer = {
        "animations/Cavalry_1_render.ExportJson",
        "animations/Cavalry_1_render.ExportJson",
        "animations/Cavalry_1_render.ExportJson",
    },
    swordsman = {
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

return {
    soldier_bg = STAR_BG,
    soldier = SOLDIER_TYPE,
    soldier_effect = SOLDIER_EFFECT_ANIMATIONS,
    effect_animation_files = EFFECT_ANIMATION_FILES,
    soldier_animation_files = SOLDIER_ANIMATION_FILES,
    soldier_animation = SOLDIER_ANIMATIONS,
    soldier_image = SOLDIER_IMAGES
}







