local Localize = import("..utils.Localize")
local window = import("..utils.window")
local promise = import("..utils.promise")
local cocos_promise = import("..utils.cocos_promise")
local BattleObject = import(".BattleObject")
local Effect = import(".Effect")
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
        left = {soldier = "lancer", count = 1000, damage = 90, morale = 100, decrease = 20},
        right = {soldier = "catapult", count = 100, damage = 80, morale = 100, decrease = 80},
        defeat = "right"
    },
    -- {
    --     left = {damage = 90, decrease = 10},
    --     right = {soldier = "swordsman", count = 100, damage = 80, morale = 100, decrease = 50},
    --     defeat = "left"
    -- },
    -- {
    --     left = {soldier = "lancer", count = 1000, damage = 90, morale = 100, decrease = 20},
    --     right = {damage = 10, decrease = 10},
    --     defeat = "right"
    -- },
    {
        left = {damage = 90, decrease = 30},
        right = {soldier = "wall", count = 1000, damage = 80, morale = 100, decrease = 90},
        defeat = "right"
    },
}
local function decode_battle_from_report(report)
    local attacks = report:GetFightAttackSoldierRoundData()
    local defends = report:GetFightDefenceSoldierRoundData()
    if report:IsFightWall() then
        for i, v in ipairs(report:GetFightAttackWallRoundData()) do
            attacks[#attacks + 1] = v
        end
        for i, v in ipairs(report:GetFightDefenceWallRoundData()) do
            defends[#defends + 1] = v
        end
    end
    local battle = {}
    local defeat
    for i = 1, #attacks do
        local attacker = attacks[i]
        local defender = defends[i]
        local left
        local right
        if defeat == "right" then
            left = {
                damage = attacker.soldierDamagedCount or attacker.wallDamagedHp,
                decrease = attacker.moraleDecreased or 0,
            }
        else
            left = {
                soldier = attacker.soldierName or "wall",
                count = attacker.soldierCount or attacker.wallHp,
                damage = attacker.soldierDamagedCount or attacker.wallDamagedHp,
                morale = attacker.morale or 100,
                decrease = attacker.moraleDecreased or 0,
            }
        end
        if defeat == "left" then
            right = {
                damage = defender.soldierDamagedCount or defender.wallDamagedHp,
                decrease = defender.moraleDecreased or 0,
            }
        else
            right = {
                soldier = defender.soldierName or "wall",
                count = defender.soldierCount or defender.wallHp,
                damage = defender.soldierDamagedCount or defender.wallDamagedHp,
                morale = defender.morale or 100,
                decrease = defender.moraleDecreased or 0,
            }
        end
        defeat = attacker.isWin and "right" or "left"
        table.insert(battle, {left = left, right = right, defeat = defeat})
    end
    return battle
end
local function decode_battle(raw)
    local rounds = {}
    local left_soldier, right_soldier
    for i, dual in ipairs(raw) do
        local r = {}
        local left, right = dual.left, dual.right
        left_soldier = left.soldier or left_soldier
        right_soldier = right.soldier or right_soldier
        if i == 1 then
            table.insert(r, {
                {soldier = left_soldier, state = "enter", count = left.count, morale = left.morale},
                {soldier = right_soldier, state = "enter", count = right.count, morale = right.morale}
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
                    table.insert(r, {{state = "defend"}, {state = "breath"}})
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
                    table.insert(r, {{state = "breath"}, {state = "defend"}})
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
            table.insert(r, {{state = "attack", effect = left_soldier}, {state = "defend"}})
            table.insert(r, {{state = "defend"}, {state = "hurt", damage = right.damage, decrease = right.decrease}})
            table.insert(r, {{state = "defend"}, {state = "attack", effect = right_soldier}})
            table.insert(r, {{state = "hurt", damage = left.damage, decrease = left.decrease}, {state = "defend"}})
            table.insert(r, {{state = "defeat"}, {state = "defend"}})
        elseif dual.defeat == "right" then
            table.insert(r, {{state = "defend"}, {state = "attack", effect = right_soldier}})
            table.insert(r, {{state = "hurt", damage = left.damage, decrease = left.decrease}, {state = "defend"}})
            table.insert(r, {{state = "attack", effect = left_soldier}, {state = "defend"}})
            table.insert(r, {{state = "defend"}, {state = "hurt", damage = right.damage, decrease = right.decrease}})
            table.insert(r, {{state = "defend"}, {state = "defeat"}})
        else
            assert(false)
        end
        table.insert(rounds, r)
    end
    return rounds
end

function GameUIReplay:ctor(report)
    self.report = report
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
    for _, anis in pairs(UILib.effect_animation_files) do
        for _, v in pairs(anis) do
            manager:addArmatureFileInfo(v)
        end
    end

    for _, anis in pairs(UILib.dragon_animations_files) do
        for _, v in pairs(anis) do
            manager:addArmatureFileInfo(v)
        end
    end

    manager:addArmatureFileInfo("animations/dragon_battle/paizi.ExportJson")
end
function GameUIReplay:onExit()
    GameUIReplay.super.onExit(self)
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
    local title = cc.ui.UIImage.new("background_288x60.png")
        :addTo(back_ground):pos(5, back_height - 65)
    self.left_name = cc.ui.UILabel.new({
        text = self.report:GetFightAttackName(),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, 288/2, 60/2)
        :addTo(title)
    local title = cc.ui.UIImage.new("background_288x60.png")
        :addTo(back_ground):pos(back_width - 288 - 5, back_height - 65):flipX(true)
    self.right_name = cc.ui.UILabel.new({
        text = self.report:GetFightDefenceName(),
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, 288/2, 60/2)
        :addTo(title)

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


    local battle = decode_battle_from_report(self.report)
    -- local battle = new_battle
    dump(battle)

    local x, y = bg:getPosition()
    self.list_view = self:CreateVerticalListViewDetached(0, 80, back_ground:getContentSize().width, y - 82 / 2):addTo(back_ground)
    self.left_corps = {}
    self.right_corps = {}
    self.left_round = 0
    self.right_round = 0
    local dual = {left = {}, right = {}}
    for i, v in ipairs(battle) do
        if v.left.soldier then
            table.insert(dual.left, v.left.soldier)
        end
        if v.right.soldier then
            table.insert(dual.right, v.right.soldier)
        end
    end
    local round = {}
    while 1 do
        local left = table.remove(dual.left, 1)
        local right = table.remove(dual.right, 1)
        if not left and not right then
            break
        end
        table.insert(round, {left = {soldier = left}, right = {soldier = right}})
    end
    for i, dual in ipairs(round) do
        local item, left, right = self:CreateItemWithListView(self.list_view, dual)
        table.insert(self.left_corps, left)
        table.insert(self.right_corps, right)
        self.list_view:addItem(item)
    end
    self.list_view:reload()
    -- :resetPosition()
    self.left_morale_max = 0
    self.right_morale_max = 0
    self.left_morale_cur = self.left_morale_max
    self.right_morale_cur = self.right_morale_max

    -- self:PlaySoldierBattle(decode_battle(battle))
    if self.report:IsDragonFight() then
        self:PlayDragonBattle():next(function()
            self:PlaySoldierBattle(decode_battle(battle))
        end):catch(function(err)
            dump(err:reason())
        end)
    else
        self:PlaySoldierBattle(decode_battle(battle)):catch(function(err)
            dump(err:reason())
        end)
    end

end
function GameUIReplay:PlayDragonBattle()
    local report = self.report
    local attack_dragon = report:GetFightAttackDragonRoundData()
    local defend_dragon = report:GetFightDefenceDragonRoundData()
    local dp = self:NewDragonBattle()
        :next(cocos_promise.delay(0.1))
        :next(function()
            local p = promise.new()
            self:Performance(0.5, function(pos)
                if attack_dragon then
                    self.left_dragon:SetHp(attack_dragon.hp - pos * attack_dragon.hpDecreased, attack_dragon.hpMax)
                end
                if defend_dragon then
                    self.right_dragon:SetHp(defend_dragon.hp - pos * defend_dragon.hpDecreased, defend_dragon.hpMax)
                end
            end, function()
                p:resolve()
            end)
            return p
        end)
        :next(cocos_promise.delay(0.8))
        :next(function()
            local left_p
            if attack_dragon then
                left_p = self.left_dragon:ShowResult(attack_dragon.isWin)
            end
            local right_p
            if defend_dragon then
                right_p = self.right_dragon:ShowResult(defend_dragon.isWin)
            end
            return left_p or right_p
        end)
        :next(cocos_promise.delay(0.8))
        :next(function()
            local p = promise.new()
            if attack_dragon then
                self.left_dragon:ShowBuff()
            end
            if defend_dragon then
                self.right_dragon:ShowBuff()
            end
            self:Performance(0.5, function(pos)
                if attack_dragon then
                    local d = attack_dragon.isWin and 100 or 50
                    self.left_dragon:SetBuff(string.format("BUFF + %d%%", math.floor(pos * d)))
                end
                if defend_dragon then
                    local d = defend_dragon.isWin and 100 or 50
                    self.right_dragon:SetBuff(string.format("BUFF + %d%%", math.floor(pos * d)))
                end
            end, function()
                p:resolve()
            end)
            return p
        end)
        :next(cocos_promise.delay(0.8))
        :next(function()
            local p = promise.new()
            self.dragon_battle:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
                if movementType == ccs.MovementEventType.complete then
                    p:resolve(self)
                end
            end)
            self.dragon_battle:getAnimation():play("Animation2", -1, 0)
            self.dragon_battle:getAnimation():setSpeedScale(0.8)
            return p
        end)
        :next(cocos_promise.delay(0.8))

    promise.new():next(cocos_promise.delay(0.2)):next(function()
        if self.dragon_battle then
            self.dragon_battle:getAnimation():play("Animation1", -1, 0)
        end
    end):resolve()

    self.dragon_battle:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.complete then
            dp:resolve(self)
        end
    end)

    return dp
end
function GameUIReplay:PlaySoldierBattle(soldier_battle)
    local rounds = promise.new()
    for i, round in ipairs(soldier_battle) do
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
    return cocos_promise.defferPromise(rounds)
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
function GameUIReplay:NewDragonBattle(battle)
    local report = self.report
    local attack_dragon = report:GetFightAttackDragonRoundData()
    local defend_dragon = report:GetFightDefenceDragonRoundData()
    local dragon_battle = ccs.Armature:create("paizi"):addTo(self.battle):align(display.CENTER, 275, 155)

    local left_bone = dragon_battle:getBone("Layer4")
    local left_dragon = self:NewDragon(true):addTo(left_bone):pos(-360, -50)
    left_bone:addDisplay(left_dragon, 0)
    left_bone:changeDisplayWithIndex(0, true)
    self.left_dragon = left_dragon
    self.left_dragon:SetHp(attack_dragon.hp, attack_dragon.hp)

    local right_bone = dragon_battle:getBone("Layer5")
    local right_dragon = self:NewDragon():addTo(right_bone):pos(238, -82)
    right_bone:addDisplay(right_dragon, 0)
    right_bone:changeDisplayWithIndex(0, true)
    self.right_dragon = right_dragon
    self.right_dragon:SetHp(defend_dragon.hp, defend_dragon.hp)

    self.dragon_battle = dragon_battle
    return promise.new()
end
function GameUIReplay:NewDragon(is_left)
    local node = display.newNode()
    function node:Init()
        self.name = cc.ui.UILabel.new({
            text = "红龙(等级20)",
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, 45, 180)
            :addTo(self)

        self.hp_progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), "progress_bar_262x16.png", "progress_bar_262x16.png", {
            label_size = 14,
            has_icon = false,
            has_bg = false
        }):addTo(self)
            :align(display.LEFT_CENTER, -82, 158):scale(0.975, 1)
        if not is_left then
            self.hp_progress:pos(166, 158)
            self.hp_progress:setScaleX(-0.975)
        end

        self.hp = cc.ui.UILabel.new({
            text = "",
            font = UIKit:getFontFilePath(),
            size = 14,
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, 45, 160)
            :addTo(self)


        self.result = cc.ui.UILabel.new({
            text = "WIN",
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x00be36)
        }):align(display.CENTER, 120, -55)
            :addTo(self):hide()
        if not is_left then
            self.result:pos(-35, -55)
        end

        self.buff = cc.ui.UILabel.new({
            text = "BUFF + 100%",
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x00be36)
        }):align(display.CENTER, 20, -55)
            :addTo(self):hide()
        if not is_left then
            self.buff:pos(80, -55)
        end

        local dragon = ccs.Armature:create("dragon_red")
            :addTo(self):align(display.CENTER, 130, 60):scale(0.6)
        dragon:getAnimation():play("Idle", -1, -1)
        dragon:setScaleX(is_left and 0.6 or -0.6)
        if not is_left then
            dragon:pos(-45, 60)
        end
    end
    function node:SetName()
        return self
    end
    function node:SetHp(cur, total)
        self.hp:setString(string.format("%d/%d", math.floor(cur), math.floor(total)))
        self.hp_progress:SetProgressInfo("", cur / total * 100)
        return self
    end
    function node:SetReulst(is_win)
        local color = is_win and UIKit:hex2c3b(0x00be36) or UIKit:hex2c3b(0xff0000)
        self.result:setColor(color)
        self.buff:setColor(color)
        self.result:setString(is_win and "WIN" or "LOSE")
        return self
    end
    function node:ShowResult(is_win)
        local p = promise.new()
        self:SetReulst(is_win)
        transition.scaleTo(self.result:scale(3):show(), {
            scale = 1,
            time = 0.15,
            onComplete = function()
                p:resolve()
            end})
        return p
    end
    function node:SetBuff(buff)
        self.buff:setString(buff)
        return self
    end
    function node:ShowBuff()
        self.buff:show()
        return self
    end
    node:Init()
    return node
end
function GameUIReplay:NewWall(x)
    return Wall.new():addTo(self.battle_bg):pos(x, 150)
end
local soldier_arrange = {
    swordsman = {row = 4, col = 2},
    sentinel = {row = 4, col = 2},
    ranger = {row = 4, col = 2},
    crossbowman = {row = 4, col = 2},
    lancer = {row = 3, col = 1},
    horseArcher = {row = 3, col = 1},
    catapult = {row = 2, col = 1},
    ballista = {row = 2, col = 1},
}
function GameUIReplay:NewCorps(soldier, x, y)
    local arrange = soldier_arrange[soldier]
    return Corps.new(soldier, arrange.row, arrange.col):addTo(self.battle):pos(x, y)
end
function GameUIReplay:NewEffect(soldier, is_left, x, y)
    if soldier == "wall" then return end
    local arrange = soldier_arrange[soldier]
    local w = is_left and 100 or -100
    local effect = Effect.new(soldier, arrange.row, arrange.col):addTo(self.battle):pos(x + w, y)
    if is_left then
        effect:turnRight()
    else
        effect:turnLeft()
    end
    effect:OnAnimationPlayEnd("attack_1", function()
        effect:removeFromParent()
    end)
    effect:PlayAnimation("attack_1", 0)
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
                end):next(BattleObject:MoveTo(2, left_end.x, left_end.y))
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
                    :next(BattleObject:MoveTo(2, right_end.x, right_end.y))
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
        action = BattleObject:Do(function(corps)
            self:NewEffect(side.effect, is_left, corps:getPosition())
            return corps
        end):next(BattleObject:AttackOnce()):next(function(corps)
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
function GameUIReplay:Performance(time, onUpdate, onComplete)
    if self.update_handle then
        self:unscheduleUpdate()
        self:removeNodeEventListener(self.update_handle)
    end
    local t = 0
    self.update_handle = self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        t = t + dt
        if t > time then
            t = time
            if type(onComplete) == "function" then
                onComplete()
            end
            self:unscheduleUpdate()
        end
        if type(onUpdate) == "function" then
            onUpdate(t / time)
        end
    end)
    self:scheduleUpdate()
    return self
end


return GameUIReplay






