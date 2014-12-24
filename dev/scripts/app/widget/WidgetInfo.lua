local WidgetUIBackGround = import(".WidgetUIBackGround")
local UIListView = import("..ui.UIListView")

local WidgetInfo = class("WidgetInfo", function ()
    return display.newNode()
end)
function WidgetInfo:ctor(params)
    local info = params.info -- 显示信息

    self.info_bg = WidgetUIBackGround.new({
        width = 568,
        height = params.h or #info*40+20,
        top_img = "back_ground_568X14_top.png",
        bottom_img = "back_ground_568X14_top.png",
        mid_img = "back_ground_568X1_mid.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):addTo(self)
    self.info_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(10, 10, 548, (params.h or #info*40+20)-20),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.info_bg)

    self:CreateInfoItem(info)
end
function WidgetInfo:SetInfo(info)
    self.info_listview:removeAllItems()
    self:CreateInfoItem(info)
    return self
end
function WidgetInfo:align(align,x,y)
    self.info_bg:align(align, x, y)
    return self
end

function WidgetInfo:CreateInfoItem(info_message)
    local meetFlag = true

    local item_width, item_height = 548,40
    for k,v in pairs(info_message) do
        local item = self.info_listview:newItem()
        item:setItemSize(item_width, item_height)
        local content
        if meetFlag then
            content = display.newSprite("back_ground_548x40_1.png")
        else
            content = display.newSprite("back_ground_548x40_2.png")
        end
        UIKit:ttfLabel({
            text = v[1],
            size = 20,
            color = 0x797154,
        }):align(display.LEFT_CENTER, 10, item_height/2):addTo(content)
        if v[2] then
            local text_2 = UIKit:ttfLabel({
                text = v[2],
                size = 20,
                color = 0x403c2f,
            }):align(display.RIGHT_CENTER, item_width-10, item_height/2):addTo(content)

            if v[3] then
                display.newSprite(v[3]):align(display.RIGHT_CENTER, item_width-15, item_height/2):addTo(content)
                text_2:setPositionX(item_width-60)
            end
        end

        meetFlag =  not meetFlag
        item:addContent(content)
        self.info_listview:addItem(item)
    end
    self.info_listview:reload()
end
return WidgetInfo


