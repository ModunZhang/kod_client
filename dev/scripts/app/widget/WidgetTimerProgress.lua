local WidgetPushButton = import(".WidgetPushButton")
local WidgetTimerProgress = class("WidgetTimerProgress", function(...)
    return display.newNode(...)
end)

function WidgetTimerProgress:ctor(width, height)
    local width = width == nil and 549 or width
    local height = height == nil and 100 or height
    local back_ground_351x96 = cc.ui.UIImage.new("back_ground_351x96.png", {scale9 = true})
    :setLayoutSize(width, height)
    self.describe = cc.ui.UILabel.new({
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, 15, height - 20)


    local progress_bg_311x35 = cc.ui.UIImage.new("progress_bg_311x35.png")
        :addTo(back_ground_351x96, 2):align(display.LEFT_CENTER, 35, 40)
    self.progress_timer = display.newProgressTimer("progress_bar_315x33.png", display.PROGRESS_TIMER_BAR)
        :align(display.LEFT_BOTTOM, 0, 0):addTo(progress_bg_311x35, 2):pos(-4, 1)
    self.progress_timer:setBarChangeRate(cc.p(1,0))
    self.progress_timer:setMidpoint(cc.p(0,0))

    self.progress_label = cc.ui.UILabel.new({
        size = 14,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xfdfac2)
    }):addTo(progress_bg_311x35, 2):align(display.LEFT_CENTER, 35, 20)


    local back_ground_43x43 = cc.ui.UIImage.new("back_ground_43x43.png")
        :addTo(back_ground_351x96, 2):align(display.CENTER, 35, 40)
    local pos = back_ground_43x43:getAnchorPointInPoints()
    cc.ui.UIImage.new("hourglass_39x46.png"):addTo(back_ground_43x43):align(display.CENTER, pos.x, pos.y):scale(0.8)


    self.button = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("加速"),
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(back_ground_351x96, 2)
        :align(display.CENTER, width - 100, height / 2)

    back_ground_351x96:addTo(self)
    self.back_ground = back_ground_351x96
end
function WidgetTimerProgress:OnButtonClicked(func)
    self.button:onButtonClicked(function(event)
        func(event)
    end)
    return self
end
function WidgetTimerProgress:SetDescribe(describe)
    self.describe:setString(describe)
    return self
end
function WidgetTimerProgress:SetProgressInfo(time_label, percent)
    self.progress_label:setString(time_label)
    self.progress_timer:setPercentage(percent)
    return self
end
function WidgetTimerProgress:align(anchorPoint, x, y)
    self.back_ground:align(anchorPoint)
    if x and y then self:setPosition(x, y) end
    return self
end



return WidgetTimerProgress






