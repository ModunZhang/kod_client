local promise = import("..utils.promise")
local cocos_promise = import("..utils.cocos_promise")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetTab = import(".WidgetTab")
local WIDGET_WIDTH = 491
local WIDGET_HEIGHT = 300
local TAB_HEIGHT = 47
local WidgetEventTabButtons = class("WidgetEventTabButtons", function()
    local rect = cc.rect(0, 0, WIDGET_WIDTH, WIDGET_HEIGHT + TAB_HEIGHT)
    local node = display.newClippingRegionNode(rect)
    node.view_rect = rect
    node.locked = false
    node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
        if node.locked then
            return false
        end
        if ("began" == event.name or "moved" == event.name or "ended" == event.name)
            and node:isTouchInViewRect(event) then
            return true
        else
            return false
        end
    end)
    return node
end)
function WidgetEventTabButtons:isTouchInViewRect(event)
    local viewRect = self:convertToWorldSpace(cc.p(self.view_rect.x, self.view_rect.y))
    viewRect.width = self.view_rect.width
    viewRect.height = self.view_rect.height
    return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
end
local timer = app.timer
-- 建筑事件
function WidgetEventTabButtons:OnDestoryDecorator()
    self:EventChangeOn("build")
end
function WidgetEventTabButtons:OnUpgradingBegin(building, current_time, city)
    self:EventChangeOn("build")
end
function WidgetEventTabButtons:OnUpgrading(building, current_time, city)
    if self:IsShow() and self:GetCurrentTab() == "build" then
        self:IteratorAllItem(function(i, v)
            if v:GetEventKey() == building:UniqueKey() then
                v:SetProgressInfo(self:BuildingDescribe(building))
                self:SetUpgradeBuilidingBtnLabel(building,v)
            end
        end)
    end
end
function WidgetEventTabButtons:OnUpgradingFinished(building, current_time, city)
    self:EventChangeOn("build")
end
-- 兵营事件
function WidgetEventTabButtons:OnBeginRecruit(barracks, event)
    self:EventChangeOn("soldier")
end
function WidgetEventTabButtons:OnRecruiting(barracks, event, current_time)
    if self:IsShow() and self:GetCurrentTab() == "soldier" then
        self:IteratorAllItem(function(i, v)
            v:SetProgressInfo(self:SoldierDescribe(event))
        end)
    end
end
function WidgetEventTabButtons:OnEndRecruit(barracks, event, current_time)
    self:EventChangeOn("soldier")
end
-- 装备事件
function WidgetEventTabButtons:OnBeginMakeEquipmentWithEvent(black_smith, event)
    self:EventChangeOn("material")
end
function WidgetEventTabButtons:OnMakingEquipmentWithEvent(black_smith, event, current_time)
    if self:IsShow() and self:GetCurrentTab() == "material" then
        self:IteratorAllItem(function(i, v)
            if v:GetEventKey() == event:UniqueKey() then
                v:SetProgressInfo(self:EquipmentDescribe(event))
            end
        end)
    end
end
function WidgetEventTabButtons:OnEndMakeEquipmentWithEvent(black_smith, event, equipment)
    self:EventChangeOn("material")
end
-- 材料事件
function WidgetEventTabButtons:OnBeginMakeMaterialsWithEvent(tool_shop, event)
    self:EventChangeOn("material")
end
function WidgetEventTabButtons:OnMakingMaterialsWithEvent(tool_shop, event, current_time)
    if self:IsShow() and self:GetCurrentTab() == "material" then
        self:IteratorAllItem(function(i, v)
            if v:GetEventKey() == event:UniqueKey() then
                v:SetProgressInfo(self:MaterialDescribe(event))
            end
        end)
    end
end
function WidgetEventTabButtons:OnEndMakeMaterialsWithEvent(tool_shop, event, current_time)
end
function WidgetEventTabButtons:OnGetMaterialsWithEvent(tool_shop, event)
    self:EventChangeOn("material")
end
function WidgetEventTabButtons:EventChangeOn(event_type)
    if self:GetCurrentTab() == event_type then
        self:PromiseOfSwitch()
    end
end
------
function WidgetEventTabButtons:ctor(city)
    self.item_array = {}
    local node = display.newNode():addTo(self)
    display.newLayer():addTo(node):pos(0, -WIDGET_HEIGHT + TAB_HEIGHT):setContentSize(cc.size(WIDGET_WIDTH, WIDGET_HEIGHT + TAB_HEIGHT))
    self.node = node
    self.tab_buttons, self.tab_map = self:CreateTabButtons()
    self.tab_buttons:addTo(node, 2):pos(0, 0)
    self.back_ground = self:CreateBackGround():addTo(node)
    self:Reset()
    self:HighLightTab("build")


    self.city = city
    city:AddListenOnType(self, City.LISTEN_TYPE.UPGRADE_BUILDING)
    city:AddListenOnType(self, City.LISTEN_TYPE.DESTROY_DECORATOR)

    self.barracks = city:GetFirstBuildingByType("barracks")
    self.barracks:AddBarracksListener(self)

    self.blackSmith = city:GetFirstBuildingByType("blackSmith")
    self.blackSmith:AddBlackSmithListener(self)

    self.toolShop = city:GetFirstBuildingByType("toolShop")
    self.toolShop:AddToolShopListener(self)
end
function WidgetEventTabButtons:onExit()
    self.toolShop:RemoveToolShopListener(self)
    self.blackSmith:RemoveBlackSmithListener(self)
    self.barracks:RemoveBarracksListener(self)
    self.city:RemoveListenerOnType(self, City.LISTEN_TYPE.UPGRADE_BUILDING)
    self.city:RemoveListenerOnType(self, City.LISTEN_TYPE.DESTROY_DECORATOR)
end
function WidgetEventTabButtons:InsertEvent(func)
    table.insert(self.event_queue, func)
end
-- 构造ui
function WidgetEventTabButtons:CreateTabButtons()
    local node = display.newNode()
    local icon_map = {
        { "material", "battle_39x38.png" },
        { "technology", "tech_39x38.png" },
        { "soldier", "soldier_39x38.png" },
        { "build", "build_39x38.png" },
    }
    local tab_map = {}
    local unit_width = 111
    local origin_x = unit_width * 4
    for i, v in ipairs(icon_map) do
        local tab_type = v[1]
        local tab_png = v[2]
        tab_map[tab_type] = WidgetTab.new({
            on = "tab_button_down_111x47.png",
            off = "tab_button_up_111x47.png",
            tab = tab_png
        }, unit_width, TAB_HEIGHT)
            :addTo(node):align(display.LEFT_BOTTOM,origin_x + (i - 5) * unit_width, 0)
            :OnTabPress(handler(self, self.OnTabClicked))
    end
    local btn = cc.ui.UIPushButton.new({normal = "hide_btn_up_48x47.png",
        pressed = "hide_btn_down_48x47.png"}):addTo(node)
        :align(display.LEFT_BOTTOM, 111*4, 0)
        :onButtonClicked(function(event)
            if not self:IsShow() then
                self:PromiseOfShow()
            else
                self:PromiseOfHide()
            end
        end)
    self.arrow = cc.ui.UIImage.new("hide_18x19.png"):addTo(btn):align(display.CENTER, 48/2, TAB_HEIGHT/2)
    return node, tab_map
end
function WidgetEventTabButtons:CreateBackGround()
    return cc.ui.UIImage.new("back_ground_491x105.png", {scale9 = true,
        capInsets = cc.rect(10, 10, WIDGET_WIDTH - 20, 105 - 20)
    }):align(display.LEFT_BOTTOM):setLayoutSize(WIDGET_WIDTH, 50)
end
function WidgetEventTabButtons:CreateItem()
    return self:CreateProgressItem():align(display.LEFT_CENTER)
end
function WidgetEventTabButtons:CreateBottom()
    return self:CreateOpenItem():align(display.LEFT_CENTER)
end
function WidgetEventTabButtons:CreateProgressItem()
    local progress = display.newProgressTimer("progress_338x43.png", display.PROGRESS_TIMER_BAR)
    progress:setBarChangeRate(cc.p(1,0))
    progress:setMidpoint(cc.p(0,0))
    progress:setPercentage(100)

    local describe = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("城堡 (等级 2) 00:10:10"),
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xd1ca95)}):addTo(progress):align(display.LEFT_CENTER, 10, 43/2)

    local btn = WidgetPushButton.new({normal = "green_btn_up_142x39.png",
        pressed = "green_btn_down_142x39.png",
        disabled = "blue_btn_up_142x39.png",
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(progress)
        :align(display.LEFT_CENTER, 340, 43/2)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        :onButtonClicked(function(event)
            end)

    cc.ui.UIImage.new("divide_line_489x2.png"):addTo(progress)
        :align(display.LEFT_BOTTOM, -4, -5)


    function progress:SetProgressInfo(str, percent)
        if describe:getString() ~= str then
            describe:setString(str)
        end
        self:setPercentage(percent)
        return self
    end
    function progress:OnClicked(func)
        btn:onButtonClicked(func)
        return self
    end
    function progress:GetEventKey()
        return self.key
    end
    function progress:SetEventKey(key)
        self.key = key
        return self
    end
    function progress:SetButtonImages(images)
        btn:setButtonImage(cc.ui.UIPushButton.NORMAL, images["normal"], true)
        btn:setButtonImage(cc.ui.UIPushButton.PRESSED, images["pressed"], true)
        btn:setButtonImage(cc.ui.UIPushButton.DISABLED, images["disabled"], true)
        return self
    end
    function progress:SetButtonLabel(str)
        btn:setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = str,
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        return self
    end
    function progress:onEnter()
        btn:setButtonEnabled(true)
    end
    function progress:GetSpeedUpButton()
        return btn
    end
    progress:setNodeEventEnabled(true)

    return progress
end
function WidgetEventTabButtons:CreateOpenItem()
    local widget = self
    local node = display.newNode()
    local label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xd1ca95)}):addTo(node):align(display.LEFT_CENTER, 10, 0)


    local button = WidgetPushButton.new({normal = "blue_btn_up_142x39.png",
        pressed = "blue_btn_down_142x39.png",
        disabled = "blue_btn_up_142x39.png"
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(node)
        :align(display.LEFT_CENTER, 340, 0)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("打开"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        :onButtonClicked(function(event)
            if widget:GetCurrentTab() == "build" then
                UIKit:newGameUI('GameUIHasBeenBuild', City):addToCurrentScene(true)
            elseif widget:GetCurrentTab() == "soldier" then
                UIKit:newGameUI('GameUIBarracks', City, self.barracks):addToCurrentScene(true)
            elseif widget:GetCurrentTab() == "material" then
                UIKit:newGameUI('GameUIToolShop', City, self.toolShop):addToCurrentScene(true)
            end
        end)



    function node:SetLabel(str)
        if label:getString() ~= str then
            label:setString(str)
        end
        return self
    end
    function node:onEnter()
        button:setButtonEnabled(widget:GetCurrentTab() ~= "technology")
    end
    node:setNodeEventEnabled(true)

    return node
end
-----
function WidgetEventTabButtons:Reset()
    for k, v in pairs(self.item_array) do
        v:removeFromParentAndCleanup(true)
    end
    self.item_array = {}
    self:ResizeBelowHorizon(0)
    self.node:stopAllActions()
    self:AdapterPosition()
    self:ResetPosition()
    self.arrow:flipY(true)
    self:Lock(false)
end
function WidgetEventTabButtons:ResetItemPosition()
    for i, v in ipairs(self.item_array) do
        v:pos(5, (i-1) * 50 + 25)
    end
end
-- 操作
function WidgetEventTabButtons:IteratorAllItem(func)
    for i, v in pairs(self.item_array) do
        if i ~= 1 and func(i, v) then
            return
        end
    end
end
function WidgetEventTabButtons:InsertItem(item, pos)
    if type(item) == "table" then
        local count = #item
        for i = count, 1, -1 do
            self:InsertItem_(item[i], pos)
        end
    else
        self:InsertItem_(item, pos)
    end
    self:ResetItemPosition()
end
function WidgetEventTabButtons:InsertItem_(item, pos)
    item:addTo(self.back_ground, 2)
    if pos then
        table.insert(self.item_array, pos, item)
    else
        table.insert(self.item_array, item)
    end
end

-- 玩家操作动画
function WidgetEventTabButtons:PromiseOfShowTab(tab)
    self:HighLightTab(tab)
    return self:PromiseOfForceShow()
end
function WidgetEventTabButtons:HighLightTab(tab)
    self:ResetOtherTabByCurrentTab(tab)
    self.tab_map[tab]:Enable(false)
    self.tab_map[tab]:SetStatus(true)
end
function WidgetEventTabButtons:OnTabClicked(widget, is_pressed)
    assert(is_pressed)
    local tab
    for k, v in pairs(self.tab_map) do
        if v == widget then
            tab = k
            break
        end
    end
    self:ResetOtherTabByCurrentTab(tab)
    self.tab_map[tab]:Enable(false)
    self:PromiseOfForceShow()
end
function WidgetEventTabButtons:ResetOtherTabByCurrentTab(tab)
    for k, v in pairs(self.tab_map) do
        if k ~= tab then
            v:Enable(true)
            v:SetStatus(false)
        end
    end
end
function WidgetEventTabButtons:PromiseOfForceShow()
    if self:IsShow() then
        return self:PromiseOfSwitch()
    else
        return self:PromiseOfShow()
    end
end
function WidgetEventTabButtons:Lock(lock)
    self.locked = lock
end
function WidgetEventTabButtons:IsShow()
    return not self.arrow:isFlippedY()
end
function WidgetEventTabButtons:IsHide()
    return self.arrow:isFlippedY()
end
function WidgetEventTabButtons:ResizeBelowHorizon(new_height)
    local height = new_height < 50 and 50 or new_height
    local size = self.back_ground:getContentSize()
    self.back_ground:setContentSize(cc.size(size.width, height))
    self.node:setPositionY(- height)
    self.tab_buttons:setPositionY(height)
end
function WidgetEventTabButtons:Length(array_len)
    return array_len * 50
end
function WidgetEventTabButtons:AdapterPosition()
    self.tab_buttons:setPositionY(self.back_ground:getContentSize().height)
end
function WidgetEventTabButtons:ResetPosition()
    self.node:setPositionY(- self.back_ground:getContentSize().height)
end
function WidgetEventTabButtons:PromiseOfSwitch()
    return self:PromiseOfHide():next(function()
        return self:PromiseOfShow()
    end)
end
function WidgetEventTabButtons:PromiseOfHide()
    self.node:stopAllActions()
    self:Lock(true)
    return cocos_promise.promiseOfMoveTo(self.node, 0,
        - self.back_ground:getContentSize().height, 0.15, "sineIn"):next(function()
            self:Reset()
        end)
end
function WidgetEventTabButtons:PromiseOfShow()
    if not self:OnBeforeShow() then
        return promise.new():resolve()
    end
    local size = self.back_ground:getContentSize()
    self.back_ground:setContentSize(cc.size(size.width, size.height))
    self.tab_buttons:setPositionY(size.height)
    self:Lock(true)
    self:Reload()
    self.node:stopAllActions()
    return cocos_promise.promiseOfMoveTo(self.node, 0, 0, 0.15, "sineIn"):next(function()
        self.arrow:flipY(false)
        self:Lock(false)
    end)
end
function WidgetEventTabButtons:OnBeforeShow()
    local tab = self:GetCurrentTab()
    if tab == "build" then
        return true
    elseif tab == "soldier" and self.barracks:IsUnlocked() then
        return true
    elseif tab == "material" and self.toolShop:IsUnlocked() then
        return true
    end
    return false
end
function WidgetEventTabButtons:GetCurrentTab()
    for k, v in pairs(self.tab_map) do
        if v:IsPressed() then
            return k
        end
    end
    assert(false)
end
function WidgetEventTabButtons:Reload()
    self:Reset()
    self:Load()
end
function WidgetEventTabButtons:IsAbleToFreeSpeedup(building)
    return building:IsAbleToFreeSpeedUpByTime(app.timer:GetServerTime())
end
function WidgetEventTabButtons:UpgradeBuildingHelpOrSpeedup(building)
    if self:IsAbleToFreeSpeedup(building) then
        local eventType = ""
        if self.city:IsFunctionBuilding(building) then
            eventType = "buildingEvents"
        elseif self.city:IsHouse(building) then
            eventType = "houseEvents"
        elseif self.city:IsGate(building) then
            eventType = "wallEvents"
        elseif self.city:IsTower(building) then
            eventType = "towerEvents"
        end
        NetManager:getFreeSpeedUpPromise(eventType,building:UniqueUpgradingKey())
            :catch(function(err)
                dump(err:reason())
            end)
    else
        -- 是否已经申请过联盟加速
        local isRequested = Alliance_Manager:GetMyAlliance()
            :IsBuildingHasBeenRequestedToHelpSpeedup(building:UniqueUpgradingKey())
        if not isRequested then
            local eventType = ""
            if self.city:IsFunctionBuilding(building) then
                eventType = "building"
            elseif self.city:IsHouse(building) then
                eventType = "house"
            elseif self.city:IsGate(building) then
                eventType = "wall"
            elseif self.city:IsTower(building) then
                eventType = "tower"
            end
            NetManager:getRequestAllianceToSpeedUpPromise(eventType,building:UniqueUpgradingKey())
                :catch(function(err)
                    dump(err:reason())
                end)
        end
    end
end
function WidgetEventTabButtons:SetUpgradeBuilidingBtnLabel(building,event_item)
    local old_status = event_item.status
    local btn_label
    local btn_images
    if self:IsAbleToFreeSpeedup(building) then
        btn_label = _("免费加速")
        btn_images = {normal = "purple_btn_up_142x39.png",
            pressed = "purple_btn_down_142x39.png",
            disabled = "purple_btn_up_142x39.png",
        }
        event_item.status = "freeSpeedup"
    else
        -- 未加入联盟或者已经申请过联盟加速
        if Alliance_Manager:GetMyAlliance():IsDefault() or
            Alliance_Manager:GetMyAlliance()
                :IsBuildingHasBeenRequestedToHelpSpeedup(building:UniqueUpgradingKey()) then
            btn_label = _("加速")
            btn_images = {normal = "green_btn_up_142x39.png",
                pressed = "green_btn_down_142x39.png",
                disabled = "blue_btn_up_142x39.png",
            }
            event_item.status = "speedup"
        else
            btn_label = _("帮助")
            btn_images = {normal = "yellow_button_146x42.png",
                pressed = "yellow_button_highlight_146x42.png",
                disabled = "yellow_button_146x42.png",
            }
            event_item.status = "help"
        end
    end
    if old_status~= event_item.status then
        event_item:SetButtonLabel(btn_label)
        event_item:SetButtonImages(btn_images)
    end
end
function WidgetEventTabButtons:Load()
    for k, v in pairs(self.tab_map) do
        if v:IsPressed() then
            if k == "build" then
                self:InsertItem(self:CreateBottom():SetLabel(_("查看已拥有的建筑")))

                local buildings = self.city:GetOnUpgradingBuildings()
                local items = {}
                for i, v in ipairs(buildings) do
                    local event_item = self:CreateItem()
                        :SetProgressInfo(self:BuildingDescribe(v))
                        :SetEventKey(v:UniqueKey()):OnClicked(
                        function(event)
                            if event.name == "CLICKED_EVENT" then
                                self:UpgradeBuildingHelpOrSpeedup(v)
                            end
                        end
                        )
                    self:SetUpgradeBuilidingBtnLabel(v,event_item)
                    table.insert(items, event_item)
                end
                self:InsertItem(items)
            elseif k == "soldier" then
                self:InsertItem(self:CreateBottom():SetLabel(_("查看现有的士兵")))
                local event = self.barracks:GetRecruitEvent()
                if event:IsRecruting() then
                    self:InsertItem(self:CreateItem():SetProgressInfo(self:SoldierDescribe(event)))
                end
            elseif k == "technology" then
                self:InsertItem(self:CreateBottom():SetLabel(_("查看现有的科技")))
            elseif k == "material" then
                self:InsertItem(self:CreateBottom():SetLabel(_("查看材料")))
                local event = self.blackSmith:GetMakeEquipmentEvent()
                if event:IsMaking() then
                    self:InsertItem(self:CreateItem()
                        :SetProgressInfo(self:EquipmentDescribe(event))
                        :SetEventKey(event:UniqueKey())
                    )
                end
                local events = self.toolShop:GetMakeMaterialsEvents()
                for k, v in pairs(events) do
                    if v:IsMaking(timer:GetServerTime()) then
                        self:InsertItem(
                            self:CreateItem()
                                :SetProgressInfo(self:MaterialDescribe(v))
                                :SetEventKey(v:UniqueKey())
                        )
                    end
                end
            end
            self:ResizeBelowHorizon(self:Length(#self.item_array))
            return
        end
    end
end
function WidgetEventTabButtons:BuildingDescribe(building)
    local upgrade_info
    if iskindof(building, "ResourceUpgradeBuilding") and building:IsBuilding() then
        upgrade_info = string.format("%s", _("建造"))
    elseif building:IsUnlocking() then
        upgrade_info = string.format("%s", _("解锁"))
    else
        upgrade_info = string.format("%s%d", _("升级到 等级"), building:GetNextLevel())
    end
    local time = timer:GetServerTime()
    local str = string.format("%s (%s) %s",
        Localize.building_name[building:GetType()],
        upgrade_info,
        GameUtils:formatTimeStyle1(building:GetUpgradingLeftTimeByCurrentTime(time)))
    local percent = building:GetUpgradingPercentByCurrentTime(time)
    return str, percent
end
function WidgetEventTabButtons:SoldierDescribe(event)
    local soldier_type, count = event:GetRecruitInfo()
    local soldier_name = Localize.soldier_name[soldier_type]
    local current_time = timer:GetServerTime()
    local str = string.format("%s%s x%d %s", _("招募"), soldier_name, count, GameUtils:formatTimeStyle1(event:LeftTime(current_time)))
    return str, event:Percent(current_time)
end
function WidgetEventTabButtons:EquipmentDescribe(event)
    local current_time = app.timer:GetServerTime()
    local str = string.format("%s %s %s", _("正在制作"), Localize.equip[event:Content()], GameUtils:formatTimeStyle1(event:LeftTime(current_time)))
    return str, event:Percent(current_time)
end
function WidgetEventTabButtons:MaterialDescribe(event)
    local current_time = app.timer:GetServerTime()
    local str = string.format("%s x%d %s", _("制造材料"), event:TotalCount(), GameUtils:formatTimeStyle1(event:LeftTime(current_time)))
    return str, event:Percent(current_time)
end

return WidgetEventTabButtons











