local GameUtils = GameUtils
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local WidgetSliderWithInput = import("..widget.WidgetSliderWithInput")
local WidgetInfoNotListView = import("..widget.WidgetInfoNotListView")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
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

function WidgetStockGoods:ctor(item)
    self.item = item

    local buy_max = math.floor(Alliance_Manager:GetMyAlliance():Honour()/item:BuyPriceInAlliance())

    local label_origin_x = 190

    -- bg
    local back_ground = WidgetUIBackGround.new({height=464,isFrame="yes"}):align(display.BOTTOM_CENTER, window.cx, 0):addTo(self)

    back_ground:setTouchEnabled(true)
    local size = back_ground:getContentSize()

    -- 道具图片
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
        text = item:IsAdvancedItem() and _("高级道具") or _("普通道具"),
        size = 20,
        color = 0xe8dfbc,
    }):align(display.RIGHT_CENTER,title_bg:getContentSize().width-40, title_bg:getContentSize().height/2):addTo(title_bg)

    local goods_desc = UIKit:ttfLabel({
        text = item:GetLocalizeDesc(),
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(400,0)
    }):align(display.LEFT_TOP,item_bg:getPositionX()+item_bg:getContentSize().width/2+30, size.height-60):addTo(back_ground)
    -- progress
    local slider_height, label_height = size.height - 170, size.height - 170

    local slider = WidgetSliderWithInput.new({max = buy_max}):addTo(back_ground):align(display.LEFT_CENTER, 25, slider_height)
        :SetSliderSize(445, 24)
        :OnSliderValueChanged(function(event)
            self:OnCountChanged(math.floor(event.value))
        end)
        :LayoutValueLabel(WidgetSliderWithInput.STYLE_LAYOUT.RIGHT,0)


    -- 联盟数量，联盟内成员需求
    local widget_info = WidgetInfoNotListView.new(
        {
            info={
                {_("联盟拥有"),item:Count()}
            }
        }
    ):align(display.CENTER, size.width/2, 165)
        :addTo(back_ground)


    -- 荣耀值
    display.newSprite("honour_128x128.png"):align(display.CENTER, 200, 50):addTo(back_ground):scale(42/128)
    local honour_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER, 300, 50):addTo(back_ground)
    self.honour_label = UIKit:ttfLabel({
        text = "0",
        size = 20,
        color = 0x403c2f,
    }):addTo(honour_bg):align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)
    -- 购买按钮
    local button = WidgetPushButton.new(
        {normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :setButtonLabel(UIKit:commonButtonLable({text = _("购买")}))
        :onButtonClicked(function(event)
            if item:IsAdvancedItem() and not Alliance_Manager:GetMyAlliance():GetSelf():CanAddAdvancedItemsToAllianceShop() then
                FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("需要军需官或以上权限"))
                    :AddToCurrentScene()
                return
            end
            NetManager:getAddAllianceItemPromise(item:Name(),slider:GetValue())
            self:removeFromParent()
        end):pos(500, 50)
        :addTo(back_ground)

    button:setButtonEnabled(buy_max~=0)
end

function WidgetStockGoods:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint, x, y)
    return self
end

function WidgetStockGoods:OnCountChanged(count)
    self.honour_label:setString(self.item:BuyPriceInAlliance()*count)
end
return WidgetStockGoods








