local Sprite = import(".Sprite")
local AirshipSprite = class("AirshipSprite", Sprite)

function AirshipSprite:ctor(city_layer, x, y)
    AirshipSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    self:GetSprite():runAction(cc.RepeatForever:create(transition.sequence{
        cc.MoveBy:create(5, cc.p(0, 20)),
        cc.MoveBy:create(5, cc.p(0, -20))
    }))
    -- self:CreateBase()
end
function AirshipSprite:IsContainPointWithFullCheck(x, y, world_x, world_y)
    return { logic_clicked = false, sprite_clicked = self:IsContainRealPoint(world_x, world_y)}
end
function AirshipSprite:GetEntity()
    return {
        GetType = function()
            return "airship"
        end
    }
end
function AirshipSprite:GetSpriteFile()
    return "airship.png"
end
function AirshipSprite:GetSpriteOffset()
    return 50, 50
end
function AirshipSprite:GetMidLogicPosition()
    return self:GetLogicMap():ConvertToLogicPosition(self:getPosition())
end
function AirshipSprite:CreateBase()
    self:GenerateBaseTiles(4, 6)
end


return AirshipSprite










