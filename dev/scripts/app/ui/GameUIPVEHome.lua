local WidgetChangeMap = import("..widget.WidgetChangeMap")
local UIPageView = import("..ui.UIPageView")
local window = import("..utils.window")
local GameUIPVEHome = UIKit:createUIClass('GameUIPVEHome')

local timer = app.timer
function GameUIPVEHome:ctor(user)
    self.user = user
    GameUIPVEHome.super.ctor(self)
end
function GameUIPVEHome:onEnter()
    self:CreateTop()
    self:CreateBottom()
    self.user:AddListenOnType(self, self.user.LISTEN_TYPE.RESOURCE)
    self:OnResourceChanged(self.user)
end
function GameUIPVEHome:onExit()
    self.user:RemoveListenerOnType(self, self.user.LISTEN_TYPE.RESOURCE)
end
function GameUIPVEHome:OnResourceChanged(user)
    local strength_resouce = user:GetStrengthResource()
    local current_strength = strength_resouce:GetResourceValueByCurrentTime(timer:GetServerTime())
    local limit = strength_resouce:GetValueLimit()
    self.strenth:setString(string.format("%d/%d", current_strength, limit))
end
function GameUIPVEHome:CreateTop()
    local top_bg = display.newSprite("head_bg.png")
        :align(display.TOP_CENTER, window.cx, window.top)
        :addTo(self)
    top_bg:setTouchEnabled(true)
    cc.ui.UIPushButton.new(
        {normal = "return_btn_up_202x93.png", pressed = "return_btn_down_202x93.png"}
    ):addTo(top_bg)
        :align(display.CENTER, 117, -2)
        :onButtonClicked(function()
            print("返回")
        end):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("返回起点"),
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xffedae)})):setButtonLabelOffset(-20, 0)


    -- 宝石按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/gem_btn_up.png", pressed = "home/gem_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)end):addTo(top_bg):pos(window.right - 103, - 2)
    display.newSprite("home/gem_1.png"):addTo(button):pos(85, 0)
    self.gem_label = UIKit:ttfLabel({text = "100,100,100",
        size = 20,
        color = 0xffd200,
        shadow = true
    }):addTo(button):align(display.CENTER, 0, 0)

    self.title = UIKit:ttfLabel({text = "1. 贫瘠之地",
        size = 26,
        color = 0xffedae,
    }):addTo(top_bg):align(display.LEFT_CENTER, window.left + 30, 60)

    self.exploring = UIKit:ttfLabel({text = "探索度 100%",
        size = 20,
        color = 0xffedae,
    }):addTo(top_bg):align(display.RIGHT_CENTER, window.right - 30, 60)
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
    display.newSprite("Hero_1.png"):addTo(char_bg):pos(55, 55):scale(0.9)

    self.tag = UIKit:ttfLabel({text = string.format("[%s] %s", "", self.user:Name() and "gaozhou"),
        size = 20,
        color = 0xffedae,
    }):addTo(bottom_bg):align(display.LEFT_CENTER, 300, display.bottom + 65)

    display.newSprite("dragon_strength_27x31.png")
    :addTo(bottom_bg):align(display.CENTER, 310, display.bottom + 25)

    local label_bg = display.newSprite("label_background_146x25.png")
    :addTo(bottom_bg):align(display.LEFT_CENTER, 315, display.bottom + 25)

    self.gem = UIKit:ttfLabel({text = "9,999,999",
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
            print("hgell")
        end):scale(0.6)
    

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
        viewRect = cc.rect(10, 4, size.width-80, size.height)}
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
                    UIKit:newGameUI('GameUIChat',"global"):addToCurrentScene(true)
                elseif event.pageIdx == 2 then
                    UIKit:newGameUI('GameUIChat',"Alliance"):addToCurrentScene(true)
                end
            end
        end)
        :addTo(chat_bg)
    pv:setTouchEnabled(true)
    pv:setTouchSwallowEnabled(false)
    -- add items
    for i=1,2 do
        local item = pv:newItem()
        local content

        content = display.newLayer()
        content:setContentSize(540, 40)
        content:setTouchEnabled(false)
        local text_tag = i==1 and "世界聊天" or "联盟聊天"
        UIKit:ttfLabel(
            {text = text_tag,
                size = 24,
                color = 0xf3f0b6})
            :addTo(content)
            :align(display.CENTER, content:getContentSize().width/2, content:getContentSize().height/2)
        item:addChild(content)
        pv:addItem(item)
    end
    pv:reload()

    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE):addTo(self)
end



return GameUIPVEHome






