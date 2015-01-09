local window = import("..utils.window")
local MultiAllianceLayer = import("..layers.MultiAllianceLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local AllianceBattleScene = class("AllianceBattleScene", MapScene)
local GameUIAllianceHome = import("..ui.GameUIAllianceHome")
local Alliance = import("..entity.Alliance")

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
    local location = self:GetAlliance():GetSelf().location
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(location.x, location.y, self:GetAlliance():Id())
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
    self:GetAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    app:GetAudioManager():PlayGameMusic("AllianceBattleScene")
    self:GetSceneLayer():ZoomTo(1)
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
    return self:GetAlliance():GetEnemyAlliance()
end

function AllianceBattleScene:onExit()
    self:GetAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    AllianceBattleScene.super.onExit(self)
end
function AllianceBattleScene:CreateSceneLayer()
    local pos = self:GetAlliance():FightPosition()
    local arrange = (pos == "top" or pos == "bottom") and MultiAllianceLayer.ARRANGE.H or MultiAllianceLayer.ARRANGE.V
    if pos == "top" or pos == "left" then
        return MultiAllianceLayer.new(arrange, self:GetAlliance(), self:GetEnemyAlliance())
    else
        return MultiAllianceLayer.new(arrange, self:GetEnemyAlliance(), self:GetAlliance())
    end
end
function AllianceBattleScene:OnTouchClicked(pre_x, pre_y, x, y)
    local building,isMyAlliance = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if building:GetEntity():GetType() ~= "building" then
            self:EnterNotAllianceBuilding(building:GetEntity(),isMyAlliance)
        else
            self:EnterAllianceBuilding(building:GetEntity(),isMyAlliance)
        end
    end
end
function AllianceBattleScene:OnBasicChanged(alliance,changed_map)
    if changed_map.status and changed_map.status.new == 'protect' then
        app:GetAudioManager():PlayGameMusic("AllianceScene")
    end
end
function AllianceBattleScene:EnterAllianceBuilding(entity,isMyAlliance)
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
    UIKit:newGameUI(class_name,entity,isMyAlliance,self:GetAlliance(),self:GetEnemyAlliance()):addToCurrentScene(true)
end

function AllianceBattleScene:EnterNotAllianceBuilding(entity,isMyAlliance)
    local category = entity:GetCategory()
    local class_name = ""
    if category == 'none' then
        class_name = "GameUIAllianceEnterBase"
    elseif category == 'member' then
        class_name = "GameUIAllianceCityEnter"
    elseif category == 'decorate' then
        class_name = "GameUIAllianceDecorateEnter"
    elseif category == 'village' then
        class_name = "GameUIAllianceVillageEnter"
    end
    UIKit:newGameUI(class_name,entity,isMyAlliance,self:GetAlliance(),self:GetEnemyAlliance()):addToCurrentScene(true)
end
return AllianceBattleScene














