local GameUIMoveSuccess = UIKit:createUIClass("GameUIMoveSuccess", "UIAutoClose")
function GameUIMoveSuccess:ctor(fromIndex, toIndex)
    GameUIMoveSuccess.super.ctor(self)
    self.bg = cc.ui.UIPushButton.new({normal = "player_levelup_bg.png"}, nil, {})
        :align(display.CENTER, display.cx, display.cy)
        :onButtonClicked(function()
            self:LeftButtonClicked()
        end)
    self:addTouchAbleChild(self.bg)

    local size = self.bg:getCascadeBoundingBox()
    UIKit:ttfLabel({
        text = _("恭喜迁移联盟成功"),
        size = 18,
        color = 0x00fff5
    }):addTo(self.bg):align(display.CENTER, 0, size.height/2 - 55)

    self:Play()
end
function GameUIMoveSuccess:onExit()
    if display.getRunningScene().__cname == 'AllianceDetailScene' then
        app:EnterMyAllianceScene()
    else
        self:LeftButtonClicked()
        if UIKit:GetUIInstance("GameUIWorldMap") then
            UIKit:GetUIInstance("GameUIWorldMap"):LeftButtonClicked()
        end
    end
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




