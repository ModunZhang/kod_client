local UpgradeBuilding = import("..entity.UpgradeBuilding")
local Localize = import("..utils.Localize")
local SpriteConfig = import("..sprites.SpriteConfig")
local window = import("..utils.window")
local WidgetTimeBar = import("..widget.WidgetTimeBar")
local WidgetBuildingIntroduce = import("..widget.WidgetBuildingIntroduce")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetBuyBuildingQueue = import("..widget.WidgetBuyBuildingQueue")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIHasBeenBuild = UIKit:createUIClass('GameUIHasBeenBuild', "GameUIWithCommonHeader")
local NOT_ABLE_TO_UPGRADE = UpgradeBuilding.NOT_ABLE_TO_UPGRADE

local building_config_map = {
    ["keep"] = {scale = 0.3, offset = {x = 10, y = -20}},
    ["watchTower"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["warehouse"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["dragonEyrie"] = {scale = 0.3, offset = {x = 0, y = -10}},
    ["toolShop"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["materialDepot"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["armyCamp"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["barracks"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["blackSmith"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["foundry"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["stoneMason"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["lumbermill"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["mill"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["hospital"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["townHall"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["tradeGuild"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["academy"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["prison"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["hunterHall"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["trainingGround"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["stable"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["workshop"] = {scale = 0.5, offset = {x = 10, y = -10}},
    ["wall"] = {scale = 0.5, offset = {x = 0, y = -10}},
    ["tower"] = {scale = 0.5, offset = {x = 0, y = -10}},
    --
    ["dwelling"] = {scale = 0.8, offset = {x = 0, y = -10}},
    ["farmer"] = {scale = 0.8, offset = {x = 0, y = -10}},
    ["woodcutter"] = {scale = 0.8, offset = {x = 0, y = -10}},
    ["quarrier"] = {scale = 0.8, offset = {x = 0, y = -10}},
    ["miner"] = {scale = 0.8, offset = {x = 0, y = -10}},
}
local timer = app.timer





function GameUIHasBeenBuild:ctor(city)
    GameUIHasBeenBuild.super.ctor(self, city, _("建筑列表"))
    self.build_city = city
end
function GameUIHasBeenBuild:onEnter()
    self.build_city:AddListenOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.onEnter(self)


    self.queue = self:LoadBuildingQueue():addTo(self)
    self:UpdateBuildingQueue(self.build_city)

    self:TabButtons()
end
function GameUIHasBeenBuild:onExit()
    self.build_city:RemoveListenerOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.onExit(self)
end
function GameUIHasBeenBuild:OnUpgradingBegin(building, current_time, city)
    self:UpdateBuildingQueue(city)

    local is_house = self.build_city:IsHouse(building)
    if self.function_list_view and not is_house then
        self.function_list_view:UpdateItemsByBuildings(self.build_city:GetBuildingsIsUnlocked())
    elseif self.house_list_view and is_house then
        self.house_list_view:UpdateItemsByBuildings(self.build_city:GetHousesWhichIsBuilded())
    end
end
function GameUIHasBeenBuild:OnUpgrading(building, current_time, city)

    local is_house = self.build_city:IsHouse(building)
    if self.function_list_view and not is_house then
        self.function_list_view:UpdateItemByBuilding(building)
    elseif self.house_list_view and is_house then
        self.house_list_view:UpdateItemByBuilding(building)
    end
end
function GameUIHasBeenBuild:OnUpgradingFinished(building, current_time, city)
    self:UpdateBuildingQueue(city)

    local is_house = self.build_city:IsHouse(building)
    if self.function_list_view and not is_house then
        self.function_list_view:UpdateItemsByBuildings(self.build_city:GetBuildingsIsUnlocked())
        local item = self.function_list_view:GetItemByUniqueKey(building:UniqueKey())
        if item then
            item:UpdateIcon(building)
        end
    elseif self.house_list_view and is_house then
        self.house_list_view:UpdateItemsByBuildings(self.build_city:GetHousesWhichIsBuilded())
        local item = self.house_list_view:GetItemByUniqueKey(building:UniqueKey())
        if item then
            item:UpdateIcon(building)
        end
    end
end
function GameUIHasBeenBuild:LoadBuildingQueue()
    local back_ground = cc.ui.UIImage.new("back_ground_534x46.png"):align(display.CENTER, window.cx, window.top - 120)
    local check = cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "wow_40x40.png" })
        :addTo(back_ground)
        :align(display.CENTER, 30, back_ground:getContentSize().height/2)
    check:setTouchEnabled(false)
    local building_label = cc.ui.UILabel.new({
        text = _("建筑队列"),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x797154)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 60, back_ground:getContentSize().height/2)

    WidgetPushButton.new(
        {normal = "add_btn_up_50x50.png",pressed = "add_btn_down_50x50.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(back_ground)
        :align(display.CENTER, back_ground:getContentSize().width - 25, back_ground:getContentSize().height/2)
        -- :setButtonEnabled(false)
        :onButtonClicked(function ( event )
            if event.name == "CLICKED_EVENT" then
                WidgetBuyBuildingQueue.new():addToCurrentScene()
            end
        end)


    function back_ground:SetBuildingQueue(current, max)
        local enable = current > 0
        check:setButtonSelected(enable)
        local str = string.format("%s %d/%d", _("建筑队列"), current, max)
        if building_label:getString() ~= str then
            building_label:setString(str)
        end
    end

    return back_ground
end
function GameUIHasBeenBuild:UpdateBuildingQueue(city)
    self.queue:SetBuildingQueue(city:GetAvailableBuildQueueCounts(), city:BuildQueueCounts())
end
function GameUIHasBeenBuild:TabButtons()
    self:CreateTabButtons({
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
        if tag == "function" then
            self:UnloadHouseListView()

            self:LoadFunctionListView()
        elseif tag == "resource" then
            self:UnloadFunctionListView()

            self:LoadHouseListView()
        end
    end):pos(window.cx, window.bottom + 34)
end
-- function
function GameUIHasBeenBuild:LoadFunctionListView()
    if not self.function_list_view then
        self.function_list_view , self.function_list_node= self:CreateListView(self.build_city:GetBuildingsIsUnlocked())
        self.function_list_view:reload()
        -- :resetPosition()
    end
end
function GameUIHasBeenBuild:UnloadFunctionListView()
    if self.function_list_view then
        self.function_list_view:removeFromParent()
        self.function_list_node:removeFromParent()
    end
    self.function_list_view = nil
    self.function_list_node = nil
end
-- house
function GameUIHasBeenBuild:LoadHouseListView()
    if not self.house_list_view then
        self.house_list_view, self.house_list_node= self:CreateListView(self.build_city:GetHousesWhichIsBuilded())
        self.house_list_view:reload()
        -- :resetPosition()
    end
end
function GameUIHasBeenBuild:UnloadHouseListView()
    if self.house_list_view then
        self.house_list_view:removeFromParent()
        self.house_list_node:removeFromParent()
    end
    self.house_list_view = nil
    self.house_list_node = nil
end
---
function GameUIHasBeenBuild:CreateListView(buildings)
    -- local list_view = self:CreateVerticalListView(window.left + 20, window.bottom + 70, window.right - 20, window.top - 180)
    local list_view ,listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 0, 568, 706),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(self):align(display.BOTTOM_CENTER,window.cx,window.bottom_top + 20)
    -- 初始化item
    local unique_map = {}
    for i, v in pairs(buildings) do
        local item = self:CreateItemWithListView(list_view)
        item:UpdateIcon(v)
        item:UpdateByBuilding(v)
        unique_map[v:UniqueKey()] = item
        list_view:addItem(item)
    end
    list_view.unique_map = unique_map

    function list_view:GetItemByUniqueKey(unique_key)
        return self.unique_map[unique_key]
    end
    function list_view:UpdateItemsByBuildings(buildings)
        for k, v in pairs(buildings) do
            self:UpdateItemByBuilding(v)
        end
    end
    function list_view:UpdateItemByBuilding(building)
        local item = self.unique_map[building:UniqueKey()]
        if item then
            item:UpdateByBuilding(building)
        end
    end
    return list_view,listnode
end
--
function GameUIHasBeenBuild:CreateItemWithListView(list_view)
    local city = self.build_city

    local item = list_view:newItem()
    local back_ground = WidgetUIBackGround.new({
                    width = 568,
                    height = 142,
                    top_img = "back_ground_568x16_top.png",
                    bottom_img = "back_ground_568x80_bottom.png",
                    mid_img = "back_ground_568x28_mid.png",
                    u_height = 16,
                    b_height = 80,
                    m_height = 28,
                })
    item:addContent(back_ground)

    local w, h = back_ground:getContentSize().width, back_ground:getContentSize().height
    item:setItemSize(w, h)

    local left_x, right_x = 5, 150
    local left = display.newSprite("building_frame_36x136.png")
        :addTo(back_ground):align(display.LEFT_CENTER, left_x, h/2):flipX(true)

    display.newSprite("building_frame_36x136.png")
        :addTo(back_ground):align(display.RIGHT_CENTER, right_x, h/2)

    local info_btn = WidgetPushButton.new(
        {normal = "info_26x26.png",pressed = "info_26x26.png"})
        :addTo(left)
        :align(display.CENTER, 16, 16)
        


    local building_icon = display.newSprite("keep_131x164.png")
        :addTo(back_ground):align(display.BOTTOM_CENTER, (left_x + right_x) / 2, 30)


    local title_blue = cc.ui.UIImage.new("title_blue_412x30.png", {scale9 = true})
        :addTo(back_ground):align(display.LEFT_CENTER, right_x, h - 23)
    -- title_blue:setContentSize(cc.size(435, 48))
    local size = title_blue:getContentSize()
    local title_label = cc.ui.UILabel.new({
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue, 2)
        :align(display.LEFT_CENTER, 30, size.height/2)


    local condition_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x7e0000)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 170, h/2)



    local desc_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 170, 35)


    local instant_build = WidgetPushButton.new(
        {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
        :addTo(back_ground)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            local building = item.building
            if city:IsFunctionBuilding(building) then
                -- NetManager:instantUpgradeBuildingByLocation(city:GetLocationIdByBuildingType(building:GetType()), NOT_HANDLE)

                local location_id = city:GetLocationIdByBuildingType(building:GetType())
                NetManager:getInstantUpgradeBuildingByLocationPromise(location_id)
                    :catch(function(err)
                        dump(err:reason())
                    end)
            elseif city:IsHouse(building) then
                local tile = city:GetTileWhichBuildingBelongs(building)
                local house_location = tile:GetBuildingLocation(building)
                -- NetManager:instantUpgradeHouseByLocation(tile.location_id, house_location, NOT_HANDLE)

                NetManager:getInstantUpgradeHouseByLocationPromise(tile.location_id, house_location)
                    :catch(function(err)
                        dump(err:reason())
                    end)
            elseif city:IsGate(building) then
                -- NetManager:instantUpgradeWallByLocation(NOT_HANDLE)
                NetManager:getInstantUpgradeWallByLocationPromise()
                            :catch(function(err)
                                dump(err:reason())
                            end)
            elseif city:IsTower(building) then
                -- NetManager:instantUpgradeTowerByLocation(building:TowerId(), NOT_HANDLE)
                NetManager:getInstantUpgradeTowerByLocationPromise(building:TowerId())
                    :catch(function(err)
                        dump(err:reason())
                    end)
            end
        end)


    local gem_bg = display.newSprite("back_ground_97x20.png")
        :addTo(back_ground, 2)
        :align(display.CENTER, w - 90, h/2+10)

    display.newSprite("gem_66x56.png")
        :addTo(gem_bg, 2)
        :align(display.CENTER, 20, 20/2)
        :scale(0.4)

    local gem_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xfff3c7)
    }):addTo(gem_bg, 2)
        :align(display.LEFT_CENTER, 40, 20/2)


    local normal_build = WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(back_ground)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("建造"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            local building = item.building
            if city:IsFunctionBuilding(building) then
                -- NetManager:upgradeBuildingByLocation(city:GetLocationIdByBuildingType(building:GetType()), NOT_HANDLE)

                local location_id = city:GetLocationIdByBuildingType(building:GetType())
                NetManager:getUpgradeBuildingByLocationPromise(location_id)
                    :catch(function(err)
                        dump(err:reason())
                    end)
            elseif city:IsHouse(building) then
                local tile = city:GetTileWhichBuildingBelongs(building)
                local house_location = tile:GetBuildingLocation(building)
                -- NetManager:upgradeHouseByLocation(tile.location_id, house_location, NOT_HANDLE)

                NetManager:getUpgradeHouseByLocationPromise(tile.location_id, house_location)
                    :catch(function(err)
                        dump(err:reason())
                    end)
            elseif city:IsGate(building) then
                -- NetManager:upgradeWallByLocation(NOT_HANDLE)
                NetManager:getUpgradeWallByLocationPromise()
                        :catch(function(err)
                            dump(err:reason())
                        end)
            elseif city:IsTower(building) then
                -- NetManager:upgradeTowerByLocation(building:TowerId(), NOT_HANDLE)
                NetManager:getUpgradeTowerByLocationPromise(building:TowerId())
                    :catch(function(err)
                        dump(err:reason())
                    end)
            end
        end)



    local progress = WidgetTimeBar.new(nil, "back_ground_138x34.png"):addTo(back_ground, 2)
        :align(display.LEFT_CENTER, 185, h/2)

    local speed_up = WidgetPushButton.new(
        {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        }
    )
        :addTo(back_ground)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("加速"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}))
        :setButtonEnabled(false)


    function item:SetBuildingType(building_type, level)
        local base_x, base_y = (left_x + right_x) / 2, 30
        local config = building_config_map[building_type]
        local png = SpriteConfig[building_type]:GetConfigByLevel(level).png

        self:SetTitleLabel(Localize.building_name[building_type])
        building_icon:setTexture(png)
        building_icon:scale(config.scale)
        building_icon:pos(base_x + config.offset.x, base_y + config.offset.y)
        info_btn:onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                WidgetBuildingIntroduce.new(City:GetFirstBuildingByType(building_type)):addToCurrentScene()
            end
        end)
        return self
    end
    function item:SetTitleLabel(label)
        if title_label:getString() ~= label then
            title_label:setString(label)
        end
        return self
    end
    function item:SetGemLabel(label)
        if gem_label:getString() ~= label then
            gem_label:setString(label)
        end
        return self
    end
    function item:SetConditionLabel(label, color)
        if condition_label:getString() ~= label then
            condition_label:setString(label)
        end
        if color then
            condition_label:setColor(color)
        end
        return self
    end
    function item:SetDescLabel(label)
        if desc_label:getString() ~= label then
            desc_label:setString(label)
        end
        return self
    end
    function item:SetProgressInfo(time_label, percent)
        progress:SetProgressInfo(time_label, percent)
        return self
    end
    function item:UpdateByBuilding(building)
        self.building = building
        repeat
            if building:IsUpgrading() then
                self:ChangeStatus("building")
                self:OnBuildingUpgrading(building)
                break
            end
            if building:IsMaxLevel() then
                self:ChangeStatus("max")
                break
            end
            if building:IsAbleToUpgrade(false) == NOT_ABLE_TO_UPGRADE.LEVEL_CAN_NOT_HIGHER_THAN_KEEP_LEVEL then
                self:ChangeStatus("disable")
                break
            end
            if building:IsAbleToUpgrade(false) == NOT_ABLE_TO_UPGRADE.BUILDINGLIST_AND_RESOURCE_NOT_ENOUGH then
                self:ChangeStatus("instant")
                self:SetConditionLabel(_("建筑队列不足"), UIKit:hex2c3b(0x7e0000))
                self:SetGemLabel(building:getUpgradeNowNeedGems())
                break
            end
            if building:IsAbleToUpgrade(false) == NOT_ABLE_TO_UPGRADE.RESOURCE_NOT_ENOUGH then
                self:ChangeStatus("instant")
                self:SetConditionLabel(_("升级资源不足"), UIKit:hex2c3b(0x7e0000))
                self:SetGemLabel(building:getUpgradeNowNeedGems())
                break
            end
            if building:IsAbleToUpgrade(false) == NOT_ABLE_TO_UPGRADE.BUILDINGLIST_NOT_ENOUGH then
                self:ChangeStatus("instant")
                self:SetConditionLabel(_("建筑队列不足"), UIKit:hex2c3b(0x7e0000))
                self:SetGemLabel(building:getUpgradeNowNeedGems())
                break
            end
            self:ChangeStatus("normal")
        until true
        self:UpdateDesc(self.building)
    end
    function item:UpdateIcon(building)
        self:SetBuildingType(building:GetType(), building:GetLevel())
    end
    function item:UpdateProgress(building)
        if building:IsUpgrading() then
            local time = timer:GetServerTime()
            local str = GameUtils:formatTimeStyle1(building:GetUpgradingLeftTimeByCurrentTime(time))
            local percent = building:GetUpgradingPercentByCurrentTime(time)
            self:SetProgressInfo(str, percent)
        end
    end
    function item:UpdateDesc(building)
        if building:IsUpgrading() then
            if building:GetNextLevel() == 1 then
                if city:IsHouse(building) then
                    self:SetDescLabel(_("正在建造"))
                else
                    self:SetDescLabel(_("正在解锁"))
                end
            else
                self:SetDescLabel(string.format("%s%d", _("正在升级到 等级"), building:GetNextLevel()))
            end
        else
            if building:IsMaxLevel() then
                self:SetDescLabel(string.format("%s", _("已经到最大等级了")))
            else
                self:SetDescLabel(string.format("%s%d%s%d", _("从等级"), building:GetLevel(), _("升级到等级"), building:GetNextLevel()))
            end
        end
    end
    function item:OnBuildingUpgradingBegin(building)
        self:ChangeStatus("building")
    end
    function item:OnBuildingUpgrading(building)
        self:UpdateProgress(building)
    end
    function item:OnBuildingUpgradingEnd(building)
        self:ChangeStatus("normal")
    end
    function item:ChangeStatus(status)
        if self.status == status then
            return
        end
        if status == "instant" then
            self:HideNormal()
            self:HideProgress()
            self:HideDisable()
            self:HideMax()

            self:ShowInstant()
        elseif status == "normal" then
            self:HideInstant()
            self:HideProgress()
            self:HideDisable()
            self:HideMax()

            self:ShowNormal()
        elseif status == "building" then
            self:HideInstant()
            self:HideNormal()
            self:HideDisable()
            self:HideMax()

            self:ShowProgress()
        elseif status == "disable" then
            self:HideInstant()
            self:HideNormal()
            self:HideProgress()
            self:HideMax()

            self:ShowDisable()
        elseif status == "max" then
            self:HideInstant()
            self:HideNormal()
            self:HideProgress()
            self:HideDisable()

            self:ShowMax()
        end
        self.status = status
        return self
    end
    function item:HideInstant()
        gem_bg:setVisible(false)
        instant_build:setVisible(false)
    end
    function item:ShowInstant()
        gem_bg:setVisible(true)
        instant_build:setVisible(true)
    end
    function item:HideNormal()
        normal_build:setVisible(false)
    end
    function item:ShowNormal()
        normal_build:setVisible(true)
        self:SetConditionLabel(_("满足条件升级"), UIKit:hex2c3b(0x007c23))
    end
    function item:HideProgress()
        progress:setVisible(false)
        speed_up:setVisible(false)
    end
    function item:ShowProgress()
        progress:setVisible(true)
        speed_up:setVisible(true)
    end
    function item:HideDisable()
        normal_build:setButtonEnabled(true)
        normal_build:setVisible(false)
    end
    function item:ShowDisable()
        normal_build:setButtonEnabled(false)
        normal_build:setVisible(true)
        self:SetConditionLabel(_("需要城堡等级")..self.building:GetNextLevel(), UIKit:hex2c3b(0x7e0000))
    end
    function item:HideMax()

    end
    function item:ShowMax()
        normal_build:setVisible(false)
        condition_label:setVisible(false)
    end
    return item
end

return GameUIHasBeenBuild



