local WidgetPushButton = import(".WidgetPushButton")
local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetUseItems = import(".WidgetUseItems")
local UILib = import("..ui.UILib")

local BUY_AND_USE = 1
local USE = 2
local boxes = {
    city ={"box_buff_1.png","box_buff_1.png"},
    war ={"box_buff_2.png","box_buff_2.png"},
}
local WidgetBuffBox = class("WidgetBuffBox", function ()
    return display.newNode()
end)

function WidgetBuffBox:ctor(params)
    local width,height = 136,190
    local buff_category = params.buff_category
    local buff_type = params.buff_type
    self:setContentSize(cc.size(width,height))
    local buff_btn = WidgetPushButton.new(
        {normal = boxes[buff_category][1],pressed = boxes[buff_category][2]})
        :addTo(self)
        :align(display.CENTER, width/2, height/2+15)
        :onButtonClicked(function ( event )
            WidgetUseItems.new():Create({item_type = WidgetUseItems.USE_TYPE.BUFF,item_name = buff_type.."_1"})
                :addToCurrentScene()
        end)
    -- buff icon
    local buff_icon = display.newSprite(UILib.buff[buff_type],0,12,{class=cc.FilteredSpriteWithOne})
        :addTo(buff_btn)
    buff_icon:scale(102/math.max(buff_icon:getContentSize().width,buff_icon:getContentSize().height))
    if not ItemManager:IsBuffActived( buff_type ) then
        local my_filter = filter
        local filters = my_filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1})
        buff_icon:setFilter(filters)
    end
    -- 信息框
    local info_bg = display.newSprite("back_ground_130x30.png")
        :align(display.CENTER, width/2, 15)
        :addTo(self)
    self.info_label = UIKit:ttfLabel(
        {
            text = "",
            size = 20,
            color = 0x403c2f
        }):align(display.CENTER, info_bg:getContentSize().width/2 ,info_bg:getContentSize().height/2)
        :addTo(info_bg)
end
function WidgetBuffBox:SetInfo(info,color)
    self.info_label:setString(info)
    if color then
        self.info_label:setColor(color)
    end
    return self
end

return WidgetBuffBox






