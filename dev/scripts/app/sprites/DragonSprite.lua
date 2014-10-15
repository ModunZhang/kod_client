local AnimationSprite = import(".AnimationSprite")
local DragonSprite = class("DragonSprite", AnimationSprite)

function DragonSprite:ctor(map_layer, tarrain)
    AnimationSprite.super.ctor(self, map_layer, nil, 0, 0)
    self:ReloadSpriteCauseTerrainChanged(tarrain)
end
function DragonSprite:SetPositionWithZOrder()

end
function DragonSprite:GetLogicZorder()
    return 1
end
function DragonSprite:ReloadSpriteCauseTerrainChanged(terrain)
    if self.sprite then
        self.sprite:removeFromParent()
    end
    self.sprite = self:CreateSprite(terrain):addTo(self)
    self:AddAnimationCallbackTo(self.sprite)
    self:PlayAnimation("Idle")
end
function DragonSprite:CreateSprite(terrain)
    local dragon_animation
    if terrain == "grass" then
        dragon_animation = "green_dragon"
    elseif terrain == "desert" then
        dragon_animation = "Red_dragon"
    elseif terrain == "icefield" then
        dragon_animation = "Blue_dragon"
    end
    local armature = ccs.Armature:create(dragon_animation)
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    armature:setScaleX(-1.5)
    armature:setScaleY(1.5)
    armature:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))

    self.idle_count = 0
    return armature
end
function DragonSprite:OnAnimationStart(animation_name)
    if animation_name == "Fly" then
        self.idle_count = 0
    end
end
function DragonSprite:OnAnimationComplete(animation_name)
end
function DragonSprite:OnAnimationEnded(animation_name)
    if animation_name == "Idle" then
        self.idle_count = self.idle_count + 1
        local count = 10
        if self.idle_count > count then
            if (math.floor(math.random() * 10000) % count) < self.idle_count - count then
                self:PlayAnimation("Fly")
            end
        else
            self:PlayAnimation("Idle")
        end
    elseif animation_name == "Fly" then
        self:PlayAnimation("Idle")
    end
end


return DragonSprite


























