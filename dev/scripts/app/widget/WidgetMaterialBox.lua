local WidgetPushButton = import(".WidgetPushButton")
local MaterialManager = import("..entity.MaterialManager")

local WidgetMaterialBox = class("WidgetMaterialBox", function()
    return display.newNode()
end)
local DRAGON_MATERIAL_PIC_MAP = {
    ["ironIngot"] = "ironIngot_92x92.png",
    ["steelIngot"] = "steelIngot_92x92.png",
    ["mithrilIngot"] = "mithrilIngot_92x92.png",
    ["blackIronIngot"] = "blackIronIngot_92x92.png",
    ["arcaniteIngot"] = "arcaniteIngot_92x92.png",
    ["wispOfFire"] = "wispOfFire_92x92.png",
    ["wispOfCold"] = "wispOfCold_92x92.png",
    ["wispOfWind"] = "wispOfWind_92x92.png",
    ["lavaSoul"] = "lavaSoul_92x92.png",
    ["iceSoul"] = "iceSoul_92x92.png",
    ["forestSoul"] = "forestSoul_92x92.png",
    ["infernoSoul"] = "infernoSoul_92x92.png",
    ["blizzardSoul"] = "blizzardSoul_92x92.png",
    ["fairySoul"] = "fairySoul_92x92.png",
    ["moltenShard"] = "moltenShard_92x92.png",
    ["glacierShard"] = "glacierShard_92x92.png",
    ["chargedShard"] = "chargedShard_92x92.png",
    ["moltenShiver"] = "moltenShiver_92x92.png",
    ["glacierShiver"] = "glacierShiver_92x92.png",
    ["chargedShiver"] = "chargedShiver_92x92.png",
    ["moltenCore"] = "moltenCore_92x92.png",
    ["glacierCore"] = "glacierCore_92x92.png",
    ["chargedCore"] = "chargedCore_92x92.png",
    ["moltenMagnet"] = "moltenMagnet_92x92.png",
    ["glacierMagnet"] = "glacierMagnet_92x92.png",
    ["chargedMagnet"] = "chargedMagnet_92x92.png",
    ["challengeRune"] = "challengeRune_92x92.png",
    ["suppressRune"] = "suppressRune_92x92.png",
    ["rageRune"] = "rageRune_92x92.png",
    ["guardRune"] = "guardRune_92x92.png",
    ["poisonRune"] = "poisonRune_92x92.png",
    ["giantRune"] = "giantRune_92x92.png",
    ["dolanRune"] = "dolanRune_92x92.png",
    ["warsongRune"] = "warsongRune_92x92.png",
    ["infernoRune"] = "infernoRune_92x92.png",
    ["arcanaRune"] = "arcanaRune_92x92.png",
    ["eternityRune"] = "eternityRune_92x92.png"
}
function WidgetMaterialBox:ctor(material_type,material_name,cb,is_has_i_icon)
    self.material_bg = WidgetPushButton.new({normal = "icon_background_wareHouseUI.png",
        pressed = "icon_background_wareHouseUI.png"}):align(display.LEFT_BOTTOM):addTo(self)
    if cb then
        self.material_bg:onButtonClicked(cb)
    end
        
    local rect = self.material_bg:getCascadeBoundingBox()

    local material = cc.ui.UIImage.new(material_type==MaterialManager.MATERIAL_TYPE.DRAGON and DRAGON_MATERIAL_PIC_MAP[material_name] or "material_blueprints.png"):addTo(self.material_bg)
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

    self.name = cc.ui.UILabel.new({
        text = material_name,
        size = 16,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(self.material_bg):align(display.CENTER, size.width / 2, rect.height-16)
end
function WidgetMaterialBox:SetNumber(number)
    self.number:setString(number)
    return self
end

return WidgetMaterialBox









