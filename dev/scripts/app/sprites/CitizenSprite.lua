local Sprite = import(".Sprite")
local CitizenSprite = class("CitizenSprite", Sprite)

local scale = 0.3
function CitizenSprite:ctor(city_layer, x, y)
    CitizenSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
 	self:TurnRight()
 	self:PlayAnimation("move_1")
end
function CitizenSprite:PlayAnimation(animation)
    self.current_animation = animation
    self.sprite:getAnimation():play(animation)
end
function CitizenSprite:CreateSprite()
    local armature = ccs.Armature:create("Infantry_1_render")
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    -- armature:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))
    -- self.idle_count = 0
    return armature
end
function CitizenSprite:TurnRight()
	self:GetSprite():setScaleX(scale)
	self:GetSprite():setScaleY(scale)
	return self
end
function CitizenSprite:TurnLeft()
	self:GetSprite():setScaleX(-scale)
	self:GetSprite():setScaleY(scale)
	return self
end
function CitizenSprite:GetSpriteOffset()
    return 0, 15
end
function CitizenSprite:GetMidLogicPosition()
    return self:GetLogicMap():ConvertToLogicPosition(self:getPosition())
end
function CitizenSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end

return CitizenSprite



