local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local UIPageView = import("..ui.UIPageView")
local Flag = import("..entity.Flag")
local Alliance = import("..entity.Alliance")
local AllianceMoonGate = import("..entity.AllianceMoonGate")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local GameUIAllianceContribute = import(".GameUIAllianceContribute")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local GameUIHelp = import(".GameUIHelp")
local WidgetChangeMap = import("..widget.WidgetChangeMap")



local GameUIAllianceHome = UIKit:createUIClass('GameUIAllianceHome')


function GameUIAllianceHome:ctor(alliance)
    GameUIAllianceHome.super.ctor(self)
    self.alliance = alliance
end

function GameUIAllianceHome:onEnter()
    GameUIAllianceHome.super.onEnter(self)
    self.bottom = self:CreateBottom()
    self.top = self:CreateTop()
    if self.top then
        self.top:Refresh()
    end

    -- 中间按钮
    self:CreateOperationButton()

    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.ALLIANCE_FIGHT)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.FIGHT_REQUESTS)

    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)

    -- 添加到全局计时器中，以便显示各个阶段的时间
    app.timer:AddListener(self)
end

function GameUIAllianceHome:CreateOperationButton()
    local first_row = 220
    local first_col = 177
    local label_padding = 100
    for i, v in ipairs({
        -- {"allianceHome/enemy.png", _("敌方")},
        {"allianceHome/help.png", _("帮助")},
        {"allianceHome/war.png", _("战斗")},
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
            :addTo(self):pos(window.right-50, y)
        button:setTag(i)
        button:setTouchSwallowEnabled(true)
    end
end

function GameUIAllianceHome:onExit()
    app.timer:RemoveListener(self)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.ALLIANCE_FIGHT)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.FIGHT_REQUESTS)
    MailManager:RemoveListenerOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)

    GameUIAllianceHome.super.onExit(self)
end

function GameUIAllianceHome:TopBg()
    local top_bg = display.newSprite("allianceHome/alliance_home_top_bg.png")
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
    local top_self_bg = WidgetPushButton.new({normal = "allianceHome/button_blue_normal_314X88.png",
        pressed = "allianceHome/button_blue_pressed_314X88.png"})
        :onButtonClicked(handler(self, self.OnTopButtonClicked))
        :align(display.TOP_CENTER, t_size.width/2-160, t_size.height-4)
        :addTo(top_bg)
    local top_enemy_bg = WidgetPushButton.new({normal = "allianceHome/button_red_normal_314X88.png",
        pressed = "allianceHome/button_red_pressed_314X88.png"})
        :onButtonClicked(handler(self, self.OnTopButtonClicked))
        :align(display.TOP_CENTER, t_size.width/2+160, t_size.height-4)
        :addTo(top_bg)

    return top_self_bg,top_enemy_bg
end

function GameUIAllianceHome:TopTabButtons()

    -- 荣誉,忠诚,坐标,世界按钮背景框
    local btn_bg = display.newSprite("allianceHome/back_ground_676x100.png")
        :align(display.TOP_CENTER,self.top_bg:getContentSize().width/2,46)
        :addTo(self.top_bg)
    btn_bg:setTouchEnabled(true)
    -- 荣耀按钮
    local honour_btn = WidgetPushButton.new({normal = "allianceHome/btn_144x44.png",
        pressed = "allianceHome/btn_144x44_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceContribute'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 124, btn_bg:getContentSize().height/2-2)
        :addTo(btn_bg)
    -- 荣耀值
    display.newSprite("honour.png")
        :align(display.CENTER, -40,honour_btn:getContentSize().height/2-4)
        :addTo(honour_btn)
    UIKit:ttfLabel(
        {
            text = _("荣耀值"),
            size = 14,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, -15, honour_btn:getContentSize().height/2+10)
        :addTo(honour_btn)
    self.honour_label = UIKit:ttfLabel(
        {
            text = GameUtils:formatNumber(self.alliance:Honour()),
            size = 18,
            color = 0xf5e8c4
        }):align(display.LEFT_CENTER, -15, honour_btn:getContentSize().height/2-10)
        :addTo(honour_btn)
    -- 忠诚按钮
    local loyalty_btn = WidgetPushButton.new({normal = "allianceHome/btn_140x44.png",
        pressed = "allianceHome/btn_140x44_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceLoyalty'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 268, btn_bg:getContentSize().height/2-2)
        :addTo(btn_bg)
    -- 忠诚值
    display.newSprite("loyalty_1.png")
        :align(display.CENTER, -40,loyalty_btn:getContentSize().height/2-4)
        :addTo(loyalty_btn)
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
    local coordinate_btn = WidgetPushButton.new({normal = "allianceHome/btn_140x44.png",
        pressed = "allianceHome/btn_140x44_light.png"})
        :onButtonClicked(function ( event )
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAlliancePosition'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 412, btn_bg:getContentSize().height/2-2)
        :addTo(btn_bg)
    -- 坐标
    display.newSprite("allianceHome/coordinate.png")
        :align(display.CENTER, -40,coordinate_btn:getContentSize().height/2-4)
        :addTo(coordinate_btn)
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
    -- 世界按钮
    local world_btn = WidgetPushButton.new({normal = "allianceHome/btn_144x44.png",
        pressed = "allianceHome/btn_144x44_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceWorld'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 556, btn_bg:getContentSize().height/2-2)
        :addTo(btn_bg)
    world_btn:setRotationSkewY(180)
    -- 世界
    display.newSprite("allianceHome/world.png")
        :align(display.CENTER, btn_bg:getContentSize().width-150,btn_bg:getContentSize().height/2-4)
        :addTo(btn_bg)
    UIKit:ttfLabel(
        {
            text = _("世界"),
            size = 14,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, btn_bg:getContentSize().width-130, btn_bg:getContentSize().height/2+10)
        :addTo(btn_bg)
    local world_label = UIKit:ttfLabel(
        {
            text = "NO.9999",
            size = 18,
            color = 0xf5e8c4
        }):align(display.LEFT_CENTER, btn_bg:getContentSize().width-130, btn_bg:getContentSize().height/2-10)
        :addTo(btn_bg)

end

function GameUIAllianceHome:CreateTop()
    local alliance = self.alliance
    local Top = {}
    local top_self_bg,top_enemy_bg = self:TopBg()
    -- 己方联盟名字
    local self_name_bg = display.newSprite("allianceHome/title_green_292X32.png")
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
    local enemy_name_bg = display.newSprite("allianceHome/title_red_292X32.png")
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
    local period_bg = display.newSprite("allianceHome/box_104x104.png")
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
    local our_num_icon = cc.ui.UIImage.new("allianceHome/power.png"):align(display.CENTER, -107, -65):addTo(top_self_bg)
    local self_power_bg = display.newSprite("allianceHome/power_background.png")
        :align(display.LEFT_CENTER, -107, -65):addTo(top_self_bg)
    local self_power_label = UIKit:ttfLabel(
        {
            text = string.formatnumberthousands(alliance:Power()),
            size = 20,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 20, self_power_bg:getContentSize().height/2)
        :addTo(self_power_bg)
    -- 敌方战力
    local enemy_power_bg = display.newSprite("allianceHome/power_background.png")
        :align(display.LEFT_CENTER, -20, -65):addTo(top_enemy_bg)
    local enemy_num_icon = cc.ui.UIImage.new("allianceHome/power.png")
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
            if status=="fight"  then
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
                enemy_num_icon:setTexture("allianceHome/power.png")
                self:SetEnemyPowerOrKill(enemyAlliance:Power())
                enemy_num_icon:scale(1.0)
            else
                enemy_num_icon:setTexture("citizen_44x50.png")
                enemy_num_icon:scale(0.7)
                self:SetEnemyPowerOrKill(alliance:GetFightRequestPlayerNum())
            end
            our_num_icon:setTexture("allianceHome/power.png")
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
    -- -- 底部背景
    -- local bottom_bg = display.newSprite("bottom_bg_640x101.png")
    --     :align(display.CENTER, display.cx, display.bottom + 101/2)
    --     :addTo(self)
    -- bottom_bg:setTouchEnabled(true)

    -- -- 聊天背景
    -- local chat_bg = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    -- chat_bg:setContentSize(640, 50)
    -- chat_bg:setTouchEnabled(true)
    -- chat_bg:addTo(bottom_bg):pos(0, bottom_bg:getContentSize().height)
    -- chat_bg:setTouchSwallowEnabled(true)
    -- chat_bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
    --     if event.name == "began" then
    --         chat_bg.prevP = cc.p(event.x,event.y)
    --         return true
    --     elseif event.name == 'ended' then
    --         if cc.pGetDistance(chat_bg.prevP,cc.p(event.x,event.y)) <= 10 then
    --             UIKit:newGameUI('GameUIChat'):addToCurrentScene(true)
    --         end
    --     end
    -- end)
    -- local button = cc.ui.UIPushButton.new(
    --     {normal = "home/chat_btn.png", pressed = "home/chat_btn.png"},
    --     {scale9 = false}
    -- ):onButtonClicked(function(event)
    --     UIKit:newGameUI('GameUIChat'):addToCurrentScene(true)
    -- end):addTo(chat_bg):pos(31, 20)


    -- -- 底部按钮
    -- local first_row = 64
    -- local first_col = 177
    -- local label_padding = 20
    -- local padding_width = 100
    -- for i, v in ipairs({
    --     {"home/bottom_icon_1.png", _("任务")},
    --     {"home/bottom_icon_2.png", _("物品")},
    --     {"home/mail.png", _("邮件")},
    --     {"home/bottom_icon_4.png", _("联盟")},
    --     {"home/bottom_icon_2.png", _("更多")},
    -- }) do
    --     local col = i - 1
    --     local x, y = first_col + col * padding_width, first_row
    --     local button = WidgetPushButton.new({normal = v[1]})
    --         :onButtonClicked(handler(self, self.OnBottomButtonClicked))
    --         :setButtonLabel("normal",cc.ui.UILabel.new({text = v[2],
    --             size = 16,
    --             font = UIKit:getFontFilePath(),
    --             color = UIKit:hex2c3b(0xf5e8c4)}
    --         )
    --         )
    --         :setButtonLabelOffset(0, -40)
    --         :addTo(bottom_bg):pos(x, y)
    --     button:setTag(i)
    -- end

    -- -- 未读邮件或战报数量显示条
    -- self.mail_unread_num_bg = display.newSprite("home/mail_unread_bg.png"):addTo(bottom_bg):pos(400, first_row+20)
    -- self.mail_unread_num_label = cc.ui.UILabel.new(
    --     {cc.ui.UILabel.LABEL_TYPE_TTF,
    --         text = GameUtils:formatNumber(MailManager:GetUnReadMailsAndReportsNum()),
    --         font = UIKit:getFontFilePath(),
    --         size = 16,
    --         -- dimensions = cc.size(200,24),
    --         color = UIKit:hex2c3b(0xf5f2b3)
    --     }):align(display.CENTER,self.mail_unread_num_bg:getContentSize().width/2,self.mail_unread_num_bg:getContentSize().height/2+4)
    --     :addTo(self.mail_unread_num_bg)
    -- if MailManager:GetUnReadMailsAndReportsNum()==0 then
    --     self.mail_unread_num_bg:setVisible(false)
    -- end
    -- -- 场景切换
    -- display.newSprite("home/toggle_bg.png"):addTo(bottom_bg):pos(91, 52)
    -- display.newSprite("home/toggle_gear.png"):addTo(bottom_bg):pos(106, 49)
    -- display.newSprite("home/toggle_map_bg.png"):addTo(bottom_bg):pos(58, 53)
    -- display.newSprite("home/toggle_point.png"):addTo(bottom_bg):pos(94, 89)
    -- display.newSprite("home/toggle_point.png"):addTo(bottom_bg):pos(94, 10)
    -- local arrow = display.newSprite("toggle_arrow_103x104.png"):addTo(bottom_bg):pos(53, 51):rotation(90)
    -- WidgetPushButton.new(
    --     {normal = "toggle_city_89x97.png", pressed = "toggle_city_89x97.png"}
    -- ):addTo(bottom_bg)
    --     :pos(52, 54)
    --     :onButtonClicked(function(event)
    --         app:lockInput(true)
    --         transition.rotateTo(arrow, {
    --             rotate = 0,
    --             time = 0.2,
    --             onComplete = function()
    --                 app:lockInput(false)
    --                 app:enterScene("MyCityScene", {City}, "custom", -1, function(scene, status)
    --                     local manager = ccs.ArmatureDataManager:getInstance()
    --                     if status == "onEnter" then
    --                         manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
    --                         local armature = ccs.Armature:create("Cloud_Animation"):addTo(scene):pos(display.cx, display.cy)
    --                         display.newColorLayer(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
    --                             transition.sequence{
    --                                 cc.CallFunc:create(function() armature:getAnimation():play("Animation1", -1, 0) end),
    --                                 cc.FadeIn:create(0.75),
    --                                 cc.CallFunc:create(function() scene:hideOutShowIn() end),
    --                                 cc.DelayTime:create(0.5),
    --                                 cc.CallFunc:create(function() armature:getAnimation():play("Animation4", -1, 0) end),
    --                                 cc.FadeOut:create(0.75),
    --                                 cc.CallFunc:create(function() scene:finish() end),
    --                             }
    --                         )
    --                     elseif status == "onExit" then
    --                         manager:removeArmatureFileInfo("animations/Cloud_Animation.ExportJson")
    --                     end
    --                 end)
    --             end}
    --         )
    --     end)

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

    local size = chat_bg:getContentSize()
    local pv = UIPageView.new {
        viewRect =  cc.rect(10, 4, size.width-80, size.height)}
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
        UIKit:newGameUI("GameUIAllianceBattle",City):addToCurrentScene()
    end
end
function GameUIAllianceHome:OnBottomButtonClicked(event)
    local tag = event.target:getTag()
    if not tag then return end
    if tag == 4 then -- tag 4 = alliance button
        -- UIKit:newGameUI('GameUIAlliance'):addToCurrentScene(true)
        UIKit:newGameUI('GameUIShop', City):addToCurrentScene(true)
    elseif tag == 3 then
        UIKit:newGameUI('GameUIMail',_("邮件"),self.city):addToCurrentScene(true)
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
function GameUIAllianceHome:OnMemberChanged(alliance,changed_map)
    for i,v in pairs(changed_map.changed) do
        if v.id == DataManager:getUserData()._id then
            self.loyalty_label:setString(GameUtils:formatNumber(v.loyalty))
        end
    end
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













