local TabButtons = import('.TabButtons')
local GameUIBuild = UIKit:createUIClass('GameUIBuild')




function GameUIBuild:ctor()
    GameUIBuild.super.ctor(self)
    local top_bg = display.newSprite("back_ground.png")
        :align(display.LEFT_TOP, display.left, display.top - 40)
        :addTo(self)
end

function GameUIBuild:onEnter()
    GameUIBuild.super.onEnter(self)

    self:CreateTitle()
    self:CreateHomeButton()
    self:CreateShopButton()
    local tab_buttons = TabButtons.new({
        {
            label = _("升级"),
            tag = "Upgrade",
            default = true,
        },
        {
            label = _("城民"),
            tag = "Citizen",
        },
        {
            label = _("城民"),
            tag = "Citizen1",
        },
    },
    {
        gap = -4,
        margin_left = -2,
        margin_right = -2,
        margin_up = -6,
        margin_down = 1
    },
    function(tag)
        if tag == "Upgrade" then

        end
    end):addTo(self):pos(display.cx, display.bottom + 100)

end
function GameUIBuild:onExit()

end

function GameUIBuild:CreateTitle()
    cc.ui.UIImage.new("head_bg.png")
    :align(display.TOP_CENTER, display.cx, display.top)
    :addTo(self)
    self.title_label = ui.newTTFLabelWithShadow({text = _("建造列表"),
        font = UIKit:getFontFilePath(),
        size = 30,
        color = UIKit:hex2c3b(0xffedae),
        shadowColor = UIKit:hex2c3b(0xffedae)
    }):addTo(self)
    self.title_label:pos(display.cx-self.title_label:getCascadeBoundingBox().size.width/2, display.top-35)
end

function GameUIBuild:CreateHomeButton()
    self.home_button = cc.ui.UIPushButton.new({normal = "home_btn_up.png",pressed = "home_btn_down.png"})
    :onButtonClicked(function(event)
        self:leftButtonClicked()
    end)
    :align(display.LEFT_TOP, display.left , display.top)
    :addTo(self)
    cc.ui.UIImage.new("home_icon.png")
    :pos(27, -72)
    :addTo(self.home_button)
end

function GameUIBuild:CreateShopButton()
    self.gem_button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up.png",pressed = "gem_btn_down.png"}
    ):onButtonClicked(function(event)
        dump(event)
    end):addTo(self)
    self.gem_button:align(display.RIGHT_TOP, display.right, display.top)
    cc.ui.UIImage.new("home/gem.png")
    :addTo(self.gem_button)
    :pos(-80, -75)

    local gem_num_bg = cc.ui.UIImage.new("gem_num_bg.png"):addTo(self.gem_button):pos(-85, -85)
    local pos = gem_num_bg:getAnchorPointInPoints()
    ui.newTTFLabel({
        text = ""..City.resource_manager:GetGemResource():GetValue(),
        font = UIKit:getFontFilePath(),
        size = 14,
        color = UIKit:hex2c3b(0xfdfac2)})
        :addTo(gem_num_bg)
        :align(display.CENTER, 40, 15)
end


return GameUIBuild


