local UIListView = import('..ui.UIListView')
local WidgetSlider = import('.WidgetSlider')
local UILib = import("..ui.UILib")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSliderWithInput = import("..widget.WidgetSliderWithInput")
local WidgetInfoBuff = import("..widget.WidgetInfoBuff")
local window = import("..utils.window")
local UIAutoClose = import("..ui.UIAutoClose")



local normal = GameDatas.Soldiers.normal
local special = GameDatas.Soldiers.special
local STAR_BG = {
    "star1_118x132.png",
    "star2_118x132.png",
    "star3_118x132.png",
    "star4_118x132.png",
    "star5_118x132.png",
}


local WidgetSoldierDetails = class("WidgetSoldierDetails", UIAutoClose)

function WidgetSoldierDetails:ctor(soldier_type,soldier_level)
    self.soldier_type = soldier_type
    self.soldier_level = soldier_level
    -- 取得对应士兵配置表
    self.s_config = soldier_level and normal[soldier_type.."_"..soldier_level]
        or special[soldier_type]
    self.s_buff_field = DataUtils:getAllSoldierBuffValue(self.s_config)
    -- LuaUtils:outputTable("self.s_config", self.s_config)
    self:InitSoldierDetails()
end

function WidgetSoldierDetails:InitSoldierDetails()
    -- 士兵信息配置表
    local sc = self.s_config

    -- bg
    local bg = WidgetUIBackGround.new({height=675,isFrame="no"}):align(display.CENTER, window.cx, window.top-520)
    self:addTouchAbleChild(bg)

    local bg_width,bg_height = bg:getContentSize().width,bg:getContentSize().height
    -- title bg
    local title_bg = display.newSprite("report_title.png", bg_width/2,bg_height+10):addTo(bg,2)
    local title_label = UIKit:ttfLabel({
        text = _("兵种详情"),
        size = 24,
        color = 0xffedae 
    }):align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2)
        :addTo(title_bg)
    -- soldier_name label
    self.soldier_name_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = Localize.soldier_name[self.soldier_type],
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0x5a5544)
    }):align(display.LEFT_CENTER,180,bg_height-50):addTo(bg,2)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent(true)
        end):align(display.CENTER, bg_width-30, bg_height+10):addTo(bg,2)
    -- 士兵头像
    -- local stars_bg = display.newSprite("soldier_head_stars_bg.png"):align(display.LEFT_TOP,100, bg_height-30):addTo(bg)
    -- local soldier_head_bg  = display.newSprite(STAR_BG[self.soldier_level],-30,stars_bg:getContentSize().height/2):addTo(stars_bg)

    -- local soldier_type_with_star = self.soldier_type..(self.soldier_level == nil and "" or string.format("_%d", self.soldier_level))
    local soldier_ui_config = UILib.soldier_image[self.soldier_type][self.soldier_level]


    local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.CENTER_TOP,100, bg_height-30)
    soldier_head_icon:scale(130/soldier_head_icon:getContentSize().height)
    display.newSprite("box_soldier_128x128.png"):addTo(soldier_head_icon):align(display.CENTER, soldier_head_icon:getContentSize().width/2, soldier_head_icon:getContentSize().height-64)
    bg:addChild(soldier_head_icon)

    -- -- 士兵星级，特殊兵种无星级
    -- local soldier_stars = self.soldier_level
    -- if soldier_stars then
    --     local gap_y = 25
    --     for i=1,5 do
    --         stars_bg:addChild(display.newSprite("soldier_stars_bg.png", 38, 15+gap_y*(i-1)))
    --         if soldier_stars>0 then
    --             stars_bg:addChild(display.newSprite("soldier_stars.png", 38, 15+gap_y*(i-1)))
    --             soldier_stars = soldier_stars-1
    --         end
    --     end
    -- end

    local num_title_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("数量"),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x5a5544)
    }):align(display.LEFT_CENTER,180,bg_height-90):addTo(bg,2)

    self.total_soldier = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = City:GetSoldierManager():GetCountBySoldierType(self.soldier_type),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x5a5544)
    }):align(display.LEFT_CENTER,num_title_label:getPositionX()+num_title_label:getContentSize().width+10,bg_height-90):addTo(bg,2)

    -- 调整解散士兵数量silder
    self:CreateDismissSoldierSilder()
    -- 士兵属性
    self:InitSoldierAttr()
end

function WidgetSoldierDetails:CreateDismissSoldierSilder()
    -- display.newSprite("dismiss_soldier_bg.png", display.cx + 233, display.top - 280):addTo(self)
    -- local dismiss_value = cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     text = _("0"),
    --     font = UIKit:getFontFilePath(),
    --     size = 20,
    --     color = UIKit:hex2c3b(0x000000)})
    --     :align(display.CENTER, display.cx + 235, display.top - 282)
    --     :addTo(self)
    -- -- 士兵总数
    -- cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     text = _("/ "..City:GetSoldierManager():GetCountBySoldierType(self.soldier_type)),
    --     font = UIKit:getFontFilePath(),
    --     size = 20,
    --     color = UIKit:hex2c3b(0x403c2f)})
    --     :align(display.CENTER, display.cx + 230, display.top - 310)
    --     :addTo(self)
    -- -- 返还城民
    -- -- icon
    display.newSprite("population.png", display.cx-110, display.top-312):addTo(self)
    local citizen_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("0"),
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)})
        :align(display.CENTER, display.cx - 70, display.top - 320)
        :addTo(self)
    -- -- sliderbar
    -- WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
    --     progress = "slider_progress_445x14.png",
    --     button = "slider_btn_66x66.png"},{max = City:GetSoldierManager():GetCountBySoldierType(self.soldier_type)}):addTo(self)
    --     :align(display.LEFT_BOTTOM, display.cx - 280, display.top - 310)
    --     :onSliderValueChanged(function(event)
    --         dismiss_value:setString(string.format("%d", math.floor(event.value)))
    --         citizen_label:setString(string.format("%d", math.floor(event.value)*self.s_config.citizen))
    --     end)
    --     :setSliderValue(0)
    self.slider = WidgetSliderWithInput.new({max = City:GetSoldierManager():GetCountBySoldierType(self.soldier_type)})
    :SetSliderSize(445, 24)
    :addTo(self)
    :align(display.LEFT_CENTER, 30, window.top - 360)
    :OnSliderValueChanged(function(event)
            citizen_label:setString(string.format("%d", math.floor(event.value)*self.s_config.citizen))
        end)
    :LayoutValueLabel(WidgetSliderWithInput.STYLE_LAYOUT.RIGHT,0)

    local dismiss_soldier_button = WidgetPushButton.new({normal = "resource_butter_red.png",pressed = "resource_butter_red_highlight.png"},{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("解散"), size = 24, color = display.COLOR_WHITE}))
        :onButtonClicked(function(event)
            print("解散士兵 =================")
        end):align(display.CENTER, display.cx + 205, display.top-440):addTo(self)
        :setButtonEnabled(false)

end

function WidgetSoldierDetails:InitSoldierAttr()
    local sc = self.s_config
    -- bg
    -- local bg = display.newSprite("back_ground_549X379.png", display.cx, display.top-600):addTo(self)
    -- -- upgrade_resources_background_3
    -- local function createAttrItem(name,value,bg_image)
    --     -- bg
    --     local attr_item = display.newSprite(bg_image)
    --     local width,height = attr_item:getContentSize().width,attr_item:getContentSize().height
    --     cc.ui.UILabel.new({
    --         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --         text = name,
    --         font = UIKit:getFontFilePath(),
    --         size = 20,
    --         color = UIKit:hex2c3b(0x615b44)})
    --         :align(display.LEFT_CENTER, 10, 20)
    --         :addTo(attr_item)
    --     cc.ui.UILabel.new({
    --         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --         text = value,
    --         font = UIKit:getFontFilePath(),
    --         size = 20,
    --         color = UIKit:hex2c3b(0x403c2f)})
    --         :align(display.CENTER_RIGHT, width-10, 20)
    --         :addTo(attr_item)
    --     return attr_item
    -- end
    local  attr_table = {
        {
             _("对步兵攻击"),
             sc.infantry,
             self:GetSoldierFieldWithBuff("infantry")
        },
        {
             _("对弓箭手攻击"),
             sc.archer,
             self:GetSoldierFieldWithBuff("archer")
        },
        {
            _("对骑兵攻击"),
             sc.cavalry,
            self:GetSoldierFieldWithBuff("cavalry")
        },
        {
             _("对投石车攻击"),
             sc.siege,
             self:GetSoldierFieldWithBuff("siege")
        },
        {
             _("对城墙攻击"),
             sc.wall,
             self:GetSoldierFieldWithBuff("wall")
        },
        {
             _("生命值"),
             sc.hp,
             self:GetSoldierFieldWithBuff("hp")
        },
        {
             _("人口"),
             sc.citizen,
             self:GetSoldierFieldWithBuff("citizen")
        },
        {
             _("维护费"),
             sc.consumeFoodPerHour,
             self:GetSoldierFieldWithBuff("consumeFoodPerHour")
        },
    }

    -- self.attr_listview = UIListView.new{
    --     -- bg = "common_tips_bg.png",
    --     -- bgColor = cc.c4b(200, 200, 200, 120),
    --     bgScale9 = true,
    --     viewRect = cc.rect(1, 0, 547, 377),
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    --     :addTo(bg,2)
    -- local bg_flag = true
    -- for k,v in pairs(attr_table) do
    --     print("==============================",k,v.name)
    --     local item = self.attr_listview:newItem()
    --     item:setItemSize(547,47)
    --     if bg_flag then
    --         --todo
    --         item:addContent(createAttrItem(v.name,v.value,"upgrade_resources_background_3.png"))
    --         bg_flag = false

    --     else
    --         item:addContent(createAttrItem(v.name,v.value,"upgrade_resources_background_2.png"))
    --         bg_flag = true
    --     end
    --     self.attr_listview:addItem(item)
    -- end
    -- self.attr_listview:reload()
    WidgetInfoBuff.new({
        info=attr_table,
        h =300,
    }):align(display.TOP_CENTER, window.cx, window.top-500):addTo(self)
end

function WidgetSoldierDetails:GetSoldierFieldWithBuff(field)
    local sf = self.s_buff_field
    if sf[field] then
        if field ~= 'consumeFoodPerHour' then
            return  " +" .. sf[field]
        else
            return " -" .. sf[field]
        end
    else
        return nil
    end
end

return WidgetSoldierDetails


