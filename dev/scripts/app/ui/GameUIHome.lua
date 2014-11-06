local window = import("..utils.window")
local WidgetTab = import("..widget.WidgetTab")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local GameUIHelp = import(".GameUIHelp")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
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
    self.gem_label:setString(gem_number)
end


function GameUIHome:ctor(city)
    GameUIHome.super.ctor(self)
    self.city = city
end

function GameUIHome:onEnter()
    GameUIHome.super.onEnter(self)
    local city = self.city
    -- 上背景
    self:CreateTop()
    self.bottom = self:CreateBottom()



    self:RefreshData()
    city:GetResourceManager():AddObserver(self)
    city:GetResourceManager():OnResourceChanged()
    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)

end
function GameUIHome:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
    MailManager:RemoveListenerOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    GameUIHome.super.onExit(self)
end
function GameUIHome:MailUnreadChanged( num )
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
    self.name_label:setString(userdata.basicInfo.name.."id "..userdata.countInfo.deviceId)
    self.power_label:setString(userdata.basicInfo.power)
    self.level_label:setString(userdata.basicInfo.level)
    self.vip_label:setString("VIP 1")
end


function GameUIHome:CreateTop()
    local top_bg = display.newSprite("top_bg_640x201.png"):addTo(self)
        :align(display.CENTER, display.cx, display.top - 201 / 2)

    -- 玩家按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/player_btn_up.png", pressed = "home/player_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        -- NetManager:sendMsg("reset", NOT_HANDLE)
        NetManager:getSendGlobalMsgPromise("reset"):catch(function(err)
            dump(err:reason())
        end)
    end):addTo(top_bg):align(display.LEFT_BOTTOM, 109, 106)


    -- 玩家名字背景加文字
    display.newSprite("home/player_name_bg.png"):addTo(button):pos(96, 65)
    self.name_label =
        cc.ui.UILabel.new({
            text = "有背",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0xfff1cc)
        }):addTo(button)
            :align(display.LEFT_CENTER, 25, 68)

    -- 玩家战斗值图片
    display.newSprite("home/power.png"):addTo(button):pos(32, 37)

    -- 玩家战斗值文字
    cc.ui.UILabel.new({
        text = _("战斗值"),
        size = 14,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x9a946b)
    }):addTo(button):align(display.LEFT_CENTER, 46, 38)


    -- 玩家战斗值数字
    self.power_label =
        cc.ui.UILabel.new({
            text = "2000000",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_RIGHT,
            color = UIKit:hex2c3b(0x9a946b)
        }):addTo(button):align(display.LEFT_CENTER, 25, 16)



    -----------------------
    -- 资源按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/res_btn_up.png", pressed = "home/res_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        end):addTo(top_bg):align(display.LEFT_BOTTOM, 317, 106)

    -- 资源图片和文字
    local first_row = 60
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
            cc.ui.UILabel.new({text = "2k",
                size = 20,
                font = UIKit:getFontFilePath(),
                color = UIKit:hex2c3b(0xf3f0b6)})
                :addTo(button):pos(x + label_padding, y)
    end
    -- 框
    display.newSprite("home/frame.png"):addTo(top_bg, 1):align(display.LEFT_TOP, 0, 200)

    -- 玩家信息背景
    local player_bg = display.newSprite("home/player_bg.png")
        :addTo(top_bg, 2)
        :align(display.LEFT_TOP, 0, 200)
    display.newSprite("home/player_icon.png")
        :addTo(player_bg)
        :pos(60, 71)
        :setTouchEnabled(true)
    display.newSprite("home/level_bg.png")
        :addTo(player_bg)
        :pos(61, 33)
        :setTouchEnabled(true)
    self.level_label =
        cc.ui.UILabel.new({text = "10000",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0xfff1cc)})
            :addTo(player_bg):align(display.CENTER, 61, 32)
    display.newSprite("home/player_exp_bar.png")
        :addTo(player_bg)
        :pos(61, 53)
        :setTouchEnabled(true)
    self.vip_label =
        cc.ui.UILabel.new({text = "VIP 1",
            size = 18,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            valign = cc.ui.TEXT_VALIGN_CENTER,
            color = UIKit:hex2c3b(0xe19319)})
            :addTo(player_bg):align(display.LEFT_CENTER, 135, 15)



    -- 宝石按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/gem_btn_up.png", pressed = "home/gem_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        -- NetManager:sendMsg("gem 10000000", NOT_HANDLE)
        UIKit:newGameUI('GameUIShop', City):addToCurrentScene(true)
    end):addTo(top_bg):pos(596, 60)
    display.newSprite("home/gem.png"):addTo(button):pos(-1, 8)
    display.newSprite("home/gem_num_bg.png"):addTo(button):pos(0, -27)
    self.gem_label =
        cc.ui.UILabel.new({text = "10000000",
            size = 16,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            color = UIKit:hex2c3b(0xe19319)})
            :addTo(button):align(display.CENTER, 0, -25)

    -- 任务条
    local quest_bar_bg = display.newSprite("home/quest_bar_bg.png"):addTo(player_bg):pos(202, -32)
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
            UIKit:newGameUI('GameUIVip', City):addToCurrentScene(true)
            -- PushService:quitAlliance(NOT_HANDLE)
        end
    end):addTo(top_bg):pos(592, -51):scale(0.6)



    return top_bg
end

function GameUIHome:CreateBottom()
    -- 底部背景
    local bottom_bg = display.newSprite("bottom_bg_640x101.png")
        :align(display.CENTER, display.cx, display.bottom + 101/2)
        :addTo(self)
    bottom_bg:setTouchEnabled(true)

    -- 聊天背景
    local chat_bg = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    chat_bg:setContentSize(640, 50)
    chat_bg:setTouchEnabled(true)
    chat_bg:addTo(bottom_bg):pos(0, bottom_bg:getContentSize().height)
    chat_bg:setTouchSwallowEnabled(true)
    chat_bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            chat_bg.prevP = cc.p(event.x,event.y)
            return true
        elseif event.name == 'ended' then
            if cc.pGetDistance(chat_bg.prevP,cc.p(event.x,event.y)) <= 10 then
                UIKit:newGameUI('GameUIChat'):addToCurrentScene(true)
            end
        end
    end)
    local button = cc.ui.UIPushButton.new(
        {normal = "home/chat_btn.png", pressed = "home/chat_btn.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        UIKit:newGameUI('GameUIChat'):addToCurrentScene(true)
    end):addTo(chat_bg):pos(31, 20)


    local event = WidgetEventTabButtons.new(self.city)
        :addTo(bottom_bg):pos(bottom_bg:getContentSize().width - 491, bottom_bg:getContentSize().height + 50)


    -- 底部按钮
    local first_row = 64
    local first_col = 177
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
        button:setTag(i)
    end

    -- 未读邮件或战报数量显示条
    self.mail_unread_num_bg = display.newSprite("home/mail_unread_bg.png"):addTo(bottom_bg):pos(400, first_row+20)
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
    -- 场景切换
    display.newSprite("home/toggle_bg.png"):addTo(bottom_bg):pos(91, 52)
    display.newSprite("home/toggle_gear.png"):addTo(bottom_bg):pos(106, 49)
    display.newSprite("home/toggle_map_bg.png"):addTo(bottom_bg):pos(58, 53)
    display.newSprite("home/toggle_point.png"):addTo(bottom_bg):pos(94, 89)
    display.newSprite("home/toggle_point.png"):addTo(bottom_bg):pos(94, 10)
    local arrow = display.newSprite("toggle_arrow_103x104.png"):addTo(bottom_bg):pos(53, 51)
    WidgetPushButton.new(
        {normal = "toggle_city_89x97.png", pressed = "toggle_city_89x97.png"}
    ):addTo(bottom_bg)
        :pos(52, 54)
        :onButtonClicked(function(event)
            app:lockInput(true)
            transition.rotateTo(arrow, {
                rotate = 90,
                time = 0.2,
                onComplete = function()
                    app:lockInput(false)
                    app:enterScene("AllianceScene", nil, "custom", -1, function(scene, status)
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
                end}
            )
        end)

    -- 协助加速按钮
    local help_button = cc.ui.UIPushButton.new(
        {normal = "loyalty.png", pressed = "loyalty.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            if DataManager:GetManager("AllianceManager"):haveAlliance() then
                GameUIHelp.new():AddToCurrentScene()
            else
                FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("加入联盟才能激活帮助功能"))
                    :AddToCurrentScene()
            end
        end
    end):addTo(self):pos(display.cx+280, display.top-560)

    return bottom_bg
end

function GameUIHome:OnBottomButtonClicked(event)
    local tag = event.target:getTag()
    if not tag then return end
    if tag == 4 then -- tag 4 = alliance button
        UIKit:newGameUI('GameUIAlliance'):addToCurrentScene(true)
    elseif tag == 3 then
        UIKit:newGameUI('GameUIMail',_("邮件"),self.city):addToCurrentScene(true)
    elseif tag == 1 then
        UIKit:newGameUI('GameUIAlliancePalace',self.city,"upgarde"):addToCurrentScene(true)
    -- elseif tag == 2 then
    --     UIKit:newGameUI('GameUIAllianceShop',self.city,"upgarde"):addToCurrentScene(true)
    elseif tag == 5 then
        UIKit:newGameUI('GameUIAllianceEnter'):addToCurrentScene(true)
    elseif tag == 2 then
        UIKit:newGameUI('GameUIReplay'):addToCurrentScene(true)
    end
end

return GameUIHome







