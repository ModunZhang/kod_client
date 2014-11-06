local promise = import("..utils.promise")
local UILib = import(".UILib")
local Wall = class("Wall", function()
    return display.newNode()
end)

function Wall:ctor()
    print(UILib.soldier_animation.wall[1])
    self.wall = ccs.Armature:create(UILib.soldier_animation.wall[1]):addTo(self):align(display.CENTER, 0 ,0)
    self.wall:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))
    self.callback_map = {}
    self:setCascadeOpacityEnabled(true)
    self:setVisible(false)
    self:performWithDelay(function()
        self:setVisible(true)
    end, 0)
end
function Wall:PlayAnimation(ani, loop_time)
    if ani ~= "hurt" and ani ~= "attack" then
        return
    end
    self.wall:getAnimation():play(ani, -1, loop_time or -1)
end
function Wall:OnAnimationCallback(armatureBack, movementType, movementID)

end
function Wall:OnAnimationCallback(armatureBack, movementType, movementID)
    if movementType == ccs.MovementEventType.start then
        self:OnAnimationStart(movementID)
    elseif movementType == ccs.MovementEventType.complete then
        -- self:OnAnimationComplete(movementID)
        self:OnAnimationEnded(movementID)
    elseif movementType == ccs.MovementEventType.loopComplete then
        self:OnAnimationEnded(movementID)
    end
end
function Wall:OnAnimationStart(animation_name)

end
function Wall:OnAnimationComplete(animation_name)

end
function Wall:OnAnimationEnded(animation_name)
    local callbacks = self.callback_map[animation_name]
    for k, v in pairs(callbacks or {}) do
        v()
        callbacks[k] = nil
    end
end
function Wall:OnAnimationPlayEnd(ani_name, func)
    if ani_name ~= "hurt" and ani_name ~= "attack" then
        func()
        return
    end
    assert(type(func) == "function")
    if not self.callback_map[ani_name] then
        self.callback_map[ani_name] = {}
    end
    table.insert(self.callback_map[ani_name], func)
end
function Wall:FadeOut()
    return function(wall)
        local p = promise.new()
        transition.fadeOut(wall, {
            time = 0.5,
            onComplete = function()
                p:resolve(wall)
            end
        })
        return p
    end
end
function Wall:AttackOnce(right)
    return function(wall)
        wall:PlayAnimation("attack", 0)
        local p = promise.new()
        wall:OnAnimationPlayEnd("attack", function()
            p:resolve(wall)
        end)
        return p
    end
end
function Wall:HitOnce()
    return function(wall)
        wall:PlayAnimation("hurt", 0)
        local p = promise.new()
        wall:OnAnimationPlayEnd("hurt", function()
            p:resolve(wall)
        end)
        return p
    end
end
function Wall:TurnLeft()
    return function(wall)
        wall:setScaleX(1)
        local p = promise.new()
        wall:performWithDelay(function()
            p:resolve(wall)
        end, 0)
        return p
    end
end
function Wall:TurnRight()
    return function(wall)
        wall:setScaleX(-1)
        local p = promise.new()
        wall:performWithDelay(function()
            p:resolve(wall)
        end, 0)
        return p
    end
end
function Wall:BreathForever()
    return Wall:Hold()
end
function Wall:BreathOnce()
    return Wall:Hold()
end
function Wall:Hold()
    return function(corps)
        local p = promise.new()
        corps:performWithDelay(function()
            p:resolve(corps)
        end, 0)
        return p
    end
end
-- 实例方法
function Wall:Do(p)
    return promise.new(p)
end

return Wall









