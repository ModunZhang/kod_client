local AnimationSprite = import(".AnimationSprite")
local PeopleSprite = class("PeopleSprite", AnimationSprite)
function PeopleSprite:ctor(city_layer, x, y)
	self.x, self.y = x, y
    AnimationSprite.super.ctor(self, city_layer, nil, city_layer.iso_map:ConvertToMapPosition(x, y))
 	self:TurnRight()
 	self:PlayAnimation("Flying")
 	self:CreateBase()
end
function PeopleSprite:CreateSprite()
    local armature = ccs.Armature:create("Red_dragon")
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    armature:setScale(self:RealScale())
    return armature
end
function PeopleSprite:RealScale()
    return 1
end
function PeopleSprite:SetPositionWithZOrder(x, y)
	self.x, self.y = self:GetMap():ConvertToLogicPosition(x, y)
	PeopleSprite.super.SetPositionWithZOrder(self, x, y)
end
function PeopleSprite:GetMidLogicPosition()
    return self.x, self.y
end

return PeopleSprite



