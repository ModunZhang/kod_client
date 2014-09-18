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

    self:LoadAnimation()
    self.city_layer = self:CreateSceneLayer()
    self:CreateMultiTouchLayer()
    self.scene_ui_layer = self:CreateSceneUILayer()
    self:CreateHomePage()

    self.city_layer:AddObserver(self)
    self.city_layer:InitWithCity(City)
    self.city_layer:IteratorCanUpgradingBuilding(function(_, building)
        self.scene_ui_layer:NewUIFromBuildingSprite(building)
    end)


    -- City:GetFirstBuildingByType("toolShop"):AddToolShopListener({
    --     OnBeginMakeMaterialsWithEvent = function(lisenter, tool_shop, event)
    --         print("OnBeginMakeMaterialsWithEvent", event:Category())
    --     end,
    --     OnMakingMaterialsWithEvent = function(lisenter, tool_shop, event, current_time)
    --         print("OnMakingMaterialsWithEvent", event:Category(), current_time)
    --     end,
    --     OnEndMakeMaterialsWithEvent = function(lisenter, tool_shop, event, current_time)
    --         print("OnEndMakeMaterialsWithEvent", event:Category(), current_time)
    --     end,
    --     OnGetMaterialsWithEvent = function(lisenter, tool_shop, event)
    --         print("OnGetMaterialsWithEvent", event:Category())
    --     end,
    -- })
    City:GetFirstBuildingByType("blackSmith"):AddBlackSmithListener({
        OnBeginMakeEquipmentWithEvent = function(lisenter, tool_shop, event)
            print("OnBeginMakeEquipmentWithEvent", event:Content())
        end,
        OnMakingEquipmentWithEvent = function(lisenter, tool_shop, event, current_time)
            print("OnMakingEquipmentWithEvent", event:Content(), event:LeftTime(current_time))
        end,
        OnEndMakeEquipmentWithEvent = function(lisenter, tool_shop, event, equipment)
            print("OnEndMakeEquipmentWithEvent", event:Content(), equipment)
        end,
    })
end
function CityScene:LoadAnimation()
    local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo("sprites/armatures/hammer/chuizidonghua.ExportJson")
    manager:addArmatureFileInfo("sprites/armatures/hammer/chuizidonghua.ExportJson")
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
    local scene_ui_layer = display.newLayer():addTo(self)
    scene_ui_layer:setTouchSwallowEnabled(false)
    function scene_ui_layer:Init()
        self.ui = {}
        self.lock_buttons = {}
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

        local levelup = BuildingLevelUpUINode.new():addTo(self)
        building_sprite:AddObserver(levelup)
        table.insert(self.ui, levelup)

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
    scene_ui_layer:Init()
    return scene_ui_layer
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
            self._keep_page = UIKit:newGameUI('GameUIKeep',City,building:GetEntity())
            self._keep_page:addToScene(self, true)
        elseif building:GetEntity():GetType() == "dragonEyrie" then
            UIKit:newGameUI('GameUIDragonEyrie', City):addToCurrentScene(true)
        elseif building:GetEntity():GetType() == "toolShop" then
            UIKit:newGameUI('GameUIToolShop', City):addToScene(self, true)
        elseif building:GetEntity():GetType() == "blackSmith" then
            UIKit:newGameUI('GameUIBlackSmith', City):addToScene(self, true)
        elseif building:GetEntity():GetType() == "materialDepot" then
            UIKit:newGameUI('GameUIMaterialDepot', City):addToScene(self, true)
        elseif building:GetEntity():GetType() == "barracks" then
            UIKit:newGameUI('GameUIBarracks', City):addToScene(self, true)
        elseif building:GetEntity():GetType() == "warehouse" then
            self._warehouse_page = UIKit:newGameUI('GameUIWarehouse',City,building:GetEntity())
            self._warehouse_page:addToScene(self, true)
        elseif iskindof(building:GetEntity(), 'ResourceUpgradeBuilding') then
            if building:GetEntity():GetType() == "dwelling" then
                UIKit:newGameUI('GameUIDwelling',building:GetEntity(), City):addToCurrentScene(true)
            else
                UIKit:newGameUI('GameUIResource',building:GetEntity()):addToCurrentScene(true)
            end
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

return CityScene












