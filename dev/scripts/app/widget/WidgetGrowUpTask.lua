local cocos_promise = import("..utils.cocos_promise")
local window = import("..utils.window")
local UIListView = import("..ui.UIListView")
local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetDropItem = import(".WidgetDropItem")
local WidgetGrowUpTask = class("WidgetGrowUpTask", WidgetPopDialog)
function WidgetGrowUpTask:ctor(category)
    WidgetGrowUpTask.super.ctor(self, 630, category:Title(), display.cy + 300)
    self.touch_layer = display.newLayer():addTo(self, 10)
    self.touch_layer:setTouchEnabled(false)

    self.category = category
end
function WidgetGrowUpTask:onEnter()
    WidgetGrowUpTask.super.onEnter(self)
    local body = self:GetBody()
    local size = body:getContentSize()
    self.listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 20, size.width, size.height - 40),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(body)
    self:RefreshItems()
end
function WidgetGrowUpTask:onExit()
    WidgetGrowUpTask.super.onExit(self)
end
function WidgetGrowUpTask:RefreshItems()
    self.listview:removeAllItems()
    for _,v in ipairs(self.category.tasks) do
        self.listview:addItem(self:CreateItem(self.listview, v))
    end
    self.listview:reload()
    if self.listview.items_[1] then
        self.listview.items_[1]:getContent():OnOpen(false)
    end
end
function WidgetGrowUpTask:CreateItem(listview, task)
    local item = listview:newItem()
    local content = WidgetDropItem.new({title=task:Title()}, function(drop_item, ani)
        if drop_item then
            drop_item:CreateRewardsPanel(task)
        end
        local w,h = item:getItemSize()
        local x,y = item:getContent():getPosition()
        local new_h = item:getContent():getCascadeBoundingBox().height + 10
        local offset = (new_h - h) * 0.5
        local item_rect = item:getCascadeBoundingBox()
        self.touch_layer:setTouchEnabled(true)
        if ani then
            transition.moveTo(item:getContent(), {x = x, y = y + offset, time = 0.2,
                onComplete = function()
                    self.touch_layer:setTouchEnabled(false)
                    if drop_item then
                        local viewRect_ = listview:getViewRectInWorldSpace()
                        local offset_y = (viewRect_.y + viewRect_.height) - (item_rect.y + item_rect.height)
                        listview.container:moveBy(0.1, 0, offset_y)
                    end
                end
            })
        else
            item:getContent():pos(x, y + offset)
            self.touch_layer:setTouchEnabled(false)
            if drop_item then
                local viewRect_ = listview:getViewRectInWorldSpace()
                local offset_y = (viewRect_.y + viewRect_.height) - (item_rect.y + item_rect.height)
                local x,y = listview.container:getPosition()
                listview.container:pos(x, y + offset_y)
            end
        end
        item:setItemSize(w, new_h, false, ani)
    end):align(display.CENTER)
    item:addContent(content)
    local rect = content:getCascadeBoundingBox()
    item:setItemSize(rect.width, rect.height + 10,false,false)
    return item
end



return WidgetGrowUpTask















