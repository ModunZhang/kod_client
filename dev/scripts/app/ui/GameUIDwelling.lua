--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
local ResourceManager = import("..entity.ResourceManager")
local GameUIResource = import(".GameUIResource")
local GameUIDwelling = class("GameUIDwelling", GameUIResource)
GameUIDwelling.CITIZEN_TYPE = {
    CITIZEN = 5,
    FOOD = 4,
    WOOD = 3,
    IRON = 2,
    STONE = 1
}
local STONE = 1
local IRON = 2
local WOOD = 3
local FOOD = 4
local CITIZEN = 5
local items = {
    [CITIZEN] = {
        production_text = _("空闲城民"),
        production_per_hour_text = _("城民增长"),
        tag_color = "dwelling/green_head.png",
        tag_icon = "home/res_citizen.png",
        tag_icon_scale = 0.8
    },
    [FOOD] = {
        production_text = _("农夫"),
        production_per_hour_text = _("粮食产量"),
        tag_color = "dwelling/yellow_head.png",
        tag_icon = "home/res_food.png",
        tag_icon_scale = 0.25
    },
    [WOOD] = {
        production_text = _("伐木工"),
        production_per_hour_text = _("木材产量"),
        tag_color = "dwelling/brown_head.png",
        tag_icon = "home/res_wood.png",
        tag_icon_scale = 0.25
    },
    [IRON] = {
        production_text = _("矿工"),
        production_per_hour_text = _("矿产产量"),
        tag_color = "dwelling/blue_head.png",
        tag_icon = "home/res_iron.png",
        tag_icon_scale = 0.25
    },
    [STONE] = {
        production_text = _("石匠"),
        production_per_hour_text = _("石料产量"),
        tag_color = "dwelling/grey_head.png",
        tag_icon = "home/res_stone.png",
        tag_icon_scale = 0.25
    }
}
local function return_item_info(res_type)
    return items[res_type]
end
function GameUIDwelling:ctor(building, city)
    GameUIDwelling.super.ctor(self, building)
    self.dwelling_city = city
    return true
end
function GameUIDwelling:onEnter()
    GameUIDwelling.super.onEnter(self)
    self.citizen_panel:UpdateData()
    self.dwelling_city:AddListenOnType(self, self.dwelling_city.LISTEN_TYPE.UPGRADE_BUILDING)
end
function GameUIDwelling:onExit()
    self.dwelling_city:RemoveListenerOnType(self, self.dwelling_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIDwelling.super.onExit(self)
end
function GameUIDwelling:CreateUI()
    self:CreateInfomation()
    self.citizen_panel = self:CreateCitizenPanel()
    self:createTabButtons()
end
function GameUIDwelling:onMovieOutStage()
    self.dwelling_city = nil
    GameUIDwelling.super.onMovieOutStage(self)
end
function GameUIDwelling:CreateCitizenPanel()
    local citizen_layer = display.newNode():addTo(self)

    local iconBg = cc.ui.UIImage.new("dwelling/citizen_bg.png")
        :pos(window.left + 45, window.top - 150)
        :addTo(citizen_layer)

    cc.ui.UIImage.new("home/res_citizen.png")
        :addTo(iconBg)

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("上限"),
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x29261c),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(citizen_layer)
        :align(display.LEFT_CENTER, window.left + 100, window.top - 110)

    local max_citizen_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "10000",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x29261c),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(citizen_layer)
        :align(display.LEFT_CENTER, window.left + 100, window.top - 134)

    local citizen_num_bg = cc.ui.UIImage.new("dwelling/citizen_num_bg.png")
        :addTo(citizen_layer)
        :pos(window.left + 45, window.top - 150 - 702)

    local tips_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("提示：预留一定的空闲城民，兵营将这些空闲城民训练成士兵"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x29261c),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(citizen_layer)
        :align(display.LEFT_CENTER, window.left + 45, window.top - 150 - 702 - 10)


    local dwelling = self
    citizen_layer.citizen_ui = {}
    citizen_layer.citizen_ui[CITIZEN] = cc.ui.UIImage.new("dwelling/green_line.png"):addTo(citizen_num_bg)
    citizen_layer.citizen_ui[FOOD] = cc.ui.UIImage.new("dwelling/yellow_line.png"):addTo(citizen_num_bg)
    citizen_layer.citizen_ui[WOOD] = cc.ui.UIImage.new("dwelling/brown_line.png"):addTo(citizen_num_bg)
    citizen_layer.citizen_ui[IRON] = cc.ui.UIImage.new("dwelling/blue_line.png"):addTo(citizen_num_bg)
    citizen_layer.citizen_ui[STONE] = cc.ui.UIImage.new("dwelling/grey_line.png"):addTo(citizen_num_bg)


    citizen_layer.citizen_number = {}
    local end_pos = window.top - 240
    local count = #citizen_layer.citizen_ui
    for i, v in pairs(citizen_layer.citizen_ui) do

        local item_info = return_item_info(i)

        local cur_pos = end_pos - (count - i) * 100

        local res_info_bg = cc.ui.UIImage.new("dwelling/res_info_bg.png"):addTo(citizen_layer):pos(window.left + 205, cur_pos)

        cc.ui.UIImage.new("dwelling/dividing_line.png"):addTo(res_info_bg):pos(0, 43)

        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = item_info.production_text,
            font = UIKit:getFontFilePath(),
            size = 30,
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            color = UIKit:hex2c3b(0x797154),
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
        }):addTo(res_info_bg):align(display.LEFT_CENTER, 45, 65)

        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = item_info.production_per_hour_text,
            font = UIKit:getFontFilePath(),
            size = 30,
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            color = UIKit:hex2c3b(0x797154),
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
        }):addTo(res_info_bg):align(display.LEFT_CENTER, 45, 20)

        local production = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = 100,
            font = UIKit:getFontFilePath(),
            size = 30,
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            color = UIKit:hex2c3b(0x29261c),
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
        }):addTo(res_info_bg):align(display.RIGHT_CENTER, 350, 65)

        local productionPerHour = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = "100/h",
            font = UIKit:getFontFilePath(),
            size = 30,
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            color = UIKit:hex2c3b(0x29261c),
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
        }):addTo(res_info_bg):align(display.RIGHT_CENTER, 350, 20)

        local head = cc.ui.UIImage.new(item_info.tag_color):addTo(res_info_bg):pos(0, 2)
        local res_bg = cc.ui.UIImage.new("dwelling/res_bg.png"):addTo(head):align(display.CENTER, 20, 40)
        local res_bg_pos = res_bg:getAnchorPointInPoints()
        cc.ui.UIImage.new(item_info.tag_icon):addTo(res_bg):scale(item_info.tag_icon_scale):align(display.CENTER, res_bg_pos.x, res_bg_pos.y)

        if i == CITIZEN then
            local add_btn = cc.ui.UIPushButton.new(
                {normal = "dwelling/add_btn_up.png",pressed = "dwelling/add_btn_down.png"})
                :addTo(res_info_bg):pos(375, 43)
            cc.ui.UIImage.new("dwelling/add.png"):addTo(add_btn):align(display.CENTER, 0, 0)
        end

        citizen_layer.citizen_number[i] = {production, productionPerHour}
    end


    function citizen_layer:UpdateData()
        local city = dwelling.dwelling_city
        citizen_array = {}
        local resource_manager = city:GetResourceManager()
        citizen_array[CITIZEN] = resource_manager:GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime())
        citizen_array[FOOD] = city:GetCitizenByType("farmer")
        citizen_array[WOOD] = city:GetCitizenByType("woodcutter")
        citizen_array[IRON] = city:GetCitizenByType("miner")
        citizen_array[STONE] = city:GetCitizenByType("quarrier")
        self:SetMaxCitizen(resource_manager:GetPopulationResource():GetTotalLimit())
        self:OnCitizenChanged(citizen_array)
    end
    function citizen_layer:OnCitizenChanged(citizen_array)
        local total_counts = self:GetCitizenCounts(citizen_array)
        local total_gap = total_counts > 0 and self:GetCitizenUIGap() * (total_counts - 1) or 0
        local actual_length = self:GetCitizenUILength() - total_gap
        local current_height = self:GetCitizenUIBegin()
        for citizen_type, number in ipairs(citizen_array) do
            local bar_ui = self.citizen_ui[citizen_type]
            if number > 0 then
                bar_ui:setVisible(true)
                local current_length = (number / self.citizen_max) * actual_length
                bar_ui:setLayoutSize(140, current_length):pos(8, current_height)
                current_height = current_height + current_length + self:GetCitizenUIGap()
            else
                bar_ui:setVisible(false)
            end
        end

        local resource_manager = dwelling.dwelling_city:GetResourceManager()
        for k, v in pairs(citizen_layer.citizen_number) do
            local production = string.format("%d", citizen_array[k])
            local productionPerHour
            if k == CITIZEN then
                productionPerHour = resource_manager:GetPopulationResource():GetProductionPerHour()
            elseif k == FOOD then
                productionPerHour = resource_manager:GetFoodResource():GetProductionPerHour()
            elseif k == WOOD then
                productionPerHour = resource_manager:GetWoodResource():GetProductionPerHour()
            elseif k == IRON then
                productionPerHour = resource_manager:GetIronResource():GetProductionPerHour()
            elseif k == STONE then
                productionPerHour = resource_manager:GetStoneResource():GetProductionPerHour()
            end
            v[1]:setString(production)
            v[2]:setString(string.format("%d/h",productionPerHour))
        end
    end
    function citizen_layer:SetMaxCitizen(citizen_max)
        self.citizen_max = citizen_max
        max_citizen_label:setString(citizen_max)
    end
    function citizen_layer:GetCitizenCounts(citizen_array)
        local counts = 0
        for k, v in pairs(citizen_array) do
            if v > 0 then
                counts = counts + 1
            end
        end
        return counts
    end
    function citizen_layer:GetCitizenUIGap()
        return 5
    end
    function citizen_layer:GetCitizenUILength()
        return self:GetCitizenUIEnd() - self:GetCitizenUIBegin()
    end
    function citizen_layer:GetCitizenUIBegin()
        return 15
    end
    function citizen_layer:GetCitizenUIEnd()
        return 688
    end

    return citizen_layer
end
function GameUIDwelling:createTabButtons()
    self:CreateTabButtons({
        {
            label = _("城民"),
            tag = "citizen",
        },
        {
            label = _("信息"),
            tag = "infomation",
        }
    },
    function(tag)
        if tag == 'infomation' then
            self.citizen_panel:setVisible(false)
            self.infomationLayer:setVisible(true)
            self:RefreshListView()
        elseif tag == "citizen" then
            self.citizen_panel:setVisible(true)
            self.infomationLayer:setVisible(false)
        else
            self.citizen_panel:setVisible(false)
            self.infomationLayer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
end
function GameUIDwelling:OnUpgradingBegin(building)
    self:OnUpgradingFinished(building)
end
function GameUIDwelling:OnUpgrading(building)

end
function GameUIDwelling:OnUpgradingFinished(building)
    if self.citizen_panel:isVisible() then
        self.citizen_panel:UpdateData()
    end
end
function GameUIDwelling:OnResourceChanged(resource_manager)
    GameUIDwelling.super.OnResourceChanged(self, resource_manager)
    if self.citizen_panel:isVisible() then
        self.citizen_panel:UpdateData()
    end
end
return GameUIDwelling











