local Sprite = import(".Sprite")
local AirshipSprite = class("AirshipSprite", Sprite)


function AirshipSprite:GetWorldPosition()
    return self:convertToWorldSpace(cc.p(self:GetSpriteOffset())),
        self:convertToWorldSpace(cc.p(self:GetSpriteTopPosition()))
end
function AirshipSprite:GetSpriteTopPosition()
    local x,y = AirshipSprite.super.GetSpriteTopPosition(self)
    return x, y - 50
end
function AirshipSprite:ctor(city_layer, x, y)
    self.logic_x, self.logic_y = x, y
    AirshipSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    self:GetSprite():runAction(cc.RepeatForever:create(transition.sequence{
        cc.MoveBy:create(5, cc.p(0, 10)),
        cc.MoveBy:create(5, cc.p(0, -10))
    }))
    -- self:CreateBase()
end
function AirshipSprite:IsContainPointWithFullCheck(x, y, world_x, world_y)
    return { logic_clicked = false, sprite_clicked = self:IsContainWorldPoint(world_x, world_y)}
end
function AirshipSprite:GetEntity()
    return {
        GetType = function()
            return "airship"
        end,
        GetLogicPosition = function()
            return self.logic_x, self.logic_y
        end,
        GetMidLogicPosition = function()
            return self.logic_x + 3, self.logic_y + 3
        end
    }
end
function AirshipSprite:GetSpriteFile()
    return "airship.png"
end
function AirshipSprite:CreateSprite()
    local sprite = AirshipSprite.super.CreateSprite(self)
    local armature = ccs.Armature:create("feiting"):addTo(sprite)
    local p = sprite:getAnchorPointInPoints()
    armature:align(display.CENTER, p.x - 10, p.y + 40):getAnimation():playWithIndex(0)
    armature:getAnimation():setSpeedScale(2)
    return sprite
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










