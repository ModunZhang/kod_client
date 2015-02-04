local UpgradingSprite = import(".UpgradingSprite")
local FunctionUpgradingSprite = class("FunctionUpgradingSprite", UpgradingSprite)

----
function FunctionUpgradingSprite:OnUpgradingBegin(building, current_time, city)
    self:OnTileChanged(city, nil)
end
function FunctionUpgradingSprite:OnUpgrading(building, current_time, city)
end
function FunctionUpgradingSprite:OnUpgradingFinished(building, current_time, city)
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

function FunctionUpgradingSprite:ctor(city_layer, entity, city)
    FunctionUpgradingSprite.super.ctor(self, city_layer, entity)
    self:OnTileChanged(city, city:GetTileWhichBuildingBelongs(entity))
end

function FunctionUpgradingSprite:GetSpriteTopPosition()
    local type_ = self:GetEntity():GetType()
    if type_ == "keep" then
        local offset_x, offset_y = self:GetSpriteOffset()
        return offset_x - 30, offset_y + (self:GetSprite():getContentSize().height/2) * self:GetSprite():getScale() - 50
    elseif type_ == "watchTower" then
        local offset_x, offset_y = self:GetSpriteOffset()
        return offset_x - 30, offset_y + (self:GetSprite():getContentSize().height/2) * self:GetSprite():getScale() - 50
    end
    return FunctionUpgradingSprite.super.GetSpriteTopPosition(self)
end



return FunctionUpgradingSprite








