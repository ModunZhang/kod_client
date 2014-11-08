local window = import("..utils.window")
local AllianceLayer = import("..layers.AllianceLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local AllianceScene = class("AllianceScene", MapScene)

function AllianceScene:ctor()
    AllianceScene.super.ctor(self)

    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("animations/chuizidonghua.ExportJson")
    manager:removeArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Blue_dragon.ExportJson")

    manager:addArmatureFileInfo("animations/chuizidonghua.ExportJson")
    manager:addArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Blue_dragon.ExportJson")
end
function AllianceScene:onEnter()
    AllianceScene.super.onEnter(self)
    local home = UIKit:newGameUI('GameUIAllianceHome'):addToScene(self)
    home:setTouchSwallowEnabled(false)

    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(10, 10)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function AllianceScene:CreateSceneLayer()
    local scene = AllianceLayer.new()
    :addTo(self)
    :ZoomTo(0.5)
    return scene
end
function AllianceScene:OnTouchClicked(pre_x, pre_y, x, y)
    local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        dump(building:GetEntity())
        if building:GetEntity():GetType() ~= "building" then
            UIKit:newGameUI('GameUIAllianceEnter',building:GetEntity()):addToCurrentScene(true)
        else
            local building_info = building:GetEntity():GetAllianceBuildingInfo()
            LuaUtils:outputTable("building_info", building_info)
            UIKit:newGameUI('GameUIAllianceEnter',building_info):addToCurrentScene(true)
        end
    end
end
return AllianceScene












