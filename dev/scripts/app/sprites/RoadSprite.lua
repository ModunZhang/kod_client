local Sprite = import(".Sprite")
local RoadSprite = class("RoadSprite", Sprite)
function RoadSprite:ctor(city_layer, entity, x, y)
    RoadSprite.super.ctor(self, city_layer, entity, x, y)
end
function RoadSprite:ReloadSpriteCauseTerrainChanged()
    self.sprite:removeFromParent()
    self.sprite = self:CreateSprite():addTo(self, SPRITE)
end
function RoadSprite:GetSpriteFile()
	print(string.format("road_%s.png", self:GetMapLayer():Terrain()))
    return string.format("road_%s.png", self:GetMapLayer():Terrain())
end
function RoadSprite:GetSpriteOffset()
    return -400, -400
end
function RoadSprite:GetLogicZorder()
    local x, y = self:GetMidLogicPosition()
    return self:GetMapLayer():GetZOrderBy(self, x, y) - 200
end


return RoadSprite
















