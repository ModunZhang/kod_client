local window = import("..utils.window")
local TwoAllianceLayer = import("..layers.TwoAllianceLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local AllianceBattleScene = class("AllianceBattleScene", MapScene)

function AllianceBattleScene:ctor()
    AllianceBattleScene.super.ctor(self)

    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Blue_dragon.ExportJson")

    manager:addArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Blue_dragon.ExportJson")
end
function AllianceBattleScene:onEnter()
    AllianceBattleScene.super.onEnter(self)
    self:CreateAllianceUI()
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(10, 10)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end

function AllianceBattleScene:CreateAllianceUI()
    local home_page = UIKit:newGameUI('GameUIAllianceHome',Alliance_Manager:GetMyAlliance()):addToScene(self)
    self:GetSceneLayer():AddObserver(home_page)
    home_page:setTouchSwallowEnabled(false)
    self.home_page = home_page
end
function AllianceBattleScene:GetHomePage()
    return self.home_page
end
function AllianceBattleScene:GetAlliance()
    return Alliance_Manager:GetMyAlliance()
end
function AllianceBattleScene:onExit()
    AllianceBattleScene.super.onExit(self)
end
function AllianceBattleScene:CreateSceneLayer()
    local scene = TwoAllianceLayer.new(self:GetAlliance(), self:GetAlliance())
    :addTo(self)
    :ZoomTo(1)
    return scene
end
function AllianceBattleScene:OnTouchClicked(pre_x, pre_y, x, y)
    local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        dump(building:GetEntity())
        if building:GetEntity():GetType() ~= "building" then
            UIKit:newGameUI('GameUIAllianceEnter',Alliance_Manager:GetMyAlliance(),building:GetEntity()):addToCurrentScene(true)
        else
            local building_info = building:GetEntity():GetAllianceBuildingInfo()
            print("index x y ",x,y,building_info.name)
            LuaUtils:outputTable("building_info", building_info)
            UIKit:newGameUI('GameUIAllianceEnter',Alliance_Manager:GetMyAlliance(),building_info):addToCurrentScene(true)
        end
    end
end
return AllianceBattleScene












