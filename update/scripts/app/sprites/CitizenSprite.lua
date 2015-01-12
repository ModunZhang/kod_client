local Sprite = import(".Sprite")
local CitizenSprite = class("CitizenSprite", Sprite)
function CitizenSprite:ctor(city_layer, x, y)
	self.x, self.y = x, y
    CitizenSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
 	self:TurnRight()
 	self:PlayAnimation("move_1")
 	-- self:CreateBase()
 	-- self.sprite:setVisible(false)
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
	self:GetSprite():setScaleX(0.5)
	self:GetSprite():setScaleY(0.5)
	return self
end
function CitizenSprite:TurnLeft()
	self:GetSprite():setScaleX(-0.5)
	self:GetSprite():setScaleY(0.5)
	return self
end
function CitizenSprite:GetSpriteOffset()
    return 0, 50
end
function CitizenSprite:SetPositionWithZOrder(x, y)
	self.x, self.y = self:GetLogicMap():ConvertToLogicPosition(x, y)
	CitizenSprite.super.SetPositionWithZOrder(self, x, y)
end
function CitizenSprite:GetMidLogicPosition()
    return self.x, self.y
end
function CitizenSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end

return CitizenSprite



