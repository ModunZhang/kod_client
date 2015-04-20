local promise = import("..utils.promise")
local MarchAttackEvent = import("..entity.MarchAttackEvent")
local Alliance = import("..entity.Alliance")
local cocos_promise = import("..utils.cocos_promise")
local WidgetPushButton = import("..widget.WidgetPushButton")
local timer = app.timer
local WIDGET_WIDTH = 640
local WIDGET_HEIGHT = 600
local ITEM_HEIGHT = 47
local WidgetMarchEvents = class("WidgetMarchEvents", function()
    local rect = cc.rect(0, 0, WIDGET_WIDTH, WIDGET_HEIGHT)
    local node = display.newClippingRegionNode(rect)
    node:setTouchEnabled(true)
    node.view_rect = rect
    node.locked = false
    node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
        if node.locked then
            return false
        end
        if ("began" == event.name or "moved" == event.name or "ended" == event.name)
            and node:isTouchInViewRect(event) then
            return true
        else
            return false
        end
    end)
    return node:setCascadeOpacityEnabled(true)
end)
function WidgetMarchEvents:isTouchInViewRect(event)
    local viewRect = self:convertToWorldSpace(cc.p(self.view_rect.x, self.view_rect.y))
    viewRect.width = self.view_rect.width
    viewRect.height = self.view_rect.height
    return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end
---------------------------



function WidgetMarchEvents:OnMarchEventRefreshed()
    self:PromiseOfSwitch()
end
function WidgetMarchEvents:OnAttackMarchEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map,false)
end

function WidgetMarchEvents:OnAttackMarchReturnEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map,false)
end

function WidgetMarchEvents:OnStrikeMarchEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map,true)
end

function WidgetMarchEvents:OnStrikeMarchReturnEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map,true)
end
function WidgetMarchEvents:ManagerCorpsFromChangedMap(changed_map,is_strkie)
    if changed_map.removed then
        table.foreachi(changed_map.removed,function(_,marchEvent)
            dump(event, "removed")
            self:PromiseOfSwitch()
            return true
        end)
    elseif changed_map.edited then
        table.foreachi(changed_map.edited,function(_,marchEvent)
            dump(marchEvent, "edited")
            self:PromiseOfSwitch()
            return true
        end)
    elseif changed_map.added then
        table.foreachi(changed_map.added,function(_,marchEvent)
            dump(marchEvent, "added")
            self:PromiseOfSwitch()
            return true
        end)
    end
end
function WidgetMarchEvents:AddOrRemoveAllianceEvent(isAdd)
    if isAdd then
        local v = self.alliance
        v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
        v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
        v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
        v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
        v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnMarchEventRefreshed)
    else
        local v = self.alliance
        v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
        v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
        v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
        v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
        v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnMarchEventRefreshed)

    end
end



---------------------------
function WidgetMarchEvents:ctor(alliance, ratio)
    self.alliance = alliance
    self.view_rect = cc.rect(0, 0, WIDGET_WIDTH * ratio, (WIDGET_HEIGHT) * ratio)
    self:setClippingRegion(self.view_rect)

    self.item_array = {}
    self.node = display.newNode():addTo(self):scale(ratio)
    cc.Layer:create():addTo(self.node):pos(0, -WIDGET_HEIGHT):setContentSize(cc.size(WIDGET_WIDTH, WIDGET_HEIGHT)):setCascadeOpacityEnabled(true)
    self.hide_btn = self:CreateHideButton():addTo(self.node)
    self.back_ground = self:CreateBackGround():addTo(self.node)
    self:Reset()
    self:AddOrRemoveAllianceEvent(true)
end
function WidgetMarchEvents:onExit()
    self:AddOrRemoveAllianceEvent(false)
end
function WidgetMarchEvents:CreateHideButton()
    local btn = cc.ui.UIPushButton.new({normal = "march_hide_btn_up.png",
        pressed = "march_hide_btn_down.png"})
        :align(display.CENTER_BOTTOM, WIDGET_WIDTH/2, 0)
        :onButtonClicked(function(event)
            if not self:IsShow() then
                self:PromiseOfShow()
            else
                self:PromiseOfHide()
            end
        end)
    local size = btn:getCascadeBoundingBox()
    self.arrow = cc.ui.UIImage.new("march_hide_arrow.png")
        :addTo(btn):align(display.CENTER, 0, size.height/2)
    return btn
end
function WidgetMarchEvents:CreateBackGround()
    local back = cc.ui.UIImage.new("tab_background_640x106.png", {scale9 = true,
        capInsets = cc.rect(2, 2, WIDGET_WIDTH - 4, 106 - 4)
    }):align(display.LEFT_BOTTOM):setLayoutSize(WIDGET_WIDTH, ITEM_HEIGHT + 2)
    return back
end
--
function WidgetMarchEvents:InsertItem(item, pos)
    if type(item) == "table" then
        local count = #item
        for i = count, 1, -1 do
            self:InsertItem_(item[i], pos)
        end
    else
        self:InsertItem_(item, pos)
    end
    for i, v in ipairs(self.item_array) do
        v:pos(1, (i-1) * ITEM_HEIGHT + 25)
    end
end
function WidgetMarchEvents:InsertItem_(item, pos)
    item:addTo(self.back_ground, 2)
    if pos then
        table.insert(self.item_array, pos, item)
    else
        table.insert(self.item_array, item)
    end
end

--
function WidgetMarchEvents:Lock(lock)
    self.locked = lock
end
function WidgetMarchEvents:IsShow()
    return not self.arrow:isFlippedY()
end
function WidgetMarchEvents:PromiseOfSwitch()
    return self:PromiseOfHide():next(function()
        return self:PromiseOfShow()
    end)
end
function WidgetMarchEvents:PromiseOfHide()
    self.node:stopAllActions()
    self:Lock(true)
    local hide_height = - self.back_ground:getContentSize().height
    return cocos_promise.promiseOfMoveTo(self.node, 0, hide_height, 0.15, "sineIn"):next(function()
        self:Reset()
    end)
end
function WidgetMarchEvents:PromiseOfShow()
    if self:HasAnyMarchEvent() then
        self:Reload()
        self.node:stopAllActions()
        return cocos_promise.promiseOfMoveTo(self.node, 0, 0, 0.15, "sineIn"):next(function()
            self.arrow:flipY(false)
        end)
    end
    return cocos_promise.defer()
end
function WidgetMarchEvents:IsShow()
    return not self.arrow:isFlippedY()
end
function WidgetMarchEvents:Reload()
    self:Reset()
    self:Load()
end
function WidgetMarchEvents:Reset()
    self.back_ground:removeAllChildren()
    self.item_array = {}
    self:ResizeBelowHorizon(0)
    self.node:stopAllActions()
    self.arrow:flipY(true)
    self:Lock(false)
end
function WidgetMarchEvents:Load()
    local items = {}
    local alliance = self.alliance
    table.foreachi(alliance:GetAttackMarchEvents(),function(_,event)
        table.insert(items, self:CreateAttackItem(event))
    end)
    table.foreachi(alliance:GetAttackMarchReturnEvents(),function(_,event)
        table.insert(items, self:CreateReturnItem(event))
    end)
    table.foreachi(alliance:GetStrikeMarchEvents(),function(_,event)
        table.insert(items, self:CreateAttackItem(event))
    end)
    table.foreachi(alliance:GetStrikeMarchReturnEvents(),function(_,event)
        table.insert(items, self:CreateReturnItem(event))
    end)
    self:InsertItem(items)
    self:ResizeBelowHorizon(self:Length(#self.item_array))
end
function WidgetMarchEvents:Length(array_len)
    return array_len * ITEM_HEIGHT + 2
end
function WidgetMarchEvents:ResizeBelowHorizon(new_height)
    local height = new_height < ITEM_HEIGHT and ITEM_HEIGHT or new_height
    local size = self.back_ground:getContentSize()
    self.back_ground:setContentSize(cc.size(size.width, height))
    self.node:setPositionY(- height)
    self.hide_btn:setPositionY(height)
end
function WidgetMarchEvents:CreateReturnItem(event)
    local node = display.newSprite("tab_event_bar.png"):align(display.LEFT_CENTER)
    local half_height = node:getContentSize().height / 2
    node.progress = display.newProgressTimer("tab_progress_bar.png",
        display.PROGRESS_TIMER_BAR):addTo(node)
        :align(display.LEFT_CENTER, 4, half_height)
    node.progress:setBarChangeRate(cc.p(1,0))
    node.progress:setMidpoint(cc.p(0,0))
    node.progress:setPercentage(50)
    node.desc = UIKit:ttfLabel({
        size = 16,
        color = 0xd1ca95,
    }):addTo(node):align(display.LEFT_CENTER, 10, half_height)

    node.speed_btn = WidgetPushButton.new({
        normal = "green_btn_up_154x39.png",
        pressed = "green_btn_down_154x39.png",
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(node):align(display.RIGHT_CENTER, WIDGET_WIDTH - 6, half_height)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
    return node
end
function WidgetMarchEvents:CreateAttackItem(event)
    local node = display.newSprite("tab_event_bar.png"):align(display.LEFT_CENTER)
    local half_height = node:getContentSize().height / 2
    node.progress = display.newProgressTimer("tab_progress_bar.png",
        display.PROGRESS_TIMER_BAR):addTo(node)
        :align(display.LEFT_CENTER, 4, half_height)
    node.progress:setBarChangeRate(cc.p(1,0))
    node.progress:setMidpoint(cc.p(0,0))
    node.progress:setPercentage(50)
    node.desc = UIKit:ttfLabel({
        size = 16,
        color = 0xd1ca95,
    }):addTo(node):align(display.LEFT_CENTER, 10, half_height)

    node.speed_btn = WidgetPushButton.new({
        normal = "march_speedup_btn_up.png",
        pressed = "march_speedup_btn_down.png",
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(node):align(display.RIGHT_CENTER, WIDGET_WIDTH - 6, half_height)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))


    node.return_btn = WidgetPushButton.new({
        normal = "march_return_btn_up.png",
        pressed = "march_return_btn_down.png",
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(node):align(display.RIGHT_CENTER, WIDGET_WIDTH - 6 - 78, half_height)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
    return node
end
function WidgetMarchEvents:CreateDefenceItem(event)
    local node = display.newSprite("tab_event_bar.png"):align(display.LEFT_CENTER)
    local half_height = node:getContentSize().height / 2
    node.progress = display.newProgressTimer("tab_progress_bar.png",
        display.PROGRESS_TIMER_BAR):addTo(node)
        :align(display.LEFT_CENTER, 4, half_height)
    node.progress:setBarChangeRate(cc.p(1,0))
    node.progress:setMidpoint(cc.p(0,0))
    node.progress:setPercentage(100)
    node.desc = UIKit:ttfLabel({
        size = 16,
        color = 0xd1ca95,
    }):addTo(node):align(display.LEFT_CENTER, 10, half_height)

    node.speed_btn = WidgetPushButton.new({
        normal = "green_btn_up_154x39.png",
        pressed = "green_btn_down_154x39.png",
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(node):align(display.RIGHT_CENTER, WIDGET_WIDTH - 6, half_height)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("撤防"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
    return node
end
function WidgetMarchEvents:HasAnyMarchEvent()
    local alliance = self.alliance
    return next(alliance:GetAttackMarchEvents()) or
        next(alliance:GetAttackMarchReturnEvents()) or
        next(alliance:GetStrikeMarchEvents()) or
        next(alliance:GetStrikeMarchReturnEvents())
end
return WidgetMarchEvents


















