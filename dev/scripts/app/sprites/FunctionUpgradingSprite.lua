local SpriteConfig = import(".SpriteConfig")
local UpgradingSprite = import(".UpgradingSprite")
local FunctionUpgradingSprite = class("FunctionUpgradingSprite", UpgradingSprite)

----
function FunctionUpgradingSprite:OnUpgradingBegin(building, current_time, city)
    self:OnTileChanged(city, nil)
end
function FunctionUpgradingSprite:OnUpgrading(building, current_time, city)
end
function FunctionUpgradingSprite:OnUpgradingFinished(building, city)
    self:OnTileChanged(city, nil)
end
function FunctionUpgradingSprite:OnTileLocked(city)
    self:OnTileChanged(city)
end
function FunctionUpgradingSprite:OnTileUnlocked(city)
    self:OnTileChanged(city)
end
function FunctionUpgradingSprite:OnTileChanged(city)
    local location_id = city:GetLocationIdByBuilding(self:GetEntity())
    local current_tile = city:GetTileByLocationId(location_id)
    if current_tile:IsUnlocked() then
        self:TranslateToUnlock()
    elseif self:GetEntity():IsUpgrading() then 
        self:TranslateToUpgrading()
    elseif city:IsTileCanbeUnlockAt(current_tile.x, current_tile.y) then
        if city:GetFirstBuildingByType("keep"):GetFreeUnlockPoint(city) > 0 then
            self:TranslateToCanbeUnlock()
        else
            self:TranslateToCanNotBeUnlock()
        end 
    else
        self:TranslateToCanNotBeUnlock()
    end
end
function FunctionUpgradingSprite:TranslateToUpgrading()
    self:setVisible(true)
    self:GetSprite():setVisible(false)
end
function FunctionUpgradingSprite:TranslateToUnlock()
    self:setVisible(true)
    self:GetSprite():setVisible(true)
end
function FunctionUpgradingSprite:TranslateToCanbeUnlock()
    self:setVisible(false)
end
function FunctionUpgradingSprite:TranslateToCanNotBeUnlock()
    self:setVisible(false)
end
--
function FunctionUpgradingSprite:OnTransformed(entity)
    self.config = SpriteConfig[entity:GetType()]
    self:ReloadSprite()
end
function FunctionUpgradingSprite:ctor(city_layer, entity, city)
    FunctionUpgradingSprite.super.ctor(self, city_layer, entity)
    self:OnTileChanged(city, city:GetTileWhichBuildingBelongs(entity))
end
function FunctionUpgradingSprite:ReloadSprite()
    FunctionUpgradingSprite.super.RefreshSprite(self)
end
function FunctionUpgradingSprite:RefreshSprite()
    
end
function FunctionUpgradingSprite:GetSpriteTopPosition()
    local x,y = FunctionUpgradingSprite.super.GetSpriteTopPosition(self)
    local type_ = self:GetEntity():GetType()
    if type_ == "keep" then
        return x - 30, y - 50
    elseif type_ == "watchTower" then
        return x - 30, y - 50
    end
    return x,y
end



return FunctionUpgradingSprite








