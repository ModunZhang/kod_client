local UIPushButton = cc.ui.UIPushButton
local WidgetPushButton = import(".WidgetPushButton")
local WidgetSoldierBox = class("WidgetSoldierBox", function()
    return display.newNode()
end)
local NORMAL = GameDatas.UnitsConfig.normal
local SPECIAL = GameDatas.UnitsConfig.special
local STAR_BG = {
    "star1_118x132.png",
    "star2_118x132.png",
    "star3_118x132.png",
    "star4_118x132.png",
    "star5_118x132.png",
}
local SOLDIER_TYPE = {
    ["swordsman_1"] = { png = "#Infantry_1_render/idle/1/00000.png" },
    ["swordsman_2"] = { png = "soldier_swordsman_2.png" },
    ["swordsman_3"] = { png = "soldier_swordsman_3.png" },
    ["sentinel_1"] = { png = "soldier_sentinel_1.png" },
    ["sentinel_2"] = { png = "soldier_sentinel_2.png" },
    ["sentinel_3"] = { png = "soldier_sentinel_3.png" },
    ["archer_1"] = { png = "#Archer_1_render/idle/1/00000.png" },
    ["archer_2"] = { png = "soldier_archer_2.png" },
    ["archer_3"] = { png = "soldier_archer_3.png" },
    ["crossbowman_1"] = { png = "soldier_crossbowman_1.png" },
    ["crossbowman_2"] = { png = "soldier_crossbowman_2.png" },
    ["crossbowman_3"] = { png = "soldier_crossbowman_2.png" },
    ["lancer_1"] = { png = "#Cavalry_1_render/idle/1/00000.png" },
    ["lancer_2"] = { png = "soldier_lancer_2.png" },
    ["lancer_3"] = { png = "soldier_lancer_3.png" },
    ["horseArcher_1"] = { png = "soldier_horseArcher_1.png" },
    ["horseArcher_2"] = { png = "soldier_horseArcher_2.png" },
    ["horseArcher_3"] = { png = "soldier_horseArcher_3.png" },
    ["catapult_1"] = { png = "#Catapult_1_render/move/1/00000.png" },
    ["catapult_2"] = { png = "soldier_catapult_2.png" },
    ["catapult_3"] = { png = "soldier_catapult_3.png" },
    ["ballista_1"] = { png = "soldier_ballista_1.png" },
    ["ballista_2"] = { png = "soldier_ballista_2.png" },
    ["ballista_3"] = { png = "soldier_ballista_3.png" },
    ["skeletonWarrior"] = { png = "soldier_skeletonWarrior.png" },
    ["skeletonArcher"] = { png = "soldier_skeletonArcher.png" },
    ["deathKnight"] = { png = "soldier_deathKnight.png" },
    ["meatWagon"] = { png = "soldier_meatWagon.png" },
-- ["priest"] = {},
-- ["demonHunter"] = {},
-- ["paladin"] = {},
-- ["steamTank"] = {},
}

local LOAD_FILES = {
    {"animations/Archer_1_render0.plist","animations/Archer_1_render0.png"},
    {"animations/Catapult_1_render0.plist","animations/Catapult_1_render0.png"},
    {"animations/Cavalry_1_render0.plist","animations/Cavalry_1_render0.png"},
    {"animations/Infantry_1_render0.plist","animations/Infantry_1_render0.png"},
}


function WidgetSoldierBox:ctor(soldier_png, cb)
    self:LoadSpriteFrames()
    self.soldier_bg = WidgetPushButton.new({normal = "star1_114x128.png",
        pressed = "star1_114x128.png"}):addTo(self)
        :onButtonClicked(cb)

    local rect = self.soldier_bg:getCascadeBoundingBox()

    local number_bg = cc.ui.UIImage.new("number_bg_116x46.png"):addTo(self)
        :align(display.CENTER, 0, - rect.height / 2 -5)

    local size = number_bg:getContentSize()
    self.number = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x423f32)
    }):addTo(number_bg):align(display.CENTER, size.width / 2, size.height / 2)
end
function WidgetSoldierBox:LoadSpriteFrames()
    for k,v in pairs(LOAD_FILES) do
        display.addSpriteFrames(v[1],v[2])
    end
end
function WidgetSoldierBox:SetSoldier(soldier_type, star)
    local soldier_type_with_star = soldier_type..(star == nil and "" or string.format("_%d", star))
    local soldier_ui_config = SOLDIER_TYPE[soldier_type_with_star]
    if soldier_ui_config then
        local bg = STAR_BG[star]
        self.soldier_bg:setButtonImage(UIPushButton.NORMAL, bg, true)
        self.soldier_bg:setButtonImage(UIPushButton.PRESSED, bg, true)
        if self.soldier then
            self.soldier_bg:removeChild(self.soldier)
        end
        self.soldier = display.newSprite(soldier_ui_config.png):addTo(self.soldier_bg)
        :align(display.CENTER, 0, 10)
        self.soldier:scale(130/self.soldier:getContentSize().height)
    end
    return self
end
function WidgetSoldierBox:SetNumber(number)
    self.number:setString(number)
    return self
end
function WidgetSoldierBox:align(anchorPoint, x, y)
    self.soldier_bg:align(anchorPoint)
    if x and y then self:setPosition(x, y) end
    return self
end
function WidgetSoldierBox:alignByPoint(point, x, y)
    self.soldier_bg:setAnchorPoint(point)
    if x and y then self:setPosition(x, y) end
    return self
end
function WidgetSoldierBox:SetButtonListener( cb )
    self.soldier_bg:removeAllEventListeners()
    self.soldier_bg:onButtonClicked(cb)
end

return WidgetSoldierBox










