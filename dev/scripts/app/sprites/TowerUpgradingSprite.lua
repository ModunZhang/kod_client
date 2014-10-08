local Orient = import("..entity.Orient")
local UpgradingSprite = import(".UpgradingSprite")
local TowerUpgradingSprite = class("TowerUpgradingSprite", UpgradingSprite)

function TowerUpgradingSprite:GetWorldPosition()
    local center_point = self:convertToWorldSpace(cc.p(self:GetSpriteOffset()))
    local bottom_point = self:convertToWorldSpace(cc.p(self:GetBottomOffset()))
    return center_point, bottom_point
end
---- 功能
function TowerUpgradingSprite:ctor(city_layer, entity)
    TowerUpgradingSprite.super.ctor(self, city_layer, entity)
    self.tower_sprite = display.newSprite("tower_head_78x124.png")
    self.tower_sprite:setPosition(self:GetHeadOffset())
    self:addChild(self.tower_sprite)
end
function TowerUpgradingSprite:GetSpriteFile()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return "tower_x_196x236.png"
    elseif entity:GetOrient() == Orient.Y then
        return "tower_y_196x236.png"
    elseif entity:GetOrient() == Orient.NEG_X then
        return "tower_neg_x_253x297.png"
    elseif entity:GetOrient() == Orient.NEG_Y then
        return "tower_neg_y_253x297.png"
    elseif entity:GetOrient() == Orient.RIGHT then
        return "tower_right_278x338.png"
    elseif entity:GetOrient() == Orient.DOWN then
        return "tower_down_307x234.png"
    elseif entity:GetOrient() == Orient.LEFT then
        return "tower_left_235x338.png"
    elseif entity:GetOrient() == Orient.UP then
        return "tower_up_327x266.png"
    elseif entity:GetOrient() == Orient.NONE then
        return "tower_none_158x181.png"
    end
    assert(false)
end
function TowerUpgradingSprite:GetSpriteOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 60, 92
    elseif entity:GetOrient() == Orient.Y then
        return -60, 92
    elseif entity:GetOrient() == Orient.NEG_X then
        return 60, 92
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -85, 87
    elseif entity:GetOrient() == Orient.RIGHT then
        return -62, 65
    elseif entity:GetOrient() == Orient.DOWN then
        return 0, 92
    elseif entity:GetOrient() == Orient.LEFT then
        return 70, 55
    elseif entity:GetOrient() == Orient.UP then
        return 0, -7
    elseif entity:GetOrient() == Orient.NONE then
        return 0,  50
    end
    assert(false)
end
function TowerUpgradingSprite:GetFlipX()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return false
    elseif entity:GetOrient() == Orient.Y then
        return false
    elseif entity:GetOrient() == Orient.NEG_X then
        return false
    elseif entity:GetOrient() == Orient.NEG_Y then
        return false
    elseif entity:GetOrient() == Orient.RIGHT then
        return false
    elseif entity:GetOrient() == Orient.DOWN then
        return false
    elseif entity:GetOrient() == Orient.LEFT then
        return false
    elseif entity:GetOrient() == Orient.UP then
        return false
    elseif entity:GetOrient() == Orient.NONE then
        return false
    end
    assert(false)
end
function TowerUpgradingSprite:GetLogicZorder(width)
    local entity = self:GetEntity()
    local map = self.iso_map
    local x, y
    if entity:GetOrient() == Orient.X then
        x, y = self:GetMidLogicPosition()
    elseif entity:GetOrient() == Orient.Y then
        x, y = self:GetMidLogicPosition()
    elseif entity:GetOrient() == Orient.NEG_X then
        x, y = self:GetMidLogicPosition()
    elseif entity:GetOrient() == Orient.NEG_Y then
        x, y = self:GetMidLogicPosition()
    elseif entity:GetOrient() == Orient.RIGHT then
        x, y = self:GetLogicPosition()
    elseif entity:GetOrient() == Orient.DOWN then
        x, y = self:GetLogicPosition()
    elseif entity:GetOrient() == Orient.LEFT then
        x, y = self:GetLogicPosition()
    elseif entity:GetOrient() == Orient.UP then
        x, y = self:GetLogicPosition()
    elseif entity:GetOrient() == Orient.NONE then
        x, y = self:GetMidLogicPosition()
    end
    return x + y * width + 100
end
function TowerUpgradingSprite:GetHeadOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 60, 180
    elseif entity:GetOrient() == Orient.Y then
        return -60, 180
    elseif entity:GetOrient() == Orient.NEG_X then
        return 60, 165
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -60, 165
    elseif entity:GetOrient() == Orient.RIGHT then
        return -10, 130
    elseif entity:GetOrient() == Orient.DOWN then
        return 0, 130
    elseif entity:GetOrient() == Orient.LEFT then
        return 10, 130
    elseif entity:GetOrient() == Orient.UP then
        return 0, 125
    elseif entity:GetOrient() == Orient.NONE then
        return 0,  135
    end
    assert(false)
end
function TowerUpgradingSprite:GetBottomOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 60, 0
    elseif entity:GetOrient() == Orient.Y then
        return -80, 20
    elseif entity:GetOrient() == Orient.NEG_X then
        return 60, 165
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -60, 165
    elseif entity:GetOrient() == Orient.RIGHT then
        return 0, 0
    elseif entity:GetOrient() == Orient.DOWN then
        return 0, 0
    elseif entity:GetOrient() == Orient.LEFT then
        return 0, 0
    elseif entity:GetOrient() == Orient.UP then
        return 0, 125
    elseif entity:GetOrient() == Orient.NONE then
        return 0,  0
    end
    assert(false)
end
return TowerUpgradingSprite






















