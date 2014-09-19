local MOVE_EVENT = "MOVE_EVENT"
local UISlider = cc.ui.UISlider
local WidgetSlider = class("WidgetSlider", UISlider)
function WidgetSlider:ctor(direction, images, options)
    WidgetSlider.super.ctor(self, direction, images, options)
    if images.progress then
        local rect = self.barSprite_:getBoundingBox()
        self.progress = display.newProgressTimer(images.progress, display.PROGRESS_TIMER_BAR)
        :addTo(self, 1):align(display.CENTER, rect.x + rect.width/2, rect.y + rect.height/2)
        self.progress:setBarChangeRate(cc.p(1,0))
        self.progress:setMidpoint(cc.p(0,0))
    end
end
function WidgetSlider:onSliderValueChanged(callback)
    return WidgetSlider.super.onSliderValueChanged(self, function(event)
        if self.progress then
            self.progress:setPercentage(event.value)
        end
        callback(event)
    end)
end
function WidgetSlider:align(...)
    WidgetSlider.super.align(self, ...)
    local rect = self.barSprite_:getBoundingBox()
    self.progress:align(display.CENTER, rect.x + rect.width/2, rect.y + rect.height/2)
    return self
end


return WidgetSlider







