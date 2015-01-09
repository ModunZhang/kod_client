local Sprite = import(".Sprite")
local RoadSprite = class("RoadSprite", Sprite)
function RoadSprite:ctor(city_layer, entity, x, y)
    RoadSprite.super.ctor(self, city_layer, entity, x, y)
end
function RoadSprite:GetSpriteFile()
    return "road.png"
end
function RoadSprite:GetSpriteOffset()
    return 300, -150
end
function RoadSprite:GetLogicZorder()
    local x, y = self:GetMidLogicPosition()
    return self:GetMapLayer():GetZOrderBy(self, x, y) - 200
end


return RoadSprite
















