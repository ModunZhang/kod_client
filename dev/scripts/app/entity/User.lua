local Localize = import("..utils.Localize")
local property = import("..utils.property")
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local User = class("User", MultiObserver)


User.LISTEN_TYPE = Enum(
    "basicInfo",
    "countInfo",
    "resources",
    "deals",
    "vipEvents",
    "iapGifts",
    "growUpTasks",
    "allianceDonate",
    "dailyTasks",
    "dailyQuests",
    "dailyQuestEvents")

property(User, "id", 0)
property(User, "basicInfo", {})
property(User, "countInfo", {})
property(User, "iapGifts", {})
property(User, "deals", {})
property(User, "pve", {})
property(User, "pveFights", {})
property(User, "vipEvents", {})
property(User, "buildings", {})
property(User, "growUpTasks", {})
property(User, "allianceDonate", {})
property(User, "apnStatus", {})
property(User, "allianceInfo", {})
property(User, "dailyQuests", {})
property(User, "dailyQuestEvents", {})
property(User, "requestToAllianceEvents", {})
property(User, "inviteToAllianceEvents", {})


local intInit = GameDatas.PlayerInitData.intInit
function User:ctor(p)
    User.super.ctor(self)
    self.resources_cache = {
        stamina = {value = 0, limit = intInit.staminaMax.value, output = intInit.staminaRecoverPerHour.value}
    }
    if type(p) == "table" then
        self:SetId(p._id)
    else
        self:SetId(p)
    end
end
function User:ResetAllListeners()
    self:ClearAllListener()
end

--[[multiobserver override]]
function User:AddListenOnType(listener, listenerType)
    if type(listenerType) == "string" then
        listenerType = User.LISTEN_TYPE[listenerType]
    end
    User.super.AddListenOnType(self, listener, listenerType)
end
function User:RemoveListenerOnType(listener, listenerType)
    if type(listenerType) == "string" then
        listenerType = User.LISTEN_TYPE[listenerType]
    end
    User.super.RemoveListenerOnType(self, listener, listenerType)
end
--[[end]]

--[[pve相关方法 begin]]
local TOTAL_STAGES = 0
local tt = 0
local stages = GameDatas.PvE.stages
for k,v in pairs(stages) do
    tt = tt + 1
end
for i = 1, tt do
    if stages[string.format("%d_1", i)] then
        TOTAL_STAGES = TOTAL_STAGES + 1
    end
end

local sections = GameDatas.PvE.sections
local PVE_LENGTH = 0
local index = 1
while sections[string.format("1_%d", index)] do
    PVE_LENGTH = PVE_LENGTH + 1
    index = index + 1
end
function User:GetPveLeftCountByName(pve_name)
    return sections[pve_name].maxFightCount - self:GetFightCountByName(pve_name)
end
function User:GetFightCountByName(pve_name)
    for i,v in ipairs(self.pveFights) do
        if v.sectionName == pve_name then
            return v.count
        end
    end
    return 0
end
function User:IsPveBossPassed(pve_name)
    return self:GetPveSectionStarByName(pve_name) > 0
end
function User:IsPveBoss(pve_name)
    local index, s_index = unpack(string.split(pve_name, "_"))
    return tonumber(s_index) == PVE_LENGTH
end
function User:IsPveNameEnable(pve_name)
    local index, s_index = unpack(string.split(pve_name, "_"))
    return self:IsPveEnable(tonumber(index), tonumber(s_index))
end
function User:IsPveEnable(index, s_index)
    if self.pve[index] then
        if s_index == 1 then return true end
        if self:GetPveSectionStarByIndex(index, s_index - 1) > 0 then
            return true
        end
    else
        if self.pve[index-1] then
            return #self.pve[index-1].sections == 21 and s_index == 1
        else
            return s_index == 1
        end
    end
end
function User:GetPveRewardByIndex(index, s_index)
    local npcs = self.pve[index]
    if npcs then
        return npcs.rewarded[s_index]
    end
end
function User:GetPveSectionStarByName(pve_name)
    local index, s_index = unpack(string.split(pve_name, "_"))
    return self:GetPveSectionStarByIndex(tonumber(index), tonumber(s_index))
end
function User:GetPveSectionStarByIndex(index, s_index)
    local npcs = self.pve[index]
    if npcs then
        return npcs.sections[s_index] or 0
    end
    return 0
end
function User:GetStageStarByIndex(index)
    local total_stars = 0
    for i,v in ipairs(self:GetStageByIndex(index).sections or {}) do
        total_stars = total_stars + v
    end
    return total_stars - ((self:GetStageByIndex(index).sections or {})[PVE_LENGTH] or 0)
end
function User:IsStageRewardedByName(stage_name)
    local stage_index,index = unpack(string.split(stage_name, "_"))
    return self:IsStageRewarded(tonumber(stage_index), tonumber(index))
end
function User:IsStageRewarded(stage_index, index)
    for i,v in ipairs(self:GetStageByIndex(stage_index).rewarded or {}) do
        if v == index then
            return true
        end
    end
end
function User:IsStageEnabled(index)
    if index == 1 then return true end
    return self:IsStagePassed(index - 1)
end
function User:IsStagePassed(index)
    return #(self:GetStageByIndex(index).sections or {}) == PVE_LENGTH
end
function User:IsAllPassed()
    return self:IsStagePassed(TOTAL_STAGES)
end
function User:GetNextStageByPveName(pve_name)
    local stage_index,pve_index = unpack(string.split(pve_name, "_"))
    return tonumber(stage_index) + 1
end
function User:HasNextStageByPveName(pve_name)
    local stage_index,pve_index = unpack(string.split(pve_name, "_"))
    return tonumber(stage_index) < TOTAL_STAGES
end
function User:HasNextStageByIndex(index)
    return index < TOTAL_STAGES
end
function User:GetStageTotalStars()
    return (PVE_LENGTH-1) * 3
end
function User:GetStageByIndex(index)
    return self.pve[index] or {}
end
function User:GetLatestPveIndex()
    local index = 1
    if #self.pve == 0 then
        index = 1
    else
        if #self.pve == TOTAL_STAGES then
            index = TOTAL_STAGES
        else
            if self:IsStagePassed(#self.pve) then
                index = #self.pve + 1
            else
                index = #self.pve
            end
        end
    end
    return index
end
--[[end]]

--[[交易相关方法]]
function User:GetMyDeals()
    return self.deals
end
function User:GetSoldDealsCount()
    local count = 0
    for k,v in pairs(self.deals) do
        if v.isSold then
            count = count + 1
        end
    end
    return count
end
function User:IsSoldOut()
    return self:GetSoldDealsCount() > 0
end
--[end]


--[[countinfo begin]]
-- 每日登陆奖励是否领取
function User:HaveEveryDayLoginReward()
    local countInfo = self.countInfo
    local flag = countInfo.day60 % 30 == 0 and 30 or countInfo.day60 % 30
    local geted = countInfo.day60RewardsCount % 30 == 0 and 30 or countInfo.day60RewardsCount % 30 -- <= geted
    return flag > geted or (geted == 30 and flag == 1)
end
-- 连续登陆奖励是否领取
local config_day14 = GameDatas.Activities.day14
function User:HaveContinutyReward()
    local countInfo = self.countInfo
    for i,v in ipairs(config_day14) do
        local config_rewards = string.split(v.rewards,",")
        if #config_rewards == 1 then
            local reward_type,item_key,count = unpack(string.split(v.rewards,":"))
            if v.day == countInfo.day14 and countInfo.day14 > countInfo.day14RewardsCount then
                return true
            end
        else
            for __,one_reward in ipairs(config_rewards) do
                local reward_type,item_key,count = unpack(string.split(one_reward,":"))
                if reward_type == 'soldiers' then
                    if v.day == countInfo.day14 and countInfo.day14 > countInfo.day14RewardsCount then
                        return true
                    end
                end
            end
        end
    end
end
-- 城堡冲级奖励是否领取
local config_levelup = GameDatas.Activities.levelup
local config_intInit = GameDatas.PlayerInitData.intInit
function User:HavePlayerLevelUpReward()
    local countInfo = self.countInfo
    local current_level = self.buildings.location_1.level
    for __,v in ipairs(config_levelup) do
        if not (app.timer:GetServerTime() > countInfo.registerTime/1000 + config_intInit.playerLevelupRewardsHours.value * 60 * 60) then
            if  v.level <= current_level then
                local max_level = 0
                local l_flag = true
                for __,l in ipairs(countInfo.levelupRewards) do
                    if l == v.index then
                        l_flag = false
                    end
                end
                if l_flag then
                    return true
                end
            end
        end
    end
end
--[[end]]

--[[iap 相关方法]]
local giftExpireHours_value = GameDatas.PlayerInitData.intInit.giftExpireHours.value
function User:GetIapGiftTime(iapGift)
    return iapGift.time / 1000 + giftExpireHours_value * 60 * 60
end

--[[end]]

--[[gcId]]
function User:IsBindGameCenter()
    return self.gcId ~= "" and self.gcId ~= json.null
end
--[[end]]

local COLLECT_TYPE = Enum("WOOD",
    "STONE",
    "IRON",
    "FOOD",
    "COIN")
function User:GetWoodCollectLevel()
    return self:GetCollectLevelByType(COLLECT_TYPE.WOOD)
end
function User:GetStoneCollectLevel()
    return self:GetCollectLevelByType(COLLECT_TYPE.STONE)
end
function User:GetIronCollectLevel()
    return self:GetCollectLevelByType(COLLECT_TYPE.IRON)
end
function User:GetFoodCollectLevel()
    return self:GetCollectLevelByType(COLLECT_TYPE.FOOD)
end
function User:GetCoinCollectLevel()
    return self:GetCollectLevelByType(COLLECT_TYPE.COIN)
end
local collect_type = {
    "woodExp",
    "stoneExp",
    "ironExp",
    "foodExp",
    "coinExp",
}
local collect_exp_config = {
    "wood",
    "stone",
    "iron",
    "food",
    "coin",
}
function User:GetCollectLevelByType(collectType)
    local exp = self.allianceInfo[collect_type[collectType]]
    local config = GameDatas.PlayerVillageExp[collect_exp_config[collectType]]
    for i = #config,1,-1 do
        if exp>=config[i].expFrom then
            return i
        end
    end
end
function User:Loyalty()
    return self.allianceInfo.loyalty
end

--[[resources begin]]
function User:GetGemValue()
    return self.resources.gem
end
function User:HasAnyStamina(num)
    local res = self.resources_cache.stamina
    return self:GetStaminaValue() >= (num or 1)
end
function User:GetStaminaValue()
    return self:GetResValueByType("stamina")
end
function User:GetStaminaLimit()
    return self:GetResLimitByType("stamina")
end
function User:GetStaminaOutput()
    return self:GetResOutputByType("stamina")
end
function User:GetResValueByType(type_)
    local res = self.resources_cache[type_]
    return GameUtils:GetCurrentProduction(
        res.value,
        res.limit,
        res.output,
        self.resources.refreshTime / 1000,
        app.timer:GetServerTime()
    )
end
function User:GetResLimitByType(type_)
    return self.resources_cache[type_].limit
end
function User:GetResOutputByType(type_)
    return self.resources_cache[type_].output
end
--[[end]]


-- [[ dailyQuests begin]]
function User:GetDailyQuests()
    if self:GetNextDailyQuestsRefreshTime() <= app.timer:GetServerTime() then
        -- 达成刷新每日任务条件
        NetManager:getDailyQuestsPromise()
    else
        local quests = {}
        for k,v in pairs(self.dailyQuestEvents) do
            table.insert(quests, v)
        end
        table.sort( quests, function( a,b )
            return a.finishTime < b.finishTime
        end )
        for k,v in pairs(self.dailyQuests.quests) do
            table.insert(quests, v)
        end
        return quests
    end
end
-- 判定是否完成所有任务
function User:IsFinishedAllDailyQuests()
    if self:GetNextDailyQuestsRefreshTime() <= app.timer:GetServerTime() then
        return false
    end
    return LuaUtils:table_empty(self.dailyQuests.quests)
end
-- 下次刷新任务时间
local dailyQuestsRefreshMinites_value = GameDatas.PlayerInitData.intInit.dailyQuestsRefreshMinites.value
function User:GetNextDailyQuestsRefreshTime()
    return dailyQuestsRefreshMinites_value * 60 + self:GetDailyQuestsRefreshTime()
end
function User:GetDailyQuestsRefreshTime()
    return self.dailyQuests.refreshTime / 1000 or 0
end
function User:IsQuestStarted(quest)
    return tolua.type(quest.finishTime) ~= "nil"
end
function User:IsQuestFinished(quest)
    return quest.finishTime == 0
end
-- 判定是否正在进行每日任务
function User:IsOnDailyQuestEvents()
    local t = self.dailyQuestEvents
    if LuaUtils:table_empty(t) then
        return false
    else
        for k,v in pairs(t) do
            if v.finishTime == 0 then
                return false
            end
        end
        return true
    end
end
-- 判定是否能领取每日任务奖励
function User:CouldGotDailyQuestReward()
    local t = self.dailyQuestEvents
    if LuaUtils:table_empty(t) then
        return false
    else
        for k,v in pairs(t) do
            if v.finishTime == 0 then
                return true
            end
        end
        return false
    end
end
--[[end]]


function User:OnPropertyChange(property_name, old_value, new_value)
end

local before_map = {
    basicInfo = function(userData, deltaData)
        local ok, value = deltaData("basicInfo.name")
        if ok then
            if Alliance_Manager and
                not Alliance_Manager:GetMyAlliance():IsDefault()
                and Alliance_Manager:GetMyAlliance():GetMemeberById(self._id)
            then
                Alliance_Manager:GetMyAlliance():GetMemeberById(self._id).name = value
            end
        end
    end,
    resources = function(userData, deltaData)
        if deltaData("resources.stamina") then
            local stamina = userData.resources_cache.stamina
            stamina.value = userData.resources.stamina
        end
    end,
    countInfo = function()end,
    deals = function()end,
    iapGifts = function()end,
    growUpTasks = function()end,
    allianceDonate = function()end,
    dailyTasks = function()end,
    dailyQuests = function()end,
    dailyQuestEvents = function(userData, deltaData)
        local ok, value = deltaData("dailyQuestEvents.edit")
        if ok then
            for k,v in pairs(value) do
                if v.finishTime == 0 then
                    GameGlobalUI:showTips(_("提示"),string.format(_("每日任务%s完成"),Localize.daily_quests_name[v.index]))
                end
            end
        end
    end,
    vipEvents = function()
        City:GetResourceManager():UpdateByCity(City, app.timer:GetServerTime())
    end,
}
local after_map = {
    growUpTasks = function(userData)
        if userData.reward_callback and
            TaskUtils:IsGetAnyCityBuildRewards(userData.growUpTasks) then
            userData.reward_callback()
            userData.reward_callback = nil
        end
    end,
}
function User:OnUserDataChanged(userData, current_time, deltaData)
    self._id                    = userData._id
    self.gcId                   = userData.gcId
    self.serverId               = userData.serverId
    self.logicServerId          = userData.logicServerId
    self.serverLevel            = userData.serverLevel
    self.basicInfo              = userData.basicInfo
    self.countInfo              = userData.countInfo
    self.resources              = userData.resources
    self.iapGifts               = userData.iapGifts
    self.deals                  = userData.deals
    self.pve                    = userData.pve
    self.pveFights              = userData.pveFights
    self.vipEvents              = userData.vipEvents
    self.buildings              = userData.buildings
    self.growUpTasks            = userData.growUpTasks
    self.allianceInfo           = userData.allianceInfo
    self.allianceDonate         = userData.allianceDonate
    self.dailyTasks             = userData.dailyTasks
    self.apnStatus              = userData.apnStatus
    self.dailyQuests            = userData.dailyQuests
    self.dailyQuestEvents       = userData.dailyQuestEvents
    self.requestToAllianceEvents= userData.requestToAllianceEvents
    self.inviteToAllianceEvents = userData.inviteToAllianceEvents

    if deltaData then
        for i,k in ipairs(User.LISTEN_TYPE) do
            local before_func = before_map[k]
            if type(k) == "string" and before_func then
                if deltaData(k) then
                    before_func(self, deltaData)
                    local notify_function_name = string.format("OnUserDataChanged_%s", k)
                    self:NotifyListeneOnType(User.LISTEN_TYPE[k], function(listener)
                        local func = listener[notify_function_name]
                        if func then
                            func(listener, self, deltaData)
                        end
                    end)
                    local after_func = after_map[k]
                    if after_func then
                        after_func(self, deltaData)
                    end
                end
            end
        end
    else
        local stamina = self.resources_cache.stamina
        stamina.value = self.resources.stamina
    end

    return self
end

--[[dailyTasks begin]]
function User:GetDailyTasksInfo(task_type)
    return self.dailyTasks[task_type] or {}
end
function User:CheckDailyTasksWasRewarded(task_type)
    for __,v in ipairs(self:GetAllDailyTasks().rewarded) do
        if v == task_type then return true end
    end
    return false
end
function User:GetAllDailyTasks()
    return self.dailyTasks or {}
end
--[[end]]


--[[vip function begin]]
-- 获取当天剩余普通免费gacha次数
function User:GetOddFreeNormalGachaCount()
    local vip_add = self:IsVIPActived() and self:GetVIPNormalGachaAdd() or 0
    return intInit.freeNormalGachaCountPerDay.value + vip_add - self.countInfo.todayFreeNormalGachaCount
end
local vip_level = GameDatas.Vip.level
function User:GetVIPFreeSpeedUpTime()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].freeSpeedup or 5
end
function User:GetVIPWoodProductionAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].woodProductionAdd or 0
end
function User:GetVIPStoneProductionAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].stoneProductionAdd or 0
end
function User:GetVIPIronProductionAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].ironProductionAdd or 0
end
function User:GetVIPFoodProductionAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].foodProductionAdd or 0
end
function User:GetVIPCitizenRecoveryAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].citizenRecoveryAdd or 0
end
function User:GetVIPMarchSpeedAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].marchSpeedAdd or 0
end
function User:GetVIPNormalGachaAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].normalGachaAdd or 0
end
--暗仓保护上限提升
function User:GetVIPStorageProtectAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].storageProtectAdd or 0
end
function User:GetVIPWallHpRecoveryAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].wallHpRecoveryAdd or 0
end
function User:GetVIPDragonExpAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].dragonExpAdd or 0
end
function User:GetVIPDragonHpRecoveryAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].dragonHpRecoveryAdd or 0
end
function User:GetVIPSoldierAttackPowerAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].soldierAttackPowerAdd or 0
end
function User:GetVIPSoldierHpAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].soldierHpAdd or 0
end
function User:GetVIPDragonLeaderShipAdd()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].dragonLeaderShipAdd or 0
end
function User:GetVIPSoldierConsumeSub()
    return self:IsVIPActived() and vip_level[self:GetVipLevel()].soldierConsumeSub or 0
end
function User:GetSpecialVipLevelExp(level)
    local level = #vip_level >= level and level or #vip_level
    return vip_level[level].expFrom
end
function User:GetSpecialVipLevelExpTo(level)
    local level = #vip_level >= level and level or #vip_level
    return vip_level[level].expTo
end
function User:IsVIPActived()
    local vipEvent = self.vipEvents[1]
    if vipEvent then
        local left = vipEvent.finishTime / 1000 - app.timer:GetServerTime()
        local isactive = left > 0
        return isactive, isactive and left or 0
    end
    return false, 0
end
function User:GetVipLevel()
    local exp = self.basicInfo.vipExp
    return DataUtils:getPlayerVIPLevel(exp)
end
--[[end]]



--[[basicinfo begin]]
function User:GetLevel()
    return self:GetPlayerLevelByExp(self.basicInfo.levelExp)
end


local config_playerLevel = GameDatas.PlayerInitData.playerLevel
function User:GetPlayerLevelByExp(exp)
    exp = checkint(exp)
    for i=#config_playerLevel,1,-1 do
        local config_ = config_playerLevel[i]
        if exp >= config_.expFrom then return config_.level end
    end
    return 0
end
function User:GetCurrentLevelExp(level)
    return config_playerLevel[level].expFrom
end
function User:GetCurrentLevelMaxExp(level)
    local config = config_playerLevel[tonumber(level) + 1]
    if not config then
        return config_playerLevel[level].expTo
    else
        return config.expFrom
    end
end
--获得有加成的龙类型
function User:GetBestDragon()
    local bestDragonForTerrain = {
        grassLand = "greenDragon",
        desert= "redDragon",
        iceField = "blueDragon",
    }
    return bestDragonForTerrain[self.basicInfo.terrain]
end
--[[end]]
--
local promise = import("..utils.promise")
function User:PromiseOfGetCityBuildRewards()
    local p = promise.new()
    self.reward_callback = function()
        p:resolve()
    end
    return p
end

return User

















