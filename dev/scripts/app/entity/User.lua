local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local User = class("User", MultiObserver)
User.LISTEN_TYPE = Enum("INVITE_TO_ALLIANCE", "REQUEST_TO_ALLIANCE")
function User:ctor()
    User.super.ctor(self)
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
    local invite = self:AddInviteEvent(req)
    self:OnRequestAllianceEvents{
        added = {invite},
        removed = {}
    }
    return invite
end
function User:AddInviteEvent(req)
    local invite_events = self.invite_events
    table.insert(invite_events, req)
    table.sort(invite_events, function(a, b)
        return a.inviteTime > b.inviteTime
    end)
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
    local request = self:AddRequestEvent(req)
    self:OnRequestAllianceEvents{
        added = {request},
        removed = {}
    }
    return request
end
function User:AddRequestEvent(req)
    local request_events = self.request_events
    table.insert(request_events, req)
    table.sort(request_events, function(a, b)
        return a.requestTime > b.requestTime
    end)
    return req
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

function User:OnUserDataChanged(userData)
    self:OnRequestToAllianceEventsChanged(userData.requestToAllianceEvents)
    self:OnInviteAllianceEventsChanged(userData.inviteToAllianceEvents)
end
function User:OnRequestToAllianceEventsChanged(requestToAllianceEvents)
	if requestToAllianceEvents then
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
end
function User:OnInviteAllianceEventsChanged(inviteToAllianceEvents)
	if inviteToAllianceEvents then
        local request_map = {}
        for _, v in ipairs(inviteToAllianceEvents) do
            request_map[v.id] = v
        end

        local remove_requests = {}
        for i, v in ipairs(self:GetInviteEvents()) do
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

        self.invite_events = inviteToAllianceEvents
        self:OnInviteAllianceEvents{
            added = add_requests,
            removed = remove_requests
        }
    end
end
return User


