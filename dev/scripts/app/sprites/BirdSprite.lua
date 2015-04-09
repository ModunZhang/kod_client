local Sprite = import(".Sprite")
local BirdSprite = class("BirdSprite", Sprite)

function BirdSprite:ctor(city_layer, x, y)
    BirdSprite.super.ctor(self, city_layer, nil, x, y)
    self:GetSprite():getAnimation():playWithIndex(0, -1)
    self:Refly()
end
function BirdSprite:Refly()
    self:GetSprite():setScaleX(-1) -- 往右飞
    -- if math.random(2) > 1 then
    --     self:GetSprite():setScaleX(-1) -- 往右飞
    -- else
    --     self:GetSprite():setScaleX(1) -- 往左飞
    -- end
    local size = self:GetMapLayer():getContentSize()
    local points = {
        cc.p(0, 0),
        cc.p(size.width/2, 0),
        cc.p(size.width, size.height),
    }
    self:pos(points[1].x, points[1].y)
    self:stopAllActions()
    self:runAction(transition.sequence({
        cc.BezierBy:create(20, points),
        cc.CallFunc:create(function()
            self:Refly()
        end)
    }))
end
function BirdSprite:CreateSprite()
    return ccs.Armature:create("gezi"):align(display.CENTER)
end
function BirdSprite:GetSpriteOffset()
    return 0,0
end
function BirdSprite:GetMidLogicPosition()
    return 0,0
end

return BirdSprite













