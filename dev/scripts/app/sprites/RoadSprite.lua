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
function RoadSprite:GetLogicZorder(width)
    local x, y = self:GetMidLogicPosition()
    return x + y * width
end


return RoadSprite
















