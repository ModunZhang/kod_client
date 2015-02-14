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
local RichText = import("..widget.RichText")
local ChatManager = import("..entity.ChatManager")
local GameUIHome = UIKit:createUIClass('GameUIHome')


local app = app
local timer = app.timer

function GameUIHome:OnResourceChanged(resource_manager)
    local wood_number = resource_manager:GetWoodResource():GetResourceValueByCurrentTime(timer:GetServerTime())
    local food_number = resource_manager:GetFoodResource():GetResourceValueByCurrentTime(timer:GetServerTime())
    local iron_number = resource_manager:GetIronResource():GetResourceValueByCurrentTime(timer:GetServerTime())
    local stone_number = resource_manager:GetStoneResource():GetResourceValueByCurrentTime(timer:GetServerTime())
    local citizen_number = resource_manager:GetPopulationResource():GetNoneAllocatedByTime(timer:GetServerTime())
    local coin_number = resource_manager:GetCoinResource():GetValue()
    local gem_number = self.city:GetUser():GetGemResource():GetValue()
    self.wood_label:setString(GameUtils:formatNumber(wood_number))
    self.food_label:setString(GameUtils:formatNumber(food_number))
    self.iron_label:setString(GameUtils:formatNumber(iron_number))
    self.stone_label:setString(GameUtils:formatNumber(stone_number))
    self.citizen_label:setString(GameUtils:formatNumber(citizen_number))
    self.coin_label:setString(GameUtils:formatNumber(coin_number))
    self.gem_label:setString(string.formatnumberthousands(gem_number))
end


function GameUIHome:ctor(city)
    GameUIHome.super.ctor(self)
    self.city = city
    self.chatManager = app:GetChatManager()
end

function GameUIHome:GetChatManager()
    return self.chatManager
end

function GameUIHome:onEnter()
    -- GameUIHome.super.onEnter(self)
    local city = self.city
    -- 上背景
    self:CreateTop()
    self.bottom = self:CreateBottom()
    local ratio = self.bottom:getScale()
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
    self.event_tab = WidgetEventTabButtons.new(self.city, ratio)
    local rect1 = self.chat_bg:getCascadeBoundingBox()
    local rect2 = self.event_tab:getCascadeBoundingBox()
    local x, y = rect1.x, rect1.y + rect1.height - 2 * ratio
    self.event_tab:addTo(self):pos(x, y)

    self:RefreshData()
    city:GetResourceManager():AddObserver(self)
    city:GetResourceManager():OnResourceChanged()
    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    Alliance_Manager:GetMyAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    User:AddListenOnType(self, User.LISTEN_TYPE.BASIC)


    -- local back = cc.ui.UIImage.new("tab_background_640x106.png", {scale9 = true,
    --     capInsets = cc.rect(2, 2, 640 - 4, 106 - 4)
    -- }):align(display.LEFT_BOTTOM, 40, display.cy):setLayoutSize(640, 50):addTo(self,100)

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
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
    self.city:GetResourceManager():RemoveObserver(self)
    MailManager:RemoveListenerOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    User:RemoveListenerOnType(self, User.LISTEN_TYPE.BASIC)
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
            self.vip_level:removeAllChildren()
            display.newSprite(string.format("home/%d.png", fromEntity:GetVipLevel())):addTo(self.vip_level)
        end
    end
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
    self.vip_level:removeAllChildren()
    display.newSprite(string.format("home/%d.png", user:GetVipLevel())):addTo(self.vip_level)
end


function GameUIHome:CreateTop()
    local top_bg = display.newSprite("top_bg_768x116.png"):addTo(self)
        :align(display.TOP_CENTER, display.cx, display.top )
    if display.width>640 then
        top_bg:scale(display.width/768)
    end

    -- 玩家按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/player_btn_up.png", pressed = "home/player_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI('GameUIVip', City,"info"):addToCurrentScene(true)
        end
    end):addTo(top_bg):align(display.LEFT_CENTER,top_bg:getContentSize().width/2-2, top_bg:getContentSize().height/2+10)
    button:setRotationSkewY(180)


    -- 玩家名字背景加文字
    local ox = 159
    local name_bg = display.newSprite("home/player_name_bg.png"):addTo(top_bg)
        :align(display.TOP_LEFT, ox, top_bg:getContentSize().height-10)
    self.name_label = cc.ui.UILabel.new({
        text = "",
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xf3f0b6)
    }):addTo(name_bg):align(display.LEFT_CENTER, 14, name_bg:getContentSize().height/2 + 3)

    -- 玩家战斗值图片
    display.newSprite("home/power.png"):addTo(top_bg):pos(ox + 20, 65)

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
        {normal = "home/player_btn_up.png", pressed = "home/player_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIResourceOverview",self.city):addToCurrentScene(true)
        end
    end):addTo(top_bg):align(display.LEFT_CENTER, top_bg:getContentSize().width/2+2, top_bg:getContentSize().height/2+10)

    -- 资源图片和文字
    local first_row = 18
    local first_col = 30
    local label_padding = 20
    local padding_width = 100
    local padding_height = 35
    for i, v in ipairs({
        {"home/res_wood.png", "wood_label"},
        {"home/res_stone.png", "stone_label"},
        {"home/res_citizen.png", "citizen_label"},
        {"home/res_food.png", "food_label"},
        {"home/res_iron.png", "iron_label"},
        {"home/res_coin.png", "coin_label"},
    }) do
        local row = i > 3 and 1 or 0
        local col = (i - 1) % 3
        local x, y = first_col + col * padding_width, first_row - (row * padding_height)
        display.newSprite(v[1]):addTo(button):pos(x, y):scale(i == 3 and 0.65 or 0.25)
        self[v[2]] =
            UIKit:ttfLabel({text = "",
                size = 18,
                color = 0xf3f0b6,
                shadow = true
            })
                :addTo(button):pos(x + label_padding, y)
    end

    -- 玩家信息背景
    local player_bg = display.newSprite("home/player_bg.png"):addTo(top_bg, 2)
        :align(display.LEFT_BOTTOM, display.width>640 and 58 or 64, 10)
    display.newSprite("home/player_icon.png"):addTo(player_bg):pos(55, 53)
    local level_bg = display.newSprite("home/level_bg.png"):addTo(player_bg):pos(55, 30)
    self.level_label = UIKit:ttfLabel({
        size = 20,
        color = 0xfff1cc,
        shadow = true,
    }):addTo(level_bg):align(display.CENTER, 37, 12)
    self.exp = display.newSprite("home/player_exp_bar.png"):addTo(player_bg):pos(55, 53)

    -- vip
    local vip_btn = cc.ui.UIPushButton.new(
        {normal = "home/vip_bg.png", pressed = "home/vip_bg.png"},
        {scale9 = false}
    ):addTo(top_bg):align(display.CENTER, ox + 195, 50)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIVip', City,"VIP"):addToCurrentScene(true)
            end
        end)
    self.vip_level = display.newNode():addTo(vip_btn):pos(-3, 15):scale(0.8)



    -- 宝石按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/gem_btn_up.png", pressed = "home/gem_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        UIKit:newGameUI('GameUIShop', City):addToCurrentScene(true)
    end):addTo(top_bg):pos(top_bg:getContentSize().width - 155, -16)
    display.newSprite("home/gem_1.png"):addTo(button):pos(60, 3)
    self.gem_label = UIKit:ttfLabel({
        size = 20,
        color = 0xffd200,
        shadow = true
    }):addTo(button):align(display.CENTER, -30, 8)

    -- 任务条
    local quest_bar_bg = cc.ui.UIPushButton.new(
        {normal = "home/quest_btn_up.png", pressed = "home/quest_btn_down.png"},
        {scale9 = false}
    ):addTo(top_bg):pos(255, -10):onButtonClicked(function(event)
        if self.quest_label:getString() == _("挖掘机技术哪家强?") then
            self.quest_label:setString(_("中国山东找蓝翔!"))
        else
            self.quest_label:setString(_("挖掘机技术哪家强?"))
        end
    end)
    display.newSprite("home/quest_icon.png"):addTo(quest_bar_bg):pos(-162, 0)
    self.quest_label = cc.ui.UILabel.new({text = "挖掘机技术哪家强?",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xfffeb3)})
        :addTo(quest_bar_bg):align(display.LEFT_CENTER, -120, 0)

    -- 礼物按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/gift.png", pressed = "home/gift.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIActivity",City):addToCurrentScene()
        end
    end):addTo(top_bg):pos(630, -81):scale(0.6)
    --帮助
    local button = cc.ui.UIPushButton.new(
        {normal = "buff_8_128x128.png", pressed = "buff_8_128x128.png"},
        {scale9 = false}
    )
    button:onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUITips",button):addToCurrentScene()
        end
    end):addTo(top_bg):pos(630, -181):scale(0.5)

    -- BUFF按钮
    local buff_button = cc.ui.UIPushButton.new(
        {normal = "buff_1_128x128.png", pressed = "buff_1_128x128.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI("GameUIBuff",self.city):addToCurrentScene()
        end
    end):addTo(self):pos(display.cx-280, display.top-260)
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
    cc.ui.UIImage.new("home/chat_btn.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width-60, 0)
    local index_1 = display.newSprite("chat_page_index_1.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2-10,chat_bg:getContentSize().height-10)
    local index_2 = display.newSprite("chat_page_index_2.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2+10,chat_bg:getContentSize().height-10)
    self.chat_bg = chat_bg

    local size = chat_bg:getContentSize()
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
                UIKit:newGameUI('GameUIChatChannel',"global"):addToCurrentScene(true)
            elseif event.pageIdx == 2 then
                UIKit:newGameUI('GameUIChatChannel',"alliance"):addToCurrentScene(true)
            end
        end
    end)
        :addTo(chat_bg)
    pv:setTouchEnabled(true)
    pv:setTouchSwallowEnabled(false)
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

    -- 底部按钮
    local first_row = 60
    local first_col = 240
    local label_padding = 20
    local padding_width = 100
    for i, v in ipairs({
        {"home/bottom_icon_1.png", _("任务")},
        {"home/bottom_icon_2.png", _("物品")},
        {"home/mail.png", _("邮件")},
        {"home/bottom_icon_4.png", _("联盟")},
        {"home/bottom_icon_2.png", _("更多")},
    }) do
        local col = i - 1
        local x, y = first_col + col * padding_width, first_row
        local button = WidgetPushButton.new({normal = v[1]})
            :onButtonClicked(handler(self, self.OnBottomButtonClicked))
            :setButtonLabel("normal",cc.ui.UILabel.new({text = v[2],
                size = 16,
                font = UIKit:getFontFilePath(),
                color = UIKit:hex2c3b(0xf5e8c4)}
            )
            )
            :setButtonLabelOffset(0, -40)
            :addTo(bottom_bg):pos(x, y)
            :scale(0.9)
        button:setTag(i)
    end

    -- 未读邮件或战报数量显示条
    self.mail_unread_num_bg = display.newSprite("home/mail_unread_bg.png"):addTo(bottom_bg):pos(460, first_row+20)
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
        {normal = "allianceHome/help.png", pressed = "allianceHome/help.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            if not Alliance_Manager:GetMyAlliance():IsDefault() then
                GameUIHelp.new():AddToCurrentScene()
            else
                FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("加入联盟才能激活帮助功能"))
                    :AddToCurrentScene()
            end
        end
    end):addTo(self):pos(display.cx+280, display.top-560)
    help_button:setVisible(not Alliance_Manager:GetMyAlliance():IsDefault())
    self.help_button = help_button
    return bottom_bg
end

function GameUIHome:OnBottomButtonClicked(event)
    local tag = event.target:getTag()
    if not tag then return end
    if tag == 4 then -- tag 4 = alliance button
        UIKit:newGameUI('GameUIAlliance'):addToCurrentScene(true)
    elseif tag == 3 then
        UIKit:newGameUI('GameUIMail',_("邮件"),self.city):addToCurrentScene(true)
    elseif tag == 2 then
        UIKit:newGameUI('GameUIItems',_("道具"),self.city):addToCurrentScene(true)
    elseif tag == 1 then
    elseif tag == 5 then
        UIKit:newGameUI('GameUISetting',self.city):addToCurrentScene(true)

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
            promise.reject("没有找到对应item")
        end
        return item
    end)
end

return GameUIHome













