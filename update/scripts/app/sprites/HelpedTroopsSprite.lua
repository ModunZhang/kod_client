local Sprite = import(".Sprite")
local HelpedTroopsSprite = class("HelpedTroopsSprite", Sprite)


function HelpedTroopsSprite:ctor(city_layer, x, y)
    self.x, self.y = x, y
    local ax, ay = city_layer:GetLogicMap():ConvertToMapPosition(x, y)
    HelpedTroopsSprite.super.ctor(self, city_layer, nil, ax, ay)
end
function HelpedTroopsSprite:GetSpriteFile()
    return "armyCamp_485x444.png", 0.6
end
function HelpedTroopsSprite:GetMidLogicPosition()
    return self.x, self.y
end

return HelpedTroopsSprite


















