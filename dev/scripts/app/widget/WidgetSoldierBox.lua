local WidgetSoldierBox = class("WidgetSoldierBox", function()
    return display.newNode()
end)


function WidgetSoldierBox:ctor(soldier_png)
    self.soldier_bg = cc.ui.UIImage.new("star1_114x128.png"):addTo(self)
    local size = self.soldier_bg:getContentSize()

    local soldier = cc.ui.UIImage.new(soldier_png):addTo(self.soldier_bg)
    :align(display.CENTER, size.width/2, size.height/2):scale(0.7)

    local number_bg = cc.ui.UIImage.new("number_bg_107x36.png"):addTo(self.soldier_bg)
    :align(display.CENTER, size.width/2, 0)

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
    self:setPosition(x, y)
    return self
end
function WidgetSoldierBox:alignByPoint(point, x, y)
    self.soldier_bg:setAnchorPoint(point)
    if x and y then self:setPosition(x, y) end
    return self
end


return WidgetSoldierBox





