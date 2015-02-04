local window = import("..utils.window")
local MultiAllianceLayer = import("..layers.MultiAllianceLayer")
local WidgetPushButton = import("..widget.WidgetPushButton")
local MapScene = import(".MapScene")
local AllianceScene = class("AllianceScene", MapScene)
local Alliance = import("..entity.Alliance")
local GameUIAllianceHome = import("..ui.GameUIAllianceHome")
function AllianceScene:ctor()
    AllianceScene.super.ctor(self)
end
function AllianceScene:onEnter()
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:addArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Blue_dragon.ExportJson")


    AllianceScene.super.onEnter(self)
    
    self:CreateAllianceUI()
    self:GotoCurrectPosition()
    app:GetAudioManager():PlayGameMusic("AllianceScene")
    self:GetSceneLayer():ZoomTo(1)

    self:GetAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self:GetAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.OPERATION)
    local alliance_map = self:GetAlliance():GetAllianceMap()
    local allianceShirine = self:GetAlliance():GetAllianceShrine()
    alliance_map:AddListenOnType(allianceShirine,alliance_map.LISTEN_TYPE.BUILDING_LEVEL)
end
function AllianceScene:GotoCurrectPosition()
    local location = self:GetAlliance():GetSelf().location
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(location.x, location.y)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
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
    return MultiAllianceLayer.new(nil, self:GetAlliance())
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
    -- if changed_map.status and changed_map.status.new == 'prepare' then
    --     app:EnterMyAllianceScene()
    -- end
    if changed_map.terrain then
        app:EnterMyAllianceScene()
    end
end
function AllianceScene:ChangeTerrain()
    self:GetSceneLayer():ChangeTerrain()
end
function AllianceScene:OnOperation(alliance,operation_type)
    if operation_type == "quit" then
        UIKit:showMessageDialog(_("提示"),_("您已经被逐出联盟"), function()
            app:EnterMyCityScene()
        end,nil,false)
    end
end

function AllianceScene:EnterAllianceBuilding(entity)
    local isMyAlliance = true
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
    elseif building_name == 'moonGate' then
        class_name = "GameUIAllianceMoonGateEnter"
    else
        print("没有此建筑--->",building_name)
        return
    end
    UIKit:newGameUI(class_name,entity,isMyAlliance,self:GetAlliance()):addToCurrentScene(true)
end

function AllianceScene:EnterNotAllianceBuilding(entity)
    local isMyAlliance = true
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
    UIKit:newGameUI(class_name,entity,isMyAlliance,self:GetAlliance()):addToCurrentScene(true)
end
return AllianceScene












