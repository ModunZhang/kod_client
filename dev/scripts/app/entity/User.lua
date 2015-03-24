local PVEDatabase = import(".PVEDatabase")
local Resource = import(".Resource")
local VipEvent = import(".VipEvent")
local GrowUpTaskManager = import(".GrowUpTaskManager")
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local property = import("..utils.property")
local TradeManager = import("..entity.TradeManager")
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local User = class("User", MultiObserver)
User.LISTEN_TYPE = Enum("BASIC",
    "RESOURCE",
    "DALIY_QUEST_REFRESH",
    "NEW_DALIY_QUEST",
    "NEW_DALIY_QUEST_EVENT",
    "VIP_EVENT",
    "COUNT_INFO",
    "DAILY_TASKS",
    "VIP_EVENT_OVER",
    "VIP_EVENT_ACTIVE",
    "TASK")
local TASK = User.LISTEN_TYPE.TASK
local BASIC = User.LISTEN_TYPE.BASIC
local RESOURCE = User.LISTEN_TYPE.RESOURCE
local COUNT_INFO = User.LISTEN_TYPE.COUNT_INFO
local config_playerLevel = GameDatas.PlayerInitData.playerLevel
User.RESOURCE_TYPE = Enum("BLOOD", "COIN", "STRENGTH", "GEM", "RUBY", "BERYL", "SAPPHIRE", "TOPAZ")
local GEM = User.RESOURCE_TYPE.GEM
local STRENGTH = User.RESOURCE_TYPE.STRENGTH

local intInit = GameDatas.PlayerInitData.intInit
local vip_level = GameDatas.Vip.level

property(User, "level", 1)
property(User, "levelExp", 0)
property(User, "power", 0)
property(User, "name", "")
property(User, "vipExp", 0)
property(User, "icon", "")
property(User, "dailyQuestsRefreshTime", 0)
property(User, "terrain", "")
property(User, "id", 0)
property(User, "marchQueue", 1)
property(User, "serverName", "")
property(User, "apnId", "")
function User:ctor(p)
    User.super.ctor(self)
    self.resources = {
        [GEM] = Resource.new(),
        [STRENGTH] = AutomaticUpdateResource.new(),
    }
    self:GetGemResource():SetValueLimit(math.huge) -- 会有人充值这么多的宝石吗？
    self:GetStrengthResource():SetValueLimit(100)

    self.used_strength = 0
    self.pve_database = PVEDatabase.new(self)
    local _,_, index = self.pve_database:GetCharPosition()
    self:GotoPVEMapByLevel(index)

    self.request_events = {}
    self.invite_events = {}
    -- 每日任务
    self.dailyQuests = {}
    self.dailyQuestEvents = {}
    -- 交易管理器
    self.trade_manager = TradeManager.new()
    if type(p) == "table" then
        self:SetId(p._id)
        self:OnBasicInfoChanged(p)
    else
        self:SetId(p)
    end
    -- vip event
    local vip_event = VipEvent.new()
    vip_event:AddObserver(self)
    self.vip_event = vip_event
    self.dailyTasks = {}
    self.growUpTaskManger = GrowUpTaskManager.new()
end
function User:GotoPVEMapByLevel(level)
    if self.cur_pve_map then
        self.cur_pve_map:RemoveAllObserver()
    end
    self.cur_pve_map = self.pve_database:GetMapByIndex(level)
end
-- return 是否成功使用体力
function User:UseStrength(num)
    if self:HasAnyStength(num) then
        self.used_strength = self.used_strength + num
        self:GetStrengthResource():ReduceResourceByCurrentTime(app.timer:GetServerTime(), num or 1)
        self:OnResourceChanged()
        return true
    end
    return false
end
function User:HasAnyStength(num)
    return self:GetStrengthResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()) >= (num or 1)
end
function User:ResetPveData()
    self:SetPveData(nil, nil, nil)
end
function User:SetPveData(fight_data, rewards_data, gem_used)
    self.fight_data = fight_data
    self.rewards_data = rewards_data
    self.gem_used = gem_used
end
function User:EncodePveDataAndResetFightRewardsData()
    local fightData = self.fight_data
    local rewards = self.rewards_data
    self.fight_data = nil
    self.rewards_data = nil

    for i,v in ipairs(rewards or {}) do
        v.probability = nil
    end
    local used_strength = self.used_strength
    self.used_strength = 0

    local gem_used = self.gem_used
    self.gem_used = nil
    return {
        pveData = {
            gemUsed = gem_used,
            staminaUsed = used_strength,
            location = self.pve_database:EncodeLocation(),
            floor = self.cur_pve_map:EncodeMap(),
        },
        fightData = fightData,
        rewards = rewards,
    }
end
function User:ResetAllListeners()
    self.cur_pve_map:RemoveAllObserver()
    self:ClearAllListener()
end
function User:GetCurrentPVEMap()
    return self.cur_pve_map
end
function User:GetPVEDatabase()
    return self.pve_database
end
function User:GetGemResource()
    return self.resources[GEM]
end
function User:GetStrengthResource()
    return self.resources[STRENGTH]
end
function User:GetTradeManager()
    return self.trade_manager
end
function User:GetTaskManager()
    return self.growUpTaskManger
end
function User:OnTaskChanged()
    self:NotifyListeneOnType(TASK, function(listener)
        listener:OnTaskChanged(self)
    end)
end
function User:OnTimer(current_time)
    self:OnResourceChanged()
    self.vip_event:OnTimer(current_time)
end
function User:OnResourceChanged()
    self:NotifyListeneOnType(RESOURCE, function(listener)
        listener:OnResourceChanged(self)
    end)
end
function User:GetInviteEvents()
    return self.invite_events
end
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
        for k,v in pairs(self.dailyQuests) do
            table.insert(quests, v)
        end
        return quests
    end
end
-- 下次刷新任务时间
function User:GetNextDailyQuestsRefreshTime()
    return GameDatas.PlayerInitData.intInit.dailyQuestsRefreshMinites.value * 60 + self.dailyQuestsRefreshTime/1000
end
function User:GetDailyQuestEvents()
    return self.dailyQuestEvents
end
function User:IsQuestStarted(quest)
    return quest.finishTime ~= nil
end
function User:IsQuestFinished(quest)
    return quest.finishTime==0
end
function User:GetRequestEvents()
    return self.request_events
end
function User:OnPropertyChange(property_name, old_value, new_value)
    self:NotifyListeneOnType(BASIC, function(listener)
        listener:OnBasicChanged(self, {
            [property_name] = {old = old_value, new = new_value}
        })
    end)
end
function User:OnUserDataChanged(userData, current_time, deltaData)
    self:SetServerName(userData.logicServerId)
    self:SetApnId(userData.apnId)
    self:OnResourcesChangedByTime(userData, current_time, deltaData)
    self:OnBasicInfoChanged(userData, deltaData)
    self:OnCountInfoChanged(userData, deltaData)
    self:GetPVEDatabase():OnUserDataChanged(userData, deltaData)
    if self.growUpTaskManger:OnUserDataChanged(userData, deltaData) then
        self:OnTaskChanged()
    end
    self.request_events = userData.requestToAllianceEvents
    self.invite_events = userData.inviteToAllianceEvents

    -- 下面还没做增量判断
    -- 每日任务
    self:OnDailyQuestsChanged(userData,deltaData)
    self:OnDailyQuestsEventsChanged(userData,deltaData)
    -- 交易
    self.trade_manager:OnUserDataChanged(userData,deltaData)
    self:GetPVEDatabase():OnUserDataChanged(userData, deltaData)

    -- vip event
    self:OnVipEventDataChange(userData, deltaData)
    -- 日常任务
    self:OnDailyTasksChanged(userData.dailyTasks)
    return self
end

function User:OnDailyTasksChanged(dailyTasks)
    if not dailyTasks then return end
    local changed_task_types = {}
    for k,v in pairs(dailyTasks) do
        table.insert(changed_task_types,k)
        self.dailyTasks[k] = v
    end
    self:NotifyListeneOnType(self.LISTEN_TYPE.DAILY_TASKS, function(listener)
        listener:OnDailyTasksChanged(self, changed_task_types)
    end)
end

function User:GetDailyTasksInfo(task_type)
    return self.dailyTasks[task_type] or {}
end

function User:CheckDailyTasksWasRewarded(task_type)
    for __,v in ipairs(self:GetAllDailyTasks().rewarded) do
        return v == task_type
    end
    return false
end

function User:GetAllDailyTasks()
    return self.dailyTasks or {}
end



function User:OnCountInfoChanged(userData, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.countInfo
    if is_fully_update or is_delta_update then
        self.countInfo = userData.countInfo
        self:NotifyListeneOnType(COUNT_INFO, function(listener)
            listener:OnCountInfoChanged(self)
        end)
    end
end


function User:GetCountInfo()
    return self.countInfo
end
-- 获取当天剩余普通免费gacha次数
function User:GetOddFreeNormalGachaCount()
    local vip_add = self:GetVipEvent():IsActived() and self:GetVIPNormalGachaAdd() or 0
    return intInit.freeNormalGachaCountPerDay.value + vip_add - self.countInfo.todayFreeNormalGachaCount
end
function User:GetVipEvent()
    return self.vip_event
end
function User:GetVipLevel()
    local exp = self.vipExp
    return DataUtils:getPlayerVIPLevel(exp)
end
function User:IsVIPActived()
    return self.vip_event:IsActived()
end
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
function User:OnVipEventDataChange(userData, deltaData)
    local is_fully_update = deltaData == nil

    local is_delta_update = not is_fully_update and deltaData.vipEvents ~= nil
    if is_fully_update then
        if userData.vipEvents then
            if not LuaUtils:table_empty(userData.vipEvents) then
                self.vip_event:UpdateData(userData.vipEvents[1])
            end
        end
        self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT, function(listener)
            listener:OnVipEventTimer(self.vip_event)
        end)
    end
    if is_delta_update then
        local add = deltaData.vipEvents.add
        local remove = deltaData.vipEvents.remove

        if remove and #remove >0 then
            -- vip 激活结束，刷新资源
            City:GetResourceManager():UpdateByCity(City, app.timer:GetServerTime())
            -- 通知出去
            self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT_OVER, function(listener)
                listener:OnVipEventOver(self.vip_event)
            end)
            self.vip_event:UpdateData(remove[1])
        end
        if add and #add >0 then
            -- vip 激活，刷新资源
            City:GetResourceManager():UpdateByCity(City, app.timer:GetServerTime())
            -- 通知出去
            self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT_ACTIVE, function(listener)
                listener:OnVipEventActive(self.vip_event)
            end)
            self.vip_event:UpdateData(add[1])
        end
        for k,v in pairs(deltaData.vipEvents) do
            if tolua.type(k) == "number" then
                self.vip_event:UpdateData(v)
            end
        end
        self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT, function(listener)
            listener:OnVipEventTimer(self.vip_event)
        end)
    end
end
function User:OnVipEventTimer( vip_event )
    self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT, function(listener)
        listener:OnVipEventTimer(vip_event)
    end)
end
function User:OnResourcesChangedByTime(userData, current_time, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.resources and deltaData.resources.stamina
    local resources = userData.resources
    if is_fully_update or is_delta_update then
        local strength = self:GetStrengthResource()
        strength:UpdateResource(current_time, resources.stamina)
        strength:SetProductionPerHour(current_time, 4)
    end
    self:GetGemResource():SetValue(resources.gem)
end
function User:OnBasicInfoChanged(userData, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.basicInfo
    if is_fully_update or is_delta_update then
        local basicInfo = userData.basicInfo
        self:SetTerrain(basicInfo.terrain)
        self:SetLevelExp(basicInfo.levelExp)
        self:SetLevel(self:GetPlayerLevelByExp(self:LevelExp()))
        self:SetPower(basicInfo.power)
        self:SetName(basicInfo.name)
        self:SetVipExp(basicInfo.vipExp)
        self:SetIcon(basicInfo.icon)
        self:SetMarchQueue(basicInfo.marchQueue)
    end
end
function User:OnDailyQuestsChanged(userData, deltaData)
    local is_fully_update = deltaData == nil
    if is_fully_update then
        if userData.dailyQuests.refreshTime then
            self:SetDailyQuestsRefreshTime(userData.dailyQuests.refreshTime)
        end
        self.dailyQuests= {}
        if userData.dailyQuests.quests then
            for k,v in pairs(userData.dailyQuests.quests) do
                self.dailyQuests[v.id] = v
            end
        end
        self:OnDailyQuestsRefresh()
    end
    local is_delta_update = not is_fully_update and deltaData.dailyQuests ~= nil

    if is_delta_update then
        local add = {}
        local edit = {}
        local remove = {}
        for k,v in pairs(deltaData.dailyQuests) do
            if k == "add" then
                for _,data in ipairs(v) do
                    self.dailyQuests[data.id] = data
                    table.insert(add,data)
                end
            end
            if k == "edit" then
                for _,data in ipairs(v) do
                    if self.dailyQuests[data.id] then
                        self.dailyQuests[data.id] = data
                        table.insert(edit,data)
                    end
                end
            end
            if k == "remove" then
                for _,data in ipairs(v) do
                    if self.dailyQuests[data.id] then
                        self.dailyQuests[data.id] = nil
                        table.insert(remove,data)
                    end
                end
            end
        end
        self:OnNewDailyQuests(
            {
                add= add,
                edit= edit,
                remove= remove,
            }
        )
    end
end
function User:OnDailyQuestsEventsChanged(userData,deltaData)
    local is_fully_update = deltaData == nil
    if is_fully_update then
        for k,v in pairs(userData.dailyQuestEvents) do
            self.dailyQuestEvents[v.id] = v
        end
    end
    local is_delta_update = not is_fully_update and deltaData.dailyQuestEvents ~= nil
    if is_delta_update then
        local add = {}
        local edit = {}
        local remove = {}
        for k,v in pairs(deltaData.dailyQuestEvents) do
            if k == "add" then
                for _,data in ipairs(v) do
                    self.dailyQuestEvents[data.id] = data
                    table.insert(add,data)
                end
            end
            if k == "edit" then
                for _,data in ipairs(v) do
                    if self.dailyQuestEvents[data.id] then
                        self.dailyQuestEvents[data.id] = data
                        table.insert(edit,data)
                    end
                end
            end
            if k == "remove" then
                for _,data in ipairs(v) do
                    if self.dailyQuestEvents[data.id] then
                        self.dailyQuestEvents[data.id] = nil
                        table.insert(remove,data)
                    end
                end
            end
        end
        self:OnNewDailyQuestsEvent(
            {
                add= add,
                edit= edit,
                remove= remove,
            }
        )
    end
end
-- 判定是否正在进行每日任务
function User:IsOnDailyQuestEvents()
    local dailyQuestEvents = self.dailyQuestEvents
    if LuaUtils:table_empty(dailyQuestEvents) then
        return false
    else
        for k,v in pairs(dailyQuestEvents) do
            if v.finishTime == 0 then
                return false
            end
        end
        return true
    end
end
function User:OnDailyQuestsRefresh()
    self:NotifyListeneOnType(User.LISTEN_TYPE.DALIY_QUEST_REFRESH, function(listener)
        listener:OnDailyQuestsRefresh(self:GetDailyQuests())
    end)
end
function User:OnNewDailyQuests(changed_map)
    self:NotifyListeneOnType(User.LISTEN_TYPE.NEW_DALIY_QUEST, function(listener)
        listener:OnNewDailyQuests(changed_map)
    end)
end
function User:OnNewDailyQuestsEvent(changed_map)
    self:NotifyListeneOnType(User.LISTEN_TYPE.NEW_DALIY_QUEST_EVENT, function(listener)
        listener:OnNewDailyQuestsEvent(changed_map)
    end)
end

function User:GetPlayerLevelByExp(exp)
    exp = checkint(exp)
    for i=#config_playerLevel,1,-1 do
        local config_ = config_playerLevel[i]
        if exp >= config_.expFrom then return config_.level end
    end
    return 0
end
--获得有加成的龙类型
function User:GetBestDragon()
    local bestDragonForTerrain = {
        grassLand = "greenDragon",
        desert= "redDragon",
        iceField = "blueDragon",
    }
    return bestDragonForTerrain[self:Terrain()]
end

return User










































