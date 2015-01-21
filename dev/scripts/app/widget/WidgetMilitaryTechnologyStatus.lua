--
-- Author: Kenny Dai
-- Date: 2015-01-19 08:58:38
--

local WidgetProgress = import(".WidgetProgress")
local WidgetPushButton = import(".WidgetPushButton")
local WidgetSpeedUp = import(".WidgetSpeedUp")
local WidgetAccelerateGroup = import(".WidgetAccelerateGroup")
local Localize = import("..utils.Localize")
local SoldierManager = import("..entity.SoldierManager")


local WidgetMilitaryTechnologyStatus = class("WidgetMilitaryTechnologyStatus", function ()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    node:align(display.CENTER_LEFT)
    node:setContentSize(cc.size(556,106))
    return node
end)

function WidgetMilitaryTechnologyStatus:ctor()
    local width , height = 556,106
    -- 描述
    self.top_bg = display.newScale9Sprite("back_ground_398x97.png", 0, 0,cc.size(556,106),cc.rect(15,10,368,77))
        :addTo(self)
    local top_bg = self.top_bg

    self.normal_node = self:CreateNormalStatus()
    self.upgrading_node = self:CreateUpgradingStatus()
    self:RefreshTop()
end
function WidgetMilitaryTechnologyStatus:CreateNormalStatus()
    local normal_node = display.newNode()
    normal_node:setContentSize(cc.size(556,106))
    normal_node:addTo(self):align(display.CENTER)
    UIKit:ttfLabel({
        text = _("研发队列空闲"),
        size = 22,
        color = 0x403c2f
    }):align(display.CENTER, normal_node:getContentSize().width/2,normal_node:getContentSize().height/2+20)
        :addTo(normal_node)
    UIKit:ttfLabel({
        text = _("请选择一个科技进行研发"),
        size = 20,
        color = 0x797154
    }):align(display.CENTER, normal_node:getContentSize().width/2,normal_node:getContentSize().height/2-20)
        :addTo(normal_node)
    normal_node:setVisible(false)
    return normal_node
end
function WidgetMilitaryTechnologyStatus:CreateUpgradingStatus()
    local upgrading_node = display.newNode()
    upgrading_node:setContentSize(cc.size(556,106))
    upgrading_node:addTo(self):align(display.CENTER)
    --进度条
    local progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), nil, nil, {
        icon_bg = "progress_bg_head_43x43.png",
        icon = "hourglass_39x46.png",
        bar_pos = {x = 0,y = 0}
    }):addTo(upgrading_node)
        :align(display.LEFT_CENTER, 34, 36)

    local upgrading_tip = UIKit:ttfLabel({
        size = 22,
        color = 0x403c2f
    }):align(display.LEFT_CENTER, 30,80)
        :addTo(upgrading_node)

    local speed_up_btn = WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("加速"),
            size = 22,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function (event)
            self.speedUp = WidgetSpeedUp.new():addToCurrentScene()
                :SetAccBtnsGroup(WidgetAccelerateGroup.SPEEDUP_TYPE.TECHNOLOGY,function ()
                    print("加速")
                end)
                :SetAccTips(_("小于5分钟时，可使用免费加速.激活VIP X后，小于5分钟时可使用免费加速"))
                :SetUpgradeTip(self.upgrading_node:GetUpgradeTip())
        end)
        :align(display.CENTER, 474, 44):addTo(upgrading_node)

    function upgrading_node:SetProgressInfo(time_label, percent)
        progress:SetProgressInfo(time_label, percent)
    end
    function upgrading_node:SetUpgradeTip(tip)
        upgrading_tip:setString(tip)
    end
    function upgrading_node:GetUpgradeTip()
        return upgrading_tip:getString()
    end
    function upgrading_node:OnSpeedUpClicked(func)
        speed_up_btn:onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                func()
            end
        end)
    end
    upgrading_node:setVisible(false)
    return upgrading_node
end
function WidgetMilitaryTechnologyStatus:RefreshTop()
    local military_tech_event = City:GetSoldierManager():GetLatestMilitaryTechEvents()
    local soldier_star_event = City:GetSoldierManager():GetLatestSoldierStarEvents()
    if City:GetSoldierManager():IsUpgradingMilitaryTech() then
        local upgrade_node = self.upgrading_node
        upgrade_node:setVisible(true)
        self.normal_node:setVisible(false)
        local tech_start_time = military_tech_event and military_tech_event.startTime or 0
        local soldier_star_start_time = soldier_star_event and soldier_star_event.startTime or 0
        local event = tech_start_time>soldier_star_start_time and military_tech_event or soldier_star_event
        if military_tech_event == event then
            local name = military_tech_event.name
            local level = City:GetSoldierManager():GetMilitaryTechsLevelByName(name)
            upgrade_node:SetUpgradeTip(string.format(_("研发对%s的攻击 Lv %d"),Localize.soldier_category[string.split(name, "_")[2]],level+1))
        end
        if soldier_star_event == event then
            local name = soldier_star_event.name
            local star = City:GetSoldierManager():GetStarBySoldierType(name)
            upgrade_node:SetUpgradeTip(string.format(_("晋升%s的星级 star %d"),Localize.soldier_name[name],star+1))
        end
    else
        self.normal_node:setVisible(true)
        self.upgrading_node:setVisible(false)
        self.upgrading_node:SetProgressInfo("",0)
    end
end
function WidgetMilitaryTechnologyStatus:onEnter()
    -- 添加到全局计时器中，以便显示各个阶段的时间
    app.timer:AddListener(self)
    City:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED)
    City:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED)
end
function WidgetMilitaryTechnologyStatus:onExit()
    app.timer:RemoveListener(self)
    City:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED)
    City:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED)
end
function WidgetMilitaryTechnologyStatus:OnTimer(current_time)
    local military_tech_event = City:GetSoldierManager():GetLatestMilitaryTechEvents()
    local soldier_star_event = City:GetSoldierManager():GetLatestSoldierStarEvents()
    local tech_start_time = military_tech_event and military_tech_event.startTime or 0
    local soldier_star_start_time = soldier_star_event and soldier_star_event.startTime or 0
    local event = tech_start_time>soldier_star_start_time and military_tech_event or soldier_star_event
    if event then
        self.upgrading_node:SetProgressInfo(GameUtils:formatTimeStyle1(event.finishTime/1000-current_time), (current_time*1000-event.startTime)/(event.finishTime-event.startTime)*100)
        if self.speedUp and self.speedUp.SetProgressInfo then
        	self.speedUp:SetProgressInfo(GameUtils:formatTimeStyle1(event.finishTime/1000-current_time), (current_time*1000-event.startTime)/(event.finishTime-event.startTime)*100)
        end
    end
end
function WidgetMilitaryTechnologyStatus:OnMilitaryTechEventsChanged(soldier_manager,changed_map)
    self:RefreshTop()
end
function WidgetMilitaryTechnologyStatus:OnSoldierStarEventsChanged( soldier_manager,changed_map )
    self:RefreshTop()
end
return WidgetMilitaryTechnologyStatus








