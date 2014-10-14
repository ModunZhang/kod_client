local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local AllianceScene = class("AllianceScene", function()
    return display.newScene("AllianceScene")
end)

function AllianceScene:ctor()
    app:makeLuaVMSnapshot()
end
function AllianceScene:onEnter()
    local button = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"}
        ,{scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.cx, window.cy)
        :onButtonClicked(function()
            app:enterScene("CityScene")
        end)
    -- self:performWithDelay(function()
    --     app:makeLuaVMSnapshot()
    --     self:performWithDelay(function()
    --         app:makeLuaVMSnapshot()
    --         app:checkLuaVMLeaks()
    --     end, 1)
    -- end, 1)
end
function AllianceScene:onExit()
    City:ResetAllListeners()
end

return AllianceScene































