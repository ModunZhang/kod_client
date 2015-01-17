--
-- Author: Danny He
-- Date: 2014-10-28 09:50:45
--
local Game = require("Game")
local normal_soldier = GameDatas.UnitsConfig.normal
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
local function soldier_soldier_battle(attackSoldiers, attackWoundedSoldierPercent, defenceSoldiers, defenceWoundedSoldierPercent)
    local attackResults = {}
    local defenceResults = {}
    while #attackSoldiers > 0 and #defenceSoldiers > 0 do
        local attackSoldier = attackSoldiers[1]
        local attackSoldierType = string.format("%s_%d", attackSoldier.name, attackSoldier.star)
        local attackSoldierConfig = normal_soldier[attackSoldierType]

        local defenceSoldier = defenceSoldiers[1]
        local defenceSoldierType = string.format("%s_%d", defenceSoldier.name, defenceSoldier.star)
        local defenceSoldierConfig = normal_soldier[defenceSoldierType]
        --
        local attackSoldierHp = attackSoldierConfig.hp
        local attackTotalPower = attackSoldierConfig[defenceSoldierConfig.type] * attackSoldier.currentCount

        local defenceSoldierHp = defenceSoldierConfig.hp
        local defenceTotalPower = defenceSoldierConfig[attackSoldierConfig.type] * defenceSoldier.currentCount
        --计算
        local attackDamagedSoldierCount
        local defenceDamagedSoldierCount
        if attackTotalPower >= defenceTotalPower then
            attackDamagedSoldierCount = round(defenceTotalPower * 0.5 / attackSoldierHp)
            defenceDamagedSoldierCount = round(sqrt(attackTotalPower * defenceTotalPower) * 0.5 / defenceSoldierHp)
        else
            attackDamagedSoldierCount = round(sqrt(attackTotalPower * defenceTotalPower) * 0.5 / attackSoldierHp)
            defenceDamagedSoldierCount = round(attackTotalPower * 0.5 / defenceSoldierHp)
        end
        -- 修正
        if attackDamagedSoldierCount > attackSoldier.currentCount * 0.7 then
            attackDamagedSoldierCount = floor(attackSoldier.currentCount * 0.7)
        end
        if defenceDamagedSoldierCount > defenceSoldier.currentCount * 0.7 then
            defenceDamagedSoldierCount = floor(defenceSoldier.currentCount * 0.7)
        end
        --
        local attackMoraleDecreased = ceil(attackDamagedSoldierCount * pow(2, attackSoldier.round - 1) / attackSoldier.totalCount * 100)
        local attackWoundedSoldierCount = ceil(attackDamagedSoldierCount * attackWoundedSoldierPercent)
        table.insert(attackResults, {
            soldierName = attackSoldier.name,
            soldierStar = attackSoldier.star,
            soldierCount = attackSoldier.currentCount,
            soldierDamagedCount = attackDamagedSoldierCount,
            soldierWoundedCount = attackWoundedSoldierCount,
            morale = attackSoldier.morale,
            moraleDecreased = attackMoraleDecreased > attackSoldier.morale and attackSoldier.morale or attackMoraleDecreased,
            isWin = attackTotalPower >= defenceTotalPower
        })
        attackSoldier.round = attackSoldier.round + 1
        attackSoldier.currentCount = attackSoldier.currentCount - attackDamagedSoldierCount
        attackSoldier.woundedCount = attackSoldier.woundedCount + attackWoundedSoldierCount
        attackSoldier.morale = attackSoldier.morale - attackMoraleDecreased


        local dfenceMoraleDecreased = ceil(defenceDamagedSoldierCount * pow(2, attackSoldier.round - 1) / defenceSoldier.totalCount * 100)
        local defenceWoundedSoldierCount = ceil(defenceDamagedSoldierCount * defenceWoundedSoldierPercent)
        table.insert(defenceResults, {
            soldierName = defenceSoldier.name,
            soldierStar = defenceSoldier.star,
            soldierCount = defenceSoldier.currentCount,
            soldierDamagedCount = defenceDamagedSoldierCount,
            soldierWoundedCount = defenceWoundedSoldierCount,
            morale = defenceSoldier.morale,
            moraleDecreased = dfenceMoraleDecreased > defenceSoldier.morale and defenceSoldier.morale or dfenceMoraleDecreased,
            isWin = attackTotalPower < defenceTotalPower
        })
        defenceSoldier.round = defenceSoldier.round + 1
        defenceSoldier.currentCount = defenceSoldier.currentCount - defenceDamagedSoldierCount
        defenceSoldier.woundedCount = defenceSoldier.woundedCount + defenceWoundedSoldierCount
        defenceSoldier.morale = defenceSoldier.morale - dfenceMoraleDecreased


        if attackTotalPower < defenceTotalPower or attackSoldier.morale <= 20 or attackSoldier.currentCount == 0 then
            table.remove(attackSoldiers, 1)
        end
        if attackTotalPower >= defenceTotalPower or defenceSoldier.morale <= 20 or defenceSoldier.currentCount == 0 then
            table.remove(defenceSoldiers, 1)
        end
    end
    return attackResults, defenceResults
end
function test1()
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

    local s1, s2 = soldier_soldier_battle(attackSoldiers, attackWoundedSoldierPercent, defenceSoldiers, defenceWoundedSoldierPercent)
    -- dump(s1)
    -- dump(s2)
end

function createDragon(strength, vitality, currentHp)
    return {strength = strength, vitality = vitality, currentHp = currentHp, totalHp = currentHp}
end
local function DragonDragonBattle(attackDragon, defenceDragon, effect)
    local attackDragonPower = attackDragon.strength * attackDragon.vitality

    local defenceDragonPower = defenceDragon.strength * defenceDragon.vitality

    if effect >= 0 then
        defenceDragonPower = defenceDragonPower * (1 - effect)
    else
        attackDragonPower = attackDragonPower * (1 + effect)
    end

    local attackDragonHpDecreased = round(defenceDragonPower * 0.02)
    attackDragon.currentHp = attackDragonHpDecreased > attackDragon.currentHp and 0 or attackDragon.currentHp - attackDragonHpDecreased

    local defenceDragonHpDecreased = round(attackDragonPower * 0.02)
    defenceDragon.currentHp = defenceDragonHpDecreased > defenceDragon.currentHp and 0 or defenceDragon.currentHp - defenceDragonHpDecreased

    return {
        hp = attackDragon.totalHp,
        hpDecreased = attackDragon.totalHp - attackDragon.currentHp,
        hpMax = attackDragon.hpMax,
        isWin = attackDragonPower >= defenceDragonPower
    }, {
        hp = defenceDragon.totalHp,
        hpDecreased = defenceDragon.totalHp - defenceDragon.currentHp,
        hpMax = defenceDragon.hpMax,
        isWin = attackDragonPower < defenceDragonPower
    }
end

function test2()
	local d1, d2 = DragonDragonBattle(createDragon(100, 100, 100), createDragon(100, 100, 100), 0.1)
	-- dump(d1)
	-- dump(d2)
end


function test3()
    local fogs = {}
    for i, v in ipairs({{1,2},{3,4}}) do
        fogs[#fogs + 1] = string.format("{%d,%d}", unpack(v))
    end
    print(string.format("{%s}", table.concat(fogs, ",")))

    local fogs = {}
    for i, v in ipairs({{1,2},{3,4}}) do
        fogs[#fogs + 1] = string.format("{%d,%d}", unpack(v))
    end
    print(string.format("{%d,%d,%s,%d}", 1, 2, 1, 0))
end








