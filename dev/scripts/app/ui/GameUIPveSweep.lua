local UILib = import(".UILib")
local UIListView = import(".UIListView")
local GameUIPveSweep = UIKit:createUIClass("GameUIPveSweep", "UIAutoClose")
function GameUIPveSweep:ctor(rewards)
    GameUIPveSweep.super.ctor(self)

    local bg = cc.ui.UIPushButton.new(
        {normal = "pve_reward_bg.png", pressed = "pve_reward_bg.png", disabled = "pve_reward_bg.png"},
        {scale9 = false},
        {}
    ):pos(display.cx, display.cy):onButtonClicked(function()
        self:LeftButtonClicked()
    end)
    local h = 378
    local size = bg:getContentSize()
    local reward_bg = display.newScale9Sprite("pve_reward_bg1.png", nil, nil, cc.size(536,h))
        :addTo(bg):pos(0, 32)

    UIKit:ttfLabel({
        text = _("确定"),
        size = 22,
        color = 0xffedae,
    }):addTo(bg):align(display.CENTER, 0, -190)

    local list = UIListView.new{
        viewRect = cc.rect(0,0,536,h - 4),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    }:addTo(reward_bg)

    for i,v in ipairs(rewards) do
        local item = list:newItem()
        local content = self:GetListItem(i,v)
        item:addContent(content)
        item:setItemSize(528,74)
        list:addItem(item)
    end
    list:reload()

    self:addTouchAbleChild(bg)
    bg:scale(0.5)
    transition.scaleTo(bg,
        {scaleX = 1, scaleY = 1, time = 0.3,
            easing = "backout",
        })
end
function GameUIPveSweep:GetListItem(index,reward)
    local bg = display.newSprite("pve_reward_item.png")
    local size = bg:getContentSize()
    local png
    if reward.type == "items" then
        png = UILib.item[reward.name]
    elseif reward.type == "soldierMaterials" then
        png = UILib.soldier_metarial[reward.name]
    end


    UIKit:ttfLabel({
        text = string.format(_("第%d战"), index),
        size = 22,
        color = 0xffedae,
    }):addTo(bg):align(display.LEFT_CENTER, 50, size.height/2)

    UIKit:ttfLabel({
        text = "X"..reward.count,
        size = 22,
        color = 0xffedae,
    }):addTo(bg):align(display.LEFT_CENTER, size.width - 50, size.height/2)

    display.newSprite(png):addTo(
        display.newSprite("box_118x118.png"):addTo(bg):pos(size.width - 100, size.height/2):scale(0.5)
    ):pos(118/2, 118/2):scale(100/128)
    return bg
end



return GameUIPveSweep























