local DragonSprite = class("DragonSprite", function()
    return display.newNode()
end)

function DragonSprite:ctor(tarrain)
    self.label = ui.newTTFLabel({ text = "text" , size = 50, x = 0, y = 0 }):addTo(self, 1)
    self.armature = self:CreateSprite(tarrain):addTo(self)
    self:PlayAnimation("Idle")
end
function DragonSprite:ReloadSprite(terrain)
    self.armature:removeFromParent()
    self.armature = self:CreateSprite(terrain):addTo(self, SPRITE)
    self:PlayAnimation("Idle")
end
function DragonSprite:CreateSprite(terrain)
    if terrain == "grass" then
        self.label:setString("这是绿龙")
    elseif terrain == "desert" then
        self.label:setString("这是红龙")
    elseif terrain == "icefield" then
        self.label:setString("这是蓝龙")
    end
    local armature = ccs.Armature:create("Red_dragon")
    armature:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
    armature:setScaleX(-1.5)
    armature:setScaleY(1.5)
    armature:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))

    self.idle_count = 0
    return armature
end
function DragonSprite:OnAnimationCallback(armatureBack, movementType, movementID)
    if movementType == ccs.MovementEventType.start then
    elseif movementType == ccs.MovementEventType.complete then
    elseif movementType == ccs.MovementEventType.loopComplete then
        if movementID == "Idle" then
            self.idle_count = self.idle_count + 1
            if self.idle_count > 10 then
                if (math.floor(math.random() * 10) % 10) < self.idle_count - 10 then
                    self:PlayAnimation("Fly")
                end
            else
                self:PlayAnimation("Idle")
            end
        elseif movementID == "Fly" then
            self.idle_count = 0
            self:PlayAnimation("Idle")
        end
    end
end
function DragonSprite:PlayAnimation(animation)
    self.current_animation = animation
    self.armature:getAnimation():play(animation)
end
function DragonSprite:CurrentAnimation()
    return self.current_animation
end


return DragonSprite























