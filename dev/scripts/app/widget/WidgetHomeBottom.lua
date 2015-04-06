local WidgetNumberTips = import(".WidgetNumberTips")
local WidgetChangeMap = import(".WidgetChangeMap")
local WidgetHomeBottom = class("WidgetHomeBottom", function()
    local bottom_bg = display.newSprite("bottom_bg_768x136.png")
    if display.width >640 then
        bottom_bg:scale(display.width/768)
    end
    bottom_bg:setTouchEnabled(true)
    return bottom_bg
end)

local function OnBottomButtonClicked(event)
    print(event.target:getTag())
end
function WidgetHomeBottom:ctor(callback)
    -- 底部按钮
    local first_row = 64
    local first_col = 240
    local label_padding = 20
    local padding_width = 100
    for i, v in ipairs({
        {"bottom_icon_mission_128x128.png", _("任务")},
        {"bottom_icon_package_128x128.png", _("物品")},
        {"mail_icon_128x128.png", _("邮件")},
        {"bottom_icon_alliance_128x128.png", _("联盟")},
        {"bottom_icon_package_77x67.png", _("更多")},
    }) do
        local col = i - 1
        local x, y = first_col + col * padding_width, first_row
        local button = cc.ui.UIPushButton.new({normal = v[1]})
            :onButtonClicked(callback or OnBottomButtonClicked)
            :addTo(self):pos(x, y)
            :onButtonPressed(function(event)
            event.target:runAction(cc.ScaleTo:create(0.1, 0.7))
            end):onButtonRelease(function(event)
            event.target:runAction(cc.ScaleTo:create(0.1, 1))
            end):setTag(i)
        UIKit:ttfLabel({
            text = v[2],
            size = 16,
            color = 0xf5e8c4})
            :addTo(self):align(display.CENTER,x, y-40)
        if i == 1 then
            self.task_count = WidgetNumberTips.new():addTo(self):pos(x+20, first_row+20)
        elseif i == 3 then
            self.mail_count = WidgetNumberTips.new():addTo(self):pos(x+20, first_row+20)
        end
    end
end



return WidgetHomeBottom


