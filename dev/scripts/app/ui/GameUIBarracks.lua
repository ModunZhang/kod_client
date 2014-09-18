--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIBarracks = UIKit:createUIClass("GameUIBarracks", "GameUIWithCommonHeader")
function GameUIBarracks:ctor(city)
    GameUIBarracks.super.ctor(self, city, _("兵营"))
end
function GameUIBarracks:onEnter()
    GameUIBarracks.super.onEnter(self)
    self.tips = self:CreateTips()
end
function GameUIBarracks:CreateTips()
    local back_ground = cc.ui.UIImage.new("back_ground_549x108.png",
        {scale9 = true}):addTo(self)
        :align(display.CENTER, display.cx, display.top - 160)

    local align_x = 30
    cc.ui.UILabel.new({
        text = _("招募队列空闲"),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2):align(display.LEFT_BOTTOM, align_x, 60)

    cc.ui.UILabel.new({
        text = _("请选择一个兵种进行招募"),
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2):align(display.LEFT_BOTTOM, align_x, 20)

    return back_ground
end
function GameUIBarracks:CreateTips()
    local back_ground = cc.ui.UIImage.new("back_ground_549x108.png",
        {scale9 = true}):addTo(self)
        :align(display.CENTER, display.cx, display.top - 160)

    local align_x = 30
    cc.ui.UILabel.new({
        text = _("招募队列空闲"),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2):align(display.LEFT_BOTTOM, align_x, 60)

    cc.ui.UILabel.new({
        text = _("请选择一个兵种进行招募"),
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2):align(display.LEFT_BOTTOM, align_x, 20)

    return back_ground
end
return GameUIBarracks
