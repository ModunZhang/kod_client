local promise = import("..utils.promise")
local UILib = import(".UILib")
local BattleObject = import(".BattleObject")
local Corps = class("Corps", BattleObject)

local normal = GameDatas.Soldiers.normal
local special = GameDatas.Soldiers.special


function Corps:ctor(soldier, star, row, col, width, height)
	Corps.super.ctor(self)
    local corps = self
    self.soldier = soldier
    local config = special[self.soldier] or normal[self.soldier.."_"..star]
    self.star = config.star
    width = width or 90
    height = height or 120
    local start_x, start_y = - width, - height
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
    local ani = UILib.soldier_animation[soldier] and UILib.soldier_animation[soldier][1] or "Infantry_1_render"
    for i = 0, col_max * row_max - 1 do
        local armature = ccs.Armature:create(ani):addTo(corps):scale(1):pos(return_x_y_by_index(row_max, col_max, i))
        table.insert(t, armature)
    end
    self.corps = t
    for _, v in pairs(self.corps) do
        v:getAnimation():setMovementEventCallFunc(handler(self, self.OnAnimationCallback))
        break
    end
end
function Corps:PlayAnimation(ani, loop_time)
    if ani == "attack" then
        app:GetAudioManager():PlayeAttackSoundBySoldierName(self.soldier)
    end
    for _, v in pairs(self.corps) do
        v:getAnimation():play(ani, -1, loop_time or -1)
    end
end
function Corps:turnLeft()
    self:setScaleX(-1)
end
function Corps:turnRight()
    self:setScaleX(1)
end
function Corps:GetSoldierConfig()
    return special[self.soldier] or normal[self.soldier.."_"..self.star]
end
function Corps:move(time, x, y)
    local config = self:GetSoldierConfig()
    local type_ = config.type
    local function step()
        app:GetAudioManager():PlaySoldierStepEffectByType(type_)
    end
    self:runAction(
        transition.sequence{
            cc.CallFunc:create(step),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(step),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(step),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(step),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(step)
        }
    )
    return Corps.super.move(self, time, x, y)
end
return Corps







