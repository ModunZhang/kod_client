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
    if not entity:IsGate() then
        self:hide()
    end
end
function WallUpgradingSprite:GetSpriteFile()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return "wall_x_290x302.png"
    elseif entity:GetOrient() == Orient.Y then
        return entity:IsGate() and "gate_292x302.png" or "wall_y_292x302.png"
    elseif entity:GetOrient() == Orient.NEG_X then
        return "wall_neg_x_328x343.png"
    elseif entity:GetOrient() == Orient.NEG_Y then
        return "wall_neg_y_328x343.png"
    end
    assert(false)
end
function WallUpgradingSprite:GetSpriteOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 99, 125
    elseif entity:GetOrient() == Orient.Y then
        return -103, 120
    elseif entity:GetOrient() == Orient.NEG_X then
        return 120, 116
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -120, 116
    end
    assert(false)
end
function WallUpgradingSprite:GetFlipX()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return false
    elseif entity:GetOrient() == Orient.Y then
        return entity:IsGate()
        -- return false
    elseif entity:GetOrient() == Orient.NEG_X then
        return false
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
        return -100, 20
    elseif entity:GetOrient() == Orient.NEG_X then
        return 100, 20
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -100, 20
    end
    assert(false)
end
return WallUpgradingSprite



















