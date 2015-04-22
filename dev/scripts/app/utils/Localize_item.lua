--
-- Author: Kenny Dai
-- Date: 2015-01-22 16:43:00
--
local items = GameDatas.Items
local buff = items.buff
local resource = items.resource
local special = items.special
local speedup = items.speedup
local function formatMin(time)
    time = tonumber(time)
    local new_time = math.floor(time / (60*24))
    if new_time>0 then
        return new_time.._("天")
    end
    local new_time = math.floor(time / 60)

    if new_time>0 then
        return new_time.._("小时")
    end
    return time.._("分钟")
end

local ITEM_CATEGORY_NAME = {
    -- buff
    masterOfDefender = _("城防大师"),
    quarterMaster = _("军需官"),
    fogOfTrick = _("诡计之雾"),
    woodBonus = _("木材生产加成"),
    stoneBonus = _("石料生产加成"),
    ironBonus = _("铁矿生产加成"),
    foodBonus = _("粮食生产加成"),
    coinBonus = _("银币生产加成"),
    citizenBonus = _("城民增长加成"),
    dragonExpBonus = _("龙语卷轴"),
    troopSizeBonus = _("战争号角"),
    dragonHpBonus = _("龙族纹章"),
    marchSpeedBonus = _("行军加速"),
    unitHpBonus = _("防御加成"),
    infantryAtkBonus = _("步兵攻击加成"),
    archerAtkBonus = _("弓手攻击加成"),
    cavalryAtkBonus = _("骑兵攻击加成"),
    siegeAtkBonus = _("攻城机械攻击加成"),
}
local ITEM_NAME = {
    -- buff
    masterOfDefender_1 = buff.masterOfDefender_1.effect.._("小时").._("城防大师"),
    masterOfDefender_2 = buff.masterOfDefender_2.effect.._("小时").._("城防大师"),
    masterOfDefender_3 = buff.masterOfDefender_3.effect.._("小时").._("城防大师"),
    quarterMaster_1 = buff.quarterMaster_1.effect.._("小时").._("军需官"),
    quarterMaster_2 = buff.quarterMaster_2.effect.._("小时").._("军需官"),
    quarterMaster_3 = buff.quarterMaster_3.effect.._("小时").._("军需官"),
    fogOfTrick_1 = buff.fogOfTrick_1.effect.._("小时").._("诡计之雾"),
    fogOfTrick_2 = buff.fogOfTrick_2.effect.._("小时").._("诡计之雾"),
    fogOfTrick_3 = buff.fogOfTrick_3.effect.._("小时").._("诡计之雾"),
    woodBonus_1 = buff.woodBonus_1.effect.._("小时").._("木材生产加成"),
    woodBonus_2 = buff.woodBonus_2.effect.._("小时").._("木材生产加成"),
    woodBonus_3 = buff.woodBonus_3.effect.._("小时").._("木材生产加成"),
    stoneBonus_1 = buff.stoneBonus_1.effect.._("小时").._("石料生产加成"),
    stoneBonus_2 = buff.stoneBonus_2.effect.._("小时").._("石料生产加成"),
    stoneBonus_3 = buff.stoneBonus_3.effect.._("小时").._("石料生产加成"),
    ironBonus_1 = buff.ironBonus_1.effect.._("小时").._("铁矿生产加成"),
    ironBonus_2 = buff.ironBonus_2.effect.._("小时").._("铁矿生产加成"),
    ironBonus_3 = buff.ironBonus_3.effect.._("小时").._("铁矿生产加成"),
    foodBonus_1 = buff.foodBonus_1.effect.._("小时").._("粮食生产加成"),
    foodBonus_2 = buff.foodBonus_2.effect.._("小时").._("粮食生产加成"),
    foodBonus_3 = buff.foodBonus_3.effect.._("小时").._("粮食生产加成"),
    coinBonus_1 = buff.coinBonus_1.effect.._("小时").._("银币生产加成"),
    coinBonus_2 = buff.coinBonus_2.effect.._("小时").._("银币生产加成"),
    coinBonus_3 = buff.coinBonus_3.effect.._("小时").._("银币生产加成"),
    citizenBonus_1 = buff.citizenBonus_1.effect.._("小时").._("城民增长加成"),
    citizenBonus_2 = buff.citizenBonus_2.effect.._("小时").._("城民增长加成"),
    citizenBonus_3 = buff.citizenBonus_3.effect.._("小时").._("城民增长加成"),
    dragonExpBonus_1 = buff.dragonExpBonus_1.effect.._("小时").._("龙语卷轴"),
    dragonExpBonus_2 = buff.dragonExpBonus_2.effect.._("小时").._("龙语卷轴"),
    dragonExpBonus_3 = buff.dragonExpBonus_3.effect.._("小时").._("龙语卷轴"),
    troopSizeBonus_1 = buff.troopSizeBonus_1.effect.._("小时").._("战争号角"),
    troopSizeBonus_2 = buff.troopSizeBonus_2.effect.._("小时").._("战争号角"),
    troopSizeBonus_3 = buff.troopSizeBonus_3.effect.._("小时").._("战争号角"),
    dragonHpBonus_1 = buff.dragonHpBonus_1.effect.._("小时").._("龙族纹章"),
    dragonHpBonus_2 = buff.dragonHpBonus_2.effect.._("小时").._("龙族纹章"),
    dragonHpBonus_3 = buff.dragonHpBonus_3.effect.._("小时").._("龙族纹章"),
    marchSpeedBonus_1 = buff.marchSpeedBonus_1.effect.._("小时").._("行军加速"),
    marchSpeedBonus_2 = buff.marchSpeedBonus_2.effect.._("小时").._("行军加速"),
    marchSpeedBonus_3 = buff.marchSpeedBonus_3.effect.._("小时").._("行军加速"),
    unitHpBonus_1 = buff.unitHpBonus_1.effect.._("小时").._("防御加成"),
    unitHpBonus_2 = buff.unitHpBonus_2.effect.._("小时").._("防御加成"),
    unitHpBonus_3 = buff.unitHpBonus_3.effect.._("小时").._("防御加成"),
    infantryAtkBonus_1 = buff.infantryAtkBonus_1.effect.._("小时").._("步兵攻击加成"),
    infantryAtkBonus_2 = buff.infantryAtkBonus_2.effect.._("小时").._("步兵攻击加成"),
    infantryAtkBonus_3 = buff.infantryAtkBonus_3.effect.._("小时").._("步兵攻击加成"),
    archerAtkBonus_1 = buff.archerAtkBonus_1.effect.._("小时").._("弓手攻击加成"),
    archerAtkBonus_2 = buff.archerAtkBonus_2.effect.._("小时").._("弓手攻击加成"),
    archerAtkBonus_3 = buff.archerAtkBonus_3.effect.._("小时").._("弓手攻击加成"),
    cavalryAtkBonus_1 = buff.cavalryAtkBonus_1.effect.._("小时").._("骑兵攻击加成"),
    cavalryAtkBonus_2 = buff.cavalryAtkBonus_2.effect.._("小时").._("骑兵攻击加成"),
    cavalryAtkBonus_3 = buff.cavalryAtkBonus_3.effect.._("小时").._("骑兵攻击加成"),
    siegeAtkBonus_1 = buff.siegeAtkBonus_1.effect.._("小时").._("攻城机械攻击加成"),
    siegeAtkBonus_2 = buff.siegeAtkBonus_2.effect.._("小时").._("攻城机械攻击加成"),
    siegeAtkBonus_3 = buff.siegeAtkBonus_3.effect.._("小时").._("攻城机械攻击加成"),

    -- resource
    woodClass_1 = resource.woodClass_1.effect.."K".._("木材"),
    woodClass_2 = resource.woodClass_2.effect.."K".._("木材"),
    woodClass_3 = resource.woodClass_3.effect.."K".._("木材"),
    woodClass_4 = resource.woodClass_4.effect.."K".._("木材"),
    woodClass_5 = resource.woodClass_5.effect.."K".._("木材"),
    woodClass_6 = resource.woodClass_6.effect.."K".._("木材"),
    woodClass_7 = resource.woodClass_7.effect.."K".._("木材"),
    stoneClass_1 = resource.stoneClass_1.effect.."K".._("石料"),
    stoneClass_2 = resource.stoneClass_2.effect.."K".._("石料"),
    stoneClass_3 = resource.stoneClass_3.effect.."K".._("石料"),
    stoneClass_4 = resource.stoneClass_4.effect.."K".._("石料"),
    stoneClass_5 = resource.stoneClass_5.effect.."K".._("石料"),
    stoneClass_6 = resource.stoneClass_6.effect.."K".._("石料"),
    stoneClass_7 = resource.stoneClass_7.effect.."K".._("石料"),
    ironClass_1 = resource.ironClass_1.effect.."K".._("铁矿"),
    ironClass_2 = resource.ironClass_2.effect.."K".._("铁矿"),
    ironClass_3 = resource.ironClass_3.effect.."K".._("铁矿"),
    ironClass_4 = resource.ironClass_4.effect.."K".._("铁矿"),
    ironClass_5 = resource.ironClass_5.effect.."K".._("铁矿"),
    ironClass_6 = resource.ironClass_6.effect.."K".._("铁矿"),
    ironClass_7 = resource.ironClass_7.effect.."K".._("铁矿"),
    foodClass_1 = resource.foodClass_1.effect.."K".._("粮食"),
    foodClass_2 = resource.foodClass_2.effect.."K".._("粮食"),
    foodClass_3 = resource.foodClass_3.effect.."K".._("粮食"),
    foodClass_4 = resource.foodClass_4.effect.."K".._("粮食"),
    foodClass_5 = resource.foodClass_5.effect.."K".._("粮食"),
    foodClass_6 = resource.foodClass_6.effect.."K".._("粮食"),
    foodClass_7 = resource.foodClass_7.effect.."K".._("粮食"),
    coinClass_1 = resource.coinClass_1.effect.."K".._("银币"),
    coinClass_2 = resource.coinClass_2.effect.."K".._("银币"),
    coinClass_3 = resource.coinClass_3.effect.."K".._("银币"),
    coinClass_4 = resource.coinClass_4.effect.."K".._("银币"),
    coinClass_5 = resource.coinClass_5.effect.."K".._("银币"),
    coinClass_6 = resource.coinClass_6.effect.."K".._("银币"),
    coinClass_7 = resource.coinClass_7.effect.."K".._("银币"),
    citizenClass_1 = (resource.citizenClass_1.effect*100).."%".._("空闲城民"),
    citizenClass_2 = (resource.citizenClass_2.effect*100).."%".._("空闲城民"),
    citizenClass_3 = (resource.citizenClass_3.effect*100).."%".._("空闲城民"),
    casinoTokenClass_1 = resource.casinoTokenClass_1.effect.."K".._("赌场筹码"),
    casinoTokenClass_2 = resource.casinoTokenClass_2.effect.."K".._("赌场筹码"),
    casinoTokenClass_3 = resource.casinoTokenClass_3.effect.."K".._("赌场筹码"),
    casinoTokenClass_4 = resource.casinoTokenClass_4.effect.."K".._("赌场筹码"),

    -- special
    movingConstruction = _("建筑移动"),
    torch = _("火炬"),
    changePlayerName = _("玩家改名卡"),
    changeCityName = _("城市改名卡"),
    retreatTroop = _("撤军令"),
    moveTheCity = _("城市移动"),
    dragonExp_1 = tonumber(special.dragonExp_1.effect).._("龙经验值"),
    dragonExp_2 = tonumber(special.dragonExp_2.effect).._("龙经验值"),
    dragonExp_3 = tonumber(special.dragonExp_3.effect).._("龙经验值"),
    dragonHp_1 = tonumber(special.dragonHp_1.effect).._("点").._("龙的生命值"),
    dragonHp_2 = tonumber(special.dragonHp_2.effect).._("点").._("龙的生命值"),
    dragonHp_3 = tonumber(special.dragonHp_3.effect).._("点").._("龙的生命值"),
    heroBlood_1 = tonumber(special.heroBlood_1.effect).._("英雄之血"),
    heroBlood_2 = tonumber(special.heroBlood_2.effect).._("英雄之血"),
    heroBlood_3 = tonumber(special.heroBlood_3.effect).._("英雄之血"),
    stamina_1 = _("体力药剂(小)"),
    stamina_2 = _("体力药剂(中)"),
    stamina_3 = _("体力药剂(大)"),
    restoreWall_1 = tonumber(special.restoreWall_1.effect).._("点").._("城墙生命值"),
    restoreWall_2 = tonumber(special.restoreWall_2.effect).._("点").._("城墙生命值"),
    restoreWall_3 = tonumber(special.restoreWall_3.effect).._("点").._("城墙生命值"),
    dragonChest_1 = _("初级").._("巨龙宝箱"),
    dragonChest_2 = _("中级").._("巨龙宝箱"),
    dragonChest_3 = _("高级").._("巨龙宝箱"),
    chest_1 = _("木").._("宝箱"),
    chest_2 = _("铜").._("宝箱"),
    chest_3 = _("银").._("宝箱"),
    chest_4 = _("金").._("宝箱"),
    chestKey_2 = _("铜").._("钥匙"),
    chestKey_3 = _("银").._("钥匙"),
    chestKey_4 = _("金").._("钥匙"),
    vipActive_1 = "VIP".._("激活")..formatMin(special.vipActive_1.effect),
    vipActive_2 = "VIP".._("激活")..formatMin(special.vipActive_2.effect),
    vipActive_3 = "VIP".._("激活")..formatMin(special.vipActive_3.effect),
    vipActive_4 = "VIP".._("激活")..formatMin(special.vipActive_4.effect),
    vipActive_5 = "VIP".._("激活")..formatMin(special.vipActive_5.effect),
    vipPoint_1 = tonumber(special.vipPoint_1.effect).."VIP".._("点数"),
    vipPoint_2 = tonumber(special.vipPoint_2.effect).."VIP".._("点数"),
    vipPoint_3 = tonumber(special.vipPoint_3.effect).."VIP".._("点数"),
    vipPoint_4 = tonumber(special.vipPoint_4.effect).."VIP".._("点数"),

    -- speedup
    speedup_1 = formatMin(speedup.speedup_1.effect).._("加速"),
    speedup_2 = formatMin(speedup.speedup_2.effect).._("加速"),
    speedup_3 = formatMin(speedup.speedup_3.effect).._("加速"),
    speedup_4 = formatMin(speedup.speedup_4.effect).._("加速"),
    speedup_5 = formatMin(speedup.speedup_5.effect).._("加速"),
    speedup_6 = formatMin(speedup.speedup_6.effect).._("加速"),
    speedup_7 = formatMin(speedup.speedup_7.effect).._("加速"),
    speedup_8 = formatMin(speedup.speedup_8.effect).._("加速"),
    warSpeedupClass_1 = _("普通").._("战争沙漏"),         
    warSpeedupClass_2 = _("强化").._("战争沙漏"),
}

local ITEM_DESC= {
    -- buff
    masterOfDefender_1 = _("战败时无法被掠夺资源，但城墙会受到攻击。同时防御时的战损下降20%，持续")..buff.masterOfDefender_1.effect.._("小时"),
    masterOfDefender_2 = _("战败时无法被掠夺资源，但城墙会受到攻击。同时防御时的战损下降20%，持续")..buff.masterOfDefender_2.effect.._("小时"),
    masterOfDefender_3 = _("战败时无法被掠夺资源，但城墙会受到攻击。同时防御时的战损下降20%，持续")..buff.masterOfDefender_3.effect.._("小时"),
    quarterMaster_1 = _("减少25%的维护费用，持续")..buff.quarterMaster_1.effect.._("小时"),
    quarterMaster_2 = _("减少25%的维护费用，持续")..buff.quarterMaster_2.effect.._("小时"),
    quarterMaster_3 = _("减少25%的维护费用，持续")..buff.quarterMaster_3.effect.._("小时"),
    fogOfTrick_1 = _("敌方突袭成功后无法获得侦查情报，也无法抢到银币（仅对玩家本人有效，对协防玩家无效）持续")..buff.fogOfTrick_1.effect.._("小时"),
    fogOfTrick_2 = _("敌方突袭成功后无法获得侦查情报，也无法抢到银币（仅对玩家本人有效，对协防玩家无效）持续")..buff.fogOfTrick_2.effect.._("小时"),
    fogOfTrick_3 = _("敌方突袭成功后无法获得侦查情报，也无法抢到银币（仅对玩家本人有效，对协防玩家无效）持续")..buff.fogOfTrick_3.effect.._("天"),
    woodBonus_1 = _("木材产量提升50%，持续")..buff.woodBonus_1.effect.._("小时"),
    woodBonus_2 = _("木材产量提升50%，持续")..buff.woodBonus_2.effect.._("小时"),
    woodBonus_3 = _("木材产量提升50%，持续")..buff.woodBonus_3.effect.._("小时"),
    stoneBonus_1 = _("石料产量提升50%，持续")..buff.stoneBonus_1.effect.._("小时"),
    stoneBonus_2 = _("石料产量提升50%，持续")..buff.stoneBonus_2.effect.._("小时"),
    stoneBonus_3 = _("石料产量提升50%，持续")..buff.stoneBonus_3.effect.._("小时"),
    ironBonus_1 = _("铁矿产量提升50%，持续")..buff.ironBonus_1.effect.._("小时"),
    ironBonus_2 = _("铁矿产量提升50%，持续")..buff.ironBonus_2.effect.._("小时"),
    ironBonus_3 = _("铁矿产量提升50%，持续")..buff.ironBonus_3.effect.._("小时"),
    foodBonus_1 = _("粮食产量提升50%，持续")..buff.foodBonus_1.effect.._("小时"),
    foodBonus_2 = _("粮食产量提升50%，持续")..buff.foodBonus_2.effect.._("小时"),
    foodBonus_3 = _("粮食产量提升50%，持续")..buff.foodBonus_3.effect.._("小时"),
    coinBonus_1 = _("银币产量提升50%，持续")..buff.coinBonus_1.effect.._("小时"),
    coinBonus_2 = _("银币产量提升50%，持续")..buff.coinBonus_2.effect.._("小时"),
    coinBonus_3 = _("银币产量提升50%，持续")..buff.coinBonus_3.effect.._("小时"),
    citizenBonus_1 = _("增加城民增长速度50%，持续")..buff.citizenBonus_1.effect.._("小时"),
    citizenBonus_2 = _("增加城民增长速度50%，持续")..buff.citizenBonus_2.effect.._("小时"),
    citizenBonus_3 = _("增加城民增长速度50%，持续")..buff.citizenBonus_3.effect.._("小时"),
    dragonExpBonus_1 = _("提升龙在战斗中获得的经验值30%，持续")..buff.dragonExpBonus_1.effect.._("小时"),
    dragonExpBonus_2 = _("提升龙在战斗中获得的经验值30%，持续")..buff.dragonExpBonus_2.effect.._("小时"),
    dragonExpBonus_3 = _("提升龙在战斗中获得的经验值30%，持续")..buff.dragonExpBonus_3.effect.._("小时"),
    troopSizeBonus_1 = _("提升龙的基础带兵量30%，持续")..buff.troopSizeBonus_1.effect.._("小时"),
    troopSizeBonus_2 = _("提升龙的基础带兵量30%，持续")..buff.troopSizeBonus_2.effect.._("小时"),
    troopSizeBonus_3 = _("提升龙的基础带兵量30%，持续5天")..buff.troopSizeBonus_3.effect.._("小时"),
    dragonHpBonus_1 = _("提升所有龙的生命值恢复速度30%，持续")..buff.dragonHpBonus_1.effect.._("小时"),
    dragonHpBonus_2 = _("提升所有龙的生命值恢复速度30%，持续")..buff.dragonHpBonus_2.effect.._("小时"),
    dragonHpBonus_3 = _("提升所有龙的生命值恢复速度30%，持续")..buff.dragonHpBonus_3.effect.._("小时"),
    marchSpeedBonus_1 = _("提升所有兵种的行军速度30%，持续")..buff.marchSpeedBonus_1.effect.._("小时"),
    marchSpeedBonus_2 = _("提升所有兵种的行军速度30%，持续")..buff.marchSpeedBonus_2.effect.._("小时"),
    marchSpeedBonus_3 = _("提升所有兵种的行军速度30%，持续")..buff.marchSpeedBonus_3.effect.._("小时"),
    unitHpBonus_1 = _("提升所有兵种的生命值30%，持续")..buff.unitHpBonus_1.effect.._("小时"),
    unitHpBonus_2 = _("提升所有兵种的生命值30%，持续")..buff.unitHpBonus_2.effect.._("小时"),
    unitHpBonus_3 = _("提升所有兵种的生命值30%，持续")..buff.unitHpBonus_3.effect.._("小时"),
    infantryAtkBonus_1 = _("提升所有步兵的攻击30%，持续")..buff.infantryAtkBonus_1.effect.._("小时"),
    infantryAtkBonus_2 = _("提升所有步兵的攻击30%，持续")..buff.infantryAtkBonus_2.effect.._("小时"),
    infantryAtkBonus_3 = _("提升所有步兵的攻击30%，持续")..buff.infantryAtkBonus_3.effect.._("小时"),
    archerAtkBonus_1 = _("提升所有弓手的攻击30%，持续")..buff.archerAtkBonus_1.effect.._("小时"),
    archerAtkBonus_2 = _("提升所有弓手的攻击30%，持续")..buff.archerAtkBonus_2.effect.._("小时"),
    archerAtkBonus_3 = _("提升所有弓手的攻击30%，持续")..buff.archerAtkBonus_3.effect.._("小时"),
    cavalryAtkBonus_1 = _("提升所有骑兵的攻击30%，持续")..buff.cavalryAtkBonus_1.effect.._("小时"),
    cavalryAtkBonus_2 = _("提升所有骑兵的攻击30%，持续")..buff.cavalryAtkBonus_2.effect.._("小时"),
    cavalryAtkBonus_3 = _("提升所有骑兵的攻击30%，持续")..buff.cavalryAtkBonus_3.effect.._("小时"),
    siegeAtkBonus_1 = _("提升所有攻城器械的攻击30%，持续")..buff.siegeAtkBonus_1.effect.._("小时"),
    siegeAtkBonus_2 = _("提升所有攻城器械的攻击30%，持续")..buff.siegeAtkBonus_2.effect.._("小时"),
    siegeAtkBonus_3 = _("提升所有攻城器械的攻击30%，持续")..buff.siegeAtkBonus_3.effect.._("小时"),

     -- resource
    woodClass_1 = resource.woodClass_1.effect.."K".._("木材"),
    woodClass_2 = resource.woodClass_2.effect.."K".._("木材"),
    woodClass_3 = resource.woodClass_3.effect.."K".._("木材"),
    woodClass_4 = resource.woodClass_4.effect.."K".._("木材"),
    woodClass_5 = resource.woodClass_5.effect.."K".._("木材"),
    woodClass_6 = resource.woodClass_6.effect.."K".._("木材"),
    woodClass_7 = resource.woodClass_7.effect.._("木材"),
    stoneClass_1 = resource.stoneClass_1.effect.."K".._("石料"),
    stoneClass_2 = resource.stoneClass_2.effect.."K".._("石料"),
    stoneClass_3 = resource.stoneClass_3.effect.."K".._("石料"),
    stoneClass_4 = resource.stoneClass_4.effect.."K".._("石料"),
    stoneClass_5 = resource.stoneClass_5.effect.."K".._("石料"),
    stoneClass_6 = resource.stoneClass_6.effect.."K".._("石料"),
    stoneClass_7 = resource.stoneClass_7.effect.."K".._("石料"),
    ironClass_1 = resource.ironClass_1.effect.."K".._("铁矿"),
    ironClass_2 = resource.ironClass_2.effect.."K".._("铁矿"),
    ironClass_3 = resource.ironClass_3.effect.."K".._("铁矿"),
    ironClass_4 = resource.ironClass_4.effect.."K".._("铁矿"),
    ironClass_5 = resource.ironClass_5.effect.."K".._("铁矿"),
    ironClass_6 = resource.ironClass_6.effect.."K".._("铁矿"),
    ironClass_7 = resource.ironClass_7.effect.."K".._("铁矿"),
    foodClass_1 = resource.foodClass_1.effect.."K".._("粮食"),
    foodClass_2 = resource.foodClass_2.effect.."K".._("粮食"),
    foodClass_3 = resource.foodClass_3.effect.."K".._("粮食"),
    foodClass_4 = resource.foodClass_4.effect.."K".._("粮食"),
    foodClass_5 = resource.foodClass_5.effect.."K".._("粮食"),
    foodClass_6 = resource.foodClass_6.effect.."K".._("粮食"),
    foodClass_7 = resource.foodClass_7.effect.."K".._("粮食"),
    coinClass_1 = resource.coinClass_1.effect.."K".._("银币"),
    coinClass_2 = resource.coinClass_2.effect.."K".._("银币"),
    coinClass_3 = resource.coinClass_3.effect.."K".._("银币"),
    coinClass_4 = resource.coinClass_4.effect.."K".._("银币"),
    coinClass_5 = resource.coinClass_5.effect.."K".._("银币"),
    coinClass_6 = resource.coinClass_6.effect.."K".._("银币"),
    coinClass_7 = resource.coinClass_7.effect.."K".._("银币"),
    citizenClass_1 = string.format(_("使用后立即回复%d%%空闲城民"),(resource.citizenClass_1.effect*100)),
    citizenClass_2 = string.format(_("使用后立即回复%d%%空闲城民"),(resource.citizenClass_2.effect*100)),
    citizenClass_3 = string.format(_("使用后立即回复%d%%空闲城民"),(resource.citizenClass_3.effect*100)),
    casinoTokenClass_1 = resource.casinoTokenClass_1.effect.."K".._("赌场筹码"),
    casinoTokenClass_2 = resource.casinoTokenClass_2.effect.."K".._("赌场筹码"),
    casinoTokenClass_3 = resource.casinoTokenClass_3.effect.."K".._("赌场筹码"),
    casinoTokenClass_4 = resource.casinoTokenClass_4.effect.."K".._("赌场筹码"),

    -- special
    movingConstruction = _("用来调换城市内的资源建筑或装饰建筑的位置"),
    torch = _("立即摧毁一座建筑"),
    changePlayerName = _("使用该道具更改你的玩家名称"),
    changeCityName = _("使用该道具更改你获得敌方的城市名称"),
    retreatTroop = _("召唤一支出征在外的部队返回城市"),
    moveTheCity = _("允许玩家将自己的城市移动到联盟领地的指定坐标"),
    dragonExp_1 = _("立即增加").._("龙的经验值")..tonumber(special.dragonExp_1.effect),
    dragonExp_2 = _("立即增加").._("龙的经验值")..tonumber(special.dragonExp_2.effect),
    dragonExp_3 = _("立即增加").._("龙的经验值")..tonumber(special.dragonExp_3.effect),
    dragonHp_1 = string.format(_("选择一条空闲或驻防的龙，立即恢复%d点龙的生命值"),tonumber(special.dragonHp_1.effect)),
    dragonHp_2 = string.format(_("选择一条空闲或驻防的龙，立即恢复%d点龙的生命值"),tonumber(special.dragonHp_2.effect)),
    dragonHp_3 = string.format(_("选择一条空闲或驻防的龙，立即恢复%d点龙的生命值"),tonumber(special.dragonHp_3.effect)),
    heroBlood_1 = string.format(_("升级龙技能必须的材料，使用后里获得获得%d英雄之血"),tonumber(special.heroBlood_1.effect)),
    heroBlood_2 = string.format(_("升级龙技能必须的材料，使用后里获得获得%d英雄之血"),tonumber(special.heroBlood_2.effect)),
    heroBlood_3 = string.format(_("升级龙技能必须的材料，使用后里获得获得%d英雄之血"),tonumber(special.heroBlood_3.effect)),
    stamina_1 = _("补足玩家探索地图所需的体力药剂"),
    stamina_2 = _("补足玩家探索地图所需的体力药剂"),
    stamina_3 = _("补足玩家探索地图所需的体力药剂"),
    restoreWall_1 = string.format(_("使用后，立即为城墙恢复%d点生命值"),tonumber(special.restoreWall_1.effect)),
    restoreWall_2 = string.format(_("使用后，立即为城墙恢复%d点生命值"),tonumber(special.restoreWall_2.effect)),
    restoreWall_3 = string.format(_("使用后，立即为城墙恢复%d点生命值"),tonumber(special.restoreWall_3.effect)),
    dragonChest_1 = _("1~2星龙的装备所需材料，打开后按照奖励列表抽取3次"),
    dragonChest_2 = _("2~3星龙的装备所需材料，打开后按照奖励列表抽取3次"),
    dragonChest_3 = _("3~4星龙的装备所需材料，打开后按照奖励列表抽取3次"),
    chest_1 = _("装有其他道具的箱子，可以直接打开，随机获得一种道具（可多个）"),
    chest_2 = _("装有其他道具的箱子，随机获得一种道具（可多个），需要铜钥匙才能打开"),
    chest_3 = _("装有其他道具的箱子，随机获得一种道具（可多个），需要银钥匙才能打开"),
    chest_4 = _("装有其他道具的箱子，随机获得一种道具（可多个），需要金钥匙才能打开"),
    chestKey_2 = _("用来打开铜宝箱的钥匙"),
    chestKey_3 = _("用来打开银宝箱的钥匙"),
    chestKey_4 = _("用来打开金宝箱的钥匙"),
    vipActive_1 = string.format(_("激活你当前的VIP等级特权，效果持续%s"),formatMin(special.vipActive_1.effect)),
    vipActive_2 = string.format(_("激活你当前的VIP等级特权，效果持续%s"),formatMin(special.vipActive_2.effect)),
    vipActive_3 = string.format(_("激活你当前的VIP等级特权，效果持续%s"),formatMin(special.vipActive_3.effect)),
    vipActive_4 = string.format(_("激活你当前的VIP等级特权，效果持续%s"),formatMin(special.vipActive_4.effect)),
    vipActive_5 = string.format(_("激活你当前的VIP等级特权，效果持续%s"),formatMin(special.vipActive_5.effect)),
    vipPoint_1 = string.format(_("增加%dVIP点数，以提高你的VIP等级"),tonumber(special.vipPoint_1.effect)),
    vipPoint_2 = string.format(_("增加%dVIP点数，以提高你的VIP等级"),tonumber(special.vipPoint_2.effect)),
    vipPoint_3 = string.format(_("增加%dVIP点数，以提高你的VIP等级"),tonumber(special.vipPoint_3.effect)),
    vipPoint_4 = string.format(_("增加%dVIP点数，以提高你的VIP等级"),tonumber(special.vipPoint_4.effect)),

    -- speedup
    speedup_1 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_1.effect),
    speedup_2 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_2.effect),
    speedup_3 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_3.effect),
    speedup_4 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_4.effect),
    speedup_5 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_5.effect),
    speedup_6 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_6.effect),
    speedup_7 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_7.effect),
    speedup_8 = _("将当前事件的剩余时间缩短")..formatMin(speedup.speedup_8.effect),
    warSpeedupClass_1 = string.format(_("立即减少%d%%的行军时间"),(speedup.warSpeedupClass_1.effect*100)) ,
    warSpeedupClass_2 = string.format(_("立即减少%d%%的行军时间"),(speedup.warSpeedupClass_2.effect*100)),
}


return {
    item_name = ITEM_NAME,
    item_desc = ITEM_DESC,
    item_category_name = ITEM_CATEGORY_NAME
}



