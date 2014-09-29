local BuildingRegister = import("..entity.BuildingRegister")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIBuild = UIKit:createUIClass('GameUIBuild', "GameUIWithCommonHeader")

local base_items = {
    { label = _("住宅"), building_type = "dwelling" },
    { label = _("农夫小屋"), building_type = "farmer" },
    { label = _("木工小屋"), building_type = "woodcutter" },
    { label = _("石匠小屋"), building_type = "quarrier" },
    { label = _("矿工小屋"), building_type = "miner" },
}
function GameUIBuild:ctor(city, select_ruins, select_ruins_list)
    GameUIBuild.super.ctor(self, city, _("建筑列表"))
    self.city = city
    self.select_ruins = select_ruins
    self.select_ruins_list = select_ruins_list
    self.city:AddListenOnType(self, self.city.LISTEN_TYPE.UPGRADE_BUILDING)
end

function GameUIBuild:onEnter()
    GameUIBuild.super.onEnter(self)
    self.base_resource_building_items = {}
    self.base_list_view = self:CreateVerticalListView(20, 0, display.right - 20, display.top - 100)
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
    self.city:RemoveListenerOnType(self, self.city.LISTEN_TYPE.UPGRADE_BUILDING)
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
    local citizen = self.city:GetResourceManager():GetPopulationResource():GetNoneAllocatedByTime(app.timer:GetServerTime())
    table.foreachi(self.base_resource_building_items, function(i, v)
        local building_type = base_items[i].building_type
        local number = #self.city:GetDecoratorsByType(building_type)
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
    local x, y = self.select_ruins:GetLogicPosition()
    local w, h = self.select_ruins.w, self.select_ruins.h
    local tile = self.city:GetTileWhichBuildingBelongs(self.select_ruins)
    local house_location = tile:GetBuildingLocation(self.select_ruins)
    NetManager:createHouseByLocation(tile.location_id, house_location, item.building.building_type, NOT_HANDLE)
    self:leftButtonClicked()
end


function GameUIBuild:CreateItemWithListView(list_view)
    local content = display.newSprite("build_item/bg.png")
    local w, h = content:getContentSize().width, content:getContentSize().height

    local title_bg = display.newSprite("build_item/title_bg.png")
        :addTo(content)
        :pos(w/2, h/2 + 51)
    local title_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "2000000",
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_bg)
        :align(display.LEFT_CENTER, 172, 24)

    display.newSprite("build_item/building_image.png")
        :addTo(content)
        :align(display.LEFT_BOTTOM, 10, 10)


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

    -- local gem_bg = display.newSprite("build_item/gem_bg.png"):addTo(content):pos(523, 83)
    -- display.newSprite("home/gem.png"):addTo(gem_bg):pos(10, 10):scale(0.5)
    -- cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     text = "100",
    --     size = 20,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_LEFT,
    --     color = display.COLOR_WHITE
    -- }):addTo(gem_bg)
    --     :align(display.LEFT_CENTER, 40, 10)

    local build_btn = WidgetPushButton.new(
        {normal = "build_item/build_btn_up.png",pressed = "build_item/build_btn_down.png"}
        ,{}
        ,{
            disabled = {name = "SATURATION", params = {0}}
        })
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = display.COLOR_WHITE}))
        :addTo(content)
        :pos(520, 40)

    local item = list_view:newItem()
    item:addContent(content)
    item:setItemSize(w, h)


    function item:SetType(item_info, on_build)
        title_label:setString(item_info.label)
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














