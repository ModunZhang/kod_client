local Sprite = import(".Sprite")
local FairGroundSprite = class("FairGroundSprite", Sprite)

function FairGroundSprite:ctor(city_layer, x, y)
    FairGroundSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    -- self:CreateBase()
end
function FairGroundSprite:IsContainPointWithFullCheck(x, y, world_x, world_y)
    return { logic_clicked = false, sprite_clicked = self:IsContainRealPoint(world_x, world_y)}
end
function FairGroundSprite:GetEntity()
    return {
        GetType = function()
            return "FairGround"
        end
    }
end
function FairGroundSprite:GetSpriteFile()
    return "Fairground_386x297.png"
end
function FairGroundSprite:GetSpriteOffset()
    return 80, 130
end
function FairGroundSprite:GetMidLogicPosition()
    return self:GetLogicMap():ConvertToLogicPosition(self:getPosition())
end
function FairGroundSprite:CreateBase()
    self:GenerateBaseTiles(6, 9)
end


return FairGroundSprite










