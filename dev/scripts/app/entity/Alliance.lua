local property = import("app.utils.property")
local Enum = import("app.utils.Enum")
local Flag = import("app.entity.Flag")
local AllianceMember = import("app.entity.AllianceMember")
local MultiObserver = import("app.entity.MultiObserver")
local Alliance = class("Alliance", MultiObserver)
Alliance.LISTEN_TYPE = Enum("OPERATION", "BASIC", "MEMBER", "EVENTS")

local unpack = unpack
local function pack(...)
    return {...}
end
property(Alliance, "power", 0)
property(Alliance, "exp", 0)
property(Alliance, "createTime", 0)
property(Alliance, "kills", 0)
property(Alliance, "level", 0)
property(Alliance, "joinType", "all")
property(Alliance, "maxMembers", 0)
property(Alliance, "describe", "")
property(Alliance, "notice", "")
function Alliance:ctor(id, name, aliasName, defaultLanguage, terrainType)
    Alliance.super.ctor(self)
    property(self, "id", id)
    property(self, "name", name)
    property(self, "aliasName", aliasName)
    property(self, "defaultLanguage", defaultLanguage or "all")
    property(self, "terrainType", terrainType or "grassLand")
    property(self, "flag", Flag:RandomFlag())
    self.members = {}
    self.events = {}
    self.join_events = {}
    self.help_vents = {}
end
function Alliance:IsDefault()
    return self:Id() == nil
end
function Alliance:OnPropertyChange(property_name, old_value, new_value)
    local is_new_alliance = property_name == "id" and old_value == nil and new_value ~= nil
    if is_new_alliance then
        self:OnOperation("join")
    end
    self:OnBasicChanged{
        [property_name] = {old = old_value, new = new_value}
    }
end
function Alliance:OnBasicChanged(changed_map)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.BASIC, function(listener)
        listener:OnBasicChanged(self, changed_map)
    end)
end
function Alliance:IteratorAllMembers(func)
    for id, v in pairs(self.members) do
        if func(id, v) then
            return
        end
    end
end
function Alliance:ReplaceMember(member)
    local old = self.members[member:Id()]
    self.members[member:Id()] = member
    return old
end
function Alliance:GetMemeberById(id)
    return self.members[id]
end
function Alliance:GetAllMembers()
    return self.members
end
function Alliance:AddMembersWithNotify(member)
    local mbr = self:AddMembers(member)
    self:OnMemberChanged{
        added = pack(mbr),
        removed = pack(),
        changed = pack(),
    }
    return mbr
end
function Alliance:AddMembers(member)
    local members = self.members
    assert(members[member:Id()] == nil)
    members[member:Id()] = member
    return member
end
function Alliance:RemoveMemberByIdWithNotify(id)
    local member = self:RemoveMemberById(id)
    self:OnMemberChanged{
        added = pack(),
        removed = pack(member),
        changed = pack(),
    }
    for _, _ in pairs(self.members) do
        return
    end
    self:Reset()
end
function Alliance:RemoveMemberById(id)
    local members = self.members
    local member = members[id]
    if not member then
        print("玩家不存在!")
        return
    end
    members[id] = nil
    return member
end
function Alliance:OnMemberChanged(changed_map)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.MEMBER, function(listener)
        listener:OnMemberChanged(self, changed_map)
    end)
end
function Alliance:Reset()
    self:SetId(nil)
    self.members = {}
    self.events = {}
    self.join_events = {}
    self.help_vents = {}
    self:OnOperation("quit")
end
function Alliance:OnOperation(operation_type)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.OPERATION, function(listener)
        listener:OnOperation(self, operation_type)
    end)
end
function Alliance:IsSameEventWithTwo(event1, event2)
    return event1.key == event2.key
        and event1.event_type == event2.event_type
        and event1.category == event2.category
        and event1.time == event2.time
end
function Alliance:PopLastEventWithNotify()
    local event = self:PopLastEvent()
    self:OnEventsChanged{
        pop = pack(event),
        push = pack()
    }
    return event
end
function Alliance:PopLastEvent()
    return table.remove(self.events)
end
function Alliance:PushEventInHeadWithNotify(event)
    local e = self:PushEventInHead(event)
    self:OnEventsChanged{
        pop = pack(),
        push = pack(e)
    }
    return e
end
function Alliance:PushEventInHead(event)
    table.insert(self.events, event)
    return event
end
function Alliance:GetEventByIndex(index)
    return self.events[index]
end
function Alliance:GetEvents()
    return self.events
end
function Alliance:CreateEvent(key, event_type, category, time, params)
    return {key = key, event_type = event_type, category = category, time = time, params = params}
end
function Alliance:OnEventsChanged(changed_map)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.EVENTS, function(listener)
        listener:OnEventsChanged(self, changed_map)
    end)
end
function Alliance:OnAllianceDataChanged(alliance_data)
    local members = alliance_data.members
    if members then
        local function find_members_with_id(id)
            for _, v in ipairs(members) do
                if v.id == id then
                    return v
                end
            end
        end
        -- 先找退出的成员
        local remove_members = {}
        self:IteratorAllMembers(function(id, member)
            if not find_members_with_id(id) then
                table.insert(remove_members, member)
            end
        end)
        dump(remove_members)

        -- 再找新加入的成员
        local add_members = {}
        for _, v in ipairs(members) do
            if not self:GetMemeberById(v.id) then
                table.insert(add_members, AllianceMember:CreatFromJsonData(v))
            end
        end
        dump(add_members)

        -- 成员更新的数据, 直接替换成员数据
        local update_members = {}
        for _, v in ipairs(members) do
            local member = self:GetMemeberById(v.id)
            local new_data = AllianceMember:CreatFromJsonData(v)
            if member and not member:IsSameDataWith(new_data) then
                self:ReplaceMember(new_data)
                table.insert(update_members, new_data)
            end
        end
        dump(update_members)

        -- 开始真正删除成员了
        for _, v in ipairs(remove_members) do
            self:RemoveMemberById(v.id)
        end

        -- 开始真正添加成员了
        for _, v in ipairs(add_members) do
            self:AddMembers(v)
        end

        local need_notify = #remove_members > 0 or #add_members > 0 or #update_members > 0
        if need_notify then
            self:OnMemberChanged{
                added = add_members,
                removed = remove_members,
                changed = update_members,
            }
        end
    end
end



return Alliance







