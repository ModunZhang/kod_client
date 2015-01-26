--
-- Author: Kenny Dai
-- Date: 2015-01-23 09:34:06
--
local WidgetDropList = import("..widget.WidgetDropList")
local window = import("..utils.window")
local Item = import("..entity.Item")

local GameUIItems = UIKit:createUIClass("GameUIItems","GameUIWithCommonHeader")

function GameUIItems:ctor(title,city)
    GameUIItems.super.ctor(self,city,title)
end
function GameUIItems:onEnter()
    GameUIItems.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("商城"),
            tag = "shop",
            default = true
        },
        {
            label = _("我的道具"),
            tag = "myItems",
        },
    }, function(tag)
        self.shop_layer:setVisible(tag == 'shop')
        self.myItems_layer:setVisible(tag == 'myItems')
        if tag == 'shop' then
        	if not self.shop_dropList then
        		self:InitShop()
        	end
        end
        if tag == 'myItems' then
        	if not self.myItems_dropList then
        		self:InitMyItems()
        	end
        end
    end):pos(window.cx, window.bottom + 34)

   
end
function GameUIItems:CreateBetweenBgAndTitle()
    GameUIItems.super.CreateBetweenBgAndTitle(self)
    -- shop_layer
    self.shop_layer = display.newLayer()
    self:addChild(self.shop_layer)
    -- myItems_layer
    self.myItems_layer = display.newLayer()
    self:addChild(self.myItems_layer)
end
function GameUIItems:onExit()
    GameUIItems.super.onExit(self)
end

function GameUIItems:InitShop()
	local layer = self.shop_layer
	 self.shop_dropList = WidgetDropList.new(
        {
            {tag = "menu_1",label = "特殊",default = true},
            {tag = "menu_2",label = "持续增益"},
            {tag = "menu_3",label = "增益"},
            {tag = "menu_4",label = "时间加速"},
        },
        function(tag)
            if tag == 'menu_2' then

            end
        end
    ):align(display.TOP_CENTER,window.cx,window.top-100):addTo(layer)
end
function GameUIItems:InitMyItems()
	local layer = self.myItems_layer
	 self.myItems_dropList = WidgetDropList.new(
        {
            {tag = "menu_1",label = "特殊",default = true},
            {tag = "menu_2",label = "持续增益"},
            {tag = "menu_3",label = "增益"},
            {tag = "menu_4",label = "时间加速"},
        },
        function(tag)
            if tag == 'menu_2' then

            end
        end
    ):align(display.TOP_CENTER,window.cx,window.top-100):addTo(layer)
end
return GameUIItems

