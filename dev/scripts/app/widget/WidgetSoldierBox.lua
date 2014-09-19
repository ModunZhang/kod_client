local WidgetPushButton = import(".WidgetPushButton")
local WidgetSoldierBox = class("WidgetSoldierBox", function()
    return display.newNode()
end)


function WidgetSoldierBox:ctor(soldier_png,cb)
    self.soldier_bg = WidgetPushButton.new({normal = "star1_114x128.png",
        pressed = "star1_114x128.png"}):addTo(self)
        :onButtonClicked(cb)
    local rect = self.soldier_bg:getCascadeBoundingBox()

    local soldier = cc.ui.UIImage.new(soldier_png):addTo(self.soldier_bg)
        :align(display.CENTER, 0, 10):scale(0.7)

    local number_bg = cc.ui.UIImage.new("number_bg_107x36.png"):addTo(self)
        :align(display.CENTER, 0, - rect.height / 2 + 5)

    local size = number_bg:getContentSize()
    self.number = cc.ui.UILabel.new({
        text = "1000",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x423f32)
    }):addTo(number_bg):align(display.CENTER, size.width / 2, size.height / 2)
end
function WidgetSoldierBox:SetNumber(number)
    self.number:setString(number)
end
function WidgetSoldierBox:align(anchorPoint, x, y)
    self.soldier_bg:align(anchorPoint)
    if x and y then self:setPosition(x, y) end
    return self
end
function WidgetSoldierBox:alignByPoint(point, x, y)
    self.soldier_bg:setAnchorPoint(point)
    if x and y then self:setPosition(x, y) end
    return self
end


return WidgetSoldierBox







