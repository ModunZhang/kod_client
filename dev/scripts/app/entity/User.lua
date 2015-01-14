local Resource = import(".Resource")
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local property = import("..utils.property")
local TradeManager = import("..entity.TradeManager")
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local User = class("User", MultiObserver)
User.LISTEN_TYPE = Enum("BASIC", "RESOURCE", "INVITE_TO_ALLIANCE", "REQUEST_TO_ALLIANCE","DALIY_QUEST_REFRESH","NEW_DALIY_QUEST","NEW_DALIY_QUEST_EVENT")
local BASIC = User.LISTEN_TYPE.BASIC
local RESOURCE = User.LISTEN_TYPE.RESOURCE
local INVITE_TO_ALLIANCE = User.LISTEN_TYPE.INVITE_TO_ALLIANCE
local REQUEST_TO_ALLIANCE = User.LISTEN_TYPE.REQUEST_TO_ALLIANCE

User.RESOURCE_TYPE = Enum("BLOOD", "COIN", "STRENGTH", "GEM", "RUBY", "BERYL", "SAPPHIRE", "TOPAZ")
local GEM = User.RESOURCE_TYPE.GEM
local STRENGTH = User.RESOURCE_TYPE.STRENGTH

property(User, "level", 1)
property(User, "levelExp", 0)
property(User, "power", 0)
property(User, "name", "")
property(User, "vipExp", 0)
property(User, "icon", "")
property(User, "dailyQuestsRefreshTime", 0)
property(User, "id", 0)
function User:ctor(p)
    User.super.ctor(self)
    self.resources = {
        [GEM] = Resource.new(),
        [STRENGTH] = AutomaticUpdateResource.new(),
    }
    self:GetGemResource():SetValueLimit(math.huge) -- 会有人充值这么多的宝石吗？

    
    self.request_events = {}
    self.invite_events = {}
    -- 每日任务
    self.dailyQuests = {}
    self.dailyQuestEvents = {}
    -- 交易管理器
    self.trade_manager = TradeManager.new()
    if type(p) == "table" then
        self:SetId(p.id)
        self:OnBasicInfoChanged(p)
    else
        self:SetId(p)
    end
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
function User:OnTimer(current_time)
    self:UpdateResourceByTime(current_time)
    self:OnResourceChanged()
end
function User:UpdateResourceByTime(current_time)
    for _, v in pairs(self.resources) do
        v:OnTimer(current_time)
    end
end
function User:OnResourceChanged()
    self:NotifyListeneOnType(RESOURCE, function(listener)
        listener:OnResourceChanged(self)
    end)
end
function User:CreateInviteEventFromJson(json_data)
    return json_data
end
function User:CreateInviteEvent(requestTime)
    return {requestTime = requestTime}
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
function User:AddInviteEventWithNotify(req)
    local invite = self:AddInviteEventWithOrder(req)
    self:OnRequestAllianceEvents{
        added = {invite},
        removed = {}
    }
    return invite
end
function User:AddInviteEventWithOrder(req)
    local invite = self:AddInviteEvent(req)
    self:SortInvites()
    return invite
end
function User:AddInviteEvent(req)
    local invite_events = self.invite_events
    table.insert(invite_events, req)
    return req
end
function User:DeleteInviteWithNotify(req)
    local invite = self:DeleteInviteWith(req)
    self:OnRequestAllianceEvents{
        added = {},
        removed = {invite}
    }
end
function User:DeleteInviteWith(req)
    local invite_events = self.invite_events
    for i, v in ipairs(invite_events) do
        if v.inviteTime == req.inviteTime then
            return table.remove(invite_events, i)
        end
    end
end
function User:SortInvites()
    table.sort(self.invite_events, function(a, b)
        return a.inviteTime > b.inviteTime
    end)
end
function User:OnInviteAllianceEvents(changed_map)
    self:NotifyListeneOnType(INVITE_TO_ALLIANCE, function(listener)
        listener:OnInviteAllianceEvents(self, changed_map)
    end)
end
function User:CreateRequestEventFromJson(json_data)
    return json_data
end
function User:CreateRequestEvent(requestTime)
    return {requestTime = requestTime}
end
function User:GetRequestEvents()
    return self.request_events
end
function User:AddRequestEventWithNotify(req)
    local request = self:AddRequestEventWithOrder(req)
    self:OnRequestAllianceEvents{
        added = {request},
        removed = {}
    }
    return request
end
function User:AddRequestEventWithOrder(req)
    local request_events = self:AddRequestEvent(req)
    self:SortRequests()
    return request_events
end
function User:AddRequestEvent(req)
    local request_events = self.request_events
    table.insert(request_events, req)
    return req
end
function User:SortRequests()
    table.sort(self.request_events, function(a, b)
        return a.requestTime > b.requestTime
    end)
end
function User:DeleteRequestWithNotify(req)
    local request = self:DeleteRequestWith(req)
    self:OnRequestAllianceEvents{
        added = {},
        removed = {request}
    }
end
function User:DeleteRequestWith(req)
    local request_events = self.request_events
    for i, v in ipairs(request_events) do
        if v.requestTime == req.requestTime then
            return table.remove(request_events, i)
        end
    end
end
function User:OnRequestAllianceEvents(changed_map)
    self:NotifyListeneOnType(REQUEST_TO_ALLIANCE, function(listener)
        listener:OnRequestAllianceEvents(self, changed_map)
    end)
end
function User:OnPropertyChange(property_name, old_value, new_value)
    self:NotifyListeneOnType(BASIC, function(listener)
        listener:OnBasicChanged(self, {
            [property_name] = {old = old_value, new = new_value}
        })
    end)
end
function User:OnUserDataChanged(userData)
    self:OnBasicInfoChanged(userData.basicInfo)
    self:OnNewInviteAllianceEventsComming(userData.__inviteToAllianceEvents)
    self:OnNewRequestToAllianceEventsComming(userData.__requestToAllianceEvents)
    self:OnRequestToAllianceEventsChanged(userData.requestToAllianceEvents)
    self:OnInviteAllianceEventsChanged(userData.inviteToAllianceEvents)
    -- 每日任务
    self:OnDailyQuestsChanged(userData.dailyQuests)
    self:OnDailyQuestsEventsChanged(userData.dailyQuestEvents)
    self:OnNewDailyQuestsComming(userData.__dailyQuests)
    self:OnNewDailyQuestsEventsComming(userData.__dailyQuestEvents)
    -- 交易
    self.trade_manager:OnUserDataChanged(userData)
end
function User:OnBasicInfoChanged(basicInfo)
    if not basicInfo then return end
    self:SetLevel(basicInfo.level)
    self:SetLevelExp(basicInfo.levelExp)
    self:SetPower(basicInfo.power)
    self:SetName(basicInfo.name)
    self:SetVipExp(basicInfo.vipExp)
    self:SetIcon(basicInfo.icon)
    self:SetDailyQuestsRefreshTime(basicInfo.dailyQuestsRefreshTime)
end
function User:OnNewRequestToAllianceEventsComming(__requestToAllianceEvents)
    if not __requestToAllianceEvents then return end
    local added = {}
    local removed = {}
    for _, v in ipairs(__requestToAllianceEvents) do
        local type_ = v.type
        local join_event = v.data
        if type_ == "add" then
            self:AddRequestEvent(join_event)
            table.insert(added, join_event)
        elseif type_ == "remove" then
            self:DeleteRequestWith(join_event)
            table.insert(removed, join_event)
        elseif type_ == "edit" then
            assert(false, "能修改吗?")
        end
    end
    self:SortRequests()
    self:OnRequestAllianceEvents{
        added = added,
        removed = removed,
    }
end
function User:OnRequestToAllianceEventsChanged(requestToAllianceEvents)
    if not requestToAllianceEvents then return end
    local request_map = {}
    for _, v in ipairs(requestToAllianceEvents) do
        request_map[v.id] = v
    end

    local remove_requests = {}
    for i, v in ipairs(self:GetRequestEvents()) do
        if not request_map[v.id] then
            table.insert(remove_requests, v)
        else
            request_map[v.id] = nil
        end
    end

    local add_requests = {}
    for _, v in pairs(request_map) do
        table.insert(add_requests, v)
    end

    self.request_events = requestToAllianceEvents
    self:OnRequestAllianceEvents{
        added = add_requests,
        removed = remove_requests
    }
end
function User:OnNewInviteAllianceEventsComming(__inviteToAllianceEvents)
    if not __inviteToAllianceEvents then return end
    local add_invites = {}
    local remove_invites = {}
    for _, v in ipairs(__inviteToAllianceEvents) do
        local type_ = v.type
        local invite = v.data
        if type_ == "add" then
            table.insert(add_invites, self:AddInviteEvent(invite))
        elseif type_ == "remove" then
            table.insert(remove_invites, self:DeleteInviteWith(invite))
        elseif type_ == "edit" then
            assert(false, "会有修改吗?")
        end
    end
    self:SortInvites()
    self:OnInviteAllianceEvents{
        added = add_invites,
        removed = remove_invites
    }
end
function User:OnInviteAllianceEventsChanged(inviteToAllianceEvents)
    if not inviteToAllianceEvents then return end
    local invite_map = {}
    for _, v in ipairs(inviteToAllianceEvents) do
        invite_map[v.id] = v
    end

    local remove_invites = {}
    for i, v in ipairs(self:GetInviteEvents()) do
        if not invite_map[v.id] then
            table.insert(remove_invites, v)
        else
            invite_map[v.id] = nil
        end
    end

    local add_invites = {}
    for _, v in pairs(invite_map) do
        table.insert(add_invites, v)
    end

    self.invite_events = inviteToAllianceEvents
    self:OnInviteAllianceEvents{
        added = add_invites,
        removed = remove_invites
    }
end
function User:OnDailyQuestsChanged(dailyQuests)
    if not dailyQuests then return end
    LuaUtils:outputTable("OnDailyQuestsChanged", dailyQuests)
    self.dailyQuests= {}
    for k,v in pairs(dailyQuests) do
        self.dailyQuests[v.id] = v
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
return User











