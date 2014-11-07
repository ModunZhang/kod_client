local promise = import("..utils.promise")
local UILib = import(".UILib")
local BattleObject = import(".BattleObject")
local Wall = class("Wall", BattleObject)

function Wall:ctor()
    Wall.super.ctor(self)
    self.wall = ccs.Armature:create(UILib.soldier_animation.wall[1]):addTo(self):align(display.CENTER, 0 ,0)
    self.wall:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))
end
function Wall:PlayAnimation(ani, loop_time)
    if ani ~= "hurt" and ani ~= "attack" then
        return
    end
    self.wall:getAnimation():play(ani, -1, loop_time or -1)
end
function Wall:OnAnimationStart(animation_name)

end
function Wall:OnAnimationComplete(animation_name)

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
function Wall:turnLeft()
    self:setScaleX(1)
end
function Wall:turnRight()
    self:setScaleX(-1)
end
return Wall









