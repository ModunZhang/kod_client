local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local UILib = import(".UILib")
local BattleObject = class("BattleObject", function()
    return display.newNode()
end)
function BattleObject:ctor()
    self.callback_map = {}
    self:setCascadeOpacityEnabled(true)
    self:setVisible(false)
    self:performWithDelay(function()
        self:setVisible(true)
    end, 0)
    self:setCascadeColorEnabled(true)
end
function BattleObject:PlayAnimation(ani, loop_time)
    assert(false)
end
function BattleObject:OnAnimationCallback(armatureBack, movementType, movementID)
    if movementType == ccs.MovementEventType.start then
        self:OnAnimationStart(movementID)
    elseif movementType == ccs.MovementEventType.complete then
        self:OnAnimationComplete(movementID)
        self:OnAnimationEnded(movementID)
    elseif movementType == ccs.MovementEventType.loopComplete then
        self:OnAnimationEnded(movementID)
    end
end
function BattleObject:OnAnimationStart(animation_name)
end
function BattleObject:OnAnimationComplete(animation_name)
end
function BattleObject:OnAnimationEnded(animation_name)
    local callbacks = self.callback_map[animation_name]
    for k, v in pairs(callbacks or {}) do
        v()
        callbacks[k] = nil
    end
end
function BattleObject:OnAnimationPlayEnd(ani_name, func)
    assert(type(func) == "function")
    if not self.callback_map[ani_name] then
        self.callback_map[ani_name] = {}
    end
    table.insert(self.callback_map[ani_name], func)
end
function BattleObject:turnLeft()
    assert(false)
end
function BattleObject:turnRight()
    assert(false)
end
function BattleObject:hit()
    self:PlayAnimation("hurt", 0)
    local p = promise.new()
    self:OnAnimationPlayEnd("hurt", function()
        p:resolve(self)
    end)
    return p
end
function BattleObject:attack()
    self:PlayAnimation("attack", 0)
    local p = promise.new()
    self:OnAnimationPlayEnd("attack", function()
        p:resolve(self)
    end)
    return p
end
function BattleObject:breath(is_forever)
    self:PlayAnimation("idle_2", is_forever and -1 or 0)
    local p = promise.new()
    self:OnAnimationPlayEnd("idle_2", function()
        p:resolve(self)
    end)
    return p
end
function BattleObject:move(time, x, y)
    self:PlayAnimation("move_2")
    local p = promise.new()
    transition.moveTo(self, {
        x = x, y = y, time = time,
        onComplete = function()
            p:resolve(self)
        end
    })
    return p
end
function BattleObject:defeat()
    local p = promise.new()
    transition.fadeOut(self, {
        time = 0.5,
        onComplete = function()
            p:resolve(self)
        end
    })
    return p
end
function BattleObject:Defeat()
    return function(object)
        return object:defeat()
    end
end
function BattleObject:MoveTo(time, x, y)
    return function(object)
        return object:move(time, x, y)
    end
end
function BattleObject:BreathForever()
    return function(object)
        return object:breath(true)
    end
end
function BattleObject:BreathOnce()
    return function(object)
        return object:breath(false)
    end
end
function BattleObject:AttackOnce(right)
    return function(object)
        return object:attack()
    end
end
function BattleObject:HitOnce()
    return function(object)
        return object:hit()
    end
end
function BattleObject:TurnLeft()
    return function(object)
        object:turnLeft()
        local p = promise.new()
        object:performWithDelay(function()
            p:resolve(object)
        end, 0)
        return p
    end
end
function BattleObject:TurnRight()
    return function(object)
        object:turnRight()
        local p = promise.new()
        object:performWithDelay(function()
            p:resolve(object)
        end, 0)
        return p
    end
end
function BattleObject:Move()
    return function(object)
        object:PlayAnimation("move_2")
        local p = promise.new()
        object:OnAnimationPlayEnd("move_2", function()
            p:resolve(object)
        end)
        return p
    end
end
function BattleObject:Hold()
    return function(object)
        local p = promise.new()
        object:performWithDelay(function()
            p:resolve(object)
        end, 0)
        return p
    end
end
-- 实例方法
function BattleObject:Do(p)
    return promise.new(p)
end

return BattleObject





















