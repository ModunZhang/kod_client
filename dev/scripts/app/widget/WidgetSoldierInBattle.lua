local Localize = import("..utils.Localize")
local UILib = import("..ui.UILib")
local UIImage = cc.ui.UIImage
local WidgetSoldierInBattle = class("WidgetSoldierInBattle", UIImage)

local normal = GameDatas.Soldiers.normal
local special = GameDatas.Soldiers.special


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
}


function WidgetSoldierInBattle:ctor(filename, options)
    WidgetSoldierInBattle.super.ctor(self, filename, options)
    self.soldier_name = options.soldier
    local pos = {x = 284/2,y = 128/2}
    local is_pve_battle = options.is_pve_battle
    local soldier_star 
    local soldier_scale = 0.8
    local frame_scale = 0.8
    if self.soldier_name == "wall" then
        soldier_star, soldier_scale = 1, 0.5
    else
        local config = special[self.soldier_name] or normal[self.soldier_name.."_"..options.star]
        soldier_star = config.star
    end
    local soldier_ui_config = is_pve_battle and BLACK_SOLDIER_IMAGES or UILib.soldier_image
    local soldier_ui = soldier_ui_config[self.soldier_name][soldier_star]

    self.soldier = display.newSprite(soldier_ui, nil, nil, {class=cc.FilteredSpriteWithOne})
    :addTo(self):align(display.CENTER, 55, pos.y):scale(soldier_scale)

    local size = self.soldier:getContentSize()
    display.newSprite("box_soldier_128x128.png")
    :align(display.CENTER, 55, pos.y):addTo(self)
    :scale(frame_scale)

    if options.side == "blue" then
        cc.ui.UIImage.new("title_blue_166x30.png")
            :addTo(self):align(display.LEFT_CENTER, 110, 105)
    elseif options.side == "red" then
        cc.ui.UIImage.new("title_red_166x30.png")
            :addTo(self):align(display.LEFT_CENTER, 110, 105)
    else
        assert(false, "只有两边!")
    end

    cc.ui.UILabel.new({
        text = Localize.soldier_name[options.soldier],
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0xebdba0)
    }):addTo(self):align(display.LEFT_CENTER, 120, 105)


    cc.ui.UIImage.new("back_ground_166x84.png")
        :addTo(self):align(display.LEFT_CENTER, 110, 45)

    self.name = cc.ui.UILabel.new({
        text = Localize.getSoldierCategoryByName(options.soldier),
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(self):align(display.LEFT_CENTER, 120, 65)

    self.status = cc.ui.UILabel.new({
        font = UIKit:getFontFilePath(),
        size = 22,
    }):addTo(self):align(display.LEFT_CENTER, 120, 30)


    self:SetUnitStatus("waiting")
end
function WidgetSoldierInBattle:SetUnitStatus(status)
    if status == "waiting" then
        self.status:setColor(UIKit:hex2c3b(0x403c2f))
        -- self.soldier_bg:clearFilter()
        self.soldier:clearFilter()
    elseif status == "fighting" then
        self.status:setColor(UIKit:hex2c3b(0x007c23))
        -- self.soldier_bg:clearFilter()
        self.soldier:clearFilter()
    elseif status == "defeated" then
        self.status:setColor(UIKit:hex2c3b(0x7e0000))
        local filter = filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1})
        -- self.soldier_bg:setFilter(filter)
        self.soldier:setFilter(filter)
    else
        assert(false, "没有状态!")
    end
    self.status:setString(Localize.soldier_status[status])
    return self
end
function WidgetSoldierInBattle:GetSoldierName()
    return self.soldier_name
end

return WidgetSoldierInBattle










