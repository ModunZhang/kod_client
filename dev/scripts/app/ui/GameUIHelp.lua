local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2= import("..widget.WidgetUIBackGround2")
local WidgetBackGroudWhite = import("..widget.WidgetBackGroudWhite")
local Alliance = import("..entity.Alliance")
local Localize = import("..utils.Localize")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetBackGroundLucid = import("..widget.WidgetBackGroundLucid")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local HELP_EVENTS = "help_events"
local GameUIHelp = class("GameUIHelp", WidgetPopDialog)

function GameUIHelp:ctor()
    GameUIHelp.super.ctor(self,756,_("协助加速"),display.top-100)
    self.alliance = Alliance_Manager:GetMyAlliance()
    self.help_events_items = {}
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.HELP_EVENTS)
end

function GameUIHelp:onEnter()
    local body = self.body
    local rb_size = body:getContentSize()

    -- 协助加速介绍
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("帮助联盟成员加速并获得联盟忠诚值，激活VIP后能够提升为盟友加速效果"),
            font = UIKit:getFontFilePath(),
            size = 18,
            align = cc.ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(360,0),
            color = UIKit:hex2c3b(0x514d3e)
        }):align(display.TOP_CENTER, rb_size.width/2, rb_size.height-40)
        :addTo(body)

    -- 当天帮助加速获得的忠诚度进度条
    local bar = display.newSprite("progress_bg_560x36.png"):addTo(body):pos(rb_size.width/2+10, rb_size.height-110)
    local progressFill = display.newSprite("progress_bar_558x32.png")
    self.ProgressTimer = cc.ProgressTimer:create(progressFill)
    local pro = self.ProgressTimer
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    pro:setMidpoint(cc.p(0,0))
    pro:align(display.LEFT_BOTTOM, 0, 2):addTo(bar)
    self.loyalty_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        align = ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xfff3c7),
    }):addTo(bar):align(display.LEFT_CENTER, 30, bar:getContentSize().height/2)
    self:SetLoyalty()
    local pro_head_bg = display.newSprite("back_ground_43x43.png", 0, bar:getContentSize().height/2):addTo(bar)
    display.newSprite("loyalty_128x128.png",pro_head_bg:getContentSize().width/2,pro_head_bg:getContentSize().height/2):addTo(pro_head_bg):scale(42/128)

    -- 帮助列表
    local help_list_bg = WidgetUIBackGround2.new(522):addTo(body):pos((rb_size.width-572)/2, 90)
    self.help_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(0,7, 572, 508),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(help_list_bg)

    -- 全部帮助按钮
    local help_all_button = WidgetPushButton.new(
        {normal = "yellow_button_146x42.png", pressed = "yellow_button_highlight_146x42.png"}
    ):setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("全部帮助"), size = 18, color = UIKit:hex2c3b(0xfff3c7)}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if self:IsAbleToHelpAll() then
                    NetManager:getHelpAllAllianceMemberSpeedUpPromise()
                else
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("没有联盟成员需要协助加速"))
                        :AddToCurrentScene()
                end
            end
        end):addTo(body):pos(rb_size.width/2, 50)
    self:InitHelpEvents()
end
function GameUIHelp:IsAbleToHelpAll()
    for k,item in pairs(self.help_events_items) do
        if item:IsAbleToHelp() then
            return true
        end
    end
end
function GameUIHelp:SetLoyalty()
    self.loyalty_label:setString(_("每日获得最大忠诚度：")..DataManager:getUserData().allianceInfo.loyalty.."/10000")
    self.ProgressTimer:setPercentage(math.floor(DataManager:getUserData().allianceInfo.loyalty/10000*100))
end
function GameUIHelp:InitHelpEvents()
    local help_events = self.alliance:GetAllHelpEvents()
    if help_events then
        for k,event in pairs(help_events) do
            if not self:IsHelpedByMe(event:GetEventData():HelpedMembers()) and not self:IsHelpedToMaxNum(event) then
                self:InsertItemToList(event)
            end
        end
        self.help_listview:reload()
    end
end
function GameUIHelp:InsertItemToList(help_event)
    -- 当前玩家的求助事件需要置顶
    local item = self:CreateHelpItem(help_event)
    if User:Id() == help_event:GetPlayerData():Id() then
        -- 检查自己请求帮助的事件是否已经结束了
        if not self:CheckEventFinished(help_event) then
            self.help_listview:addItem(item,1)
        end
    else
        self.help_listview:addItem(item)
    end
end
function GameUIHelp:CheckEventFinished(help_event)
    local city = City
    local eventData = help_event:GetEventData()
    local type = eventData:Type()
    local event_id = eventData:Id()
    local isFinished = true
    if type == "buildingEvents" then
        city:IteratorFunctionBuildingsByFunc(function(key, building)
            if building:UniqueUpgradingKey() == event_id then
                isFinished = false
            end
        end)
        -- 城墙，箭塔
        if city:GetGate():UniqueUpgradingKey() == event_id then
            isFinished = false
        end
        if city:GetTower():UniqueUpgradingKey() == event_id then
            isFinished = false
        end
    elseif type == "houseEvents" then
        city:IteratorDecoratorBuildingsByFunc(function(key, building)
            if building:UniqueUpgradingKey() == event_id then
                isFinished = false
            end
        end)
    elseif type == "productionTechEvents" then
        city:IteratorProductionTechEvents(function(productionTechnologyEvent)
            if productionTechnologyEvent:Id() == event_id then
                isFinished = false
            end
        end)
    elseif type == "militaryTechEvents" then
        city:GetSoldierManager():IteratorMilitaryTechEvents(function(militaryTechEvent)
            if militaryTechEvent:Id() == event_id then
                isFinished = false
            end
        end)
    elseif type == "soldierStarEvents" then
        city:GetSoldierManager():IteratorSoldierStarEvents(function(soldierStarEvent)
            if soldierStarEvent:Id() == event_id then
                isFinished = false
            end
        end)
    end

    return isFinished
end
function GameUIHelp:IsHelpedByMe(helpedMembers)
    local _id = User:Id()
    for k,id in pairs(helpedMembers) do
        if id == _id then
            return true
        end
    end
end
function GameUIHelp:IsHelpedToMaxNum(event)
    return #event:GetEventData():HelpedMembers() == event:GetEventData():MaxHelpCount()
end
function GameUIHelp:RefreshUI(help_events)
    for k,item in pairs(self.help_events_items) do
        -- 帮助事件已经结束，删除列表中对应的帮助项
        local flag = true
        local flag_1 = true

        for _,v in pairs(help_events) do
            if v:Id()==k then
                -- 帮助过的需要删除
                if not self:IsHelpedByMe(v:GetEventData():HelpedMembers()) or not self:IsHelpedToMaxNum(v) then
                    flag = false
                end
            end
        end

        if flag then
            self:DeleteHelpItem(k)
        end
    end
    for k,event in pairs(help_events) do
        if not self.help_events_items[event:Id()] then
            self:InsertItemToList(event)
            self.help_listview:reload()
        end
    end
end

function GameUIHelp:DeleteHelpItem(id)
    if self.help_events_items[id] then
        self.help_listview:removeItem(self.help_events_items[id])
        self.help_events_items[id] = nil
    end
end
function GameUIHelp:GetHelpEventDesc( eventData )
    local type = eventData:Type()
    local name = eventData:Name()
    if type == "buildingEvents"
        or type == "houseEvents"
    then
        return _("正在升级")..Localize.building_name[name].._("Lv")..eventData:Level()
    elseif type == "militaryTechEvents" then
        return string.format(_("研发%s对%s的攻击到 Lv %d"),Localize.soldier_category[string.split(name, "_")[1]],Localize.soldier_category[string.split(name, "_")[2]],eventData:Level()+1)
    elseif type == "soldierStarEvents" then
        return string.format(_("晋升%s的星级 star %d"),Localize.soldier_name[name],eventData:Level()+1)
    elseif type == "materialEvents" then
        return _("未处理")
    elseif type == "soldierEvents" then
        return _("未处理")
    elseif type == "treatSoldierEvents" then
        return _("未处理")
    elseif type == "dragonEquipmentEvents" then
        return _("未处理")
    elseif type == "dragonHatchEvents" then
        return _("未处理")
    elseif type == "dragonDeathEvents" then
        return _("未处理")
    elseif type == "productionTechEvents" then
        return _("未处理")
    end
end
function GameUIHelp:CreateHelpItem(event)
    local playerData = event:GetPlayerData()
    local eventData = event:GetEventData()

    local item = self.help_listview:newItem()
    item.eventId = event:Id()
    local item_width, item_height = 568,130
    item:setItemSize(item_width, item_height)
    local bg = display.newSprite("back_ground_568X126.png")
    local bg_size = bg:getContentSize()
    display.newSprite("people.png"):addTo(bg):pos(20, bg_size.height-24)
    -- 玩家名字
    local name_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        text = playerData:Name(),
        size = 24,
        color = UIKit:hex2c3b(0x514d3e),
        dimensions = cc.size(0,26),
    }):addTo(bg):align(display.LEFT_CENTER, 50, bg_size.height-24)
    -- 请求帮助事件
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        text = self:GetHelpEventDesc(eventData),
        size = 20,
        color = UIKit:hex2c3b(0x797154),
        dimensions = cc.size(0,0),
    }):addTo(bg):align(display.LEFT_TOP, 20, bg_size.height-50)
    -- 此条事件被帮助次数进度条
    local bar = display.newSprite("progress_bg_366x34.png"):addTo(bg):pos(200,30)
    local progressFill = display.newSprite("progress_bar_366x34.png")
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    local pro = ProgressTimer
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    pro:setMidpoint(cc.p(0,0))
    pro:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)


    local helpedMembers = eventData:HelpedMembers()
    local maxHelpCount = eventData:MaxHelpCount()
    pro:setPercentage(math.floor(#helpedMembers/maxHelpCount*100))
    local help_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        text = _("帮助")..#helpedMembers.."/"..maxHelpCount,
        size = 18,
        align = ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xfff3c7),
    }):addTo(bar):align(display.LEFT_CENTER, 30, bar:getContentSize().height/2)
    -- 帮助按钮
    if User:Id() ~= playerData:Id() then
        local help_button = WidgetPushButton.new(
            {normal = "yellow_button_146x42.png", pressed = "yellow_button_highlight_146x42.png"}
        ):setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("帮助"), size = 18, color = UIKit:hex2c3b(0xfff3c7)}))
            :onButtonClicked(function(e)
                if e.name == "CLICKED_EVENT" then
                    NetManager:getHelpAllianceMemberSpeedUpPromise(event:Id()):catch(function(err)
                        dump(err:reason())
                    end)
                end
            end):addTo(bg):pos(480, 30)
    end
    item:addContent(bg)

    self.help_events_items[event:Id()] = item

    function item:SetHelp(event)
        help_label:setString(_("帮助")..#event:GetEventData():HelpedMembers().."/"..event:GetEventData():MaxHelpCount())
        ProgressTimer:setPercentage(math.floor(#event:GetEventData():HelpedMembers()/event:GetEventData():MaxHelpCount()*100))
        return item
    end

    function item:IsAbleToHelp()
        return User:Id() ~= event:GetPlayerData():Id()
    end

    return item
end
-- function GameUIHelp:OnAllHelpEventChanged(event)
--     self:RefreshUI(event)
-- end
function GameUIHelp:OnHelpEventChanged(changed_help_event)
    if changed_help_event.added then
        local added = changed_help_event.added
        for _,event in pairs(added) do
            if not self:IsHelpedByMe(event:GetEventData():HelpedMembers()) or not self:IsHelpedToMaxNum(event) then
                self:InsertItemToList(event)
            end
        end
        self.help_listview:reload()
    end
    if changed_help_event.removed then
        local removed = changed_help_event.removed
        for _,event in pairs(removed) do
            self:DeleteHelpItem(event:Id())
        end
    end
    if changed_help_event.edit then
        local edit = changed_help_event.edit
        for _,event in pairs(edit) do
            local item = self.help_events_items[event:Id()]
            if item then
                if self:IsHelpedByMe(event:GetEventData():HelpedMembers()) or self:IsHelpedToMaxNum(event) then
                    self:DeleteHelpItem(event:Id())
                else
                    item:SetHelp(event)
                end
            end
        end
    end
end
function GameUIHelp:AddToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end

function GameUIHelp:onExit()
    self.alliance:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.HELP_EVENTS)
end

return GameUIHelp









