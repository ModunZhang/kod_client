local Localize = import("..utils.Localize")
local property = import("..utils.property")
local Enum = import("..utils.Enum")
local Flag = import(".Flag")
local AllianceShrine = import(".AllianceShrine")
local AllianceMoonGate = import(".AllianceMoonGate")
local AllianceMap = import(".AllianceMap")
local HelpEvent = import(".HelpEvent")
local memberMeta = import(".memberMeta")
local MultiObserver = import(".MultiObserver")
local MarchAttackEvent = import(".MarchAttackEvent")
local MarchAttackReturnEvent = import(".MarchAttackReturnEvent")
local AllianceItemsManager = import(".AllianceItemsManager")
local Alliance = class("Alliance", MultiObserver)
local VillageEvent = import(".VillageEvent")
local AllianceBelvedere = import(".AllianceBelvedere")
--注意:突袭用的MarchAttackEvent 所以使用OnAttackMarchEventTimerChanged
Alliance.LISTEN_TYPE = Enum("OPERATION", "BASIC", "MEMBER", "EVENTS", "JOIN_EVENTS", "HELP_EVENTS","ALL_HELP_EVENTS","FIGHT_REQUESTS","FIGHT_REPORTS",
    "OnAttackMarchEventDataChanged","OnAttackMarchEventTimerChanged","OnAttackMarchReturnEventDataChanged","ALLIANCE_FIGHT"
    ,"OnStrikeMarchEventDataChanged","OnStrikeMarchReturnEventDataChanged","OnVillageEventsDataChanged","OnVillageEventTimer","COUNT_INFO",
    "VILLAGE_LEVELS_CHANGED","OnMarchEventRefreshed")
local unpack = unpack
property(Alliance, "power", 0)
property(Alliance, "createTime", 0)
property(Alliance, "kill", 0)
property(Alliance, "honour", 0)
property(Alliance, "joinType", "all")
property(Alliance, "maxMembers", 0)
property(Alliance, "describe", "")
property(Alliance, "notice", "")
property(Alliance, "archon", "")
property(Alliance, "memberCount", 0)
property(Alliance, "status", "")
property(Alliance, "statusStartTime", 0)
property(Alliance, "statusFinishTime", 0)
property(Alliance, "fightPosition", "")
function Alliance:ctor(id, name, aliasName, defaultLanguage, terrainType)
    Alliance.super.ctor(self)
    property(self, "id", id)
    property(self, "name", name)
    property(self, "aliasName", aliasName)
    property(self, "defaultLanguage", defaultLanguage or "all")
    property(self, "terrain", terrainType or "grassLand")
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
    self.help_events = {}
    self.fight_requests = {}
    self.alliance_fight_reports = {}
    self.countInfo = {}
    self.allianceFight = {}
    self.alliance_map = AllianceMap.new(self)
    self.alliance_shrine = AllianceShrine.new(self)
    -- 村落等级
    self.villageLevels = {}
    --行军事件
    self.attackMarchEvents = {}
    self.attackMarchReturnEvents = {}
    self.strikeMarchEvents = {}
    self.strikeMarchReturnEvents = {}
    --村落采集
    self.villageEvents = {}
    self.alliance_villages = {}
    self.alliance_belvedere = AllianceBelvedere.new(self)
    self:SetNeedUpdateEnemyAlliance(false)

    -- 联盟道具管理
    self.items_manager = AllianceItemsManager.new()
end
function Alliance:GetAllianceBelvedere()
    return self.alliance_belvedere
end
function Alliance:GetAllianceShrine()
    return self.alliance_shrine
end
function Alliance:GetAllianceFight()
    return self.allianceFight
end
function Alliance:GetVillageLevels()
    return self.villageLevels
end
function Alliance:GetItemsManager()
    return self.items_manager
end
function Alliance:ResetAllListeners()
    self.alliance_map:ClearAllListener()
    self:ClearAllListener()
end
function Alliance:GetAllianceMap()
    return self.alliance_map
end
function Alliance:DecodeFromJsonData(json_data)
    local alliance = Alliance.new(json_data.id, json_data.name, json_data.tag, json_data.language)
    alliance:SetHonour(json_data.honour)
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
    if self.flag:IsDifferentWith(flag) then
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
function Alliance:GetMemeberById(id)
    return self.members[id]
end
function Alliance:GetAllMembers()
    return self.members
end
function Alliance:GetMembersCount()
    local count = 0
    for _,v in pairs(self:GetAllMembers()) do
        count = count + 1
    end
    return count
end
function Alliance:OnMemberChanged()
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.MEMBER, function(listener)
        listener:OnMemberChanged(self)
    end)
end
function Alliance:GetFightRequest()
    return self.fight_requests
end
function Alliance:GetFightRequestPlayerNum()
    return #self.fight_requests
end
function Alliance:IsRequested()
    for k,v in pairs(self.fight_requests) do
        print("User:Id()=",User:Id(),"fight request=",v)
        if v == User:Id() then
            return true
        end
    end
end
function Alliance:GetAllianceFightReports()
    return self.alliance_fight_reports
end
function Alliance:GetLastAllianceFightReports()
    return self.alliance_fight_reports[1]
end
function Alliance:GetOurLastAllianceFightReportsData()
    local last = self:GetLastAllianceFightReports()
    if last then
        return self.id == last.attackAllianceId and last.attackAlliance or last.defenceAlliance
    end
end
function Alliance:GetEnemyLastAllianceFightReportsData()
    local last = self:GetLastAllianceFightReports()
    if last then
        return self.id == last.attackAllianceId and last.defenceAlliance or last.attackAlliance
    end
end
function Alliance:GetAllHelpEvents()
    return self.help_events
end
function Alliance:AddHelpEvent(event)
    local help_events = self.help_events
    assert(help_events[event:Id()] == nil)
    help_events[event:Id()] = event
    return event
end
function Alliance:RemoveHelpEvent(event)
    return self:RemoveHelpEventById(event:Id())
end
function Alliance:RemoveHelpEventById(id)
    local help_events = self.help_events
    local old = help_events[id]
    help_events[id] = nil
    return old
end
function Alliance:EditHelpEvent(event)
    local help_events = self.help_events
    help_events[event:Id()] = event
    return event
end
function Alliance:ReFreashHelpEvent(changed_help_event)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.HELP_EVENTS, function(listener)
        listener:OnHelpEventChanged(changed_help_event)
    end)

end
function Alliance:HasBeenRequestedToHelpSpeedup(eventId)
    if self.help_events then
        for _,h_event in pairs(self.help_events) do
            if h_event:GetPlayerData():Id() == User:Id() and h_event:GetEventData():Id() == eventId then
                return true
            end
        end
    end
end
-- 获取其他所有联盟成员的申请帮助事件数量
function Alliance:GetOtherRequestEventsNum()
    local request_num = 0
    if self.help_events then
        for _,h_event in pairs(self.help_events) do
            if h_event:GetPlayerData():Id() ~= User:Id() then
                request_num = request_num + 1
            end
        end
    end
    return request_num
end
function Alliance:Reset()
    if self:NeedUpdateEnemyAlliance() then
        self:GetEnemyAlliance():Reset()
    end
    self:GetAllianceBelvedere():Reset()
    for k,v in pairs(self) do
        if type(v) == 'string' then
            self[k] = ""
        elseif type(v) == 'number' then
            self[k] = 0
        end
    end
    self:SetId(nil)
    self:SetJoinType("all")
    self.members = {}
    self.events = {}
    self.join_events = {}
    self.help_events = {}
    self.alliance_villages = {}
    self.villageLevels = {}
    self:OnOperation("quit")
    self.alliance_map:Reset()
    self.alliance_shrine:Reset()
    self:ResetMarchEvent()
    self:ResetVillageEvents()
end
function Alliance:OnOperation(operation_type)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.OPERATION, function(listener)
        listener:OnOperation(self, operation_type)
    end)
end
function Alliance:GetEvents()
    return self.events
end
function Alliance:GetCountInfo()
    return self.countInfo
end
function Alliance:OnEventsChanged()
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.EVENTS, function(listener)
        listener:OnEventsChanged(self)
    end)
end

function Alliance:GetJoinEvents()
    return self.join_events
end
function Alliance:OnJoinEventsChanged()
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.JOIN_EVENTS, function(listener)
        listener:OnJoinEventsChanged(self)
    end)
end
function Alliance:OnAllianceDataChanged(alliance_data,refresh_time,deltaData)
    if self:NeedUpdateEnemyAlliance() and alliance_data.enemyAllianceDoc then
        if deltaData then
            self:UpdateEnemyAlliance(alliance_data.enemyAllianceDoc,alliance_data.basicInfo and alliance_data.basicInfo.status or nil,
                deltaData.enemyAllianceDoc or {})
        else
            self:UpdateEnemyAlliance(alliance_data.enemyAllianceDoc,alliance_data.basicInfo and alliance_data.basicInfo.status or nil,deltaData)
        end

    end
    if alliance_data.notice then
        self:SetNotice(alliance_data.notice)
    end
    if alliance_data.desc then
        self:SetDescribe(alliance_data.desc)
    end
    if alliance_data.titles then
        self:SetTitleNames(alliance_data.titles)
    end
    self:OnAllianceBasicInfoChangedFirst(alliance_data,deltaData)
    self:OnAllianceFightReportsChanged(alliance_data)

    self:OnAllianceMemberDataChanged(alliance_data,deltaData)

    self:OnAllianceEventsChanged(alliance_data,deltaData)

    self:OnJoinRequestEventsChanged(alliance_data,deltaData)

    self:OnHelpEventsChanged(alliance_data,deltaData)

    self:OnAllianceCountInfoChanged(alliance_data.countInfo)
    
    self:OnAllianceFightChanged(alliance_data.allianceFight)

    self:OnAllianceFightRequestsChanged(alliance_data)

    self:OnVillageLevelsChanged(alliance_data.villageLevels)
    self.alliance_shrine:OnAllianceDataChanged(alliance_data,deltaData)
    --TODO:
    self.alliance_map:OnAllianceDataChanged(alliance_data)

    self:OnAttackMarchEventsDataChanged(alliance_data,deltaData)

    self:OnAttackMarchReturnEventsDataChanged(alliance_data,deltaData)

    self:OnStrikeMarchEventsDataChanged(alliance_data,deltaData)

    self:OnStrikeMarchReturnEventsDataChanged(alliance_data,deltaData)

    self:OnVillageEventsDataChanged(alliance_data,deltaData)

    self:DecodeAllianceVillages(alliance_data,deltaData)

    -- 联盟道具管理 TODO:
    self.items_manager:OnItemsChanged(alliance_data.items)
    self.items_manager:__OnItemsChanged(alliance_data.__items)
    self.items_manager:OnItemLogsChanged(alliance_data.itemLogs)
    self.items_manager:__OnItemsLogsChanged(alliance_data.__itemLogs)

end

function Alliance:OnAllianceBasicInfoChangedFirst(alliance_data,deltaData)
    if not alliance_data.basicInfo then return end
    local basicInfo = alliance_data.basicInfo
    self:SetName(basicInfo.name)
    self:SetAliasName(basicInfo.tag)
    self:SetDefaultLanguage(basicInfo.language)
    self:SetFlag(Flag:DecodeFromJson(basicInfo.flag))
    self:SetTerrain(basicInfo.terrain)
    self:SetJoinType(basicInfo.joinType)
    self:SetKill(basicInfo.kill)
    self:SetPower(basicInfo.power)
    self:SetHonour(basicInfo.honour)
    self:SetCreateTime(basicInfo.createTime)
    self:SetStatus(basicInfo.status)
    self:SetStatusStartTime(basicInfo.statusStartTime)
    self:SetStatusFinishTime(basicInfo.statusFinishTime)
end
function Alliance:OnAllianceEventsChanged(alliance_data,deltaData)
    if not alliance_data.events then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.events ~= nil
    if is_fully_update then
        self.events = alliance_data.events
        self:OnEventsChanged()
    end
    if is_delta_update then
        self:OnEventsChanged()
    end
end
function Alliance:OnJoinRequestEventsChanged(alliance_data,deltaData)
    if not alliance_data.joinRequestEvents then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.joinRequestEvents ~= nil
    if is_fully_update then
        self.join_events = alliance_data.joinRequestEvents
        self:OnJoinEventsChanged()
    end
    if is_delta_update then
        self:OnJoinEventsChanged()
    end
    
end
function Alliance:OnAllianceMemberDataChanged(alliance_data,deltaData)
    if not alliance_data.members then return end
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.members ~= nil
    if is_fully_update then
        self.members = {}
        for _,v in ipairs(alliance_data.members) do
            self.members[v.id] = setmetatable(v, memberMeta)
        end
        self:OnMemberChanged()
    end
    if is_delta_update then
        self:OnMemberChanged()
    end
end
function Alliance:OnAllianceFightRequestsChanged(alliance_data)
    if alliance_data.fightRequests then
        self.fight_requests = alliance_data.fightRequests
    end
    if alliance_data.__fightRequests then
        for k,v in pairs(alliance_data.__fightRequests) do
            if v.type == "add" then
                table.insert(self.fight_requests,v.data)
            end
        end
        self:NotifyListeneOnType(Alliance.LISTEN_TYPE.FIGHT_REQUESTS, function(listener)
            listener:OnAllianceFightRequestsChanged(#self.fight_requests)
        end)
    end
end
function Alliance:OnAllianceFightReportsChanged(alliance_data)
    if alliance_data.allianceFightReports then
        self.alliance_fight_reports = alliance_data.allianceFightReports
        table.sort( self.alliance_fight_reports, function(a, b)
            return a.fightTime > b.fightTime
        end )
    end
    if alliance_data.__allianceFightReports then
        local add = {}
        local remove = {}
        for k,v in pairs(alliance_data.__allianceFightReports) do
            if v.type == "add" then
                table.insert(self.alliance_fight_reports,v.data)
                table.insert(add,v.data)
            elseif v.type == "remove" then
                for index,old in pairs(self.alliance_fight_reports) do
                    if old.id == v.data.id then
                        table.remove(self.alliance_fight_reports,index)
                        table.insert(remove,v.data)
                    end
                end
            end
        end
        table.sort( self.alliance_fight_reports, function(a, b)
            return a.fightTime > b.fightTime
        end )
        self:NotifyListeneOnType(Alliance.LISTEN_TYPE.FIGHT_REPORTS, function(listener)
            listener:OnAllianceFightReportsChanged({add = add,remove=remove})
        end)
    end

end
function Alliance:OnHelpEventsChanged(alliance_data,deltaData)
    if not alliance_data.helpEvents then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.helpEvents ~= nil
    if is_fully_update then
        for _,v in pairs(alliance_data.helpEvents) do
            self.help_events[v.id] = HelpEvent.new():UpdateData(v)
        end
        self:NotifyListeneOnType(Alliance.LISTEN_TYPE.ALL_HELP_EVENTS, function(listener)
            listener:OnAllHelpEventChanged(self.help_events)
        end)
    end
    if is_delta_update then
        local added = {}
        local removed = {}
        local edit = {}
        GameUtils:Handler_DeltaData_Func(
            deltaData.helpEvents,
            function(help_event)
                local helpEvent = HelpEvent.new():UpdateData(help_event)
                self:AddHelpEvent(helpEvent)
                table.insert(added, helpEvent)
            end,
            function(help_event)
                local helpEvent = HelpEvent.new():UpdateData(help_event)
                self:EditHelpEvent(helpEvent)
                table.insert(edit, helpEvent)
            end,
            function(help_event)
                local helpEvent = HelpEvent.new():UpdateData(help_event)
                self:RemoveHelpEvent(helpEvent)
                table.insert(removed, helpEvent)
            end
        )
        self:ReFreashHelpEvent{
            added = added,
            removed = removed,
            edit = edit,
        }
    end
end
function Alliance:GetAllianceArchonMember()
    for k,v in pairs(self.members) do
        if v:IsArchon() then
            return v
        end
    end
    return nil
end

function Alliance:OnTimer(current_time)
    self:GetAllianceShrine():OnTimer(current_time)
    self:IteratorAttackMarchEvents(function(attackMarchEvent)
        attackMarchEvent:OnTimer(current_time)
    end)
    self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
        attackMarchReturnEvent:OnTimer(current_time)
    end)
    self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
        strikeMarchEvent:OnTimer(current_time)
    end)
    self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
        strikeMarchReturnEvent:OnTimer(current_time)
    end)
    self:IteratorVillageEvents(function(villageEvent)
        villageEvent:OnTimer(current_time)
    end)
    if self:NeedUpdateEnemyAlliance() then
        self:GetEnemyAlliance():OnTimer(current_time)
    end
end

--行军事件
--------------------------------------------------------------------------------
function Alliance:OnMarchEventTimer(attackMarchEvent)
    self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnAttackMarchEventTimerChanged,attackMarchEvent)
    if self:GetAllianceBelvedere()['OnAttackMarchEventTimerChanged'] then
        self:GetAllianceBelvedere():OnAttackMarchEventTimerChanged(attackMarchEvent)
    end
end

function Alliance:CallEventsChangedListeners(LISTEN_TYPE,changed_map)
    self:NotifyListeneOnType(LISTEN_TYPE, function(listener)
        listener[Alliance.LISTEN_TYPE[LISTEN_TYPE]](listener,changed_map)
    end)
    if self:GetAllianceBelvedere()[Alliance.LISTEN_TYPE[LISTEN_TYPE]] then
        self:GetAllianceBelvedere()[Alliance.LISTEN_TYPE[LISTEN_TYPE]](self:GetAllianceBelvedere(),changed_map)
    end
end

function Alliance:GetAttackMarchEvents(march_type)
    local r = {}
    if not march_type then
        self:IteratorAttackMarchEvents(function(attackMarchEvent)
            table.insert(r,attackMarchEvent)
        end)
    else
        self:IteratorAttackMarchEvents(function(attackMarchEvent)
            if attackMarchEvent:MarchType() == march_type then
                table.insert(r,attackMarchEvent)
            end
        end)
    end
    return r
end

function Alliance:GetAttackMarchReturnEvents(march_type)
    local r = {}
    if not march_type then
        self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
            table.insert(r,attackMarchReturnEvent)
        end)
    else
        self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
            if attackMarchReturnEvent:MarchType() == march_type then
                table.insert(r,attackMarchReturnEvent)
            end
        end)
    end
    return r
end

function Alliance:OnAttackMarchEventsDataChanged(alliance_data,deltaData)
    if not alliance_data.attackMarchEvents then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.attackMarchEvents ~= nil
    if is_fully_update then
        self:IteratorAttackMarchEvents(function(attackMarchEvent)
            attackMarchEvent:Reset()
        end)
        self.attackMarchEvents = {}
        for _,v in ipairs(alliance_data.attackMarchEvents) do
            local attackMarchEvent = MarchAttackEvent.new()
            attackMarchEvent:UpdateData(v)
            self.attackMarchEvents[attackMarchEvent:Id()] = attackMarchEvent
            attackMarchEvent:AddObserver(self)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnMarchEventRefreshed,"OnAttackMarchEventsDataChanged")
    end

    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.attackMarchEvents
            ,function(event_data)
                local attackMarchEvent = MarchAttackEvent.new()
                attackMarchEvent:UpdateData(event_data)
                self.attackMarchEvents[attackMarchEvent:Id()] = attackMarchEvent
                attackMarchEvent:AddObserver(self)
                return attackMarchEvent
            end
            ,function(event_data)
                if self.attackMarchEvents[event_data.id] then
                    local attackMarchEvent = self.attackMarchEvents[event_data.id]
                    attackMarchEvent:UpdateData(event_data)
                    return attackMarchEvent
                end
            end
            ,function(event_data)
                if self.attackMarchEvents[event_data.id] then
                    local attackMarchEvent = self.attackMarchEvents[event_data.id]
                    attackMarchEvent:Reset()
                    self.attackMarchEvents[event_data.id] = nil
                    attackMarchEvent = MarchAttackEvent.new()
                    attackMarchEvent:UpdateData(event_data)
                    return attackMarchEvent
                end
            end
     )
     self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged,GameUtils:pack_event_table(changed_map))
    end
end

function Alliance:IteratorAttackMarchEvents(func)
    for _,attackMarchEvent in pairs(self.attackMarchEvents) do
        func(attackMarchEvent)
    end
end


function Alliance:OnAttackMarchReturnEventsDataChanged(alliance_data,deltaData)
    if not alliance_data.attackMarchReturnEvents then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.attackMarchReturnEvents ~= nil
    if is_fully_update then
        self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
            attackMarchReturnEvent:Reset()
        end)
        self.attackMarchReturnEvents = {}
        for _,v in ipairs(alliance_data.attackMarchReturnEvents) do
            local attackMarchReturnEvent = MarchAttackReturnEvent.new()
            attackMarchReturnEvent:UpdateData(v)
            self.attackMarchReturnEvents[attackMarchReturnEvent:Id()] = attackMarchReturnEvent
            attackMarchReturnEvent:AddObserver(self)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnMarchEventRefreshed,"OnAttackMarchReturnEventDataChanged")
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.attackMarchReturnEvents
            ,function(event_data)
                local attackMarchReturnEvent = MarchAttackReturnEvent.new()
                attackMarchReturnEvent:UpdateData(event_data)
                self.attackMarchReturnEvents[attackMarchReturnEvent:Id()] = attackMarchReturnEvent
                attackMarchReturnEvent:AddObserver(self)
                return attackMarchReturnEvent
            end
            ,function(event_data)
                if self.attackMarchReturnEvents[event_data.id] then
                    local attackMarchReturnEvent = self.attackMarchReturnEvents[event_data.id]
                    attackMarchReturnEvent:UpdateData(event_data)
                    return attackMarchReturnEvent
                end
            end
            ,function(event_data)
                if self.attackMarchReturnEvents[event_data.id] then
                    local attackMarchReturnEvent = self.attackMarchReturnEvents[event_data.id]
                    attackMarchReturnEvent:Reset()
                    self.attackMarchReturnEvents[event_data.id] = nil
                    attackMarchReturnEvent = MarchAttackReturnEvent.new()
                    attackMarchReturnEvent:UpdateData(event_data)
                    return attackMarchReturnEvent
                end
            end
        )
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged,GameUtils:pack_event_table(changed_map))
    end
end

function Alliance:IteratorAttackMarchReturnEvents(func)
    for _,attackMarchReturnEvent in pairs(self.attackMarchReturnEvents) do
        func(attackMarchReturnEvent)
    end
end

--重置行军事件
function Alliance:ResetMarchEvent()
    self:IteratorAttackMarchEvents(function(attackMarchEvent)
        attackMarchEvent:Reset()
    end)
    self.attackMarchEvents = {}
    self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
        attackMarchReturnEvent:Reset()
    end)
    self.attackMarchReturnEvents = {}

    self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
        strikeMarchEvent:Reset()
    end)
    self.strikeMarchEvents = {}
    self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
        strikeMarchReturnEvent:Reset()
    end)
    self.strikeMarchReturnEvents = {}
end

function Alliance:OnAllianceCountInfoChanged(countInfo)
    if not countInfo then
        return
    end
    self.countInfo = countInfo
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.COUNT_INFO, function(listener)
        listener:OnAllianceCountInfoChanged(self,self.countInfo)
    end)
end
function Alliance:OnAllianceFightChanged(allianceFight)
    if not allianceFight or allianceFight == json.null then return end
    for k,v in pairs(allianceFight) do
        if string.find(k,"__") then
            local key = string.sub(k,3,-1)
            for _,change in pairs(v) do
                if change.type == "add" then
                    table.insert(self.allianceFight[key], change.data)
                elseif change.type == "edit" then
                    for index,playerKill in pairs(self.allianceFight[key]) do
                        if playerKill.id==change.data.id then
                            self.allianceFight[key][index] = change.data
                        end
                    end
                end
            end
        else
            self.allianceFight[k] = v
        end
    end
    if not LuaUtils:table_empty(allianceFight) then
        local mergeStyle = self:GetAllianceFight()['mergeStyle']
        local isAttacker = self:Id() == self:GetAllianceFight()['attackAllianceId']
        if isAttacker then
            self:SetFightPosition(mergeStyle)
        else
            self:SetFightPosition(self:GetReversedPosition(mergeStyle))
        end
    else
        self.allianceFight = {}
        self:SetFightPosition("")
    end
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.ALLIANCE_FIGHT, function(listener)
        listener:OnAllianceFightChanged(self,self.allianceFight)
    end)
end
function Alliance:OnVillageLevelsChanged(villageLevels)
    if not villageLevels then return end
    local changed_map = {}
    for k,v in pairs(villageLevels) do
        self.villageLevels[k] = v
        changed_map[k] = v
    end
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.VILLAGE_LEVELS_CHANGED, function(listener)
        listener:OnVillageLevelsChanged(self,changed_map)
    end)
end
function Alliance:GetReversedPosition(p)
    if p == 'left' then
        return 'right'
    elseif p == 'right' then
        return 'left'
    elseif p == 'top' then
        return 'bottom'
    elseif p == 'bottom' then
        return 'top'
    end
end

function Alliance:GetMyAllianceFightCountData()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.attackAllianceCountData or allianceFight.defenceAllianceCountData
end
function Alliance:GetEnemyAllianceFightCountData()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.defenceAllianceCountData or allianceFight.attackAllianceCountData
end
function Alliance:GetMyAllianceFightPlayerKills()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.attackPlayerKills or allianceFight.defencePlayerKills
end
function Alliance:GetEnemyAllianceFightPlayerKills()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.defencePlayerKills or allianceFight.attackPlayerKills
end

function Alliance:OnStrikeMarchEventsDataChanged(alliance_data,deltaData)
    if not alliance_data.strikeMarchEvents then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.strikeMarchEvents ~= nil
    if is_fully_update then
        self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
            strikeMarchEvent:Reset()
        end)
        self.strikeMarchEvents = {}
        for _,v in ipairs(alliance_data.strikeMarchEvents) do
            local strikeMarchEvent = MarchAttackEvent.new()
            strikeMarchEvent:UpdateData(v)
            self.strikeMarchEvents[strikeMarchEvent:Id()] = strikeMarchEvent
            strikeMarchEvent:AddObserver(self)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnMarchEventRefreshed,"OnStrikeMarchEventDataChanged")
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.strikeMarchEvents
            ,function(event_data)
                local strikeMarchEvent = MarchAttackEvent.new()
                strikeMarchEvent:UpdateData(event_data)
                self.strikeMarchEvents[strikeMarchEvent:Id()] = strikeMarchEvent
                strikeMarchEvent:AddObserver(self)
                return strikeMarchEvent
            end
            ,function(event_data)
                if self.strikeMarchEvents[event_data.id] then
                    local strikeMarchEvent = self.strikeMarchEvents[event_data.id]
                    strikeMarchEvent:UpdateData(event_data)
                    return strikeMarchEvent
                end
            end
            ,function(event_data)
                if self.strikeMarchEvents[event_data.id] then
                    local strikeMarchEvent = self.strikeMarchEvents[event_data.id]
                    strikeMarchEvent:Reset()
                    self.strikeMarchEvents[event_data.id] = nil
                    strikeMarchEvent = MarchAttackEvent.new()
                    strikeMarchEvent:UpdateData(event_data)
                    return strikeMarchEvent
                end
            end
        )
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged,GameUtils:pack_event_table(changed_map))
    end
end

function Alliance:IteratorStrikeMarchEvents(func)
    for _,v in pairs(self.strikeMarchEvents) do
        func(v)
    end
end

function Alliance:OnStrikeMarchReturnEventsDataChanged(alliance_data,deltaData)
    if not alliance_data.strikeMarchReturnEvents then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.strikeMarchReturnEvents ~= nil
    if is_fully_update then
        self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
            strikeMarchReturnEvent:Reset()
        end)
        self.strikeMarchReturnEvents = {}
        for _,v in ipairs(alliance_data.strikeMarchReturnEvents) do
            local strikeMarchReturnEvent = MarchAttackReturnEvent.new()
            strikeMarchReturnEvent:UpdateData(v)
            self.strikeMarchReturnEvents[strikeMarchReturnEvent:Id()] = strikeMarchReturnEvent
            strikeMarchReturnEvent:AddObserver(self)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnMarchEventRefreshed,"OnStrikeMarchReturnEventDataChanged")
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.strikeMarchReturnEvents
            ,function(event_data)
                local strikeMarchReturnEvent = MarchAttackReturnEvent.new()
                strikeMarchReturnEvent:UpdateData(event_data)
                self.strikeMarchReturnEvents[strikeMarchReturnEvent:Id()] = strikeMarchReturnEvent
                strikeMarchReturnEvent:AddObserver(self)
                return strikeMarchReturnEvent
            end
            ,function(event_data)
                if self.strikeMarchReturnEvents[event_data.id] then
                    local strikeMarchReturnEvent = self.strikeMarchReturnEvents[event_data.id]
                    strikeMarchReturnEvent:UpdateData(event_data)
                    return strikeMarchReturnEvent
                end
            end
            ,function(event_data)
                if self.strikeMarchReturnEvents[event_data.id] then
                    local strikeMarchReturnEvent = self.strikeMarchReturnEvents[event_data.id]
                    strikeMarchReturnEvent:Reset()
                    self.strikeMarchReturnEvents[event_data.id] = nil
                    strikeMarchReturnEvent = MarchAttackReturnEvent.new()
                    strikeMarchReturnEvent:UpdateData(event_data)
                    return strikeMarchReturnEvent
                end
            end
        )
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged,GameUtils:pack_event_table(changed_map))
    end
end

function Alliance:IteratorStrikeMarchReturnEvents(func)
    for _,v in pairs(self.strikeMarchReturnEvents) do
        func(v)
    end
end

function Alliance:GetStrikeMarchEvents(march_type)
    local r = {}
    if not march_type then
        self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
            table.insert(r,strikeMarchEvent)
        end)
    else
        self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
            if strikeMarchEvent:MarchType() == march_type then
                table.insert(r,strikeMarchEvent)
            end
        end)
    end
    return r
end

function Alliance:CheckStrikeVillageHaveTarget(village_id)
    local strikeEvents = self:GetStrikeMarchEvents("village")
    for _,strikeEvent in ipairs(strikeEvents) do
        if strikeEvent:GetPlayerRole() == strikeEvent.MARCH_EVENT_PLAYER_ROLE.SENDER then
            return true
        end
    end
    return false
end

function Alliance:GetStrikeMarchReturnEvents(march_type)
    local r = {}
    if not march_type then
        self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
            table.insert(r,strikeMarchReturnEvent)
        end)
    else
        self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
            if strikeMarchReturnEvent:MarchType() == march_type then
                table.insert(r,strikeMarchReturnEvent)
            end
        end)
    end
    return r
end

function Alliance:CheckHelpDefenceMarchEventsHaveTarget(memeberId)
    local helpEvents = self:GetAttackMarchEvents("helpDefence")
    for _,attackEvent in ipairs(helpEvents) do
        if attackEvent:GetPlayerRole() == attackEvent.MARCH_EVENT_PLAYER_ROLE.SENDER
            and attackEvent:GetDefenceData().id == memeberId then
            return true
        end
    end
    return false
end

function Alliance:GetSelf()
    return self:GetMemeberById(DataManager:getUserData()._id)
end

--这里会取敌方的的村落信息，因为可能是占领的敌方村落
------------------------------------------------------------------------------------------
function Alliance:OnVillageEventTimer(villageEvent)
    local village = self:GetAllianceVillageInfos()[villageEvent:VillageData().id]
    if not village then
        village = self:GetEnemyAlliance():GetAllianceVillageInfos()[villageEvent:VillageData().id]
    end
    if village then
        if villageEvent:GetTime() >= 0 then
            local left_resource = village.resource - villageEvent:CollectCount()
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.OnVillageEventTimer, function(listener)
                listener:OnVillageEventTimer(villageEvent,left_resource)
            end)
            if self:GetAllianceBelvedere()['OnVillageEventTimer'] then
                self:GetAllianceBelvedere():OnVillageEventTimer(villageEvent,left_resource)
            end
        end
    end
end

--村落采集事件
function Alliance:OnVillageEventsDataChanged(alliance_data,deltaData)
    if not alliance_data.villageEvents then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.villageEvents ~= nil
    if is_fully_update then
        local removed = {}
        self:IteratorVillageEvents(function(villageEvent)
            table.insert(removed,villageEvent)
            villageEvent:Reset()
        end)
        self.villageEvents = {}
        for _,v in ipairs(alliance_data.villageEvents) do
            local villageEvent = VillageEvent.new()
            villageEvent:UpdateData(v)
            self.villageEvents[villageEvent:Id()] = villageEvent
            villageEvent:AddObserver(self)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnVillageEventsDataChanged,{removed = removed})
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.villageEvents
            ,function(event_data)
                local villageEvent = VillageEvent.new()
                villageEvent:UpdateData(event_data)
                self.villageEvents[villageEvent:Id()] = villageEvent
                villageEvent:AddObserver(self)
                return villageEvent
            end
            ,function(event_data)
                if self.villageEvents[event_data.id] then
                    local villageEvent = self.villageEvents[event_data.id]
                    villageEvent:UpdateData(event_data)
                    return villageEvent
                end
            end
            ,function(event_data)
                if self.villageEvents[event_data.id] then
                    local villageEvent = self.villageEvents[event_data.id]
                    villageEvent:Reset()
                    self.villageEvents[villageEvent:Id()] = nil
                    villageEvent = VillageEvent.new()
                    villageEvent:UpdateData(event_data)
                    return villageEvent
                end
            end
        )
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnVillageEventsDataChanged,GameUtils:pack_event_table(changed_map))
    end
end

function Alliance:IteratorVillageEvents(func)
    for _,v in pairs(self.villageEvents) do
        func(v)
    end
end
function Alliance:ResetVillageEvents()
    self:IteratorVillageEvents(function(villageEvent)
        villageEvent:Reset()
    end)
    self.villageEvents = {}
end

function Alliance:CheckVillageMarchEventHaveTarget(village_Id)
    local villageEvents = self:GetAttackMarchEvents("village")
    for _,attackEvent in ipairs(villageEvents) do
        if attackEvent:GetPlayerRole() == attackEvent.MARCH_EVENT_PLAYER_ROLE.SENDER
            and attackEvent:GetDefenceData().id == village_Id then
            return true
        end
    end
    return false
end

--有id为指定事件 没有id时获取所有采集事件
function Alliance:GetVillageEvent(id)
    if id then
        return self.villageEvents[id]
    else
        local r = {}
        self:IteratorVillageEvents(function(villageEvent)
            table.insert(r, villageEvent)
        end)
        return r
    end
end
function Alliance:FindVillageEventByVillageId(village_id)
    for _,v in pairs(self.villageEvents) do
        if v:VillageData().id == village_id then
            return v
        end
    end
    return nil
end
--TODO:检测村落重新刷新ui更新是否有bug
function Alliance:DecodeAllianceVillages(alliance_data,deltaData)
    if not alliance_data.villages then return end
    local is_fully_update = deltaData == nil 
    local is_delta_update = not is_fully_update and deltaData.villages ~= nil
    if is_fully_update then
        for _,v in ipairs(alliance_data.villages) do
            self.alliance_villages[v.id] = v
        end
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
             deltaData.villages
            ,function(event_data)
                self.alliance_villages[event_data.id] = event_data
            end
            ,function(event_data)
                if self.alliance_villages[event_data.id] then
                    self.alliance_villages[event_data.id] = event_data
                end
            end
            ,function(event_data)
                if self.alliance_villages[event_data.id] then
                    self.alliance_villages[event_data.id] = nil
                end
            end
        )
    end
end

function Alliance:IteratorAllianceVillageInfo(func)
    for _,v in pairs(self.alliance_villages) do
        func(v)
    end
end

function Alliance:GetAllianceVillageInfos()
    return self.alliance_villages
end

--敌方联盟
function Alliance:GetEnemyAlliance()
    return self.enemyAlliance
end

function Alliance:SetEnemyAlliance(alliance)
    self.enemyAlliance = alliance
end

function Alliance:HaveEnemyAlliance()
    return not self:GetEnemyAlliance():IsDefault()
end

function Alliance:InitEnemyAlliance()
    local enemy_alliance = Alliance.new()
    enemy_alliance:SetEnemyAlliance(self)
    self:SetEnemyAlliance(enemy_alliance)
end

function Alliance:UpdateEnemyAlliance(json_data,my_alliance_status,deltaData)
    if not json_data then return end
    if my_alliance_status == 'protect' or my_alliance_status == 'peace' then
        self:GetEnemyAlliance():Reset()
    else
        local enemy_alliance = self:GetEnemyAlliance()
        if enemy_alliance:IsDefault() then
            local my_belvedere = self:GetAllianceBelvedere()
            local enemy_belvedere = enemy_alliance:GetAllianceBelvedere()
            enemy_belvedere:AddListenOnType(my_belvedere, enemy_belvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged)
            enemy_belvedere:AddListenOnType(my_belvedere, enemy_belvedere.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
            enemy_belvedere:AddListenOnType(my_belvedere, enemy_belvedere.LISTEN_TYPE.OnAttackMarchEventDataChanged)
            --瞭望塔coming不需要知道敌方对自己联盟的村落事件和返回事件 reset 会自动去掉所有监听
        end
        if json_data._id then
            enemy_alliance:SetId(json_data._id)
        end
        if json_data.basicInfo then
            enemy_alliance:SetName(json_data.basicInfo.name)
            enemy_alliance:SetAliasName(json_data.basicInfo.tag)
        end
        enemy_alliance:OnAllianceDataChanged(json_data,deltaData)
    end
end

function Alliance:SetNeedUpdateEnemyAlliance(need)
    self.needUpdateEnemyAlliance = need
end

function Alliance:NeedUpdateEnemyAlliance()
    return self.needUpdateEnemyAlliance
end

return Alliance