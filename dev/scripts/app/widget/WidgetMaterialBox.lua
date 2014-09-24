local WidgetPushButton = import(".WidgetPushButton")
local WidgetMaterialBox = class("WidgetMaterialBox", function()
    return display.newNode()
end)

function WidgetMaterialBox:ctor(material_png,cb,is_has_i_icon)
    self.material_bg = WidgetPushButton.new({normal = "icon_background_wareHouseUI.png",
        pressed = "icon_background_wareHouseUI.png"}):align(display.LEFT_BOTTOM):addTo(self)
    if cb then
        self.material_bg:onButtonClicked(cb)
    end
        
    local rect = self.material_bg:getCascadeBoundingBox()

    local material = cc.ui.UIImage.new(material_png):addTo(self.material_bg)
        :align(display.LEFT_BOTTOM, 5, 5)
    if is_has_i_icon then
        local material_bg_i = cc.ui.UIImage.new("back_ground_i_46X45.png"):addTo(self.material_bg,2)
            :align(display.BOTTOM_RIGHT, rect.width, 0)
    end

    local number_bg = cc.ui.UIImage.new("number_bg_114X31.png"):addTo(self.material_bg)
        :align(display.LEFT_BOTTOM, 0, 0)

    local size = number_bg:getContentSize()
    self.number = cc.ui.UILabel.new({
        -- text = "0/99",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(number_bg):align(display.CENTER, size.width / 2, 16)
end
function WidgetMaterialBox:SetNumber(number)
    self.number:setString(number)
    return self
end

return WidgetMaterialBox









