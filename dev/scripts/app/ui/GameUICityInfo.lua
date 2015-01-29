local window = import("..utils.window")
local UIPageView = import("..ui.UIPageView")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUICityInfo = UIKit:createUIClass('GameUICityInfo')
local RichText = import("..widget.RichText")
local ChatManager = import("..entity.ChatManager")

function GameUICityInfo:ctor(user)
    GameUICityInfo.super.ctor(self)
    self.user = user
    self.chatManager = app:GetChatManager()
end

function GameUICityInfo:GetChatManager()
    return self.chatManager
end

function GameUICityInfo:TO_TOP()
    self:RefreshChatMessage()
end

function GameUICityInfo:TO_REFRESH()
    self:RefreshChatMessage()
end

function GameUICityInfo:RefreshChatMessage()
    if not self.chat_labels then return end
    local last_chat_messages = self:GetChatManager():FetchLastChannelMessage()
    for i,v in ipairs(self.chat_labels) do
        local rich_text = self.chat_labels[i]
        rich_text:Text(last_chat_messages[i],1)
        rich_text:align(display.LEFT_CENTER, 0, 10)
    end
end

function GameUICityInfo:onEnter()
    GameUICityInfo.super.onEnter(self)
    self:CreateTop()
    self:CreateBottom()
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
end
function GameUICityInfo:onExit()
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
    GameUICityInfo.super.onExit(self)
end
function GameUICityInfo:CreateTop()
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

        end):addTo(top_bg):align(display.LEFT_CENTER,top_bg:getContentSize().width/2-2, top_bg:getContentSize().height/2+10)
    button:setRotationSkewY(180)

    -- 玩家名字背景加文字
    local name_bg = display.newSprite("home/player_name_bg.png"):addTo(top_bg)
        :align(display.TOP_RIGHT,top_bg:getContentSize().width/2, top_bg:getContentSize().height-10)
    self.name_label =
        cc.ui.UILabel.new({
            text = self.user:Name(),
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0xf3f0b6)
        }):addTo(name_bg)
            :align(display.LEFT_CENTER, 20, name_bg:getContentSize().height/2+5)

    -- 玩家战斗值图片
    display.newSprite("home/power.png"):addTo(top_bg):pos(194, 60)

    -- 玩家战斗值文字
    UIKit:ttfLabel({
        text = _("战斗值"),
        size = 14,
        color = 0x9a946b,
        shadow = true
    }):addTo(top_bg):align(display.LEFT_CENTER, 204, 60)


    -- 玩家战斗值数字
    self.power_label =
        UIKit:ttfLabel({
            text = self.user:Power(),
            size = 20,
            color = 0xf3f0b6,
            shadow = true
        }):addTo(top_bg):align(display.LEFT_CENTER, 194, 40)

    -- 资源按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/player_btn_up.png", pressed = "home/player_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)

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
            UIKit:ttfLabel({text = "-",
                size = 18,
                color = 0xf3f0b6,
                shadow = true
            })
                :addTo(button):pos(x + label_padding, y)
    end


    -- 玩家信息背景
    local player_bg = display.newSprite("home/player_bg.png")
        :addTo(top_bg, 2)
        :align(display.LEFT_BOTTOM, display.width>640 and 58 or 64, 0)

    display.newSprite("home/player_icon.png")
        :addTo(player_bg)
        :pos(60, 71)
    display.newSprite("home/level_bg.png")
        :addTo(player_bg)
        :pos(61, 33)
    self.level_label =
        UIKit:ttfLabel({text = self.user:Level(),
            size = 20,
            color = 0xfff1cc,
            shadow = true
        }):addTo(player_bg):align(display.CENTER, 61, 32)
    display.newSprite("home/player_exp_bar.png")
        :addTo(player_bg)
        :pos(61, 60)



    -- vip
    local vip_btn = cc.ui.UIPushButton.new(
        {normal = "home/vip_bg.png", pressed = "home/vip_bg.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)

        end):addTo(top_bg):align(display.LEFT_TOP, display.width>640 and 56 or 63, 33)

    self.vip_label =
        UIKit:ttfLabel({text = string.format("VIP %d", 1),
            size = 18,
            color = 0xe19319,
            shadow = true
        }):addTo(vip_btn):align(display.CENTER, 180, -25)

    return top_bg
end


function GameUICityInfo:CreateBottom()
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
    cc.ui.UIImage.new("home/chat_btn.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width-60, 0)
    local index_1 = display.newSprite("chat_page_index_1.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2-10,chat_bg:getContentSize().height-10)
    local index_2 = display.newSprite("chat_page_index_2.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2+10,chat_bg:getContentSize().height-10)
    self.chat_bg = chat_bg

    local size = chat_bg:getContentSize()
    local pv = UIPageView.new {
        viewRect = cc.rect(10, 4, size.width-80, size.height),
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


    cc.ui.UILabel.new({text = "您正在访问其他玩家的城市, 无法使用其他功能, 点击左下角返回城市",
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_CENTER,
        valign = cc.ui.TEXT_VALIGN_CENTER,
        dimensions = cc.size(400, 100),
        color = UIKit:hex2c3b(0xe19319)})
        :addTo(bottom_bg):align(display.LEFT_CENTER, 250, display.bottom + 101/2)

    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE):addTo(self)
end

return GameUICityInfo













