local Sprite = import(".Sprite")
local RuinSprite = class("RuinSprite", Sprite)
local random = math.random
function RuinSprite:ctor(city_layer, entity)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    RuinSprite.super.ctor(self, city_layer, entity, x, y)
end
function RuinSprite:GetSpriteFile()
    local index = random(123456789) % 2 + 1
    local ruin_png = index == 1 and "ruin_1_136x92.png" or "ruin_2_132x90.png"
    return ruin_png
end
function RuinSprite:GetSpriteOffset()
    return 0, 60
end


return RuinSprite



