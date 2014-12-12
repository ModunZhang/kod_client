local WidgetUIBackGround = import(".WidgetUIBackGround")
local UIListView = import("..ui.UIListView")

local WidgetInfoWithTitle = class("WidgetInfoWithTitle", function ()
    return display.newNode()
end)
function WidgetInfoWithTitle:ctor(params)
    local info = params.info -- 显示信息
    local height = params.h or 266
    self.info_bg = WidgetUIBackGround.new({
        width = 548,
        height = height,
        top_img = "back_ground_548x62_top.png",
        bottom_img = "back_ground_548x18_bottom.png",
        mid_img = "back_ground_548x1_mid.png",
        u_height = 62,
        b_height = 18,
        m_height = 1,
    }):addTo(self)

    UIKit:ttfLabel({
        text = params.title,
        size = 24,
        color = 0xffedae
    }):align(display.CENTER,self.info_bg:getContentSize().width/2, self.info_bg:getContentSize().height-25)
        :addTo(self.info_bg)

    self.info_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(13, 10, 524, height-66),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.info_bg)

    self:CreateInfoItems(info)
end

function WidgetInfoWithTitle:align(align,x,y)
    self.info_bg:align(align, x, y)
    return self
end

function WidgetInfoWithTitle:CreateInfoItems(info_message)
	if not info_message then
		return
	end
	self.info_listview:removeAllItems()
    local meetFlag = true

    local item_width, item_height = 548,40
    for k,v in pairs(info_message) do
        local item = self.info_listview:newItem()
        item:setItemSize(item_width, item_height)
        local content = display.newNode()
        content:setContentSize(cc.size(item_width, item_height))
        display.newScale9Sprite(meetFlag and "back_ground_548x40_1.png" or "back_ground_548x40_2.png",item_width/2,item_height/2,cc.size(item_width,item_height))
            :addTo(content)

        UIKit:ttfLabel({
            text = v[1],
            size = 20,
            color = 0x797154,
        }):align(display.LEFT_CENTER, 20, item_height/2):addTo(content)

        UIKit:ttfLabel({
            text = v[2],
            size = 20,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER, item_width-20, item_height/2):addTo(content)

        meetFlag =  not meetFlag
        item:addContent(content)
        self.info_listview:addItem(item)
    end
    self.info_listview:reload()
end
function WidgetInfoWithTitle:GetListView()
	return self.info_listview
end
return WidgetInfoWithTitle


