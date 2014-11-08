local Localize = import("..utils.Localize")
local window = import("..utils.window")
local promise = import("..utils.promise")
local BattleObject = import(".BattleObject")
local Wall = import(".Wall")
local Corps = import(".Corps")
local UILib = import(".UILib")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetProgress = import("..widget.WidgetProgress")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSoldierInBattle = import("..widget.WidgetSoldierInBattle")
local GameUIReplay = UIKit:createUIClass('GameUIReplay')

local new_battle = {
    {
        dual = {
            left = {soldier = "ranger", count = 1000, damage = 90, morale = 100, decrease = 20},
            right = {soldier = "lancer", count = 100, damage = 80, morale = 100, decrease = 80},
            defeat = "right"
        }
    },
    {
        dual = {
            left = {damage = 90, decrease = 10},
            right = {soldier = "ranger", count = 100, damage = 80, morale = 100, decrease = 50},
            defeat = "right"
        }
    },
    {
        dual = {
            left = {damage = 90, decrease = 30},
            right = {soldier = "wall", count = 1000, damage = 80, morale = 100, decrease = 90},
            defeat = "right"
        }
    },
}
local function decode_battle(raw)
    local rounds = {}
    for i, v in ipairs(raw) do
        local r = {}
        local dual = v.dual
        local left, right = dual.left, dual.right
        if i == 1 then
            table.insert(r, {
                {soldier = left.soldier, state = "enter", count = left.count, morale = left.morale},
                {soldier = right.soldier, state = "enter", count = right.count, morale = right.morale}
            })
        else
            if left.soldier then
                local soldier = left.soldier
                local count = left.count
                local morale = left.morale
                if soldier == "wall" then
                    table.insert(r, {
                        {soldier = soldier, state = "enter", count = count, morale = morale}, {state = "move"}
                    })
                else
                    table.insert(r, {
                        {soldier = soldier, state = "enter", count = count, morale = morale}, {state = "defend"}
                    })
                end
            elseif right.soldier then
                local soldier = right.soldier
                local count = right.count
                local morale = right.morale
                if soldier == "wall" then
                    table.insert(r, {
                        {state = "move"}, {soldier = soldier, state = "enter", count = count, morale = morale}
                    })
                else
                    table.insert(r, {
                        {state = "defend"}, {soldier = soldier, state = "enter", count = count, morale = morale}
                    })
                end
            else
                assert(false)
            end
        end
        if dual.defeat == "left" then
            table.insert(r, {{state = "attack"}, {state = "defend"}})
            table.insert(r, {{state = "defend"}, {state = "hurt", damage = right.damage, decrease = right.decrease}})
            table.insert(r, {{state = "defend"}, {state = "attack"}})
            table.insert(r, {{state = "hurt", damage = left.damage, decrease = left.decrease}, {state = "defend"}})
            table.insert(r, {{state = "defeat"}, {state = "defend"}})
        elseif dual.defeat == "right" then
            table.insert(r, {{state = "defend"}, {state = "attack"}})
            table.insert(r, {{state = "hurt", damage = left.damage, decrease = left.decrease}, {state = "defend"}})
            table.insert(r, {{state = "attack"}, {state = "defend"}})
            table.insert(r, {{state = "defend"}, {state = "hurt", damage = right.damage, decrease = right.decrease}})
            table.insert(r, {{state = "defend"}, {state = "defeat"}})
        else
            assert(false)
        end
        table.insert(rounds, r)
    end
    return rounds
end

function GameUIReplay:ctor()
    GameUIReplay.super.ctor(self)
    for _, v in pairs{
        {"animations/Archer_1_render0.plist","animations/Archer_1_render0.png"},
        {"animations/Catapult_1_render0.plist","animations/Catapult_1_render0.png"},
        {"animations/Cavalry_1_render0.plist","animations/Cavalry_1_render0.png"},
        {"animations/Infantry_1_render0.plist","animations/Infantry_1_render0.png"},
    } do
        display.addSpriteFrames(unpack(v))
    end
    local manager = ccs.ArmatureDataManager:getInstance()
    for _, anis in pairs(UILib.soldier_animation_files) do
        for _, v in pairs(anis) do
            manager:addArmatureFileInfo(v)
        end
    end
end
function GameUIReplay:onExit()
    GameUIReplay.super.onExit(self)
    for _, v in pairs{
        {"animations/Archer_1_render0.plist","animations/Archer_1_render0.png"},
        {"animations/Catapult_1_render0.plist","animations/Catapult_1_render0.png"},
        {"animations/Cavalry_1_render0.plist","animations/Cavalry_1_render0.png"},
        {"animations/Infantry_1_render0.plist","animations/Infantry_1_render0.png"},
    } do
        display.removeSpriteFramesWithFile(unpack(v))
    end
end
function GameUIReplay:onEnter()
    GameUIReplay.super.onEnter(self)
    display.newColorLayer(UIKit:hex2c4b(0x7a000000)):addTo(self)
    local back_width = 608
    local back_width_half = back_width / 2
    local back_height = 938
    local back_height_half = back_height / 2
    -- 背景
    local back_ground = WidgetUIBackGround.new({height = back_height})
        :addTo(self):align(display.CENTER, window.cx, window.cy)



    local rect = cc.rect(back_width_half - 590/2, back_height - 388 - 10, 590, 388)
    local clip = display.newClippingRegionNode(rect):addTo(back_ground)

    local battle = display.newNode():addTo(clip)
        :pos(back_width_half - 590/2, back_height - 388 - 10)
    self.battle = battle
    local battle_bg = cc.ui.UIImage.new("battle_bg_grass_772x388.png")
        :addTo(battle):align(display.CENTER, rect.width / 2, rect.height / 2)
    self.battle_bg = battle_bg




    -- 按钮
    WidgetPushButton.new(
        {normal = "yellow_btn_up_149x47.png",pressed = "yellow_btn_down_149x47.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("关闭"),
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(back_ground):align(display.CENTER, back_width - 100, 50)
        :onButtonClicked(function(event)
            self:leftButtonClicked()
        end)


    -- title
    local player_name = cc.ui.UIImage.new("background_288x60.png")
        :addTo(back_ground):pos(5, back_height - 65)
    cc.ui.UILabel.new({
        text = "playerName1",
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, 288/2, 60/2)
        :addTo(player_name)
    local player_name = cc.ui.UIImage.new("background_288x60.png")
        :addTo(back_ground):pos(back_width - 288 - 5, back_height - 65):flipX(true)
    cc.ui.UILabel.new({
        text = "playerName2",
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, 288/2, 60/2)
        :addTo(player_name)

    local unit_bg = cc.ui.UIImage.new("unit_name_bg_blue_276x48.png")
        :addTo(back_ground):pos(7, back_height - 65 - 39)
    self.left_soldier = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER, 276/2, 48/2)
        :addTo(unit_bg)

    local unit_bg = cc.ui.UIImage.new("unit_name_bg_red_276x48.png")
        :addTo(back_ground):pos(back_width - 276 - 7, back_height - 65 - 39)
    self.right_soldier = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER, 276/2, 48/2)
        :addTo(unit_bg)


    local vs_background_114x114 = cc.ui.UIImage.new("vs_background_114x114.png")
        :addTo(back_ground):align(display.CENTER, back_width_half, back_height - 114/2)
    cc.ui.UIImage.new("vs_73x47.png")
        :addTo(vs_background_114x114):align(display.CENTER, 114/2, 114/2)


    local unit_info_bg = cc.ui.UIImage.new("background_blue_342x70.png")
        :addTo(back_ground):align(display.LEFT_TOP, 10, back_height - 388 - 13)
    self.left_count = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER, 10, 53)
        :addTo(unit_info_bg)

    self.left_category = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.RIGHT_CENTER, 240, 53)
        :addTo(unit_info_bg)


    local progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), "progress_bg_224x30.png", "progress_224x30.png", {
        icon_bg = "icon_bg_38x40.png",
        icon = "icon_32x34.png",
        bar_pos = {x = 0,y = 0}
    }):addTo(unit_info_bg):align(display.LEFT_CENTER, 20, 20)
    -- progress:SetProgressInfo("", 100)

    self.left_progress = progress

    self.left_morale = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER, 50, 20)
        :addTo(unit_info_bg)

    local unit_info_bg = cc.ui.UIImage.new("background_red_342x70.png")
        :addTo(back_ground):align(display.RIGHT_TOP, back_width - 10, back_height - 388 - 13)

    self.right_count = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.RIGHT_CENTER, 342 - 10, 53)
        :addTo(unit_info_bg)

    self.right_category = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER, 342 - 240, 53)
        :addTo(unit_info_bg)

    local progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), "progress_bg_224x30.png", "progress_224x30.png", {
        icon_bg = "icon_bg_38x40.png",
        icon = "icon_32x34.png",
        bar_pos = {x = 0,y = 0}
    }):addTo(unit_info_bg):align(display.LEFT_CENTER, 342 - 20, 20)
    progress:SetProgressInfo("", 50)
    progress:setScaleX(-1)
    self.right_progress = progress

    self.right_morale = cc.ui.UILabel.new({
        text = "",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.RIGHT_CENTER, 342 - 50, 20)
        :addTo(unit_info_bg)

    cc.ui.UIImage.new("line_600x30.png")
        :addTo(back_ground):align(display.CENTER, back_width_half, back_height - 388)
    local bg = cc.ui.UIImage.new("back_ground_82x82.png")
        :addTo(back_ground):align(display.CENTER, back_width_half, back_height - 388 - 48)

    local x, y = bg:getPosition()
    self.list_view = self:CreateVerticalListViewDetached(0, 80, back_ground:getContentSize().width, y - 82 / 2):addTo(back_ground)
    self.left_corps = {}
    self.right_corps = {}
    self.left_round = 0
    self.right_round = 0
    for i, v in pairs(new_battle) do
        local item, left, right = self:CreateItemWithListView(self.list_view, v.dual)
        table.insert(self.left_corps, left)
        table.insert(self.right_corps, right)
        self.list_view:addItem(item)
    end
    self.list_view:reload():resetPosition()


    self.left_morale_max = 0
    self.right_morale_max = 0
    self.left_morale_cur = self.left_morale_max
    self.right_morale_cur = self.right_morale_max

    local rounds = promise.new()
    for i, round in ipairs(decode_battle(new_battle)) do
        rounds:next(function()
            local pa
            for _, v in ipairs(round) do
                local left, right = unpack(v)
                local left_action = self:DecodeStateBySide(left, true)
                local right_action = self:DecodeStateBySide(right, false)
                if not pa then
                    pa = promise.all(left_action:resolve(self.left), right_action:resolve(self.right))
                else
                    pa:next(function(result)
                        local left, right = unpack(result)
                        return promise.all(left_action:resolve(left), right_action:resolve(right))
                    end)
                end
            end
            return pa
        end)
    end
    rounds:resolve()
end
function GameUIReplay:MoveBattleBgBy(x)
    return function(battle_bg)
        local p = promise.new()
        transition.moveBy(battle_bg, {
            x = x, y = 0, time = 1,
            onComplete = function()
                p:resolve(battle_bg)
            end
        })
        return p
    end
end
function GameUIReplay:NewWall(x)
    return Wall.new():addTo(self.battle_bg):pos(x, 150)
end
function GameUIReplay:NewCorps(soldier, x, y)
    local soldier_arrange = {
        swordsman = {row = 4, col = 2},
        ranger = {row = 4, col = 2},
        lancer = {row = 3, col = 1},
        catapult = {row = 2, col = 1},
    }
    local arrange = soldier_arrange[soldier]
    return Corps.new(soldier, arrange.row, arrange.col):addTo(self.battle):pos(x, y)
end
function GameUIReplay:DecodeStateBySide(side, is_left)
    local height = 90
    local len = 200
    local left_start = {x = -100, y = height}
    local left_end = {x = left_start.x + len, y = height}
    local right_start = {x = 700, y = height}
    local right_end = {x = right_start.x - len, y = height}
    local action
    local state = side.state
    if state == "enter" then
        if is_left then
            if side.soldier == "wall" then
                self.left = self:NewWall(50)
                action = promise.new(function(wall)
                    self:NextSoldierBySide("left")
                    return wall
                end):next(BattleObject:TurnRight()):next(function()
                    return promise.new(GameUIReplay:MoveBattleBgBy(90))
                        :next(function()
                            return self.left
                        end):resolve(self.battle_bg)
                end)
            else
                self.left = self:NewCorps(side.soldier, left_start.x, left_start.y)
                action = BattleObject:Do(function(corps)
                    self:NextSoldierBySide("left")
                    return corps
                end):next(BattleObject:MoveTo(left_end.x, left_end.y, 2))
                    :next(BattleObject:BreathForever())
            end
            self.left_category:setString(Localize.getSoldierCategoryByName(side.soldier))
            self.left_soldier:setString(Localize.soldier_name[side.soldier])
            self.left_count:setString(side.count)

            self.left_morale_max = side.morale
            self.left_morale_cur = self.left_morale_max
            local percent = (self.left_morale_cur / self.left_morale_max) * 100
            self.left_morale:setString(percent.."%")
            self.left_progress:SetProgressInfo("", percent)
        else
            if side.soldier == "wall" then
                self.right = self:NewWall(730)
                action = promise.new(function(wall)
                    self:NextSoldierBySide("right")
                    return wall
                end):next(BattleObject:TurnLeft()):next(function()
                    return promise.new(GameUIReplay:MoveBattleBgBy(-90))
                        :next(function()
                            return self.right
                        end):resolve(self.battle_bg)
                end)
            else
                self.right = self:NewCorps(side.soldier, right_start.x, right_start.y)
                action = BattleObject:Do(function(corps)
                    self:NextSoldierBySide("right")
                    return corps
                end):next(BattleObject:TurnLeft())
                    :next(BattleObject:MoveTo(right_end.x, right_end.y, 2))
                    :next(BattleObject:BreathForever())
            end
            self.right_category:setString(Localize.getSoldierCategoryByName(side.soldier))
            self.right_soldier:setString(Localize.soldier_name[side.soldier])
            self.right_count:setString(side.count)

            self.right_morale_max = side.morale
            self.right_morale_cur = self.right_morale_max
            local percent = (self.right_morale_cur / self.right_morale_max) * 100
            self.right_morale:setString(percent.."%")
            self.right_progress:SetProgressInfo("", percent)
        end
    elseif state == "attack" then
        action = BattleObject:Do(BattleObject:AttackOnce()):next(function(corps)
            BattleObject:Do(BattleObject:BreathForever()):resolve(corps)
            return corps
        end)
    elseif state == "defend" then
        action = BattleObject:Do(BattleObject:Hold())
    elseif state == "breath" then
        action = BattleObject:Do(BattleObject:BreathForever())
    elseif state == "hurt" then
        action = BattleObject:Do(function(corps)
            if is_left then
                self.left_count:setString(tonumber(self.left_count:getString()) - side.damage)

                self.left_morale_cur = self.left_morale_cur - side.decrease
                local percent = (self.left_morale_cur / self.left_morale_max) * 100
                self.left_morale:setString(percent.."%")
                self.left_progress:SetProgressInfo("", percent)
            else
                self.right_count:setString(tonumber(self.right_count:getString()) - side.damage)

                self.right_morale_cur = self.right_morale_cur - side.decrease
                local percent = (self.right_morale_cur / self.right_morale_max) * 100
                self.right_morale:setString(percent.."%")
                self.right_progress:SetProgressInfo("", percent)
            end
            return corps
        end):next(BattleObject:HitOnce()):next(function(corps)
            BattleObject:Do(BattleObject:BreathForever()):resolve(corps)
            return corps
        end)
    elseif state == "move" then
        action = BattleObject:Do(BattleObject:Move())
    elseif state == "defeat" then
        action = BattleObject:Do(function(corps)
            self:SetCurrentSoldierStateBySide(is_left and "left" or "right", "defeated")
            return corps
        end):next(BattleObject:Defeat()):next(function(corps)
            if corps == self.left then
                self.left = nil
            elseif corps == self.right then
                self.right = nil
            end
            corps:removeFromParent()
            return corps
        end)
    else
        assert(false, "不支持这个动作!")
    end
    return action
end
function GameUIReplay:CreateItemWithListView(list_view, dual)
    local gap = 10
    local row_item = display.newNode()
    local left, right = dual.left, dual.right
    local left_item, right_item
    if left.soldier then
        left_item = WidgetSoldierInBattle.new("back_ground_284x128.png",
            {side = "blue", soldier = left.soldier, star = 1}):addTo(row_item)
            :align(display.CENTER, -284/2 - gap, 0)
    end
    if right.soldier then
        right_item = WidgetSoldierInBattle.new("back_ground_284x128.png",
            {side = "red", soldier = right.soldier, star = 1}):addTo(row_item)
            :align(display.CENTER, 284/2 + gap, 0)
    end
    local item = list_view:newItem()
    item:addContent(row_item)
    item:setItemSize(284 * 2, 128)
    return item, left_item, right_item
end
function GameUIReplay:SetCurrentSoldierStateBySide(side, status)
    print(side, status)
    if side == "left" then
        self.left_corps[self.left_round]:SetUnitStatus(status)
    elseif side == "right" then
        self.right_corps[self.right_round]:SetUnitStatus(status)
    else
        assert(false)
    end
end
function GameUIReplay:NextSoldierBySide(side)
    if side == "left" then
        self.left_round = self.left_round + 1
        self.left_corps[self.left_round]:SetUnitStatus("fighting")
    elseif side == "right" then
        self.right_round = self.right_round + 1
        self.right_corps[self.right_round]:SetUnitStatus("fighting")
    else
        assert(false)
    end
end
return GameUIReplay





































































