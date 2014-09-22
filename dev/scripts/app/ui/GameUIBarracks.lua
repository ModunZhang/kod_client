--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local WidgetTips = import("..widget.WidgetTips")
local WidgetSoldierBox = import("..widget.WidgetSoldierBox")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local GameUIBarracks = UIKit:createUIClass("GameUIBarracks", "GameUIWithCommonHeader")
function GameUIBarracks:ctor(city)
    GameUIBarracks.super.ctor(self, city, _("兵营"))
end
function GameUIBarracks:onEnter()
    GameUIBarracks.super.onEnter(self)

    self.tips = WidgetTips.new(_("招募队列空闲"), _("请选择一个兵种进行招募")):addTo(self)
    :align(display.CENTER, display.cx, display.top - 160)

    self.timer = WidgetTimerProgress.new(549, 108):addTo(self)
        :align(display.CENTER, display.cx, display.top - 160)
        :SetDescribe(_("招募弓箭手x300"))
        :SetProgressInfo("00:20:00", 80)
        :OnButtonClicked(function(event)
            print("hello")
        end)


    local rect = self.timer:getCascadeBoundingBox()
    self.list_view = self:CreateVerticalListView(rect.x, display.bottom + 70, rect.x + rect.width, rect.y - 20)
    local item = self:CreateItemWithListView(self.list_view)
    self.list_view:addItem(item)
    local item = self:CreateItemWithListView(self.list_view)
    self.list_view:addItem(item)
    self.list_view:reload():resetPosition()


    





    self:TabButtons() 
end
function GameUIBarracks:TabButtons()
    self:CreateTabButtons({
        {
            label = _("升级"),
            tag = "upgrade",
        },
        {
            label = _("招募"),
            tag = "recruit",
            default = true,
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.list_view:setVisible(false)
        elseif tag == "recruit" then
            self.list_view:setVisible(true)
        elseif tag == "specialRecruit" then
            self.list_view:setVisible(false)
        end
    end):pos(display.cx, display.bottom + 40)
end
function GameUIBarracks:CreateItemWithListView(list_view)
    local rect = list_view:getViewRect()
    local origin_x = - rect.width / 2
    local widget_rect = self.timer:getCascadeBoundingBox()
    local unit_width = 130
    local gap_x = (widget_rect.width - unit_width * 4) / 3
    local row_item = display.newNode()


    for i = 1, 4 do
        WidgetSoldierBox.new("soldier_130x183.png", function(event)
            print("hello")
        end):addTo(row_item)
            :alignByPoint(cc.p(0.5, 0.4), origin_x + (unit_width + gap_x) * (i - 1) + unit_width / 2, 0)
            :SetNumber(999)
    end
    local item = list_view:newItem()

    item:addContent(row_item)
    item:setItemSize(widget_rect.width, 170)
    return item
end





return GameUIBarracks





