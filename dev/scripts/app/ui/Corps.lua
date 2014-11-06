local promise = import("..utils.promise")
local UILib = import(".UILib")
local Corps = class("Corps", function()
    return display.newNode()
end)


function Corps:ctor(soldier, row, col)
    local corps = self
    local start_x, start_y = -90, -120
    local width, height = - start_x * 2, - start_y * 2
    local function return_x_y_by_index(row_max, col_max, index)
        local unit_height = height / row_max
        local unit_width = width / col_max
        local cur_row = row_max - index % row_max - 1
        local cur_col = math.floor(index / row_max)
        return start_x + (cur_col + 0.5) * unit_width, start_y + (cur_row + 0.5) * unit_height
    end
    local row_max = row or 4
    local col_max = col or 2
    local t = {}
    local ani = UILib.soldier_animation[soldier][1] or "Infantry_1_render"
    for i = 0, col_max * row_max - 1 do
        local armature = ccs.Armature:create(ani):addTo(corps):scale(0.5):pos(return_x_y_by_index(row_max, col_max, i))
        table.insert(t, armature)
    end
    self.corps = t
    for _, v in pairs(self.corps) do
        v:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))
        break
    end
    self.callback_map = {}
    self:setCascadeOpacityEnabled(true)
    self:setVisible(false)
    self:performWithDelay(function()
        self:setVisible(true)
    end, 0)
end
function Corps:PlayAnimation(ani, loop_time)
    for _, v in pairs(self.corps) do
        v:getAnimation():play(ani, -1, loop_time or -1)
    end
end
function Corps:OnAnimationCallback(armatureBack, movementType, movementID)

end
function Corps:OnAnimationCallback(armatureBack, movementType, movementID)
    if movementType == ccs.MovementEventType.start then
        self:OnAnimationStart(movementID)
    elseif movementType == ccs.MovementEventType.complete then
        -- self:OnAnimationComplete(movementID)
        self:OnAnimationEnded(movementID)
    elseif movementType == ccs.MovementEventType.loopComplete then
        self:OnAnimationEnded(movementID)
    end
end
function Corps:OnAnimationStart(animation_name)

end
function Corps:OnAnimationComplete(animation_name)

end
function Corps:OnAnimationEnded(animation_name)
    local callbacks = self.callback_map[animation_name]
    for k, v in pairs(callbacks or {}) do
        v()
        callbacks[k] = nil
    end
end
function Corps:OnAnimationPlayEnd(ani_name, func)
    assert(type(func) == "function")
    if not self.callback_map[ani_name] then
        self.callback_map[ani_name] = {}
    end
    table.insert(self.callback_map[ani_name], func)
end
function Corps:FadeOut()
    return function(corps)
        local p = promise.new()
        transition.fadeOut(corps, {
            time = 0.5,
            onComplete = function()
                p:resolve(corps)
            end
        })
        return p
    end
end
function Corps:MoveTo(x, y, time)
    return function(corps)
        corps:PlayAnimation("move_2")
        local p = promise.new()
        transition.moveTo(corps, {
            x = x, y = y, time = time,
            onComplete = function()
                p:resolve(corps)
            end
        })
        return p
    end
end
function Corps:BreathForever()
    return function(corps)
        corps:PlayAnimation("idle_2")
        local p = promise.new()
        corps:OnAnimationPlayEnd("idle_2", function()
            p:resolve(corps)
        end)
        return p
    end
end
function Corps:BreathOnce()
    return function(corps)
        corps:PlayAnimation("idle_2", 0)
        local p = promise.new()
        corps:OnAnimationPlayEnd("idle_2", function()
            p:resolve(corps)
        end)
        return p
    end
end
function Corps:AttackOnce(right)
    return function(corps)
        corps:PlayAnimation("attack", 0)
        local p = promise.new()
        corps:OnAnimationPlayEnd("attack", function()
            p:resolve(corps)
        end)
        return p
    end
end
function Corps:HitOnce()
    return function(corps)
        corps:PlayAnimation("hurt", 0)
        local p = promise.new()
        corps:OnAnimationPlayEnd("hurt", function()
            p:resolve(corps)
        end)
        return p
    end
end
function Corps:TurnLeft()
    return function(corps)
        corps:setScaleX(-1)
        local p = promise.new()
        corps:performWithDelay(function()
            p:resolve(corps)
        end, 0)
        return p
    end
end
function Corps:TurnRight()
    return function(corps)
        corps:setScaleX(1)
        local p = promise.new()
        corps:performWithDelay(function()
            p:resolve(corps)
        end, 0)
        return p
    end
end
function Corps:Hold()
    return function(corps)
        local p = promise.new()
        corps:performWithDelay(function()
            p:resolve(corps)
        end, 0)
        return p
    end
end
-- 实例方法
function Corps:Do(p)
    return promise.new(p)
end

return Corps







