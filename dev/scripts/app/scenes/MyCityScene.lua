local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local TutorialLayer = import("..ui.TutorialLayer")
local GameUINpc = import("..ui.GameUINpc")
local Arrow = import("..ui.Arrow")
local City = import("..entity.City")
local CityScene = import(".CityScene")
local MyCityScene = class("MyCityScene", CityScene)

function MyCityScene:ctor(city)
    MyCityScene.super.ctor(self, city)
    self.clicked_callbacks = {}
end
function MyCityScene:onEnter()
    MyCityScene.super.onEnter(self)
    self.arrow_layer = self:CreateArrowLayer()
    self.tutorial_layer = self:CreateTutorialLayer()
    home_page = self:CreateHomePage()
    self:GetSceneLayer():IteratorInnnerBuildings(function(_, building)
        self:GetSceneUILayer():NewUIFromBuildingSprite(building)
    end)
    self.city:AddListenOnType(self, City.LISTEN_TYPE.UPGRADE_BUILDING)
end
function MyCityScene:GetArrowTutorial()
    if not self.arrow_tutorial then
        local arrow_tutorial = TutorialLayer.new():addTo(self)
        self.arrow_tutorial = arrow_tutorial
    end
    return self.arrow_tutorial
end
function MyCityScene:DestoryArrowTutorial(func)
    if self.arrow_tutorial then
        self.arrow_tutorial:removeFromParent()
        self.arrow_tutorial = nil
    end
    return cocos_promise.deffer(func)
end
function MyCityScene:GetHomePage()
    return home_page
end
function MyCityScene:onEnterTransitionFinish()
    if device.platform == "mac" then
        return
    end
    local city = self.city
    local scene = self
    local check_map = {
        [1] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                return City:GetHouseByPosition(12, 12)
            end
            return true
        end,
        [2] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                local building = City:GetHouseByPosition(12, 12)
                return not building:IsUpgrading() and building:GetLevel() == 1
            end
            return true
        end,
        [3] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                return City:GetHouseByPosition(15, 12)
            end
            return true
        end,
        [4] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                local building = City:GetHouseByPosition(15, 12)
                return not building:IsUpgrading() and building:GetLevel() == 1
            end
            return true
        end,
        [5] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                return City:GetHouseByPosition(18, 12)
            end
            return true
        end,
        [6] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                local building = City:GetHouseByPosition(18, 12)
                return not building:IsUpgrading() and building:GetLevel() == 1
            end
            return true
        end,
        [7] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                local building = City:GetFirstBuildingByType("keep")
                return building:GetLevel() == 2 or (building:IsUpgrading() and building:GetLevel() == 1)
            end
            return true
        end,
        [8] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                local building = City:GetFirstBuildingByType("keep")
                return not building:IsUpgrading() and building:GetLevel() == 2
            end
            return true
        end,
        [9] = function()
            if #City:GetUnlockedFunctionBuildings() <= 4 then
                return false
            end
            return true
        end,
        [10] = function()
            if #City:GetUnlockedFunctionBuildings() <= 5 then
                local building = City:GetFirstBuildingByType("barracks")
                return not building:IsUpgrading() and building:GetLevel() == 1
            end
            return true
        end,
        [11] = function()
            local count = City:GetSoldierManager():GetCountBySoldierType("swordsman")
            local barracks = City:GetFirstBuildingByType("barracks")
            if count > 0 or barracks:IsRecruting() then
                return true
            end
        end,
    }
    local function check(step)
        local check_func = check_map[step]
        return not check_func and true or check_func()
    end
end
function MyCityScene:CreateHomePage()
    local home = UIKit:newGameUI('GameUIHome', self.city):addToScene(self)
    home:setLocalZOrder(10)
    home:setTouchSwallowEnabled(false)
    return home
end
function MyCityScene:onExit()
    home_page = nil
    MyCityScene.super.onExit(self)
end
function MyCityScene:GetTutorialLayer()
    return self.tutorial_layer
end
function MyCityScene:PromiseOfClickBuilding(x, y)
    assert(#self.clicked_callbacks == 0)
    local arrow
    self:GetSceneLayer():FindBuildingBy(x, y):next(function(building)
        arrow = Arrow.new():addTo(self.arrow_layer)
        building:AddObserver(arrow)
        building:OnSceneMove()
    end):catch(function(err)
        dump(err:reason())
    end)
    local p = promise.new()
    self:GetTutorialLayer():Enable()
    table.insert(self.clicked_callbacks, function(building)
        local x_, y_ = building:GetEntity():GetLogicPosition()
        if x == x_ and y == y_ then
            self:GetTutorialLayer():Disable()
            self:GetSceneLayer():FindBuildingBy(x, y):next(function(building)
                building:RemoveObserver(arrow)
                arrow:removeFromParent()
            end):catch(function(err)
                dump(err:reason())
            end)
            p:resolve(building)
            return true
        end
    end)
    return p
end
function MyCityScene:CheckClickPromise(building)
    if #self.clicked_callbacks > 0 then
        if self.clicked_callbacks[1](building) then
            table.remove(self.clicked_callbacks, 1)
            return
        end
        return true
    end
end
function MyCityScene:PromiseOfClickLockButton(building_type)
    local btn = self:GetLockButtonsByBuildingType(building_type)
    local tutorial_layer = TutorialLayer.new(btn):addTo(self):Enable()
    local rect = btn:getCascadeBoundingBox()
    Arrow.new():addTo(tutorial_layer):OnPositionChanged(rect.x, rect.y)
    return UIKit:PromiseOfOpen("GameUIUnlockBuilding"):next(function(ui)
        tutorial_layer:removeFromParent()
        return ui
    end)
end
function MyCityScene:GetLockButtonsByBuildingType(building_type)
    local lock_button
    local location_id = self.city:GetLocationIdByBuildingType(building_type)
    self:GetSceneUILayer():IteratorLockButtons(function(_, v)
        if v.sprite:GetEntity().location_id == location_id then
            lock_button = v
            return true
        end
    end)
    return cocos_promise.deffer(function() return lock_button end)
end



---
function MyCityScene:OnUpgradingBegin()
    app:GetAudioManager():PlayeEffectSoundWithKey("UI_BUILDING_UPGRADE_START")
end
function MyCityScene:OnUpgrading()

end
function MyCityScene:OnUpgradingFinished()

end
function MyCityScene:OnCreateDecoratorSprite(building_sprite)
    self:GetSceneUILayer():NewUIFromBuildingSprite(building_sprite)
end
function MyCityScene:OnDestoryDecoratorSprite(building_sprite)
    self:GetSceneUILayer():RemoveUIFromBuildingSprite(building_sprite)
end
function MyCityScene:OnTreesChanged(trees, road)
    local city = self.city
    self:GetSceneUILayer():RemoveAllLockButtons()
    table.foreach(trees, function(_, tree_)
        if tree_:GetEntity().location_id then
            local building = city:GetBuildingByLocationId(tree_:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                self:GetSceneUILayer():NewLockButtonFromBuildingSprite(tree_)
            end
        end
    end)
    if road then
        if road:GetEntity().location_id then
            local building = city:GetBuildingByLocationId(road:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                self:GetSceneUILayer():NewLockButtonFromBuildingSprite(road)
            end
        end
    end
end
function MyCityScene:OnTowersChanged(old_towers, new_towers)
    table.foreach(old_towers, function(k, tower)
        if tower:GetEntity():IsUnlocked() then
            self:GetSceneUILayer():RemoveUIFromBuildingSprite(tower)
        end
    end)
    table.foreach(new_towers, function(k, tower)
        if tower:GetEntity():IsUnlocked() then
            self:GetSceneUILayer():NewUIFromBuildingSprite(tower)
        end
    end)
end
function MyCityScene:OnGateChanged(old_walls, new_walls)
    table.foreach(old_walls, function(k, wall)
        if wall:GetEntity():IsGate() then
            self:GetSceneUILayer():RemoveUIFromBuildingSprite(wall)
        end
    end)

    table.foreach(new_walls, function(k, wall)
        if wall:GetEntity():IsGate() then
            self:GetSceneUILayer():NewUIFromBuildingSprite(wall)
        end
    end)
end
function MyCityScene:OnSceneScale(scene_layer)
    if scene_layer:getScale() < 0.5 then
        self:GetSceneUILayer():HideLevelUpNode()
    else
        self:GetSceneUILayer():ShowLevelUpNode()
    end
end
function MyCityScene:OnTouchClicked(pre_x, pre_y, x, y)
    local city = self.city
    local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if self:CheckClickPromise(building) then return end
        if building:GetEntity():GetType() == "ruins" then
            UIKit:newGameUI('GameUIBuild', city, building:GetEntity()):addToScene(self, true)
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
            self._armyCamp_page = UIKit:newGameUI('GameUIAcademy',city,building:GetEntity()):addToScene(self, true)
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
return MyCityScene



















