local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUICityInfo = UIKit:createUIClass('GameUICityInfo')


function GameUICityInfo:ctor(user)
    GameUICityInfo.super.ctor(self)
    self.user = user
end

function GameUICityInfo:onEnter()
    GameUICityInfo.super.onEnter(self)
    -- 上背景
    self:CreateTop()
    self.bottom = self:CreateBottom()
end
function GameUICityInfo:CreateTop()
    local top_bg = display.newSprite("top_bg_640x201.png"):addTo(self)
        :align(display.CENTER, display.cx, display.top - 201 / 2)

    -- 玩家按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/player_btn_up.png", pressed = "home/player_btn_down.png"},
        {scale9 = false}
    ):addTo(top_bg):align(display.LEFT_BOTTOM, 109, 106)


    -- 玩家名字背景加文字
    display.newSprite("home/player_name_bg.png"):addTo(button):pos(96, 65)
    self.name_label =
        cc.ui.UILabel.new({
            text = self.user:Name(),
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
            text = self.user:Power(),
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
            cc.ui.UILabel.new({text = "-",
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
        cc.ui.UILabel.new({text = self.user:Level(),
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
        cc.ui.UILabel.new({text = self.user:VipExp(),
            size = 18,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            valign = cc.ui.TEXT_VALIGN_CENTER,
            color = UIKit:hex2c3b(0xe19319)})
            :addTo(player_bg):align(display.LEFT_CENTER, 135, 15)

    return top_bg
end

function GameUICityInfo:CreateBottom()
    -- 底部背景
    local bottom_bg = display.newSprite("bottom_bg_640x101.png")
        :align(display.CENTER, display.cx, display.bottom + 101/2)
        :addTo(self)
    bottom_bg:setTouchEnabled(true)

    -- 说明
    cc.ui.UILabel.new({text = "您正在访问其他玩家的城市, 无法使用其他功能, 点击左下角返回区域地图",
            size = 20,
            font = UIKit:getFontFilePath(),
            align = cc.ui.TEXT_ALIGN_CENTER,
            valign = cc.ui.TEXT_VALIGN_CENTER,
            dimensions = cc.size(400, 100),
            color = UIKit:hex2c3b(0xe19319)})
            :addTo(bottom_bg):align(display.LEFT_CENTER, 150, display.bottom + 101/2)

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
    return bottom_bg
end
return GameUICityInfo









