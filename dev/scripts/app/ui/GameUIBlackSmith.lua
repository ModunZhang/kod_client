--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local EQUIPMENTS = GameDatas.SmithConfig.equipments
local MaterialManager = import("..entity.MaterialManager")
local UIPushButton = cc.ui.UIPushButton
local WidgetTips = import("..widget.WidgetTips")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local WidgetMakeEquip = import("..widget.WidgetMakeEquip")
local GameUIBlackSmith = UIKit:createUIClass("GameUIBlackSmith", "GameUIUpgradeBuilding")

local STAR_BG = {
    "star1_105x104.png",
    "star2_105x104.png",
    "star3_105x104.png",
    "star4_105x104.png",
    "star5_105x104.png",
}

function GameUIBlackSmith:ctor(city, black_smith)
    GameUIBlackSmith.super.ctor(self, city, _("铁匠铺"),black_smith)
    self.black_smith_city = city
    self.black_smith = black_smith
end
function GameUIBlackSmith:onEnter()
    GameUIBlackSmith.super.onEnter(self)
    self.title = self:InitEquipmentTitle()
    self.red_dragon_list_view, self.red_dragon_equip_map = self:CreateRedDragonEquipments()
    self.blue_dragon_list_view, self.blue_dragon_equip_map = self:CreateBlueDragonEquipments()
    self.green_dragon_list_view, self.green_dragon_equip_map = self:CreateGreenDragonEquipments()
    self:TabButtons()



    self.black_smith_city:GetMaterialManager():IteratorEquipmentMaterialsByType(function(k, v)
        local red_dragon = self.red_dragon_equip_map[k]
        if red_dragon then
            red_dragon:SetNumber(v)
        end
    end)

    self.black_smith_city:GetMaterialManager():AddObserver(self)
    self.black_smith:AddBlackSmithListener(self)
end
function GameUIBlackSmith:onExit()
    self.black_smith_city:GetMaterialManager():RemoveObserver(self)
    self.black_smith:RemoveBlackSmithListener(self)
    GameUIBlackSmith.super.onExit(self)
end
function GameUIBlackSmith:OnBeginMakeEquipmentWithEvent(black_smith, event)
    self.tips:setVisible(false)
    self.timer:setVisible(true)
    self:OnMakingEquipmentWithEvent(black_smith, event, app.timer:GetServerTime())
end
function GameUIBlackSmith:OnMakingEquipmentWithEvent(black_smith, event, current_time)
    if self.tips:isVisible() then
        self.tips:setVisible(false)
    end
    if not self.timer:isVisible() then
        self.timer:setVisible(true)
    end
    if self.title:isVisible() then
        self.timer:SetDescribe(string.format("%s %s", _("正在制作"), event:Content()))

        local elapse_time = event:ElapseTime(current_time)
        local total_time = event:FinishTime() - event:StartTime()
        local percent = (elapse_time * 100.0 / total_time)
        self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)), percent)
    end
end
function GameUIBlackSmith:OnEndMakeEquipmentWithEvent(black_smith, event, equipment)
    self.tips:setVisible(true)
    self.timer:setVisible(false)
end
function GameUIBlackSmith:OnMaterialsChanged(material_manager, material_type, changed)
    if MaterialManager.MATERIAL_TYPE.EQUIPMENT == material_type then
        if self.red_dragon_list_view:isVisible() then
            for k, v in pairs(changed) do
                self.red_dragon_equip_map[k]:SetNumber(v.new)
            end
        end
    end
end
function GameUIBlackSmith:TabButtons()
    self:CreateTabButtons({
        -- {
        --     label = _("升级"),
        --     tag = "upgrade",
        -- },
        {
            label = _("红龙装备"),
            tag = "redDragon",
        -- default = true,
        },
        {
            label = _("蓝龙装备"),
            tag = "blueDragon",
        },
        {
            label = _("绿龙装备"),
            tag = "greenDragon",
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.title:setVisible(false)
            self.red_dragon_list_view:setVisible(false)
            self.blue_dragon_list_view:setVisible(false)
            self.green_dragon_list_view:setVisible(false)
        elseif tag == "redDragon" then
            self.title:setVisible(true)
            self.red_dragon_list_view:setVisible(true)
            self.blue_dragon_list_view:setVisible(false)
            self.green_dragon_list_view:setVisible(false)
        elseif tag == "blueDragon" then
            self.title:setVisible(true)
            self.red_dragon_list_view:setVisible(false)
            self.blue_dragon_list_view:setVisible(true)
            self.green_dragon_list_view:setVisible(false)
        elseif tag == "greenDragon" then
            self.title:setVisible(true)
            self.red_dragon_list_view:setVisible(false)
            self.blue_dragon_list_view:setVisible(false)
            self.green_dragon_list_view:setVisible(true)
        end
    end):pos(display.cx, display.bottom + 40)
end
function GameUIBlackSmith:InitEquipmentTitle()
    local node = display.newNode():addTo(self)
    self.tips = WidgetTips.new(_("建造队列空闲"), _("请选择一个装备进行制造")):addTo(node)
        :align(display.CENTER, display.cx, display.top - 160)
        :show()

    self.timer = WidgetTimerProgress.new(549, 108):addTo(node)
        :align(display.CENTER, display.cx, display.top - 160)
        :hide()
        :OnButtonClicked(function(event)
            print("hello")
        end)
    return node
end
function GameUIBlackSmith:CreateRedDragonEquipments()
    return self:CreateDragonEquipmentsByType("redDragon")
end
function GameUIBlackSmith:CreateBlueDragonEquipments()
    return self:CreateDragonEquipmentsByType("blueDragon")
end
function GameUIBlackSmith:CreateGreenDragonEquipments()
    return self:CreateDragonEquipmentsByType("greenDragon")
end
function GameUIBlackSmith:CreateDragonEquipmentsByType(dragon_type)
    local equip_map = {}
    local red_dragon_equipments = self:GetDragonEquipmentsByType(dragon_type)
    local list_view = self:CreateVerticalListView(20, display.bottom + 70, display.right - 20, display.top - 230)
    for i, v in ipairs(red_dragon_equipments) do
        local item = self:CreateItemWithListViewByEquipments(list_view, v.equipments, v.title, equip_map)
        list_view:addItem(item)
    end
    list_view:reload():resetPosition()
    return list_view, equip_map
end
function GameUIBlackSmith:GetDragonEquipmentsByType(dragon_type)
    local sort_map = {
        ["crown"] = 1,
        ["chest"] = 2,
        ["sting"] = 3,
        ["orb"] = 4,
        ["armguardLeft,armguardRight"] = 5
    }
    local red_dragon_equipments = {
        [1] = { title = _("灰色套装"), equipments = {}},
        [2] = { title = _("绿色套装"), equipments = {}},
        [3] = { title = _("蓝色套装"), equipments = {}},
        [4] = { title = _("紫色套装"), equipments = {}},
        [5] = { title = _("橙色套装"), equipments = {}},
    }
    for name, v in pairs(EQUIPMENTS) do
        if v.usedFor == dragon_type then
            table.insert(red_dragon_equipments[v.maxStar].equipments, v)
        end
    end
    for _, v in pairs(red_dragon_equipments) do
        table.sort(v.equipments, function(a, b)
            return sort_map[a.category] < sort_map[b.category]
        end)
    end
    return red_dragon_equipments
end
function GameUIBlackSmith:CreateItemWithListViewByEquipments(list_view, equipments, title, equip_map)
    local equip_map = equip_map == nil and {} or equip_map
    -- 背景
    local back_ground = cc.ui.UIImage.new("back_ground_608x227.png"):align(display.CENTER)

    -- title blue
    local pos = back_ground:getAnchorPointInPoints()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png"):addTo(back_ground)
    title_blue:align(display.CENTER, pos.x, back_ground:getContentSize().height - title_blue:getContentSize().height/2)

    -- title label
    local title_label = cc.ui.UILabel.new({
        text = title,
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue)
        :align(display.LEFT_CENTER, 15, title_blue:getContentSize().height/2)

    local unit_len, origin_y, gap_x = 105, 115, 10
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

function GameUIBlackSmith:CreateEquipmentByType(equip_type)
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
    cc.ui.UIImage.new("moltenCrown_128x128.png"):addTo(equipment_btn)
        :align(display.CENTER):scale(0.8)

    -- 详细按钮
    local info_clicked = nil
    local info_btn = WidgetPushButton.new(
        {normal = "info_46x45.png", pressed = "info_46x45.png"})
        :addTo(equipment_btn):align(display.CENTER, 105/2 - 46/2, - 104/2 + 45/2)
        :onButtonClicked(function(event)
            if type(info_clicked) == "function" then
                info_clicked(event)
            end
            info_press_tag = true
        end)

    -- number bg
    local back_ground_97x20 = cc.ui.UIImage.new("back_ground_97x20.png"):addTo(equipment_btn)
        :align(display.CENTER, 0, - 104 / 2 - 25)

    -- number label
    local pos = back_ground_97x20:getAnchorPointInPoints()
    local number_label = cc.ui.UILabel.new({
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground_97x20)
        :align(display.CENTER, pos.x, pos.y)


    function equipment_btn:SetNumber(number)
        number_label:setString(number)
        return self
    end

    equip_clicked = function(event)
        WidgetMakeEquip.new(equip_type, self.black_smith, self.black_smith_city):addTo(self)
            :align(display.CENTER, display.cx, display.cy)
    end
    info_clicked = function(event)
        print("info_clicked", equip_type)
    end

    return equipment_btn
end

return GameUIBlackSmith

































