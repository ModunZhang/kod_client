local Orient = import("..entity.Orient")
local UpgradingSprite = import(".UpgradingSprite")
local WallUpgradingSprite = class("WallUpgradingSprite", UpgradingSprite)

function WallUpgradingSprite:GetWorldPosition()
    local center_point = self:convertToWorldSpace(cc.p(self:GetSpriteOffset()))
    local bottom_point = self:convertToWorldSpace(cc.p(self:GetBottomOffset()))
    return center_point, bottom_point
end
----
function WallUpgradingSprite:ctor(city_layer, entity)
    WallUpgradingSprite.super.ctor(self, city_layer, entity, x, y)
end
function WallUpgradingSprite:GetSpriteFile()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return entity:IsGate() and "sprites/walls/gate.png" or "sprites/walls/wall_x.png"
    elseif entity:GetOrient() == Orient.Y then
        return "sprites/walls/wall_x.png"
    elseif entity:GetOrient() == Orient.NEG_X then
        return "sprites/walls/wall_neg_x.png"
    elseif entity:GetOrient() == Orient.NEG_Y then
        return "sprites/walls/wall_neg_x.png"
    end
    assert(false)
end
function WallUpgradingSprite:GetSpriteOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 100, 120
    elseif entity:GetOrient() == Orient.Y then
        return -100, 120
    elseif entity:GetOrient() == Orient.NEG_X then
        return 100, 120
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -100, 120
    end
    assert(false)
end
function WallUpgradingSprite:GetFlipX()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return false
    elseif entity:GetOrient() == Orient.Y then
        return true
    elseif entity:GetOrient() == Orient.NEG_X then
        return false
    elseif entity:GetOrient() == Orient.NEG_Y then
        return true
    end
    assert(false)
end
function WallUpgradingSprite:GetBottomOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 120, 20
    elseif entity:GetOrient() == Orient.Y then
        return -100, 20
    elseif entity:GetOrient() == Orient.NEG_X then
        return 100, 20
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -100, 20
    end
    assert(false)
end
return WallUpgradingSprite



















