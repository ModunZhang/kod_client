local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local Flag = import("..entity.Flag")
local Alliance = import("..entity.Alliance")
local AllianceMoonGate = import("..entity.AllianceMoonGate")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local GameUIAllianceContribute = import(".GameUIAllianceContribute")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")


-- local MailManager = import("..entity.MailManager")
local GameUIAllianceHome = UIKit:createUIClass('GameUIAllianceHome')


function GameUIAllianceHome:ctor()
    GameUIAllianceHome.super.ctor(self)

    self.alliance = Alliance_Manager:GetMyAlliance()
    self.member = self.alliance:GetMemeberById(DataManager:getUserData()._id)
end

function GameUIAllianceHome:onEnter()
    GameUIAllianceHome.super.onEnter(self)
    self.bottom = self:CreateBottom()
    self.top = self:CreateTop()
    self.top:Refresh()

    -- 中间按钮
    self:CreateOperationButton()

    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.MEMBER)

    self.alliance:GetAllianceMoonGate():AddListenOnType(self, AllianceMoonGate.LISTEN_TYPE.OnCountDataChanged)

    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)

    -- 添加到全局计时器中，以便显示各个阶段的时间
    app.timer:AddListener(self)
end

function GameUIAllianceHome:CreateOperationButton()
    local first_row = 220
    local first_col = 177
    local label_padding = 100
    for i, v in ipairs({
        {"allianceHome/enemy.png", _("敌方")},
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
    MailManager:RemoveListenerOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    self.alliance:GetAllianceMoonGate():RemoveListenerOnType(self, AllianceMoonGate.LISTEN_TYPE.OnCountDataChanged)

    GameUIAllianceHome.super.onExit(self)
end

function GameUIAllianceHome:CreateTop()
    local alliance = self.alliance
    local Top = {}
    -- 顶部背景,为按钮
    local top_self_bg = WidgetPushButton.new({normal = "allianceHome/button_blue_normal_320X94.png",
        pressed = "allianceHome/button_blue_pressed_320X94.png"})
        :onButtonClicked(handler(self, self.OnTopButtonClicked))
        :align(display.TOP_RIGHT, window.cx, window.top)
        :addTo(self)
    top_self_bg:setTouchEnabled(true)
    top_self_bg:setTouchSwallowEnabled(true)
    local top_enemy_bg = WidgetPushButton.new({normal = "allianceHome/button_red_normal_320X94.png",
        pressed = "allianceHome/button_red_pressed_320X94.png"})
        :onButtonClicked(handler(self, self.OnTopButtonClicked))
        :align(display.TOP_LEFT, window.cx, window.top)
        :addTo(self)
    top_enemy_bg:setTouchEnabled(true)
    top_enemy_bg:setTouchSwallowEnabled(true)
    local t_self_width,t_self_height = top_self_bg:getCascadeBoundingBox().size.width,top_self_bg:getCascadeBoundingBox().size.height
    local t_enemy_width,t_enemy_height = top_enemy_bg:getCascadeBoundingBox().size.width,top_enemy_bg:getCascadeBoundingBox().size.height

    -- 己方联盟名字
    local self_name_bg = display.newSprite("allianceHome/title_green_292X32.png")
        :align(display.LEFT_CENTER, -t_self_width+10,-26)
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
        :align(display.RIGHT_CENTER, t_enemy_width-10,-26)
        :addTo(top_enemy_bg)
    local enemy_name_label = UIKit:ttfLabel(
        {
            text = "["..alliance:AliasName().."] "..alliance:Name(),
            size = 18,
            color = 0xffedae
        }):align(display.RIGHT_CENTER, enemy_name_bg:getContentSize().width-30, 20)
        :addTo(enemy_name_bg)
    local enemy_peace_label = UIKit:ttfLabel(
        {
            text = _("请求开战玩家"),
            size = 18,
            color = 0xffedae
        }):align(display.LEFT_CENTER, 140,-26)
        :addTo(top_enemy_bg)

    -- 和平期,战争期,准备期背景
    local period_bg = display.newSprite("allianceHome/back_ground_123x102.png")
        :align(display.TOP_CENTER, 0,0)
        :addTo(top_enemy_bg)
    local vs = display.newSprite("allianceHome/VS_.png")
        :align(display.TOP_CENTER, period_bg:getContentSize().width/2,period_bg:getContentSize().height)
        :addTo(period_bg)
    local time_bg = display.newSprite("allianceHome/back_ground_109x46.png")
        :align(display.BOTTOM_CENTER, period_bg:getContentSize().width/2,12)
        :addTo(period_bg)
    local period_text = self:GetAlliancePeriod()
    local period_label = UIKit:ttfLabel(
        {
            text = period_text,
            size = 16,
            color = 0xbdb582
        }):align(display.TOP_CENTER, time_bg:getContentSize().width/2, time_bg:getContentSize().height)
        :addTo(time_bg)
    self.time_label = UIKit:ttfLabel(
        {
            text = "",
            size = 18,
            color = 0xffedae
        }):align(display.BOTTOM_CENTER, time_bg:getContentSize().width/2, 0)
        :addTo(time_bg)
    -- 己方战力
    local our_num_icon = cc.ui.UIImage.new("allianceHome/power.png"):align(display.CENTER, -t_self_width+50, -65):addTo(top_self_bg)
    local self_power_bg = display.newSprite("allianceHome/power_background.png")
        :align(display.LEFT_CENTER, -t_self_width+50, -65):addTo(top_self_bg)
    local self_power_label = UIKit:ttfLabel(
        {
            text = string.formatnumberthousands(alliance:Power()),
            size = 20,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 20, self_power_bg:getContentSize().height/2)
        :addTo(self_power_bg)
    -- 敌方战力
    local enemy_power_bg = display.newSprite("allianceHome/power_background.png")
        :align(display.LEFT_CENTER, 140, -65):addTo(top_enemy_bg)
    local enemy_num_icon = cc.ui.UIImage.new("allianceHome/power.png")
        :align(display.CENTER, 0, enemy_power_bg:getContentSize().height/2)
        :addTo(enemy_power_bg)
    local enemy_power_label = UIKit:ttfLabel(
        {
            text = string.formatnumberthousands(alliance:Power()),
            size = 20,
            color = 0xbdb582
        }):align(display.LEFT_CENTER, 20, enemy_power_bg:getContentSize().height/2)
        :addTo(enemy_power_bg)

    -- 荣誉,忠诚,坐标,世界按钮背景框
    local btn_bg = display.newSprite("allianceHome/back_ground_637x55.png")
        :align(display.TOP_CENTER, window.cx,window.top-t_self_height)
        :addTo(self)
    btn_bg:setTouchEnabled(true)
    -- 荣耀按钮
    local honour_btn = WidgetPushButton.new({normal = "allianceHome/btn_142X42.png",
        pressed = "allianceHome/btn_142X42_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceContribute'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 102, btn_bg:getContentSize().height/2-2)
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
    local loyalty_btn = WidgetPushButton.new({normal = "allianceHome/btn_138X42.png",
        pressed = "allianceHome/btn_138X42_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceLoyalty'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 248, btn_bg:getContentSize().height/2-2)
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
    self.loyalty_label = UIKit:ttfLabel(
        {
            text = GameUtils:formatNumber(self.member:Loyalty()),
            size = 18,
            color = 0xf5e8c4
        }):align(display.LEFT_CENTER, -15, loyalty_btn:getContentSize().height/2-10)
        :addTo(loyalty_btn)
    -- 坐标按钮
    local coordinate_btn = WidgetPushButton.new({normal = "allianceHome/btn_138X42.png",
        pressed = "allianceHome/btn_138X42_light.png"})
        :onButtonClicked(function ( event )
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAlliancePosition'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 392, btn_bg:getContentSize().height/2-2)
        :addTo(btn_bg)
    -- 坐标
    display.newSprite("allianceHome/coordinate.png")
        :align(display.CENTER, -40,coordinate_btn:getContentSize().height/2-4)
        :addTo(coordinate_btn)
    UIKit:ttfLabel(
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
    local world_btn = WidgetPushButton.new({normal = "allianceHome/btn_142X42.png",
        pressed = "allianceHome/btn_142X42_light.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceWorld'):addToCurrentScene(true)
            end
        end)
        :align(display.CENTER, 536, btn_bg:getContentSize().height/2-2)
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
    MailManager:AddListenOnType(self,MailManager.LISTEN_TYPE.UNREAD_MAILS_CHANGED)
    local home = self
    function Top:Refresh()
        local alliance = home.alliance
        local status = alliance:Status()
        local moonGate = alliance:GetAllianceMoonGate()
        local enemyAlliance = moonGate:GetEnemyAlliance()
        period_label:setString(home:GetAlliancePeriod())
        -- 和平期
        if status=="peace" then
            enemy_name_bg:setVisible(false)
            vs:setVisible(false)
            enemy_peace_label:setVisible(true)
        else
            enemy_name_bg:setVisible(true)
            vs:setVisible(true)
            enemy_peace_label:setVisible(false)

            -- 敌方联盟旗帜
            if enemy_flag then
                enemy_name_bg:removeChildByTag(201, true)
            end
            local enemy_flag = ui_helper:CreateFlagContentSprite(Flag.new():DecodeFromJson(enemyAlliance.flag)):scale(0.5)
            enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
                :addTo(enemy_name_bg)
            enemy_flag:setTag(201)
            enemy_name_label:setString("["..enemyAlliance.tag.."] "..enemyAlliance.name)

        end
        if status=="fight" then
            our_num_icon:setTexture("battle_39x38.png")
            enemy_num_icon:setTexture("battle_39x38.png")
            enemy_num_icon:scale(1.0)
            self:SetOurPowerOrKill(moonGate:GetCountData().our.kill)
            self:SetEnemyPowerOrKill(moonGate:GetCountData().enemy.kill)
        else
            if status~="peace" then
                enemy_num_icon:setTexture("allianceHome/power.png")
                self:SetEnemyPowerOrKill(enemyAlliance.power)
                enemy_num_icon:scale(1.0)
            else
                enemy_num_icon:setTexture("citizen_44x50.png")
                enemy_num_icon:scale(0.7)
                self:SetEnemyPowerOrKill(0)
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


function GameUIAllianceHome:MailUnreadChanged( num )
    if num==0 then
        self.mail_unread_num_bg:setVisible(false)
    else
        self.mail_unread_num_bg:setVisible(true)
        self.mail_unread_num_label:setString(GameUtils:formatNumber(num))
    end
end
function GameUIAllianceHome:CreateBottom()
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
    local arrow = display.newSprite("toggle_arrow_103x104.png"):addTo(bottom_bg):pos(53, 51):rotation(90)
    WidgetPushButton.new(
        {normal = "toggle_city_89x97.png", pressed = "toggle_city_89x97.png"}
    ):addTo(bottom_bg)
        :pos(52, 54)
        :onButtonClicked(function(event)
            app:lockInput(true)
            transition.rotateTo(arrow, {
                rotate = 0,
                time = 0.2,
                onComplete = function()
                    app:lockInput(false)
                    app:enterScene("MyCityScene", {City}, "custom", -1, function(scene, status)
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

    return bottom_bg
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
    if tag == 3 then -- 战斗
        NetManager:getFindAllianceToFightPromose()
    elseif tag == 2 then

    elseif tag == 1 then
        local enemy_alliance_id = self.alliance:GetAllianceMoonGate():GetEnemyAlliance().id
        if enemy_alliance_id and string.trim(enemy_alliance_id) ~= "" then
            NetManager:getFtechAllianceViewDataPromose(enemy_alliance_id):next(function()
                app:lockInput(false)
                app:enterScene("EnemyAllianceScene", {Alliance_Manager:GetEnemyAlliance()}, "custom", -1, function(scene, status)
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
            end)
        else
            FullScreenPopDialogUI.new():SetTitle(_("提示"))
                :SetPopMessage(_("当前是和平期"))
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
function GameUIAllianceHome:OnSceneMove(logic_x, logic_y)
    self.coordinate_label:setString(logic_x..","..logic_y)
end
function GameUIAllianceHome:MailUnreadChanged( num )
    if num==0 then
        self.mail_unread_num_bg:setVisible(false)
    else
        self.mail_unread_num_bg:setVisible(true)
        self.mail_unread_num_label:setString(GameUtils:formatNumber(num))
    end
end

function GameUIAllianceHome:OnCountDataChanged(changed_map)
    local status = self.alliance:Status()
    if status=="fight" then
        if changed_map.our.kill then
            self.top:SetOurPowerOrKill(changed_map.our.kill.new)
        end
        if changed_map.enemy.kill then
            self.top:SetEnemyPowerOrKill(changed_map.enemy.kill.new)
        end
    end
end

function GameUIAllianceHome:OnTimer(current_time)
    local status = self.alliance:Status()
    if status ~= "peace" then
        local statusFinishTime = self.alliance:StatusFinishTime()
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

