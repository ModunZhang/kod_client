local window = import("..utils.window")
local promise = import("..utils.promise")
local Corps = import(".Corps")
local UILib = import(".UILib")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetProgress = import("..widget.WidgetProgress")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSoldierInBattle = import("..widget.WidgetSoldierInBattle")
local GameUIReplay = UIKit:createUIClass('GameUIReplay')


local battle_data = {
    {
        {{soldier = "swordsman", state = "enter"}, {soldier = "lancer", state = "enter"}},
        {{state = "attack"}, {state = "defend"}},
        {{state = "defend"}, {state = "hurt"}},
        {{state = "defend"}, {state = "attack"}},
        {{state = "hurt"}, {state = "defend"}},
        {{state = "defeat"}, {state = "defend"}},
    },
    {
        {{soldier = "swordsman", state = "enter"}, {state = "defend"}},
        {{state = "attack"}, {state = "defend"}},
        {{state = "defend"}, {state = "hurt"}},
        {{state = "defend"}, {state = "attack"}},
        {{state = "hurt"}, {state = "defend"}},
        {{state = "defeat"}, {state = "defend"}},
    },
-- {
--     {{soldier = "archer", state = "enter"}, {state = "defend"}},
--     {{state = "attack"}, {state = "defend"}},
--     {{state = "defend"}, {state = "hurt"}},
--     {{state = "defend"}, {state = "attack"}},
--     {{state = "hurt"}, {state = "defend"}},
--     {{state = "defeat"}, {state = "defend"}},
-- },
-- {
--     {{soldier = "catapult", state = "enter"}, {state = "defend"}},
--     {{state = "defend"}, {state = "attack"}},
--     {{state = "hurt"}, {state = "defend"}},
--     {{state = "attack"}, {state = "defend"}},
--     {{state = "defend"}, {state = "hurt"}},
--     {{state = "defend"}, {state = "defeat"}},
-- },
}


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




    local battle_bg = cc.ui.UIImage.new("battle_bg_590x388.png")
        :addTo(back_ground):align(display.CENTER, back_width_half, back_height - 388/2 - 10)
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
    cc.ui.UILabel.new({
        text = "unitName1",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER, 276/2, 48/2)
        :addTo(unit_bg)

    local unit_bg = cc.ui.UIImage.new("unit_name_bg_red_276x48.png")
        :addTo(back_ground):pos(back_width - 276 - 7, back_height - 65 - 39)
    cc.ui.UILabel.new({
        text = "unitName2",
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
    cc.ui.UILabel.new({
        text = "40000",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER, 10, 53)
        :addTo(unit_info_bg)

    cc.ui.UILabel.new({
        text = "骑兵",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.RIGHT_CENTER, 240, 53)
        :addTo(unit_info_bg)


    local progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), "progress_bg_224x30.png", "progress_224x30.png", {
        icon_bg = "icon_bg_38x40.png",
        icon = "icon_32x34.png",
    })
        :addTo(unit_info_bg)
        :align(display.LEFT_CENTER, 20, 20)
    progress:SetProgressInfo("", 50)

    cc.ui.UILabel.new({
        text = "10000%",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER, 50, 20)
        :addTo(unit_info_bg)

    local unit_info_bg = cc.ui.UIImage.new("background_red_342x70.png")
        :addTo(back_ground):align(display.RIGHT_TOP, back_width - 10, back_height - 388 - 13)

    cc.ui.UILabel.new({
        text = "40000",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.RIGHT_CENTER, 342 - 10, 53)
        :addTo(unit_info_bg)

    cc.ui.UILabel.new({
        text = "骑兵",
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.LEFT_CENTER, 342 - 240, 53)
        :addTo(unit_info_bg)

    local progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), "progress_bg_224x30.png", "progress_224x30.png", {
        icon_bg = "icon_bg_38x40.png",
        icon = "icon_32x34.png",
    })
        :addTo(unit_info_bg)
        :align(display.LEFT_CENTER, 342 - 20, 20)
    progress:SetProgressInfo("", 50)
    progress:setScaleX(-1)

    cc.ui.UILabel.new({
        text = "80000%",
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


    local item, left, right = self:CreateItemWithListView(self.list_view, {"swordsman", "lancer"})
    table.insert(self.left_corps, left)
    table.insert(self.right_corps, right)
    self.list_view:addItem(item)

    local item, left, right = self:CreateItemWithListView(self.list_view, {"swordsman", nil})
    table.insert(self.left_corps, left)
    table.insert(self.right_corps, right)
    self.list_view:addItem(item)

    self.list_view:reload():resetPosition()

    local rounds = promise.new()
    for i, round in ipairs(battle_data) do
        rounds:next(function()
            local pa
            for _, v in ipairs(round) do
                local left, right = unpack(v)
                local left_action = self:DecodeStateBySide(left, true, i)
                local right_action = self:DecodeStateBySide(right, false, i)
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
function GameUIReplay:NewCorps(soldier, x, y)
    local soldier_arrange = {
        swordsman = {row = 4, col = 2},
        archer = {row = 4, col = 2},
        lancer = {row = 3, col = 1},
        catapult = {row = 2, col = 1},
    }
    local arrange = soldier_arrange[soldier]
    return Corps.new(soldier, arrange.row, arrange.col):addTo(self.battle_bg):pos(x, y)
end
function GameUIReplay:DecodeStateBySide(side, is_left, round)
    local height = 90
    local len = 200
    local left_start = {x = -100, y = height}
    local left_end = {x = left_start.x + len, y = height}
    local right_start = {x = 700, y = height}
    local right_end = {x = right_start.x - len, y = height}
    local action
    if side.state == "enter" then
        if is_left then
            self.left = self:NewCorps(side.soldier, left_start.x, left_start.y)
            action = Corps:Do(function(corps)
                self.left_corps[round]:SetUnitStatus("fighting")
                return corps
            end):next(Corps:MoveTo(left_end.x, left_end.y, 2))
                :next(Corps:BreathForever())
        else
            self.right = self:NewCorps(side.soldier, right_start.x, right_start.y)
            action = Corps:Do(function(corps)
                self.right_corps[round]:SetUnitStatus("fighting")
                return corps
            end):next(Corps:TurnLeft()):next(Corps:MoveTo(right_end.x, right_end.y, 2)):next(Corps:BreathForever())
        end
    elseif side.state == "attack" then
        action = Corps:Do(Corps:AttackOnce()):next(function(corps)
            Corps:Do(Corps:BreathForever()):resolve(corps)
            return corps
        end)
    elseif side.state == "defend" then
        action = Corps:Do(Corps:Hold())
    elseif side.state == "breath" then
        action = Corps:Do(Corps:BreathForever())
    elseif side.state == "hurt" then
        action = Corps:Do(Corps:HitOnce()):next(function(corps)
            Corps:Do(Corps:BreathForever()):resolve(corps)
            return corps
        end)
    elseif side.state == "defeat" then
        action = Corps:Do(function(corps)
            if is_left then
                self.left_corps[round]:SetUnitStatus("defeated")
            else
                self.right_corps[round]:SetUnitStatus("defeated")
            end
            return corps
        end):next(Corps:FadeOut()):next(function(corps)
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
function GameUIReplay:CreateItemWithListView(list_view, duals)
    local gap = 10
    local row_item = display.newNode()
    local duals = duals or {true, true}
    local left_soldier, right_soldier = unpack(duals)
    local left, right
    if left_soldier then
        left = WidgetSoldierInBattle.new("back_ground_284x128.png",
            {side = "blue", soldier = left_soldier, star = 1}):addTo(row_item)
            :align(display.CENTER, -284/2 - gap, 0)
    end
    if right_soldier then
        right = WidgetSoldierInBattle.new("back_ground_284x128.png",
            {side = "red", soldier = right_soldier, star = 1}):addTo(row_item)
            :align(display.CENTER, 284/2 + gap, 0)
    end
    local item = list_view:newItem()
    item:addContent(row_item)
    item:setItemSize(284 * 2, 128)
    return item, left, right
end

return GameUIReplay























