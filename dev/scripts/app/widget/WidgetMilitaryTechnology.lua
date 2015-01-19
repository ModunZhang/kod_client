--
-- Author: Kenny Dai
-- Date: 2015-01-17 10:33:17
--
local window = import("..utils.window")
local WidgetProgress = import(".WidgetProgress")
local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetPushButton = import(".WidgetPushButton")

local function create_line_item(icon,text_1,text_2)
	local line = display.newScale9Sprite("divide_line_489x2.png", 0, 0,cc.size(384,2),cc.rect(10,1,364,0))
    local icon = display.newSprite(icon):addTo(line,2):align(display.LEFT_BOTTOM, 0, 0)
    UIKit:ttfLabel({
        text = text_1,
        size = 20,
        color = 0x797154,
    }):align(display.LEFT_BOTTOM, 50 , 0)
        :addTo(line)
    UIKit:ttfLabel({
        text = text_2,
        size = 22,
        color = 0x403c2f,
    }):align(display.RIGHT_BOTTOM, 384 , 0)
        :addTo(line)

    return line
end

local WidgetMilitaryTechnology = class("WidgetMilitaryTechnology", function ()
    local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0, 0,568, 620),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list_node.listview = list
    return list_node
end)

function WidgetMilitaryTechnology:ctor()
	self:CreateItem()
	self.listview:reload()
end

function WidgetMilitaryTechnology:CreateItem()
    local list = self.listview
    local item = list:newItem()
    local item_width,item_height = 568,150
    item:setItemSize(item_width,item_height)
    list:addItem(item)

    local content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    item:addContent(content)

    local title_bg = display.newScale9Sprite("title_blue_430x30.png",item_width/2,item_height-25,cc.size(550,30),cc.rect(15,10,400,10))
        :addTo(content)
    UIKit:ttfLabel({
        text = "对步兵的攻击 Lv2",
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 20 , title_bg:getContentSize().height/2)
        :addTo(title_bg)

    local upgrade_btn = WidgetPushButton.new({normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png"})
            :setButtonLabel(UIKit:ttfLabel({
                text = _("研发"),
                size = 22,
                color = 0xffedae,
                shadow= true
            }))
            :align(display.CENTER, item_width-90, 44):addTo(content)

    create_line_item("icon_hit.png","步兵对弓箭手攻击","+2%"):addTo(content):align(display.LEFT_CENTER, 10, 60)
    create_line_item("icon_teac.png","步兵科技","+2%"):addTo(content):align(display.LEFT_CENTER, 10, 20)

end

return WidgetMilitaryTechnology

