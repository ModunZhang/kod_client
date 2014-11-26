local CityScene = import(".CityScene")
local MyCityScene = class("MyCityScene", CityScene)

function MyCityScene:ctor(city)
    MyCityScene.super.ctor(self, city)
end
function MyCityScene:onEnter()
    local city = self.city
    self.scene_ui_layer = self:CreateSceneUILayer()
    MyCityScene.super.onEnter(self)
    home_page = self:CreateHomePage()


    self:GetSceneLayer():IteratorInnnerBuildings(function(_, building)
        self.scene_ui_layer:NewUIFromBuildingSprite(building)
    end)
    city:AddListenOnType(self, city.LISTEN_TYPE.UPGRADE_BUILDING)
end
function MyCityScene:CreateHomePage()
    local home = UIKit:newGameUI('GameUIHome', self.city):addToScene(self)
    home:setTouchSwallowEnabled(false)
    return home
end
function MyCityScene:onExit()
    home_page = nil
    MyCityScene.super.onExit(self)
end
function MyCityScene:OnUpgradingBegin()
    audio.playSound("ui_building_upgrade_start.mp3")
end
function MyCityScene:OnUpgrading()

end
function MyCityScene:OnUpgradingFinished()

end
function MyCityScene:OnCreateDecoratorSprite(building_sprite)
    self.scene_ui_layer:NewUIFromBuildingSprite(building_sprite)
end
function MyCityScene:OnDestoryDecoratorSprite(building_sprite)
    self.scene_ui_layer:RemoveUIFromBuildingSprite(building_sprite)
end
function MyCityScene:OnTreesChanged(trees, road)
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
function MyCityScene:OnTowersChanged(old_towers, new_towers)
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
function MyCityScene:OnGateChanged(old_walls, new_walls)
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
function MyCityScene:OnSceneScale(scene_layer)
    if scene_layer:getScale() < 0.5 then
        self.scene_ui_layer:HideLevelUpNode()
    else
        self.scene_ui_layer:ShowLevelUpNode()
    end
end
function MyCityScene:OnTouchClicked(pre_x, pre_y, x, y)
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
return MyCityScene

