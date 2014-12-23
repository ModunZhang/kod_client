local window = import("..utils.window")
local TwoAllianceLayer = import("..layers.TwoAllianceLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local AllianceBattleScene = class("AllianceBattleScene", MapScene)
local GameUIAllianceHome = import("..ui.GameUIAllianceHome")
local Alliance = import("..entity.Alliance")
local GameUIAllianceEnter = import("..ui.GameUIAllianceEnter")

function AllianceBattleScene:ctor()
    City:ResetAllListeners()
    Alliance_Manager:GetMyAlliance():ResetAllListeners()
    
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
    self:GetAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
end

function AllianceBattleScene:CreateAllianceUI()
    local home_page = GameUIAllianceHome.new(self:GetAlliance()):addTo(self)
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

function AllianceBattleScene:GetEnemyAlliance()
    return Alliance_Manager:GetEnemyAlliance()
end

function AllianceBattleScene:onExit()
    self:GetAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    AllianceBattleScene.super.onExit(self)
end
function AllianceBattleScene:CreateSceneLayer()
    local scene = TwoAllianceLayer.new(self:GetAlliance(),self:GetEnemyAlliance())
    :addTo(self)
    :ZoomTo(1)
    return scene
end
function AllianceBattleScene:OnTouchClicked(pre_x, pre_y, x, y)
    local building,isMyAlliance = self:GetSceneLayer():GetClickedObject(x, y)
    print(isMyAlliance,"isMyAlliance--->")
    if building then
        local mode = isMyAlliance and GameUIAllianceEnter.MODE.Normal or GameUIAllianceEnter.MODE.Enemy
        if building:GetEntity():GetType() ~= "building" then
            UIKit:newGameUI('GameUIAllianceEnter'
                ,isMyAlliance and self:GetAlliance() or self:GetEnemyAlliance()
                ,building:GetEntity()
                ,mode
            ):addToCurrentScene(true)
        else
            local building_info = building:GetEntity():GetAllianceBuildingInfo()
            UIKit:newGameUI('GameUIAllianceEnter'
                ,isMyAlliance and self:GetAlliance() or  self:GetEnemyAlliance() 
                ,building_info
                ,mode
            ):addToCurrentScene(true)
        end
    end
end
function AllianceBattleScene:OnBasicChanged(alliance,changed_map)
    if changed_map.status and changed_map.status.new == 'protect' then
        app:EnterMyAllianceScene()
    end
end
return AllianceBattleScene












