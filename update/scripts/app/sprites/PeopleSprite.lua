local AnimationSprite = import(".AnimationSprite")
local PeopleSprite = class("PeopleSprite", AnimationSprite)
function PeopleSprite:ctor(city_layer, x, y)
	self.x, self.y = x, y
    AnimationSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
 	self:TurnLeft()
 	-- self:PlayAnimation("move_1")
 	-- self:CreateBase()
end
function PeopleSprite:CreateSprite()
    local armature = ccs.Armature:create("Infantry_1_render")
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    armature:setScale(self:RealScale())
    return armature
end
function PeopleSprite:RealScale()
    return 1
end
function PeopleSprite:SetPositionWithZOrder(x, y)
	self.x, self.y = self:GetLogicMap():ConvertToLogicPosition(x, y)
	PeopleSprite.super.SetPositionWithZOrder(self, x, y)
end
function PeopleSprite:GetMidLogicPosition()
    return self.x - 1, self.y - 1
end

return PeopleSprite



