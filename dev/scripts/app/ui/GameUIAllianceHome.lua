local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetEventTabButtons = import("..widget.WidgetEventTabButtons")
local Flag = import("..entity.Flag")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")

-- local MailManager = import("..entity.MailManager")
local GameUIAllianceHome = UIKit:createUIClass('GameUIAllianceHome')


function GameUIAllianceHome:ctor()
    GameUIAllianceHome.super.ctor(self)
    self.alliance = Alliance_Manager:GetMyAlliance()
end

function GameUIAllianceHome:onEnter()
    GameUIAllianceHome.super.onEnter(self)
    self.bottom = self:CreateBottom()
    self.bottom = self:CreateTop()
end

function GameUIAllianceHome:CreateTop()
    local alliance = self.alliance
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
    -- 荣誉,忠诚,坐标,世界按钮背景框
    local btn_bg = display.newSprite("allianceHome/back_ground_637x55.png")
        :align(display.TOP_CENTER, 0,-t_self_height)
        :addTo(top_self_bg)
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
    -- 敌方联盟旗帜
    local enemy_flag = ui_helper:CreateFlagContentSprite(alliance:Flag()):scale(0.5)
    enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
        :addTo(enemy_name_bg)
    -- 和平期,战争期,准备期背景
    local period_bg = display.newSprite("allianceHome/back_ground_123x102.png")
        :align(display.TOP_CENTER, 0,0)
        :addTo(top_enemy_bg)
    local vs = display.newSprite("allianceHome/VS_.png")
        :align(display.TOP_CENTER, period_bg:getContentSize().width/2,period_bg:getContentSize().height)
        :addTo(period_bg)

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
        {"home/bottom_icon_3.png", _("邮件")},
        {"home/bottom_icon_4.png", _("联盟")},
        {"home/mail.png", _("邮件")},
        {"home/bottom_icon_4.png", _("部队")},
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
            -- text = GameUtils:formatNumber(DataManager:GetManager("MailManager"):GetUnReadMailsAndReportsNum()),
            font = UIKit:getFontFilePath(),
            size = 16,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xf5f2b3)
        }):align(display.CENTER,self.mail_unread_num_bg:getContentSize().width/2,self.mail_unread_num_bg:getContentSize().height/2+4)
        :addTo(self.mail_unread_num_bg)
    -- if DataManager:GetManager("MailManager"):GetUnReadMailsAndReportsNum()==0 then
    -- self.mail_unread_num_bg:setVisible(false)
    -- end
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
                    app:enterScene("CityScene", nil, "custom", -1, function(scene, status)
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

return GameUIAllianceHome



