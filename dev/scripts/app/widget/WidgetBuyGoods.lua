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

function WidgetBuyGoods:ctor(item)
    self.buy_max = item:Count()
    local buy_max = self.buy_max

    local label_origin_x = 190

    -- bg
    local back_ground = WidgetUIBackGround.new({height=338,isFrame = 'yes'}):align(display.BOTTOM_CENTER, window.cx, 0):addTo(self)
    local size = back_ground:getContentSize()

    back_ground:setTouchEnabled(true)

    -- 道具图片
    -- local tool_img_bg = display.newSprite("tool_box_green.png"):align(display.TOP_LEFT, 10, 332):addTo(back_ground)
    -- local tool_img = display.newSprite("tool_1.png")
    --     :align(display.CENTER,tool_img_bg:getContentSize().width/2,tool_img_bg:getContentSize().height/2)
    --     :addTo(tool_img_bg)
    local item_bg = display.newSprite("box_118x118.png"):addTo(back_ground):align(display.CENTER, 70, size.height-80)
    local item_icon_color_bg = display.newSprite("box_item_100x100.png"):addTo(item_bg):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
    -- tool image
    display.newSprite("tool_1.png"):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
        :addTo(item_bg):scale(0.8)
    local i_icon = display.newSprite("goods_26x26.png"):addTo(item_bg):align(display.CENTER, 15, 15)

    -- 道具title
    local title_bg = display.newScale9Sprite("title_blue_430x30.png",370,size.height-40,cc.size(458,30),cc.rect(15,10,400,10))
        :addTo(back_ground)
    local goods_name = UIKit:ttfLabel({
        text = item:GetLocalizeName(),
        size = 24,
        color = 0xffedae,
    }):align(display.LEFT_CENTER,20, title_bg:getContentSize().height/2):addTo(title_bg)
    UIKit:ttfLabel({
        text = _("高级道具"),
        size = 20,
        color = 0xe8dfbc,
    }):align(display.RIGHT_CENTER,title_bg:getContentSize().width-40, title_bg:getContentSize().height/2):addTo(title_bg)

    local goods_desc = UIKit:ttfLabel({
        text = item:GetLocalizeDesc(),
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(400,0)
    }):align(display.LEFT_TOP,item_bg:getPositionX()+item_bg:getContentSize().width/2+30, 280):addTo(back_ground)
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
        text = item:PriceInAlliance(),
        size = 20,
        color = 0x403c2f,
    }):addTo(loyalty_bg):align(display.CENTER,loyalty_bg:getContentSize().width/2,loyalty_bg:getContentSize().height/2)
    -- 购买按钮
    local button = WidgetPushButton.new(
        {normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :setButtonLabel(UIKit:commonButtonLable({text = _("购买")}))
        :onButtonClicked(function(event)

        end):pos(500, 50)
        :addTo(back_ground)

    button:setButtonEnabled(buy_max~=0)
end

function WidgetBuyGoods:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint, x, y)
    return self
end

function WidgetBuyGoods:OnCountChanged(count)
    self.goods_current_count:setString(count)
end
return WidgetBuyGoods




