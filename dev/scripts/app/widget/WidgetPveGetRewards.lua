local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetPVEGetRewards = class("WidgetPVEGetRewards", WidgetPopDialog)


function WidgetPVEGetRewards:ctor()
    WidgetPVEGetRewards.super.ctor(self, 300, _("完成奖励"), display.cy + 150)
end
function WidgetPVEGetRewards:onEnter()
    WidgetPVEGetRewards.super.onEnter(self)

    local s = self:GetBody():getContentSize()
    local bg = display.newSprite("pve_background_568x151.png"):addTo(self:GetBody())
        :pos(s.width/2, s.height - 100)
    local s1 = bg:getContentSize()
    display.newSprite("pve_box.png"):addTo(bg):pos(75, s1.height/2)

    UIKit:ttfLabel({text = _("蓝龙宝箱"), size = 22, color = 0x403c2f})
        :addTo(bg):align(display.LEFT_CENTER, 150, s1.height-30)
    UIKit:ttfLabel({
        text = _("巨龙宝箱, 随机开出巨龙晋级材料和一定数量的建筑材料"),
        size = 20,
        color = 0x615b44,
        dimensions = cc.size(380, 70),
        margin = 1,
        lineHeight = 35,
    })
        :addTo(bg):align(display.LEFT_TOP, 150, s1.height-60)


    cc.ui.UIPushButton.new({normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png", disabled = "yellow_disable_185x65.png"})
        :addTo(self:GetBody()):pos(s.width/2, 60)
        :setButtonLabel(UIKit:ttfLabel({text = _("领取"), size = 24, color = 0xffedae}))
        :onButtonClicked(function()

            end):setButtonEnabled(false)
end





return WidgetPVEGetRewards

