--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
local WidgetWithBlueTitle = import("..widget.WidgetWithBlueTitle")
local GameUITownHall = UIKit:createUIClass("GameUITownHall", "GameUIUpgradeBuilding")
function GameUITownHall:ctor(city, townHall)
    GameUITownHall.super.ctor(self, city, _("市政厅"), townHall)
    self.town_hall_city = city
    self.town_hall = townHall
end
function GameUITownHall:onEnter()
    GameUITownHall.super.onEnter(self)
    self.list_view = self:CreateAdministration()
    self:TabButtons()
end
function GameUITownHall:onExit()
    GameUITownHall.super.onExit(self)
end
function GameUITownHall:TabButtons()
    self:CreateTabButtons({
        {
            label = _("市政"),
            tag = "administration",
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.list_view:setVisible(false)
        elseif tag == "administration" then
            self.list_view:setVisible(true)
        end
    end):pos(window.cx, window.bottom + 40)
end

function GameUITownHall:CreateAdministration()
    local list_view = self:CreateVerticalListView(window.left + 20, window.bottom + 70, window.right - 20, window.top - 100)

    local function new_divide_item1(widget, height)
        local size = widget:getContentSize()
        cc.ui.UILabel.new({
            text = "达到 8/8",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x615b44)
        }):addTo(widget, 2):align(display.LEFT_CENTER, 30, size.height - height)

        cc.ui.UILabel.new({
            text = "增加 %5 城民增长",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x615b44)
        }):addTo(widget, 2):align(display.RIGHT_CENTER, size.width - 70, size.height - height)

        cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "no_40x40.png" })
            :addTo(widget)
            :align(display.CENTER, size.width - 40, size.height - height)
            :setButtonSelected(true)
            :setTouchEnabled(false)

        cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(widget, 2)
            :setLayoutSize(570, 2):align(display.CENTER, size.width / 2, size.height - height - 25)
    end

    local function new_divide_item2(widget, height)
        local size = widget:getContentSize()
        cc.ui.UILabel.new({
            text = "达到 8/8",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x615b44)
        }):addTo(widget, 2):align(display.LEFT_CENTER, 30, size.height - height)

        cc.ui.UILabel.new({
            text = "增加 %5 城民增长",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x615b44)
        }):addTo(widget, 2):align(display.RIGHT_CENTER, size.width - 70, size.height - height)

        cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "no_40x40.png" })
            :addTo(widget)
            :align(display.CENTER, size.width - 40, size.height - height)
            :setButtonSelected(true)
            :setTouchEnabled(false)

        cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(widget, 2)
            :setLayoutSize(570, 2):align(display.CENTER, size.width / 2, size.height - height - 25)
    end

    local widget = WidgetWithBlueTitle.new(170, _("周围2格范围的住宅数量")):align(display.CENTER)
    new_divide_item1(widget, 80)
    new_divide_item1(widget, 130)
    local item = list_view:newItem()
    item:addContent(widget)
    item:setItemSize(widget:getContentSize().width, widget:getContentSize().height + 10)
    list_view:addItem(item)


    local widget = WidgetWithBlueTitle.new(170, _("税收")):align(display.CENTER)
    new_divide_item2(widget, 80)
    new_divide_item2(widget, 130)
    local item = list_view:newItem()
    item:addContent(widget)
    item:setItemSize(widget:getContentSize().width, widget:getContentSize().height + 10)
    list_view:addItem(item)


    list_view:reload():resetPosition()

    return list_view
end



return GameUITownHall



















