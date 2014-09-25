local GameUtils = GameUtils
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSlider = import("..widget.WidgetSlider")
local WidgetSoldierDetails = import('..widget.WidgetSoldierDetails')
local WidgetRecruitSoldier = class("WidgetRecruitSoldier", function(...)
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            node:blank_clicked()
        end
        return true
    end)
    return node
end)
local NORMAL = GameDatas.UnitsConfig.normal
local SPECIAL = GameDatas.UnitsConfig.special
local STAR_BG = {
    "star1_114x128.png",
    "star2_114x128.png",
    "star3_114x128.png",
    "star4_114x128.png",
}
local SOLDIER_TYPE = {
    ["swordsman_1"] = { png = "soldier_swordsman_1.png" },
    ["swordsman_2"] = { png = "soldier_swordsman_2.png" },
    ["swordsman_3"] = { png = "soldier_swordsman_3.png" },
    ["sentinel_1"] = { png = "soldier_sentinel_1.png" },
    ["sentinel_2"] = { png = "soldier_sentinel_2.png" },
    ["sentinel_3"] = { png = "soldier_sentinel_3.png" },
    ["archer_1"] = { png = "soldier_archer_1.png" },
    ["archer_2"] = { png = "soldier_archer_2.png" },
    ["archer_3"] = { png = "soldier_archer_3.png" },
    ["crossbowman_1"] = { png = "soldier_crossbowman_1.png" },
    ["crossbowman_2"] = { png = "soldier_crossbowman_2.png" },
    ["crossbowman_3"] = { png = "soldier_crossbowman_2.png" },
    ["lancer_1"] = { png = "soldier_lancer_1.png" },
    ["lancer_2"] = { png = "soldier_lancer_2.png" },
    ["lancer_3"] = { png = "soldier_lancer_3.png" },
    ["horseArcher_1"] = { png = "soldier_horseArcher_1.png" },
    ["horseArcher_2"] = { png = "soldier_horseArcher_2.png" },
    ["horseArcher_3"] = { png = "soldier_horseArcher_3.png" },
    ["catapult_1"] = { png = "soldier_catapult_1.png" },
    ["catapult_2"] = { png = "soldier_catapult_2.png" },
    ["catapult_3"] = { png = "soldier_catapult_3.png" },
    ["ballista_1"] = { png = "soldier_ballista_1.png" },
    ["ballista_2"] = { png = "soldier_ballista_2.png" },
    ["ballista_3"] = { png = "soldier_ballista_3.png" },
    ["skeletonWarrior"] = { png = "soldier_skeletonWarrior.png" },
    ["skeletonArcher"] = { png = "soldier_skeletonArcher.png" },
    ["deathKnight"] = { png = "soldier_deathKnight.png" },
    ["meatWagon"] = { png = "meatWagon.png" },
    ["priest"] = {},
    ["demonHunter"] = {},
    ["paladin"] = {},
    ["steamTank"] = {},
}
local SOLDIER_CATEGORY_MAP = {
    ["swordsman"] = "infantry",
    ["sentinel"] = "infantry",

    ["archer"] = "archer",
    ["crossbowman"] = "archer",

    ["lancer"] = "cavalry",
    ["horseArcher"] = "cavalry",

    ["catapult"] = "siege",
    ["ballista"] = "siege",
}
local SOLDIER_VS_MAP = {
    ["infantry"] = {
        strong_vs = { "siege", "wall" },
        weak_vs = { "cavalry", "archer" }
    },
    ["archer"] = {
        strong_vs = { "cavalry", "infantry" },
        weak_vs = { "wall", "siege" }
    },
    ["cavalry"] = {
        strong_vs = { "infantry", "siege" },
        weak_vs = { "archer", "wall" }
    },
    ["siege"] = {
        strong_vs = { "wall", "archer" },
        weak_vs = { "infantry", "cavalry" }
    },
    ["wall"] = {
        strong_vs = { "archer", "cavalry" },
        weak_vs = { "siege", "infantry"}
    }
}
local SOLDIER_LOCALIZE_MAP = {
    ["infantry"] = _("步兵"),
    ["archer"] = _("弓手"),
    ["cavalry"] = _("骑兵"),
    ["siege"] = _("攻城"),
    ["wall"] = _("城墙"),
}

local function return_vs_soldiers_map(soldier_type)
    return SOLDIER_VS_MAP[SOLDIER_CATEGORY_MAP[soldier_type]]
end


function WidgetRecruitSoldier:ctor(soldier_type, star, recruit_max)
    self.soldier_type = soldier_type
    self.recruit_max = recruit_max

    local label_origin_x = 190
    -- bg
    local back_ground = cc.ui.UIImage.new("back_ground_608x458.png",
        {scale9 = true}):addTo(self):setLayoutSize(608, 500)
    back_ground:setTouchEnabled(true)

    -- title
    local size = back_ground:getContentSize()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width/2, size.height - 49/2)

    -- title label
    local size = title_blue:getContentSize()
    self.title = cc.ui.UILabel.new({
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue)
        :align(display.LEFT_CENTER, label_origin_x, size.height/2)


    -- info
    cc.ui.UIPushButton.new({normal = "info_16x33.png",
        pressed = "info_16x33.png"}):addTo(title_blue)
        :align(display.LEFT_CENTER, title_blue:getContentSize().width - 30, size.height/2)
        :onButtonClicked(function(event)
            WidgetSoldierDetails.new(soldier_type, 1):addTo(self)
        end)

    -- soldier bg
    local size = back_ground:getContentSize()
    local width, height = 140, 130
    local soldier_bg = cc.ui.UIImage.new("back_ground_54x127.png",
        {scale9 = true}):addTo(back_ground, 2)
        :align(display.CENTER, 100, size.height - 50)
        :setLayoutSize(width, height)

    -- stars
    self.stars = {}
    local origin_x, origin_y, gap_y = width - 15, 15, 25
    for i = 1, 5 do
        local bg = cc.ui.UIImage.new("star_bg_24x23.png"):addTo(soldier_bg, 2)
            :align(display.CENTER, origin_x, origin_y + (i - 1) * gap_y)

        local pos = bg:getAnchorPointInPoints()
        local star = cc.ui.UIImage.new("star_18x16.png"):addTo(bg)
            :align(display.CENTER, pos.x, pos.y)
        table.insert(self.stars, star)
    end


    -- star_bg
    local size = soldier_bg:getContentSize()
    local star_bg = cc.ui.UIImage.new("star1_114x128.png"):addTo(soldier_bg, 2)
        :align(display.CENTER, 55, size.height/2)
    self.star_bg = star_bg

    -- soldier type
    local pos = star_bg:getAnchorPointInPoints()
    local soldier = cc.ui.UIImage.new("soldier_130x183.png"):addTo(star_bg)
        :align(display.CENTER, pos.x, pos.y + 5):scale(0.7)
    self.soldier = soldier


    --
    local size = back_ground:getContentSize()
    local label = cc.ui.UILabel.new({
        text = "强势对抗",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x5bb800)
    }):addTo(back_ground, 2)
        :align(display.LEFT_BOTTOM, label_origin_x, size.height - 65 - 11)

    local vs_map = return_vs_soldiers_map(soldier_type)
    local strong_vs = {}
    for i, v in ipairs(vs_map.strong_vs) do
        table.insert(strong_vs, SOLDIER_LOCALIZE_MAP[v])
    end
    local soldier_name = cc.ui.UILabel.new({
        text = table.concat(strong_vs, ", "),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, label_origin_x + label:getContentSize().width, size.height - 65)

    local label = cc.ui.UILabel.new({
        text = "弱势对抗",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x890000)
    }):addTo(back_ground, 2)
        :align(display.LEFT_BOTTOM, label_origin_x, size.height - 100 - 11)

    local weak_vs = {}
    for i, v in ipairs(vs_map.weak_vs) do
        table.insert(weak_vs, SOLDIER_LOCALIZE_MAP[v])
    end
    local soldier_name = cc.ui.UILabel.new({
        text = table.concat(weak_vs, ", "),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, label_origin_x + label:getContentSize().width, size.height - 100)


    -- food icon
    cc.ui.UIImage.new("res_food_114x100.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 130, size.height - 90):scale(0.5)

    cc.ui.UILabel.new({
        text = _("维护费"),
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x7f775f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, size.width - 100, size.height - 70)

    -- upkeep
    self.upkeep = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, size.width - 100, size.height - 100)

    -- progress
    local slider_height, label_height = size.height - 170, size.height - 150
    local slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
        progress = "slider_progress_445x14.png",
        button = "slider_btn_66x66.png"}, {max = recruit_max}):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 25, slider_height)
        :onSliderValueChanged(function(event)
            self:OnCountChanged(math.floor(event.value))
        end)


    -- soldier count bg
    local bg = cc.ui.UIImage.new("back_ground_83x32.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 70, label_height)

    -- soldier current
    local pos = bg:getAnchorPointInPoints()
    self.soldier_current_count = cc.ui.UILabel.new({
        text = "0",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(bg, 2)
        :align(display.CENTER, pos.x, pos.y)

    -- soldier total count
    self.soldier_total_count = cc.ui.UILabel.new({
        text = string.format("/ %d", recruit_max),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 70, label_height - 35)


    -- need bg
    local need = cc.ui.UIImage.new("back_ground_583x107.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width/2, size.height/2 - 30)

    -- needs
    local size = need:getContentSize()
    local margin_x = 80
    local length = size.width - margin_x * 2
    local origin_x, origin_y, gap_x = margin_x, 30, length / 4
    local res_map = {
        { "food", "res_food_114x100.png" },
        { "wood", "res_wood_114x100.png" },
        { "iron", "res_iron_114x100.png" },
        { "stone", "res_stone_128x128.png" },
        { "citizen", "res_citizen_44x50.png" },
    }
    self.res_map = {}
    for i, v in pairs(res_map) do
        local res_type = v[1]
        local png = v[2]
        local x = origin_x + (i - 1) * gap_x
        local scale = i == #res_map and 1 or 0.4
        cc.ui.UIImage.new(png):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y):scale(scale)

        local total = cc.ui.UILabel.new({
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y - 40)

        local need = cc.ui.UILabel.new({
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0x403c2f)
        -- color = display.COLOR_RED
        }):addTo(need, 2)
            :align(display.CENTER, x, size.height - origin_y - 60)

        self.res_map[res_type] = { total = total, need = need }
    end

    -- 立即招募
    local size = back_ground:getContentSize()
    local instant_button = cc.ui.UIPushButton.new(
        {normal = "green_btn_up_250x65.png",pressed = "green_btn_down_250x65.png"})
        :addTo(back_ground, 2)
        :align(display.CENTER, 160, 120)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("立即招募"),
            size = 24,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            DataUtils:buyResource({
                }, {})
            NetManager:instantRecruitNormalSoldier(self.soldier_type, self.count, NOT_HANDLE)
            self:instant_button_clicked()
        end)

    -- gem
    cc.ui.UIImage.new("gem_66x56.png"):addTo(instant_button, 2)
        :align(display.CENTER, -100, -50):scale(0.5)

    -- gem count
    self.gem_label = cc.ui.UILabel.new({
        text = "600",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(instant_button, 2)
        :align(display.LEFT_CENTER, -100 + 20, -50)


    -- 招募
    local button = cc.ui.UIPushButton.new(
        {normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"})
        :addTo(back_ground, 2)
        :align(display.CENTER, size.width - 120, 120)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("招募"),
            size = 27,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            NetManager:recruitNormalSoldier(self.soldier_type, self.count, NOT_HANDLE)
            -- self:SetSoldier(soldier_type, 3)
            -- self:OnCountChanged(self.count)
            -- slider:Max(100)
            -- self.soldier_total_count:setString(string.format("/ %d", 100))
            self:button_clicked()
        end)

    -- 时间glass
    cc.ui.UIImage.new("hourglass_39x46.png"):addTo(button, 2)
        :align(display.LEFT_CENTER, -90, -55):scale(0.7)

    -- 时间
    local center = -20
    self.recruit_time = cc.ui.UILabel.new({
        -- text = "20:20:20",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(button, 2)
        :align(display.CENTER, center, -50)

    cc.ui.UILabel.new({
        text = "-(20:20:20)",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x068329)
    }):addTo(button, 2)
        :align(display.CENTER, center, -70)

    self.back_ground = back_ground

    self:SetSoldier(soldier_type, star)
    self:OnCountChanged(0)
end
function WidgetRecruitSoldier:SetSoldier(soldier_type, star)
    local soldier_config, soldier_ui_config = self:GetConfigBySoldierTypeAndStar(soldier_type, star)
    -- title
    self.title:setString(_(soldier_config.description))
    -- bg
    self.star_bg:setTexture(display.newSprite(STAR_BG[star]):getTexture())
    -- soldier
    self.soldier:setTexture(display.newSprite(soldier_ui_config.png):getTexture())
    -- stars
    local star = soldier_config.star
    for i, v in ipairs(self.stars) do
        v:setVisible(i <= star)
    end

    self.soldier_config = soldier_config
    self.soldier_ui_config = soldier_ui_config
    return self
end
function WidgetRecruitSoldier:GetConfigBySoldierTypeAndStar(soldier_type, star)
    local soldier_type_with_star = soldier_type..(star == nil and "" or string.format("_%d", star))
    local soldier_config = NORMAL[soldier_type_with_star] == nil and SPECIAL[soldier_type] or NORMAL[soldier_type_with_star]
    local soldier_ui_config = SOLDIER_TYPE[soldier_type_with_star]
    return soldier_config, soldier_ui_config
end
function WidgetRecruitSoldier:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint, x, y)
    return self
end
local app = app
local timer = app.timer
function WidgetRecruitSoldier:OnResourceChanged(resource_manager)
    local server_time = timer:GetServerTime()
    local res_map = {}
    res_map.wood = resource_manager:GetWoodResource():GetResourceValueByCurrentTime(server_time)
    res_map.food = resource_manager:GetFoodResource():GetResourceValueByCurrentTime(server_time)
    res_map.iron = resource_manager:GetIronResource():GetResourceValueByCurrentTime(server_time)
    res_map.stone = resource_manager:GetStoneResource():GetResourceValueByCurrentTime(server_time)
    res_map.citizen = resource_manager:GetPopulationResource():GetNoneAllocatedByTime(server_time)
    for k, v in pairs(self.res_map) do
        local total = res_map[k]
        v.total:setString(GameUtils:formatNumber(total))
    end
    self.res_total_map = res_map
end
function WidgetRecruitSoldier:OnInstantButtonClicked(func)
    self.instant_button_clicked = func
    return self
end
function WidgetRecruitSoldier:OnNormalButtonClicked(func)
    self.button_clicked = func
    return self
end
function WidgetRecruitSoldier:OnBlankClicked(func)
    self.blank_clicked = func
    return self
end
function WidgetRecruitSoldier:OnCountChanged(count)
    local soldier_config = self.soldier_config
    local soldier_ui_config = self.soldier_ui_config
    local total_time = soldier_config.recruitTime * count
    self.soldier_current_count:setString(string.format("%d", count))
    self.upkeep:setString(string.format("%s%d", count > 0 and "-" or "", soldier_config.upkeep * count))
    self.recruit_time:setString(GameUtils:formatTimeStyle1(total_time))

    local total_map = self.res_total_map == nil and {} or self.res_total_map
    local current_res_map = {}
    for k, v in pairs(self.res_map) do
        local total = total_map[k] == nil and 0 or total_map[k]
        local current = soldier_config[k] * count
        current_res_map[k] = current
        local color = total >= current and UIKit:hex2c3b(0x403c2f) or display.COLOR_RED
        v.need:setString(string.format("/ %s", GameUtils:formatNumber(current)))
        v.total:setColor(color)
        v.need:setColor(color)
    end
    self.count = count
    self.gem_label:setString(DataUtils:buyResource(current_res_map, {}) + DataUtils:getGemByTimeInterval(total_time))
end
return WidgetRecruitSoldier




















