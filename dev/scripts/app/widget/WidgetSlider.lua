local promise = import("..utils.promise")
local MOVE_EVENT = "MOVE_EVENT"
local UISlider = cc.ui.UISlider
local WidgetSlider = class("WidgetSlider", UISlider)
function WidgetSlider:ctor(direction, images, options)
    self.callbacks = {}
    WidgetSlider.super.ctor(self, direction, images, options)
    if images.progress then
        local rect = self.barSprite_:getBoundingBox()
        self.progress = display.newProgressTimer(images.progress, display.PROGRESS_TIMER_BAR)
            :addTo(self, 1):align(display.CENTER, rect.x + rect.width/2, rect.y + rect.height/2)
        self.progress:setBarChangeRate(cc.p(1,0))
        self.progress:setMidpoint(cc.p(0,0))
        self.buttonSprite_:setLocalZOrder(2)
    end

end
function WidgetSlider:setSliderSize(width, height)
    local rect = self.barSprite_:getBoundingBox()

    local old_widht = rect.width 
    WidgetSlider.super.setSliderSize(self,width, height)
    self:updateButtonPosition_()
    self.progress:setScaleX(width*(self.progress:getContentSize().width/old_widht)/self.progress:getContentSize().width)
    local rect = self.barSprite_:getBoundingBox()
    self.progress:align(display.CENTER, rect.x + rect.width/2, rect.y + rect.height/2)

    -- self.progress:setScaleY(height/self.progress:getContentSize().height)
end
function WidgetSlider:align(align, x, y)
    WidgetSlider.super.align(self,align, x, y)
    self.progress:align(align)
end
function WidgetSlider:onSliderValueChanged(callback)
    return WidgetSlider.super.onSliderValueChanged(self, function(event)
        local percent = math.floor((event.value- self.min_)/ (self.max_ - self.min_) * 100)
        if self.progress then
            self.progress:setPercentage(percent)
        end
        callback(event)
        self:CheckProgress(percent)
    end)
end
function WidgetSlider:Max(max)
    self.max_ = max
    self:updateButtonPosition_()
    self:dispatchEvent({name = UISlider.VALUE_CHANGED_EVENT, value = self.value_})
    return self
end
function WidgetSlider:Min(min)
    self.min_ = min
    self:updateButtonPosition_()
    self:dispatchEvent({name = UISlider.VALUE_CHANGED_EVENT, value = self.value_})
    return self
end
function WidgetSlider:align(...)
    WidgetSlider.super.align(self, ...)
    local rect = self.barSprite_:getBoundingBox()
    self.progress:align(display.CENTER, rect.x + rect.width/2, rect.y + rect.height/2)
    return self
end
function WidgetSlider:CheckProgress(progress)
    local callbacks = self.callbacks
    if #callbacks > 0 and callbacks[1](progress) then
        table.remove(callbacks, 1)
    end
end
function WidgetSlider:PromiseOfProgress(percent)
    local callbacks = self.callbacks
    assert(#callbacks == 0)
    local p = promise.new()
    table.insert(callbacks, function(val)
        if percent == val then
            self.onTouch_ = function() end
            p:resolve(self)
            return true
        end
    end)
    return p
end


return WidgetSlider








