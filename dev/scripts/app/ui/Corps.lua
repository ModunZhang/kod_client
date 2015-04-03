local promise = import("..utils.promise")
local UILib = import(".UILib")
local BattleObject = import(".BattleObject")
local Corps = class("Corps", BattleObject)

local normal = GameDatas.Soldiers.normal
local special = GameDatas.Soldiers.special

local soldier_config = {
    ----
    ["swordsman"] = {
        x = -45,
        y = -120,
        {"bubing_1", -10, 45, 0.8},
        {"bubing_2", -20, 40, 0.8},
        {"bubing_3", -15, 35, 0.8},
    },
    ["ranger"] = {
        x = -45,
        y = -120,
        {"gongjianshou_1", 0, 45, 0.8},
        {"gongjianshou_2", 0, 45, 0.8},
        {"gongjianshou_3", 0, 45, 0.8},
    },
    ["lancer"] = {
        x = -45,
        y = -120,
        {"qibing_1", -10, 50, 0.8},
        {"qibing_2", -10, 50, 0.8},
        {"qibing_3", -10, 50, 0.8},
    },
    ["catapult"] = {
        x = 50,
        y = -80,
        {  "toushiche", 0, 35, 1},
        {"toushiche_2", 0, 35, 1},
        {"toushiche_3", 0, 35, 1},
    },

    -----
    ["sentinel"] = {
        x = -45,
        y = -120,
        {"shaobing_1", 0, 55, 0.8},
        {"shaobing_2", 0, 55, 0.8},
        {"shaobing_3", 0, 55, 0.8},
    },
    ["crossbowman"] = {
        x = -45,
        y = -120,
        {"nugongshou_1", 0, 45, 0.8},
        {"nugongshou_2", 0, 50, 0.8},
        {"nugongshou_3", 15, 45, 0.8},
    },
    ["horseArcher"] = {
        x = -45,
        y = -120,
        {"youqibing_1", -15, 55, 0.8},
        {"youqibing_2", -15, 55, 0.8},
        {"youqibing_3", -15, 55, 0.8},
    },
    ["ballista"] = {
        x = 100,
        y = -80,
        {"nuche_1", 0, 30, 1},
        {"nuche_2", 0, 30, 1},
        {"nuche_3", 0, 30, 1},
    },
    ----
    ["skeletonWarrior"] = {
        x = -45,
        y = -120,
        {"kulouyongshi", 0, 40, 0.8},
        {"kulouyongshi", 0, 40, 0.8},
        {"kulouyongshi", 0, 40, 0.8},
    },
    ["skeletonArcher"] = {
        x = -45,
        y = -120,
        {"kulousheshou", 25, 40, 0.8},
        {"kulousheshou", 25, 40, 0.8},
        {"kulousheshou", 25, 40, 0.8},
    },
    ["deathKnight"] = {
        x = -45,
        y = -120,
        {"siwangqishi", -10, 50, 0.8},
        {"siwangqishi", -10, 50, 0.8},
        {"siwangqishi", -10, 50, 0.8},
    },
    ["meatWagon"] = {
        x = 50,
        y = -80,
        {"jiaorouche", 0, 30, 0.8},
        {"jiaorouche", 0, 30, 0.8},
        {"jiaorouche", 0, 30, 0.8},
    },
}

function Corps:ctor(soldier, star, row, col, width, height)
    Corps.super.ctor(self)
    local corps = self
    self.soldier = soldier
    local config = special[self.soldier] or normal[self.soldier.."_"..star]
    self.config = config
    self.star = config.star
    width = width or 90
    height = height or 120
    local pos_config = soldier_config[self.soldier]
    local start_x, start_y = pos_config.x, pos_config.y
    local width, height = width * 2, height * 2
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
    local ani_name,_,_ = unpack(soldier_config[self.soldier][self.star])
    for i = 0, col_max * row_max - 1 do
        local armature = ccs.Armature:create(ani_name):addTo(corps):scale(1):pos(return_x_y_by_index(row_max, col_max, i))
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
function Corps:breath(is_forever)
    if self.config.type == "siege" then
        self:PlayAnimation("move_90", is_forever and -1 or 0)
        local p = promise.new()
        self:OnAnimationPlayEnd("move_90", function()
            p:resolve(self)
        end)
        return p
    else
        self:PlayAnimation("idle_90", is_forever and -1 or 0)
        local p = promise.new()
        self:OnAnimationPlayEnd("idle_90", function()
            p:resolve(self)
        end)
        return p
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








