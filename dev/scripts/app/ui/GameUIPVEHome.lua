local WidgetChangeMap = import("..widget.WidgetChangeMap")
local UIPageView = import("..ui.UIPageView")
local window = import("..utils.window")
local GameUIPVEHome = UIKit:createUIClass('GameUIPVEHome')
local WidgetUseItems = import("..widget.WidgetUseItems")
local RichText = import("..widget.RichText")
local ChatManager = import("..entity.ChatManager")
local timer = app.timer
function GameUIPVEHome:ctor(user, scene)
    self.user = user
    self.scene = scene
    self.layer = scene:GetSceneLayer()
    GameUIPVEHome.super.ctor(self)
    self.chatManager = app:GetChatManager()
end
function GameUIPVEHome:TO_TOP()
    self:RefreshChatMessage()
end
function GameUIPVEHome:TO_REFRESH()
    self:RefreshChatMessage()
end
function GameUIPVEHome:RefreshChatMessage()
    if not self.chat_labels then return end
    local last_chat_messages = self:GetChatManager():FetchLastChannelMessage()
    for i,v in ipairs(self.chat_labels) do
        local rich_text = self.chat_labels[i]
        rich_text:Text(last_chat_messages[i],1)
        rich_text:align(display.LEFT_CENTER, 0, 10)
    end
end
function GameUIPVEHome:GetChatManager()
    return self.chatManager
end
function GameUIPVEHome:onEnter()
    self:CreateTop()
    self:CreateBottom()
    self.user:AddListenOnType(self, self.user.LISTEN_TYPE.RESOURCE)
    self:OnResourceChanged(self.user)
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)

    self.layer:AddPVEListener(self)
    self.layer:NotifyExploring()
end
function GameUIPVEHome:onExit()
    self.layer:RemovePVEListener(self)
    self.user:RemoveListenerOnType(self, self.user.LISTEN_TYPE.RESOURCE)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_REFRESH)
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
end
function GameUIPVEHome:OnResourceChanged(user)
    local strength_resouce = user:GetStrengthResource()
    local current_strength = strength_resouce:GetResourceValueByCurrentTime(timer:GetServerTime())
    local limit = strength_resouce:GetValueLimit()
    self.strenth:setString(string.format("%d/%d", current_strength, limit))
    self.gem_label:setString(string.formatnumberthousands(user:GetGemResource():GetValue()))
end
function GameUIPVEHome:OnExploreChanged(pve_layer)
    self.exploring:setString(string.format("探索度 %.2f%%", pve_layer:ExploreDegree() * 100))
end
function GameUIPVEHome:CreateTop()
    local top_bg = display.newSprite("head_bg.png")
        :align(display.TOP_CENTER, window.cx, window.top)
        :addTo(self)
    local size = top_bg:getContentSize()
    top_bg:setTouchEnabled(true)

    cc.ui.UIPushButton.new(
        {normal = "return_btn_up_202x93.png", pressed = "return_btn_down_202x93.png"}
    ):addTo(top_bg)
        :align(display.LEFT_CENTER, 20, -5)
        :onButtonClicked(function()
            self.layer:ResetCharPos()
        end):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("返回起点"),
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xffedae)})):setButtonLabelOffset(-20, 0)


    -- 宝石按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up_196x68.png", pressed = "gem_btn_down_196x68.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        UIKit:newGameUI('GameUIShop', City):addToCurrentScene(true)
    end):addTo(top_bg):pos(top_bg:getContentSize().width - 130, -16)
    display.newSprite("gem_icon_62x61.png"):addTo(button):pos(60, 3)
    self.gem_label = UIKit:ttfLabel({
        size = 20,
        color = 0xffd200,
        shadow = true,
    }):addTo(button):align(display.CENTER, -30, 8)


    self.title = UIKit:ttfLabel({
        text = string.format("%d, %s", self.layer:CurrentPVEMap():GetIndex(), self.layer:CurrentPVEMap():Name()),
        size = 26,
        color = 0xffedae,
    }):addTo(top_bg):align(display.LEFT_CENTER, 60, 60)

    self.exploring = UIKit:ttfLabel({
        size = 20,
        color = 0xffedae,
    }):addTo(top_bg):align(display.RIGHT_CENTER, size.width - 60, 60)
end

function GameUIPVEHome:CreateBottom()
    -- 底部背景
    local bottom_bg = display.newSprite("bottom_bg_768x136.png")
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)
        :addTo(self)
    bottom_bg:setTouchEnabled(true)
    if display.width >640 then
        bottom_bg:scale(display.width/768)
    end


    local char_bg = display.newSprite("chat_hero_background.png")
    :addTo(bottom_bg, 1):pos(250, display.bottom + 50):scale(0.65)
    display.newSprite("playerIcon_default.png"):addTo(char_bg):pos(55, 55):scale(0.9)
    local alliance_name = Alliance_Manager:GetMyAlliance():IsDefault() and "" or Alliance_Manager:GetMyAlliance():Name()
    self.tag = UIKit:ttfLabel({text = string.format("[%s] %s", alliance_name, self.user:Name()),
        size = 20,
        color = 0xffedae,
    }):addTo(bottom_bg):align(display.LEFT_CENTER, 300, display.bottom + 65)

    display.newSprite("dragon_strength_27x31.png")
    :addTo(bottom_bg):align(display.CENTER, 310, display.bottom + 25)

    local label_bg = display.newSprite("label_background_146x25.png")
    :addTo(bottom_bg):align(display.LEFT_CENTER, 315, display.bottom + 25)

    self.gem = UIKit:ttfLabel({
        text = self.user:Power(),
        size = 20,
        color = 0xbdb582,
    }):addTo(label_bg):align(display.LEFT_CENTER, 20, 13)



    display.newSprite("dragon_lv_icon.png"):scale(0.8)
    :addTo(bottom_bg, 1):align(display.CENTER, 510, display.bottom + 25)

    local label_bg = display.newSprite("label_background_146x25.png")
    :addTo(bottom_bg):align(display.LEFT_CENTER, 515, display.bottom + 25)

    self.strenth = UIKit:ttfLabel({text = "",
        size = 20,
        color = 0xbdb582,
    }):addTo(label_bg):align(display.LEFT_CENTER, 20, 13)

    cc.ui.UIPushButton.new(
        {normal = "add_btn_up_50x50.png",pressed = "add_btn_down_50x50.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(label_bg)
        :align(display.CENTER, 131, 13)
        :onButtonClicked(function ( event )
            WidgetUseItems.new():Create({
                        item_type = WidgetUseItems.USE_TYPE.STAMINA
                    }):addToCurrentScene()
        end):scale(0.6)
    

    -- 聊天背景
    local chat_bg = display.newSprite("chat_background.png")
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height-10)
        :addTo(bottom_bg)
    cc.ui.UIImage.new("chat_btn_60x48.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width-60, 0)
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
    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE):addTo(self)
end



return GameUIPVEHome






