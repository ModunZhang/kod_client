local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local SpriteButton = import("..ui.SpriteButton")
local BuildingLevelUpUINode = import("..ui.BuildingLevelUpUINode")
local BuildingUpgradeUINode = import("..ui.BuildingUpgradeUINode")
local CityLayer = import("..layers.CityLayer")
local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local IsoMapAnchorBottomLeft = import("..map.IsoMapAnchorBottomLeft")
local MapScene = import(".MapScene")
import('app.service.ListenerService')
import('app.service.PushService')
local CityScene = class("CityScene", MapScene)

local app = app
local timer = app.timer
local debug = false
function CityScene:ctor()
    CityScene.super.ctor(self)
    self:LoadAnimation()
end
function CityScene:onEnter()
    CityScene.super.onEnter(self)
    self.scene_ui_layer = self:CreateSceneUILayer()
    home_page = self:CreateHomePage()
    ListenerService:start()

    self:GetSceneLayer():AddObserver(self)
    self:GetSceneLayer():InitWithCity(City)
    self:GetSceneLayer():IteratorInnnerBuildings(function(_, building)
        self.scene_ui_layer:NewUIFromBuildingSprite(building)
    end)
    City:AddListenOnType(self, City.LISTEN_TYPE.UPGRADE_BUILDING)
    self:PlayBackgroundMusic()
end
function CityScene:onExit()
    self:stopAllActions()
    audio.stopMusic()
    audio.stopAllSounds()
    City:ResetAllListeners()
end
-- init ui
function CityScene:LoadAnimation()
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
function CityScene:CreateSceneLayer()
    local scene = CityLayer.new():addTo(self)
    local origin_point = scene:GetPositionIndex(0, 0)
    self.iso_map = IsoMapAnchorBottomLeft.new({
        tile_w = 80, tile_h = 56, map_width = 50, map_height = 50, base_x = origin_point.x, base_y = origin_point.y
    })
    scene:ZoomTo(0.7)
    return scene
end
function CityScene:CreateSceneUILayer()
    local scene_ui_layer = display.newLayer():addTo(self)
    scene_ui_layer:setTouchSwallowEnabled(false)
    function scene_ui_layer:Init()
        self.levelup_node = display.newNode():addTo(self)
        self.levelup_node:setCascadeOpacityEnabled(true)
        self.ui = {}
        self.level_up_ui = {}
        self.lock_buttons = {}
        self.status = nil
    end
    function scene_ui_layer:NewLockButtonFromBuildingSprite(building_sprite)
        local lock_button = SpriteButton.new(building_sprite, City):addTo(self, 1)
        building_sprite:AddObserver(lock_button)
        City:AddListenOnType(lock_button, City.LISTEN_TYPE.UPGRADE_BUILDING)
        table.insert(self.lock_buttons, lock_button)
        building_sprite:OnSceneMove()
    end
    function scene_ui_layer:RemoveAllLockButtons()
        for _, v in pairs(self.lock_buttons) do
            v:removeFromParentAndCleanup(true)
            City:RemoveListenerOnType(v, City.LISTEN_TYPE.UPGRADE_BUILDING)
        end
        self.lock_buttons = {}
    end
    function scene_ui_layer:NewUIFromBuildingSprite(building_sprite)
        local progress = BuildingUpgradeUINode.new():addTo(self)
        building_sprite:AddObserver(progress)
        table.insert(self.ui, progress)

        local levelup = BuildingLevelUpUINode.new():addTo(self.levelup_node)
        building_sprite:AddObserver(levelup)
        table.insert(self.ui, levelup)

        building_sprite:CheckCondition()
        building_sprite:OnSceneMove()
    end
    function scene_ui_layer:RemoveUIFromBuildingSprite(building_sprite)
        building_sprite:NotifyObservers(function(ob)
            table.foreachi(self.ui, function(i, v)
                if ob == v then
                    table.remove(self.ui, i)
                    v:removeFromParentAndCleanup(true)
                end
            end)
        end)
    end
    function scene_ui_layer:ShowLevelUpNode()
        if self.status == "show" then
            return
        end
        self.levelup_node:stopAllActions()
        self.levelup_node:fadeTo(0.5, 255)
        self.status = "show"
    end
    function scene_ui_layer:HideLevelUpNode()
        if self.status == "hide" then
            return
        end
        self.levelup_node:stopAllActions()
        self.levelup_node:fadeTo(0.5, 0)
        self.status = "hide"
    end
    scene_ui_layer:Init()
    return scene_ui_layer
end
function CityScene:CreateHomePage()
    local home = UIKit:newGameUI('GameUIHome', City):addToScene(self)
    home:setTouchSwallowEnabled(false)
    return home
end
function CityScene:onEnterTransitionFinish()
    self:GotoLogicPoint(6, 4)
end

-- function
function CityScene:GotoLogicPoint(x, y)
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(x, y)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function CityScene:PlayBackgroundMusic()
    -- audio.playMusic("audios/music_city.mp3", true)
    -- audio.playSound("audios/sfx_peace.mp3", true)
    -- self:performWithDelay(function()
    --     self:PlayBackgroundMusic()
    -- end, 113 + 30)
end
function CityScene:ChangeTerrain(terrain_type)
    self:GetSceneLayer():ChangeTerrain(terrain_type)
end

--- callback
function CityScene:OnUpgradingBegin()
    audio.playSound("ui_building_upgrade_start.mp3")
end
function CityScene:OnUpgrading()

end
function CityScene:OnUpgradingFinished()

end
function CityScene:OnCreateDecoratorSprite(building_sprite)
    self.scene_ui_layer:NewUIFromBuildingSprite(building_sprite)
end
function CityScene:OnDestoryDecoratorSprite(building_sprite)
    self.scene_ui_layer:RemoveUIFromBuildingSprite(building_sprite)
end
function CityScene:OnTreesChanged(trees, road)
    self.scene_ui_layer:RemoveAllLockButtons()
    table.foreach(trees, function(_, tree_)
        if tree_:GetEntity().location_id then
            local building = City:GetBuildingByLocationId(tree_:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                self.scene_ui_layer:NewLockButtonFromBuildingSprite(tree_)
            end
        end
    end)
    if road then
        if road:GetEntity().location_id then
            local building = City:GetBuildingByLocationId(road:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                self.scene_ui_layer:NewLockButtonFromBuildingSprite(road)
            end
        end
    end
end
function CityScene:OnTowersChanged(old_towers, new_towers)
    if self.scene_ui_layer then
        table.foreach(old_towers, function(k, tower)
            if tower:GetEntity():IsUnlocked() then
                self.scene_ui_layer:RemoveUIFromBuildingSprite(tower)
            end
        end)
        table.foreach(new_towers, function(k, tower)
            if tower:GetEntity():IsUnlocked() then
                self.scene_ui_layer:NewUIFromBuildingSprite(tower)
            end
        end)
    end
end
function CityScene:OnGateChanged(old_walls, new_walls)
    if self.scene_ui_layer then
        table.foreach(old_walls, function(k, wall)
            if wall:GetEntity():IsGate() then
                self.scene_ui_layer:RemoveUIFromBuildingSprite(wall)
            end
        end)

        table.foreach(new_walls, function(k, wall)
            if wall:GetEntity():IsGate() then
                self.scene_ui_layer:NewUIFromBuildingSprite(wall)
            end
        end)
    end
end

-- override
function CityScene:OnTwoTouch(x1, y1, x2, y2, event_type)
    CityScene.super.OnTwoTouch(self, x1, y1, x2, y2, event_type)
    if event_type == "moved" then
        if scene:getScale() < 0.5 then
            self.scene_ui_layer:HideLevelUpNode()
        else
            self.scene_ui_layer:ShowLevelUpNode()
        end
    end
end
function CityScene:OnTouchBegan(pre_x, pre_y, x, y)
    if not debug then return end
    local citynode = self:GetSceneLayer():GetCityNode()
    local point = citynode:convertToNodeSpace(cc.p(x, y))
    local tx, ty = self.iso_map:ConvertToLogicPosition(point.x, point.y)
    if not self.building then
        local building = self:GetSceneLayer():GetClickedObject(tx, ty, x, y)
        if building then
            local lx, ly = building:GetLogicPosition()
            building._shiftx = lx - tx
            building._shifty = ly - ty
            building:zorder(99999999)
            self.building = building
        end
    end
end
function CityScene:OnTouchEnd(pre_x, pre_y, x, y)
    if not debug then return end
    local citynode = self:GetSceneLayer():GetCityNode()
    local point = citynode:convertToNodeSpace(cc.p(x, y))
    local tx, ty = self.iso_map:ConvertToLogicPosition(point.x, point.y)
    if self.building then
        local lx, ly = self.building:GetLogicPosition()
        self.building:zorder(lx + ly * 50 + 100)
        if self.building._shiftx + tx == lx and
            self.building._shifty + ty == ly then
        end
    end
    self.building = nil
end
function CityScene:OnTouchCancelled(pre_x, pre_y, x, y)

end
function CityScene:OnTouchMove(pre_x, pre_y, x, y)
    if debug then
        if self.building then
            local citynode = self:GetSceneLayer():GetCityNode()
            local point = citynode:convertToNodeSpace(cc.p(x, y))
            local lx, ly = self.iso_map:ConvertToLogicPosition(point.x, point.y)
            local bx, by = self.building:GetLogicPosition()
            local is_moved_one_more = lx ~= bx or ly ~= by
            if is_moved_one_more then
                self.building:SetLogicPosition(lx + self.building._shiftx, ly + self.building._shifty)
            end
            return
        end
    end
    CityScene.super.OnTouchMove(self, pre_x, pre_y, x, y)
end
function CityScene:OnTouchClicked(pre_x, pre_y, x, y)
    local citynode = self:GetSceneLayer():GetCityNode()
    local point = citynode:convertToNodeSpace(cc.p(x, y))
    local tx, ty = self.iso_map:ConvertToLogicPosition(point.x, point.y)
    local building = self:GetSceneLayer():GetClickedObject(tx, ty, x, y)
    if building then
        if building:GetEntity():GetType() == "ruins" then
            local select_ruins_list = City:GetNeighbourRuinWithSpecificRuin(building:GetEntity())
            local select_ruins = building:GetEntity()
            UIKit:newGameUI('GameUIBuild', City, select_ruins, select_ruins_list):addToScene(self, true)
        elseif building:GetEntity():GetType() == "keep" then
            self._keep_page = UIKit:newGameUI('GameUIKeep',City,building:GetEntity())
            self._keep_page:addToScene(self, true)
        elseif building:GetEntity():GetType() == "dragonEyrie" then
            UIKit:newGameUI('GameUIDragonEyrie', City,building:GetEntity()):addToCurrentScene(true)
        elseif building:GetEntity():GetType() == "toolShop" then
            UIKit:newGameUI('GameUIToolShop', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "blackSmith" then
            UIKit:newGameUI('GameUIBlackSmith', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "materialDepot" then
            UIKit:newGameUI('GameUIMaterialDepot', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "barracks" then
            UIKit:newGameUI('GameUIBarracks', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "armyCamp" then
            self._armyCamp_page = UIKit:newGameUI('GameUIArmyCamp',City,building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "townHall" then
            self._armyCamp_page = UIKit:newGameUI('GameUITownHall',City,building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "foundry"
            or building:GetEntity():GetType() == "stoneMason"
            or building:GetEntity():GetType() == "lumbermill"
            or building:GetEntity():GetType() == "mill" then
            self._armyCamp_page = UIKit:newGameUI('GameUIPResourceBuilding',City,building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "warehouse" then
            self._warehouse_page = UIKit:newGameUI('GameUIWarehouse',City,building:GetEntity())
            self._warehouse_page:addToScene(self, true)
        elseif iskindof(building:GetEntity(), 'ResourceUpgradeBuilding') then
            if building:GetEntity():GetType() == "dwelling" then
                UIKit:newGameUI('GameUIDwelling',building:GetEntity(), City):addToCurrentScene(true)
            else
                UIKit:newGameUI('GameUIResource',building:GetEntity()):addToCurrentScene(true)
            end
        elseif building:GetEntity():GetType() == "hospital" then
            UIKit:newGameUI('GameUIHospital', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "watchTower" then
            UIKit:newGameUI('GameUIWatchTower', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "tradeGuild" then
            UIKit:newGameUI('GameUITradeGuild', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "wall" then
            UIKit:newGameUI('GameUIWall', City, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "tower" then
            UIKit:newGameUI('GameUITower', City, building:GetEntity()):addToScene(self, true)
        end

    end
end


return CityScene





























