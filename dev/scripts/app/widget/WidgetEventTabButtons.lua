local promise = import("..utils.promise")
local cocos_promise = import("..utils.cocos_promise")
local Localize = import("..utils.Localize")
local SoldierManager = import("..entity.SoldierManager")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIMilitaryTechSpeedUp = import("..ui.GameUIMilitaryTechSpeedUp")
local GameUIBuildingSpeedUp = import("..ui.GameUIBuildingSpeedUp")
local GameUIBarracksSpeedUp = import("..ui.GameUIBarracksSpeedUp")
local GameUIToolShopSpeedUp = import("..ui.GameUIToolShopSpeedUp")
local WidgetTab = import(".WidgetTab")
local timer = app.timer
local WIDGET_WIDTH = 640
local WIDGET_HEIGHT = 300
local TAB_HEIGHT = 42
local WidgetEventTabButtons = class("WidgetEventTabButtons", function()
    local rect = cc.rect(0, 0, WIDGET_WIDTH, WIDGET_HEIGHT + TAB_HEIGHT)
    local node = display.newClippingRegionNode(rect)
    node:setTouchEnabled(true)
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
-- 建筑事件
function WidgetEventTabButtons:OnDestoryDecorator()
    self:EventChangeOn("build")
end
function WidgetEventTabButtons:OnUpgradingBegin(building, current_time, city)
    self:EventChangeOn("build")
    self:RefreshBuildQueueByType("build")
end
function WidgetEventTabButtons:OnUpgrading(building, current_time, city)
    if self:IsShow() and self:GetCurrentTab() == "build" then
        self:IteratorAllItem(function(i, v)
            if v:GetEventKey() == building:UniqueKey() then
                v:SetProgressInfo(self:BuildingDescribe(building))
                self:SetProgressItemBtnLabel(self:IsAbleToFreeSpeedup(building),building:UniqueUpgradingKey(),v)
            end
        end)
    end
end
function WidgetEventTabButtons:OnUpgradingFinished(building, city)
    self:EventChangeOn("build")
    self:RefreshBuildQueueByType("build", "soldier", "material", "technology")
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
    self:EventChangeOn("material")
end
function WidgetEventTabButtons:OnGetMaterialsWithEvent(tool_shop, event)
    self:EventChangeOn("material")
end

-- 军事科技
function WidgetEventTabButtons:OnSoldierStarEventsTimer(star_event)
    if self:IsShow() and self:GetCurrentTab() == "technology" then
        self:IteratorAllItem(function(i, v)
            if v.GetEventKey and v:GetEventKey() == star_event:Id() then
                v:SetProgressInfo(self:MilitaryTechDescribe(star_event))
                self:SetProgressItemBtnLabel(DataUtils:getFreeSpeedUpLimitTime()>star_event:GetTime(),star_event:Id(),v)
            end
        end)
    end
end
function WidgetEventTabButtons:OnMilitaryTechEventsTimer(tech_event)
    if self:IsShow() and self:GetCurrentTab() == "technology" then
        self:IteratorAllItem(function(i, v)
            if v.GetEventKey and v:GetEventKey() == tech_event:Id() then
                v:SetProgressInfo(self:MilitaryTechDescribe(tech_event))
                self:SetProgressItemBtnLabel(DataUtils:getFreeSpeedUpLimitTime()>tech_event:GetTime(),tech_event:Id(),v)
            end
        end)
    end
end
function WidgetEventTabButtons:OnMilitaryTechEventsChanged()
    self:EventChangeOn("technology")
    self:RefreshBuildQueueByType("technology")
end
function WidgetEventTabButtons:OnSoldierStarEventsChanged()
    self:EventChangeOn("technology")
    self:RefreshBuildQueueByType("technology")
end
function WidgetEventTabButtons:EventChangeOn(event_type)
    self:RefreshBuildQueueByType(event_type)
    if self:GetCurrentTab() == event_type then
        self:PromiseOfSwitch()
    end
end
------
function WidgetEventTabButtons:ctor(city, ratio)
    self.view_rect = cc.rect(0, 0, WIDGET_WIDTH * ratio, (WIDGET_HEIGHT + TAB_HEIGHT) * ratio)
    self:setClippingRegion(self.view_rect)

    self.item_array = {}
    local node = display.newNode():addTo(self)
    node:scale(ratio)
    cc.Layer:create():addTo(node):pos(0, -WIDGET_HEIGHT + TAB_HEIGHT):setContentSize(cc.size(WIDGET_WIDTH, WIDGET_HEIGHT + TAB_HEIGHT))
    self.node = node
    self.tab_buttons, self.tab_map = self:CreateTabButtons()
    self.tab_buttons:addTo(node, 2):pos(0, 0)
    self.back_ground = self:CreateBackGround():addTo(node)

    self.city = city
    city:AddListenOnType(self, City.LISTEN_TYPE.UPGRADE_BUILDING)
    city:AddListenOnType(self, City.LISTEN_TYPE.DESTROY_DECORATOR)

    self.barracks = city:GetFirstBuildingByType("barracks")
    self.barracks:AddBarracksListener(self)

    self.blackSmith = city:GetFirstBuildingByType("blackSmith")
    self.blackSmith:AddBlackSmithListener(self)

    self.toolShop = city:GetFirstBuildingByType("toolShop")
    self.toolShop:AddToolShopListener(self)

    city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.OnSoldierStarEventsTimer)
    city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.OnMilitaryTechEventsTimer)
    city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED)
    city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED)


    self:Reset()
    self:ShowStartEvent()
    self.tab_map["build"]:SetSelect(true)
    self:RefreshBuildQueueByType("build", "soldier", "material", "technology")
end
function WidgetEventTabButtons:RefreshBuildQueueByType(...)
    local cur_tab = self:GetCurrentTab()
    local city = self.city
    for _,key in ipairs{...} do
        local item = self.tab_map[key]
        local able = cur_tab ~= key and self:IsTabEnable(key)
        if key == "build" then
            item:SetActiveNumber(#city:GetUpgradingBuildings(), city:BuildQueueCounts()):Enable(able)
        elseif key == "soldier" then
            item:SetActiveNumber(self.barracks:IsRecruting() and 1 or 0, self.barracks:IsUnlocked() and 1 or 0):Enable(able)
        elseif key == "material" then
            local count = 0
            count = count + (self.blackSmith:IsMakingEquipment() and 1 or 0)
            count = count + (self.toolShop:IsMakingAny(timer:GetServerTime()) and 1 or 0)
            local total_count = 0
            total_count = total_count + (self.toolShop:IsUnlocked() and 1 or 0)
            total_count = total_count + (self.blackSmith:IsUnlocked() and 1 or 0)
            item:SetActiveNumber(count, total_count):Enable(able)
        elseif key == "technology" then
            local total_num = 0
            local buildings = {
                "academy",
                "trainingGround",
                "hunterHall",
                "stable",
                "workshop",
            }
            for i,v in ipairs(buildings) do
                if city:GetFirstBuildingByType(v):IsUnlocked() then
                    total_num = total_num + 1
                end
            end
            item:SetActiveNumber(city:GetSoldierManager():GetTotalUpgradingMilitaryTechNum()+#city:GetProductionTechEventsArray(), total_num):Enable(able)
        end
    end
end
function WidgetEventTabButtons:ShowStartEvent()
    if #self.city:GetUpgradingBuildings() > 0 then
        return self:PromiseOfShowTab("build")
    elseif self.barracks:IsRecruting() then
        return self:PromiseOfShowTab("soldier")
    elseif self.blackSmith:IsMakingEquipment() or self.toolShop:IsMakingAny(timer:GetServerTime()) then
        return self:PromiseOfShowTab("material")
    end
end
function WidgetEventTabButtons:onExit()
    self.toolShop:RemoveToolShopListener(self)
    self.blackSmith:RemoveBlackSmithListener(self)
    self.barracks:RemoveBarracksListener(self)
    self.city:RemoveListenerOnType(self, City.LISTEN_TYPE.UPGRADE_BUILDING)
    self.city:RemoveListenerOnType(self, City.LISTEN_TYPE.DESTROY_DECORATOR)
    self.city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.OnSoldierStarEventsTimer)
    self.city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.OnMilitaryTechEventsTimer)
    self.city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED)
    self.city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED)
end
function WidgetEventTabButtons:InsertEvent(func)
    table.insert(self.event_queue, func)
end
-- 构造ui
function WidgetEventTabButtons:CreateTabButtons()
    local node = display.newNode()
    display.newSprite("tab_background_578x50.png"):addTo(node):align(display.LEFT_BOTTOM)
    local origin_x = 138 * 4 + 28
    -- hide
    local btn = cc.ui.UIPushButton.new({normal = "hide_btn_up.png",
        pressed = "hide_btn_down.png"}):addTo(node)
        :align(display.LEFT_BOTTOM, origin_x, 0)
        :onButtonClicked(function(event)
            if not self:IsShow() then
                self:PromiseOfShow()
            else
                self:PromiseOfHide()
            end
        end)
    self.arrow = cc.ui.UIImage.new("hide_icon.png"):addTo(btn):align(display.CENTER, 56/2, TAB_HEIGHT/2)


    local icon_map = {
        { "technology", "tech_39x38.png" },
        { "material", "battle_39x38.png" },
        { "soldier", "soldier_39x38.png" },
        { "build", "build_39x38.png" },
    }
    local tab_map = {}
    origin_x = origin_x - 4
    for i, v in ipairs(icon_map) do
        local tab_type = v[1]
        local tab_png = v[2]
        tab_map[tab_type] = WidgetTab.new({
            on = "tab_button_down_142x42.png",
            off = "tab_button_up_142x42.png",
            tab = tab_png,
        }, 142, TAB_HEIGHT)
            :addTo(node):align(display.LEFT_BOTTOM,origin_x + (i - 5) * (142 + 1), 4)
            :OnTabPress(handler(self, self.OnTabClicked))
            :EnableTag(true):SetActiveNumber(0, 1)
    end
    return node, tab_map
end
function WidgetEventTabButtons:CreateBackGround()
    local back = cc.ui.UIImage.new("tab_background_640x106.png", {scale9 = true,
        capInsets = cc.rect(2, 2, WIDGET_WIDTH - 4, 106 - 4)
    }):align(display.LEFT_BOTTOM):setLayoutSize(WIDGET_WIDTH, 50)
    return back
end
function WidgetEventTabButtons:CreateItem()
    return self:CreateProgressItem():align(display.LEFT_CENTER)
end
function WidgetEventTabButtons:CreateBottom()
    return self:CreateOpenItem():align(display.LEFT_CENTER)
end
function WidgetEventTabButtons:CreateMilitaryItem(building)
    return self:CreateOpenMilitaryTechItem(building):align(display.LEFT_CENTER)
end
function WidgetEventTabButtons:CreateProgressItem()
    local progress = display.newProgressTimer("progress_bar_432x36.png", display.PROGRESS_TIMER_BAR)
    progress:setBarChangeRate(cc.p(1,0))
    progress:setMidpoint(cc.p(0,0))
    progress:setPercentage(100)
    display.newSprite("progress_background_432x36.png"):addTo(progress, -1):align(display.LEFT_BOTTOM)
    local bg = display.newSprite("progress_bg_head_43x43.png"):addTo(progress, 1):align(display.CENTER, 0, 36/2)
    display.newSprite("hourglass_39x46.png"):addTo(bg):align(display.CENTER, 43/2, 43/2):scale(0.8)

    local describe = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xd1ca95)}):addTo(progress):align(display.LEFT_CENTER, 30, 36/2)

    local btn = WidgetPushButton.new({normal = "green_btn_up_142x39.png",
        pressed = "green_btn_down_142x39.png",
        disabled = "blue_btn_up_142x39.png",
    }
    ,{}
    ,{
        disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    }):addTo(progress)
        :align(display.RIGHT_CENTER, WIDGET_WIDTH - 55, 36/2)
        :setButtonLabel(cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("加速"),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)}))
        :onButtonClicked(function(event)
            end)
    cc.ui.UIImage.new("divide_line_489x2.png"):addTo(progress)
        :align(display.LEFT_BOTTOM, -38, -6):setLayoutSize(638, 2)


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
    }):addTo(node):align(display.RIGHT_CENTER, WIDGET_WIDTH - 55, 0)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("打开"),
            size = 18,
            color = 0xfff3c7,
            shadow = true
        }))


    function node:SetLabel(str)
        if label:getString() ~= str then
            label:setString(str)
        end
        return self
    end
    function node:OnOpenClicked(func)
        button:onButtonClicked(func)
        return self
    end

    return node
end
function WidgetEventTabButtons:CreateOpenMilitaryTechItem(building)
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
    }):addTo(node):align(display.RIGHT_CENTER, WIDGET_WIDTH - 55, 0)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("打开"),
            size = 18,
            color = 0xfff3c7,
            shadow = true
        }))
        :onButtonClicked(function(event)
            print("CreateOpenMilitaryTechItem==",building:GetType())
            UIKit:newGameUI('GameUIMilitaryTechBuilding', City, building):addToCurrentScene(true)
        end)

    cc.ui.UIImage.new("divide_line_489x2.png"):addTo(node)
        :align(display.LEFT_BOTTOM, -38, -25):setLayoutSize(638, 2)
    function node:SetLabel(str)
        if label:getString() ~= str then
            label:setString(str)
        end
        return self
    end

    return node
end
-----
function WidgetEventTabButtons:Reset()
    for k, v in pairs(self.item_array) do
        v:removeFromParent()
    end
    for k, v in pairs(self.tab_map) do
        v:Enable(self:IsTabEnable(k)):SetHighLight(false)
    end
    self.item_array = {}
    self:ResizeBelowHorizon(0)
    self.node:stopAllActions()
    self:AdapterPosition()
    self:ResetPosition()
    self.arrow:flipY(true)
    self:Lock(false)
end
function WidgetEventTabButtons:IsTabEnable(tab)
    if tab == "build" then
        return true
    elseif tab == "soldier" and self.barracks:IsUnlocked() then
        return true
    elseif tab == "material" and (self.toolShop:IsUnlocked() or self.blackSmith:IsUnlocked()) then
        return true
    elseif tab == "technology" then
        local city = self.city
        local total_num = 0
        local buildings = {
            "academy",
            "trainingGround",
            "hunterHall",
            "stable",
            "workshop",
        }
        for _,v in ipairs(buildings) do
            if city:GetFirstBuildingByType(v):IsUnlocked() then
                total_num = total_num + 1
            end
        end
        return total_num > 0
    end
    return false
end
function WidgetEventTabButtons:ResetItemPosition()
    for i, v in ipairs(self.item_array) do
        v:pos(40, (i-1) * 50 + 25)
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
    self.tab_map[tab]:Enable(true):Active(true)
end
function WidgetEventTabButtons:OnTabClicked(widget, is_pressed)
    local tab
    for k, v in pairs(self.tab_map) do
        if v == widget then
            tab = k
        end
    end
    self:ResetOtherTabByCurrentTab(tab)
    self.tab_map[tab]:SetSelect(true)
    if self:IsShow() then
        if is_pressed then
            self:PromiseOfSwitch()
        else
            self:PromiseOfHide()
        end
    else
        self:PromiseOfForceShow()
    end
end
function WidgetEventTabButtons:ResetOtherTabByCurrentTab(tab)
    for k, v in pairs(self.tab_map) do
        if k ~= tab then
            v:Enable(self:IsTabEnable(k)):Active(false)
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
    self.node:setPositionY(self:HidePosY())
end
function WidgetEventTabButtons:PromiseOfSwitch()
    return self:PromiseOfHide():next(function()
        return self:PromiseOfShow()
    end)
end
function WidgetEventTabButtons:PromiseOfHide()
    self.node:stopAllActions()
    self:Lock(true)
    return cocos_promise.promiseOfMoveTo(self.node, 0, self:HidePosY(), 0.15, "sineIn"):next(function()
        self:Reset()
    end)
end
function WidgetEventTabButtons:PromiseOfShow()
    if not self:OnBeforeShow() then
        return cocos_promise.defer()
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
function WidgetEventTabButtons:HidePosY()
    return -self.back_ground:getContentSize().height
end
function WidgetEventTabButtons:OnBeforeShow()
    return self:IsTabEnable(self:GetCurrentTab())
end
function WidgetEventTabButtons:GetCurrentTab()
    for k, v in pairs(self.tab_map) do
        if v:IsSelected() then
            return k
        end
    end
end
function WidgetEventTabButtons:Reload()
    self:Reset()
    self:Load()
end
function WidgetEventTabButtons:IsAbleToFreeSpeedup(building)
    return building:IsAbleToFreeSpeedUpByTime(app.timer:GetServerTime())
end
function WidgetEventTabButtons:UpgradeBuildingHelpOrSpeedup(building)
    local eventType = building:EventType()
    if self:IsAbleToFreeSpeedup(building) then
        NetManager:getFreeSpeedUpPromise(eventType,building:UniqueUpgradingKey())
            :catch(function(err)
                dump(err:reason())
            end)
    else
        if not Alliance_Manager:GetMyAlliance():IsDefault() then
            -- 是否已经申请过联盟加速
            local isRequested = Alliance_Manager:GetMyAlliance()
                :HasBeenRequestedToHelpSpeedup(building:UniqueUpgradingKey())
            if not isRequested then
                NetManager:getRequestAllianceToSpeedUpPromise(eventType,building:UniqueUpgradingKey())
                    :catch(function(err)
                        dump(err:reason())
                    end)
                return
            end
        end
        -- 没加入联盟或者已加入联盟并且申请过帮助时执行使用道具加速
        GameUIBuildingSpeedUp.new(building):addToCurrentScene(true)
    end
end
function WidgetEventTabButtons:MiliTaryTechUpgradeOrSpeedup(event)
    if DataUtils:getFreeSpeedUpLimitTime()>event:GetTime() then
        NetManager:getFreeSpeedUpPromise(event:GetEventType(),event:Id())
            :catch(function(err)
                dump(err:reason())
            end)
    else
        if not Alliance_Manager:GetMyAlliance():IsDefault() then
            -- 是否已经申请过联盟加速
            local isRequested = Alliance_Manager:GetMyAlliance()
                :HasBeenRequestedToHelpSpeedup(event:Id())
            if not isRequested then
                NetManager:getRequestAllianceToSpeedUpPromise(event:GetEventType(),event:Id())
                    :catch(function(err)
                        dump(err:reason())
                    end)
                return
            end
        end
        -- 没加入联盟或者已加入联盟并且申请过帮助时执行使用道具加速
        GameUIMilitaryTechSpeedUp.new(event):addToCurrentScene(true)
    end
end
function WidgetEventTabButtons:SoldierRecruitUpgradeOrSpeedup()
    GameUIBarracksSpeedUp.new(self.city:GetFirstBuildingByType("barracks")):addToCurrentScene(true)
end
function WidgetEventTabButtons:MaterialEventUpgradeOrSpeedup()
    GameUIToolShopSpeedUp.new(self.city:GetFirstBuildingByType("toolShop")):addToCurrentScene(true)
end

function WidgetEventTabButtons:SetProgressItemBtnLabel(canFreeSpeedUp,event_key,event_item)
    local old_status = event_item.status
    local btn_label
    local btn_images
    if canFreeSpeedUp then
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
                :HasBeenRequestedToHelpSpeedup(event_key) then
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
        if v:IsSelected() then
            self:HighLightTab(k)
            if k == "build" then
                self:InsertItem(self:CreateBottom():OnOpenClicked(function(event)
                    UIKit:newGameUI('GameUIHasBeenBuild', self.city):addToCurrentScene(true)
                end):SetLabel(_("查看已拥有的建筑")))

                local buildings = self.city:GetUpgradingBuildings(true)
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
                    self:SetProgressItemBtnLabel(self:IsAbleToFreeSpeedup(v),v:UniqueUpgradingKey(),event_item)
                    table.insert(items, event_item)
                end
                self:InsertItem(items)
            elseif k == "soldier" then
                self:InsertItem(self:CreateBottom():OnOpenClicked(function(event)
                    UIKit:newGameUI('GameUIBarracks', self.city, self.barracks):addToCurrentScene(true)
                end):SetLabel(_("查看现有的士兵")))
                local event = self.barracks:GetRecruitEvent()
                if event:IsRecruting() then
                    local item = self:CreateItem():SetProgressInfo(self:SoldierDescribe(event))
                        :SetEventKey(event:Id())
                        :OnClicked(
                            function(e)
                                if e.name == "CLICKED_EVENT" then
                                    self:SoldierRecruitUpgradeOrSpeedup()
                                end
                            end
                        )
                    self:InsertItem(item)
                end
            elseif k == "technology" then
                self:InsertItem(self:CreateBottom():OnOpenClicked(function(event)
                    UIKit:newGameUI('GameUIQuickTechnology', self.city):addToCurrentScene(true)
                end):SetLabel(_("查看现有的科技")))

                -- 军事科技部分
                local soldier_manager = self.city:GetSoldierManager()
                local trainingGround = City:GetFirstBuildingByType("trainingGround")
                if trainingGround:GetLevel()>0 then
                    if soldier_manager:IsUpgradingMilitaryTech("trainingGround") then
                        local event = soldier_manager:GetUpgradingMilitaryTech("trainingGround")
                        local item = self:CreateItem()
                            :SetProgressInfo(self:MilitaryTechDescribe(event))
                            :SetEventKey(event:Id())
                            :OnClicked(
                                function(e)
                                    if e.name == "CLICKED_EVENT" then
                                        self:MiliTaryTechUpgradeOrSpeedup(event)
                                    end
                                end
                            )
                        self:SetProgressItemBtnLabel(DataUtils:getFreeSpeedUpLimitTime()>event:GetTime(),event:Id(),item)
                        self:InsertItem(item)
                    else
                        self:InsertItem(self:CreateMilitaryItem(trainingGround):SetLabel(_("训练营地空闲")))
                    end
                end
                local hunterHall = City:GetFirstBuildingByType("hunterHall")
                if hunterHall:GetLevel()>0 then
                    if soldier_manager:IsUpgradingMilitaryTech("hunterHall") then
                        local event = soldier_manager:GetUpgradingMilitaryTech("hunterHall")
                        local item = self:CreateItem()
                            :SetProgressInfo(self:MilitaryTechDescribe(event))
                            :SetEventKey(event:Id())
                            :OnClicked(
                                function(e)
                                    if e.name == "CLICKED_EVENT" then
                                        self:MiliTaryTechUpgradeOrSpeedup(event)
                                    end
                                end
                            )
                        self:SetProgressItemBtnLabel(DataUtils:getFreeSpeedUpLimitTime()>event:GetTime(),event:Id(),item)
                        self:InsertItem(item)
                    else
                        self:InsertItem(self:CreateMilitaryItem(hunterHall):SetLabel(_("猎手大厅空闲")))
                    end
                end
                local stable = City:GetFirstBuildingByType("stable")
                if stable:GetLevel()>0 then
                    if soldier_manager:IsUpgradingMilitaryTech("stable") then
                        local event = soldier_manager:GetUpgradingMilitaryTech("stable")
                        local item = self:CreateItem()
                            :SetProgressInfo(self:MilitaryTechDescribe(event))
                            :SetEventKey(event:Id())
                            :OnClicked(
                                function(e)
                                    if e.name == "CLICKED_EVENT" then
                                        self:MiliTaryTechUpgradeOrSpeedup(event)
                                    end
                                end
                            )
                        self:SetProgressItemBtnLabel(DataUtils:getFreeSpeedUpLimitTime()>event:GetTime(),event:Id(),item)
                        self:InsertItem(item)
                    else
                        self:InsertItem(self:CreateMilitaryItem(stable):SetLabel(_("马厩空闲")))
                    end
                end
                local workshop = City:GetFirstBuildingByType("workshop")
                if workshop:GetLevel()>0 then
                    if soldier_manager:IsUpgradingMilitaryTech("workshop") then
                        local event = soldier_manager:GetUpgradingMilitaryTech("workshop")
                        local item = self:CreateItem()
                            :SetProgressInfo(self:MilitaryTechDescribe(event))
                            :SetEventKey(event:Id())
                            :OnClicked(
                                function(e)
                                    if e.name == "CLICKED_EVENT" then
                                        self:MiliTaryTechUpgradeOrSpeedup(event)
                                    end
                                end
                            )
                        self:SetProgressItemBtnLabel(DataUtils:getFreeSpeedUpLimitTime()>event:GetTime(),event:Id(),item)
                        self:InsertItem(item)
                    else
                        self:InsertItem(self:CreateMilitaryItem(workshop):SetLabel(_("车间空闲")))
                    end
                end
            elseif k == "material" then
                self:InsertItem(self:CreateBottom():OnOpenClicked(function(event)
                    UIKit:newGameUI('GameUIMaterials', self.toolShop, self.blackSmith):addToCurrentScene(true)
                end):SetLabel(_("查看材料")))
                local event = self.blackSmith:GetMakeEquipmentEvent()
                if event:IsMaking() then
                    local item = self:CreateItem():SetProgressInfo(self:EquipmentDescribe(event))
                        :SetEventKey(event:Id())
                        :OnClicked(
                            function(e)
                                if e.name == "CLICKED_EVENT" then
                                    self:MaterialEventUpgradeOrSpeedup()
                                end
                            end
                        )
                    self:InsertItem(item)
                    -- self:InsertItem(self:CreateItem()
                    --     :SetProgressInfo(self:EquipmentDescribe(event))
                    --     :SetEventKey(event:UniqueKey())
                    -- )
                end
                local events = self.toolShop:GetMakeMaterialsEvents()
                for k, v in pairs(events) do
                    if v:IsMaking(timer:GetServerTime()) then
                        local item = self:CreateItem():SetProgressInfo(self:MaterialDescribe(v))
                            :SetEventKey(v:Id())
                            :OnClicked(
                                function(e)
                                    if e.name == "CLICKED_EVENT" then
                                        self:MaterialEventUpgradeOrSpeedup()
                                    end
                                end
                            )
                        self:InsertItem(item)

                        -- self:InsertItem(
                        --     self:CreateItem()
                        --         :SetProgressInfo(self:MaterialDescribe(v))
                        --         :SetEventKey(v:UniqueKey())
                        -- )
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
function WidgetEventTabButtons:MilitaryTechDescribe(event)
    local current_time = app.timer:GetServerTime()
    local str = event:GetLocalizeDesc().."  "..GameUtils:formatTimeStyle1(event:GetTime())
    return str, event:Percent(current_time)
end

return WidgetEventTabButtons
































