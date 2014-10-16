local window = import("..utils.window")
local AllianceLayer = import("..layers.AllianceLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local AllianceScene = class("AllianceScene", MapScene)

function AllianceScene:ctor()
    AllianceScene.super.ctor(self)
end
function AllianceScene:onEnter()


    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("animations/chuizidonghua.ExportJson")
    manager:removeArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Blue_dragon.ExportJson")

    manager:addArmatureFileInfo("animations/chuizidonghua.ExportJson")
    manager:addArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Blue_dragon.ExportJson")

    AllianceScene.super.onEnter(self)

    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(10, 10)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)

    -- local button = WidgetPushButton.new(
    --     {normal = "green_btn_up.png", pressed = "green_btn_down.png"}
    --     ,{scale9 = false}
    -- ):setButtonLabel(cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     size = 24,
    --     font = UIKit:getFontFilePath(),
    --     color = UIKit:hex2c3b(0xfff3c7)}))
    --     :addTo(self)
    --     :align(display.CENTER, window.cx, window.cy)
    --     :onButtonClicked(function()
    --         app:enterScene("CityScene")
    --     end)
end
function AllianceScene:onExit()
    AllianceScene.super.onExit(self)
    City:ResetAllListeners()
end
function AllianceScene:CreateSceneLayer()
    local scene = AllianceLayer.new()
    :addTo(self)
    :ZoomTo(0.7)
    return scene
end

return AllianceScene































