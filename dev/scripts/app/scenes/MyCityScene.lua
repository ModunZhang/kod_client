local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local GameUIWatchTowerTroopDetail = import("..ui.GameUIWatchTowerTroopDetail")
local WidgetMoveHouse = import("..widget.WidgetMoveHouse")
local TutorialLayer = import("..ui.TutorialLayer")
local GameUINpc = import("..ui.GameUINpc")
local Arrow = import("..ui.Arrow")
local City = import("..entity.City")
local User = import("..entity.User")
local CityScene = import(".CityScene")
local MyCityScene = class("MyCityScene", CityScene)


function MyCityScene:ctor(...)
    MyCityScene.super.ctor(self, ...)
    self.clicked_callbacks = {}
end
function MyCityScene:onEnter()
    MyCityScene.super.onEnter(self)
    self.arrow_layer = self:CreateArrowLayer()
    self.tutorial_layer = self:CreateTutorialLayer()
    self.home_page = self:CreateHomePage()
    -- self:GetSceneLayer():IteratorInnnerBuildings(function(_, building)
    --     self:GetSceneUILayer():NewUIFromBuildingSprite(building)
    -- end)

    self:GetCity():AddListenOnType(self, City.LISTEN_TYPE.UPGRADE_BUILDING)
    self:GetCity():GetUser():AddListenOnType(self, User.LISTEN_TYPE.BASIC)

    self.action_node = display.newNode():addTo(self)
end
function MyCityScene:onExit()
    MyCityScene.super.onExit(self)
end
function MyCityScene:EnterEditMode()
    MyCityScene.super.EnterEditMode(self)
    self:GetSceneUILayer():EnterEditMode()
    self:GetHomePage():DisplayOff()
end
function MyCityScene:LeaveEditMode()
    MyCityScene.super.LeaveEditMode(self)
    self:GetSceneUILayer():LeaveEditMode()
    self:GetHomePage():DisplayOn()
    self:GetSceneUILayer():removeChildByTag(WidgetMoveHouse.ADD_TAG, true)
end
-- 给对应建筑添加指示动画
function MyCityScene:AddIndicateForBuilding(building_sprite)
    -- 已经添加，则移除
    if self.indicate then
        self.indicate:removeFromParent(true)
        self.indicate = nil
    end
    -- 指向建筑的箭头
    local arrow = display.newSprite("arrow_home.png")
        :scale(0.4):addTo(building_sprite):pos(building_sprite:GetSpriteTopPosition()):setLocalZOrder(1001)
    arrow:setRotation(240)
    local seq_1 = transition.sequence{
        cc.ScaleTo:create(0.4, 0.8),
        cc.ScaleTo:create(0.4, 0.4),
    }
    arrow:runAction(cc.RepeatForever:create(seq_1))
    self.indicate = arrow
    self.action_node:stopAllActions()
    self.action_node:performWithDelay(function()
        if self.indicate then
            self.indicate:removeFromParent(true)
            self.indicate = nil
        end
    end, 4.0)
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
    return cocos_promise.defer(func)
end
function MyCityScene:GetHomePage()
    return self.home_page
end
function MyCityScene:onEnterTransitionFinish()
    if device.platform == "mac" then
        return
    end
    local city = self:GetCity()
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
    local home = UIKit:newGameUI('GameUIHome', self:GetCity()):AddToScene(self)
    home:setLocalZOrder(10)
    home:setTouchSwallowEnabled(false)
    return home
end
function MyCityScene:onExit()
    self:GetCity():GetUser():RemoveListenerOnType(self, User.LISTEN_TYPE.BASIC)
    self.home_page = nil
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
    local location_id = self:GetCity():GetLocationIdByBuildingType(building_type)
    self:GetSceneUILayer():IteratorLockButtons(function(_, v)
        if v.sprite:GetEntity().location_id == location_id then
            lock_button = v
            return true
        end
    end)
    return cocos_promise.defer(function() return lock_button end)
end



---
function MyCityScene:OnBasicChanged(user, changed)
    if changed.terrain then
        self:ChangeTerrain(changed.terrain.new)
    end
end
function MyCityScene:OnUpgradingBegin()
    app:GetAudioManager():PlayeEffectSoundWithKey("UI_BUILDING_UPGRADE_START")
end
function MyCityScene:OnUpgrading()

end
function MyCityScene:OnUpgradingFinished(building)
    if building:GetType() == "wall" then
        self:GetSceneLayer():UpdateWallsWithCity(self:GetCity())
    end
    self:GetSceneLayer():CheckCanUpgrade()
end
function MyCityScene:OnCreateDecoratorSprite(building_sprite)
    -- self:GetSceneUILayer():NewUIFromBuildingSprite(building_sprite)
end
function MyCityScene:OnDestoryDecoratorSprite(building_sprite)
    -- self:GetSceneUILayer():RemoveUIFromBuildingSprite(building_sprite)
end
function MyCityScene:OnTilesChanged(tiles)
    local city = self:GetCity()
    self:GetSceneUILayer():RemoveAllLockButtons()
    table.foreach(tiles, function(_, tile)
        if tile:GetEntity().location_id then
            local building = city:GetBuildingByLocationId(tile:GetEntity().location_id)
            if building and not building:IsUpgrading() then
                self:GetSceneUILayer():NewLockButtonFromBuildingSprite(tile)
            end
        end
    end)
end
function MyCityScene:OnTowersChanged(old_towers, new_towers)
    -- table.foreach(old_towers, function(k, tower)
    --     -- if tower:GetEntity():IsUnlocked() then
    --     self:GetSceneUILayer():RemoveUIFromBuildingSprite(tower)
    --     -- end
    -- end)
    -- table.foreach(new_towers, function(k, tower)
    --     -- if tower:GetEntity():IsUnlocked() then
    --     self:GetSceneUILayer():NewUIFromBuildingSprite(tower)
    --     -- end
    -- end)
end
function MyCityScene:OnGateChanged(old_walls, new_walls)
    -- table.foreach(old_walls, function(k, wall)
    --     if wall:GetEntity():IsGate() then
    --         self:GetSceneUILayer():RemoveUIFromBuildingSprite(wall)
    --     end
    -- end)

    -- table.foreach(new_walls, function(k, wall)
    --     if wall:GetEntity():IsGate() then
    --         self:GetSceneUILayer():NewUIFromBuildingSprite(wall)
    --     end
    -- end)
end
function MyCityScene:OnSceneScale(scene_layer)
    if scene_layer:getScale() < (scene_layer:GetScaleRange()) * 1.3 then
        -- self:GetSceneUILayer():HideLevelUpNode()
        scene_layer:HideLevelUpNode()
    else
        -- self:GetSceneUILayer():ShowLevelUpNode()
        scene_layer:ShowLevelUpNode()
    end
end
function MyCityScene:OnTouchClicked(pre_x, pre_y, x, y)
    if self.event_manager:TouchCounts() > 0 then return end
    local city = self:GetCity()
    local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        if self:CheckClickPromise(building) then return end

        if iskindof(building, "HelpedTroopsSprite") then
            local helped = city:GetHelpedByTroops()[building:GetIndex()]
            local type_ = GameUIWatchTowerTroopDetail.DATA_TYPE.HELP_DEFENCE
            local user = self.city:GetUser()
            UIKit:newGameUI("GameUIWatchTowerTroopDetail", type_, helped, user:Id(),false):AddToCurrentScene(true)
            return
        end
        local type_ = building:GetEntity():GetType()
        if type_ == "ruins" then
            if self:IsEditMode() then
                self:GetSceneUILayer():getChildByTag(WidgetMoveHouse.ADD_TAG):SetMoveToRuins(building)
            else
                UIKit:newGameUI('GameUIBuild', city, building:GetEntity()):AddToScene(self, true)
            end
        elseif type_ == "keep" then
            self._keep_page = UIKit:newGameUI('GameUIKeep',city,building:GetEntity())
            self._keep_page:AddToScene(self, true)
        elseif type_ == "dragonEyrie" then
            UIKit:newGameUI('GameUIDragonEyrieMain', city,building:GetEntity()):AddToCurrentScene(true)
        elseif type_ == "toolShop" then
            UIKit:newGameUI('GameUIToolShop', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "blackSmith" then
            UIKit:newGameUI('GameUIBlackSmith', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "materialDepot" then
            UIKit:newGameUI('GameUIMaterialDepot', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "barracks" then
            UIKit:newGameUI('GameUIBarracks', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "academy" then
            self._armyCamp_page = UIKit:newGameUI('GameUIAcademy',city,building:GetEntity()):AddToScene(self, true)
        elseif type_ == "townHall" then
            self._armyCamp_page = UIKit:newGameUI('GameUITownHall',city,building:GetEntity()):AddToScene(self, true)
        elseif type_ == "foundry"
            or type_ == "stoneMason"
            or type_ == "lumbermill"
            or type_ == "mill" then
            self._armyCamp_page = UIKit:newGameUI('GameUIPResourceBuilding',city,building:GetEntity()):AddToScene(self, true)
        elseif type_ == "warehouse" then
            self._warehouse_page = UIKit:newGameUI('GameUIWarehouse',city,building:GetEntity())
            self._warehouse_page:AddToScene(self, true)
        elseif iskindof(building:GetEntity(), 'ResourceUpgradeBuilding') then
            if type_ == "dwelling" then
                UIKit:newGameUI('GameUIDwelling',building:GetEntity(), city):AddToCurrentScene(true)
            else
                UIKit:newGameUI('GameUIResource',building:GetEntity()):AddToCurrentScene(true)
            end
        elseif type_ == "hospital" then
            UIKit:newGameUI('GameUIHospital', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "watchTower" then
            UIKit:newGameUI('GameUIWatchTower', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "tradeGuild" then
            UIKit:newGameUI('GameUITradeGuild', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "wall" then
            UIKit:newGameUI('GameUIWall', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "tower" then
            UIKit:newGameUI('GameUITower', city, building:GetEntity():BelongCity():GetTower()):AddToScene(self, true)
        elseif type_ == "trainingGround"
            or type_ == "stable"
            or type_ == "hunterHall"
            or type_ == "workshop"
        then
            UIKit:newGameUI('GameUIMilitaryTechBuilding', city, building:GetEntity()):AddToScene(self, true)
        elseif type_ == "airship" then
            local dragon_type = city:GetDragonEyrie():GetDragonManager():GetCanFightPowerfulDragonType()
            if #dragon_type > 0 then
                local _,_,index = self.city:GetUser():GetPVEDatabase():GetCharPosition()
                app:EnterPVEScene(index)
            else
                FullScreenPopDialogUI.new()
                    :AddToCurrentScene()
                    :SetTitle("陛下")
                    :SetPopMessage("必须有一条空闲的龙，才能进入pve")
            end
        elseif type_ == "FairGround" then
            UIKit:newGameUI("GameUIGacha", self.city):AddToCurrentScene(true)
        end
    elseif self:IsEditMode() then
        self:LeaveEditMode()
    end
end
return MyCityScene





























