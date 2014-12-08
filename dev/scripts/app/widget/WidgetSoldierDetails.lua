local UIListView = import('..ui.UIListView')
local WidgetSlider = import('.WidgetSlider')
local UILib = import("..ui.UILib")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")

local normal = GameDatas.UnitsConfig.normal
local special = GameDatas.UnitsConfig.special
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
    ["meatWagon"] = { png = "meatWagon.png" },
    ["priest"] = {},
    ["demonHunter"] = {},
    ["paladin"] = {},
    ["steamTank"] = {},
}

local WidgetSoldierDetails = class("WidgetSoldierDetails", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function WidgetSoldierDetails:ctor(soldier_type,soldier_level)
    self.soldier_type = soldier_type
    self.soldier_level = soldier_level
    -- 取得对应士兵配置表
    self.s_config = soldier_level and normal[soldier_type.."_"..soldier_level]
        or special[soldier_type]
        LuaUtils:outputTable("self.s_config", self.s_config)
    self:InitSoldierDetails()
end

function WidgetSoldierDetails:InitSoldierDetails()
    -- 士兵信息配置表
    local sc = self.s_config

    -- bg
    local bg = display.newScale9Sprite("full_screen_dialog_bg.png", display.cx, display.top-480,cc.size(610,675)):addTo(self)
    local bg_width,bg_height = bg:getContentSize().width,bg:getContentSize().height
    -- title bg
    display.newSprite("Title_blue.png", bg_width/2,bg_height-30):addTo(bg,2)
    -- soldier_name label
    self.soldier_name_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = Localize.soldier_name[string.sub(sc.name, 1, -3)],
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER,180,bg_height-30):addTo(bg,2)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent(true)
        end):align(display.CENTER, bg_width-20, bg_height-20):addTo(bg,2)
    -- 士兵头像
    local stars_bg = display.newSprite("soldier_head_stars_bg.png", display.cx-170, display.top-185):addTo(self)
    local soldier_head_bg  = display.newSprite(STAR_BG[self.soldier_level], display.cx-230, display.top-185):addTo(self)

    local soldier_type_with_star = self.soldier_type..(self.soldier_level == nil and "" or string.format("_%d", self.soldier_level))
    local soldier_ui_config = UILib.soldier_image[self.soldier_type][self.soldier_level]
    

    local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.LEFT_BOTTOM,0,10)
    soldier_head_icon:scale(130/soldier_head_icon:getContentSize().height)
    -- soldier_head_icon:setScale(0.7)
    soldier_head_bg:addChild(soldier_head_icon)

    -- 士兵星级，特殊兵种无星级
    local soldier_stars = self.soldier_level
    if soldier_stars then
        local gap_y = 25
        for i=1,5 do
            stars_bg:addChild(display.newSprite("soldier_stars_bg.png", 38, 15+gap_y*(i-1)))
            if soldier_stars>0 then
                stars_bg:addChild(display.newSprite("soldier_stars.png", 38, 15+gap_y*(i-1)))
                soldier_stars = soldier_stars-1
            end
        end
    end

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("数量"),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x5a5544)
    }):align(display.LEFT_CENTER,180,bg_height-70):addTo(bg,2)

    self.total_soldier = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = City:GetSoldierManager():GetCountBySoldierType(self.soldier_type),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x5a5544)
    }):align(display.LEFT_CENTER,180,bg_height-96):addTo(bg,2)

    -- 调整解散士兵数量silder
    self:CreateDismissSoldierSilder()
    -- 士兵属性
    self:InitSoldierAttr()
end

function WidgetSoldierDetails:CreateDismissSoldierSilder()
    display.newSprite("dismiss_soldier_bg.png", display.cx + 233, display.top - 280):addTo(self)
    local dismiss_value = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("0"),
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x000000)})
        :align(display.CENTER, display.cx + 235, display.top - 282)
        :addTo(self)
    -- 士兵总数
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("/ "..City:GetSoldierManager():GetCountBySoldierType(self.soldier_type)),
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)})
        :align(display.CENTER, display.cx + 230, display.top - 310)
        :addTo(self)
    -- 返还城民
    -- icon
    display.newSprite("population.png", display.cx-255, display.top-370):addTo(self)
    local citizen_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("0"),
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)})
        :align(display.CENTER, display.cx - 215, display.top - 378)
        :addTo(self)
    -- sliderbar
    WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
        progress = "slider_progress_445x14.png",
        button = "slider_btn_66x66.png"},{max = City:GetSoldierManager():GetCountBySoldierType(self.soldier_type)}):addTo(self)
        :align(display.LEFT_BOTTOM, display.cx - 280, display.top - 310)
        :onSliderValueChanged(function(event)
            dismiss_value:setString(string.format("%d", math.floor(event.value)))
            citizen_label:setString(string.format("%d", math.floor(event.value)*self.s_config.citizen))
        end)
        :setSliderValue(0)
 
    local dismiss_soldier_button = WidgetPushButton.new({normal = "resource_butter_red.png",pressed = "resource_butter_red_highlight.png"},{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("解散"), size = 24, color = display.COLOR_WHITE}))
        :onButtonClicked(function(event)
            print("解散士兵 =================")
        end):align(display.CENTER, display.cx + 205, display.top-370):addTo(self)
        :setButtonEnabled(false)

end

function WidgetSoldierDetails:InitSoldierAttr()
    local sc = self.s_config
    -- bg
    local bg = display.newSprite("back_ground_549X379.png", display.cx, display.top-600):addTo(self)
    -- upgrade_resources_background_3
    local function createAttrItem(name,value,bg_image)
        -- bg
        local attr_item = display.newSprite(bg_image)
        local width,height = attr_item:getContentSize().width,attr_item:getContentSize().height
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = name,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x615b44)})
            :align(display.LEFT_CENTER, 10, 20)
            :addTo(attr_item)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)})
            :align(display.CENTER_RIGHT, width-10, 20)
            :addTo(attr_item)
        return attr_item
    end
    local  attr_table = {
        {
            name = _("对步兵攻击"),
            value = sc.infantry..""
        },
        {
            name = _("对弓箭手攻击"),
            value = sc.archer..""
        },
        {
            name = _("对骑兵攻击"),
            value = sc.cavalry..""
        },
        {
            name = _("对投石车攻击"),
            value = sc.siege..""
        },
        {
            name = _("对城墙攻击"),
            value = sc.wall..""
        },
        {
            name = _("生命值"),
            value = sc.hp..""
        },
        {
            name = _("人口"),
            value = sc.citizen..""
        },
        {
            name = _("维护费"),
            value = sc.consumeFood..""
        },
    }

    self.attr_listview = UIListView.new{
        -- bg = "common_tips_bg.png",
        -- bgColor = cc.c4b(200, 200, 200, 120),
        bgScale9 = true,
        viewRect = cc.rect(1, 0, 547, 377),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(bg,2)
    local bg_flag = true
    for k,v in pairs(attr_table) do
        print("==============================",k,v.name)
        local item = self.attr_listview:newItem()
        item:setItemSize(547,47)
        if bg_flag then
            --todo
            item:addContent(createAttrItem(v.name,v.value,"upgrade_resources_background_3.png"))
            bg_flag = false

        else
            item:addContent(createAttrItem(v.name,v.value,"upgrade_resources_background_2.png"))
            bg_flag = true
        end
        self.attr_listview:addItem(item)
    end
    self.attr_listview:reload()
end

return WidgetSoldierDetails

