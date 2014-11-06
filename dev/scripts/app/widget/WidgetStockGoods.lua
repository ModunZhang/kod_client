local GameUtils = GameUtils
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local WidgetSlider = import("..widget.WidgetSlider")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetStockGoods = class("WidgetStockGoods", function(...)
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

function WidgetStockGoods:ctor(buy_max)
    self.buy_max = buy_max

    local label_origin_x = 190

    -- bg
    local back_ground = WidgetUIBackGround.new({height=464}):align(display.BOTTOM_CENTER, window.cx, 0):addTo(self)

    back_ground:setTouchEnabled(true)
    local size = back_ground:getContentSize()

    -- 道具图片
    local tool_img_bg = display.newSprite("tool_box_green.png"):align(display.TOP_LEFT, 10, size.height-5):addTo(back_ground)
    local tool_img = display.newSprite("tool_1.png")
        :align(display.CENTER,tool_img_bg:getContentSize().width/2,tool_img_bg:getContentSize().height/2)
        :addTo(tool_img_bg)

    -- 道具title
    local title_bg = display.newSprite("title_blue_402x48.png")
        :align(display.CENTER, 370, size.height-25)
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
    }):align(display.LEFT_TOP,tool_img_bg:getPositionX()+tool_img_bg:getContentSize().width+10, size.height-40):addTo(back_ground)
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

    -- 联盟数量，联盟内成员需求
    local info_bg = WidgetUIBackGround.new({
        width = 568,
        height = 100,
        top_img = "back_ground_568X14_top.png",
        bottom_img = "back_ground_568X14_top.png",
        mid_img = "back_ground_568X1_mid.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):align(display.CENTER,size.width/2, 165):addTo(back_ground)
    local function createContent(image_bg,title,value)
        local content = display.newScale9Sprite(image_bg,0,0,cc.size(550,42))
        UIKit:ttfLabel({
            text = title,
            size = 20,
            color = 0x5d563f,
        }):align(display.LEFT_CENTER, 10, content:getContentSize().height/2):addTo(content,2)
        UIKit:ttfLabel({
            text = value,
            size = 20,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER, 530, content:getContentSize().height/2):addTo(content,2)
        return content
    end
    -- 联盟拥有数量
    createContent("upgrade_resources_background_3.png",_("联盟拥有"),20)
        :align(display.CENTER, info_bg:getContentSize().width/2, 70):addTo(info_bg)
    createContent("upgrade_resources_background_2.png",_("需求的成员数量"),2)
        :align(display.CENTER, info_bg:getContentSize().width/2, 28):addTo(info_bg)


    -- 荣耀值
    display.newSprite("honour.png"):align(display.CENTER, 200, 50):addTo(back_ground)
    local honour_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER, 300, 50):addTo(back_ground)
    self.loyalty_label = UIKit:ttfLabel({
        text = "10000",
        size = 20,
        color = 0x403c2f,
    }):addTo(honour_bg):align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)
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

function WidgetStockGoods:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint, x, y)
    return self
end

function WidgetStockGoods:OnCountChanged(count)
    self.goods_current_count:setString(count)
end
return WidgetStockGoods





