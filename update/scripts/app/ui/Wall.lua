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
    self.wall:getAnimation():play(ani, -1, loop_time or -1)
end
function Wall:turnLeft()
    self:setScaleX(1)
end
function Wall:turnRight()
    self:setScaleX(-1)
end
function Wall:breath()
    return promise.new()
end
return Wall









