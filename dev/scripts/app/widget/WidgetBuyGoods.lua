local GameUtils = GameUtils
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local WidgetSlider = import("..widget.WidgetSlider")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetBuyGoods = class("WidgetBuyGoods", function(...)
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            node:removeFromParent()
        end
        return true
    end)
    return node
end)

function WidgetBuyGoods:ctor(buy_max)
    self.buy_max = buy_max

    local label_origin_x = 190

    -- bg
    local back_ground = WidgetUIBackGround.new({height=338}):align(display.BOTTOM_CENTER, window.cx, 0):addTo(self)

    back_ground:setTouchEnabled(true)

    -- 道具图片
    local tool_img_bg = display.newSprite("tool_box_green.png"):align(display.TOP_LEFT, 10, 332):addTo(back_ground)
    local tool_img = display.newSprite("tool_1.png")
        :align(display.CENTER,tool_img_bg:getContentSize().width/2,tool_img_bg:getContentSize().height/2)
        :addTo(tool_img_bg)
    local size = back_ground:getContentSize()

    -- 道具title
    local title_bg = display.newSprite("title_blue_402x48.png")
        :align(display.CENTER, 370, 310)
        :scale(438/402)
        :addTo(back_ground)
    local goods_name = UIKit:ttfLabel({
        text = "tool name",
        size = 24,
        color = 0xffedae,
    }):align(display.LEFT_CENTER,20, title_bg:getContentSize().height/2):addTo(title_bg)
    UIKit:ttfLabel({
        text = _("高级道具"),
        size = 20,
        color = 0xe8dfbc,
    }):align(display.RIGHT_CENTER,title_bg:getContentSize().width-40, title_bg:getContentSize().height/2):addTo(title_bg)

    local goods_desc = UIKit:ttfLabel({
        text = _("..............item descripition...................................item descripition....................."),
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(400,0)
    }):align(display.LEFT_TOP,tool_img_bg:getPositionX()+tool_img_bg:getContentSize().width+10, 290):addTo(back_ground)
    -- progress
    local slider_height, label_height = size.height - 190, size.height - 170
    local slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
        progress = "slider_progress_445x14.png",
        button = "slider_btn_66x66.png"}, {max = buy_max}):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 25, slider_height)
        :onSliderValueChanged(function(event)
            self:OnCountChanged(math.floor(event.value))
        end)


    -- goods count bg
    local bg = cc.ui.UIImage.new("back_ground_83x32.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width - 70, label_height)

    -- goods current
    local pos = bg:getAnchorPointInPoints()
    self.goods_current_count = UIKit:ttfLabel({
        text = "0",
        size = 20,
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = 0x403c2f
    }):addTo(bg, 2)
        :align(display.CENTER, pos.x, pos.y)

    -- goods total count
    self.goods_total_count = UIKit:ttfLabel({
        text = string.format("/ %d", buy_max),
        size = 20,
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = 0x403c2f
    }):addTo(back_ground)
        :align(display.CENTER, size.width - 70, label_height - 35)

    self:OnCountChanged(0)
 -- 忠诚值
    display.newSprite("loyalty_1.png"):align(display.CENTER, 200, 50):addTo(back_ground)
    local loyalty_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER, 300, 50):addTo(back_ground)
    self.loyalty_label = UIKit:ttfLabel({
        text = "10000",
        size = 20,
        color = 0x403c2f,
    }):addTo(loyalty_bg):align(display.CENTER,loyalty_bg:getContentSize().width/2,loyalty_bg:getContentSize().height/2)
    -- 购买按钮
    WidgetPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("购买"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER, 500, 50):addTo(back_ground)

end

function WidgetBuyGoods:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint, x, y)
    return self
end

function WidgetBuyGoods:OnCountChanged(count)
    self.goods_current_count:setString(count)
end
return WidgetBuyGoods




