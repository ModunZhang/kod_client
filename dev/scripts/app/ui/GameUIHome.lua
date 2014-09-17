
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
    self.gem_label:setString(GameUtils:formatNumber(gem_number))
end


function GameUIHome:ctor(city)
    GameUIHome.super.ctor(self)
    self.city = city
end

function GameUIHome:onEnter()
    GameUIHome.super.onEnter(self)
    local city = self.city
    -- 上背景
    local top_bg = display.newSprite("home/top_bg.png")
        :align(display.LEFT_TOP, display.left, display.top)
        :addTo(self)

    -- 玩家按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/player_btn_up.png", pressed = "home/player_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
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

    -- 资源按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/res_btn_up.png", pressed = "home/res_btn_down.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        NetManager:instantUpgradeBuildingByLocation(1, NOT_HANDLE)
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
    cc.ui.UILabel.new({text = "任务就是杀死你",
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
        NetManager:instantMakeBuildingMaterial(NOT_HANDLE)
    end):addTo(quest_bar_bg):pos(290, 20)
    local pos = button:getAnchorPointInPoints()
    display.newSprite("home/quest_hook.png"):addTo(button):pos(pos.x, pos.y)

    -- 礼物按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "home/gift.png", pressed = "home/gift.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        dump(event)
    end):addTo(top_bg):pos(592, -51):scale(0.6)

    -- 底部背景
    local bottom_bg = display.newSprite("home/bottom_bg.png")
        :align(display.LEFT_BOTTOM, display.left, display.bottom)
        :addTo(self)
    bottom_bg:setTouchEnabled(true)

    -- 聊天背景
    local chat_bg = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    chat_bg:setContentSize(640, 50)
    chat_bg:setTouchEnabled(true)
    chat_bg:addTo(bottom_bg):pos(0, bottom_bg:getContentSize().height)

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
        {"home/bottom_icon_4.png", _("部队")},
        {"home/bottom_icon_2.png", _("更多")},
    }) do
        local col = i - 1
        local x, y = first_col + col * padding_width, first_row
        local icon = display.newSprite(v[1]):addTo(bottom_bg):pos(x, y)
        local pos = icon:getAnchorPointInPoints()
        cc.ui.UILabel.new({text = v[2],
            size = 16,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xf5e8c4)})
            :addTo(icon):align(display.CENTER, pos.x, pos.y - 45)
    end

    -- 场景切换
    display.newSprite("home/toggle_bg.png"):addTo(bottom_bg):pos(91, 52)
    display.newSprite("home/toggle_gear.png"):addTo(bottom_bg):pos(106, 49)
    display.newSprite("home/toggle_map_bg.png"):addTo(bottom_bg):pos(58, 53)
    display.newSprite("home/toggle_point.png"):addTo(bottom_bg):pos(94, 89)
    display.newSprite("home/toggle_point.png"):addTo(bottom_bg):pos(94, 10)
    display.newSprite("home/toggle_arrow.png"):addTo(bottom_bg):pos(53, 51)
    display.newSprite("home/toggle_city.png"):addTo(bottom_bg):pos(52, 54)


    -- 更新数值
    local userdata = DataManager:getUserData()
    self.name_label:setString(userdata.basicInfo.name)
    self.power_label:setString(userdata.basicInfo.power)
    self.level_label:setString(userdata.basicInfo.level)
    self.vip_label:setString("VIP "..userdata.basicInfo.vip)

    city:GetResourceManager():AddObserver(self)
    city:GetResourceManager():OnResourceChanged()
end
function GameUIHome:onExit()
    self.city:GetResourceManager():RemoveObserver(self)
    GameUIHome.super.onExit(self)
end


return GameUIHome


