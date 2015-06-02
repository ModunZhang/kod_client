local UpgradeBuilding = import("..entity.UpgradeBuilding")
local Localize = import("..utils.Localize")
local SpriteConfig = import("..sprites.SpriteConfig")
local window = import("..utils.window")
local WidgetTimeBar = import("..widget.WidgetTimeBar")
local WidgetBuildingIntroduce = import("..widget.WidgetBuildingIntroduce")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIBuildingSpeedUp = import("..ui.GameUIBuildingSpeedUp")
local GameUIHasBeenBuild = UIKit:createUIClass('GameUIHasBeenBuild', "GameUIWithCommonHeader")
local NOT_ABLE_TO_UPGRADE = UpgradeBuilding.NOT_ABLE_TO_UPGRADE
local timer = app.timer
local UIKit = UIKit
local building_config_map = {
    ["keep"] = {scale = 0.3, offset = {x = 80, y = 74}},
    ["watchTower"] = {scale = 0.35, offset = {x = 90, y = 70}},
    ["warehouse"] = {scale = 0.5, offset = {x = 84, y = 70}},
    ["dragonEyrie"] = {scale = 0.35, offset = {x = 74, y = 70}},
    ["toolShop"] = {scale = 0.5, offset = {x = 80, y = 70}},
    ["materialDepot"] = {scale = 0.5, offset = {x = 70, y = 70}},
    ["barracks"] = {scale = 0.5, offset = {x = 80, y = 70}},
    ["blackSmith"] = {scale = 0.5, offset = {x = 75, y = 70}},
    ["foundry"] = {scale = 0.47, offset = {x = 75, y = 74}},
    ["stoneMason"] = {scale = 0.47, offset = {x = 76, y = 75}},
    ["lumbermill"] = {scale = 0.45, offset = {x = 80, y = 74}},
    ["mill"] = {scale = 0.45, offset = {x = 76, y = 74}},
    ["hospital"] = {scale = 0.5, offset = {x = 80, y = 75}},
    ["townHall"] = {scale = 0.45, offset = {x = 76, y = 74}},
    ["tradeGuild"] = {scale = 0.5, offset = {x = 74, y = 74}},
    ["academy"] = {scale = 0.5, offset = {x = 80, y = 74}},
    ["prison"] = {scale = 0.4, offset = {x = 80, y = 80}},
    ["hunterHall"] = {scale = 0.5, offset = {x = 74, y = 74}},
    ["trainingGround"] = {scale = 0.5, offset = {x = 76, y = 74}},
    ["stable"] = {scale = 0.46, offset = {x = 74, y = 74}},
    ["workshop"] = {scale = 0.46, offset = {x = 74, y = 74}},

    ["wall"] = {scale = 0.5, offset = {x = 74, y = 74}},
    ["tower"] = {scale = 0.5, offset = {x = 74, y = 74}},
    --
    ["dwelling"] = {scale = 0.8, offset = {x = 74, y = 74}},
    ["farmer"] = {scale = 0.8, offset = {x = 74, y = 74}},
    ["woodcutter"] = {scale = 0.8, offset = {x = 74, y = 74}},
    ["quarrier"] = {scale = 0.8, offset = {x = 74, y = 74}},
    ["miner"] = {scale = 0.8, offset = {x = 74, y = 74}},
}




local Item = class("Item", WidgetUIBackGround)
function Item:ctor(parent_ui)
    self.parent_ui = parent_ui
    Item.super.ctor(self, {
        width = 568,
        height = 150,
        top_img = "back_ground_568x16_top.png",
        bottom_img = "back_ground_568x80_bottom.png",
        mid_img = "back_ground_568x28_mid.png",
        u_height = 16,
        b_height = 80,
        m_height = 28,
    })
    local back_ground = self
    local w, h = back_ground:getContentSize().width, back_ground:getContentSize().height
    local left_x, right_x = 5, 150

    display.newSprite("alliance_item_flag_box_126X126.png"):addTo(back_ground)
        :pos((left_x + right_x) / 2, h/2):scale(134/126)

    self.building_icon = cc.ui.UIImage.new("info_26x26.png"):addTo(back_ground)
        :align(display.CENTER, (left_x + right_x) / 2, h/2)

    local title_blue = display.newScale9Sprite("title_blue_430x30.png", 0,0, cc.size(412,30), cc.rect(10,10,410,10))
        :addTo(back_ground):align(display.LEFT_CENTER, right_x, h - 23)

    local size = title_blue:getContentSize()
    self.title_label = UIKit:ttfLabel({
        size = 22,
        color = 0xffedae,
    }):addTo(title_blue, 2):align(display.LEFT_CENTER, 23 - 5, size.height/2)

    self.condition_label = UIKit:ttfLabel({
        size = 20,
        color = 0x7e0000,
    }):addTo(back_ground, 2):align(display.LEFT_CENTER, 170 - 5, h/2)

    self.desc_label = UIKit:ttfLabel({
        size = 20,
        color = 0x403c2f,
    }):addTo(back_ground, 2):align(display.LEFT_CENTER, 170 - 5, 35)

    self.progress = WidgetTimeBar.new(nil, "back_ground_166x84.png"):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 185, h/2)

    self.speed_up = WidgetPushButton.new(
        {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"}
    ):addTo(back_ground):align(display.CENTER, w - 90, 40)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("加速"),
            size = 24,
            color = 0xffedae,
        }))
end
function Item:SetBuildingType(building_type, level)
    local config = SpriteConfig[building_type]
    local png = SpriteConfig[building_type]:GetConfigByLevel(level).png
    self.title_label:setString(Localize.building_name[building_type])
    self.building_icon:setTexture(png)
    self.building_icon:setPosition(building_config_map[building_type].offset.x,building_config_map[building_type].offset.y)
    self.building_icon:scale(building_config_map[building_type].scale)
    self.building_icon:removeAllChildren()
    local p = self.building_icon:getAnchorPointInPoints()
    for _,v in ipairs(config:GetStaticImagesByLevel()) do
        display.newSprite(v):addTo(self.building_icon):pos(p.x, p.y)
    end
    return self
end
function Item:SetConditionLabel(label, color)
    self.condition_label:show():setString(label)
    if color then
        self.condition_label:setColor(color)
    end
    return self
end
function Item:RebindEventListener()
    local w, h = self:getContentSize().width, self:getContentSize().height

    if self.info_btn then
        self.info_btn:removeFromParent()
    end
    self.info_btn = WidgetPushButton.new({normal = "info_26x26.png",pressed = "info_26x26.png"})
        :addTo(self)
        :align(display.CENTER, 32, 32)
        :onButtonClicked(function(event)
            local building = self.building
            UIKit:newWidgetUI("WidgetBuildingIntroduce", self.building):AddToCurrentScene(true)
        end)

    if self.free_speedUp then
        self.free_speedUp:removeFromParent()
    end
    self.free_speedUp = WidgetPushButton.new(
        {normal = "purple_btn_up_148x58.png",pressed = "purple_btn_down_148x58.png"})
        :addTo(self)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("免费加速"),
            size = 24,
            color = 0xffedae,
        })):onButtonClicked(function(event)
        local building = self.building
        NetManager:getFreeSpeedUpPromise(building:EventType(), building:UniqueUpgradingKey())
        end)

    if self.instant_build then
        self.instant_build:removeFromParent()
    end
    self.instant_build = WidgetPushButton.new(
        {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
        :addTo(self):align(display.CENTER, w - 90, 40)
        :setButtonLabel(
            UIKit:ttfLabel({
                text = _("升级"),
                size = 24,
                color = 0xffedae,
            })
        ):onButtonClicked(function(event)
        local building = self.building
        local city = building:BelongCity()
        local gem_needs = building:getUpgradeNowNeedGems()
        if gem_needs > city:GetUser():GetGemResource():GetValue() then
            local dialog = UIKit:showMessageDialog()
            dialog:SetTitle(_("提示"))
            dialog:SetPopMessage(UpgradeBuilding.NOT_ABLE_TO_UPGRADE.GEM_NOT_ENOUGH)
            dialog:CreateOKButton(
                {
                    listener = function ()
                        UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
                        self.parent_ui:LeftButtonClicked()
                    end,
                    btn_name= _("前往商店")
                }
            )
            return
        end
        if city:IsFunctionBuilding(building) then
            local location_id = city:GetLocationIdByBuilding(building)
            NetManager:getInstantUpgradeBuildingByLocationPromise(location_id)
        elseif city:IsHouse(building) then
            local tile = city:GetTileWhichBuildingBelongs(building)
            local house_location = tile:GetBuildingLocation(building)
            NetManager:getInstantUpgradeHouseByLocationPromise(tile.location_id, house_location)
        elseif city:IsGate(building) then
            NetManager:getInstantUpgradeWallByLocationPromise()
        elseif city:IsTower(building) then
            NetManager:getInstantUpgradeTowerPromise()
        end
        end)

    local gem_icon = display.newSprite("gem_icon_62x61.png")
        :addTo(self.instant_build, 2):align(display.CENTER, -50, 50):scale(0.7)

    self.gem_label = UIKit:ttfLabel({
        size = 20,
        color = 0x403c2f,
    }):addTo(gem_icon, 2):align(display.LEFT_CENTER, 60, 61/2)


    if self.normal_build then
        self.normal_build:removeFromParent()
    end
    self.normal_build = WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
    ):addTo(self):align(display.CENTER, w - 90, 40)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("升级"),
            size = 24,
            color = 0xffedae,
        })):onButtonClicked(function(event)
        local building = self.building
        local city = building:BelongCity()
        local illegal, is_pre_condition = building:IsAbleToUpgrade(false)
        local jump_building = building:GetPreConditionBuilding()
        local cur_scene = display.getRunningScene()
        if illegal and is_pre_condition
            and type(jump_building) == "table"
            and cur_scene.AddIndicateForBuilding then
            UIKit:showMessageDialog(_("提示"), _("前置建筑条件不满足, 请前往。"), function()
                local building_sprite = cur_scene:GetSceneLayer():FindBuildingSpriteByBuilding(jump_building, city)
                local x,y = jump_building:GetMidLogicPosition()
                cur_scene:GotoLogicPoint(x,y,40):next(function()
                    cur_scene:AddIndicateForBuilding(building_sprite)
                end)
                self.parent_ui:LeftButtonClicked()
            end)
            return
        end

        if city:IsFunctionBuilding(building) then
            local location_id = city:GetLocationIdByBuilding(building)
            NetManager:getUpgradeBuildingByLocationPromise(location_id)
        elseif city:IsHouse(building) then
            local tile = city:GetTileWhichBuildingBelongs(building)
            local house_location = tile:GetBuildingLocation(building)

            NetManager:getUpgradeHouseByLocationPromise(tile.location_id, house_location)
        elseif city:IsGate(building) then
            NetManager:getUpgradeWallByLocationPromise()
        elseif city:IsTower(building) then
            NetManager:getUpgradeTowerPromise()
        end
        end)

    if self.speed_up then
        self.speed_up:removeFromParent()
    end
    self.speed_up = WidgetPushButton.new(
        {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"}
    ):addTo(self):align(display.CENTER, w - 90, 40)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("加速"),
            size = 24,
            color = 0xffedae,
        })):onButtonClicked(function(event)
        UIKit:newGameUI("GameUIBuildingSpeedUp", self.building):AddToCurrentScene(true)
        end)
end
function Item:UpdateByBuilding(building, current_time)
    self.building = building
    self:SetBuildingType(building:GetType(), building:GetLevel())
    repeat
        if building:IsUpgrading() then
            -- assert(current_time ~= 0)
            local can_free_speedUp = building:GetUpgradingLeftTimeByCurrentTime(current_time) <= DataUtils:getFreeSpeedUpLimitTime()
            self:ChangeStatus(can_free_speedUp and "free" or "building")
            self:UpdateProgress(building)
            break
        end
        if building:IsMaxLevel() then
            self:ChangeStatus("max")
            break
        end
        local illegal, is_pre_condition = building:IsAbleToUpgrade(false)
        if illegal then
            if is_pre_condition then
                self:ChangeStatus("disable")
            else
                self:ChangeStatus("instant")
                self.gem_label:setString(string.formatnumberthousands(building:getUpgradeNowNeedGems()))
            end
            self:SetConditionLabel(illegal, UIKit:hex2c3b(0x7e0000))
        else
            self:ChangeStatus("normal")
            self:SetConditionLabel(_("满足条件"), UIKit:hex2c3b(0x007c23))
        end
    until true
    self:UpdateDesc(building)
end
function Item:UpdateProgress(building)
    if building:IsUpgrading() then
        local time = timer:GetServerTime()
        local str = GameUtils:formatTimeStyle1(building:GetUpgradingLeftTimeByCurrentTime(time))
        local percent = building:GetUpgradingPercentByCurrentTime(time)
        self.progress:SetProgressInfo(str, percent)
    end
end
function Item:UpdateDesc(building)
    if building:IsUpgrading() then
        if building:GetNextLevel() == 1 then
            self.desc_label:setString(building:IsHouse() and _("正在建造") or _("正在解锁"))
            self.desc_label:setPositionY(35)
        else
            self.desc_label:setString(string.format(_("正在升级到等级%d"), building:GetNextLevel()))
            self.desc_label:setPositionY(35)
        end
    else
        if building:IsMaxLevel() then
            self.desc_label:setString(_("已经到最大等级了"))
            self.desc_label:setPositionY(70)
        else
            self.desc_label:setString(string.format(_("从等级%d升级到等级%d"), building:GetLevel(), building:GetNextLevel()))
            self.desc_label:setPositionY(35)
        end
    end
end
function Item:ChangeStatus(status)
    if self.status == status then
        return
    end
    if status == "instant" then
        self:HideFreeSpeedUp()
        self:HideNormalButton()
        self:HideProgress()

        self:ShowInstantButton()
    elseif status == "free" then
        self:HideNormalButton()
        self:HideInstantButton()

        self:ShowProgress()
        self:ShowFreeSpeedUp()
    elseif status == "normal" then
        self:HideFreeSpeedUp()
        self:HideInstantButton()
        self:HideProgress()

        self:ShowNormalButton()
    elseif status == "building" then
        self:HideFreeSpeedUp()
        self:HideInstantButton()
        self:HideNormalButton()

        self:ShowProgress()
        self.speed_up:setVisible(true)
    elseif status == "disable" then
        self:HideFreeSpeedUp()
        self:HideInstantButton()
        self:HideProgress()
        self:ShowNormalButton()
    elseif status == "max" then
        self:HideFreeSpeedUp()
        self:HideInstantButton()
        self:HideNormalButton()
        self:HideProgress()
        self.speed_up:hide()
        self.condition_label:hide()
    end
    self.status = status
    return self
end
function Item:HideInstantButton()
    self.instant_build:setVisible(false)
end
function Item:ShowInstantButton()
    self.speed_up:setVisible(false)
    self.instant_build:setVisible(true)
end
function Item:HideNormalButton()
    self.normal_build:setVisible(false)
end
function Item:ShowNormalButton()
    self.speed_up:setVisible(false)
    self.normal_build:setVisible(true)
end
function Item:HideProgress()
    self.progress:setVisible(false)
end
function Item:ShowProgress()
    self.progress:setVisible(true)
end
function Item:ShowFreeSpeedUp()
    self.speed_up:setVisible(false)
    self.free_speedUp:show()
end
function Item:HideFreeSpeedUp()
    self.free_speedUp:hide()
end




function GameUIHasBeenBuild:ctor(city)
    GameUIHasBeenBuild.super.ctor(self, city, _("建筑列表"))
    self.build_city = city
end
function GameUIHasBeenBuild:OnMoveInStage()
    timer:AddListener(self)
    self.build_city:AddListenOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.OnMoveInStage(self)

    self.queue = self:LoadBuildingQueue():addTo(self:GetView())
    self:UpdateBuildingQueue(self.build_city)

    self.function_list_view, self.function_list_node = self:CreateListView()
    self.function_list_view:setDelegate(handler(self, self.sourceDelegateFunction))

    self.house_list_view, self.house_list_node = self:CreateListView()
    self.house_list_view:setDelegate(handler(self, self.sourceDelegateHouse))

    self:TabButtons()
end
function GameUIHasBeenBuild:onExit()
    timer:RemoveListener(self)
    self.build_city:RemoveListenerOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.onExit(self)
end
function GameUIHasBeenBuild:OnTimer(time)
    self:RefreshAllItems()
end
function GameUIHasBeenBuild:OnUpgradingBegin(building, current_time, city)
    self:UpdateBuildingQueue(city)
    self:RefreshAllItems()
end
function GameUIHasBeenBuild:OnUpgrading(building, current_time, city)
end
function GameUIHasBeenBuild:OnUpgradingFinished(building, city)
    self:UpdateBuildingQueue(city)
    self:RefreshCurrentList(self.tabs:GetSelectedButtonTag())
end
function GameUIHasBeenBuild:RefreshAllItems()
    local time = timer:GetServerTime()
    if self.function_list_node:isVisible() then
        for i,v in ipairs(self.function_list_view.items_) do
            v:getContent():UpdateByBuilding(self.buildings[v.idx_], time)
        end
    else
        for i,v in ipairs(self.house_list_view.items_) do
            v:getContent():UpdateByBuilding(self.houses[v.idx_], time)
        end
    end
end
function GameUIHasBeenBuild:LoadBuildingQueue()
    local back_ground = display.newScale9Sprite("back_ground_166x84.png", 0,0,cc.size(534,46),cc.rect(15,10,136,64))
        :align(display.CENTER, window.cx, window.top - 120)
    local check = cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "wow_40x40.png" })
        :addTo(back_ground)
        :align(display.CENTER, 30, back_ground:getContentSize().height/2)
    check:setTouchEnabled(false)
    local building_label = UIKit:ttfLabel({
        text = _("建筑队列"),
        size = 20,
        color = 0x615b44,
    }):addTo(back_ground, 2):align(display.LEFT_CENTER, 60, back_ground:getContentSize().height/2)

    WidgetPushButton.new({normal = "add_btn_up_50x50.png",pressed = "add_btn_down_50x50.png"})
        :addTo(back_ground)
        :align(display.CENTER, back_ground:getContentSize().width - 25, back_ground:getContentSize().height/2)
        :onButtonClicked(function ( event )
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI("GameUIActivityRewardNew",4):AddToCurrentScene(true)
            end
        end)

    function back_ground:SetBuildingQueue(current, max)
        local enable = current > 0
        check:setButtonSelected(enable)
        building_label:setString(string.format("%s %d/%d", _("建筑队列"), current, max))
    end

    return back_ground
end
function GameUIHasBeenBuild:UpdateBuildingQueue(city)
    self.queue:SetBuildingQueue(city:GetAvailableBuildQueueCounts(), city:BuildQueueCounts())
end
function GameUIHasBeenBuild:TabButtons()
    self.tabs = self:CreateTabButtons({
        {
            label = _("功能建筑"),
            tag = "function",
            default = true
        },
        {
            label = _("资源建筑"),
            tag = "resource",
        },
    },
    function(tag)
        self:RefreshCurrentList(tag)
    end):pos(window.cx, window.bottom + 34)
end
function GameUIHasBeenBuild:RefreshCurrentList(tag)
    if tag == "function" then
        self:UnloadHouseListView()
        self:LoadFunctionListView()
    else
        self:UnloadFunctionListView()
        self:LoadHouseListView()
    end
end
function GameUIHasBeenBuild:LoadFunctionListView()
    self.buildings = self.build_city:GetBuildingsIsUnlocked()
    self.function_list_view:reload()
    self.function_list_node:show()
end
function GameUIHasBeenBuild:UnloadFunctionListView()
    self.function_list_node:hide()
end
function GameUIHasBeenBuild:LoadHouseListView()
    self.houses = self.build_city:GetHousesWhichIsBuilded()
    self.house_list_view:reload()
    self.house_list_node:show()
end
function GameUIHasBeenBuild:UnloadHouseListView()
    self.house_list_node:hide()
end
function GameUIHasBeenBuild:CreateListView()
    local list_view, listnode = UIKit:commonListView({
        async = true, --异步加载
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 0, 568, 680),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(self:GetView()):align(display.BOTTOM_CENTER,window.cx,window.bottom_top + 20)
    list_view:setRedundancyViewVal(list_view:getViewRect().height)
    -- list_view:setDelegate(handler(self, self.sourceDelegate))
    return list_view, listnode
end
function GameUIHasBeenBuild:sourceDelegateFunction(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        return #self.buildings
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        item = listView:dequeueItem()
        if not item then
            item = listView:newItem()
            content = Item.new(self)
            item:addContent(content)
        else
            content = item:getContent()
            content.status = nil
        end
        content:RebindEventListener()
        content:UpdateByBuilding(self.buildings[idx], timer:GetServerTime())
        local size = content:getContentSize()
        item:setItemSize(size.width, size.height)
        return item
    end
end
function GameUIHasBeenBuild:sourceDelegateHouse(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        return #self.houses
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        item = listView:dequeueItem()
        if not item then
            item = listView:newItem()
            content = Item.new(self)
            item:addContent(content)
        else
            content = item:getContent()
            content.status = nil
        end
        content:RebindEventListener()
        content:UpdateByBuilding(self.houses[idx], timer:GetServerTime())
        local size = content:getContentSize()
        item:setItemSize(size.width, size.height)
        return item
    end
end

return GameUIHasBeenBuild




















