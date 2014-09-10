local Sprite = import(".Sprite")
local RuinSprite = class("RuinSprite", Sprite)
function RuinSprite:ctor(city_layer, entity)
    local x, y = city_layer.iso_map:ConvertToMapPosition(entity:GetLogicPosition())
    RuinSprite.super.ctor(self, city_layer, entity, x, y)
end
function RuinSprite:GetSpriteFile()
    local index = (math.floor(math.random() * 1000) % 3) + 1
    local ruin_png = "sprites/buildings/ruin_"..index..".png"
    return ruin_png
end
function RuinSprite:GetSpriteOffset()
    return 0, 80
end


return RuinSprite



