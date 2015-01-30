local Orient = import("..entity.Orient")
local UpgradingSprite = import(".UpgradingSprite")
local WallUpgradingSprite = class("WallUpgradingSprite", UpgradingSprite)

local offset_map = {
    [1] = {
        [Orient.X] = {15, 49},
        [Orient.Y] = {-16, 49},
        [Orient.NEG_X] = {15, 49},
        [Orient.NEG_Y] = {-16, 49},
        gate = {-62, 72}
    },
    [2] = {
        [Orient.X] = {15, 49},
        [Orient.Y] = {-16, 49},
        [Orient.NEG_X] = {15, 49},
        [Orient.NEG_Y] = {-16, 49},
        gate = {-62, 72}
    },
    [3] = {
        [Orient.X] = {15, 49},
        [Orient.Y] = {-16, 49},
        [Orient.NEG_X] = {15, 49},
        [Orient.NEG_Y] = {-16, 49},
        gate = {-75, 81}
    },
}
function WallUpgradingSprite:GetWorldPosition()
    local center_point = self:convertToWorldSpace(cc.p(self:GetSpriteOffset()))
    local bottom_point = self:convertToWorldSpace(cc.p(self:GetBottomOffset()))
    return center_point, bottom_point
end
----
function WallUpgradingSprite:ctor(city_layer, entity, level)
    self.level = level
    WallUpgradingSprite.super.ctor(self, city_layer, entity)
end
function WallUpgradingSprite:GetSpriteFile()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return string.format("wall_x_%d.png", self.level)
    elseif entity:GetOrient() == Orient.Y then
        return entity:IsGate() and string.format("gate_%d.png", self.level) or string.format("wall_y_%d.png", self.level)
    elseif entity:GetOrient() == Orient.NEG_X then
        return string.format("wall_x_%d.png", self.level)
    elseif entity:GetOrient() == Orient.NEG_Y then
        return string.format("wall_y_%d.png", self.level)
    end
    assert(false)
end
function WallUpgradingSprite:GetSpriteOffset()
    local entity = self:GetEntity()
    local offset = offset_map[self.level]
    if entity:IsGate() then
        return unpack(offset.gate)
    else
        return unpack(offset[entity:GetOrient()])
    end
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





















