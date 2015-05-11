--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local EQUIPMENTS = GameDatas.DragonEquipments.equipments
local Localize = import("..utils.Localize")
local MaterialManager = import("..entity.MaterialManager")
local UIPushButton = cc.ui.UIPushButton
local window = import("..utils.window")
local UILib = import("..ui.UILib")
local WidgetTips = import("..widget.WidgetTips")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetMakeEquip = import("..widget.WidgetMakeEquip")
local WidgetManufacture = import("..widget.WidgetManufacture")
local GameUIMaterials = UIKit:createUIClass("GameUIMaterials", "GameUIWithCommonHeader")


local STAR_BG = {
    "box_100x100_1.png",
    "box_100x100_2.png",
    "box_100x100_3.png",
    "box_100x100_4.png",
    "box_100x100_5.png",
}
local function return_map_of_list_view_and_ui_map(list_view, ui_map,list_node)
    return { list_view = list_view, ui_map = ui_map,list_node=list_node}
end
function GameUIMaterials:ctor(toolShop, blackSmith)
    GameUIMaterials.super.ctor(self, toolShop:BelongCity(), _("制造材料"), blackSmith)
    self.dragon_map = {}
    self.toolShop = toolShop
    self.blackSmith = blackSmith
end
function GameUIMaterials:OnMoveInStage()
    GameUIMaterials.super.OnMoveInStage(self)
    self.title = self:InitEquipmentTitle()
    self:TabButtons()
    self.blackSmith:BelongCity():GetMaterialManager():AddObserver(self)
    self.blackSmith:AddBlackSmithListener(self)
end
function GameUIMaterials:onExit()
    self.blackSmith:BelongCity():GetMaterialManager():RemoveObserver(self)
    self.blackSmith:RemoveBlackSmithListener(self)
    GameUIMaterials.super.onExit(self)
end
function GameUIMaterials:OnBeginMakeEquipmentWithEvent(blackSmith, event)
    self.tips:setVisible(false)
    self.timer:setVisible(true)
    self:OnMakingEquipmentWithEvent(blackSmith, event, app.timer:GetServerTime())
    self:LeftButtonClicked()
end
function GameUIMaterials:OnMakingEquipmentWithEvent(blackSmith, event, current_time)
    if self.title:isVisible() then
        if self.tips:isVisible() then
            self.tips:setVisible(false)
        end
        if not self.timer:isVisible() then
            self.timer:setVisible(true)
        end
        self.timer:SetDescribe(string.format("%s %s", _("正在制作"), Localize.equip[event:Content()]))
        self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)), event:Percent(current_time))
    end
end
function GameUIMaterials:OnEndMakeEquipmentWithEvent(blackSmith, event, equipment)
    self.tips:setVisible(true)
    self.timer:setVisible(false)
end
function GameUIMaterials:OnMaterialsChanged(material_manager, material_type, changed)
    if MaterialManager.MATERIAL_TYPE.EQUIPMENT == material_type then
        for dragon_type, dragon in pairs(self.dragon_map) do
            if dragon.list_view:isVisible() then
                for k, v in pairs(changed) do
                    if EQUIPMENTS[k].usedFor == dragon_type then
                        dragon.ui_map[k]:SetNumber(v.new)
                    end
                end
                break
            end
        end
    end
end
function GameUIMaterials:TabButtons()
    local tab_params = {}
    if self.toolShop:IsUnlocked() then
        table.insert(tab_params, {
            label = _("制造材料"),
            tag = "manufacture",
            default = true,
        })
    end
    if self.blackSmith:IsUnlocked() then
        table.insert(tab_params, {
            label = _("红龙装备"),
            tag = "redDragon",
            default = not self.toolShop:IsUnlocked()
        })
        table.insert(tab_params, {
            label = _("蓝龙装备"),
            tag = "blueDragon",
        })
        table.insert(tab_params, {
            label = _("绿龙装备"),
            tag = "greenDragon",
        })
    end
    self:CreateTabButtons(tab_params,
        function(tag)
            if tag == 'manufacture' then
                self.title:setVisible(false)
                for _, v in pairs(self.dragon_map) do
                    v.list_view:setVisible(false)
                    v.list_node:setVisible(false)
                end
                if self.toolShop:IsUnlocked() then
                    self.manufacture = WidgetManufacture.new(self.toolShop):addTo(self:GetView())
                end
            else
                if self.manufacture then
                    self.manufacture:removeFromParent()
                    self.manufacture = nil
                end
                if self.blackSmith:IsUnlocked() then
                    self:SwitchToDragon(tag)
                end
            end
        end):pos(window.cx, window.bottom + 34)
end
function GameUIMaterials:SwitchToDragon(dragon_type)
    if not self.dragon_map[dragon_type] then
        dragon_equipments = {}
        dragon_equipments = return_map_of_list_view_and_ui_map(self:CreateDragonEquipmentsByType(dragon_type))
        self.blackSmith:BelongCity():GetMaterialManager():IteratorEquipmentMaterialsByType(function(k, v)
            if EQUIPMENTS[k].usedFor == dragon_type and dragon_equipments.ui_map[k] then
                dragon_equipments.ui_map[k]:SetNumber(v)
            end
        end)
        self.dragon_map[dragon_type] = dragon_equipments
    end

    self.title:setVisible(true)
    for k, v in pairs(self.dragon_map) do
        if k == dragon_type then
            v.list_view:setVisible(true)
            v.list_node:setVisible(true)
        else
            v.list_view:setVisible(false)
            v.list_node:setVisible(false)
        end
    end

    local event = self.blackSmith:GetMakeEquipmentEvent()
    self.tips:setVisible(event:IsEmpty())
    self.timer:setVisible(event:IsMaking())
    if event:IsMaking() then
        local current_time = app.timer:GetServerTime()
        self.timer:SetDescribe(string.format("%s %s", _("正在制作"), Localize.equip[event:Content()]))
        self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)), event:Percent(current_time))
    end
end
function GameUIMaterials:InitEquipmentTitle()
    local node = display.newNode():addTo(self:GetView())
    self.tips = WidgetTips.new(_("建造队列空闲"), _("请选择一个装备进行制造")):addTo(node)
        :align(display.CENTER, display.cx, display.top - 140)
        :show()

    self.timer = WidgetTimerProgress.new(549, 108):addTo(node)
        :align(display.CENTER, display.cx, display.top - 140)
        :hide()
        :OnButtonClicked(function(event)
            UIKit:newGameUI("GameUIBlackSmithSpeedUp", self.blackSmith):AddToCurrentScene(true)
        end)
    return node
end
function GameUIMaterials:CreateDragonEquipments()
    local dragon_map = {
        redDragon = {},
        blueDragon = {},
        greenDragon = {},
    }

    for k, v in pairs(dragon_map) do
        dragon_map[k] = return_map_of_list_view_and_ui_map(self:CreateDragonEquipmentsByType(k))
    end

    self.blackSmith:BelongCity():GetMaterialManager():IteratorEquipmentMaterialsByType(function(k, v)
        dragon_map[EQUIPMENTS[k].usedFor].ui_map[k]:SetNumber(v)
    end)
    return dragon_map
end
function GameUIMaterials:CreateDragonEquipmentsByType(dragon_type)
    local equip_map = {}
    local dragon_equipments = self:GetDragonEquipmentsByType(dragon_type)
    local list_view ,listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 0, 568, 650),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(self:GetView()):align(display.BOTTOM_CENTER,window.cx,window.bottom_top + 20)

    for i, v in ipairs(dragon_equipments) do
        local item = self:CreateItemWithListViewByEquipments(list_view, v.equipments, v.title, equip_map)
        list_view:addItem(item)
    end
    list_view:reload()
    return list_view, equip_map,listnode
end
function GameUIMaterials:GetDragonEquipmentsByType(dragon_type)
    local sort_map = {
        ["crown"] = 1,
        ["chest"] = 2,
        ["sting"] = 3,
        ["orb"] = 4,
        ["armguardLeft,armguardRight"] = 5
    }
    local dragon_equipments = {
        [1] = { title = _("灰色套装"), equipments = {}},
        [2] = { title = _("绿色套装"), equipments = {}},
        [3] = { title = _("蓝色套装"), equipments = {}},
        [4] = { title = _("紫色套装"), equipments = {}},
    -- [5] = { title = _("橙色套装"), equipments = {}},
    }
    for name, v in pairs(EQUIPMENTS) do
        if v.usedFor == dragon_type and dragon_equipments[v.maxStar] then
            table.insert(dragon_equipments[v.maxStar].equipments, v)
        end
    end
    for _, v in pairs(dragon_equipments) do
        table.sort(v.equipments, function(a, b)
            return sort_map[a.category] < sort_map[b.category]
        end)
    end
    return dragon_equipments
end
function GameUIMaterials:CreateItemWithListViewByEquipments(list_view, equipments, title, equip_map)
    local equip_map = equip_map == nil and {} or equip_map
    -- 背景
    local back_ground = WidgetUIBackGround.new({width=568,height=188},WidgetUIBackGround.STYLE_TYPE.STYLE_2):align(display.CENTER)
    -- cc.ui.UIImage.new("back_ground_608x227.png"):align(display.CENTER)

    -- title blue
    local pos = back_ground:getAnchorPointInPoints()
    local title_blue = cc.ui.UIImage.new("title_blue_558x34.png"):addTo(back_ground)
    title_blue:align(display.CENTER, pos.x, back_ground:getContentSize().height - title_blue:getContentSize().height/2-6)

    -- title label
    local title_label = cc.ui.UILabel.new({
        text = title,
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue)
        :align(display.CENTER, title_blue:getContentSize().width/2, title_blue:getContentSize().height/2)

    local unit_len, origin_y, gap_x = 105, 90, 10
    local len = #equipments
    local total_len = len * unit_len + (len - 1) * gap_x
    local origin_x = pos.x - total_len / 2 + unit_len / 2
    for i, v in ipairs(equipments) do
        equip_map[v.name] = self:CreateEquipmentByType(v.name):addTo(back_ground)
            :align(display.CENTER, origin_x + (unit_len + gap_x) * (i - 1), origin_y)
            :SetNumber(0)
    end

    local item = list_view:newItem()
    item:addContent(back_ground)
    item:setItemSize(back_ground:getContentSize().width, back_ground:getContentSize().height + 10)
    return item
end

function GameUIMaterials:CreateEquipmentByType(equip_type)
    local equip_config = EQUIPMENTS[equip_type]
    local info_press_tag = false
    -- 装备按钮
    local equip_clicked = nil
    local bg = STAR_BG[equip_config.maxStar]
    local equipment_btn = WidgetPushButton.new(
        {normal = bg, pressed = bg})
        :onButtonClicked(function(event)
            if not info_press_tag and type(equip_clicked) == "function" then
                equip_clicked(event)
            end
            info_press_tag = false
        end)
    -- 装备图标
    cc.ui.UIImage.new(UILib.equipment[equip_type]):addTo(equipment_btn)
        :align(display.CENTER):scale(0.5)

    -- 详细按钮
    local info_clicked = nil
    local info_btn = WidgetPushButton.new(
        {normal = "i_icon_20x20.png", pressed = "i_icon_20x20.png"})
        :addTo(equipment_btn):align(display.CENTER, 105/2 - 46/2+8, - 104/2 + 45/2-4)
        :onButtonClicked(function(event)
            if type(info_clicked) == "function" then
                info_clicked(event)
            end
            info_press_tag = true
        end)

    -- number bg
    local number_bg_100x40 = cc.ui.UIImage.new("number_bg_100x40.png"):addTo(equipment_btn)
        :align(display.CENTER, 0, - 104 / 2 - 12)

    -- number label
    local pos = number_bg_100x40:getAnchorPointInPoints()
    local number_label = cc.ui.UILabel.new({
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(number_bg_100x40)
        :align(display.CENTER, pos.x, pos.y)


    function equipment_btn:SetNumber(number)
        if number_label:getString() ~= tostring(number) then
            number_label:setString(number)
        end
        return self
    end

    equip_clicked = function(event)
        UIKit:newWidgetUI("WidgetMakeEquip", equip_type, self.blackSmith, self.blackSmith:BelongCity()):AddToCurrentScene()
    end
    info_clicked = function(event)
        print("info_clicked", equip_type)
    end

    return equipment_btn
end

return GameUIMaterials















