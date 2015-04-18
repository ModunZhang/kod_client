local GameUILevelUp = UIKit:createUIClass("GameUILevelUp", "UIAutoClose")
function GameUILevelUp:ctor(user)
    GameUILevelUp.super.ctor(self)

    local bg = cc.ui.UIPushButton.new({normal = "player_level_bg.png"}, nil, {})
    :align(display.CENTER, display.cx, display.cy)
    :onButtonClicked(function(event)
    	self:LeftButtonClicked()
    end)
    local size = bg:getCascadeBoundingBox()
    self:addTouchAbleChild(bg)
    UIKit:ttfLabel({
        text = _("恭喜你达到"),
        size = 18,
        color = 0x00fff5
    }):addTo(bg):align(display.CENTER, 0, size.height/2 - 55)

    UIKit:ttfLabel({
        text = string.format(_("等级 %d"), user:Level()),
        size = 57,
        color = 0xf7f7f7
    }):addTo(bg):align(display.CENTER, 0, size.height/2 - 100)

    local rewards = {
        {
            {icon = "reward_icon.png", value = "x100"},
            {icon = "reward_icon.png", value = "x100"},
            {icon = "reward_icon.png", value = "x100"},
        },
        {
            {icon = "reward_icon.png", value = "x100"},
            {icon = "reward_icon.png", value = "x100"},
            {icon = "reward_icon.png", value = "x100"},
        }
    }
    local start_x, start_y, w, h = -size.width/2 + 80, -size.height/2 + 130, 150, 60
    for row,rows in ipairs(rewards) do
        for col,v in ipairs(rows) do
            local x,y = start_x + (col-1) * w, start_y + (row-1) * h
            display.newSprite(v.icon):addTo(bg):align(display.LEFT_CENTER, x, y)
            UIKit:ttfLabel({
                text = v.value,
                size = 16,
                color = 0xffedae
            }):addTo(bg):align(display.LEFT_CENTER, x + 50, y)
        end
    end
    bg:scale(0.3)
    app:GetAudioManager():PlayeEffectSoundWithKey("HOORAY")
    transition.scaleTo(bg, {
        scale = 1, 
        time = 0.3, 
        easing = "backout",
        onComplete = function()

        end,
    })
end

return GameUILevelUp


