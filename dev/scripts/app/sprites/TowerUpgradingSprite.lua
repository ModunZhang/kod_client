local Orient = import("..entity.Orient")
local UpgradingSprite = import(".UpgradingSprite")
local TowerUpgradingSprite = class("TowerUpgradingSprite", UpgradingSprite)
local HEAD_SPRITE = 2
function TowerUpgradingSprite:GetWorldPosition()
    local center_point = self:convertToWorldSpace(cc.p(self:GetSpriteOffset()))
    local bottom_point = self:convertToWorldSpace(cc.p(self:GetBottomOffset()))
    return center_point, bottom_point
end
---- 功能
function TowerUpgradingSprite:ctor(city_layer, entity)
    TowerUpgradingSprite.super.ctor(self, city_layer, entity)
end
function TowerUpgradingSprite:GetSpriteFile()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return "tower_x.png"
    elseif entity:GetOrient() == Orient.Y then
        return "tower_y.png"
    elseif entity:GetOrient() == Orient.NEG_X then
        -- return "tower_neg_x.png"
        assert(false)
    elseif entity:GetOrient() == Orient.NEG_Y then
        -- return "tower_neg_y.png"
        assert(false)
    elseif entity:GetOrient() == Orient.RIGHT then
        local x, y = entity:GetLogicPosition()
        if y < 0 then
            return "tower_right_x.png"
        end
        return "tower_right.png"
    elseif entity:GetOrient() == Orient.DOWN then
        return "tower_down.png"
    elseif entity:GetOrient() == Orient.LEFT then
        local x, y = entity:GetLogicPosition()
        if x < 0 then
            return "tower_left_y.png"
        end
        return "tower_left.png"
    elseif entity:GetOrient() == Orient.UP then
        return "tower_up.png"
    elseif entity:GetOrient() == Orient.NONE then
        return "tower_none.png"
        -- return entity:GetSubOrient() ~= nil and "tower_none_158x181.png" or "tower_none_80x154.png"
    end
    assert(false)
end
function TowerUpgradingSprite:GetSpriteOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 15, 75
    elseif entity:GetOrient() == Orient.Y then
        return -14, 74
    elseif entity:GetOrient() == Orient.NEG_X then
        return 83, 83
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -82, 83
    elseif entity:GetOrient() == Orient.RIGHT then
        local x, y = entity:GetLogicPosition()
        if y < 0 then
            return -17, 31
        end
        return -5, 63
    elseif entity:GetOrient() == Orient.DOWN then
        return 0, 71
    elseif entity:GetOrient() == Orient.LEFT then
        local x, y = entity:GetLogicPosition()
        if x < 0 then
            return -44, 73
        end
        return 16, 62
    elseif entity:GetOrient() == Orient.UP then
        return 0, -7
    elseif entity:GetOrient() == Orient.NONE then
        -- if entity:GetSubOrient() == Orient.LEFT then
        --     return 38,  38
        -- elseif entity:GetSubOrient() == Orient.RIGHT then
        --     return -38,  38
        -- end
        return 0, 71
    end
    assert(false)
end
function TowerUpgradingSprite:GetFlipX()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return false
    elseif entity:GetOrient() == Orient.Y then
        return true
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
        if entity:GetSubOrient() == Orient.LEFT then
            return true
        elseif entity:GetSubOrient() == Orient.RIGHT then
            return false
        end
        return false
    end
    assert(false)
end
function TowerUpgradingSprite:GetLogicZorder()
    local entity = self:GetEntity()
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
    return self:GetMapLayer():GetZOrderBy(self, x, y)
end
function TowerUpgradingSprite:GetHeadOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 60, 180
    elseif entity:GetOrient() == Orient.Y then
        return -60, 180
    elseif entity:GetOrient() == Orient.NEG_X then
        return 60, 175
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -60, 175
    elseif entity:GetOrient() == Orient.RIGHT then
        return 0, 140
    elseif entity:GetOrient() == Orient.DOWN then
        return -10, 135
    elseif entity:GetOrient() == Orient.LEFT then
        return 0, 140
    elseif entity:GetOrient() == Orient.UP then
        return 0, 130
    elseif entity:GetOrient() == Orient.NONE then
        return 0,  135
    end
    assert(false)
end
function TowerUpgradingSprite:GetBottomOffset()
    local entity = self:GetEntity()
    if entity:GetOrient() == Orient.X then
        return 30, 0
    elseif entity:GetOrient() == Orient.Y then
        return -50, 20
    elseif entity:GetOrient() == Orient.NEG_X then
        return 60, 165
    elseif entity:GetOrient() == Orient.NEG_Y then
        return -60, 165
    elseif entity:GetOrient() == Orient.RIGHT then
        return 0, 0
    elseif entity:GetOrient() == Orient.DOWN then
        return 0, 0
    elseif entity:GetOrient() == Orient.LEFT then
        return -20, 0
    elseif entity:GetOrient() == Orient.UP then
        return 0, 125
    elseif entity:GetOrient() == Orient.NONE then
        return 0,  0
    end
    assert(false)
end
return TowerUpgradingSprite























