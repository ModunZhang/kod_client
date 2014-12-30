local window = import("..utils.window")
local AllianceLayer = import("..layers.AllianceLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local AllianceScene = class("AllianceScene", MapScene)
local Alliance = import("..entity.Alliance")
local GameUIAllianceHome = import("..ui.GameUIAllianceHome")
function AllianceScene:ctor()
    City:ResetAllListeners()
    Alliance_Manager:GetMyAlliance():ResetAllListeners()

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
    self:CreateAllianceUI()
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(10, 10)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)

    self:GetSceneLayer():ZoomTo(1)
end

function AllianceScene:CreateAllianceUI()
    -- local home_page = UIKit:newGameUI('GameUIAllianceHome',Alliance_Manager:GetMyAlliance()):addToScene(self)
    local home_page = GameUIAllianceHome.new(self:GetAlliance()):addTo(self)
    self:GetSceneLayer():AddObserver(home_page)
    home_page:setTouchSwallowEnabled(false)
    self.home_page = home_page
end
function AllianceScene:GetHomePage()
    return self.home_page
end
function AllianceScene:GetAlliance()
    return Alliance_Manager:GetMyAlliance()
end
function AllianceScene:onExit()
    self:GetAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    AllianceScene.super.onExit(self)
end
function AllianceScene:CreateSceneLayer()
    return AllianceLayer.new(self:GetAlliance())
end
function AllianceScene:OnTouchClicked(pre_x, pre_y, x, y)
    local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if building:GetEntity():GetType() ~= "building" then
            self:EnterNotAllianceBuilding(building:GetEntity())
        else
            self:EnterAllianceBuilding(building:GetEntity())
        end
    end
end
function AllianceScene:OnBasicChanged(alliance,changed_map)
    if changed_map.status and changed_map.status.new == 'prepare' then
        app:EnterMyAllianceScene()
    end
end

function AllianceScene:EnterAllianceBuilding(entity)
    local building_info = entity:GetAllianceBuildingInfo()
    local building_name = building_info.name
    local class_name = ""
    if building_name == 'shrine' then
        class_name = "GameUIAllianceShrineEnter"
    elseif building_name == 'palace' then
        class_name = "GameUIAlliancePalaceEnter"
    elseif building_name == 'shop' then
        class_name = "GameUIAllianceShopEnter"    
    elseif building_name == 'orderHall' then
        class_name = "GameUIAllianceOrderHallEnter"
    else
        print("没有此建筑--->",building_name)
        return
    end
    UIKit:newGameUI(class_name,entity,self:GetAlliance()):addToCurrentScene(true)
end

function AllianceScene:EnterNotAllianceBuilding(entity)
    local category = entity:GetCategory()
    local class_name = ""
    if category == 'none' then
        class_name = "GameUIAllianceEnterBase"
    elseif category == 'member' then -- TODO:
        class_name = "GameUIAllianceCityEnter"
        UIKit:newGameUI(class_name,entity,true,self:GetAlliance()):addToCurrentScene(true)
        return 
    elseif category == 'decorate' then 
         class_name = "GameUIAllianceDecorateEnter"
    elseif category == 'village' then -- TODO:
        class_name = "GameUIAllianceVillageEnter"
        UIKit:newGameUI(class_name,entity,true,self:GetAlliance()):addToCurrentScene(true)
        return 
    end
    UIKit:newGameUI(class_name,entity,self:GetAlliance()):addToCurrentScene(true)
end
return AllianceScene












