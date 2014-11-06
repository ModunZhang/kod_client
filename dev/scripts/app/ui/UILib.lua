local STAR_BG = {
    "star1_118x132.png",
    "star2_118x132.png",
    "star3_118x132.png",
    "star4_118x132.png",
    "star5_118x132.png",
}
local SOLDIER_ANIMATIONS = {
    ranger = {
        "Archer_1_render",
    },
    catapult = {
        "Catapult_1_render",
    },
    lancer = {
        "Cavalry_1_render",
    },
    swordsman = {
        "Infantry_1_render",
    },
    wall = {
        "chengqiang_1",
    }
}
local SOLDIER_ANIMATION_FILES = {
    ranger = {
        "animations/Archer_1_render.ExportJson",
    },
    catapult = {
        "animations/Catapult_1_render.ExportJson",
    },
    lancer = {
        "animations/Cavalry_1_render.ExportJson",
    },
    swordsman = {
        "animations/Infantry_1_render.ExportJson",
    },
    wall = {
        "animations/chengqiang_1.ExportJson",
    }
}
local SOLDIER_IMAGES = {
    ranger = {
        "#Archer_1_render/idle/1/00000.png",
    },
    catapult = {
        "#Catapult_1_render/move/1/00000.png",
    },
    lancer = {
        "#Cavalry_1_render/idle/1/00000.png",
    },
    swordsman = {
        "#Infantry_1_render/idle/1/00000.png",
    }
}

return {
    soldier_bg = STAR_BG,
    soldier = SOLDIER_TYPE,
    soldier_animation_files = SOLDIER_ANIMATION_FILES,
    soldier_animation = SOLDIER_ANIMATIONS,
    soldier_image = SOLDIER_IMAGES
}



