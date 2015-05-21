local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetPVEGetRewards = class("WidgetPVEGetRewards", WidgetPopDialog)


function WidgetPVEGetRewards:ctor(percent)
    WidgetPVEGetRewards.super.ctor(self, 414, _("完成奖励"), display.cy + 150)
    self.percent = percent or 0
end
function WidgetPVEGetRewards:onEnter()
    WidgetPVEGetRewards.super.onEnter(self)
    local s = self:GetBody():getContentSize()

    display.newSprite("pve_icon_airship.png"):addTo(self:GetBody())
    :pos(70, s.height - 90)

    UIKit:ttfLabel({text = _("关卡探索进度"), size = 20, color = 0x403c2f}):addTo(self:GetBody())
    :align(display.LEFT_CENTER, 130, s.height - 60)

    local pbg = display.newSprite("progress_bar_458x40_1.png"):addTo(self:GetBody())
    :align(display.LEFT_CENTER, 130, s.height - 110)
    local s2 = pbg:getContentSize()
    UIKit:commonProgressTimer("progress_bar_458x40_2.png"):addTo(pbg)
    :align(display.LEFT_CENTER, 0, s2.height/2):setPercentage(self.percent)

    UIKit:ttfLabel({text = string.format("%d%%", self.percent), size = 22, color = 0xffedae, shadow = true}):addTo(pbg,1)
    :align(display.CENTER, s2.width/2, s2.height/2)

    local bg = display.newSprite("pve_background_568x151.png"):addTo(self:GetBody())
        :pos(s.width/2, s.height - 230)
    local s1 = bg:getContentSize()
    display.newSprite("pve_box.png"):addTo(bg):pos(75, s1.height/2)

    UIKit:ttfLabel({text = _("蓝龙宝箱"), size = 22, color = 0x403c2f})
        :addTo(bg):align(display.LEFT_CENTER, 150, s1.height-35)
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

            end):setButtonEnabled(self.percent >= 100)
end





return WidgetPVEGetRewards

