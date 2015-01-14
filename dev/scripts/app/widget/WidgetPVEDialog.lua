local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetPVEDialog = class("WidgetPVEDialog", WidgetPopDialog)


function WidgetPVEDialog:ctor(title)
    WidgetPVEDialog.super.ctor(self, 250, title, display.cy + 150)

    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.LEFT_CENTER, 100, 520)
        :addTo(self):flipX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.RIGHT_CENTER, 100 + 133, 520)
        :addTo(self)
    display.newSprite(self:GetIcon()):addTo(self):pos(100 + 133 * 0.5, 520)

    --
    local level_bg = display.newSprite("back_ground_138x34.png")
        :addTo(self):pos(100 + 133 * 0.5, 520 - 100)
    local size = level_bg:getContentSize()
    UIKit:ttfLabel({
        text = self:GetTitle(),
        size = 20,
        color = 0x514d3e,
    }):addTo(level_bg):align(display.CENTER, size.width/2 , size.height/2)

    --
    UIKit:ttfLabel({
        text = self:GetDesc(),
        size = 18,
        color = 0x797154,
        dimensions = cc.size(300,0)
    }):align(display.LEFT_TOP, 100 + 180, 550):addTo(self)

    --
    local param = self:SetUpButtons()
    for i = #param, 1, -1 do
        cc.ui.UIPushButton.new({normal = "btn_138x110.png",pressed = "btn_pressed_138x110.png"})
            :addTo(self):pos(590 - (#param - i) * 138, display.cy - 145):setButtonLabel(UIKit:ttfLabel({
            text = param[i].label,
            size = 25,
            color = 0xffedae}))
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    if type(param[i].callback) == "function" then
                        param[i].callback()
                    else
                        self:removeFromParent()
                    end
                end
            end)
    end
end
function WidgetPVEDialog:GetIcon()
    return "airship_106x81.png"
end
function WidgetPVEDialog:GetTitle()
    return ""
end
function WidgetPVEDialog:GetDesc()
    return ""
end
function WidgetPVEDialog:SetUpButtons()
    return { { label = _("离开") } }
end




return WidgetPVEDialog




