local property = import("..utils.property")
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local User = class("User", MultiObserver)
User.LISTEN_TYPE = Enum("BASIC", "INVITE_TO_ALLIANCE", "REQUEST_TO_ALLIANCE")
property(User, "level", 1)
property(User, "levelExp", 0)
property(User, "power", 0)
property(User, "name", "")
property(User, "vipExp", 0)
property(User, "icon", "")
function User:ctor(id)
    User.super.ctor(self)
    property(self, "id", id)
    self.request_events = {}
    self.invite_events = {}
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
    self:NotifyListeneOnType(User.LISTEN_TYPE.INVITE_TO_ALLIANCE, function(listener)
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
    self:NotifyListeneOnType(User.LISTEN_TYPE.REQUEST_TO_ALLIANCE, function(listener)
        listener:OnRequestAllianceEvents(self, changed_map)
    end)
end
function User:OnPropertyChange(property_name, old_value, new_value)
    self:NotifyListeneOnType(User.LISTEN_TYPE.BASIC, function(listener)
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
end
function User:OnBasicInfoChanged(basicInfo)
    if not basicInfo then return end
    self:SetLevel(basicInfo.level)
    self:SetLevelExp(basicInfo.levelExp)
    self:SetPower(basicInfo.power)
    self:SetName(basicInfo.name)
    self:SetVipExp(basicInfo.vipExp)
    self:SetIcon(basicInfo.icon)
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
return User








