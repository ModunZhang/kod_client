local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2= import("..widget.WidgetUIBackGround2")
local WidgetBackGroudWhite = import("..widget.WidgetBackGroudWhite")
local Localize = import("..utils.Localize")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetBackGroundLucid = import("..widget.WidgetBackGroundLucid")
local HELP_EVENTS = "help_events"
local GameUIHelp = class("GameUIHelp", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function GameUIHelp:ctor()
    self:setNodeEventEnabled(true)
    self.alliance_manager = DataManager:GetManager("AllianceManager")
    self.alliance_manager:OnAllianceDataEvent(HELP_EVENTS,handler(self, self.OnAllianceDataEvent))
    self.help_events_items = {}
end

function GameUIHelp:onEnter()
    local body = WidgetUIBackGround.new({height=756}):addTo(self):align(display.TOP_CENTER,display.cx,display.top-100)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height)
        :addTo(body)
    local title_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("协助加速"),
            font = UIKit:getFontFilePath(),
            size = 22,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2)
        :addTo(title)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent()
        end):align(display.CENTER, title:getContentSize().width-10, title:getContentSize().height-10)
        :addTo(title):addChild(display.newSprite("X_3.png"))
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
    display.newSprite("loyalty.png",pro_head_bg:getContentSize().width/2,pro_head_bg:getContentSize().height/2):addTo(pro_head_bg)

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
                -- PushService:quitAlliance(NOT_HANDLE)
                if self:IsAbleToHelpAll() then
                    NetManager:helpAllAllianceMemberSpeedUp(NOT_HANDLE)
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
    self.loyalty_label:setString(_("每日获得最大忠诚度：")..DataManager:getUserData().basicInfo.loyalty.."/10000")
    self.ProgressTimer:setPercentage(math.floor(DataManager:getUserData().basicInfo.loyalty/10000*100))
end
function GameUIHelp:InitHelpEvents()
    local help_events = self.alliance_manager:GetMyAllianceData().helpEvents
    if help_events then
        for k,event in pairs(help_events) do
            if not self:IsHelpedByMe(event.helpedMembers) then
                self:InsertItemToList(event)
            end
        end
        self.help_listview:reload()
    end
end
function GameUIHelp:InsertItemToList(help_event)
    -- 当前玩家的求助事件需要置顶
    local item = self:CreateHelpItem(help_event)
    if DataManager:getUserData()._id == help_event.id then
        self.help_listview:addItem(item,1)
    else
        self.help_listview:addItem(item)
    end
end
function GameUIHelp:IsHelpedByMe(helpedMembers)
    local _id = DataManager:getUserData()._id
    for k,id in pairs(helpedMembers) do
        if id == _id then
            return true
        end
    end
end
function GameUIHelp:RefreshUI(help_events)
    for k,item in pairs(self.help_events_items) do
        -- 帮助事件已经结束，删除列表中对应的帮助项
        local flag = true
        local flag_1 = true

        for _,v in pairs(help_events) do
            if v.eventId==k then
                -- 帮助过的需要删除
                if not self:IsHelpedByMe(v.helpedMembers) then
                    flag = false
                end
            end
        end

        if flag then
            print("删除求助事件",k)
            self:DeleteHelpItem(k)
        end
    end
    for k,event in pairs(help_events) do
        if not self.help_events_items[event.eventId] then
            print("收到新的求助加速事件",event.eventId,event.buildingName,event.name)
            self:InsertItemToList(event)
            self.help_listview:reload()
        end
    end
end

function GameUIHelp:DeleteHelpItem(id)
    self.help_listview:removeItem(self.help_events_items[id])
    self.help_events_items[id] = nil
end

function GameUIHelp:CreateHelpItem(event)
    local item = self.help_listview:newItem()
    item.eventId = event.eventId
    local item_width, item_height = 568,130
    item:setItemSize(item_width, item_height)
    local bg = display.newSprite("back_ground_568X126.png")
    local bg_size = bg:getContentSize()
    display.newSprite("people.png"):addTo(bg):pos(20, bg_size.height-24)
    -- 玩家名字
    local name_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        text = event.name,
        size = 24,
        color = UIKit:hex2c3b(0x514d3e),
        dimensions = cc.size(0,26),
    }):addTo(bg):align(display.LEFT_CENTER, 50, bg_size.height-24)
    -- 请求帮助事件
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        text = _("正在升级")..Localize.building_name[event.buildingName].._("Lv")..event.buildingLevel,
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
    pro:setPercentage(math.floor(#event.helpedMembers/event.maxHelpCount*100))
    local help_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        text = _("帮助")..#event.helpedMembers.."/"..event.maxHelpCount,
        size = 18,
        align = ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xfff3c7),
    }):addTo(bar):align(display.LEFT_CENTER, 30, bar:getContentSize().height/2)
    -- 帮助按钮
    if DataManager:getUserData()._id ~= event.id then
        local help_button = WidgetPushButton.new(
            {normal = "yellow_button_146x42.png", pressed = "yellow_button_highlight_146x42.png"}
        ):setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("帮助"), size = 18, color = UIKit:hex2c3b(0xfff3c7)}))
            :onButtonClicked(function(e)
                if e.name == "CLICKED_EVENT" then
                    print("===event.eventId",event.eventId,event.buildingName,event.name)
                    NetManager:helpAllianceMemberSpeedUp(event.eventId,function ( flag )
                        -- 帮助成功，从待帮助列表中移除
                        if flag then
                            self:DeleteHelpItem(event.eventId)
                            self:SetLoyalty()
                        end
                    end)
                end
            end):addTo(bg):pos(480, 30)
    end
    item:addContent(bg)

    print("帮助事件ID=",event.eventId)
    self.help_events_items[event.eventId] = item

    function item:SetHelp(event)
        help_label:setString(_("帮助")..#event.helpedMembers.."/"..event.maxHelpCount)
        ProgressTimer:setPercentage(math.floor(#event.helpedMembers/event.maxHelpCount*100))
        return item
    end

    function item:IsAbleToHelp()
        return DataManager:getUserData()._id ~= event.id
    end

    return item
end
function GameUIHelp:OnAllianceDataEvent(event)
    print("GameUIHelp:OnAllianceDataEvent----->",event.eventName)
    dump(event.data)
    if event.eventName == "onAllianceDataChanged" then
        self:RefreshUI(event.data.helpEvents)
    elseif event.eventName == "onAllianceHelpEventChanged" then
        local help_event = event.data.event
        LuaUtils:outputTable("onAllianceHelpEventChanged-->>help_events", help_event)
        local item = self.help_events_items[help_event.eventId]
        if item then
            item:SetHelp(help_event)
        end
    end
end
function GameUIHelp:AddToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end

function GameUIHelp:onExit()
    self.alliance_manager:RemoveEventByTag(HELP_EVENTS)
end

return GameUIHelp











