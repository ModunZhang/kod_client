local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local window = import("..utils.window")
local UIPageView = import("..ui.UIPageView")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local Arrow = import(".Arrow")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local GameUIHelp = import(".GameUIHelp")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local Alliance = import("..entity.Alliance")
local GrowUpTaskManager = import("..entity.GrowUpTaskManager")
local RichText = import("..widget.RichText")
local ChatManager = import("..entity.ChatManager")
local GameUIHome = UIKit:createUIClass('GameUIHome')


local app = app
local timer = app.timer

function GameUIHome:OnResourceChanged(resource_manager)
    local server_time = timer:GetServerTime()
    local wood_number = resource_manager:GetWoodResource():GetResourceValueByCurrentTime(server_time)
    local food_number = resource_manager:GetFoodResource():GetResourceValueByCurrentTime(server_time)
    local iron_number = resource_manager:GetIronResource():GetResourceValueByCurrentTime(server_time)
    local stone_number = resource_manager:GetStoneResource():GetResourceValueByCurrentTime(server_time)
    local citizen_number = resource_manager:GetPopulationResource():GetNoneAllocatedByTime(server_time)
    local coin_number = resource_manager:GetCoinResource():GetResourceValueByCurrentTime(server_time)
    local gem_number = self.city:GetUser():GetGemResource():GetValue()
    self.wood_label:setString(GameUtils:formatNumber(wood_number))
    self.food_label:setString(GameUtils:formatNumber(food_number))
    self.iron_label:setString(GameUtils:formatNumber(iron_number))
    self.stone_label:setString(GameUtils:formatNumber(stone_number))
    self.citizen_label:setString(GameUtils:formatNumber(citizen_number))
    self.coin_label:setString(GameUtils:formatNumber(coin_number))
    self.gem_label:setString(string.formatnumberthousands(gem_number))
end
function GameUIHome:OnUpgradingBegin()
end
function GameUIHome:OnUpgrading()
end
function GameUIHome:OnUpgradingFinished()
    self:OnTaskChanged()
end
function GameUIHome:OnTaskChanged()
    self.task = self.city:GetRecommendTask()
    if self.task then
        self.quest_label:setString(self.task:Title())
    else
        self.quest_label:setString(_("当前没有推荐任务!"))
    end
    self:SetCompleteTaskCount(self.city:GetUser():GetTaskManager():GetCompleteTaskCount())
end
function GameUIHome:SetCompleteTaskCount(count)
    if count > 0 then
        self.complete_task_count:show()
        self.complete_task_count_label:setString(count > 99 and "..." or count)
    else
        self.complete_task_count:hide()
    end
end


function GameUIHome:ctor(city)
    GameUIHome.super.ctor(self,{type = UIKit.UITYPE.BACKGROUND})
    self.city = city
    self.chatManager = app:GetChatManager()
end

function GameUIHome:GetChatManager()
    return self.chatManager
end

function GameUIHome:DisplayOn()
    self.visible_count = self.visible_count + 1
    -- self:setVisible(self.visible_count > 0)
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIHome:DisplayOff()
    self.visible_count = self.visible_count - 1
    -- self:setVisible(self.visible_count > 0)
    self:FadeToSelf(self.visible_count > 0)
end

function GameUIHome:FadeToSelf(isFullDisplay)
    self:setCascadeOpacityEnabled(true)
    local opacity = isFullDisplay == true and 255 or 0
    local p = isFullDisplay and 0 or 99999999
    transition.fadeTo(self, {opacity = opacity, time = 0.2,
        onComplete = function()
                self:pos(p, p)
            end
        })
end

function GameUIHome:onEnter()
    -- GameUIHome.super.onEnter(self)
    self.visible_count = 1
    local city = self.city
    -- 上背景
    self:CreateTop()
    self.bottom = self:CreateBottom()
    self.bottom:setCascadeOpacityEnabled(true)
    local ratio = self.bottom:getScale()
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
    self.event_tab = WidgetEventTabButtons.new(self.city, ratio)
    local rect1 = self.chat_bg:getCascadeBoundingBox()
    local rect2 = self.event_tab:getCascadeBoundingBox()
    local x, y = rect1.x, rect1.y + rect1.height - 2 * ratio
    self.event_tab:addTo(self):pos(x, y)

    self:RefreshData()
    city:AddListenOnType(self, city.LISTEN_TYPE.UPGRADE_BUILDING)
    city:GetResourceManager():AddObserver(self)
    city:GetResourceManager():OnResourceChanged()
    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    Alliance_Manager:GetMyAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    Alliance_Manager:GetMyAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.HELP_EVENTS)
    Alliance_Manager:GetMyAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.ALL_HELP_EVENTS)

    User:AddListenOnType(self, User.LISTEN_TYPE.BASIC)
    User:AddListenOnType(self, User.LISTEN_TYPE.TASK)
    User:AddListenOnType(self, User.LISTEN_TYPE.VIP_EVENT_ACTIVE)
    User:AddListenOnType(self, User.LISTEN_TYPE.VIP_EVENT_OVER)


    -- local back = cc.ui.UIImage.new("tab_background_640x106.png", {scale9 = true,
    --     capInsets = cc.rect(2, 2, 640 - 4, 106 - 4)
    -- }):align(display.LEFT_BOTTOM, 40, display.cy):setLayoutSize(640, 50):addTo(self,100)
    self:OnTaskChanged(User)
end

function GameUIHome:TO_TOP()
    self:RefreshChatMessage()
end

function GameUIHome:TO_REFRESH()
    self:RefreshChatMessage()
end

function GameUIHome:RefreshChatMessage()
    if not self.chat_labels then return end
    local last_chat_messages = self:GetChatManager():FetchLastChannelMessage()
    for i,v in ipairs(self.chat_labels) do
        local rich_text = self.chat_labels[i]
        rich_text:Text(last_chat_messages[i],1)
        rich_text:align(display.LEFT_CENTER, 0, 10)
    end
end

function GameUIHome:onExit()
    self.city:RemoveListenerOnType(self, self.city.LISTEN_TYPE.UPGRADE_BUILDING)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
    self.city:GetResourceManager():RemoveObserver(self)
    MailManager:RemoveListenerOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.HELP_EVENTS)
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.ALL_HELP_EVENTS)

    User:RemoveListenerOnType(self, User.LISTEN_TYPE.BASIC)
    User:RemoveListenerOnType(self, User.LISTEN_TYPE.TASK)
    User:RemoveListenerOnType(self, User.LISTEN_TYPE.VIP_EVENT_ACTIVE)
    User:RemoveListenerOnType(self, User.LISTEN_TYPE.VIP_EVENT_OVER)
    -- GameUIHome.super.onExit(self)
end
function GameUIHome:OnBasicChanged(fromEntity,changed_map)
    if changed_map.id then
        local flag = changed_map.id.new~=nil or changed_map.id.old~=""
        self.help_button:setVisible(flag)
    end
    if fromEntity.__cname == "User" then
        if changed_map.name then
            self.name_label:setString(changed_map.name.new)
        end
        if changed_map.vipExp then
            self:RefreshVIP()
        end
    end
    self:RefreshData()
end
function GameUIHome:OnHelpEventChanged(changed_map)
    local alliance = Alliance_Manager:GetMyAlliance()
    self.help_button:setVisible(LuaUtils:table_size(alliance:GetAllHelpEvents())>0)
    local request_num = alliance:GetOtherRequestEventsNum()
    self.request_help_num_bg:setVisible(request_num>0)
    self.request_help_num:setString(GameUtils:formatNumber(request_num))
end
function GameUIHome:OnAllHelpEventChanged(help_events)
    local alliance = Alliance_Manager:GetMyAlliance()
    self.help_button:setVisible(LuaUtils:table_size(help_events)>0)
    local request_num = alliance:GetOtherRequestEventsNum()
    self.request_help_num_bg:setVisible(request_num>0)
    self.request_help_num:setString(GameUtils:formatNumber(request_num))
end

function GameUIHome:MailUnreadChanged(...)
    local num =MailManager:GetUnReadMailsNum()+MailManager:GetUnReadReportsNum()
    if num==0 then
        self.mail_unread_num_bg:setVisible(false)
    else
        self.mail_unread_num_bg:setVisible(true)
        self.mail_unread_num_label:setString(GameUtils:formatNumber(num))
    end
end
function GameUIHome:RefreshData()
    -- 更新数值
    local user = self.city:GetUser()
    self.name_label:setString(user:Name())
    self.power_label:setString(user:Power())
    self.level_label:setString(user:Level())
    self:RefreshVIP()
end


function GameUIHome:CreateTop()
    local top_bg = display.newSprite("top_bg_768x116.png"):addTo(self)
        :align(display.TOP_CENTER, display.cx, display.top ):setCascadeOpacityEnabled(true)
    if display.width>640 then
        top_bg:scale(display.width/768)
    end

    -- 玩家按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "player_btn_up_314x86.png", pressed = "player_btn_down_314x86.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI('GameUIVip', City,"info"):AddToCurrentScene(true)
        end
    end):addTo(top_bg):align(display.LEFT_CENTER,top_bg:getContentSize().width/2-2, top_bg:getContentSize().height/2+10)
    button:setRotationSkewY(180)


    -- 玩家名字背景加文字
    local ox = 159
    local name_bg = display.newSprite("player_name_bg_168x30.png"):addTo(top_bg)
        :align(display.TOP_LEFT, ox, top_bg:getContentSize().height-10):setCascadeOpacityEnabled(true)
    self.name_label = cc.ui.UILabel.new({
        text = "",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xf3f0b6)
    }):addTo(name_bg):align(display.LEFT_CENTER, 14, name_bg:getContentSize().height/2 + 3)

    -- 玩家战斗值图片
    display.newSprite("power_16x19.png"):addTo(top_bg):pos(ox + 20, 65)

    -- 玩家战斗值文字
    UIKit:ttfLabel({
        text = _("战斗值："),
        size = 14,
        color = 0x9a946b,
        shadow = true
    }):addTo(top_bg):align(display.LEFT_CENTER, ox + 30, 65)

    -- 玩家战斗值数字
    self.power_label = UIKit:ttfLabel({
        text = "",
        size = 20,
        color = 0xf3f0b6,
        shadow = true
    }):addTo(top_bg):align(display.LEFT_CENTER, ox + 14, 42)



    -----------------------
    -- 资源按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "player_btn_up_314x86.png", pressed = "player_btn_down_314x86.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIResourceOverview",self.city):AddToCurrentScene(true)
        end
    end):addTo(top_bg):align(display.LEFT_CENTER, top_bg:getContentSize().width/2+2, top_bg:getContentSize().height/2+10)

    -- 资源图片和文字
    local first_row = 18
    local first_col = 30
    local label_padding = 20
    local padding_width = 100
    local padding_height = 35
    for i, v in ipairs({
        {"res_wood_114x100.png", "wood_label"},
        {"res_stone_128x128.png", "stone_label"},
        {"res_citizen_44x50.png", "citizen_label"},
        {"res_food_114x100.png", "food_label"},
        {"res_iron_114x100.png", "iron_label"},
        {"coin_icon.png", "coin_label"},
    }) do
        local row = i > 3 and 1 or 0
        local col = (i - 1) % 3
        local x, y = first_col + col * padding_width, first_row - (row * padding_height)
        display.newSprite(v[1]):addTo(button):pos(x, y):scale(i == 3 and 0.65 or 0.25)
        self[v[2]] = UIKit:ttfLabel({text = "",
            size = 18,
            color = 0xf3f0b6,
            shadow = true
        }):addTo(button):pos(x + label_padding, y)
    end

    -- 玩家信息背景
    local player_bg = display.newSprite("player_bg_110x106.png"):addTo(top_bg, 2)
        :align(display.LEFT_BOTTOM, display.width>640 and 58 or 64, 10):setCascadeOpacityEnabled(true)
    display.newSprite("player_icon_110x106.png"):addTo(player_bg):pos(55, 53)
    local level_bg = display.newSprite("level_bg_74x24.png"):addTo(player_bg):pos(55, 30):setCascadeOpacityEnabled(true)
    self.level_label = UIKit:ttfLabel({
        size = 20,
        color = 0xfff1cc,
        shadow = true,
    }):addTo(level_bg):align(display.CENTER, 37, 12)
    self.exp = display.newSprite("player_exp_bar_110x106.png"):addTo(player_bg):pos(55, 53)

    -- vip
    local vip_btn = cc.ui.UIPushButton.new(
        {},
        {scale9 = false}
    ):addTo(top_bg):align(display.CENTER, ox + 195, 50)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIVip', City,"VIP"):AddToCurrentScene(true)
            end
        end)
    local vip_btn_img = User:IsVIPActived() and "vip_bg_110x124.png" or "vip_bg_disable_110x124.png"
    vip_btn:setButtonImage(cc.ui.UIPushButton.NORMAL, vip_btn_img, true)
    vip_btn:setButtonImage(cc.ui.UIPushButton.PRESSED, vip_btn_img, true)
    self.vip_level = display.newNode():addTo(vip_btn):pos(-3, 15):scale(0.8)
    self.vip_btn = vip_btn



    -- 宝石按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up_196x68.png", pressed = "gem_btn_down_196x68.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
    end):addTo(top_bg):pos(top_bg:getContentSize().width - 155, -16)
    display.newSprite("gem_icon_62x61.png"):addTo(button):pos(60, 3)
    self.gem_label = UIKit:ttfLabel({
        size = 20,
        color = 0xffd200,
        shadow = true
    }):addTo(button):align(display.CENTER, -30, 8)

    -- 任务条
    local quest_bar_bg = cc.ui.UIPushButton.new(
        {normal = "quest_btn_up_386x62.png", pressed = "quest_btn_down_386x62.png"},
        {scale9 = false}
    ):addTo(top_bg):pos(255, -10):onButtonClicked(function(event)
        if self.task then
            local building
            if self.task:BuildingType() == "tower" then
                building = self.city:GetNearGateTower()
            else
                building = self.city:GetHighestBuildingByType(self.task:BuildingType())
            end
            if building then
                local current_scene = display.getRunningScene()
                current_scene:GotoLogicPoint(building:GetMidLogicPosition())
                local building_sprite = current_scene:GetSceneLayer():FindBuildingSpriteByBuilding(building, self.city)
                current_scene:AddIndicateForBuilding(building_sprite)
            end
        end
    end)
    display.newSprite("quest_icon_27x42.png"):addTo(quest_bar_bg):pos(-162, 0)
    self.quest_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xfffeb3)})
        :addTo(quest_bar_bg):align(display.LEFT_CENTER, -120, 0)

    -- 礼物按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "gift_128x128.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIActivity",City):AddToCurrentScene(true)
        end
    end):addTo(self):pos(display.right-40, display.top-200):scale(0.6)
    --帮助
    local button = cc.ui.UIPushButton.new(
        {normal = "buff_8_128x128.png", pressed = "buff_8_128x128.png"},
        {scale9 = false}
    )
    button:onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUITips",button):AddToCurrentScene(true)
        end
    end):addTo(self):pos(display.right-40, display.top-290):scale(0.5)

    -- BUFF按钮
    local buff_button = cc.ui.UIPushButton.new(
        {normal = "buff_1_128x128.png", pressed = "buff_1_128x128.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIBuff",self.city):AddToCurrentScene(true)
        end
    end):addTo(self):pos(display.left+40, display.top-200)
        :scale(0.5)
    return top_bg
end

function GameUIHome:CreateBottom()
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
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height-11)
        :addTo(bottom_bg)
    chat_bg:setCascadeOpacityEnabled(true)
    local size = chat_bg:getContentSize()
    local index_1 = display.newSprite("chat_page_index_1.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2-10,chat_bg:getContentSize().height-10)
    local index_2 = display.newSprite("chat_page_index_2.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2+10,chat_bg:getContentSize().height-10)
    self.chat_bg = chat_bg
    local pv = UIPageView.new {
        viewRect = cc.rect(10, 4, size.width-80, size.height),
        row = 2,
        padding = {left = 0, right = 0, top = 10, bottom = 0}
    }:onTouch(function (event)
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
    end):addTo(chat_bg)
    pv:setTouchEnabled(true)
    pv:setTouchSwallowEnabled(false)
    pv:setCascadeOpacityEnabled(true)
    self.chat_labels = {}
    local last_chat_messages = self:GetChatManager():FetchLastChannelMessage()
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

    cc.ui.UIPushButton.new({normal = "chat_btn_60x48.png",
        pressed = "chat_btn_60x48.png"}):addTo(chat_bg)
        :pos(chat_bg:getContentSize().width-30, size.height/2)
        :onButtonClicked(function()
            if 1 == pv:getCurPageIdx() then
                UIKit:newGameUI('GameUIChatChannel',"global"):AddToCurrentScene(true)
            elseif 2 == pv:getCurPageIdx() then
                UIKit:newGameUI('GameUIChatChannel',"alliance"):AddToCurrentScene(true)
            end
        end)

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
        local button = cc.ui.UIPushButton.new({normal = v[1]})
            :onButtonClicked(handler(self, self.OnBottomButtonClicked))
            :addTo(bottom_bg):pos(x, y)
            :scale(0.55)
        UIKit:ttfLabel({
            text = v[2],
            size = 16,
            color = 0xf5e8c4})
            :addTo(bottom_bg):align(display.CENTER,x, y-40)
        button:setTag(i)
        button:addButtonPressedEventListener(function ()
            button:runAction(cc.ScaleTo:create(0.1, 0.7))
        end)
        button:addButtonReleaseEventListener(function ()
            button:runAction(cc.ScaleTo:create(0.1, 0.55))
        end)
        if i == 1 then
            -- 未读邮件或战报数量显示条
            self.complete_task_count = display.newSprite("mail_unread_bg_36x23.png"):addTo(bottom_bg):pos(260, first_row+20)
            local size = self.complete_task_count:getContentSize()
            self.complete_task_count_label = cc.ui.UILabel.new(
                {cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = GameUtils:formatNumber(0),
                    font = UIKit:getFontFilePath(),
                    size = 16,
                    color = UIKit:hex2c3b(0xf5f2b3)
                }):align(display.CENTER, size.width/2, size.height/2+4):addTo(self.complete_task_count)
        end
    end

    -- 未读邮件或战报数量显示条
    self.mail_unread_num_bg = display.newSprite("mail_unread_bg_36x23.png"):addTo(bottom_bg):pos(460, first_row+20)
    self.mail_unread_num_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = GameUtils:formatNumber(MailManager:GetUnReadMailsAndReportsNum() or 0),
            font = UIKit:getFontFilePath(),
            size = 16,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xf5f2b3)
        }):align(display.CENTER,self.mail_unread_num_bg:getContentSize().width/2,self.mail_unread_num_bg:getContentSize().height/2+4)
        :addTo(self.mail_unread_num_bg)
    if MailManager:GetUnReadMailsAndReportsNum()==0 then
        self.mail_unread_num_bg:setVisible(false)
    end


    -- 场景切换

    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_CITY):addTo(self)


    -- 协助加速按钮
    local help_button = cc.ui.UIPushButton.new(
        {normal = "help_68x60.png", pressed = "help_68x60.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            if not Alliance_Manager:GetMyAlliance():IsDefault() then
                GameUIHelp.new():AddToCurrentScene(true)
            else
                FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("加入联盟才能激活帮助功能"))
                    :AddToCurrentScene()
            end
        end
    end):addTo(self):pos(display.right-40, display.bottom+300)
    help_button:setVisible(not Alliance_Manager:GetMyAlliance():IsDefault())
    help_button:setVisible(LuaUtils:table_size(Alliance_Manager:GetMyAlliance():GetAllHelpEvents())>0)

    -- 请求帮助的其他联盟成员请求帮助事件数量
    local request_help_num_bg = display.newSprite("mail_unread_bg_36x23.png"):addTo(help_button):pos(20,-20)
    local request_num = Alliance_Manager:GetMyAlliance():GetOtherRequestEventsNum()
    self.request_help_num = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = GameUtils:formatNumber(request_num),
            font = UIKit:getFontFilePath(),
            size = 16,
            color = UIKit:hex2c3b(0xf5f2b3)
        }):align(display.CENTER,request_help_num_bg:getContentSize().width/2,request_help_num_bg:getContentSize().height/2+4)
        :addTo(request_help_num_bg)
    request_help_num_bg:setVisible(request_num>0)
    self.request_help_num_bg = request_help_num_bg
    self.help_button = help_button

    -- TODO:临时gacha按钮
    -- local gacha_button = cc.ui.UIPushButton.new(
    --     {normal = "icon_casinoToken.png", pressed = "icon_casinoToken.png"},
    --     {scale9 = false}
    -- ):onButtonClicked(function(event)
    --     if event.name == "CLICKED_EVENT" then
    --         UIKit:newGameUI("GameUIGacha", self.city):AddToCurrentScene(true)
    --     end
    -- end):addTo(self):pos(display.right-40, display.bottom+400):scale(0.6)

    return bottom_bg
end

function GameUIHome:OnBottomButtonClicked(event)
    local tag = event.target:getTag()
    if not tag then return end
    if tag == 4 then -- tag 4 = alliance button
        UIKit:newGameUI('GameUIAlliance'):AddToCurrentScene(true)
    elseif tag == 3 then
        UIKit:newGameUI('GameUIMail',_("邮件"),self.city):AddToCurrentScene(true)
    elseif tag == 2 then
        UIKit:newGameUI('GameUIItems',_("道具"),self.city):AddToCurrentScene(true)
    elseif tag == 1 then
        UIKit:newGameUI('GameUIMission',self.city):AddToCurrentScene(true)
    elseif tag == 5 then
        UIKit:newGameUI('GameUISetting',self.city):AddToCurrentScene(true)
    end



end
function GameUIHome:OnVipEventActive( vip_event )
    self:RefreshVIP()
end
function GameUIHome:OnVipEventOver( vip_event )
    self:RefreshVIP()
end

function GameUIHome:RefreshVIP()
    local vip_btn = self.vip_btn
    local vip_btn_img = User:IsVIPActived() and "vip_bg_110x124.png" or "vip_bg_disable_110x124.png"
    vip_btn:setButtonImage(cc.ui.UIPushButton.NORMAL, vip_btn_img, true)
    vip_btn:setButtonImage(cc.ui.UIPushButton.PRESSED, vip_btn_img, true)
    local vip_level = self.vip_level
    vip_level:removeAllChildren()
    local level_img = display.newSprite(string.format("VIP_%d_46x32.png", User:GetVipLevel()),0,0,{class=cc.FilteredSpriteWithOne}):addTo(vip_level)
    if not User:IsVIPActived() then
        local my_filter = filter
        local filters = my_filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1})
        level_img:setFilter(filters)
    end
end

-- fte
function GameUIHome:DefferShow(tab_type)
    return self.event_tab:PromiseOfShowTab(tab_type):next(function() return self end)
end
function GameUIHome:Find()
    local item
    self.event_tab:IteratorAllItem(function(_, v)
        item = v:GetSpeedUpButton()
        return true
    end)
    return cocos_promise.defer(function()
        if not item then
            promise.reject({code = -1, msg = "没有找到对应item"}, "")
        end
        return item
    end)
end

return GameUIHome




































