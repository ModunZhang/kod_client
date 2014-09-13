local FoodResourceUpgradeBuilding = import("..entity.FoodResourceUpgradeBuilding")
local WoodResourceUpgradeBuilding = import("..entity.WoodResourceUpgradeBuilding")
local IronResourceUpgradeBuilding = import("..entity.IronResourceUpgradeBuilding")
local StoneResourceUpgradeBuilding = import("..entity.StoneResourceUpgradeBuilding")
local TabButtons = import('.TabButtons')
local GameUIBuild = UIKit:createUIClass('GameUIBuild')

local base_items = {
    { label = _("住宅"), building_type = "dwelling" },
    { label = _("农夫小屋"), building_type = "farmer" },
    { label = _("木工小屋"), building_type = "woodcutter" },
    { label = _("石匠小屋"), building_type = "quarrier" },
    { label = _("矿工小屋"), building_type = "miner" },
}
function GameUIBuild:ctor(city, select_ruins, select_ruins_list)
    GameUIBuild.super.ctor(self)
    self.city = city
    self.select_ruins = select_ruins
    self.select_ruins_list = select_ruins_list
    self.city:AddListenOnType(self, self.city.LISTEN_TYPE.UPGRADE_BUILDING)
end

function GameUIBuild:onEnter()
    GameUIBuild.super.onEnter(self)
    self:CreateBackGround()
    self:CreateTitle()
    self:CreateHomeButton()
    self:CreateShopButton()
    self.base_list_view = self:CreateListView()
    self.base_resource_building_items = {}
    for i, v in ipairs(base_items) do
        local item = self:CreateItem(self.base_list_view)
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
        local number = #self.city:GetDecoratorsByType(base_items[i].building_type)
        local max_number = 3
        v:SetNumber(number, max_number)
        local building
        if base_items[i].building_type == "farmer" then
            building = FoodResourceUpgradeBuilding.new({ building_type = base_items[i].building_type, level = 1, finishTime = 0 })
        elseif base_items[i].building_type == "woodcutter" then
            building = WoodResourceUpgradeBuilding.new({ building_type = base_items[i].building_type, level = 1, finishTime = 0 })
        elseif base_items[i].building_type == "miner" then
            building = IronResourceUpgradeBuilding.new({ building_type = base_items[i].building_type, level = 1, finishTime = 0 })
        elseif base_items[i].building_type == "quarrier" then
            building = StoneResourceUpgradeBuilding.new({ building_type = base_items[i].building_type, level = 1, finishTime = 0 })
        end
        if building then
            if building:GetCitizen() < citizen then
                v:SetBuildEnable(true)
                v:SetCondition(_("满足条件"))
            else
                v:SetBuildEnable(false)
                v:SetCondition(_("空闲城民不足"), display.COLOR_RED)
            end 
        end
    end)
end
function GameUIBuild:OnBuildOnItem(item)
    local x, y = self.select_ruins:GetLogicPosition()
    local w, h = self.select_ruins.w, self.select_ruins.h
    local tile = self.city:GetTileWhichBuildingBelongs(self.select_ruins)
    local house_location = tile:GetBuildingLocation(self.select_ruins)
    NetManager:createHouseByLocation(tile.location_id, house_location, item.building.building_type, function(...) end)
    self:leftButtonClicked()
end



function GameUIBuild:CreateBackGround()
    local top_bg = display.newSprite("back_ground.png")
        :align(display.LEFT_TOP, display.left, display.top - 40)
        :addTo(self)
end
function GameUIBuild:CreateTitle()
    cc.ui.UIImage.new("head_bg.png")
        :align(display.TOP_CENTER, display.cx, display.top)
        :addTo(self)
    self.title_label = ui.newTTFLabelWithShadow({text = _("建造列表"),
        font = UIKit:getFontFilePath(),
        size = 30,
        color = UIKit:hex2c3b(0xffedae),
        shadowColor = UIKit:hex2c3b(0xffedae)
    }):addTo(self)
    self.title_label:pos(display.cx-self.title_label:getCascadeBoundingBox().size.width/2, display.top-35)
end

function GameUIBuild:CreateHomeButton()
    self.home_button = cc.ui.UIPushButton.new(
        {normal = "home_btn_up.png",pressed = "home_btn_down.png"})
        :onButtonClicked(function(event)
            self:leftButtonClicked()
        end)
        :align(display.LEFT_TOP, display.left , display.top)
        :addTo(self)
    cc.ui.UIImage.new("home_icon.png")
        :pos(27, -72)
        :addTo(self.home_button)
end

function GameUIBuild:CreateShopButton()
    self.gem_button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up.png",pressed = "gem_btn_down.png"}
    ):onButtonClicked(function(event)
        dump(event)
    end):addTo(self)
    self.gem_button:align(display.RIGHT_TOP, display.right, display.top)
    cc.ui.UIImage.new("home/gem.png")
        :addTo(self.gem_button)
        :pos(-80, -75)

    local gem_num_bg = cc.ui.UIImage.new("gem_num_bg.png"):addTo(self.gem_button):pos(-85, -85)
    local pos = gem_num_bg:getAnchorPointInPoints()
    ui.newTTFLabel({
        text = ""..City.resource_manager:GetGemResource():GetValue(),
        font = UIKit:getFontFilePath(),
        size = 14,
        color = UIKit:hex2c3b(0xfdfac2)})
        :addTo(gem_num_bg)
        :align(display.CENTER, 40, 15)
end

function GameUIBuild:CreateTabButtons()
    local tab_buttons = TabButtons.new({
        {
            label = _("升级"),
            tag = "Upgrade",
            default = true,
        },
        {
            label = _("城民"),
            tag = "Citizen",
        },
        {
            label = _("城民"),
            tag = "Citizen1",
        },
    },
    {
        gap = -4,
        margin_left = -2,
        margin_right = -2,
        margin_up = -6,
        margin_down = 1
    },
    function(tag)
        if tag == "Upgrade" then

        end
    end)
        :addTo(self)
        :pos(display.cx, display.bottom + 50)
end

function GameUIBuild:CreateListView()
    local origin_x, origin_y = 20, 0
    local end_x, end_y = display.right - origin_x, display.top - 100
    local width, height = end_x - origin_x, end_y - origin_y
    return cc.ui.UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(origin_x, origin_y, width, height),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)
end

function GameUIBuild:CreateItem(list_view)
    local content = display.newSprite("build_item/bg.png")
    local w, h = content:getContentSize().width, content:getContentSize().height

    local title_bg = display.newSprite("build_item/title_bg.png")
        :addTo(content)
        :pos(w/2, h/2 + 51)
    local title_label = cc.ui.UILabel.new({
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


    cc.ui.UIPushButton.new(
        {normal = "build_item/info.png",pressed = "build_item/info.png"})
        :addTo(content)
        :align(display.LEFT_BOTTOM, 10, 10)
        :setTouchSwallowEnabled(false)

    local condition_label = cc.ui.UILabel.new({
        text = "已达到最大建筑数量",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x797154)
    }):addTo(content)
        :align(display.LEFT_CENTER, 175, 80)

    local number_label = cc.ui.UILabel.new({
        text = "建筑数量 5 / 5",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(content)
        :align(display.LEFT_CENTER, 175, 40)

    local gem_bg = display.newSprite("build_item/gem_bg.png"):addTo(content):pos(523, 83)
    display.newSprite("home/gem.png"):addTo(gem_bg):pos(10, 10):scale(0.5)
    cc.ui.UILabel.new({
        text = "100",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = display.COLOR_WHITE
    }):addTo(gem_bg)
        :align(display.LEFT_CENTER, 40, 10)

    local build_btn = cc.ui.UIPushButton.new(
        {normal = "build_item/build_btn_up.png",pressed = "build_item/build_btn_down.png"})
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = display.COLOR_WHITE}))
        :addTo(content)
        :pos(520, 40)
        :onButtonPressed(function(event)
            event.target.pre_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
        end)
        :onButtonRelease(function(event)
            local cur_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
            if event.touchInTarget and cc.pGetDistance(cur_pos, event.target.pre_pos) < 10 then
                event.target:my_onButtonClicked(event)
            end
        end)
    build_btn:setTouchSwallowEnabled(false)
    build_btn.set_clicked_function = function(sender, func) sender.my_onButtonClicked = func end

    local item = list_view:newItem()
    item:addContent(content)
    item:setItemSize(w, h)


    function item:SetType(item_info, on_build)
        title_label:setString(item_info.label)
        build_btn:set_clicked_function(function(event)
            on_build(self)
        end)
    end
    function item:SetNumber(number, max_number)
        number_label:setString(_(string.format("数量 %d/%d", number, max_number)))
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
        build_btn:setVisible(is_enable)
    end

    return item
end

return GameUIBuild












