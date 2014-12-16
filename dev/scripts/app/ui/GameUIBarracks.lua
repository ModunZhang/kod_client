--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local cocos_promise = import("..utils.cocos_promise")
local window = import("..utils.window")
local Localize = import("..utils.Localize")
local WidgetTips = import("..widget.WidgetTips")
local WidgetSoldierBox = import("..widget.WidgetSoldierBox")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local WidgetRecruitSoldier = import("..widget.WidgetRecruitSoldier")
local SoldierManager = import("..entity.SoldierManager")
local GameUIBarracks = UIKit:createUIClass("GameUIBarracks", "GameUIUpgradeBuilding")
function GameUIBarracks:ctor(city, barracks)
    GameUIBarracks.super.ctor(self, city, _("兵营"),barracks)
    self.barracks_city = city
    self.barracks = barracks
end
function GameUIBarracks:onEnter()
    GameUIBarracks.super.onEnter(self)
    self.soldier_map = {}
    self.timerAndTips = self:CreateTimerAndTips()
    self.recruit = self:CreateSoldierUI()
    self.specialRecruit = self:CreateSpecialSoldierUI()
    self:TabButtons()
    self.barracks:AddBarracksListener(self)
    self.barracks_city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)

end
function GameUIBarracks:onExit()
    self.barracks:RemoveBarracksListener(self)
    self.barracks_city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)
    GameUIBarracks.super.onExit(self)
end
function GameUIBarracks:OnBeginRecruit(barracks, event)
    self.tips:setVisible(false)
    self.timer:setVisible(true)
    self:OnRecruiting(barracks, event, app.timer:GetServerTime())
end
function GameUIBarracks:OnRecruiting(barracks, event, current_time)
    if self.timerAndTips:isVisible() then
        if not self.timer:isVisible() then
            self.timer:setVisible(true)
        end
        if self.tips:isVisible() then
            self.tips:setVisible(false)
        end
        local soldier_type, count = event:GetRecruitInfo()
        local soldier_name = Localize.soldier_name[soldier_type]
        self.timer:SetDescribe(string.format("%s%s x%d", _("招募"), soldier_name, count))
        self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)), event:Percent(current_time))
    end
end
function GameUIBarracks:OnEndRecruit(barracks, event, current_time)
    self.tips:setVisible(true)
    self.timer:setVisible(false)
end
function GameUIBarracks:CreateTimerAndTips()
    local timerAndTips = display.newNode():addTo(self)
    self.tips = WidgetTips.new(_("招募队列空闲"), _("请选择一个兵种进行招募")):addTo(timerAndTips)
        :align(display.CENTER, window.cx, window.top - 160)
        :show()

    self.timer = WidgetTimerProgress.new(549, 108):addTo(timerAndTips)
        :align(display.CENTER, window.cx, window.top - 160)
        :hide()
        :OnButtonClicked(function(event)
            print("hello")
        end)
    self.timer:GetSpeedUpButton():setButtonEnabled(false)
    return timerAndTips
end

function GameUIBarracks:CreateSoldierUI()
    local recruit = display.newNode():addTo(self)
    -- self.tips = WidgetTips.new(_("招募队列空闲"), _("请选择一个兵种进行招募")):addTo(recruit)
    --     :align(display.CENTER, window.cx, window.top - 160)
    --     :show()

    -- self.timer = WidgetTimerProgress.new(549, 108):addTo(recruit)
    --     :align(display.CENTER, window.cx, window.top - 160)
    --     :hide()
    --     :OnButtonClicked(function(event)
    --         print("hello")
    --     end)
    -- self.timer:GetSpeedUpButton():setButtonEnabled(false)

    local rect = self.timer:getCascadeBoundingBox()
    self.list_view = self:CreateVerticalListViewDetached(rect.x, window.bottom + 70, rect.x + rect.width, rect.y - 20):addTo(recruit)

    for i, v in ipairs({
        {"swordsman", "ranger", "lancer", "catapult"},
        {"sentinel", "crossbowman", "horseArcher", "ballista"}
    }) do
        self.list_view:addItem(self:CreateItemWithListView(self.list_view, v))
    end

    local soldier_map = self.barracks_city:GetSoldierManager():GetSoldierMap()
    for k, v in pairs(self.soldier_map) do
        v:SetNumber(soldier_map[k])
    end

    self.list_view:reload():resetPosition()
    return recruit
end
function GameUIBarracks:CreateSpecialSoldierUI()
    local special = display.newNode():addTo(self)


    local rect = self.timer:getCascadeBoundingBox()
    local list_view ,listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0,0, rect.width, rect.y - 10 - window.bottom - 110),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:align(display.BOTTOM_CENTER, window.cx, window.bottom_top+20):addTo(special)
    self.special_list_view = list_view

    local titles ={
        {
            title = _("亡灵部队"),
            title_img = "title_red_554x34.png",
        },
        {
            title = _("精灵部队"),
            title_img = "title_green_554x34.png",
        },
    }

    for i, v in ipairs({
        {"skeletonWarrior", "skeletonArcher", "deathKnight", "meatWagon"},
        {"priest", "demonHunter", "paladin", "steamTank"}
    }) do
        self.special_list_view:addItem(self:CreateSpecialItemWithListView(self.special_list_view, v,titles[i].title, titles[i].title_img))
    end

    local soldier_map = self.barracks_city:GetSoldierManager():GetSoldierMap()
    for k, v in pairs(self.soldier_map) do
        v:SetNumber(soldier_map[k])
    end

    self.special_list_view:reload():resetPosition()
    return special
end
function GameUIBarracks:TabButtons()
    self.tab_buttons = self:CreateTabButtons({
        {
            label = _("招募"),
            tag = "recruit",
        },
        {
            label = _("召唤"),
            tag = "specialRecruit",
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.recruit:setVisible(false)
            self.specialRecruit:setVisible(false)
            self.timerAndTips:setVisible(false)
        elseif tag == "recruit" then
            local event = self.barracks:GetRecruitEvent()
            self.timer:setVisible(event:IsRecruting() )
            self.tips:setVisible(event:IsEmpty())
            if event:IsRecruting() then
                local soldier_type, count = event:GetRecruitInfo()
                local soldier_name = Localize.soldier_name[soldier_type]
                self.timer:SetDescribe(string.format("%s%s x%d", _("招募"), soldier_name, count))
                local current_time = app.timer:GetServerTime()
                self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)), event:Percent(current_time))
            end
            self.recruit:setVisible(true)
            self.timerAndTips:setVisible(true)
            self.specialRecruit:setVisible(false)
        elseif tag == "specialRecruit" then
            self.recruit:setVisible(false)
            self.timerAndTips:setVisible(true)
            self.specialRecruit:setVisible(true)
            -- NetManager:getRecruitSpecialSoldierPromise("skeletonWarrior", 1, NOT_HANDLE)
        end
    end):pos(window.cx, window.bottom + 34)
end
function GameUIBarracks:CreateItemWithListView(list_view, soldiers)
    local rect = list_view:getViewRect()
    local origin_x = - rect.width / 2
    local widget_rect = self.timer:getCascadeBoundingBox()
    local unit_width = 130
    local gap_x = (widget_rect.width - unit_width * 4) / 3
    local row_item = display.newNode()
    for i, soldier_name in pairs(soldiers) do
        self.soldier_map[soldier_name] =
            WidgetSoldierBox.new(nil, function(event)
                WidgetRecruitSoldier.new(self.barracks, self.barracks_city, soldier_name)
                    :addTo(self)
                    :align(display.CENTER, window.cx, 500 / 2)
            end):addTo(row_item)
                :alignByPoint(cc.p(0.5, 0.4), origin_x + (unit_width + gap_x) * (i - 1) + unit_width / 2, 0)
                :SetSoldier(soldier_name, self.barracks.soldier_star)
    end

    local item = list_view:newItem()
    item:addContent(row_item)
    item:setItemSize(widget_rect.width, 170)
    return item
end
function GameUIBarracks:CreateSpecialItemWithListView( list_view, soldiers ,title,title_img)
    local rect = list_view:getViewRect()
    local origin_x = 10
    local widget_width = 568
    local unit_width = 130
    local gap_x = (widget_width - unit_width * 4-origin_x*2) / 3
    local row_item = WidgetUIBackGround.new({height=274,width=widget_width},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    for i, soldier_name in pairs(soldiers) do
        self.soldier_map[soldier_name] =
            WidgetSoldierBox.new(nil, function(event)
                WidgetRecruitSoldier.new(self.barracks, self.barracks_city, soldier_name,self.barracks_city:GetSoldierManager():GetStarBySoldierType(soldier_name))
                    :addTo(self)
                    :align(display.CENTER, window.cx, 500 / 2)
            end):addTo(row_item)
                :alignByPoint(cc.p(0.5, 0.4), origin_x + (unit_width + gap_x) * (i - 1) + unit_width / 2, 140)
                :SetSoldier(soldier_name, self.barracks_city:GetSoldierManager():GetStarBySoldierType(soldier_name))
    end

    -- title
    local title_bg = display.newSprite(title_img)
        :align(display.TOP_CENTER, row_item:getContentSize().width/2, row_item:getContentSize().height-8)
        :addTo(row_item)

    UIKit:ttfLabel({
        text = title,
        size = 22,
        color = 0xffedae
    }):addTo(title_bg)
        :align(display.CENTER, title_bg:getContentSize().width/2,title_bg:getContentSize().height/2)

    -- 招募时间限制

    local time_bg = display.newSprite("back_ground_548X34.png")
        :align(display.BOTTOM_CENTER, row_item:getContentSize().width/2, 10)
        :addTo(row_item)
    UIKit:ttfLabel({
        text = "下一次开启招募：01:52:34",
        size = 20,
        color = 0x514d3e
    }):addTo(time_bg)
        :align(display.CENTER, time_bg:getContentSize().width/2,time_bg:getContentSize().height/2)

    local item = list_view:newItem()
    item:addContent(row_item)
    item:setItemSize(widget_width, 284)
    return item
end
function GameUIBarracks:OnSoliderCountChanged(...)
    local soldier_map = self.barracks_city:GetSoldierManager():GetSoldierMap()
    for k, v in pairs(self.soldier_map) do
        v:SetNumber(soldier_map[k])
    end
end

--fte
function GameUIBarracks:Lock()
    self.list_view:getScrollNode():setTouchEnabled(false)
    return cocos_promise.deffer(function() return self end)
end
function GameUIBarracks:Find(control_type)
    if control_type == "recruit" then
        return cocos_promise.deffer(function()
            return self.tab_buttons:GetTabByTag("recruit")
        end)
    elseif control_type == "swordsman" then
        return cocos_promise.deffer(function()
            return self.soldier_map["swordsman"]
        end)
    end
end
function GameUIBarracks:WaitTag()
    return self.tab_buttons:PromiseOfTag("recruit"):next(function()
        return self
    end)
end


return GameUIBarracks





