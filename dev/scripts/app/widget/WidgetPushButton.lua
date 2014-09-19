local MOVE_EVENT = "MOVE_EVENT"
local UIPushButton = cc.ui.UIPushButton
local WidgetPushButton = class("WidgetPushButton", UIPushButton)
function WidgetPushButton:ctor(...)
    WidgetPushButton.super.ctor(self, ...)
    self.pre_pos = nil
    self:onButtonPressed(function(event)
        self.pre_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
    end)
    self:addEventListener(MOVE_EVENT, function(event)
        local cur_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
        if event.touchInTarget and cc.pGetDistance(cur_pos, self.pre_pos) > 10 then
            if event.target.fsm_:canDoEvent("release") then
                event.target.fsm_:doEvent("release")
            end
        end
    end)
    self:setTouchSwallowEnabled(false)
end
function WidgetPushButton:onTouch_(event)
    -- print("----UIPushButton:onTouch_")
    local name, x, y = event.name, event.x, event.y
    -- print("----name, x, y = ", name, x, y)
    if name == "began" then
        -- print("----began")
        if not self:checkTouchInSprite_(x, y) then return false end
        -- print("----doEvent('press')")
        self.fsm_:doEvent("press")
        self:dispatchEvent({name = UIPushButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        return true
    end

    local touchInTarget = self:checkTouchInSprite_(x, y)
    if name == "moved" then
        if touchInTarget then
            self:dispatchEvent({name = MOVE_EVENT, x = x, y = y, touchInTarget = true})
        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIPushButton.RELEASE_EVENT, x = x, y = y, touchInTarget = false})
        end
    else
        local is_pressed = self.fsm_:isState("pressed")
        if self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIPushButton.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
        end
        if name == "ended" and is_pressed and touchInTarget then
            self:dispatchEvent({name = UIPushButton.CLICKED_EVENT, x = x, y = y, touchInTarget = true})
        end
    end
end



return WidgetPushButton






