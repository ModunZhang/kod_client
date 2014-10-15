local WidgetProgress = class("WidgetProgress", function(...)
    return display.newNode(...)
end)

function WidgetProgress:ctor(label_color, bg, bar)
    local progress_bg = cc.ui.UIImage.new(bg == nil and "progress_bg_311x35.png" or bg)
        :addTo(self, 2):align(display.LEFT_BOTTOM)
    self.progress_timer = display.newProgressTimer(bar == nil and "progress_bar_315x33.png" or bar, display.PROGRESS_TIMER_BAR)
        :align(display.LEFT_BOTTOM, 0, 0):addTo(progress_bg, 2):pos(-4, 1)
    self.progress_timer:setBarChangeRate(cc.p(1,0))
    self.progress_timer:setMidpoint(cc.p(0,0))

    self.progress_label = cc.ui.UILabel.new({
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = label_color == nil and UIKit:hex2c3b(0xfdfac2) or label_color
    }):addTo(progress_bg, 2):align(display.LEFT_CENTER, 35, 20)

    local back_ground_43x43 = cc.ui.UIImage.new("back_ground_43x43.png")
        :addTo(progress_bg, 2):align(display.CENTER, 0, progress_bg:getContentSize().height/2)
    local pos = back_ground_43x43:getAnchorPointInPoints()
    cc.ui.UIImage.new("hourglass_39x46.png"):addTo(back_ground_43x43):align(display.CENTER, pos.x, pos.y):scale(0.8)

    self.back_ground = progress_bg
end
function WidgetProgress:SetProgressInfo(time_label, percent)
    if self.progress_label:getString() ~= time_label then
        self.progress_label:setString(time_label)
    end
    self.progress_timer:setPercentage(percent)
    return self
end
function WidgetProgress:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint)
    if x and y then self:setPosition(x, y) end
    return self
end



return WidgetProgress







