local WidgetPushButton = import(".WidgetPushButton")
local MaterialManager = import("..entity.MaterialManager")
local UILib = import("..ui.UILib")

local WidgetMaterialBox = class("WidgetMaterialBox", function()
    return display.newNode()
end)

function WidgetMaterialBox:ctor(material_type,material_name,cb,is_has_i_icon)
    self.material_bg = WidgetPushButton.new({normal = "box_blue_124x124.png",
        pressed = "box_blue_124x124.png"}):align(display.LEFT_BOTTOM):addTo(self)
    if cb then
        self.material_bg:onButtonClicked(cb)
    end
        
    local rect = self.material_bg:getCascadeBoundingBox()

    local material = cc.ui.UIImage.new(self:GetMaterialImage(material_type,material_name)):addTo(self.material_bg)
        :align(display.LEFT_BOTTOM, 5, 5)
    -- if is_has_i_icon then
    --     local material_bg_i = cc.ui.UIImage.new("back_ground_i_46X45.png"):addTo(self.material_bg,2)
    --         :align(display.BOTTOM_RIGHT, rect.width, 0)
    -- end

    self.number_bg = cc.ui.UIImage.new("box_number_bg_124x53.png"):addTo(self.material_bg)
        :align(display.LEFT_BOTTOM, 0, -42)
        :hide()
    local number_bg = self.number_bg 

    local size = number_bg:getContentSize()
    self.number = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f
    }):addTo(number_bg):align(display.CENTER, size.width / 2, 26)

    self.name = cc.ui.UILabel.new({
        text = material_name,
        size = 16,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(self.material_bg):align(display.CENTER, size.width / 2, rect.height-16)
end
function WidgetMaterialBox:SetNumber(number)
    self.number_bg:show()
    self.number:setString(number)
    return self
end

function WidgetMaterialBox:GetMaterialImage(material_type,material_name)
    local metarial = ""
    if material_type == MaterialManager.MATERIAL_TYPE.BUILD then
        metarial = "materials"
    elseif material_type == MaterialManager.MATERIAL_TYPE.DRAGON  then
        metarial = "dragon_material_pic_map"
    elseif material_type == MaterialManager.MATERIAL_TYPE.SOLDIER  then
        metarial = "soldier_metarial"
    elseif material_type == MaterialManager.MATERIAL_TYPE.EQUIPMENT  then 
        metarial = "equipment"
    end
    return UILib[metarial][material_name]
end


return WidgetMaterialBox









