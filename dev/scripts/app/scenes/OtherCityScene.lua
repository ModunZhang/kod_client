local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local UILib = import("..ui.UILib")
local SpriteButton = import("..ui.SpriteButton")
local BuildingLevelUpUINode = import("..ui.BuildingLevelUpUINode")
local BuildingUpgradeUINode = import("..ui.BuildingUpgradeUINode")
local CityLayer = import("..layers.CityLayer")
local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local IsoMapAnchorBottomLeft = import("..map.IsoMapAnchorBottomLeft")
local MapScene = import(".MapScene")
local promise = import("..utils.promise")
local Alliance = import("..entity.Alliance")
local OtherCityScene = class("OtherCityScene", MapScene)

local app = app
local timer = app.timer
local DEBUG = false
function OtherCityScene:ctor(city)
    self.city = city
    OtherCityScene.super.ctor(self)
    self:LoadAnimation()
end
function OtherCityScene:onEnter()
    local city = self.city
    OtherCityScene.super.onEnter(self)
    self.scene_ui_layer = self:CreateSceneUILayer()
    home_page = self:CreateHomePage()


    self:GetSceneLayer():AddObserver(self)
    self:GetSceneLayer():InitWithCity(city)
    self:GetSceneLayer():IteratorInnnerBuildings(function(_, building)
        self.scene_ui_layer:NewUIFromBuildingSprite(building)
    end)
    city:AddListenOnType(self, city.LISTEN_TYPE.UPGRADE_BUILDING)
    self:PlayBackgroundMusic()
    self:GotoLogicPoint(6, 4)


    -- Alliance_Manager:GetMyAlliance():AddListenOnType({
    --     OnBasicChanged = function(this, alliance, changed_map)
    --         dump(changed_map)
    --     end}, Alliance.LISTEN_TYPE.BASIC)
    -- Alliance_Manager:GetMyAlliance():AddListenOnType({
    --     OnOperation = function(this, alliance, operation_type)
    --         dump(operation_type)
    --     end}, Alliance.LISTEN_TYPE.OPERATION)
    -- Alliance_Manager:GetMyAlliance():AddListenOnType({
    --     OnMemberChanged = function(this, alliance, changed_map)
    --         dump(changed_map)
    --     end}, Alliance.LISTEN_TYPE.MEMBER)
    -- Alliance_Manager:GetMyAlliance():AddListenOnType({
    --     OnEventsChanged = function(this, alliance, changed_map)
    --         dump(changed_map)
    --     end
    -- }, Alliance.LISTEN_TYPE.EVENTS)

    -- Alliance_Manager:GetMyAlliance():AddListenOnType({
    --     OnJoinEventsChanged = function(this, alliance, changed_map)
    --         dump(changed_map)
    --     end
    -- }, Alliance.LISTEN_TYPE.JOIN_EVENTS)



    -- User:AddListenOnType({
    --     OnRequestAllianceEvents = function(this, user, changed_map)
    --         dump(changed_map)
    --     end
    -- }, User.LISTEN_TYPE.REQUEST_TO_ALLIANCE)

    -- User:AddListenOnType({
    --     OnInviteAllianceEvents = function(this, user, changed_map)
    --         dump(changed_map)
    --     end
    -- }, User.LISTEN_TYPE.INVITE_TO_ALLIANCE)

    self:GetSceneLayer():ZoomTo(0.7)


    -- local ai_create_house_array = {
    --     "woodcutter",
    --     "quarrier",
    --     "miner",
    --     "farmer",
    -- }
    -- local ai_house_index = 1
    -- self:performWithDelay(function()
    --     local city = self.city
    --     print("新一轮ai循环")
    --     -- step 1
    --     -- 先检查小屋可不可以建造,建造小屋的顺序为:
    --     -- 首先检查住宅小屋,造满才能建造其他的小屋
    --     city:IteratorTilesByFunc(function(x, y, tile)
    --         if tile:IsUnlocked() and tile:CanBuildHouses() then
    --             for i = 1, 3 do
    --                 local x, y = tile:GetAbsolutePositionByLocation(i)
    --                 if city:GetAvailableBuildQueueCounts() > 0 then
    --                     local building = city:GetHouseByPosition(x, y)
    --                     if not building then
    --                         print("可以建造!", tile.location_id, i, "dwelling")
    --                         -- 还能不能建造住宅?
    --                         local house_type
    --                         if city:GetLeftBuildingCountsByType("dwelling") > 0 then
    --                             house_type = "dwelling"
    --                         else
    --                             local ht = ai_create_house_array[ai_house_index]
    --                             if city:GetLeftBuildingCountsByType(ht) > 0 then
    --                                 house_type = ht
    --                             else
    --                                 for i, v in ipairs(ai_create_house_array) do
    --                                     if city:GetLeftBuildingCountsByType(v) > 0 then
    --                                         ai_house_index = i
    --                                         house_type = v
    --                                     end
    --                                 end
    --                             end
    --                             -- 下一次造的建筑
    --                             ai_house_index = (ai_house_index - 1) % #ai_create_house_array + 1
    --                         end
    --                         if house_type then
    --                             NetManager:getCreateHouseByLocationPromise(tile.location_id, i, house_type)
    --                         end
    --                         return
    --                     end
    --                 end
    --             end
    --         end
    --     end)

    --     -- step 2
    --     -- 检查能升级的建筑物,如果没有则升级主城

    --     -- step 3
    --     -- 最后检查有没有免费加速的建筑物如果有则加速

    -- end, 1)
end
function OtherCityScene:onExit()
    home_page = nil
    self:stopAllActions()
    audio.stopMusic()
    audio.stopAllSounds()
    OtherCityScene.super.onExit(self)
end
-- init ui
function OtherCityScene:LoadAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    for _, animations in pairs(UILib.soldier_animation_files) do
        for i, ani_file in pairs(animations) do
            manager:removeArmatureFileInfo(ani_file)
            manager:addArmatureFileInfo(ani_file)
        end
    end

    manager:removeArmatureFileInfo("animations/Cloud_Animation.ExportJson")
    manager:removeArmatureFileInfo("animations/chuizidonghua.ExportJson")
    manager:removeArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:removeArmatureFileInfo("animations/Blue_dragon.ExportJson")

    manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
    manager:addArmatureFileInfo("animations/chuizidonghua.ExportJson")
    manager:addArmatureFileInfo("animations/green_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Red_dragon.ExportJson")
    manager:addArmatureFileInfo("animations/Blue_dragon.ExportJson")
end
function OtherCityScene:CreateSceneLayer()
    local scene = CityLayer.new(self):addTo(self)
    local origin_point = scene:GetPositionIndex(0, 0)
    self.iso_map = IsoMapAnchorBottomLeft.new({
        tile_w = 80, tile_h = 56, map_width = 50, map_height = 50, base_x = origin_point.x, base_y = origin_point.y
    })
    return scene
end
function OtherCityScene:CreateSceneUILayer()
    local city = self.city
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
        local lock_button = SpriteButton.new(building_sprite, city):addTo(self, 1)
        building_sprite:AddObserver(lock_button)
        city:AddListenOnType(lock_button, city.LISTEN_TYPE.UPGRADE_BUILDING)
        table.insert(self.lock_buttons, lock_button)
        building_sprite:OnSceneMove()
    end
    function scene_ui_layer:RemoveAllLockButtons()
        for _, v in pairs(self.lock_buttons) do
            v:removeFromParentAndCleanup(true)
            city:RemoveListenerOnType(v, city.LISTEN_TYPE.UPGRADE_BUILDING)
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
function OtherCityScene:CreateHomePage()
    local home = UIKit:newGameUI('GameUIHome', self.city):addToScene(self)
    home:setTouchSwallowEnabled(false)
    return home
end
function OtherCityScene:onEnterTransitionFinish()

end

-- function
function OtherCityScene:GotoLogicPoint(x, y)
    local point = self:GetSceneLayer():ConvertLogicPositionToMapPosition(x, y)
    self:GetSceneLayer():GotoMapPositionInMiddle(point.x, point.y)
end
function OtherCityScene:PlayBackgroundMusic()
    audio.playMusic("audios/music_city.mp3", true)
    audio.playSound("audios/sfx_peace.mp3", true)
    self:performWithDelay(function()
        self:PlayBackgroundMusic()
    end, 113 + 30)
end
function OtherCityScene:ChangeTerrain(terrain_type)
    self:GetSceneLayer():ChangeTerrain(terrain_type)
end

--- callback
function OtherCityScene:OnUpgradingBegin()
    audio.playSound("ui_building_upgrade_start.mp3")
end
function OtherCityScene:OnUpgrading()

end
function OtherCityScene:OnUpgradingFinished()

end
function OtherCityScene:OnCreateDecoratorSprite(building_sprite)
    self.scene_ui_layer:NewUIFromBuildingSprite(building_sprite)
end
function OtherCityScene:OnDestoryDecoratorSprite(building_sprite)
    self.scene_ui_layer:RemoveUIFromBuildingSprite(building_sprite)
end
function OtherCityScene:OnTreesChanged(trees, road)
    local city = self.city
    self.scene_ui_layer:RemoveAllLockButtons()
    table.foreach(trees, function(_, tree_)
        if tree_:GetEntity().location_id then
            local building = city:GetBuildingByLocationId(tree_:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                self.scene_ui_layer:NewLockButtonFromBuildingSprite(tree_)
            end
        end
    end)
    if road then
        if road:GetEntity().location_id then
            local building = city:GetBuildingByLocationId(road:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                self.scene_ui_layer:NewLockButtonFromBuildingSprite(road)
            end
        end
    end
end
function OtherCityScene:OnTowersChanged(old_towers, new_towers)
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
function OtherCityScene:OnGateChanged(old_walls, new_walls)
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
function OtherCityScene:OnSceneScale(scene_layer)
    if scene_layer:getScale() < 0.5 then
        self.scene_ui_layer:HideLevelUpNode()
    else
        self.scene_ui_layer:ShowLevelUpNode()
    end
end
function OtherCityScene:OnTouchBegan(pre_x, pre_y, x, y)
    if not DEBUG then return end
    local citynode = self:GetSceneLayer():GetCityNode()
    local point = citynode:convertToNodeSpace(cc.p(x, y))
    local tx, ty = self.iso_map:ConvertToLogicPosition(point.x, point.y)
    if not self.building then
        local building = self:GetSceneLayer():GetClickedObject(x, y)
        if building then
            local lx, ly = building:GetLogicPosition()
            building._shiftx = lx - tx
            building._shifty = ly - ty
            building:zorder(99999999)
            self.building = building
        end
    end
end
function OtherCityScene:OnTouchEnd(pre_x, pre_y, x, y)
    if not DEBUG then return end
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
function OtherCityScene:OnTouchCancelled(pre_x, pre_y, x, y)

end
function OtherCityScene:OnTouchMove(pre_x, pre_y, x, y)
    if DEBUG then
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
    OtherCityScene.super.OnTouchMove(self, pre_x, pre_y, x, y)
end
function OtherCityScene:OnTouchClicked(pre_x, pre_y, x, y)
    local city = self.city
    local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if building:GetEntity():GetType() == "ruins" then
            local select_ruins_list = city:GetNeighbourRuinWithSpecificRuin(building:GetEntity())
            local select_ruins = building:GetEntity()
            UIKit:newGameUI('GameUIBuild', city, select_ruins, select_ruins_list):addToScene(self, true)
        elseif building:GetEntity():GetType() == "keep" then
            self._keep_page = UIKit:newGameUI('GameUIKeep',city,building:GetEntity())
            self._keep_page:addToScene(self, true)
        elseif building:GetEntity():GetType() == "dragonEyrie" then
            UIKit:newGameUI('GameUIDragonEyrieMain', city,building:GetEntity()):addToCurrentScene(true)
        elseif building:GetEntity():GetType() == "toolShop" then
            UIKit:newGameUI('GameUIToolShop', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "blackSmith" then
            UIKit:newGameUI('GameUIBlackSmith', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "materialDepot" then
            UIKit:newGameUI('GameUIMaterialDepot', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "barracks" then
            UIKit:newGameUI('GameUIBarracks', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "armyCamp" then
            self._armyCamp_page = UIKit:newGameUI('GameUIArmyCamp',city,building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "townHall" then
            self._armyCamp_page = UIKit:newGameUI('GameUITownHall',city,building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "foundry"
            or building:GetEntity():GetType() == "stoneMason"
            or building:GetEntity():GetType() == "lumbermill"
            or building:GetEntity():GetType() == "mill" then
            self._armyCamp_page = UIKit:newGameUI('GameUIPResourceBuilding',city,building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "warehouse" then
            self._warehouse_page = UIKit:newGameUI('GameUIWarehouse',city,building:GetEntity())
            self._warehouse_page:addToScene(self, true)
        elseif iskindof(building:GetEntity(), 'ResourceUpgradeBuilding') then
            if building:GetEntity():GetType() == "dwelling" then
                UIKit:newGameUI('GameUIDwelling',building:GetEntity(), city):addToCurrentScene(true)
            else
                UIKit:newGameUI('GameUIResource',building:GetEntity()):addToCurrentScene(true)
            end
        elseif building:GetEntity():GetType() == "hospital" then
            UIKit:newGameUI('GameUIHospital', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "watchTower" then
            UIKit:newGameUI('GameUIWatchTower', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "tradeGuild" then
            UIKit:newGameUI('GameUITradeGuild', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "wall" then
            UIKit:newGameUI('GameUIWall', city, building:GetEntity()):addToScene(self, true)
        elseif building:GetEntity():GetType() == "tower" then
            UIKit:newGameUI('GameUITower', city, building:GetEntity()):addToScene(self, true)
        end

    end
end


return OtherCityScene
