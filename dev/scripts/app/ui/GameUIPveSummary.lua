local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local Localize_item = import("..utils.Localize_item")
local lights = import("..particles.lights")
local GameUIPveSummary = UIKit:createUIClass("GameUIPveSummary", "UIAutoClose")
local config_dragonLevel = GameDatas.Dragons.dragonLevel

function GameUIPveSummary:ctor(param)
    GameUIPveSummary.super.ctor(self)
    if param.star > 0 then
        self:BuildVictoryUI(param)
    else
        self:BuildDefeatUI(param)
    end
end
function GameUIPveSummary:BuildVictoryUI(param)
    local bg = cc.ui.UIPushButton.new(
        {normal = "pve_reward_bg.png", pressed = "pve_reward_bg.png", disabled = "pve_reward_bg.png"},
        {scale9 = false},
        {}
    ):pos(display.cx, display.cy):onButtonClicked(function()
        self:LeftButtonClicked()
    end)

    display.newSprite("pve_summary_bg1.png"):addTo(bg):align(display.BOTTOM_CENTER, 0, 200)
    display.newSprite("pve_summary_bg2.png"):addTo(bg):align(display.BOTTOM_CENTER, 0, 200)
    ccs.Armature:create("win"):addTo(bg):align(display.CENTER, 0, 300):getAnimation():play("Victory", -1, 0)

    self.items = {}
    local sbg = display.newSprite("tmp_pve_bg.png"):addTo(bg):pos(0, 210)
    local size = sbg:getContentSize()
    display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2 - 60, 35):scale(0.8)
    self.items[1] = display.newSprite("tmp_pve_star.png"):addTo(sbg):pos(size.width/2 - 60, 50):scale(1.8)

    display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2, 35)
    self.items[2] = display.newSprite("tmp_pve_star.png"):addTo(sbg):pos(size.width/2, 50):scale(2)

    display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2 + 60, 35):scale(0.8)
    self.items[3] = display.newSprite("tmp_pve_star.png"):addTo(sbg):pos(size.width/2 + 60, 50):scale(1.8)

    for i = 1, #self.items do
        self.items[i]:setVisible(false)
            :runAction(transition.sequence{
                cc.DelayTime:create((i-1) * 0.5 + 0.5),
                cc.CallFunc:create(function() 
                	local e = i <= param.star
                	self.items[i]:setVisible(e) 
                	if e then
                		app:GetAudioManager():PlayeEffectSoundWithKey("PVE_STAR"..i)
                	end
                end),
                cc.EaseBackOut:create(
                    cc.Spawn:create(
                        cc.MoveTo:create(0.2, cc.p(size.width/2 - 60 + (i-1) * 60, 35)),
                        cc.ScaleTo:create(0.2, i == 2 and 1 or 0.8, i == 2 and 1 or 0.8)
                    )
                ),
            })
    end

    local dragon_bg = display.newSprite("dragon_bg_114x114.png"):addTo(bg):pos(-160, 90)
    self.dragon_img = display.newSprite(UILib.dragon_head[param.dragonType])
        :align(display.CENTER, dragon_bg:getContentSize().width/2, dragon_bg:getContentSize().height/2+5):addTo(dragon_bg)

    local level_label = UIKit:ttfLabel({
        text = Localize.dragon[param.dragonType]..string.format(_("(等级 %d)"), param.old_level),
        size = 22,
        color = 0xffedae,
    }):addTo(bg):align(display.LEFT_CENTER, -80, 120)

    local bar = display.newSprite("progress_bar_348x40_1.png"):addTo(bg):align(display.LEFT_CENTER, -90, 60)
    local progresstimer_new = cc.ProgressTimer:create(display.newSprite("tmp_progress_green_bar_348x40_2.png"))
    progresstimer_new:setType(display.PROGRESS_TIMER_BAR)
    progresstimer_new:setBarChangeRate(cc.p(1,0))
    progresstimer_new:setMidpoint(cc.p(0,0))
    progresstimer_new:align(display.LEFT_BOTTOM, 0, 1):addTo(bar)
    progresstimer_new:setPercentage(param.old_exp/config_dragonLevel[param.old_level].expNeed * 100)

    local progresstimer_old = cc.ProgressTimer:create(display.newSprite("progress_bar_348x40_2.png"))
    progresstimer_old:setType(display.PROGRESS_TIMER_BAR)
    progresstimer_old:setBarChangeRate(cc.p(1,0))
    progresstimer_old:setMidpoint(cc.p(0,0))
    progresstimer_old:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    progresstimer_old:setPercentage(param.old_exp/config_dragonLevel[param.old_level].expNeed * 100)


    local upexp = 0
    if param.old_level ~= param.new_level then
        for i = param.old_level, param.new_level do
            if param.old_level == i then
                upexp = config_dragonLevel[param.old_level].expNeed - param.old_exp
            elseif param.new_level == i then
                upexp = upexp + param.new_exp
            else
                upexp = upexp + config_dragonLevel[i].expNeed
            end
        end
    else
        upexp = param.new_exp - param.old_exp
    end

    local exp_label = UIKit:ttfLabel({
        text = string.format("%d/%d(+%d)", param.old_exp, config_dragonLevel[param.old_level].expNeed, upexp),
        size = 22,
        color = 0xffedae,
        shadow = true,
    }):addTo(bg):align(display.LEFT_CENTER, -70, 60)

    local unit_time = 0.8
    local acts = {}
    if param.new_level - param.old_level > 0 then
        for i = param.old_level, param.new_level do
            table.insert(acts, cc.CallFunc:create(function()
                progresstimer_new:setPercentage(0)
            end))
            if i == param.old_level then
                table.insert(acts, cc.CallFunc:create(function()
                    local expNeed = config_dragonLevel[i].expNeed
                    self:Performance(unit_time, function(ratio)
                        exp_label:setString(string.format("%d/%d(+%d)", param.old_exp + ratio * (expNeed-param.old_exp), expNeed, upexp))
                    end)
                end))
                table.insert(acts, cc.ProgressTo:create(unit_time, 100))
                table.insert(acts, cc.CallFunc:create(function()
                    level_label:setString(Localize.dragon[param.dragonType]..string.format(_("(等级 %d)"), i + 1))
                end))
                table.insert(acts, cc.CallFunc:create(function() progresstimer_old:hide() end))
            elseif i == param.new_level then
                table.insert(acts, cc.CallFunc:create(function()
                    local expNeed = config_dragonLevel[i].expNeed
                    self:Performance(unit_time, function(ratio)
                        exp_label:setString(string.format("%d/%d(+%d)", param.new_exp * ratio, expNeed, upexp))
                    end)
                end))
                table.insert(acts, cc.ProgressTo:create(unit_time, param.new_exp/config_dragonLevel[param.new_level].expNeed * 100))
            else
                table.insert(acts, cc.CallFunc:create(function()
                    local expNeed = config_dragonLevel[i].expNeed
                    self:Performance(unit_time, function(ratio)
                        exp_label:setString(string.format("%d/%d(+%d)", ratio * expNeed, expNeed, upexp))
                    end)
                end))
                table.insert(acts, cc.ProgressTo:create(unit_time, 100))
                table.insert(acts, cc.CallFunc:create(function()
                    level_label:setString(Localize.dragon[param.dragonType]..string.format(_("(等级 %d)"), i + 1))
                end))
            end
        end
    else
        table.insert(acts, cc.ProgressTo:create(unit_time, param.new_exp/config_dragonLevel[param.old_level].expNeed * 100))
        self:Performance(unit_time, function(ratio)
            exp_label:setString(string.format("%d/%d(+%d)", param.old_exp + ratio * upexp, config_dragonLevel[param.old_level].expNeed, upexp))
        end)
    end
    progresstimer_new:runAction(transition.sequence(acts))


    display.newSprite("pve_summary_bg3.png"):addTo(bg):pos(0, -80)
    display.newSprite("pve_summary_bg4.png"):addTo(bg):pos(0, -80)

    local reward = param.reward[1]
    if reward then
        local png, txt
        if reward.type == "items" then
            png = UILib.item[reward.name]
            txt = Localize_item.item_name[reward.name]
        elseif reward.type == "soldierMaterials" then
            png = UILib.soldier_metarial[reward.name]
            txt = Localize.soldier_material[reward.name]
        end

        local icon = display.newSprite(png):addTo(
            display.newSprite("box_118x118.png"):addTo(bg):pos(-50, -80)
        ):pos(118/2, 118/2):scale(100/128)
        lights():addTo(icon):pos(128/2, 128/2)

        UIKit:ttfLabel({
            text = txt,
            size = 22,
            color = 0xffedae,
        }):addTo(bg):align(display.LEFT_CENTER, 30, -40)

        UIKit:ttfLabel({
            text = _("获得数量 : ")..reward.count,
            size = 22,
            color = 0xffedae,
        }):addTo(bg):align(display.LEFT_CENTER, 30, -110)

    else
        UIKit:ttfLabel({
            text = _("材料库房已满,丢失所获得材料!"),
            size = 22,
            color = 0xffedae,
        }):addTo(bg):align(display.CENTER, 0 , -80)
    end


    UIKit:ttfLabel({
        text = _("确定"),
        size = 22,
        color = 0xffedae,
    }):addTo(bg):align(display.CENTER, 0, -190)

    self:addTouchAbleChild(bg)
end
function GameUIPveSummary:BuildDefeatUI(param)
    local bg = cc.ui.UIPushButton.new(
        {normal = "pve_reward_bg.png", pressed = "pve_reward_bg.png", disabled = "pve_reward_bg.png"},
        {scale9 = false},
        {}
    ):pos(display.cx, display.cy):onButtonClicked(function()
        self:LeftButtonClicked()
    end)
    display.newSprite("pve_summary_bg1.png"):addTo(bg):align(display.BOTTOM_CENTER, 0, 200)

    self.items = {}
    local sbg = display.newSprite("tmp_pve_bg.png"):addTo(bg):pos(0, 210)
    local size = sbg:getContentSize()
    self.items[1] = display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2 - 60, 32):scale(0.8)
    self.items[2] = display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2, 32)
    self.items[3] = display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2 + 60, 32):scale(0.8)
    ccs.Armature:create("win"):addTo(bg):align(display.CENTER, 0, 300):getAnimation():play("Defeat", -1, 0)



    display.newScale9Sprite("pve_summary_bg3.png", nil, nil, cc.size(534, 148 * 2)):addTo(bg):pos(0,10)
    local dragon = cc.ui.UIPushButton.new(
        {normal = "pve_summary_bg4.png", pressed = "pve_summary_bg4.png", disabled = "pve_summary_bg4.png"},
        {scale9 = false},
        {}
    ):addTo(bg):pos(0, 82):onButtonClicked(function()
        UIKit:newGameUI("GameUIDragonEyrieMain", City, City:GetFirstBuildingByType("dragonEyrie"), "dragon"):AddToCurrentScene(true)
        self:LeftButtonClicked()
    end)
    display.newSprite("dragonEyrie.png"):addTo(dragon):scale(0.3):pos(-150, 0)

    UIKit:ttfLabel({
        text = _("龙巢"),
        size = 22,
        color = 0xffedae,
    }):addTo(dragon):align(display.LEFT_CENTER, -80, 30)

    UIKit:ttfLabel({
        text = _("提升龙的等级"),
        size = 22,
        color = 0xffedae,
    }):addTo(dragon):align(display.LEFT_CENTER, -80, -30)

    display.newSprite("fte_icon_arrow.png"):align(display.CENTER, 200, 0):addTo(dragon):rotation(-90)


    local barracks = cc.ui.UIPushButton.new(
        {normal = "pve_summary_bg4.png", pressed = "pve_summary_bg4.png", disabled = "pve_summary_bg4.png"},
        {scale9 = false},
        {}
    ):addTo(bg):pos(0, -62):onButtonClicked(function()
        UIKit:newGameUI("GameUIBarracks", City, City:GetFirstBuildingByType("barracks"), "recruit"):AddToCurrentScene(true)
        self:LeftButtonClicked()
    end)
    display.newSprite("barracks.png"):addTo(barracks):scale(0.4):pos(-150, 0)
    UIKit:ttfLabel({
        text = _("兵营"),
        size = 22,
        color = 0xffedae,
    }):addTo(barracks):align(display.LEFT_CENTER, -80, 30)

    UIKit:ttfLabel({
        text = _("招募更多兵种"),
        size = 22,
        color = 0xffedae,
    }):addTo(barracks):align(display.LEFT_CENTER, -80, -30)
    display.newSprite("fte_icon_arrow.png"):align(display.CENTER, 200, 0):addTo(barracks):rotation(-90)


    UIKit:ttfLabel({
        text = _("确定"),
        size = 22,
        color = 0xffedae,
    }):addTo(bg):align(display.CENTER, 0, -190)

    self:addTouchAbleChild(bg)
end
function GameUIPveSummary:Performance(t, func)
    local time = 0
    local dt = 0.01
    local node = display.newNode():addTo(self)
    node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        time = time + dt
        if time >= t then
            func(1)
            node:unscheduleUpdate()
            node:removeFromParent()
        else
            func(time/t)
        end
    end)
    node:scheduleUpdate()
end



return GameUIPveSummary





























