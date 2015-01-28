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
    WallUpgradingSprite.super.ctor(self, city_layer, entity)
end
function WallUpgradingSprite:GetSpriteFile()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return "wall_x.png"
    elseif entity:GetOrient() == Orient.Y then
        return entity:IsGate() and "gate.png" or "wall_y.png"
    elseif entity:GetOrient() == Orient.NEG_X then
        return "wall_x.png"
    elseif entity:GetOrient() == Orient.NEG_Y then
        return "wall_y.png"
    end
    assert(false)
end
function WallUpgradingSprite:GetSpriteOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 15, 49
    elseif entity:GetOrient() == Orient.Y then
        if entity:IsGate() then
            return -75, 81
        end
        return -16, 49
    elseif entity:GetOrient() == Orient.NEG_X then
        return 15, 49
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -16, 49
    end
    assert(false)
end
function WallUpgradingSprite:GetFlipX()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return true
    elseif entity:GetOrient() == Orient.Y then
        -- return entity:IsGate()
        return false
    elseif entity:GetOrient() == Orient.NEG_X then
        return true
    elseif entity:GetOrient() == Orient.NEG_Y then
        return false
    end
    assert(false)
end
function WallUpgradingSprite:GetBottomOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 120, 20
    elseif entity:GetOrient() == Orient.Y then
        if entity:IsGate() then
            return -150, 0
        end
        return 50, 22
    elseif entity:GetOrient() == Orient.NEG_X then
        return 100, 20
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -100, 20
    end
    assert(false)
end
return WallUpgradingSprite



















