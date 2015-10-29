local GameUIMoveSuccess = UIKit:createUIClass("GameUIMoveSuccess", "UIAutoClose")
function GameUIMoveSuccess:ctor(fromIndex, toIndex)
    GameUIMoveSuccess.super.ctor(self)
    self.bg = cc.ui.UIPushButton.new({normal = "player_levelup_bg.png"}, nil, {})
        :align(display.CENTER, display.cx, display.cy)
        :onButtonClicked(function()
            self:LeftButtonClicked()
        end)
    self:addTouchAbleChild(self.bg)
    self:Play()
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




