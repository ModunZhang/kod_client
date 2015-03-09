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

    local body = self:GetBody()
    local size = body:getContentSize()
    self.listview = UIListView.new{
        bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 20, size.width, size.height - 40),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(body)
    self:RefreshItems()
end
function WidgetGrowUpTask:onEnter()
    WidgetGrowUpTask.super.onEnter(self)
end
function WidgetGrowUpTask:onExit()
    WidgetGrowUpTask.super.onExit(self)
end
function WidgetGrowUpTask:RefreshItems()
    self.count = 1
    self.listview:removeAllItems()
    for _,v in ipairs(self.category.tasks) do
        self.listview:addItem(self:CreateItem(self.listview, v))
    end
    self.listview:reload()
end
function WidgetGrowUpTask:CreateItem(listview, task)
    local item = listview:newItem()
    local content = WidgetDropItem.new({title=task:Title()}, function(content)
        if content then
            local extend = (#task:GetRewards() - 4)
            content:size(572, 304 + (extend > 0 and extend or 0) * 40)
        end

        local w,h = item:getItemSize()
        local x,y = item:getContent():getPosition()
        local new_h = item:getContent():getCascadeBoundingBox().height + 10
        local offset = (new_h - h) * 0.5
        local item_rect = item:getCascadeBoundingBox()
        self.touch_layer:setTouchEnabled(true)
        transition.moveTo(item:getContent(), {x = x, y = y + offset, time = 0.2,
            onComplete = function()
                self.touch_layer:setTouchEnabled(false)
                if content then
                    local viewRect_ = listview:getViewRectInWorldSpace()
                    local offset_y = (viewRect_.y + viewRect_.height) - (item_rect.y + item_rect.height)
                    listview.container:moveBy(0.1, 0, offset_y)

                    local size = content:getContentSize()
                    local desc = UIKit:ttfLabel({
                        text = task:Desc(),
                        size = 18,
                        color = 0x797154,
                        dimensions = cc.size(500,0)
                    }):align(display.LEFT_TOP, 40, size.height - 30):addTo(content)

                    local under_y = 20
                    local base_under_line = size.height - 110 - under_y
                    UIKit:ttfLabel({
                        text = _("任务奖励"),
                        size = 20,
                        color = 0x403c2f,
                    }):align(display.CENTER, 572/2, size.height - 100):addTo(content)
                    display.newSprite("line_550x2.png"):align(display.CENTER, 572/2, base_under_line):addTo(content)

                    local base_y = base_under_line
                    local gap_y = 20
                    for i,v in ipairs(task:GetRewards()) do
                        local cur_y = base_y - gap_y
                        cc.ui.UIImage.new(v:Icon()):align(display.CENTER, 572/2 - 230, cur_y):addTo(content):setLayoutSize(30, 30)
                        UIKit:ttfLabel({
                            text = v:Desc(),
                            size = 20,
                            color = 0x403c2f,
                        }):align(display.CENTER, 572/2 - 180, cur_y):addTo(content)
                        UIKit:ttfLabel({
                            text = v:CountDesc(),
                            size = 20,
                            color = 0x403c2f,
                        }):align(display.CENTER, 572/2 + 220, cur_y):addTo(content)
                        if i ~= #task:GetRewards() then
                            display.newSprite("line_550x2.png"):align(display.CENTER, 572/2, cur_y - under_y):addTo(content)
                        end
                        base_y = cur_y - under_y
                    end
                end
            end
        })
        item:setItemSize(w, new_h, false)
    end)
    content:align(display.CENTER)
    item:addContent(content)
    item:setItemSize(content:getCascadeBoundingBox().width, content:getCascadeBoundingBox().height + 10,false)
    self.count = self.count + 1
    return item
end



return WidgetGrowUpTask







