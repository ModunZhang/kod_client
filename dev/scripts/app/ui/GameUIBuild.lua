local window = import("..utils.window")
local BuildingRegister = import("..entity.BuildingRegister")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIBuild = UIKit:createUIClass('GameUIBuild', "GameUIWithCommonHeader")

local base_items = {
    { label = _("住宅"), building_type = "dwelling", png = "dwelling_1_297x365.png", scale = 0.4 },
    { label = _("农夫小屋"), building_type = "farmer", png = "farmer_1_315x281.png", scale = 0.4 },
    { label = _("木工小屋"), building_type = "woodcutter", png = "woodcutter_1_342x250.png", scale = 0.4 },
    { label = _("石匠小屋"), building_type = "quarrier", png = "quarrier_1_303x296.png", scale = 0.4 },
    { label = _("矿工小屋"), building_type = "miner", png = "miner_1_315x309.png", scale = 0.4 },
}
function GameUIBuild:ctor(city, select_ruins, select_ruins_list)
    GameUIBuild.super.ctor(self, city, _("待建地基"))
    self.build_city = city
    self.select_ruins = select_ruins
    self.select_ruins_list = select_ruins_list
    self.build_city:AddListenOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
end

function GameUIBuild:onEnter()
    GameUIBuild.super.onEnter(self)
    self.base_resource_building_items = {}
    self.base_list_view = self:CreateVerticalListView(window.left + 20, window.bottom+20, window.right - 20, window.top - 100)
    for i, v in ipairs(base_items) do
        local item = self:CreateItemWithListView(self.base_list_view)
        item.building = v
        item:SetType(v, handler(self, self.OnBuildOnItem))
        self.base_list_view:addItem(item)
        table.insert(self.base_resource_building_items, item)
    end
    self.base_list_view:reload():resetPosition()
    self:OnCityChanged()
end
function GameUIBuild:onExit()
    self.build_city:RemoveListenerOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIBuild.super.onExit(self)
end

function GameUIBuild:OnUpgradingBegin(building)
    self:OnCityChanged()
end
function GameUIBuild:OnUpgrading()

end
function GameUIBuild:OnUpgradingFinished(building)
    self:OnCityChanged()
end
function GameUIBuild:OnCityChanged()
    local citizen = self.build_city:GetResourceManager():GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime())
    table.foreachi(self.base_resource_building_items, function(i, v)
        local building_type = base_items[i].building_type
        local number = #self.build_city:GetDecoratorsByType(building_type)
        local max_number = City:GetBuildingMaxCountsByType(building_type)
        local building = BuildingRegister[building_type].new({building_type = building_type, level = 1, finishTime = 0})
        v:SetNumber(number, max_number)
        if building then
            if building:GetCitizen() > citizen then
                v:SetBuildEnable(false)
                v:SetCondition(_("空闲城民不足"), display.COLOR_RED)
            elseif number >= max_number then
                v:SetBuildEnable(false)
                v:SetCondition(_("已达到最大建筑数量"), display.COLOR_RED)
            else
                v:SetBuildEnable(true)
                v:SetCondition(_("满足条件"))
            end
        end
    end)
end
function GameUIBuild:OnBuildOnItem(item)
    local max = self.build_city.build_queue
    local current_time = app.timer:GetServerTime()
    local upgrading_buildings = self.build_city:GetUpgradingBuildingsWithOrder(current_time)
    local current = max - #upgrading_buildings

    if current > 0 then
        self:BuildWithRuins(self.select_ruins, item.building.building_type)
    else
        local dialog = FullScreenPopDialogUI.new():addTo(self)
        local required_gems = DataUtils:getGemByTimeInterval(upgrading_buildings[1]:GetUpgradingLeftTimeByCurrentTime(current_time))
        dialog:SetTitle(_("提示"))
        dialog:SetPopMessage(_("您当前没有空闲的建筑队列,是否花费魔法石立即完成上一个队列"))
        dialog:CreateNeeds("Topaz-icon.png", required_gems)
        dialog:CreateOKButton(function()
            self:BuildWithRuins(self.select_ruins, item.building.building_type)
        end)
    end
end
function GameUIBuild:BuildWithRuins(select_ruins, building_type)
    local x, y = select_ruins:GetLogicPosition()
    local w, h = select_ruins.w, select_ruins.h
    local tile = self.build_city:GetTileWhichBuildingBelongs(select_ruins)
    local house_location = tile:GetBuildingLocation(select_ruins)
    NetManager:createHouseByLocation(tile.location_id, house_location, building_type, NOT_HANDLE)
    self:leftButtonClicked()
end

function GameUIBuild:CreateItemWithListView(list_view)

    local item = list_view:newItem()
    local content = WidgetUIBackGround.new(170)
    item:addContent(content)

    local w, h = content:getContentSize().width, content:getContentSize().height
    item:setItemSize(w, h)


    local left_x, right_x = 15, 160
    local left = display.newSprite("building_frame_36x136.png")
        :addTo(content):align(display.LEFT_CENTER, left_x, h/2):flipX(true)

    display.newSprite("building_frame_36x136.png")
        :addTo(content):align(display.RIGHT_CENTER, right_x, h/2)

    WidgetPushButton.new(
        {normal = "info_26x26.png",pressed = "info_26x26.png"})
        :addTo(left)
        :align(display.CENTER, 6, 6)


    local building_icon = display.newSprite("dwelling_1_297x365.png")
        :addTo(content):align(display.BOTTOM_CENTER, (left_x + right_x) / 2, 30)



    -- local title_bg = display.newSprite("build_item/title_bg.png")
    --     :addTo(content)
    --     :pos(w/2, h/2 + 51)
    -- local title_label = cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     text = "2000000",
    --     size = 24,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_LEFT,
    --     color = UIKit:hex2c3b(0xffedae)
    -- }):addTo(title_bg)
    --     :align(display.LEFT_CENTER, 172, 24)

    -- display.newSprite("build_item/building_image.png")
    --     :addTo(content)
    --     :align(display.LEFT_BOTTOM, 10, 10)

    local title_blue = cc.ui.UIImage.new("title_blue_402x48.png", {scale9 = true})
        :addTo(content):align(display.LEFT_CENTER, right_x, h - 33)
    title_blue:setContentSize(cc.size(435, 48))
    local size = title_blue:getContentSize()
    local title_label = cc.ui.UILabel.new({
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue, 2)
        :align(display.LEFT_CENTER, 30, size.height/2)


    WidgetPushButton.new(
        {normal = "build_item/info.png",pressed = "build_item/info.png"})
        :addTo(content)
        :align(display.LEFT_BOTTOM, 10, 10)

    local condition_label = cc.ui.UILabel.new({
        text = _("已达到最大建筑数量"),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x797154)
    }):addTo(content)
        :align(display.LEFT_CENTER, 175, 80)

    local number_label = cc.ui.UILabel.new({
        text = _("建筑数量").."5 / 5",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(content)
        :align(display.LEFT_CENTER, 175, 40)

    local build_btn = WidgetPushButton.new(
        {normal = "build_item/build_btn_up.png",pressed = "build_item/build_btn_down.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :pos(520, 40)



    function item:SetType(item_info, on_build)
        building_icon:setTexture(item_info.png)
        building_icon:scale(item_info.scale)
        if title_label:getString() ~= item_info.label then
            title_label:setString(item_info.label)
        end
        build_btn:onButtonClicked(function(event)
            on_build(self)
        end)
    end
    function item:SetNumber(number, max_number)
        number_label:setString(_("数量")..string.format(" %d/%d", number, max_number))
        if number == max_number then
            self:SetCondition(_("已达到最大建筑数量"))
            self:SetBuildEnable(false)
        else
            self:SetCondition(_("满足条件"))
            self:SetBuildEnable(true)
        end
    end
    function item:SetCondition(condition, color)
        condition_label:setString(_(condition))
        condition_label:setColor(color == nil and display.COLOR_GREEN or display.COLOR_RED)
    end
    function item:SetBuildEnable(is_enable)
        build_btn:setButtonEnabled(is_enable)
    end

    return item
end

return GameUIBuild




















