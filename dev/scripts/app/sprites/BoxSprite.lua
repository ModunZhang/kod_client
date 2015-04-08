--
-- Author: Kenny Dai
-- Date: 2015-04-08 17:34:41
--
local AnimationSprite = import(".AnimationSprite")
local BoxSprite = class("BoxSprite", AnimationSprite)

function BoxSprite:ctor(box_type)
    AnimationSprite.super.ctor(self, nil, nil, display.cx-100, display.cy)
	self.box_type = box_type
end
function BoxSprite:CreateSprite()
	local box_type = self.box_type
    local box_animation
    if box_type == "dragonChest_1" then
        box_animation = "lanse"
    elseif box_type == "dragonChest_2" then
        box_animation = "lvse_box"
    elseif box_type == "dragonChest_3" then
        box_animation = "zise_box"
    else
        box_animation = box_type
    end
    local armature = ccs.Armature:create(box_animation)
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    armature:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))

    return armature
end

function BoxSprite:OnAnimationEnded(animation_name)
    self:removeFromParent(true)
end

return BoxSprite


























