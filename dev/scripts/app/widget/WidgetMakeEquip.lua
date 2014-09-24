local EQUIPMENTS = GameDatas.SmithConfig.equipments
local Localize = import("..utils.Localize")
local MaterialManager = import("..entity.MaterialManager")
local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetUIBackGround2 = import(".WidgetUIBackGround2")
local WidgetMakeEquip = class("WidgetMakeEquip", function()
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    return node
end)
local STAR_BG = {
    "star1_105x104.png",
    "star2_105x104.png",
    "star3_105x104.png",
    "star4_105x104.png",
    "star5_105x104.png",
}
local DRAGON_BG = {
    redDragon = "star4_105x104.png",
    blueDragon = "star3_105x104.png",
    greenDragon = "star2_105x104.png",
}
local MATERIAL_MAP = {
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
local EQUIP_LOCALIZE = Localize.equip_material
local EQUIP_LOCALIZE = Localize.equip
local DRAGON_LOCALIZE = Localize.dragon
local BODY_LOCALIZE = Localize.body
function WidgetMakeEquip:ctor(equip_type, black_smith, city)
    self.equip_type = equip_type
    self.black_smith = black_smith
    self.city = city
    local equip_config = EQUIPMENTS[equip_type]
    self.matrials = LuaUtils:table_map(string.split(equip_config.materials, ","), function(k, v)
        return k, string.split(v, ":")
    end)
    self.equip_config = equip_config
    -- back_ground
    local back_ground = WidgetUIBackGround.new(650):addTo(self)

    -- title
    local size = back_ground:getContentSize()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png"):addTo(back_ground, 2)
        :align(display.CENTER, size.width/2, size.height - 49/2)

    -- title label
    local size = title_blue:getContentSize()
    self.title = cc.ui.UILabel.new({
        text = _("制造装备"),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue)
        :align(display.LEFT_CENTER, 20, size.height/2)

    -- X
    local x_btn = cc.ui.UIPushButton.new({normal = "x_up_66x66.png",
        pressed = "x_down_66x66.png"}):addTo(title_blue, 2)
        :align(display.CENTER, size.width - 15, size.height - 15)
        :onButtonClicked(function(event)
            self:Close()
        end)
    cc.ui.UIImage.new("x_31x28.png"):addTo(x_btn, 2):align(display.CENTER, 0, 0)


    -- 装备星级背景
    local bg = STAR_BG[equip_config.maxStar]
    local size = back_ground:getContentSize()
    local star_bg = cc.ui.UIImage.new(bg):addTo(back_ground, 2)
        :align(display.CENTER, 80, size.height - 115)


    -- 装备图标
    local pos = star_bg:getAnchorPointInPoints()
    cc.ui.UIImage.new("moltenCrown_128x128.png"):addTo(star_bg, 2)
        :align(display.CENTER, pos.x, pos.y):scale(0.8)

    -- 装备的数量背景
    local back_ground_97x20 = cc.ui.UIImage.new("back_ground_97x20.png"):addTo(star_bg, 2)
        :align(display.CENTER, pos.x, pos.y - 10 - 128/2)

    -- 装备数量label
    local pos = back_ground_97x20:getAnchorPointInPoints()
    self.number = cc.ui.UILabel.new({
        text = _("0 / 99"),
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground_97x20)
        :align(display.CENTER, pos.x, pos.y)


    -- 装备名字
    cc.ui.UILabel.new({
        text = EQUIP_LOCALIZE[equip_type],
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x29261c)
    }):addTo(back_ground)
        :align(display.LEFT_CENTER, 150, size.height - 70)


    -- used for dragon
    cc.ui.UILabel.new({
        text = string.format("%s%s%s", _("仅供"), DRAGON_LOCALIZE[equip_config.usedFor], _("装备")),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground)
        :align(display.LEFT_CENTER, 150, size.height - 110)

    cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(back_ground, 2)
        :setLayoutSize(430, 2):align(display.LEFT_CENTER, 150, size.height - 130)

    -- used for dragon category
    cc.ui.UILabel.new({
        text = BODY_LOCALIZE[equip_config.category],
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground)
        :align(display.LEFT_CENTER, 150, size.height - 150)

    cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(back_ground, 2)
        :setLayoutSize(430, 2):align(display.LEFT_CENTER, 150, size.height - 170)

    -- 立即建造
    local size = back_ground:getContentSize()
    local instant_button = cc.ui.UIPushButton.new({normal = "green_btn_up_250x65.png",
        pressed = "green_btn_down_250x65.png"}):addTo(back_ground)
        :align(display.CENTER, 150, size.height - 250)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("立即制造"),
            size = 24,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            NetManager:instantMakeDragonEquipment(equip_type, NOT_HANDLE)
            self:Close()
        end)

    -- gem
    cc.ui.UIImage.new("gem_66x56.png"):addTo(instant_button, 2)
        :align(display.CENTER, -100, -50):scale(0.5)

    -- gem count
    self.gem_label = cc.ui.UILabel.new({
        text = "600",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(instant_button, 2)
        :align(display.LEFT_CENTER, -100 + 20, -50)

    local size = back_ground:getContentSize()
    local button = cc.ui.UIPushButton.new({normal = "yellow_btn_up_185x65.png",
        pressed = "yellow_btn_down_185x65.png"}):addTo(back_ground)
        :align(display.CENTER, size.width - 130, size.height - 250)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("制造"),
            size = 24,
            color = UIKit:hex2c3b(0xfff3c7)
        }))
        :onButtonClicked(function(event)
            NetManager:makeDragonEquipment(equip_type, NOT_HANDLE)
            self:Close()
        end)

    -- 时间glass
    cc.ui.UIImage.new("hourglass_39x46.png"):addTo(button, 2)
        :align(display.LEFT_CENTER, -90, -55):scale(0.7)

    -- 时间
    local center = -20
    self.make_time = cc.ui.UILabel.new({
        text = GameUtils:formatTimeStyle1(equip_config.makeTime),
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(button, 2)
        :align(display.CENTER, center, -50)

    -- buff增益
    self.buff_time = cc.ui.UILabel.new({
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x068329)
    }):addTo(button, 2)
        :align(display.CENTER, center, -70)


    -- 需求框
    local size = back_ground:getContentSize()
    local need_bg = WidgetUIBackGround2.new(200):addTo(back_ground)
        :align(display.CENTER, size.width / 2, size.height - 440)

    -- 需求title
    local size = need_bg:getContentSize()
    local title_bg = cc.ui.UIImage.new("title_bg_566x36.png"):addTo(need_bg, 2)
        :align(display.CENTER, size.width / 2, size.height - 36/2 - 2)

    -- 需求label
    local pos = title_bg:getAnchorPointInPoints()
    cc.ui.UILabel.new({
        text = _("需要材料"),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(title_bg, 2)
        :align(display.CENTER, pos.x, pos.y)


    -- 需求列表
    local pos = need_bg:getAnchorPointInPoints()
    local unit_len, origin_y, gap_x = 105, 95, 80
    local len = #self.matrials
    local total_len = len * unit_len + (len - 1) * gap_x
    local origin_x = pos.x - total_len / 2 + unit_len / 2
    local materials_map = {}
    for i, v in ipairs(self.matrials) do
        local material_type = v[1]
        -- 材料背景根据龙的颜色来
        local material = cc.ui.UIImage.new(DRAGON_BG[equip_config.usedFor]):addTo(need_bg, 2)
            :align(display.CENTER, origin_x + (unit_len + gap_x) * (i - 1), origin_y)
        -- 材料icon
        local pos = material:getAnchorPointInPoints()
        local material_image = MATERIAL_MAP[material_type]
        cc.ui.UIImage.new(material_image):addTo(material, 2)
            :align(display.CENTER, pos.x, pos.y)
        -- 材料数量
        materials_map[i] = cc.ui.UILabel.new({
            size = 18,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            -- color = display.COLOR_RED
            color = UIKit:hex2c3b(0x403c2f)
        }):addTo(material, 2)
            :align(display.CENTER, pos.x, pos.y - material:getContentSize().height / 2 - 18)
    end
    self.materials_map = materials_map

    -- 建造队列
    cc.ui.UIImage.new("hammer_31x33.png"):addTo(back_ground, 2)
        :align(display.CENTER, 30, 80)

    self.build_label = cc.ui.UILabel.new({
        text = _("制造队列"),
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 60, 80)

    local size = back_ground:getContentSize()
    self.build_check_box = cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "no_40x40.png" })
        :addTo(back_ground)
        :align(display.LEFT_CENTER, size.width - 60, 80)
        :setButtonSelected(true)
    self.build_check_box:setTouchEnabled(false)

    cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(back_ground, 2)
        :setLayoutSize(570, 2):align(display.CENTER, size.width / 2, 80 - 22)

    -- 需要银币
    cc.ui.UIImage.new("coin_icon.png"):addTo(back_ground, 2)
        :align(display.CENTER, 30, 40):scale(0.3)

    self.coin_label = cc.ui.UILabel.new({
        text = _("银币"),
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 60, 40)

    local size = back_ground:getContentSize()
    self.coin_check_box = cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "no_40x40.png" })
        :addTo(back_ground)
        :align(display.LEFT_CENTER, size.width - 60, 40)
        :setButtonSelected(true)
    self.coin_check_box:setTouchEnabled(false)

    local size = back_ground:getContentSize()
    cc.ui.UIImage.new("dividing_line_594x2.png"):addTo(back_ground, 2)
        :setLayoutSize(570, 2):align(display.CENTER, size.width / 2, 40 - 22)



    self.back_ground = back_ground
end
function WidgetMakeEquip:onEnter()
    self.black_smith:AddBlackSmithListener(self)
    self.city:GetMaterialManager():AddObserver(self)
    self.city:GetResourceManager():AddObserver(self)

    
    self:UpdateEquipCounts()
    self:UpdateMaterials()
    self:UpdateBuildLabel(self.black_smith:IsEquipmentEventEmpty() and 0 or 1)
    self:UpdateCoin(self.city:GetResourceManager():GetCoinResource():GetValue())
    self:UpdateGemLabel()
    self:UpdateBuffTime()
end
function WidgetMakeEquip:onExit()
    self.black_smith:RemoveBlackSmithListener(self)
    self.city:GetMaterialManager():RemoveObserver(self)
    self.city:GetResourceManager():RemoveObserver(self)
end
-- 装备数量监听
function WidgetMakeEquip:OnMaterialsChanged(material_manager, material_type, changed)
    if material_type == MaterialManager.MATERIAL_TYPE.EQUIPMENT then
        local current = changed[self.equip_type]
        if current then
            self.number:setString(current.new)
        end
    end
end
-- 资源数量监听
function WidgetMakeEquip:OnResourceChanged(resource_manager)
    self:UpdateCoin(resource_manager:GetCoinResource():GetValue())
end
-- 建造队列监听
function WidgetMakeEquip:OnBeginMakeEquipmentWithEvent(black_smith, event)
    self:UpdateBuildLabel(1)
end
function WidgetMakeEquip:OnMakingEquipmentWithEvent(black_smith, event, current_time)
    self:UpdateBuildLabel(1)
end
function WidgetMakeEquip:OnEndMakeEquipmentWithEvent(black_smith, event, equipment)
    self:UpdateBuildLabel(0)
end
-- 更新装备数量
function WidgetMakeEquip:UpdateEquipCounts()
    local material_manager = self.city:GetMaterialManager()
    local cur = material_manager:GetMaterialsByType(MaterialManager.MATERIAL_TYPE.EQUIPMENT)[self.equip_type]
    local max = self.city:GetFirstBuildingByType("materialDepot"):GetMaxDragonEquipment()
    local label = string.format("%d/%d", cur, max)
    if label ~= self.number:getString() then
        self.number:setString(label)
    end
end
-- 更新材料数量
function WidgetMakeEquip:UpdateMaterials()
    local material_manager = self.city:GetMaterialManager()
    local materials = material_manager:GetMaterialsByType(MaterialManager.MATERIAL_TYPE.DRAGON)
    local matrials_map = self.materials_map
    for i, v in ipairs(self.matrials) do
        local material_type = v[1]
        local matrials_need = tonumber(v[2])
        local ui = matrials_map[i]
        local current = materials[material_type]
        ui:setString(string.format("%d/%d", current, matrials_need))
        local un_reached = matrials_need > current
        ui:setColor(un_reached and display.COLOR_RED or UIKit:hex2c3b(0x403c2f))
    end
end
-- 更新建筑队列
function WidgetMakeEquip:UpdateBuildLabel(queue)
    local is_enough = queue == 0
    local label = string.format("%s %d/%d", _("制造队列"), queue, 1)
    if label ~= self.build_label:getString() then
        self.build_label:setString(label)
    end
    self.build_label:setColor(is_enough and UIKit:hex2c3b(0x403c2f) or display.COLOR_RED)
    self.build_check_box:setButtonSelected(is_enough)
end
-- 更新银币数量
function WidgetMakeEquip:UpdateCoin(coin)
    local equip_config = self.equip_config
    local need_coin = equip_config.coin
    local label = string.format("%s %s/%s", _("需要银币"), GameUtils:formatNumber(need_coin), GameUtils:formatNumber(coin))
    if self.coin_label:getString() ~= label then
        self.coin_label:setString(label)
    end
    local is_enough = coin >= need_coin
    self.coin_label:setColor(is_enough and UIKit:hex2c3b(0x403c2f) or display.COLOR_RED)
    self.coin_check_box:setButtonSelected(is_enough)
end
-- 更新宝石数量
function WidgetMakeEquip:UpdateGemLabel()
    local equip_config = self.equip_config
    local gem_label = string.format("%d", DataUtils:buyResource({coin = equip_config.coin}, {}) + DataUtils:getGemByTimeInterval(equip_config.makeTime))
    if self.gem_label:getString() ~= gem_label then
        self.gem_label:setString(gem_label)
    end
end
-- 更新buff加成
function WidgetMakeEquip:UpdateBuffTime()
    local time = self.equip_config.makeTime
    local math = math
    local const = 1000000
    local rate = 1 / (1 + self.black_smith:GetEfficiency())
    local rate_new = math.floor(rate * const) / const
    local actual_time = math.floor(rate_new * time)
    self.buff_time:setString(string.format("(-%s)", GameUtils:formatTimeStyle1(time - actual_time)))
end

function WidgetMakeEquip:Close()
    if type(self.on_closed) == "function" then
        self.on_closed(self)
    end
    self:removeFromParentAndCleanup(true)
end
function WidgetMakeEquip:OnClosed(func)
    self.on_closed = func
    return self
end
function WidgetMakeEquip:align(anchorPoint, x, y)
    local size = self.back_ground:getContentSize()
    local point = display.ANCHOR_POINTS[anchorPoint]
    local offset_x, offset_y = size.width * point.x, size.height * point.y
    self.back_ground:setPosition(- offset_x + x, - offset_y + y)
    return self
end





return WidgetMakeEquip










































