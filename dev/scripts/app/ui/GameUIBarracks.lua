--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
local WidgetTips = import("..widget.WidgetTips")
local WidgetSoldierBox = import("..widget.WidgetSoldierBox")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local WidgetRecruitSoldier = import("..widget.WidgetRecruitSoldier")
local GameUIBarracks = UIKit:createUIClass("GameUIBarracks", "GameUIUpgradeBuilding")
function GameUIBarracks:ctor(city, barracks)
    GameUIBarracks.super.ctor(self, city, _("兵营"),barracks)
    self.barracks_city = city
    self.barracks = barracks
end
function GameUIBarracks:onEnter()
    GameUIBarracks.super.onEnter(self)
    self.recruit = self:CreateSoldierUI()
    self:TabButtons()
    self.barracks:AddBarracksListener(self)
    self.barracks_city:GetSoldierManager():AddObserver(self)
end
function GameUIBarracks:onExit()
    self.barracks:RemoveBarracksListener(self)
    self.barracks_city:GetSoldierManager():RemoveObserver(self)
    GameUIBarracks.super.onExit(self)
end
function GameUIBarracks:OnBeginRecruit(barracks, event)
    self.tips:setVisible(false)
    self.timer:setVisible(true)
    self:OnRecruiting(barracks, event, app.timer:GetServerTime())
end
function GameUIBarracks:OnRecruiting(barracks, event, current_time)
    if self.recruit:isVisible() then
        if not self.timer:isVisible() then
            self.timer:setVisible(true)
        end
        if self.tips:isVisible() then
            self.tips:setVisible(false)
        end
        local soldier_type, count = event:GetRecruitInfo()
        local soldier_name = barracks:GetSoldierConfigByType(soldier_type).description
        self.timer:SetDescribe(string.format("%s%s x%d", _("招募"), _(soldier_name), count))
        self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)), event:Percent(current_time))
    end
end
function GameUIBarracks:OnEndRecruit(barracks, event, current_time)
    self.tips:setVisible(true)
    self.timer:setVisible(false)
end

function GameUIBarracks:CreateSoldierUI()
    local recruit = display.newNode():addTo(self)
    self.tips = WidgetTips.new(_("招募队列空闲"), _("请选择一个兵种进行招募")):addTo(recruit)
        :align(display.CENTER, window.cx, window.top - 160)
        :show()

    self.timer = WidgetTimerProgress.new(549, 108):addTo(recruit)
        :align(display.CENTER, window.cx, window.top - 160)
        :hide()
        :OnButtonClicked(function(event)
            print("hello")
        end)

    self.soldier_map = {}
    local rect = self.timer:getCascadeBoundingBox()
    self.list_view = self:CreateVerticalListViewDetached(rect.x, window.bottom + 70, rect.x + rect.width, rect.y - 20):addTo(recruit)

    for i, v in ipairs({
        {"swordsman", "sentinel", "archer", "crossbowman"},
        {"lancer", "horseArcher", "catapult", "ballista"}
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
function GameUIBarracks:TabButtons()
    self:CreateTabButtons({
        {
            label = _("招募"),
            tag = "recruit",
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.recruit:setVisible(false)
        elseif tag == "recruit" then
            local event = self.barracks:GetRecruitEvent()
            self.timer:setVisible(event:IsRecruting() )
            self.tips:setVisible(event:IsEmpty())
            if event:IsRecruting() then
                local soldier_type, count = event:GetRecruitInfo()
                local soldier_name = self.barracks:GetSoldierConfigByType(soldier_type).description
                self.timer:SetDescribe(string.format("%s%s x%d", _("招募"), _(soldier_name), count))
                local current_time = app.timer:GetServerTime()
                self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)), event:Percent(current_time))
            end
            self.recruit:setVisible(true)
        elseif tag == "specialRecruit" then
            self.recruit:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 40)
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
                local widget = WidgetRecruitSoldier.new(soldier_name,
                    self.barracks.soldier_star,
                    self.barracks:GetMaxRecruitSoldierCount())
                    :addTo(self)
                    :align(display.CENTER, window.cx, 500 / 2)
                    :OnBlankClicked(function(widget)
                        self.barracks_city:GetResourceManager():RemoveObserver(widget)
                        widget:removeFromParentAndCleanup(true)
                    end)
                    :OnNormalButtonClicked(function(widget)
                        self.barracks_city:GetResourceManager():RemoveObserver(widget)
                        widget:removeFromParentAndCleanup(true)
                    end)
                    :OnInstantButtonClicked(function(widget)
                        self.barracks_city:GetResourceManager():RemoveObserver(widget)
                        widget:removeFromParentAndCleanup(true)
                    end)
                self.barracks_city:GetResourceManager():AddObserver(widget)
                self.barracks_city:GetResourceManager():OnResourceChanged()
            end):addTo(row_item)
                :alignByPoint(cc.p(0.5, 0.4), origin_x + (unit_width + gap_x) * (i - 1) + unit_width / 2, 0)
                :SetSoldier(soldier_name, self.barracks.soldier_star)
    end

    local item = list_view:newItem()
    item:addContent(row_item)
    item:setItemSize(widget_rect.width, 170)
    return item
end
function GameUIBarracks:OnSoliderCountChanged(...)
    local soldier_map = self.barracks_city:GetSoldierManager():GetSoldierMap()
    for k, v in pairs(self.soldier_map) do
        v:SetNumber(soldier_map[k])
    end
end




return GameUIBarracks

















