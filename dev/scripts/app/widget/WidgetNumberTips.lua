local WidgetNumberTips = class("WidgetNumberTips", function()
    return display.newSprite("mail_unread_bg_36x23.png")
end)

function WidgetNumberTips:ctor()
    local size = self:getContentSize()
    self.label = cc.ui.UILabel.new({
        cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 16,
        color = UIKit:hex2c3b(0xf5f2b3)
    }):align(display.CENTER, size.width/2, size.height/2+4):addTo(self)
end

function WidgetNumberTips:SetNumber(number)
    number = number or 0
    if number > 0 then
        self.label:setString(number > 99 and "99+" or number)
        self:show()
    else
        self:hide()
    end
    return self
end





return WidgetNumberTips




