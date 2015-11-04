local GameUIMoveSuccess = UIKit:createUIClass("GameUIMoveSuccess", "UIAutoClose")
function GameUIMoveSuccess:ctor(fromIndex, toIndex)
    GameUIMoveSuccess.super.ctor(self)
    self.bg = cc.ui.UIPushButton.new({normal = "player_levelup_bg.png"}, nil, {})
        :align(display.CENTER, display.cx, display.cy)
        :onButtonClicked(function()
            self:LeftButtonClicked()
        end)
    self:addTouchAbleChild(self.bg)


    display.newSprite("pve_reward_item.png")
    :addTo(self.bg):pos(0,10):scale(0.8)
    display.newSprite("pve_reward_item.png")
    :addTo(self.bg):pos(0,-50):scale(0.8)

    display.newSprite("icon_world_88x88.png")
    :addTo(self.bg):pos(-180, 10):scale(0.5)
    UIKit:ttfLabel({
        text = _("圈数"),
        size = 22,
        color = 0xffedae,
    }):addTo(self.bg):align(display.LEFT_CENTER, -150, 10)

    UIKit:ttfLabel({
        text = DataUtils:getMapRoundByMapIndex(toIndex),
        size = 22,
        color = 0xa1dd00,
    }):addTo(self.bg):align(display.CENTER, 170, 10)

    display.newSprite("buff_68x68.png")
    :addTo(self.bg):pos(-180, -50):scale(0.5)
    UIKit:ttfLabel({
        text = _("增益数量"),
        size = 22,
        color = 0xffedae,
    }):addTo(self.bg):align(display.LEFT_CENTER, -150, -50)

    UIKit:ttfLabel({
        text = DataUtils:getMapBuffNumByMapIndex(toIndex),
        size = 22,
        color = 0xa1dd00,
    }):addTo(self.bg):align(display.CENTER, 170, -50)

    local size = self.bg:getCascadeBoundingBox()
    UIKit:ttfLabel({
        text = _("恭喜迁移联盟成功"),
        size = 40,
        color = 0xf7f7f7,
        shadow = true,
    }):addTo(self.bg):align(display.CENTER, 0, size.height/2 - 100)



    self:Play()
end
function GameUIMoveSuccess:onExit()
    app:EnterMyAllianceScene()
end
function GameUIMoveSuccess:Play()
    app:GetAudioManager():PlayeEffectSoundWithKey("HOORAY")
    self.bg:scale(0.3):show():stopAllActions()
    transition.scaleTo(self.bg, {
        scale = 1,
        time = 0.3,
        easing = "backout",
        onComplete = function()

        end,
    })
end

return GameUIMoveSuccess




