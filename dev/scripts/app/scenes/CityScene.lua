local SpriteButton = import("..ui.SpriteButton")
local BuildingLevelUpUINode = import("..ui.BuildingLevelUpUINode")
local BuildingUpgradeUINode = import("..ui.BuildingUpgradeUINode")
local CityLayer = import("..layers.CityLayer")
local EventManager = import("..layers.EventManager")
local TouchJudgment = import("..layers.TouchJudgment")
local IsoMapAnchorBottomLeft = import("..map.IsoMapAnchorBottomLeft")
local app = app
local timer = app.timer
local running_scene = nil
import('app.service.ListenerService')


local CityScene = class("CityScene", function()
    return display.newScene("CityScene")
end)

function goto_logic(x, y, time)
    time = 0
    local p = logic2world(x, y)
    goto_world_pos(p.x, p.y, time == nil and 0.5 or time)
end
function goto_world_pos(target_x, target_y, time)
    local scene = running_scene.city_layer
    local scene_mid_point = scene:getParent():convertToNodeSpace(cc.p(display.cx, display.cy))
    local world_point = scene:convertToWorldSpace(cc.p(target_x, target_y))
    local new_scene_point = scene:getParent():convertToNodeSpace(world_point)
    local dx, dy = scene_mid_point.x - new_scene_point.x, scene_mid_point.y - new_scene_point.y
    local current_x, current_y = scene:getPosition()

    if time == 0 then
        scene:setPosition(cc.p(current_x + dx, current_y + dy))
    else
        transition.moveTo(scene, {x = current_x + dx, y = current_y + dy, time = time})
    end
end
function logic2world(x, y)
    local scene = running_scene.city_layer
    local city_node = running_scene.city_layer:GetCityNode()
    local map_pos = cc.p(running_scene.iso_map:ConvertToMapPosition(x, y))
    return scene:convertToNodeSpace(city_node:convertToWorldSpace(map_pos))
end
function CityScene:ctor()
    self.event_manager = EventManager.new(self)
    self.touch_judgment = TouchJudgment.new(self)
end
function CityScene:onEnter()
    ListenerService:start()
    running_scene = self

    self.city_layer = self:CreateSceneLayer()
    self:CreateMultiTouchLayer()


    self.upgrading_ui = {}
    self._sprite_layer = display.newLayer():addTo(self)
    self._sprite_layer:setTouchSwallowEnabled(false)

    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("sprites/armatures/hammer/chuizidonghua.ExportJson")
    manager:addArmatureFileInfo("sprites/armatures/hammer/chuizidonghua.ExportJson")

    self.city_layer:IteratorCanUpgradingBuilding(function(_, building)
        local levelup = BuildingLevelUpUINode.new():addTo(self._sprite_layer)
        building:AddObserver(levelup)
        table.insert(self.upgrading_ui, levelup)

        local progress = BuildingUpgradeUINode.new():addTo(self._sprite_layer)
        building:AddObserver(progress)
        table.insert(self.upgrading_ui, progress)
        building:OnSceneMove()
    end)
    self:CreateHomePage()
    self.city_layer:AddObserver(self)
    self.city_layer:InitWithCity(City)
end
function CityScene:CreateMultiTouchLayer()
    local touch_layer = display.newLayer():addTo(self)
    touch_layer:setTouchEnabled(true)
    touch_layer:setTouchSwallowEnabled(false)
    touch_layer:setTouchMode(cc.TOUCH_MODE_ALL_AT_ONCE)
    touch_layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        self.event_manager:OnEvent(event)
    end)
end
function CityScene:CreateSceneLayer()
    local scene = CityLayer.new():addTo(self, 0, 1)
    local origin_point = scene:GetPositionIndex(0, 0)
    self.iso_map = IsoMapAnchorBottomLeft.new({
        tile_w = 80, tile_h = 56, map_width = 50, map_height = 50, base_x = origin_point.x, base_y = origin_point.y
    })
    scene:ZoomTo(0.5)
    return scene
end
function CityScene:CreateSceneUILayer()

end
function CityScene:CreateHomePage()
    local home = UIKit:newGameUI('GameUIHome', City):addToScene(self)
    home:setTouchSwallowEnabled(false)
    return home
end
function CityScene:onEnterTransitionFinish()
    goto_logic(0, 0, 0)
end
function CityScene:onExit()

end
function CityScene:OneTouch(pre_x, pre_y, x, y, touch_type)
    local citynode = self.city_layer:GetCityNode()
    if touch_type == "began" then
        self.touch_judgment:OnTouchBegan(pre_x, pre_y, x, y)
        return true
    elseif touch_type == "moved" then
        self.touch_judgment:OnTouchMove(pre_x, pre_y, x, y)
    elseif touch_type == "ended" then
        self.touch_judgment:OnTouchEnd(pre_x, pre_y, x, y)
    elseif touch_type == "cancelled" then
        self.touch_judgment:OnTouchCancelled(pre_x, pre_y, x, y)
    end
end
----- EventManager
function CityScene:OnOneTouch(pre_x, pre_y, x, y, touch_type)
    self:OneTouch(pre_x, pre_y, x, y, touch_type)
    -- if self.lock_buttons then
    --     table.foreach(self.lock_buttons, function(k, v)
    --         if v:IsInStateName("confirm") and not v:hitTest(x, y) then
    --             v:TranslateToSatateByName("locked")
    --         end
    --     end)
    -- end
end
function CityScene:OnTwoTouch(x1, y1, x2, y2, event_type)
    local scene = self.city_layer
    if event_type == "began" then
        self.distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBegin()
    elseif event_type == "moved" then
        local new_distance = math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
        scene:ZoomBy(new_distance / self.distance)
    elseif event_type == "ended" then
        scene:ZoomEnd()
        self.distance = nil
    end
end
-- TouchJudgment
function CityScene:OnTouchBegan(pre_x, pre_y, x, y)
end
function CityScene:OnTouchEnd(pre_x, pre_y, x, y)
end
function CityScene:OnTouchCancelled(pre_x, pre_y, x, y)
end
function CityScene:OnTouchMove(pre_x, pre_y, x, y)
    if self.distance then return end
    local parent = self.city_layer:getParent()
    local old_point = parent:convertToNodeSpace(cc.p(pre_x, pre_y))
    local new_point = parent:convertToNodeSpace(cc.p(x, y))
    local old_x, old_y = self.city_layer:getPosition()
    local diffX = new_point.x - old_point.x
    local diffY = new_point.y - old_point.y
    self.city_layer:setPosition(cc.p(old_x + diffX, old_y + diffY))
end
function CityScene:OnTouchClicked(pre_x, pre_y, x, y)
    local citynode = self.city_layer:GetCityNode()
    local point = citynode:convertToNodeSpace(cc.p(x, y))
    local tx, ty = self.iso_map:ConvertToLogicPosition(point.x, point.y)
    local building = self.city_layer:GetClickedObject(tx, ty, x, y)
    if building then
        if building:GetEntity():GetType() == "ruins" then
            local select_ruins_list = City:GetNeighbourRuinWithSpecificRuin(building:GetEntity())
            local select_ruins = building:GetEntity()
            UIKit:newGameUI('GameUIBuild', City, select_ruins, select_ruins_list):addToScene(self, true)
        elseif building:GetEntity():GetType() == "keep" then
            self._keep_page = UIKit:newGameUI('GameUIKeep')
            self._keep_page:addToScene(self, true)
        elseif building:GetEntity():GetType() == "warehouse" then
            self._warehouse_page = UIKit:newGameUI('GameUIWarehouse',building:GetEntity())
            self._warehouse_page:addToScene(self, true)
        end
    end
end
function CityScene:OnTouchExtend(old_speed_x, old_speed_y, new_speed_x, new_speed_y, millisecond)
    local parent = self.city_layer:getParent()
    local speed = parent:convertToNodeSpace(cc.p(new_speed_x, new_speed_y))
    local x, y  = self.city_layer:getPosition()
    local sp = self:convertToNodeSpace(cc.p(speed.x * millisecond, speed.y * millisecond))
    self.city_layer:setPosition(cc.p(x + sp.x, y + sp.y))
end
function CityScene:OnCreateDecoratorSprite(building_sprite)
    local progress = BuildingUpgradeUINode.new():addTo(self._sprite_layer)
    building_sprite:AddObserver(progress)
    table.insert(self.upgrading_ui, progress)

    local levelup = BuildingLevelUpUINode.new():addTo(self._sprite_layer)
    building_sprite:AddObserver(levelup)
    table.insert(self.upgrading_ui, levelup)
    building_sprite:OnSceneMove()
end
function CityScene:OnDestoryDecoratorSprite(building_sprite)
    building_sprite:NotifyObservers(function(ob)
        for i, ui in ipairs(self.upgrading_ui) do
            if ob == ui then
                table.remove(self.upgrading_ui, i)
                ui:removeFromParentAndCleanup(true)
            end
        end
    end)
end
function CityScene:OnTreesChanged(trees, road)
    for _, v in pairs(self.lock_buttons == nil and {} or self.lock_buttons) do
        City:RemoveListenerOnType(v, City.LISTEN_TYPE.UPGRADE_BUILDING)
        v:removeFromParentAndCleanup(true)
    end
    self.lock_buttons = {}
    table.foreach(trees, function(_, tree_)
        if tree_:GetEntity().location_id then
            local building = City:GetBuildingByLocationId(tree_:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                local lock_button = SpriteButton.new(tree_, City):addTo(self._sprite_layer, -1)
                table.insert(self.lock_buttons, lock_button)
                tree_:AddObserver(lock_button)
                tree_:OnSceneMove()
                City:AddListenOnType(lock_button, City.LISTEN_TYPE.UPGRADE_BUILDING)
            end
        end
    end)
    if road then
        if road:GetEntity().location_id then
            local building = City:GetBuildingByLocationId(road:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                local lock_button = SpriteButton.new(road, City):addTo(self._sprite_layer, 1)
                table.insert(self.lock_buttons, lock_button)
                road:AddObserver(lock_button)
                road:OnSceneMove()
                City:AddListenOnType(lock_button, City.LISTEN_TYPE.UPGRADE_BUILDING)
            end
        end
    end
end
function CityScene:OnTowersChanged(old_towers, new_towers)
    if self._sprite_layer then
        table.foreach(old_towers, function(k, tower)
            if tower:GetEntity():IsUnlocked() then
                tower:NotifyObservers(function(ob)
                    for i, ui in ipairs(self.upgrading_ui) do
                        if ob == ui then
                            table.remove(self.upgrading_ui, i)
                            ui:removeFromParentAndCleanup(true)
                        end
                    end
                end)
            end
        end)

        table.foreach(new_towers, function(k, tower)
            if tower:GetEntity():IsUnlocked() then
                local progress = BuildingUpgradeUINode.new():addTo(self._sprite_layer)
                tower:AddObserver(progress)
                table.insert(self.upgrading_ui, progress)

                local levelup = BuildingLevelUpUINode.new():addTo(self._sprite_layer)
                tower:AddObserver(levelup)
                table.insert(self.upgrading_ui, levelup)
                tower:OnSceneMove()
            end
        end)
    end
end
function CityScene:OnGateChanged(old_walls, new_walls)
    if self._sprite_layer then
        table.foreach(old_walls, function(k, wall)
            if wall:GetEntity():IsGate() then
                wall:NotifyObservers(function(ob)
                    for i, ui in ipairs(self.upgrading_ui) do
                        if ob == ui then
                            table.remove(self.upgrading_ui, i)
                            ui:removeFromParentAndCleanup(true)
                        end
                    end
                end)
            end
        end)

        table.foreach(new_walls, function(k, wall)
            if wall:GetEntity():IsGate() then
                local progress = BuildingUpgradeUINode.new():addTo(self._sprite_layer)
                wall:AddObserver(progress)
                table.insert(self.upgrading_ui, progress)

                local levelup = BuildingLevelUpUINode.new():addTo(self._sprite_layer)
                wall:AddObserver(levelup)
                table.insert(self.upgrading_ui, levelup)

                wall:OnSceneMove()
            end
        end)
    end
end

return CityScene







