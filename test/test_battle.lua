--
-- Author: Danny He
-- Date: 2014-10-28 09:50:45
--
local Game = require("Game")
import("app.utils.GameUtils")
local normal_soldier = GameDatas.Soldiers.normal
module( "test_battle", lunit.testcase, package.seeall )

function createSoldiers(name, star, count)
    return {name = name, star = star, morale = 100, currentCount = count, totalCount = count, woundedCount = 0, round = 0}
end

local pow = math.pow
local ceil = math.ceil
local sqrt = math.sqrt
local floor = math.floor
local round = function(v)
    return floor(v + 0.5)
end
-- function test1()
--     local attackWoundedSoldierPercent = 0.4
--     local attackSoldiers = {
--         createSoldiers("swordsman", 1, 100),
--         createSoldiers("sentinel", 1, 100),
--         createSoldiers("ranger", 1, 100),
--     }

--     local defenceWoundedSoldierPercent = 0.4
--     local defenceSoldiers = {
--         createSoldiers("swordsman", 1, 100),
--         createSoldiers("sentinel", 1, 100),
--         createSoldiers("ranger", 1, 100),
--     }

--     local s1, s2 = soldier_soldier_battle(attackSoldiers, attackWoundedSoldierPercent, defenceSoldiers, defenceWoundedSoldierPercent)
--     -- dump(s1)
--     -- dump(s2)
-- end

function createDragon(strength, vitality, currentHp)
    return {strength = strength, vitality = vitality, currentHp = currentHp, totalHp = currentHp, hpMax = currentHp}
end
function test3()
    local attack_dragon, defence_dragon = GameUtils:DragonDragonBattle(createDragon(100, 100, 100), createDragon(100, 100, 100), 0.1)
    dump(attack_dragon)
    -- dump(defence_dragon)
    local attackWoundedSoldierPercent = 0.4
    local attackSoldiers = {
        createSoldiers("swordsman", 1, 100),
        createSoldiers("sentinel", 1, 100),
        createSoldiers("ranger", 1, 100),
    }
    local defenceWoundedSoldierPercent = 0.4
    local defenceSoldiers = {
        createSoldiers("swordsman", 1, 100),
        createSoldiers("sentinel", 1, 100),
        createSoldiers("ranger", 1, 100),
    }
    dump(attackSoldiers)
    local attack_soldier, defence_soldier = GameUtils:SoldierSoldierBattle(attackSoldiers, 0.4, defenceSoldiers, 0.4)
    dump(attackSoldiers)
    dump(attack_soldier)
end









