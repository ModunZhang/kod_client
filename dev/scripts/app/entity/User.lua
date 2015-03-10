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
function User:SetPveData(fight_data, rewards_data)
    self.fight_data = fight_data
    self.rewards_data = rewards_data
end
function User:EncodePveDataAndResetFightRewardsData()
    local fightData = self.fight_data
    local rewards = self.rewards_data
    self.fight_data = nil
    self.rewards_data = nil

    for i,v in ipairs(rewards or {}) do
        v.probability = nil
    end

    return {
        pveData = {
            staminaUsed = self.used_strength,
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
    return GameDatas.PlayerInitData.floatInit.dailyQuestsRefreshHours.value * 60 * 60 + self.dailyQuestsRefreshTime/1000
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
function User:OnUserDataChanged(userData, current_time)
    self:OnResourcesChangedByTime(userData.resources, current_time)
    self:OnBasicInfoChanged(userData.basicInfo)
    self:OnCountInfoChanged(userData.countInfo)
    self:OnNewInviteAllianceEventsComming(userData.__inviteToAllianceEvents)
    self:OnRequestToAllianceEventsChanged(userData.requestToAllianceEvents)
    self:OnNewRequestToAllianceEventsComming(userData.__requestToAllianceEvents)
    self:OnInviteAllianceEventsChanged(userData.inviteToAllianceEvents)
    -- 每日任务
    self:OnDailyQuestsChanged(userData.dailyQuests)
    self:OnDailyQuestsEventsChanged(userData.dailyQuestEvents)
    self:OnNewDailyQuestsComming(userData.__dailyQuests)
    self:OnNewDailyQuestsEventsComming(userData.__dailyQuestEvents)
    -- 交易
    self.trade_manager:OnUserDataChanged(userData)
    self:GetPVEDatabase():OnUserDataChanged(userData)

    -- vip event
    self:OnVipEventDataChange(userData)
    if self.growUpTaskManger:OnUserDataChanged(userData) then
        self:OnTaskChanged()
    end
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



function User:OnCountInfoChanged(countInfo)
    if not countInfo then return end
    if self.countInfo then
        for k,v in pairs(countInfo) do
            self.countInfo[k] = v
        end
        self:NotifyListeneOnType(COUNT_INFO, function(listener)
            listener:OnCountInfoChanged(self, {
                })
        end)
    else
        self.countInfo  = countInfo
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
    for i=#vip_level,1,-1 do
        local config = vip_level[i]
        if exp >= config.expFrom then
            local percent = math.floor((exp - config.expFrom)/(config.expTo-config.expFrom)*100)
            return config.level,percent,exp
        end
    end
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
function User:OnVipEventDataChange(userData)
    if userData.vipEvents then
        if not LuaUtils:table_empty(userData.vipEvents) then
            self.vip_event:UpdateData(userData.vipEvents[1])
        end
    end
    if userData.__vipEvents then
        self.vip_event:UpdateData(userData.__vipEvents[1].data)
        if userData.__vipEvents[1].type=="add" then
            -- vip 激活，刷新资源
            City:GetResourceManager():UpdateByCity(City, app.timer:GetServerTime())
            -- 通知出去
            self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT_ACTIVE, function(listener)
                listener:OnVipEventActive(self.vip_event)
            end)
        end
        if userData.__vipEvents[1].type=="remove" then
            -- vip 激活结束，刷新资源
            City:GetResourceManager():UpdateByCity(City, app.timer:GetServerTime())
            -- 通知出去
            self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT_OVER, function(listener)
                listener:OnVipEventOver(self.vip_event)
            end)
        end
    end

    self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT, function(listener)
        listener:OnVipEventTimer(self.vip_event)
    end)
end
function User:OnVipEventTimer( vip_event )
    self:NotifyListeneOnType(User.LISTEN_TYPE.VIP_EVENT, function(listener)
        listener:OnVipEventTimer(vip_event)
    end)
end
function User:OnResourcesChangedByTime(resources, current_time)
    if not resources then return end
    if resources.gem then
        self:GetGemResource():SetValue(resources.gem)
    end
    if resources.stamina then
        self.used_strength = 0
        local strength = self:GetStrengthResource()
        strength:UpdateResource(current_time, resources.stamina)
        strength:SetProductionPerHour(current_time, 4)
    end
end
function User:OnBasicInfoChanged(basicInfo)
    if not basicInfo then return end
    self:SetTerrain(basicInfo.terrain)
    self:SetLevelExp(basicInfo.levelExp)
    self:SetLevel(self:GetPlayerLevelByExp(self:LevelExp()))
    self:SetPower(basicInfo.power)
    self:SetName(basicInfo.name)
    self:SetVipExp(basicInfo.vipExp)
    self:SetIcon(basicInfo.icon)
    self:SetMarchQueue(basicInfo.marchQueue)
end
function User:OnNewRequestToAllianceEventsComming(__requestToAllianceEvents)
    if not __requestToAllianceEvents then return end
    GameUtils:Event_Handler_Func(
        __requestToAllianceEvents
        ,function(event_data)
            table.insert(self.request_events, event_data)
        end
        ,function(event_data)
            assert(false, "会有修改吗?")
        end
        ,function(event_data)
            for i,v in ipairs(self.request_events) do
                if v.requestTime == event_data.requestTime then
                    table.remove(self.request_events, i)
                    break
                end
            end
        end
    )
end
function User:OnRequestToAllianceEventsChanged(requestToAllianceEvents)
    if not requestToAllianceEvents then return end
    self.request_events = requestToAllianceEvents
end
function User:OnNewInviteAllianceEventsComming(__inviteToAllianceEvents)
    if not __inviteToAllianceEvents then return end
    GameUtils:Event_Handler_Func(
        __inviteToAllianceEvents
        ,function(event_data)
            table.insert(self.invite_events, event_data)
        end
        ,function(event_data)
            assert(false, "会有修改吗?")
        end
        ,function(event_data)
            for i,v in ipairs(self.invite_events) do
                if v.inviteTime == event_data.inviteTime and v.id == event_data.id then
                    table.remove(self.invite_events, i)
                    break
                end
            end
        end
    )
end
function User:OnInviteAllianceEventsChanged(inviteToAllianceEvents)
    if not inviteToAllianceEvents then return end
    self.invite_events = inviteToAllianceEvents
end
function User:OnDailyQuestsChanged(dailyQuests)
    if not dailyQuests then return end
    LuaUtils:outputTable("OnDailyQuestsChanged", dailyQuests)
    if dailyQuests.refreshTime then
        self:SetDailyQuestsRefreshTime(dailyQuests.refreshTime)
    end
    self.dailyQuests= {}
    if dailyQuests.quests then
        for k,v in pairs(dailyQuests.quests) do
            self.dailyQuests[v.id] = v
        end
    end
    self:OnDailyQuestsRefresh()
end
function User:OnDailyQuestsEventsChanged(dailyQuestEvents)
    if not dailyQuestEvents then return end
    LuaUtils:outputTable("dailyQuestEvents", dailyQuestEvents)
    for k,v in pairs(dailyQuestEvents) do
        self.dailyQuestEvents[v.id] = v
    end
end
function User:OnNewDailyQuestsComming(__dailyQuests)
    if not __dailyQuests then return end
    LuaUtils:outputTable("__dailyQuests", __dailyQuests)
    local add = {}
    local edit = {}
    local remove = {}
    for k,v in pairs(__dailyQuests) do
        if v.type == "add" then
            self.dailyQuests[v.data.id] = v.data
            table.insert(add,v.data)
        end
        if v.type == "edit" then
            if self.dailyQuests[v.data.id] then
                self.dailyQuests[v.data.id] = v.data
                table.insert(edit,v.data)
            end
        end
        if v.type == "remove" then
            if self.dailyQuests[v.data.id] then
                self.dailyQuests[v.data.id] = nil
                table.insert(remove,v.data)
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
function User:OnNewDailyQuestsEventsComming(__dailyQuestEvents)
    if not __dailyQuestEvents then return end
    LuaUtils:outputTable("__dailyQuestEvents", __dailyQuestEvents)
    local add = {}
    local edit = {}
    local remove = {}
    for k,v in pairs(__dailyQuestEvents) do
        if v.type == "add" then
            self.dailyQuestEvents[v.data.id] = v.data
            table.insert(add,v.data)
        end
        if v.type == "edit" then
            if self.dailyQuestEvents[v.data.id] then
                self.dailyQuestEvents[v.data.id] = v.data
                table.insert(edit,v.data)
            end
        end
        if v.type == "remove" then
            if self.dailyQuestEvents[v.data.id] then
                self.dailyQuestEvents[v.data.id] = nil
                table.insert(remove,v.data)
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






















