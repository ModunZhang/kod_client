--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
local WidgetProgress = import("..widget.WidgetProgress")
local WidgetPushButton = import("..widget.WidgetPushButton")
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
    self.town_hall:AddTownHallListener(self)
    self.town_hall:AddUpgradeListener(self)
    -- self.town_hall_city:AddListenOnType(self, self.town_hall_city.LISTEN_TYPE.UPGRADE_BUILDING)
    self:UpdateDwellingCondition()
end
function GameUITownHall:onExit()
    -- self.town_hall_city:RemoveListenerOnType(self, self.town_hall_city.LISTEN_TYPE.UPGRADE_BUILDING)
    self.town_hall:RemoveTownHallListener(self)
    self.town_hall:RemoveUpgradeListener(self)
    GameUITownHall.super.onExit(self)
end
-- function GameUITownHall:OnUpgradingBegin()
--     self:UpdateDwellingCondition()
-- end
-- function GameUITownHall:OnUpgrading()

-- end
-- function GameUITownHall:OnUpgradingFinished()
-- end

function GameUITownHall:OnBuildingUpgradingBegin()
end
function GameUITownHall:OnBuildingUpgradeFinished()
end
function GameUITownHall:OnBuildingUpgrading()
    if self.impose then
        self.impose:RefreshImpose()
    end
end
function GameUITownHall:OnBeginImposeWithEvent(building, event)
    -- 前置条件
    assert(self.impose)
    assert(self.timer == nil)
    local list_view = self.list_view
    self.timer = self:CreateTimerItemWithListView(list_view):RefreshByEvent(event, app.timer:GetServerTime())
    list_view:replaceItem(self.timer, self.impose)
    self.impose = nil
    -- 重置列表
    list_view:reload()
end
function GameUITownHall:OnImposingWithEvent(building, event, current_time)
    assert(self.impose == nil)
    assert(self.timer)
    self.timer:RefreshByEvent(event, current_time)
end
function GameUITownHall:OnEndImposeWithEvent(building, event, current_time)
    assert(self.impose == nil)
    assert(self.timer)

    local list_view = self.list_view
    self.impose = self:CreateImposeItemWithListView(list_view):RefreshImpose()
    list_view:replaceItem(self.impose, self.timer)
    self.timer = nil

    -- 重置列表
    list_view:reload()
end
function GameUITownHall:UpdateDwellingCondition()
    local cur = #self.town_hall_city:GetHousesAroundFunctionBuildingByType(self.town_hall, "dwelling", 2)
    self.dwelling:GetLineByIndex(1):SetCondition(cur, 3)
    self.dwelling:GetLineByIndex(2):SetCondition(cur, 6)
end
---
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
    end):pos(window.cx, window.bottom + 34)
end
function GameUITownHall:CreateAdministration()
    local list_view = self:CreateVerticalListView(window.left + 20, window.bottom + 70, window.right - 20, window.top - 100)

    self.dwelling = self:CreateDwellingItemWithListView(list_view)
    list_view:addItem(self.dwelling)

    if self.town_hall:IsEmpty() then
        self.impose = self:CreateImposeItemWithListView(list_view):RefreshImpose()
        list_view:addItem(self.impose)
    elseif self.town_hall:IsInImposing() then
        self.timer = self:CreateTimerItemWithListView(list_view)
            :RefreshByEvent(self.town_hall:GetTaxEvent(), app.timer:GetServerTime())
        list_view:addItem(self.timer)
    end

    list_view:reload()
    return list_view
end

function GameUITownHall:CreateDwellingItemWithListView(list_view)
    local widget = WidgetWithBlueTitle.new(160, _("周围2格范围的住宅数量")):align(display.CENTER)
    local size = widget:getContentSize()
    local lineItems = {}
    for i, v in ipairs({1,2}) do
        table.insert(lineItems, self:CreateDwellingLineItem(size.width):addTo(widget, 2)
            :pos(size.width/2, size.height - 80 - (i-1) * 40))
    end
    local item = list_view:newItem()
    item:addContent(widget)
    item:setItemSize(size.width, size.height + 10)


    function item:GetLineByIndex(index)
        return lineItems[index]
    end
    return item
end

function GameUITownHall:CreateImposeItemWithListView(list_view)
    local townHall = self
    local widget = WidgetWithBlueTitle.new(260, _("税收")):align(display.CENTER)
    local size = widget:getContentSize()
    local lineItems = {}
    for i, v in ipairs({
        { icon = "citizen_44x50.png", scale = 0.6, title =_("损失城民") },
        { icon = "coin_icon.png", scale = 0.25, title =_("获得银币") },
        { icon = "hourglass_39x46.png", scale = 0.6, title =_("时间") }
    }) do
        table.insert(lineItems, self:CreateTaxLineItem(size.width, v):addTo(widget, 2)
            :pos(size.width/2, size.height - 80 - (i-1) * 40))
    end
    WidgetPushButton.new(
        {normal = "yellow_btn_up_185x65.png", pressed = "yellow_btn_down_185x65.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("增税"),
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(widget, 2):align(display.CENTER, size.width - 110, 50)
        :onButtonClicked(function(event)
            NetManager:impose(NOT_HANDLE)
        end)
    local item = list_view:newItem()
    item:addContent(widget)
    item:setItemSize(widget:getContentSize().width, widget:getContentSize().height + 10)

    function item:GetLineByIndex(index)
        return lineItems[index]
    end
    function item:RefreshImpose()
        local citizen, tax, time = townHall.town_hall:GetImposeInfo()
        self:GetLineByIndex(1):SetLabel(tostring(citizen))
        self:GetLineByIndex(2):SetLabel(tostring(tax))
        self:GetLineByIndex(3):SetLabel(GameUtils:formatTimeStyle1(time))
        return self
    end
    return item
end

function GameUITownHall:CreateTimerItemWithListView(list_view)
    local widget = WidgetWithBlueTitle.new(180, _("税收")):align(display.CENTER)
    local size = widget:getContentSize()
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("获得银币"),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(widget, 2):align(display.LEFT_CENTER, 40, size.height - 80)
    cc.ui.UIImage.new("coin_icon.png"):addTo(widget, 2):align(display.CENTER, 300, size.height - 80):scale(0.25)
    local label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "20000",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(widget, 2):align(display.LEFT_CENTER, 300 + 20, size.height - 80)


    local progress = WidgetProgress.new():addTo(widget, 2)
        :align(display.LEFT_CENTER, 60, size.height - 125)

    WidgetPushButton.new({normal = "green_btn_up_169x86.png", pressed = "green_btn_down_169x86.png"})
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(widget, 2):align(display.CENTER, size.width - 120, size.height - 110)
        :onButtonClicked(function(event)
        end)

    local item = list_view:newItem()
    item:addContent(widget)
    item:setItemSize(widget:getContentSize().width, widget:getContentSize().height + 10)

    function item:SetProgressInfo(label, percent)
        progress:SetProgressInfo(label, percent)
        return self
    end
    function item:SetNumberLabel(str)
        if label:getString() ~= str then
            label:setString(str)
        end
        return self
    end
    function item:RefreshByEvent(event, current_time)
        return self:SetNumberLabel(event:Value())
            :SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)),
                event:Percent(current_time))
    end
    return item
end

-- function GameUITownHall:CreateGetItemWithListView(list_view)
--     local widget = WidgetWithBlueTitle.new(180, _("税收")):align(display.CENTER)
--     local size = widget:getContentSize()

--     cc.ui.UILabel.new({
--         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
--         text = "征收银币完成",
--         size = 24,
--         font = UIKit:getFontFilePath(),
--         align = cc.ui.TEXT_ALIGN_RIGHT,
--         color = UIKit:hex2c3b(0x403c2f)
--     }):addTo(widget, 2):align(display.LEFT_CENTER, 40, size.height - 90)

--     cc.ui.UILabel.new({
--         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
--         text = "获得银币",
--         size = 20,
--         font = UIKit:getFontFilePath(),
--         align = cc.ui.TEXT_ALIGN_RIGHT,
--         color = UIKit:hex2c3b(0x615b44)
--     }):addTo(widget, 2):align(display.LEFT_CENTER, 40, size.height - 135)
--     cc.ui.UIImage.new("coin_icon.png"):addTo(widget, 2):align(display.CENTER, 200, size.height - 135):scale(0.25)
--     local get_label = cc.ui.UILabel.new({
--         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
--         size = 20,
--         font = UIKit:getFontFilePath(),
--         align = cc.ui.TEXT_ALIGN_RIGHT,
--         color = UIKit:hex2c3b(0x403c2f)
--     }):addTo(widget, 2):align(display.LEFT_CENTER, 200 + 20, size.height - 135)

--     WidgetPushButton.new(
--         {normal = "yellow_btn_up_185x65.png", pressed = "yellow_btn_down_185x65.png"},
--         {scale9 = false}
--     ):setButtonLabel(cc.ui.UILabel.new({
--         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
--         text = _("获得"),
--         size = 24,
--         font = UIKit:getFontFilePath(),
--         color = UIKit:hex2c3b(0xfff3c7)}))
--         :addTo(widget, 2):align(display.CENTER, size.width - 120, size.height - 120)
--         :onButtonClicked(function(event)
--             -- self.town_hall:GetTax()
--         end)

--     local item = list_view:newItem()
--     item:addContent(widget)
--     item:setItemSize(widget:getContentSize().width, widget:getContentSize().height + 10)


--     function item:SetGetLabel(str)
--         if get_label:getString() ~= str then
--             get_label:setString(str)
--         end
--         return self
--     end

--     return item
-- end

function GameUITownHall:CreateDwellingLineItem(width)
    local left, right = -width/2, width/2
    local node = display.newNode()
    local condition = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x615b44)
    }):addTo(node, 2):align(display.LEFT_CENTER, left + 30, 0)

    cc.ui.UILabel.new({
        text = string.format("%s%%5%s", _("增加"), _("城民增长")),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x615b44)
    }):addTo(node, 2):align(display.RIGHT_CENTER, right - 70, 0)

    local check = cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "no_40x40.png" })
        :addTo(node)
        :align(display.CENTER, right - 40, 0)
        :setButtonSelected(true)
    check:setTouchEnabled(false)

    cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(node, 2)
        :setLayoutSize(570, 3):align(display.CENTER, 0, -20)


    function node:align()
        assert("you should not use this function for any purpose!")
    end
    function node:SetCondition(current, max)
        local str = string.format("%s %d/%d", _("达到"), current > max and max or current, max)
        if condition:getString() ~= str then
            condition:setString(str)
        end
        check:setButtonSelected(max <= current)
        return self
    end
    return node
end
function GameUITownHall:CreateTaxLineItem(width, param)
    local left, right = -width/2, width/2
    local node = display.newNode()
    cc.ui.UIImage.new(param.icon):addTo(node, 2)
        :align(display.BOTTOM_CENTER, left + 40, 0):scale(param.scale)
    cc.ui.UILabel.new({
        text = param.title,
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x615b44)
    }):addTo(node, 2):align(display.LEFT_BOTTOM, left + 70, 0)

    local label = cc.ui.UILabel.new({
        text = "增加 5% 城民增长",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x615b44)
    }):addTo(node, 2):align(display.RIGHT_BOTTOM, right - 30, 0)

    cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(node, 2)
        :setLayoutSize(570, 3):align(display.CENTER, 0, -5)

    function node:align()
        assert("you should not use this function for any purpose!")
    end
    function node:SetLabel(str)
        if label:getString() ~= str then
            label:setString(str)
        end
        return self
    end
    return node
end


return GameUITownHall











































