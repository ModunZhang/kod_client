local Localize = import("..utils.Localize")
local property = import("..utils.property")
local Enum = import("..utils.Enum")
local Flag = import(".Flag")
local AllianceMember = import(".AllianceMember")
local MultiObserver = import(".MultiObserver")
local Alliance = class("Alliance", MultiObserver)
Alliance.LISTEN_TYPE = Enum("OPERATION", "BASIC", "MEMBER", "EVENTS", "JOIN_EVENTS")
local unpack = unpack
local function pack(...)
    return {...}
end
property(Alliance, "power", 0)
property(Alliance, "exp", 0)
property(Alliance, "createTime", 0)
property(Alliance, "kill", 0)
property(Alliance, "level", 0)
property(Alliance, "joinType", "all")
property(Alliance, "maxMembers", 0)
property(Alliance, "describe", "")
property(Alliance, "notice", "")
property(Alliance, "archon", "")
property(Alliance, "memberCount", 0)
function Alliance:ctor(id, name, aliasName, defaultLanguage, terrainType)
    Alliance.super.ctor(self)
    property(self, "id", id)
    property(self, "name", name)
    property(self, "aliasName", aliasName)
    property(self, "defaultLanguage", defaultLanguage or "all")
    property(self, "terrainType", terrainType or "grassLand")
    self.flag = Flag:RandomFlag()
    self.titles = {
        ["member"] = "__member",
        ["supervisor"] = "__supervisor",
        ["quartermaster"] = "__quartermaster",
        ["general"] = "__general",
        ["archon"] = "__archon",
        ["elite"] = "__elite",
    }
    self.members = {}
    self.events = {}
    self.join_events = {}
    self.help_vents = {}
end
function Alliance:DecodeFromJsonData(json_data)
    local alliance = Alliance.new(json_data.id, json_data.name, json_data.tag, json_data.language)
    alliance:SetLevel(json_data.level)
    alliance:SetPower(json_data.power)
    alliance:SetArchon(json_data.archon)
    alliance:SetKill(json_data.kill)
    alliance:SetMemberCount(json_data.members)
    alliance:SetJoinType(json_data.joinType)
    alliance:SetFlag(Flag:DecodeFromJson(json_data.flag))
    return alliance
end
local alliance_title = Localize.alliance_title
function Alliance:GetMemberTitle()
    return self:GetTitles()["member"]
end
function Alliance:GetSupervisorTitle()
    return self:GetTitles()["supervisor"]
end
function Alliance:GetQuarterMasterTitle()
    return self:GetTitles()["quartermaster"]
end
function Alliance:GetGeneralTitle()
    return self:GetTitles()["general"]
end
function Alliance:GetArchonTitle()
    return self:GetTitles()["archon"]
end
function Alliance:GetEliteTitle()
    return self:GetTitles()["elite"]
end
function Alliance:ModifyTitleWithMemberType(member_type, new_name)
    if self.titles[member_type] ~= new_name then
        local old_value = self.titles[member_type]
        self.titles[member_type] = new_name
        self:OnBasicChanged{
            ["title_name"] = {old = old_value, new = new_name}
        }
    end
end
function Alliance:SetTitleNames(title_names)
    for k, v in pairs(title_names) do
        self:ModifyTitleWithMemberType(k, v)
    end
end
function Alliance:GetTitles()
    return LuaUtils:table_map(self.titles, function(k, v)
        if string.sub(v, 1, 2) == "__" then
            dump(alliance_title[k])
            return k, alliance_title[k]
        end
        return k,v
    end)
end
function Alliance:Flag()
    return self.flag
end
function Alliance:SetFlag(flag)
    if not self.flag:IsSameWithFlag(flag) then
        local old = self.flag
        self.flag = flag
        self:OnPropertyChange("flag", old, flag)
    end
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
function Alliance:ReplaceMemberWithNotify(member)
    if not member:IsSameDataWith(self:GetMemeberById(member:Id())) then
        local old = self:ReplaceMember(member)
        self:OnMemberChanged{
            added = pack(),
            removed = pack(),
            changed = pack({old = old, new = member}),
        }
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
    self:SetJoinType("all")
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
        and event1.type == event2.type
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
    table.insert(self.events, 1, event)
    return event
end
function Alliance:TopEvent()
    return self:GetEventByIndex(1)
end
function Alliance:GetEventByIndex(index)
    return self.events[index]
end
function Alliance:GetEvents()
    return self.events
end
function Alliance:CreateEventFromJsonData(json_data)
    return json_data
end
function Alliance:CreateEvent(key, type, category, time, params)
    return {key = key, type = type, category = category, time = time, params = params}
end
function Alliance:OnEventsChanged(changed_map)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.EVENTS, function(listener)
        listener:OnEventsChanged(self, changed_map)
    end)
end
function Alliance:CreateJoinEventsFromJsonData(json_data)
    return json_data
end
function Alliance:CreateJoinEvents(id, name, level, power, requestTime)
    return {id = id, name = name, level = level, power = power, requestTime = requestTime}
end
function Alliance:AddJoinEventWithNotify(event)
    local e = self:AddJoinEvent(event)
    self:OnJoinEventsChanged{
        added = pack(e),
        removed = pack(),
    }
    return e
end
function Alliance:AddJoinEvent(event)
    local join_events = self.join_events
    assert(join_events[event.id] == nil)
    join_events[event.id] = event
    return event
end

function Alliance:RemoveJoinEventWithNotify(event)
    return self:RemoveJoinEventWithNotifyById(event.id)
end
function Alliance:RemoveJoinEventWithNotifyById(id)
    local e = self:RemoveJoinEventById(id)
    self:OnJoinEventsChanged{
        added = pack(),
        removed = pack(e),
    }
    return e
end
function Alliance:RemoveJoinEventById(id)
    local join_events = self.join_events
    local old = join_events[id]
    join_events[id] = nil
    return old
end
function Alliance:RemoveJoinEvent(event)
    return self:RemoveJoinEventById(event.id)
end
function Alliance:GetJoinEventsCount()
    local count = 0
    for _,_ in pairs(self.join_events) do
        count = count + 1
    end
    return count
end
function Alliance:GetJoinEventsMap()
    return self.join_events
end
function Alliance:OnJoinEventsChanged(changed_map)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.JOIN_EVENTS, function(listener)
        listener:OnJoinEventsChanged(self, changed_map)
    end)
end
function Alliance:OnAllianceDataChanged(alliance_data)
    if alliance_data.notice then
        self:SetNotice(alliance_data.notice)
    end
    if alliance_data.desc then
        self:SetDescribe(alliance_data.desc)
    end
    if alliance_data.titles then
        self:SetTitleNames(alliance_data.titles)
    end
    self:OnAllianceBasicInfoChanged(alliance_data.basicInfo)
    self:OnAllianceEventsChanged(alliance_data.events)
    self:OnJoinRequestEventsChanged(alliance_data.joinRequestEvents)
    self:OnHelpEventsChanged(alliance_data.helpEvents)
    self:OnAllianceMemberDataChanged(alliance_data.members)
end
function Alliance:OnAllianceBasicInfoChanged(basicInfo)
    if not basicInfo then return end
    self:SetName(basicInfo.name)
    self:SetAliasName(basicInfo.tag)
    self:SetDefaultLanguage(basicInfo.language)
    self:SetFlag(Flag:DecodeFromJson(basicInfo.flag))
    self:SetTerrainType(basicInfo.terrain)
    self:SetJoinType(basicInfo.joinType)
    self:SetKill(basicInfo.kill)
    self:SetPower(basicInfo.power)
    self:SetExp(basicInfo.exp)
    self:SetLevel(basicInfo.level)
    self:SetCreateTime(basicInfo.createTime)
end
function Alliance:OnAllianceEventsChanged(events)
    if events == nil then return end
    -- 先按从新到旧排序
    table.sort(events, function(a, b)
        return a.time > b.time
    end)
    -- 只会添加新事件，只会在登录的时候才会重新加载所有事件
    -- 先找到最近的事件索引
    local top_event = self:TopEvent() or {time = 0}
    local index = 0
    for i, new_event in ipairs(events) do
        local diff_time = new_event.time - top_event.time
        if diff_time > 0 then
            index = i
        else
            break
        end
    end
    -- 索引大于0才表明有新的事件来临
    local is_new_events_coming = index > 0
    if is_new_events_coming then
        local new_coming_events = {}
        for i = index, 1, -1 do
            local new_event = self:CreateEventFromJsonData(events[i])
            table.insert(new_coming_events, 1, new_event)
            self:PushEventInHead(new_event)
        end
        self:OnEventsChanged{
            pop = pack(),
            push = new_coming_events
        }
    end
end
function Alliance:OnJoinRequestEventsChanged(joinRequestEvents)
    if not joinRequestEvents then return end
    local join_events = self.join_events
    -- 找出新加入的请求
    local mark_map = {}
    local added = {}
    for i, v in ipairs(joinRequestEvents) do
        if not join_events[v.id] then
            table.insert(added, v)
        end
        mark_map[v.id] = true
    end
    -- 找出删除的请求
    local removed = {}
    for k, v in pairs(join_events) do
        if not mark_map[k] then
            table.insert(removed, v)
        end
    end
    -- 更新集合
    join_events = {}
    for i, v in ipairs(joinRequestEvents) do
        join_events[v.id] = v
    end
    self.join_events = join_events


    self:OnJoinEventsChanged{
        added = added,
        removed = removed,
    }
end
function Alliance:OnAllianceMemberDataChanged(members)
    if not members then return end
    -- 先更新成员数量
    self:SetMemberCount(#members)

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
    -- dump(remove_members)

    -- 再找新加入的成员
    local add_members = {}
    for _, v in ipairs(members) do
        if not self:GetMemeberById(v.id) then
            table.insert(add_members, AllianceMember:CreatFromData(v))
        end
    end
    -- dump(add_members)

    -- 成员更新的数据, 直接替换成员数据
    local update_members = {}
    for _, v in ipairs(members) do
        local member = self:GetMemeberById(v.id)
        local new_data = AllianceMember:CreatFromData(v)
        if member and not member:IsSameDataWith(new_data) then
            local old = self:ReplaceMember(new_data)
            table.insert(update_members, {old = old, new = new_data})
        end
    end
    -- dump(update_members)

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
function Alliance:OnOneAllianceMemberDataChanged(member_data)
    self:ReplaceMemberWithNotify(AllianceMember:CreatFromData(member_data))
end
function Alliance:OnHelpEventsChanged(helpEvents)
    dump(helpEvents)
end
function Alliance:GetAllianceArchonMember()
    for k,v in pairs(self.members) do
        if v:IsArchon() then
            return v
        end
    end
    return nil
end
return Alliance






















