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
    masterOfDefender_1 = string.format(_("%d小时城防大师"),buff.masterOfDefender_1.effect),
    masterOfDefender_2 = string.format(_("%d小时城防大师"),buff.masterOfDefender_2.effect),
    masterOfDefender_3 = string.format(_("%d小时城防大师"),buff.masterOfDefender_3.effect),
    quarterMaster_1 = string.format(_("%d小时军需官"),buff.quarterMaster_1.effect),
    quarterMaster_2 = string.format(_("%d小时军需官"),buff.quarterMaster_2.effect),
    quarterMaster_3 = string.format(_("%d小时军需官"),buff.quarterMaster_3.effect),
    fogOfTrick_1 = string.format(_("%d小时诡计之雾"),buff.fogOfTrick_1.effect),
    fogOfTrick_2 = string.format(_("%d小时诡计之雾"),buff.fogOfTrick_2.effect),
    fogOfTrick_3 = string.format(_("%d小时诡计之雾"),buff.fogOfTrick_3.effect),
    woodBonus_1 = string.format(_("%d小时木材生产加成"),buff.woodBonus_1.effect),
    woodBonus_2 = string.format(_("%d小时木材生产加成"),buff.woodBonus_2.effect),
    woodBonus_3 = string.format(_("%d小时木材生产加成"),buff.woodBonus_3.effect),
    stoneBonus_1 = string.format(_("%d小时石料生产加成"),buff.stoneBonus_1.effect),
    stoneBonus_2 = string.format(_("%d小时石料生产加成"),buff.stoneBonus_2.effect),
    stoneBonus_3 = string.format(_("%d小时石料生产加成"),buff.stoneBonus_3.effect),
    ironBonus_1 = string.format(_("%d小时铁矿生产加成"),buff.ironBonus_1.effect),
    ironBonus_2 = string.format(_("%d小时铁矿生产加成"),buff.ironBonus_2.effect),
    ironBonus_3 = string.format(_("%d小时铁矿生产加成"),buff.ironBonus_3.effect),
    foodBonus_1 = string.format(_("%d小时粮食生产加成"),buff.foodBonus_1.effect),
    foodBonus_2 = string.format(_("%d小时粮食生产加成"),buff.foodBonus_2.effect),
    foodBonus_3 = string.format(_("%d小时粮食生产加成"),buff.foodBonus_3.effect),
    coinBonus_1 = string.format(_("%d小时银币生产加成"),buff.coinBonus_1.effect),
    coinBonus_2 = string.format(_("%d小时银币生产加成"),buff.coinBonus_2.effect),
    coinBonus_3 = string.format(_("%d小时银币生产加成"),buff.coinBonus_3.effect),
    citizenBonus_1 = string.format(_("%d小时城民增长加成"),buff.citizenBonus_1.effect),
    citizenBonus_2 = string.format(_("%d小时城民增长加成"),buff.citizenBonus_2.effect),
    citizenBonus_3 = string.format(_("%d小时城民增长加成"),buff.citizenBonus_3.effect),
    dragonExpBonus_1 = string.format(_("%d小时龙语卷轴"),buff.dragonExpBonus_1.effect),
    dragonExpBonus_2 = string.format(_("%d小时龙语卷轴"),buff.dragonExpBonus_2.effect),
    dragonExpBonus_3 = string.format(_("%d小时龙语卷轴"),buff.dragonExpBonus_3.effect),
    troopSizeBonus_1 = string.format(_("%d小时战争号角"),buff.troopSizeBonus_1.effect),
    troopSizeBonus_2 = string.format(_("%d小时战争号角"),buff.troopSizeBonus_2.effect),
    troopSizeBonus_3 = string.format(_("%d小时战争号角"),buff.troopSizeBonus_3.effect),
    dragonHpBonus_1 = string.format(_("%d小时龙族纹章"),buff.dragonHpBonus_1.effect),
    dragonHpBonus_2 = string.format(_("%d小时龙族纹章"),buff.dragonHpBonus_2.effect),
    dragonHpBonus_3 = string.format(_("%d小时龙族纹章"),buff.dragonHpBonus_3.effect),
    marchSpeedBonus_1 = string.format(_("%d小时行军加速"),buff.marchSpeedBonus_1.effect),
    marchSpeedBonus_2 = string.format(_("%d小时行军加速"),buff.marchSpeedBonus_2.effect),
    marchSpeedBonus_3 = string.format(_("%d小时行军加速"),buff.marchSpeedBonus_3.effect),
    unitHpBonus_1 = string.format(_("%d小时防御加成"),buff.unitHpBonus_1.effect),
    unitHpBonus_2 = string.format(_("%d小时防御加成"),buff.unitHpBonus_2.effect),
    unitHpBonus_3 = string.format(_("%d小时防御加成"),buff.unitHpBonus_3.effect),
    infantryAtkBonus_1 = string.format(_("%d小时步兵攻击加成"),buff.infantryAtkBonus_1.effect),
    infantryAtkBonus_2 = string.format(_("%d小时步兵攻击加成"),buff.infantryAtkBonus_2.effect),
    infantryAtkBonus_3 = string.format(_("%d小时步兵攻击加成"),buff.infantryAtkBonus_3.effect),
    archerAtkBonus_1 = string.format(_("%d小时弓手攻击加成"),buff.archerAtkBonus_1.effect),
    archerAtkBonus_2 = string.format(_("%d小时弓手攻击加成"),buff.archerAtkBonus_2.effect),
    archerAtkBonus_3 = string.format(_("%d小时弓手攻击加成"),buff.archerAtkBonus_3.effect),
    cavalryAtkBonus_1 = string.format(_("%d小时骑兵攻击加成"),buff.cavalryAtkBonus_1.effect),
    cavalryAtkBonus_2 = string.format(_("%d小时骑兵攻击加成"),buff.cavalryAtkBonus_2.effect),
    cavalryAtkBonus_3 = string.format(_("%d小时骑兵攻击加成"),buff.cavalryAtkBonus_3.effect),
    siegeAtkBonus_1 = string.format(_("%d小时攻城机械攻击加成"),buff.siegeAtkBonus_1.effect),
    siegeAtkBonus_2 = string.format(_("%d小时攻城机械攻击加成"),buff.siegeAtkBonus_2.effect),
    siegeAtkBonus_3 = string.format(_("%d小时攻城机械攻击加成"),buff.siegeAtkBonus_3.effect),

    -- resource
    woodClass_1 = string.format(_("%dK木材"),resource.woodClass_1.effect),
    woodClass_2 = string.format(_("%dK木材"),resource.woodClass_2.effect),
    woodClass_3 = string.format(_("%dK木材"),resource.woodClass_3.effect),
    woodClass_4 = string.format(_("%dK木材"),resource.woodClass_4.effect),
    woodClass_5 = string.format(_("%dK木材"),resource.woodClass_5.effect),
    woodClass_6 = string.format(_("%dK木材"),resource.woodClass_6.effect),
    woodClass_7 = string.format(_("%dK木材"),resource.woodClass_7.effect),
    stoneClass_1 = string.format(_("%dK石料"),resource.stoneClass_1.effect),
    stoneClass_2 = string.format(_("%dK石料"),resource.stoneClass_2.effect),
    stoneClass_3 = string.format(_("%dK石料"),resource.stoneClass_3.effect),
    stoneClass_4 = string.format(_("%dK石料"),resource.stoneClass_4.effect),
    stoneClass_5 = string.format(_("%dK石料"),resource.stoneClass_5.effect),
    stoneClass_6 = string.format(_("%dK石料"),resource.stoneClass_6.effect),
    stoneClass_7 = string.format(_("%dK石料"),resource.stoneClass_7.effect),
    ironClass_1 = string.format(_("%dK铁矿"),resource.ironClass_1.effect),
    ironClass_2 = string.format(_("%dK铁矿"),resource.ironClass_2.effect),
    ironClass_3 = string.format(_("%dK铁矿"),resource.ironClass_3.effect),
    ironClass_4 = string.format(_("%dK铁矿"),resource.ironClass_4.effect),
    ironClass_5 = string.format(_("%dK铁矿"),resource.ironClass_5.effect),
    ironClass_6 = string.format(_("%dK铁矿"),resource.ironClass_6.effect),
    ironClass_7 = string.format(_("%dK铁矿"),resource.ironClass_7.effect),
    foodClass_1 = string.format(_("%dK粮食"),resource.foodClass_1.effect),
    foodClass_2 = string.format(_("%dK粮食"),resource.foodClass_2.effect),
    foodClass_3 = string.format(_("%dK粮食"),resource.foodClass_3.effect),
    foodClass_4 = string.format(_("%dK粮食"),resource.foodClass_4.effect),
    foodClass_5 = string.format(_("%dK粮食"),resource.foodClass_5.effect),
    foodClass_6 = string.format(_("%dK粮食"),resource.foodClass_6.effect),
    foodClass_7 = string.format(_("%dK粮食"),resource.foodClass_7.effect),
    coinClass_1 = string.format(_("%dK银币"),resource.coinClass_1.effect),
    coinClass_2 = string.format(_("%dK银币"),resource.coinClass_2.effect),
    coinClass_3 = string.format(_("%dK银币"),resource.coinClass_3.effect),
    coinClass_4 = string.format(_("%dK银币"),resource.coinClass_4.effect),
    coinClass_5 = string.format(_("%dK银币"),resource.coinClass_5.effect),
    coinClass_6 = string.format(_("%dK银币"),resource.coinClass_6.effect),
    coinClass_7 = string.format(_("%dK银币"),resource.coinClass_7.effect),
    gemClass_1 = string.format(_("%d金龙币"),resource.gemClass_1.effect),
    gemClass_2 = string.format(_("%d金龙币"),resource.gemClass_2.effect),
    gemClass_3 = string.format(_("%d金龙币"),resource.gemClass_3.effect),
    citizenClass_1 = string.format(_("%d%%空闲城民"),resource.citizenClass_1.effect * 100),
    citizenClass_2 = string.format(_("%d%%空闲城民"),resource.citizenClass_2.effect * 100),
    citizenClass_3 = string.format(_("%d%%空闲城民"),resource.citizenClass_3.effect * 100),
    casinoTokenClass_1 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_1.effect),
    casinoTokenClass_2 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_2.effect),
    casinoTokenClass_3 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_3.effect),
    casinoTokenClass_4 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_4.effect),
    casinoTokenClass_5 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_5.effect),

    -- special
    movingConstruction = _("建筑移动"),
    torch = _("火炬"),
    changePlayerName = _("玩家改名卡"),
    changeCityName = _("城市改名卡"),
    retreatTroop = _("撤军令"),
    moveTheCity = _("城市移动"),
    dragonExp_1 = string.format(_("%d龙经验值"),tonumber(special.dragonExp_1.effect)),
    dragonExp_2 = string.format(_("%d龙经验值"),tonumber(special.dragonExp_2.effect)),
    dragonExp_3 = string.format(_("%d龙经验值"),tonumber(special.dragonExp_3.effect)),
    dragonHp_1 = string.format(_("%d点龙的生命值"),tonumber(special.dragonHp_1.effect)),
    dragonHp_2 = string.format(_("%d点龙的生命值"),tonumber(special.dragonHp_2.effect)),
    dragonHp_3 = string.format(_("%d点龙的生命值"),tonumber(special.dragonHp_3.effect)),
    heroBlood_1 = string.format(_("%d英雄之血"),tonumber(special.heroBlood_1.effect)),
    heroBlood_2 = string.format(_("%d英雄之血"),tonumber(special.heroBlood_2.effect)),
    heroBlood_3 = string.format(_("%d英雄之血"),tonumber(special.heroBlood_3.effect)),
    stamina_1 = _("体力药剂(小)"),
    stamina_2 = _("体力药剂(中)"),
    stamina_3 = _("体力药剂(大)"),
    restoreWall_1 =  string.format(_("%d点城墙的生命值"),tonumber(special.restoreWall_1.effect)),
    restoreWall_2 =  string.format(_("%d点城墙的生命值"),tonumber(special.restoreWall_2.effect)),
    restoreWall_3 =  string.format(_("%d点城墙的生命值"),tonumber(special.restoreWall_3.effect)),
    dragonChest_1 = _("初级巨龙宝箱"),
    dragonChest_2 = _("中级巨龙宝箱"),
    dragonChest_3 = _("高级巨龙宝箱"),
    chest_1 = _("木宝箱"),
    chest_2 = _("铜宝箱"),
    chest_3 = _("银宝箱"),
    chest_4 = _("金宝箱"),
    chestKey_2 = _("铜钥匙"),
    chestKey_3 = _("银钥匙"),
    chestKey_4 = _("金钥匙"),
    vipActive_1 = string.format(_("VIP激活%s"),formatMin(special.vipActive_1.effect)),
    vipActive_2 = string.format(_("VIP激活%s"),formatMin(special.vipActive_2.effect)),
    vipActive_3 = string.format(_("VIP激活%s"),formatMin(special.vipActive_3.effect)),
    vipActive_4 = string.format(_("VIP激活%s"),formatMin(special.vipActive_4.effect)),
    vipActive_5 = string.format(_("VIP激活%s"),formatMin(special.vipActive_5.effect)),
    vipPoint_1 = string.format(_("%dVIP点数"),tonumber(special.vipPoint_1.effect)),
    vipPoint_2 = string.format(_("%dVIP点数"),tonumber(special.vipPoint_2.effect)),
    vipPoint_3 = string.format(_("%dVIP点数"),tonumber(special.vipPoint_3.effect)),
    vipPoint_4 = string.format(_("%dVIP点数"),tonumber(special.vipPoint_4.effect)),

    -- speedup
    speedup_1 = string.format(_("%s加速"),formatMin(speedup.speedup_1.effect)),
    speedup_2 = string.format(_("%s加速"),formatMin(speedup.speedup_2.effect)),
    speedup_3 = string.format(_("%s加速"),formatMin(speedup.speedup_3.effect)),
    speedup_4 = string.format(_("%s加速"),formatMin(speedup.speedup_4.effect)),
    speedup_5 = string.format(_("%s加速"),formatMin(speedup.speedup_5.effect)),
    speedup_6 = string.format(_("%s加速"),formatMin(speedup.speedup_6.effect)),
    speedup_7 = string.format(_("%s加速"),formatMin(speedup.speedup_7.effect)),
    speedup_8 = string.format(_("%s加速"),formatMin(speedup.speedup_8.effect)),
    warSpeedupClass_1 = _("普通战争沙漏"),
    warSpeedupClass_2 = _("强化战争沙漏"),
}

local ITEM_DESC= {
    -- buff
    masterOfDefender_1 = string.format(_("战败时无法被掠夺资源，但城墙会受到攻击。同时防御时的战损下降20%%，持续%d小时"),buff.masterOfDefender_1.effect),
    masterOfDefender_2 = string.format(_("战败时无法被掠夺资源，但城墙会受到攻击。同时防御时的战损下降20%%，持续%d小时"),buff.masterOfDefender_2.effect),
    masterOfDefender_3 = string.format(_("战败时无法被掠夺资源，但城墙会受到攻击。同时防御时的战损下降20%%，持续%d小时"),buff.masterOfDefender_3.effect),
    quarterMaster_1 = string.format(_("减少25%%的维护费用，持续%d小时"),buff.quarterMaster_1.effect),
    quarterMaster_2 = string.format(_("减少25%%的维护费用，持续%d小时"),buff.quarterMaster_2.effect),
    quarterMaster_3 = string.format(_("减少25%%的维护费用，持续%d小时"),buff.quarterMaster_3.effect),
    fogOfTrick_1 = string.format(_("敌方突袭成功后无法获得侦查情报，也无法抢到银币（仅对玩家本人有效，对协防玩家无效）持续%d小时"),buff.fogOfTrick_1.effect),
    fogOfTrick_2 = string.format(_("敌方突袭成功后无法获得侦查情报，也无法抢到银币（仅对玩家本人有效，对协防玩家无效）持续%d小时"),buff.fogOfTrick_2.effect),
    fogOfTrick_3 = string.format(_("敌方突袭成功后无法获得侦查情报，也无法抢到银币（仅对玩家本人有效，对协防玩家无效）持续%d小时"),buff.fogOfTrick_3.effect),
    woodBonus_1 = string.format(_("木材产量提升50%%，持续%d小时"),buff.woodBonus_1.effect),
    woodBonus_2 = string.format(_("木材产量提升50%%，持续%d小时"),buff.woodBonus_2.effect),
    woodBonus_3 = string.format(_("木材产量提升50%%，持续%d小时"),buff.woodBonus_3.effect),
    stoneBonus_1 = string.format(_("石料产量提升50%%，持续%d小时"),buff.stoneBonus_1.effect),
    stoneBonus_2 = string.format(_("石料产量提升50%%，持续%d小时"),buff.stoneBonus_2.effect),
    stoneBonus_3 = string.format(_("石料产量提升50%%，持续%d小时"),buff.stoneBonus_3.effect),
    ironBonus_1 = string.format(_("铁矿产量提升50%%，持续%d小时"),buff.ironBonus_1.effect),
    ironBonus_2 = string.format(_("铁矿产量提升50%%，持续%d小时"),buff.ironBonus_2.effect),
    ironBonus_3 = string.format(_("铁矿产量提升50%%，持续%d小时"),buff.ironBonus_3.effect),
    foodBonus_1 = string.format(_("粮食产量提升50%%，持续%d小时"),buff.foodBonus_1.effect),
    foodBonus_2 = string.format(_("粮食产量提升50%%，持续%d小时"),buff.foodBonus_2.effect),
    foodBonus_3 = string.format(_("粮食产量提升50%%，持续%d小时"),buff.foodBonus_3.effect),
    coinBonus_1 = string.format(_("银币产量提升50%%，持续%d小时"),buff.coinBonus_1.effect),
    coinBonus_2 = string.format(_("银币产量提升50%%，持续%d小时"),buff.coinBonus_2.effect),
    coinBonus_3 = string.format(_("银币产量提升50%%，持续%d小时"),buff.coinBonus_3.effect),
    citizenBonus_1 = string.format(_("增加城民增长速度50%%，持续%d小时"),buff.citizenBonus_1.effect),
    citizenBonus_2 = string.format(_("增加城民增长速度50%%，持续%d小时"),buff.citizenBonus_2.effect),
    citizenBonus_3 = string.format(_("增加城民增长速度50%%，持续%d小时"),buff.citizenBonus_3.effect),
    dragonExpBonus_1 = string.format(_("提升龙在战斗中获得的经验值30%%，持续%d小时"),buff.dragonExpBonus_1.effect),
    dragonExpBonus_2 = string.format(_("提升龙在战斗中获得的经验值30%%，持续%d小时"),buff.dragonExpBonus_2.effect),
    dragonExpBonus_3 = string.format(_("提升龙在战斗中获得的经验值30%%，持续%d小时"),buff.dragonExpBonus_3.effect),
    troopSizeBonus_1 = string.format(_("提升龙的基础带兵量30%%，持续%d小时"),buff.troopSizeBonus_1.effect),
    troopSizeBonus_2 = string.format(_("提升龙的基础带兵量30%%，持续%d小时"),buff.troopSizeBonus_2.effect),
    troopSizeBonus_3 = string.format(_("提升龙的基础带兵量30%%，持续%d小时"),buff.troopSizeBonus_3.effect),
    dragonHpBonus_1 = string.format(_("提升所有龙的生命值恢复速度30%%，持续%d小时"),buff.dragonHpBonus_1.effect),
    dragonHpBonus_2 = string.format(_("提升所有龙的生命值恢复速度30%%，持续%d小时"),buff.dragonHpBonus_2.effect),
    dragonHpBonus_3 = string.format(_("提升所有龙的生命值恢复速度30%%，持续%d小时"),buff.dragonHpBonus_3.effect),
    marchSpeedBonus_1 = string.format(_("提升所有兵种的行军速度30%%，持续%d小时"),buff.marchSpeedBonus_1.effect),
    marchSpeedBonus_2 = string.format(_("提升所有兵种的行军速度30%%，持续%d小时"),buff.marchSpeedBonus_2.effect),
    marchSpeedBonus_3 = string.format(_("提升所有兵种的行军速度30%%，持续%d小时"),buff.marchSpeedBonus_3.effect),
    unitHpBonus_1 = string.format(_("提升所有兵种的生命值30%%，持续%d小时"),buff.unitHpBonus_1.effect),
    unitHpBonus_2 = string.format(_("提升所有兵种的生命值30%%，持续%d小时"),buff.unitHpBonus_2.effect),
    unitHpBonus_3 = string.format(_("提升所有兵种的生命值30%%，持续%d小时"),buff.unitHpBonus_3.effect),
    infantryAtkBonus_1 = string.format(_("提升所有步兵的攻击30%%，持续%d小时"),buff.infantryAtkBonus_1.effect),
    infantryAtkBonus_2 = string.format(_("提升所有步兵的攻击30%%，持续%d小时"),buff.infantryAtkBonus_2.effect),
    infantryAtkBonus_3 = string.format(_("提升所有步兵的攻击30%%，持续%d小时"),buff.infantryAtkBonus_3.effect),
    archerAtkBonus_1 = string.format(_("提升所有弓手的攻击30%%，持续%d小时"),buff.archerAtkBonus_1.effect),
    archerAtkBonus_2 = string.format(_("提升所有弓手的攻击30%%，持续%d小时"),buff.archerAtkBonus_2.effect),
    archerAtkBonus_3 = string.format(_("提升所有弓手的攻击30%%，持续%d小时"),buff.archerAtkBonus_3.effect),
    cavalryAtkBonus_1 = string.format(_("提升所有骑兵的攻击30%%，持续%d小时"),buff.cavalryAtkBonus_1.effect),
    cavalryAtkBonus_2 = string.format(_("提升所有骑兵的攻击30%%，持续%d小时"),buff.cavalryAtkBonus_2.effect),
    cavalryAtkBonus_3 = string.format(_("提升所有骑兵的攻击30%%，持续%d小时"),buff.cavalryAtkBonus_3.effect),
    siegeAtkBonus_1 = string.format(_("提升所有攻城器械的攻击30%%，持续%d小时"),buff.siegeAtkBonus_1.effect),
    siegeAtkBonus_2 = string.format(_("提升所有攻城器械的攻击30%%，持续%d小时"),buff.siegeAtkBonus_2.effect),
    siegeAtkBonus_3 = string.format(_("提升所有攻城器械的攻击30%%，持续%d小时"),buff.siegeAtkBonus_3.effect),

    -- resource
    woodClass_1 = string.format(_("%dK木材"),resource.woodClass_1.effect),
    woodClass_2 = string.format(_("%dK木材"),resource.woodClass_2.effect),
    woodClass_3 = string.format(_("%dK木材"),resource.woodClass_3.effect),
    woodClass_4 = string.format(_("%dK木材"),resource.woodClass_4.effect),
    woodClass_5 = string.format(_("%dK木材"),resource.woodClass_5.effect),
    woodClass_6 = string.format(_("%dK木材"),resource.woodClass_6.effect),
    woodClass_7 = string.format(_("%dK木材"),resource.woodClass_7.effect),
    stoneClass_1 = string.format(_("%dK石料"),resource.stoneClass_1.effect),
    stoneClass_2 = string.format(_("%dK石料"),resource.stoneClass_2.effect),
    stoneClass_3 = string.format(_("%dK石料"),resource.stoneClass_3.effect),
    stoneClass_4 = string.format(_("%dK石料"),resource.stoneClass_4.effect),
    stoneClass_5 = string.format(_("%dK石料"),resource.stoneClass_5.effect),
    stoneClass_6 = string.format(_("%dK石料"),resource.stoneClass_6.effect),
    stoneClass_7 = string.format(_("%dK石料"),resource.stoneClass_7.effect),
    ironClass_1 = string.format(_("%dK铁矿"),resource.ironClass_1.effect),
    ironClass_2 = string.format(_("%dK铁矿"),resource.ironClass_2.effect),
    ironClass_3 = string.format(_("%dK铁矿"),resource.ironClass_3.effect),
    ironClass_4 = string.format(_("%dK铁矿"),resource.ironClass_4.effect),
    ironClass_5 = string.format(_("%dK铁矿"),resource.ironClass_5.effect),
    ironClass_6 = string.format(_("%dK铁矿"),resource.ironClass_6.effect),
    ironClass_7 = string.format(_("%dK铁矿"),resource.ironClass_7.effect),
    foodClass_1 = string.format(_("%dK粮食"),resource.foodClass_1.effect),
    foodClass_2 = string.format(_("%dK粮食"),resource.foodClass_2.effect),
    foodClass_3 = string.format(_("%dK粮食"),resource.foodClass_3.effect),
    foodClass_4 = string.format(_("%dK粮食"),resource.foodClass_4.effect),
    foodClass_5 = string.format(_("%dK粮食"),resource.foodClass_5.effect),
    foodClass_6 = string.format(_("%dK粮食"),resource.foodClass_6.effect),
    foodClass_7 = string.format(_("%dK粮食"),resource.foodClass_7.effect),
    coinClass_1 = string.format(_("%dK银币"),resource.coinClass_1.effect),
    coinClass_2 = string.format(_("%dK银币"),resource.coinClass_2.effect),
    coinClass_3 = string.format(_("%dK银币"),resource.coinClass_3.effect),
    coinClass_4 = string.format(_("%dK银币"),resource.coinClass_4.effect),
    coinClass_5 = string.format(_("%dK银币"),resource.coinClass_5.effect),
    coinClass_6 = string.format(_("%dK银币"),resource.coinClass_6.effect),
    coinClass_7 = string.format(_("%dK银币"),resource.coinClass_7.effect),
    gemClass_1 = string.format(_("%d金龙币"),resource.gemClass_1.effect),
    gemClass_2 = string.format(_("%d金龙币"),resource.gemClass_2.effect),
    gemClass_3 = string.format(_("%d金龙币"),resource.gemClass_3.effect),
    citizenClass_1 = string.format(_("使用后立即回复%d%%空闲城民"),resource.citizenClass_1.effect * 100),
    citizenClass_2 = string.format(_("使用后立即回复%d%%空闲城民"),resource.citizenClass_2.effect * 100),
    citizenClass_3 = string.format(_("使用后立即回复%d%%空闲城民"),resource.citizenClass_3.effect * 100),
    casinoTokenClass_1 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_1.effect),
    casinoTokenClass_2 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_2.effect),
    casinoTokenClass_3 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_3.effect),
    casinoTokenClass_4 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_4.effect),
    casinoTokenClass_5 = string.format(_("%dK赌场筹码"),resource.casinoTokenClass_5.effect),

    -- special
    movingConstruction = _("用来调换城市内的资源建筑或装饰建筑的位置"),
    torch = _("立即摧毁一座建筑"),
    changePlayerName = _("使用该道具更改你的玩家名称"),
    changeCityName = _("使用该道具更改你获得敌方的城市名称"),
    retreatTroop = _("召唤一支出征在外的部队返回城市"),
    moveTheCity = _("允许玩家将自己的城市移动到联盟领地的指定坐标"),
    dragonExp_1 = string.format(_("立即增加龙的经验值%d"),tonumber(special.dragonExp_1.effect)),
    dragonExp_2 = string.format(_("立即增加龙的经验值%d"),tonumber(special.dragonExp_2.effect)),
    dragonExp_3 = string.format(_("立即增加龙的经验值%d"),tonumber(special.dragonExp_3.effect)),
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
    speedup_1 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_1.effect)),
    speedup_2 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_2.effect)),
    speedup_3 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_3.effect)),
    speedup_4 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_4.effect)),
    speedup_5 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_5.effect)),
    speedup_6 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_6.effect)),
    speedup_7 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_7.effect)),
    speedup_8 = string.format(_("将当前事件的剩余时间缩短%s"),formatMin(speedup.speedup_8.effect)),
    warSpeedupClass_1 = string.format(_("立即减少%d%%的行军时间"),(speedup.warSpeedupClass_1.effect*100)) ,
    warSpeedupClass_2 = string.format(_("立即减少%d%%的行军时间"),(speedup.warSpeedupClass_2.effect*100)),
}


return {
    item_name = ITEM_NAME,
    item_desc = ITEM_DESC,
    item_category_name = ITEM_CATEGORY_NAME
}





