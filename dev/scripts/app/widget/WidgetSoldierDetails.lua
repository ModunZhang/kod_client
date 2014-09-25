local UIListView = import('..ui.UIListView')
local WidgetSlider = import('.WidgetSlider')

local normal = GameDatas.UnitsConfig.normal
local special = GameDatas.UnitsConfig.special



local WidgetSoldierDetails = class("WidgetSoldierDetails", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function WidgetSoldierDetails:ctor(soldier_type,soldier_level)
    self.soldier_type = soldier_type
    self.soldier_level = soldier_level
    -- 取得对应士兵配置表
    self.s_config = soldier_level and normal[soldier_type.."_"..soldier_level]
        or special[soldier_type]
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
        text = _(sc.description),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER,180,bg_height-30):addTo(bg,2)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent(true)
        end):align(display.CENTER, bg_width-20, bg_height-20):addTo(bg,2):addChild(display.newSprite("X_3.png"))
    -- 士兵头像
    local stars_bg = display.newSprite("soldier_head_stars_bg.png", display.cx-170, display.top-185):addTo(self)
    local soldier_head_bg  = display.newSprite("soldier_blue_box.png", display.cx-230, display.top-185):addTo(self)
    local soldier_head_image = self.soldier_level and "soldier_"..self.soldier_type.."_"..self.soldier_level..".png"
        or "soldier_"..self.soldier_type..".png"

    local soldier_head_icon = display.newSprite(soldier_head_image):align(display.LEFT_BOTTOM,10,10)
    soldier_head_icon:setScale(0.7)
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
            dismiss_value:setString(string.format("%d", event.value))
            dismiss_value:setString(string.format("%d", event.value*self.s_config.citizen))
        end)
        :setSliderValue(0)
 
    cc.ui.UIPushButton.new({normal = "resource_butter_red.png",pressed = "resource_butter_red_highlight.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("解散"), size = 24, color = display.COLOR_WHITE}))
        :onButtonClicked(function(event)
            print("解散士兵 =================")
        end):align(display.CENTER, display.cx + 205, display.top-370):addTo(self)

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
            value = sc.atkInfs..""
        },
        {
            name = _("对弓箭手攻击"),
            value = sc.atkHunter..""
        },
        {
            name = _("对骑兵攻击"),
            value = sc.atkCavalry..""
        },
        {
            name = _("对投石车攻击"),
            value = sc.atkSiege..""
        },
        {
            name = _("对城墙攻击"),
            value = sc.atkWall..""
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
            value = sc.upkeep..""
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

