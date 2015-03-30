local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local UIPageView = import("..ui.UIPageView")
local Flag = import("..entity.Flag")
local Alliance = import("..entity.Alliance")
local SoldierManager = import("..entity.SoldierManager")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local GameUIAllianceContribute = import(".GameUIAllianceContribute")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local GameUIHelp = import(".GameUIHelp")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local RichText = import("..widget.RichText")
local ChatManager = import("..entity.ChatManager")
local GameUIAllianceHome = UIKit:createUIClass('GameUIAllianceHome')
local cc = cc
function GameUIAllianceHome:ctor(alliance)
    GameUIAllianceHome.super.ctor(self)
    self.alliance = alliance
    self.chatManager = app:GetChatManager()
end

function GameUIAllianceHome:GetChatManager()
    return self.chatManager
end
function GameUIAllianceHome:DisplayOn()
    self.visible_count = self.visible_count + 1
    self:setVisible(self.visible_count > 0)
end
function GameUIAllianceHome:DisplayOff()
    self.visible_count = self.visible_count - 1
    self:setVisible(self.visible_count > 0)
end
function GameUIAllianceHome:onEnter()
    GameUIAllianceHome.super.onEnter(self)
    self.visible_count = 1
    self.bottom = self:CreateBottom()
    self.top = self:CreateTop()

    local rect1 = self.bottom:getCascadeBoundingBox()
    local rect2 = self.top_bg:getCascadeBoundingBox()
    self.screen_rect = cc.rect(0, rect1.height, display.width, rect2.y - rect1.height)
    self.arrow = display.newSprite("arrow_home.png")
        :addTo(self):align(display.TOP_CENTER):scale(0.3):hide()
    self.arrow:setTouchEnabled(true)
    self.arrow:setTouchSwallowEnabled(true)
    self.arrow:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self.arrow:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        local touch_type = event.name
        local pre_x, pre_y, x, y = event.prevX, event.prevY, event.x, event.y
        if touch_type == "began" then
        elseif touch_type == "moved" then
        elseif touch_type == "ended" then
            local scene = display.getRunningScene()
            local location = scene:GetAlliance():GetSelf().location
            scene:GotoLogicPosition(location.x, location.y, scene:GetAlliance():Id())
        end
        return true
    end)
    local size = self.arrow:getContentSize()
    self.arrow_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xf5e8c4)
    }):addTo(self.arrow):rotation(90)
        :align(display.LEFT_CENTER, size.width/2 + 10, size.height/2 + 10)

    if self.top then
        self.top:Refresh()
    end

    -- 中间按钮
    self:CreateOperationButton()
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.ALLIANCE_FIGHT)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.FIGHT_REQUESTS)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.HELP_EVENTS)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.ALL_HELP_EVENTS)
    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    local city = City
    city:AddListenOnType(self, city.LISTEN_TYPE.UPGRADE_BUILDING)
    city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED)
    city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED)
    city:AddListenOnType(self,city.LISTEN_TYPE.PRODUCTION_EVENT_CHANGED)
    -- 添加到全局计时器中，以便显示各个阶段的时间
    app.timer:AddListener(self)
end

function GameUIAllianceHome:CreateOperationButton()
    local first_row = 220
    local first_col = 177
    local label_padding = 100
    for i, v in ipairs({
        {"help_68x60.png", _("帮助")},
        {"war_54x55.png", _("战斗")},
    }) do
        local col = i - 1
        local y =  first_row + col*label_padding
        local button = WidgetPushButton.new({normal = v[1]})
            :onButtonClicked(handler(self, self.OnMidButtonClicked))
            :setButtonLabel("normal",cc.ui.UILabel.new({text = v[2],
                size = 16,
                font = UIKit:getFontFilePath(),
                color = UIKit:hex2c3b(0xf5e8c4)}
            )
            )
            :setButtonLabelOffset(0, -40)
            :addTo(self):pos(display.right-50, y)
        button:setTag(i)
        button:setTouchSwallowEnabled(true)
        if i == 1 then
            self:RefreshHelpButtonVisible()
            local alliance = self.alliance
            -- 请求帮助的其他联盟成员请求帮助事件数量
            local request_help_num_bg = display.newSprite("mail_unread_bg_36x23.png"):addTo(button):pos(20,-20)
            local request_num = alliance:GetOtherRequestEventsNum()
            self.request_help_num = UIKit:ttfLabel(
                {
                    text = GameUtils:formatNumber(request_num),
                    size = 16,
                    color = 0xf5f2b3
                }):align(display.CENTER,request_help_num_bg:getContentSize().width/2,request_help_num_bg:getContentSize().height/2+4)
                :addTo(request_help_num_bg)
            self.request_help_num_bg = request_help_num_bg
            self:VisibleRequestHelpNum()
        end
    end
end
function GameUIAllianceHome:VisibleRequestHelpNum()
    local alliance = self.alliance
    local request_num = alliance:GetOtherRequestEventsNum()
    self.request_help_num_bg:setVisible(request_num>0)
    self.request_help_num:setString(GameUtils:formatNumber(request_num))
end
function GameUIAllianceHome:RefreshHelpButtonVisible()
    local help_button = self:getChildByTag(1)
    if help_button then
        local alliance = Alliance_Manager:GetMyAlliance()
        help_button:setVisible(not alliance:IsDefault() and #alliance:GetCouldShowHelpEvents()>0)
    end
end
function GameUIAllianceHome:OnUpgradingBegin()
end
function GameUIAllianceHome:OnUpgrading()
end
function GameUIAllianceHome:OnUpgradingFinished()
    self:RefreshHelpButtonVisible()
end
function GameUIAllianceHome:OnMilitaryTechEventsChanged()
    self:RefreshHelpButtonVisible()
end
function GameUIAllianceHome:OnSoldierStarEventsChanged()
    self:RefreshHelpButtonVisible()
end
function GameUIAllianceHome:OnProductionTechnologyEventDataChanged()
    self:RefreshHelpButtonVisible()
end
function GameUIAllianceHome:OnHelpEventChanged()
    self:RefreshHelpButtonVisible()
    self:VisibleRequestHelpNum()
end
function GameUIAllianceHome:OnAllHelpEventChanged()
    self:RefreshHelpButtonVisible()
    self:VisibleRequestHelpNum()
end
function GameUIAllianceHome:onExit()
    app.timer:RemoveListener(self)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.ALLIANCE_FIGHT)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.FIGHT_REQUESTS)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.HELP_EVENTS)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.ALL_HELP_EVENTS)
    MailManager:RemoveListenerOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)

    local city = City
    city:RemoveListenerOnType(self, city.LISTEN_TYPE.UPGRADE_BUILDING)
    city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_EVENTS_CHANGED)
    city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_STAR_EVENTS_CHANGED)
    city:RemoveListenerOnType(self,city.LISTEN_TYPE.PRODUCTION_EVENT_CHANGED)
    GameUIAllianceHome.super.onExit(self)
end

function GameUIAllianceHome:TO_TOP()
    self:RefreshChatMessage()
end

function GameUIAllianceHome:TO_REFRESH()
    self:RefreshChatMessage()
end

function GameUIAllianceHome:RefreshChatMessage()
    if not self.chat_labels then return end
    local last_chat_messages = self:GetChatManager():FetchLastChannelMessage()
    for i,v in ipairs(self.chat_labels) do
        local rich_text = self.chat_labels[i]
        rich_text:Text(last_chat_messages[i],1)
        rich_text:align(display.LEFT_CENTER, 0, 10)
    end
end

function GameUIAllianceHome:TopBg()
    local top_bg = display.newSprite("alliance_home_top_bg_768x116.png")
        :align(display.TOP_CENTER, window.cx, window.top)
        :addTo(self)
    if display.width >640 then
        top_bg:scale(display.width/768)
    end
    top_bg:setTouchEnabled(true)
    self.top_bg = top_bg

    top_bg:setTouchSwallowEnabled(true)
    local t_size = top_bg:getContentSize()

    -- 顶部背景,为按钮
    local top_self_bg = WidgetPushButton.new({normal = "button_blue_normal_314X88.png",
        pressed = "button_blue_pressed_314X88.png"})
        :onButtonClicked(handler(self, self.OnTopButtonClicked))
        :align(display.TOP_CENTER, t_size.width/2-160, t_size.height-4)
        :addTo(top_bg)
    local top_enemy_bg = WidgetPushButton.new({normal = "button_red_normal_314X88.png",
        pressed = "button_red_pressed_314X88.png"})
        :onButtonClicked(handler(self, self.OnTopButtonClicked))
        :align(display.TOP_CENTER, t_size.width/2+160, t_size.height-4)
        :addTo(top_bg)

    return top_self_bg,top_enemy_bg
end

function GameUIAllianceHome:TopTabButtons()
    -- 荣誉,忠诚,坐标按钮背景框
    local btn_bg = display.newSprite("back_ground_676x100.png")
        :align(display.TOP_CENTER,self.top_bg:getContentSize().width/2,46)
        :addTo(self.top_bg)
    btn_bg:setTouchEnabled(true)
    -- 荣耀按钮
    local honour_btn = WidgetPushButton.new({normal = "btn_196x44.png",
        pressed = "btn_196x44_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                GameUIAllianceContribute.new():AddToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 145, btn_bg:getContentSize().height/2-1)
        :addTo(btn_bg)
    -- 荣耀值
    display.newSprite("honour_128x128.png")
        :align(display.CENTER, 120,btn_bg:getContentSize().height/2-3)
        :addTo(btn_bg)
        :scale(42/128)
    UIKit:ttfLabel(
        {
            text = _("荣耀值"),
            size = 14,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 145, btn_bg:getContentSize().height/2+8)
        :addTo(btn_bg)
    self.honour_label = UIKit:ttfLabel(
        {
            text = GameUtils:formatNumber(self.alliance:Honour()),
            size = 18,
            color = 0xf5e8c4
        }):align(display.LEFT_CENTER, 145, btn_bg:getContentSize().height/2-8)
        :addTo(btn_bg)
    honour_btn:setRotationSkewY(180)

    -- 忠诚按钮
    local loyalty_btn = WidgetPushButton.new({normal = "btn_196x44.png",
        pressed = "btn_196x44_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceLoyalty'):AddToCurrentScene(true)
            end
        end)
        :align(display.CENTER, btn_bg:getContentSize().width-144, btn_bg:getContentSize().height/2-1)
        :addTo(btn_bg)
    -- 忠诚值
    display.newSprite("loyalty_128x128.png")
        :align(display.CENTER, -40,loyalty_btn:getContentSize().height/2-4)
        :addTo(loyalty_btn)
        :scale(42/128)
    UIKit:ttfLabel(
        {
            text = _("忠诚值"),
            size = 14,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, -15, loyalty_btn:getContentSize().height/2+10)
        :addTo(loyalty_btn)
    local member = self.alliance:GetMemeberById(DataManager:getUserData()._id)
    self.loyalty_label = UIKit:ttfLabel(
        {
            text = GameUtils:formatNumber(member:Loyalty()),
            size = 18,
            color = 0xf5e8c4
        }):align(display.LEFT_CENTER, -15, loyalty_btn:getContentSize().height/2-10)
        :addTo(loyalty_btn)
    -- 坐标按钮
    local coordinate_btn = WidgetPushButton.new({normal = "btn_mid_196x44.png",
        pressed = "btn_mid_196x44_light.png"})
        :onButtonClicked(function ( event )
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAlliancePosition'):AddToCurrentScene(true)
            end
        end)
        :align(display.CENTER, btn_bg:getContentSize().width/2+6, btn_bg:getContentSize().height/2-1)
        :addTo(btn_bg)
    -- 坐标
    display.newSprite("coordinate_128x128.png")
        :align(display.CENTER, -40,coordinate_btn:getContentSize().height/2-4)
        :addTo(coordinate_btn)
        :scale(42/128)
    self.coordinate_title_label = UIKit:ttfLabel(
        {
            text = _("坐标"),
            size = 14,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, -15, coordinate_btn:getContentSize().height/2+10)
        :addTo(coordinate_btn)
    self.coordinate_label = UIKit:ttfLabel(
        {
            text = "23,21",
            size = 18,
            color = 0xf5e8c4
        }):align(display.LEFT_CENTER, -15, coordinate_btn:getContentSize().height/2-10)
        :addTo(coordinate_btn)


end

function GameUIAllianceHome:CreateTop()
    local alliance = self.alliance
    local Top = {}
    local top_self_bg,top_enemy_bg = self:TopBg()
    -- 己方联盟名字
    local self_name_bg = display.newSprite("title_green_292X32.png")
        :align(display.LEFT_CENTER, -147,-26)
        :addTo(top_self_bg):flipX(true)
    local self_name_label = UIKit:ttfLabel(
        {
            text = "["..alliance:AliasName().."] "..alliance:Name(),
            size = 18,
            color = 0xffedae
        }):align(display.LEFT_CENTER, 30, 20)
        :addTo(self_name_bg)
    -- 己方联盟旗帜
    local ui_helper = WidgetAllianceUIHelper.new()
    local self_flag = ui_helper:CreateFlagContentSprite(alliance:Flag()):scale(0.5)
    self_flag:align(display.CENTER, self_name_bg:getContentSize().width-100, -30):addTo(self_name_bg)

    -- 敌方联盟名字
    local enemy_name_bg = display.newSprite("title_red_292X32.png")
        :align(display.RIGHT_CENTER, 147,-26)
        :addTo(top_enemy_bg)
    local enemy_name_label = UIKit:ttfLabel(
        {
            text = "",
            size = 18,
            color = 0xffedae
        }):align(display.RIGHT_CENTER, enemy_name_bg:getContentSize().width-30, 20)
        :addTo(enemy_name_bg)
    local enemy_peace_label = UIKit:ttfLabel(
        {
            text = _("请求开战玩家"),
            size = 18,
            color = 0xffedae
        }):align(display.LEFT_CENTER, -20,-26)
        :addTo(top_enemy_bg)

    -- 和平期,战争期,准备期背景
    local period_bg = display.newSprite("box_104x104.png")
        :align(display.TOP_CENTER, self.top_bg:getContentSize().width/2,self.top_bg:getContentSize().height)
        :addTo(self.top_bg)

    local period_text = self:GetAlliancePeriod()
    local period_label = UIKit:ttfLabel(
        {
            text = period_text,
            size = 16,
            color = 0xbdb582
        }):align(display.TOP_CENTER, period_bg:getContentSize().width/2, period_bg:getContentSize().height-14)
        :addTo(period_bg)
    self.time_label = UIKit:ttfLabel(
        {
            text = "",
            size = 18,
            color = 0xffedae
        }):align(display.BOTTOM_CENTER, period_bg:getContentSize().width/2, period_bg:getContentSize().height/2-10)
        :addTo(period_bg)
    -- 己方战力
    local our_num_icon = cc.ui.UIImage.new("power_24x29.png"):align(display.CENTER, -107, -65):addTo(top_self_bg)
    local self_power_bg = display.newSprite("power_background_146x26.png")
        :align(display.LEFT_CENTER, -107, -65):addTo(top_self_bg)
    local self_power_label = UIKit:ttfLabel(
        {
            text = string.formatnumberthousands(alliance:Power()),
            size = 20,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 20, self_power_bg:getContentSize().height/2)
        :addTo(self_power_bg)
    -- 敌方战力
    local enemy_power_bg = display.newSprite("power_background_146x26.png")
        :align(display.LEFT_CENTER, -20, -65):addTo(top_enemy_bg)
    local enemy_num_icon = cc.ui.UIImage.new("power_24x29.png")
        :align(display.CENTER, 0, enemy_power_bg:getContentSize().height/2)
        :addTo(enemy_power_bg)
    local enemy_power_label = UIKit:ttfLabel(
        {
            text = "",
            size = 20,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 20, enemy_power_bg:getContentSize().height/2)
        :addTo(enemy_power_bg)

    self:TopTabButtons()

    local home = self
    function Top:Refresh()
        local alliance = home.alliance
        local status = alliance:Status()
        local enemyAlliance = Alliance_Manager:GetMyAlliance():GetEnemyAlliance()
        period_label:setString(home:GetAlliancePeriod())
        -- 和平期
        if status=="peace" then
            enemy_name_bg:setVisible(false)
            enemy_peace_label:setVisible(true)
        else
            enemy_name_bg:setVisible(true)
            enemy_peace_label:setVisible(false)

            -- 敌方联盟旗帜
            if enemy_name_bg:getChildByTag(201) then
                enemy_name_bg:removeChildByTag(201, true)
            end
            if status=="fight" or status=="prepare" then
                local enemy_flag = ui_helper:CreateFlagContentSprite(enemyAlliance:Flag()):scale(0.5)
                enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
                    :addTo(enemy_name_bg)
                enemy_flag:setTag(201)
                enemy_name_label:setString("["..enemyAlliance:AliasName().."] "..enemyAlliance:Name())
            elseif status=="protect" then
                local enemy_reprot_data = alliance:GetEnemyLastAllianceFightReportsData()
                local enemy_flag = ui_helper:CreateFlagContentSprite(Flag.new():DecodeFromJson(enemy_reprot_data.flag)):scale(0.5)
                enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
                    :addTo(enemy_name_bg)
                enemy_flag:setTag(201)
                enemy_name_label:setString("["..enemy_reprot_data.tag.."] "..enemy_reprot_data.name)
            end
        end
        if status=="fight"  then
            our_num_icon:setTexture("battle_39x38.png")
            enemy_num_icon:setTexture("battle_39x38.png")
            enemy_num_icon:scale(1.0)

            self:SetOurPowerOrKill(alliance:GetMyAllianceFightCountData().kill)
            self:SetEnemyPowerOrKill(alliance:GetEnemyAllianceFightCountData().kill)
        elseif status=="protect" then
            our_num_icon:setTexture("battle_39x38.png")
            enemy_num_icon:setTexture("battle_39x38.png")
            enemy_num_icon:scale(1.0)
            local our_reprot_data_kill = alliance:GetOurLastAllianceFightReportsData().kill
            local enemy_reprot_data_kill = alliance:GetEnemyLastAllianceFightReportsData().kill
            self:SetOurPowerOrKill(our_reprot_data_kill)

            self:SetEnemyPowerOrKill(enemy_reprot_data_kill)

        else
            if status~="peace" then
                enemy_num_icon:setTexture("power_24x29.png")
                self:SetEnemyPowerOrKill(enemyAlliance:Power())
                enemy_num_icon:scale(1.0)
            else
                enemy_num_icon:setTexture("res_citizen_44x50.png")
                enemy_num_icon:scale(0.7)
                self:SetEnemyPowerOrKill(alliance:GetFightRequestPlayerNum())
            end
            our_num_icon:setTexture("power_24x29.png")
            self:SetOurPowerOrKill(alliance:Power())
        end
    end
    function Top:SetOurPowerOrKill(num)
        self_power_label:setString(string.formatnumberthousands(num))
    end
    function Top:SetEnemyPowerOrKill(num)
        enemy_power_label:setString(string.formatnumberthousands(num))
    end
    return Top
end

function GameUIAllianceHome:OnAllianceFightRequestsChanged(request_num)
    if self.alliance:Status() == "peace" then
        self.top:SetEnemyPowerOrKill(request_num)
    end
end

function GameUIAllianceHome:MailUnreadChanged(...)
    local num =MailManager:GetUnReadMailsNum() + MailManager:GetUnReadReportsNum()
    if num==0 then
        self.mail_unread_num_bg:setVisible(false)
    else
        self.mail_unread_num_bg:setVisible(true)
        self.mail_unread_num_label:setString(GameUtils:formatNumber(num))
    end
end
function GameUIAllianceHome:CreateBottom()

    -- 底部背景
    local bottom_bg = display.newSprite("bottom_bg_768x136.png")
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)
        :addTo(self)
    bottom_bg:setTouchEnabled(true)
    if display.width >640 then
        bottom_bg:scale(display.width/768)
    end

    -- 聊天背景
    local chat_bg = display.newSprite("chat_background.png")
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height-10)
        :addTo(bottom_bg)
    cc.ui.UIImage.new("chat_btn_60x48.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width-60, 0)
    local index_1 = display.newSprite("chat_page_index_1.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2-10,chat_bg:getContentSize().height-10)
    local index_2 = display.newSprite("chat_page_index_2.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2+10,chat_bg:getContentSize().height-10)

    local size = chat_bg:getContentSize()
    local pv = UIPageView.new {
        viewRect =  cc.rect(10, 4, size.width-80, size.height),
        row = 2,
        padding = {left = 0, right = 0, top = 10, bottom = 0}
    }
        :onTouch(function (event)
            dump(event,"UIPageView event")
            if event.name == "pageChange" then
                if 1 == event.pageIdx then
                    index_1:setPositionX(chat_bg:getContentSize().width/2-10)
                    index_2:setPositionX(chat_bg:getContentSize().width/2+10)
                elseif 2 == event.pageIdx then
                    index_1:setPositionX(chat_bg:getContentSize().width/2+10)
                    index_2:setPositionX(chat_bg:getContentSize().width/2-10)
                end
            elseif event.name == "clicked" then
                if event.pageIdx == 1 then
                    UIKit:newGameUI('GameUIChatChannel',"global"):AddToCurrentScene(true)
                elseif event.pageIdx == 2 then
                    UIKit:newGameUI('GameUIChatChannel',"alliance"):AddToCurrentScene(true)
                end
            end
        end)
        :addTo(chat_bg)
    pv:setTouchEnabled(true)
    pv:setTouchSwallowEnabled(false)
    -- add items
    self.chat_labels = {}
    local last_chat_messages = self:GetChatManager():FetchLastChannelMessage()
    dump(last_chat_messages,"last_chat_messages--->")
    -- add items
    for i=1,4 do
        local item = pv:newItem()
        local content

        content = display.newLayer()
        content:setContentSize(540, 20)
        content:setTouchEnabled(false)
        local label = RichText.new({width = 540,size = 16,color = 0xc7bd97})
        label:Text(last_chat_messages[i],1)
        label:addTo(content):align(display.LEFT_CENTER, 0, content:getContentSize().height/2)
        table.insert(self.chat_labels, label)
        item:addChild(content)
        pv:addItem(item)
    end
    pv:reload()


    -- 底部按钮
    local first_row = 64
    local first_col = 240
    local label_padding = 20
    local padding_width = 100
    for i, v in ipairs({
        {"bottom_icon_mission_128x128.png", _("任务")},
        {"bottom_icon_package_128x128.png", _("物品")},
        {"mail_icon_128x128.png", _("邮件")},
        {"bottom_icon_alliance_128x128.png", _("联盟")},
        {"bottom_icon_package_77x67.png", _("更多")},
    }) do
        local col = i - 1
        local x, y = first_col + col * padding_width, first_row
        local button = WidgetPushButton.new({normal = v[1]})
            :onButtonClicked(handler(self, self.OnBottomButtonClicked))
            :addTo(bottom_bg):pos(x, y)
            :scale(0.55)
        button:setTag(i)
        button:addButtonPressedEventListener(function ()
            local seq_1 = transition.sequence{
                cc.ScaleTo:create(0.1, 0.55),
                cc.ScaleTo:create(0.1, 0.6),
                cc.ScaleTo:create(0.1, 0.55),
            }
            button:runAction(seq_1)
        end)
        UIKit:ttfLabel({
            text = v[2],
            size = 16,
            color = 0xf5e8c4})
            :addTo(bottom_bg):align(display.CENTER,x, y-40)
    end

    -- 未读邮件或战报数量显示条
    self.mail_unread_num_bg = display.newSprite("mail_unread_bg_36x23.png"):addTo(bottom_bg):pos(460, first_row+20)
    self.mail_unread_num_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = GameUtils:formatNumber(MailManager:GetUnReadMailsAndReportsNum()),
            font = UIKit:getFontFilePath(),
            size = 16,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xf5f2b3)
        }):align(display.CENTER,self.mail_unread_num_bg:getContentSize().width/2,self.mail_unread_num_bg:getContentSize().height/2+4)
        :addTo(self.mail_unread_num_bg)
    if MailManager:GetUnReadMailsAndReportsNum()==0 then
        self.mail_unread_num_bg:setVisible(false)
    end


    self:AddMapChangeButton()

    return bottom_bg
end
function GameUIAllianceHome:AddMapChangeButton()
    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE):addTo(self)
end
function GameUIAllianceHome:OnTopButtonClicked(event)
    print("OnTopButtonClicked=",event.name)
    if event.name == "CLICKED_EVENT" then
        UIKit:newGameUI("GameUIAllianceBattle",City):AddToCurrentScene(true)
    end
end
function GameUIAllianceHome:OnBottomButtonClicked(event)
    local tag = event.target:getTag()
    if not tag then return end
    if tag == 4 then -- tag 4 = alliance button
        -- UIKit:newGameUI('GameUIAlliance'):AddToCurrentScene(true)
        UIKit:newGameUI('GameUIShop', City):AddToCurrentScene(true)
    elseif tag == 1 then
        UIKit:newGameUI('GameUIMission',City):AddToCurrentScene(true)
    elseif tag == 3 then
        UIKit:newGameUI('GameUIMail',_("邮件"),City):AddToCurrentScene(true)
    elseif tag == 5 then
        UIKit:newGameUI('GameUISetting',City):AddToCurrentScene(true)
    end
end
function GameUIAllianceHome:OnMidButtonClicked(event)
    local tag = event.target:getTag()
    if not tag then return end
    if tag == 2 then -- 战斗
    -- NetManager:getFindAllianceToFightPromose()
    elseif tag == 1 then
        if not self.alliance:IsDefault() then
            GameUIHelp.new():AddToCurrentScene()
        else
            FullScreenPopDialogUI.new():SetTitle(_("提示"))
                :SetPopMessage(_("加入联盟才能激活帮助功能"))
                :AddToCurrentScene()
        end
    end
end

function GameUIAllianceHome:OnBasicChanged(alliance,changed_map)
    if changed_map.honour then
        self.honour_label:setString(GameUtils:formatNumber(changed_map.honour.new))
    elseif changed_map.status then
        self.top:Refresh()
    end
end
function GameUIAllianceHome:OnMemberChanged(alliance)
    local self_member = alliance:GetMemeberById(DataManager:getUserData()._id)
    self.loyalty_label:setString(GameUtils:formatNumber(self_member.loyalty))
end
-- function GameUIAllianceHome:OnAllianceCountInfoChanged(alliance,countInfo)
--     self.count = 0
--     local status = self.alliance:Status()
--     if status=="fight" or status=="protect" then
--         print("self.count",self.count)
--         LuaUtils:outputTable("GameUIAllianceHome:OnAllianceCountInfoChanged==countInfo", countInfo)
--         self.count = self.count + 1
--         if countInfo.kill then
--             self.top:SetOurPowerOrKill(countInfo.kill)
--         end
--         if countInfo.beKilled then
--             self.top:SetEnemyPowerOrKill(countInfo.beKilled)
--         end
--     end
-- end
local function pGetIntersectPoint(pt1,pt2,pt3,pt4)
    local s,t, ret = 0,0,false
    ret,s,t = cc.pIsLineIntersect(pt1,pt2,pt3,pt4,s,t)
    if ret then
        return cc.p(pt1.x + s * (pt2.x - pt1.x), pt1.y + s * (pt2.y - pt1.y)), s
    else
        return cc.p(0,0), s
    end
end
function GameUIAllianceHome:OnSceneMove(logic_x, logic_y, alliance_view)
    local coordinate_str = string.format("%d, %d", logic_x, logic_y)
    local is_mine
    if alliance_view then
        is_mine = alliance_view:GetAlliance():Id() == self.alliance:Id() and _("我方") or _("敌方")
    else
        is_mine = _("坐标")
    end
    self.coordinate_label:setString(coordinate_str)
    self.coordinate_title_label:setString(is_mine)

    -- ----- arrow
    local scene = display.getRunningScene()
    if scene.GetAlliance then
        local alliance = scene:GetAlliance()
        local layer = scene:GetSceneLayer()
        local location = alliance:GetSelf().location
        local point = layer:ConvertLogicPositionToMapPosition(location.x, location.y, alliance:Id())
        local world_point = layer:convertToWorldSpace(point)
        local mid_point = cc.p(display.cx, display.cy)
        local screen_rect = self.screen_rect
        local left_bottom_point = cc.p(screen_rect.x, screen_rect.y)
        local left_top_point = cc.p(screen_rect.x, screen_rect.y + screen_rect.height)
        local right_bottom_point = cc.p(screen_rect.x + screen_rect.width, screen_rect.y)
        local right_top_point = cc.p(screen_rect.x + screen_rect.width, screen_rect.y + screen_rect.height)
        if not cc.rectContainsPoint(screen_rect, world_point) then
            local degree = math.deg(cc.pGetAngle(cc.pSub(mid_point, world_point), cc.p(0, 1))) + 180
            local points = {right_bottom_point,right_top_point,left_top_point,left_bottom_point}
            for i = 1, #points do
                local p1, p2
                if i ~= #points then
                    p1 = points[i]
                    p2 = points[i + 1]
                else
                    p1 = points[i]
                    p2 = points[1]
                end
                local p,s = pGetIntersectPoint(mid_point, world_point, p1, p2)
                if s > 0 and cc.rectContainsPoint(screen_rect, p) then
                    self.arrow:show():pos(p.x, p.y):rotation(degree)
                    local isflip = (degree > 0 and degree < 180)
                    self.arrow_label:align(isflip and display.RIGHT_CENTER or display.LEFT_CENTER)
                    self.arrow_label:scale(isflip and -3 or 3)
                    local distance = math.ceil(cc.pGetLength(cc.pSub(world_point, p)) / 80)
                    self.arrow_label:setString(string.format("%dM", distance))
                    break
                end
            end
        else
            self.arrow:hide()
        end
    end
end
function GameUIAllianceHome:OnAllianceFightChanged(alliance,allianceFight)
    local status = self.alliance:Status()
    if status=="fight" then
        local our , enemy
        if self.alliance:Id() == allianceFight.attackAllianceId  then
            our = allianceFight.attackAllianceCountData
            enemy = allianceFight.defenceAllianceCountData
        else
            our = allianceFight.defenceAllianceCountData
            enemy = allianceFight.attackAllianceCountData
        end
        if our and enemy then
            self.top:SetOurPowerOrKill(our.kill)
            self.top:SetEnemyPowerOrKill(enemy.kill)
        end
    end
end
function GameUIAllianceHome:OnTimer(current_time)
    local status = self.alliance:Status()
    if status ~= "peace" then
        local statusFinishTime = self.alliance:StatusFinishTime()
        -- print("OnTimer == ",math.floor(statusFinishTime/1000)>current_time,math.floor(statusFinishTime/1000),current_time)
        if math.floor(statusFinishTime/1000)>current_time then
            self.time_label:setString(GameUtils:formatTimeStyle1(math.floor(statusFinishTime/1000)-current_time))
        end
    else
        local statusStartTime = self.alliance:StatusStartTime()
        if current_time>= math.floor(statusStartTime/1000) then
            self.time_label:setString(GameUtils:formatTimeStyle1(current_time-math.floor(statusStartTime/1000)))
        end
    end
end

function GameUIAllianceHome:GetAlliancePeriod()
    local period = ""
    local status = self.alliance:Status()
    if status == "peace" then
        period = _("和平期")
    elseif status == "prepare" then
        period = _("准备期")
    elseif status == "fight" then
        period = _("战争期")
    elseif status == "protect" then
        period = _("保护期")
    end
    return period
end

return GameUIAllianceHome





























