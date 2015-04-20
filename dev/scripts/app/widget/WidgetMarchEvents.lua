local promise = import("..utils.promise")
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

------
function WidgetMarchEvents:ctor(ratio)
    self.view_rect = cc.rect(0, 0, WIDGET_WIDTH * ratio, (WIDGET_HEIGHT) * ratio)
    self:setClippingRegion(self.view_rect)
    self.node = display.newNode():addTo(self):scale(ratio)
    cc.Layer:create():addTo(self.node):pos(0, -WIDGET_HEIGHT):setContentSize(cc.size(WIDGET_WIDTH, WIDGET_HEIGHT)):setCascadeOpacityEnabled(true)
    self.hide_btn = self:CreateHideButton():addTo(self.node)
    self.back_ground = self:CreateBackGround():addTo(self.node)
    self:Reset()
end
function WidgetMarchEvents:onExit()
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
    }):align(display.LEFT_BOTTOM, 0, - ITEM_HEIGHT-2):setLayoutSize(WIDGET_WIDTH, ITEM_HEIGHT + 2)
    return back
end
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
    return cocos_promise.promiseOfMoveTo(self.node, 0, self:HidePosY(), 0.15, "sineIn"):next(function()
        self:Reset()
    end)
end
function WidgetMarchEvents:HidePosY()
    return - self.back_ground:getContentSize().height
end
function WidgetMarchEvents:PromiseOfShow()
    if not self:OnBeforeShow() then
        return cocos_promise.defer()
    end
    self:Reset()
    self.node:stopAllActions()
    return cocos_promise.promiseOfMoveTo(self.node, 0, 0, 0.15, "sineIn"):next(function()
        self.arrow:flipY(false)
    end)
end
function WidgetMarchEvents:Reset()
    self:ResizeBelowHorizon(0)
    self.node:stopAllActions()
    self.arrow:flipY(true)
    self:Lock(false)
end
function WidgetMarchEvents:OnBeforeShow()
    return true
end
function WidgetMarchEvents:IsShow()
    return not self.arrow:isFlippedY()
end
function WidgetMarchEvents:ResizeBelowHorizon(new_height)
    local height = new_height < ITEM_HEIGHT and ITEM_HEIGHT or new_height
    local size = self.back_ground:getContentSize()
    self.back_ground:setContentSize(cc.size(size.width, height))
    self.node:setPositionY(- height)
end
-- function WidgetMarchEvents:ResetPosition()
--     self.node:setPositionY(self:HidePosY())
-- end
return WidgetMarchEvents















