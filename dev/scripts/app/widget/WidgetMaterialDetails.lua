local UIListView = import('..ui.UIListView')
local WidgetPushButton = import(".WidgetPushButton")
local WidgetMaterialBox = import("..widget.WidgetMaterialBox")
local MaterialManager = import("..entity.MaterialManager")
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
local WidgetMaterialDetails = class("WidgetMaterialDetails", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function WidgetMaterialDetails:ctor(material_type,material_name)
    self:InitMaterialDetails(material_type,material_name)
end

function WidgetMaterialDetails:InitMaterialDetails(material_type,material_name)
    -- bg
    local bg = display.newScale9Sprite("full_screen_dialog_bg.png", display.cx, display.top-480,cc.size(608,506)):addTo(self)
    local bg_width,bg_height = bg:getContentSize().width,bg:getContentSize().height
    -- title bg
    display.newSprite("Title_blue.png", bg_width/2,bg_height-30):addTo(bg,2)
    -- soldier_name label
    self.soldier_name_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _(material_name),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER,30,bg_height-30):addTo(bg,2)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent(true)
        end):align(display.CENTER, bg_width-20, bg_height-20):addTo(bg,2)
    -- 材料icon
    local materialBox = WidgetMaterialBox.new(material_type,material_name)
    local num = City:GetMaterialManager():GetMaterialsByType(material_type)[material_name].."/"..City:GetBuildingByType("materialDepot")[1]:GetMaxMaterial()
    materialBox:SetNumber(num)
    materialBox:addTo(self):pos(display.cx - 285, display.top -410)
    -- 材料介绍
    self.material_introduce = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("材料介绍"),
            font = UIKit:getFontFilePath(),
            size = 22,
            valign = ui.TEXT_VALIGN_TOP,
            dimensions = cc.size(320, 120),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_TOP, display.cx - 130, display.top -290)
        :addTo(self)
    -- 来源渠道
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("来源渠道"),
            font = UIKit:getFontFilePath(),
            size = 22,
            valign = ui.TEXT_VALIGN_TOP,
            -- dimensions = cc.size(320, 120),
            color = UIKit:hex2c3b(0x5a5544)
        }):align(display.CENTER, display.cx, display.top -430)
        :addTo(self)
    -- listview
    self.origin_listview = UIListView.new{
        -- bgColor = cc.c4b(200, 200, 0, 170),
        bg ="back_ground_571X253.png",
        bgScale9 = true,
        viewRect = cc.rect(display.cx-286, display.top-700, 571, 253),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)
   self.origin_listview:addItem(self:CreateOriginItem(self.origin_listview))
   self.origin_listview:addItem(self:CreateOriginItem(self.origin_listview))
   self.origin_listview:addItem(self:CreateOriginItem(self.origin_listview))
   self.origin_listview:addItem(self:CreateOriginItem(self.origin_listview))
   self.origin_listview:addItem(self:CreateOriginItem(self.origin_listview))
   self.origin_listview:reload()
end

function WidgetMaterialDetails:CreateOriginItem(listView)
    local item = listView:newItem()
    item:setItemSize(571,65)
    local bg = display.newSprite("back_ground_568X62.png")
    local size_bg = bg:getContentSize()
    -- star icon 
    display.newSprite("stars_23X22.png"):align(display.LEFT_CENTER, 10, size_bg.height/2):addTo(bg)
    -- 来源 label
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("工具作坊生产"),
            font = UIKit:getFontFilePath(),
            size = 22,
            valign = ui.TEXT_VALIGN_TOP,
            -- dimensions = cc.size(320, 120),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER, size_bg.width/2,  size_bg.height/2)
        :addTo(bg)
    -- 来源链接button
    WidgetPushButton.new({normal = "X_62X62_2.png",
        pressed = "X_62X62_1.png"}):align(display.CENTER_RIGHT,size_bg.width, size_bg.height/2):addTo(bg)
        :onButtonClicked(function (  )
            print("链接到资源来源")
        end):addChild(display.newSprite("arrow_19X27.png",-31,0))
    item:addContent(bg)
    return item
end

return WidgetMaterialDetails




