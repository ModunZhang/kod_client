local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local window = import("..utils.window")
local UIPageView = import("..ui.UIPageView")
local WidgetTab = import("..widget.WidgetTab")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local Arrow = import(".Arrow")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local GameUIHelp = import(".GameUIHelp")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local Alliance = import("..entity.Alliance")


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
    local gem_number = resource_manager:GetGemResource():GetValue()
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
end

function GameUIHome:onEnter()
    -- GameUIHome.super.onEnter(self)
    local city = self.city
    -- 上背景
    self:CreateTop()
    self.bottom = self:CreateBottom()
    self.event_tab = WidgetEventTabButtons.new(self.city)
    local rect1 = self.chat_bg:getCascadeBoundingBox()
    local rect2 = self.event_tab:getCascadeBoundingBox()
    local ratio = self.bottom:getScale()
    local x, y = rect1.x + rect1.width - rect2.width - 8 * ratio, rect1.y + rect1.height - 2 * ratio
    local line = display.newSprite("back_ground_492X14.png")
    line:addTo(self, 0):align(display.LEFT_TOP, x, y)
    self.event_tab:addTo(self, 0):pos(x, y)



    self:RefreshData()
    city:GetResourceManager():AddObserver(self)
    city:GetResourceManager():OnResourceChanged()
    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    Alliance_Manager:GetMyAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)

end
function GameUIHome:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
    MailManager:RemoveListenerOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    Alliance_Manager:GetMyAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    -- GameUIHome.super.onExit(self)
end
function GameUIHome:OnBasicChanged(alliance,changed_map)
    if changed_map.id then
        local flag = changed_map.id.new~=nil or changed_map.id.old~=""
        self.help_button:setVisible(flag)
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
    local userdata = DataManager:getUserData()
    self.name_label:setString(userdata.basicInfo.name)
    self.power_label:setString(userdata.basicInfo.power)
    self.level_label:setString(userdata.basicInfo.level)
    self.vip_label:setString("VIP 1")
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
    local name_bg = display.newSprite("home/player_name_bg.png"):addTo(top_bg)
        :align(display.TOP_RIGHT,top_bg:getContentSize().width/2, top_bg:getContentSize().height-10)
    self.name_label =
        cc.ui.UILabel.new({
            text = "有背",
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
            text = "2000000",
            size = 20,
            color = 0xf3f0b6,
            shadow = true
        }):addTo(top_bg):align(display.LEFT_CENTER, 194, 40)



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
            UIKit:ttfLabel({text = "2k",
                size = 18,
                color = 0xf3f0b6,
                shadow = true
            })
                :addTo(button):pos(x + label_padding, y)
    end
    -- 框
    -- display.newSprite("home/frame.png"):addTo(top_bg, 1):align(display.LEFT_TOP, 0, 200)

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
        UIKit:ttfLabel({text = "10000",
            size = 20,
            color = 0xfff1cc,
            shadow = true
        })
            :addTo(player_bg):align(display.CENTER, 61, 32)
    display.newSprite("home/player_exp_bar.png")
        :addTo(player_bg)
        :pos(61, 60)
    -- vip
    local vip_btn = cc.ui.UIPushButton.new(
        {normal = "home/vip_bg.png", pressed = "home/vip_bg.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            UIKit:newGameUI('GameUIVip', City,"VIP"):addToCurrentScene(true)
        end
    end):addTo(top_bg):align(display.LEFT_TOP, display.width>640 and 56 or 63, 33)

    self.vip_label =
        UIKit:ttfLabel({text = "VIP 1",
            size = 18,
            color = 0xe19319,
            shadow = true
        })
            :addTo(vip_btn):align(display.CENTER, 180, -25)



    -- 宝石按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/gem_btn_up.png", pressed = "home/gem_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        -- NetManager:sendMsg("gem 10000000", NOT_HANDLE)
        UIKit:newGameUI('GameUIShop', City):addToCurrentScene(true)
    end):addTo(top_bg):pos(596, 0)
    display.newSprite("home/gem_1.png"):addTo(button):pos(85, 0)
    -- display.newSprite("home/gem_num_bg.png"):addTo(button):pos(0, -27)
    self.gem_label =
        UIKit:ttfLabel({text = "10000000",
            size = 20,
            color = 0xffd200,
            shadow = true
        })
            :addTo(button):align(display.CENTER, 0, 0)

    -- 任务条
    local quest_bar_bg = display.newSprite("home/quest_bar_bg.png"):addTo(player_bg):pos(202, -62)
    quest_bar_bg:setTouchEnabled(true)
    local quest_bg = display.newSprite("home/quest_bg.png"):addTo(quest_bar_bg):pos(-15, 24)
    local pos = quest_bg:getAnchorPointInPoints()
    display.newSprite("home/quest_icon.png"):addTo(quest_bg):pos(pos.x, pos.y):scale(0.7)
    self.quest_label =
        cc.ui.UILabel.new({text = "挖掘机技术哪家强?",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0x3b3827)})
            :addTo(quest_bar_bg):align(display.LEFT_CENTER, 25, 18)
    display.newSprite("home/quest_info.png"):addTo(quest_bar_bg):pos(300, 20)

    local button = cc.ui.UIPushButton.new(
        {normal = "home/quest_btn_up.png", pressed = "home/quest_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        -- NetManager:instantMakeBuildingMaterial(NOT_HANDLE)
        if self.quest_label:getString() == _("挖掘机技术哪家强?") then
            self.quest_label:setString(_("中国山东找蓝翔!"))
        else
            self.quest_label:setString(_("挖掘机技术哪家强?"))
        end

    end):addTo(quest_bar_bg):pos(290, 20)
    local pos = button:getAnchorPointInPoints()
    display.newSprite("home/quest_hook.png"):addTo(button):pos(pos.x, pos.y)

    -- 礼物按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/gift.png", pressed = "home/gift.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        dump(event)
        if event.name == "CLICKED_EVENT" then
        end
    end):addTo(top_bg):pos(630, -81):scale(0.6)

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
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height-10)
        :addTo(bottom_bg)
    cc.ui.UIImage.new("home/chat_btn.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width-60, 0)
    local index_1 = display.newSprite("chat_page_index_1.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2-10,chat_bg:getContentSize().height-10)
    local index_2 = display.newSprite("chat_page_index_2.png"):addTo(chat_bg):pos(chat_bg:getContentSize().width/2+10,chat_bg:getContentSize().height-10)
    self.chat_bg = chat_bg

    local size = chat_bg:getContentSize()
    local pv = UIPageView.new {
        viewRect = cc.rect(10, 4, size.width, size.height)}
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
        app:enterScene("PVEScene", nil, "custom", -1, function(scene, status)
            local manager = ccs.ArmatureDataManager:getInstance()
            if status == "onEnter" then
                manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
                local armature = ccs.Armature:create("Cloud_Animation"):addTo(scene):pos(display.cx, display.cy)
                display.newColorLayer(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
                    transition.sequence{
                        cc.CallFunc:create(function() armature:getAnimation():play("Animation1", -1, 0) end),
                        cc.FadeIn:create(0.75),
                        cc.CallFunc:create(function() scene:hideOutShowIn() end),
                        cc.DelayTime:create(0.5),
                        cc.CallFunc:create(function() armature:getAnimation():play("Animation4", -1, 0) end),
                        cc.FadeOut:create(0.75),
                        cc.CallFunc:create(function() scene:finish() end),
                    }
                )
            elseif status == "onExit" then
                manager:removeArmatureFileInfo("animations/Cloud_Animation.ExportJson")
            end
        end)
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
    return cocos_promise.deffer(function()
        if not item then
            promise.reject("没有找到对应item")
        end
        return item
    end)
end

return GameUIHome







