local Localize = import("..utils.Localize")
local property = import("..utils.property")
local Enum = import("..utils.Enum")
local AllianceShrine = import(".AllianceShrine")
local AllianceMoonGate = import(".AllianceMoonGate")
local AllianceMap = import(".AllianceMap")
local memberMeta = import(".memberMeta")
local MultiObserver = import(".MultiObserver")
local MarchAttackEvent = import(".MarchAttackEvent")
local MarchAttackReturnEvent = import(".MarchAttackReturnEvent")
local AllianceItemsManager = import(".AllianceItemsManager")
local Alliance = class("Alliance", MultiObserver)
local VillageEvent = import(".VillageEvent")
local AllianceBelvedere = import(".AllianceBelvedere")
local config_palace = GameDatas.AllianceBuilding.palace
local pushManager_ = app:GetPushManager()
local audioManager_ = app:GetAudioManager()
--注意:突袭用的MarchAttackEvent 所以使用OnAttackMarchEventTimerChanged
Alliance.LISTEN_TYPE = Enum(
    "OPERATION",
    "BASIC",
    "MEMBER",
    "EVENTS",
    "JOIN_EVENTS",
    "HELP_EVENTS",
    "ALLIANCE_FIGHT",
    "OnAttackMarchEventDataChanged",
    "OnAttackMarchEventTimerChanged",
    "OnAttackMarchReturnEventDataChanged",
    "OnStrikeMarchEventDataChanged",
    "OnStrikeMarchReturnEventDataChanged",
    "OnVillageEventsDataChanged",
    "OnVillageEventTimer",
    "VILLAGE_LEVELS_CHANGED",
    "OnMarchEventRefreshed")
local unpack = unpack
property(Alliance, "id", nil)
property(Alliance, "notice", "")
property(Alliance, "desc", "")
property(Alliance, "titles", {})
property(Alliance, "members", {})
property(Alliance, "fightRequests", {})
property(Alliance, "basicInfo", {})
property(Alliance, "countInfo", {})
property(Alliance, "events", {})
property(Alliance, "joinRequestEvents", {})
property(Alliance, "helpEvents", {})
property(Alliance, "villages", {})
property(Alliance, "monsters", {})
property(Alliance, "villageLevels", {})
property(Alliance, "allianceFight", {})
property(Alliance, "allianceFightReports", {})
property(Alliance, "lastAllianceFightReport", nil)
property(Alliance, "attackMarchEvents", {})
property(Alliance, "attackMarchReturnEvents", {})
property(Alliance, "strikeMarchEvents", {})
property(Alliance, "strikeMarchReturnEvents", {})
property(Alliance, "villageEvents", {})
function Alliance:ctor()
    Alliance.super.ctor(self)
    self.alliance_map = AllianceMap.new(self)
    self.alliance_shrine = AllianceShrine.new(self)
    self.alliance_belvedere = AllianceBelvedere.new(self) -- 村落采集
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
    self.alliance_shrine:ClearAllListener()
    self.alliance_map:ClearAllListener()
    self:ClearAllListener()
end
function Alliance:GetAllianceMap()
    return self.alliance_map
end
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
function Alliance:GetTitles()
    return LuaUtils:table_map(self.titles, function(k, v)
        if string.sub(v, 1, 2) == "__" then
            return k, Localize.alliance_title[k]
        end
        return k,v
    end)
end
function Alliance:IsDefault()
    return self:Id() == nil or self:Id() == json.null
end
function Alliance:OnPropertyChange(property_name, old_value, new_value)
    local is_new_alliance = property_name == "id" and (old_value == nil or old_value == json.null) and new_value ~= nil
    if is_new_alliance then
        self:OnOperation("join")
    end
end
function Alliance:IteratorAllMembers(func)
    for _,v in pairs(self.members) do
        if func(v) then
            return
        end
    end
end

function Alliance:GetAllianceArchon()
    local archon = json.null
    self:IteratorAllMembers(function(member)
        if member:IsArchon() then
            archon = member
        end
    end)
    return archon
end

function Alliance:GetMemeberById(id)
    for _,v in pairs(self.members) do
        if v.id == id then
            return v
        end
    end
end
function Alliance:GetMemberByMapObjectsId(id)
    for _,v in pairs(self.members) do
        if v.mapId == id then
            return v
        end
    end
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
-- return 当前人数,在线人数,最大成员数
function Alliance:GetMembersCountInfo()
    local count,online,maxCount = 0,0,0
    for __,v in pairs(self:GetAllMembers()) do
        count = count + 1
        if type(v.online) == 'boolean' and v.online  then
            online = online + 1
        end
    end
    local maxmembers = config_palace[1].memberCount
    for _,v in ipairs(self:GetAllianceMap():GetAllBuildingsInfo()) do
        if v.name == 'palace' then
            maxmembers = config_palace[v.level].memberCount
            break
        end
    end
    return count,online,maxmembers
end
function Alliance:GetFightRequestPlayerNum()
    return #self.fightRequests
end
function Alliance:IsRequested()
    for _,v in pairs(self:FightRequests()) do
        if v == User:Id() then
            return true
        end
    end
end
function Alliance:GetLastAllianceFightReports()
    local last_report
    for _,v in pairs(self.allianceFightReports) do
        if not last_report then
            last_report = v
        else
            if v.fightTime > last_report.fightTime then
                last_report = v
            end
        end
    end
    return last_report
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
function Alliance:GetCouldShowHelpEvents()
    local could_show = {}
    for k,event in pairs(self.helpEvents) do
        -- 去掉被自己帮助过的
        local isHelped
        local _id = User:Id()
        for k,id in pairs(event.eventData.helpedMembers) do
            if id == _id then
                isHelped = true
            end
        end
        if not isHelped then
            -- 已经帮助到最大次数的去掉
            if #event.eventData.helpedMembers < event.eventData.maxHelpCount then

                -- 属于自己的求助事件，已经结束的
                local isFinished = false
                if User:Id() == event.playerData.id then
                    local city = City
                    local eventData = event.eventData
                    local type = eventData.type
                    local event_id = eventData.id
                    if type == "buildingEvents" then
                        city:IteratorFunctionBuildingsByFunc(function(key, building)
                            if building:UniqueUpgradingKey() == event_id then
                                isFinished = true
                            end
                        end)
                        -- 城墙，箭塔
                        if city:GetGate():UniqueUpgradingKey() == event_id then
                            isFinished = true
                        end
                        if city:GetTower():UniqueUpgradingKey() == event_id then
                            isFinished = true
                        end
                    elseif type == "houseEvents" then
                        city:IteratorDecoratorBuildingsByFunc(function(key, building)
                            if building:UniqueUpgradingKey() == event_id then
                                isFinished = true
                            end
                        end)
                    elseif type == "productionTechEvents" then
                        city:IteratorProductionTechEvents(function(productionTechnologyEvent)
                            if productionTechnologyEvent:Id() == event_id then
                                isFinished = true
                            end
                        end)
                    elseif type == "militaryTechEvents" then
                        city:GetSoldierManager():IteratorMilitaryTechEvents(function(militaryTechEvent)
                            if militaryTechEvent:Id() == event_id then
                                isFinished = true
                            end
                        end)
                    elseif type == "soldierStarEvents" then
                        city:GetSoldierManager():IteratorSoldierStarEvents(function(soldierStarEvent)
                            if soldierStarEvent:Id() == event_id then
                                isFinished = true
                            end
                        end)
                    end
                else
                    isFinished = true
                end
                if isFinished then
                    table.insert(could_show, event)
                end
            end
        end
    end
    return could_show
end

local function IsCanbeHelpedByMe(event)
    local _id = User:Id()
    for k,id in pairs(event.eventData.helpedMembers) do
        if id == _id then
            return false
        end
    end
    return event.playerData.id ~= _id
end
-- 获取其他所有联盟成员的申请的没有被自己帮助过的事件数量
function Alliance:GetOtherRequestEventsNum()
    local request_num = 0
    for _,v in pairs(self.helpEvents) do
        request_num = request_num + (IsCanbeHelpedByMe(v) and 1 or 0)
    end
    return request_num
end

local function GetReversedPosition(p)
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
function Alliance:GetFightPosition()
    if self.allianceFight ~= json.null and next(self.allianceFight) then
        local mergeStyle = self.allianceFight.mergeStyle
        local isAttacker = self.id == self.allianceFight.attackAllianceId
        return isAttacker and mergeStyle or GetReversedPosition(mergeStyle)
    end
end


function Alliance:Reset()
    property(self, "RESET")
    self.alliance_map:Reset()
    self.alliance_shrine:Reset()
    self:GetAllianceBelvedere():Reset()
    self:ResetMarchEvent()
    self:ResetVillageEvents()
    self:OnOperation("quit")
end
function Alliance:OnOperation(operation_type)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.OPERATION, function(listener)
        listener:OnOperation(self, operation_type)
    end)
end

function Alliance:OnAllianceDataChanged(alliance_data,refresh_time,deltaData)
    self.basicInfo = alliance_data.basicInfo
    self.notice = alliance_data.notice
    self.desc = alliance_data.desc
    self.titles = alliance_data.titles
    self.countInfo = alliance_data.countInfo
    self.events = alliance_data.events
    self.helpEvents = alliance_data.helpEvents
    self.joinRequestEvents = alliance_data.joinRequestEvents
    self.fightRequests = alliance_data.fightRequests
    self.allianceFightReports = alliance_data.allianceFightReports
    self.allianceFight = alliance_data.allianceFight
    self.villageLevels = alliance_data.villageLevels
    self.villages = alliance_data.villages
    self.monsters = alliance_data.monsters
    self.members = alliance_data.members
    for _,v in ipairs(self.members) do
        setmetatable(v, memberMeta)
    end

    if deltaData then
        if deltaData.basicInfo then
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.BASIC, function(listener)
                listener:OnAllianceBasicChanged(self, deltaData)
            end)
        end
        if deltaData.allianceFight then
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.ALLIANCE_FIGHT, function(listener)
                listener:OnAllianceFightChanged(self, deltaData)
            end)
        end
        if deltaData.members then
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.MEMBER, function(listener)
                listener:OnMemberChanged(self, deltaData)
            end)
        end
        if deltaData.events then
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.EVENTS, function(listener)
                listener:OnEventsChanged(self, deltaData)
            end)
        end
        if deltaData.joinRequestEvents then
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.JOIN_EVENTS, function(listener)
                listener:OnJoinEventsChanged(self, deltaData)
            end)
        end
        if deltaData.helpEvents then
            if self:IsMyAlliance() then
                self:NotifyHelpEvents(deltaData)
            end
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.HELP_EVENTS, function(listener)
                listener:OnHelpEventChanged(self, deltaData)
            end)
        end
        if deltaData.villageLevels then
            self:NotifyListeneOnType(Alliance.LISTEN_TYPE.VILLAGE_LEVELS_CHANGED, function(listener)
                listener:OnVillageLevelsChanged(self, deltaData)
            end)
        end
    end
    self.alliance_shrine:OnAllianceDataChanged(alliance_data,deltaData,refresh_time)
    self.alliance_map:OnAllianceDataChanged(alliance_data, deltaData)
    self:OnAttackMarchEventsDataChanged(alliance_data,deltaData,refresh_time)
    self:OnAttackMarchReturnEventsDataChanged(alliance_data,deltaData,refresh_time)
    self:OnStrikeMarchEventsDataChanged(alliance_data,deltaData,refresh_time)
    self:OnStrikeMarchReturnEventsDataChanged(alliance_data,deltaData,refresh_time)
    self:OnVillageEventsDataChanged(alliance_data,deltaData,refresh_time)
    -- 联盟道具管理
    self.items_manager:OnItemsChanged(alliance_data,deltaData)
    self.items_manager:OnItemLogsChanged(alliance_data,deltaData)
end
function Alliance:NotifyHelpEvents(deltaData)
    local ok, results = deltaData("helpEvents.%d.eventData.helpedMembers.%d")
    if ok then
        for i,v in ipairs(results) do
            local helpeventindex, _, memberid = unpack(v)
            local event = self.helpEvents[helpeventindex]
            if event.playerData.id == User:Id() then
                self:NotifyMemberHelp(memberid, event.eventData)
            end
        end
    end
end
function Alliance:NotifyMemberHelp(id, eventData)
    local event_name
    if eventData.type == "buildingEvents" or eventData.type == "houseEvents" then
        event_name = Localize.building_name[eventData.name]
    elseif eventData.type == "militaryTechEvents" then
        local soldiers = string.split(eventData.name, "_")
        local soldier_category = Localize.soldier_category
        if soldiers[2] == "hpAdd" then
            event_name = string.format(_("%s血量增加"),soldier_category[soldiers[1]])
        else
            event_name = string.format(_("%s对%s的攻击"),soldier_category[soldiers[1]],soldier_category[soldiers[2]])
        end
    elseif eventData.type == "soldierStarEvents" then
        event_name = string.format(_("晋升%s的星级"),Localize.soldier_name[eventData.name])
    elseif eventData.type == "productionTechEvents" then
        event_name = Localize.productiontechnology_name[eventData.name]
    end
    local name = self:GetMemeberById(id):Name()
    GameGlobalUI:showTips(_("提示"),string.format(_("%s帮助升级%s成功"),name,event_name))
    app:GetAudioManager():PlayeEffectSoundWithKey("BUY_ITEM")
end
function Alliance:GetAllianceArchonMember()
    for _,v in pairs(self.members) do
        if v:IsArchon() then
            return v
        end
    end
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
    if self.basicInfo.status == "prepare" and math.floor(self.basicInfo.statusFinishTime / 1000) == math.floor(current_time) then
        app:GetAudioManager():PlayeEffectSoundWithKey("BATTLE_START")
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
        listener[Alliance.LISTEN_TYPE[LISTEN_TYPE]](listener,changed_map,self)
    end)
    if self:GetAllianceBelvedere()[Alliance.LISTEN_TYPE[LISTEN_TYPE]] then
        self:GetAllianceBelvedere()[Alliance.LISTEN_TYPE[LISTEN_TYPE]](self:GetAllianceBelvedere(),changed_map,self)
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

function Alliance:OnAttackMarchEventsDataChanged(alliance_data,deltaData,refresh_time)
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
            attackMarchEvent:UpdateData(v,refresh_time)
            self.attackMarchEvents[attackMarchEvent:Id()] = attackMarchEvent
            attackMarchEvent:AddObserver(self)
            self:updateWatchTowerLocalPushIf(attackMarchEvent)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnMarchEventRefreshed,"OnAttackMarchEventsDataChanged")
    end

    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.attackMarchEvents
            ,function(event_data)
                local attackMarchEvent = MarchAttackEvent.new()
                attackMarchEvent:UpdateData(event_data,refresh_time)
                self.attackMarchEvents[attackMarchEvent:Id()] = attackMarchEvent
                attackMarchEvent:AddObserver(self)
                self:updateWatchTowerLocalPushIf(attackMarchEvent)
                return attackMarchEvent
            end
            ,function(event_data)
                if self.attackMarchEvents[event_data.id] then
                    local attackMarchEvent = self.attackMarchEvents[event_data.id]
                    attackMarchEvent:UpdateData(event_data,refresh_time)
                    self:updateWatchTowerLocalPushIf(attackMarchEvent)
                    return attackMarchEvent
                end
            end
            ,function(event_data)
                if self.attackMarchEvents[event_data.id] then
                    local attackMarchEvent = self.attackMarchEvents[event_data.id]
                    attackMarchEvent:Reset()
                    self.attackMarchEvents[event_data.id] = nil
                    attackMarchEvent = MarchAttackEvent.new()
                    attackMarchEvent:UpdateData(event_data,refresh_time)
                    self:cancelLocalMarchEventPushIf(attackMarchEvent)
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


function Alliance:OnAttackMarchReturnEventsDataChanged(alliance_data,deltaData,refresh_time)
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
            attackMarchReturnEvent:UpdateData(v,refresh_time)
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
                attackMarchReturnEvent:UpdateData(event_data,refresh_time)
                self.attackMarchReturnEvents[attackMarchReturnEvent:Id()] = attackMarchReturnEvent
                attackMarchReturnEvent:AddObserver(self)
                return attackMarchReturnEvent
            end
            ,function(event_data)
                if self.attackMarchReturnEvents[event_data.id] then
                    local attackMarchReturnEvent = self.attackMarchReturnEvents[event_data.id]
                    attackMarchReturnEvent:UpdateData(event_data,refresh_time)
                    return attackMarchReturnEvent
                end
            end
            ,function(event_data)
                if self.attackMarchReturnEvents[event_data.id] then
                    local attackMarchReturnEvent = self.attackMarchReturnEvents[event_data.id]
                    attackMarchReturnEvent:Reset()
                    self.attackMarchReturnEvents[event_data.id] = nil
                    attackMarchReturnEvent = MarchAttackReturnEvent.new()
                    attackMarchReturnEvent:UpdateData(event_data,refresh_time)
                    self:cancelLocalMarchEventPushIf(attackMarchReturnEvent)
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

function Alliance:GetMyAllianceFightCountData()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.attacker.allianceCountData or allianceFight.defencer.allianceCountData
end
function Alliance:GetEnemyAllianceFightCountData()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.defencer.allianceCountData or allianceFight.attacker.allianceCountData
end
function Alliance:GetMyAllianceFightPlayerKills()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.attacker.playerKills or allianceFight.defencer.playerKills
end
function Alliance:GetEnemyAllianceFightPlayerKills()
    local allianceFight = self.allianceFight
    return self.id == allianceFight.attackAllianceId and allianceFight.defencer.playerKills or allianceFight.attacker.playerKills
end

function Alliance:OnStrikeMarchEventsDataChanged(alliance_data,deltaData,refresh_time)
    if not alliance_data.strikeMarchEvents then return end
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.strikeMarchEvents ~= nil
    if is_fully_update then
        self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
            strikeMarchEvent:Reset()
        end)
        self.strikeMarchEvents = {}
        for _,v in ipairs(alliance_data.strikeMarchEvents) do
            local strikeMarchEvent = MarchAttackEvent.new(true)
            strikeMarchEvent:UpdateData(v,refresh_time)
            self.strikeMarchEvents[strikeMarchEvent:Id()] = strikeMarchEvent
            strikeMarchEvent:AddObserver(self)
            self:updateWatchTowerLocalPushIf(strikeMarchEvent)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnMarchEventRefreshed,"OnStrikeMarchEventDataChanged")
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.strikeMarchEvents
            ,function(event_data)
                local strikeMarchEvent = MarchAttackEvent.new(true)
                strikeMarchEvent:UpdateData(event_data,refresh_time)
                self.strikeMarchEvents[strikeMarchEvent:Id()] = strikeMarchEvent
                strikeMarchEvent:AddObserver(self)
                self:updateWatchTowerLocalPushIf(strikeMarchEvent)
                return strikeMarchEvent
            end
            ,function(event_data)
                if self.strikeMarchEvents[event_data.id] then
                    local strikeMarchEvent = self.strikeMarchEvents[event_data.id]
                    strikeMarchEvent:UpdateData(event_data,refresh_time)
                    self:updateWatchTowerLocalPushIf(strikeMarchEvent)
                    return strikeMarchEvent
                end
            end
            ,function(event_data)
                if self.strikeMarchEvents[event_data.id] then
                    local strikeMarchEvent = self.strikeMarchEvents[event_data.id]
                    strikeMarchEvent:Reset()
                    self.strikeMarchEvents[event_data.id] = nil
                    strikeMarchEvent = MarchAttackEvent.new(true)
                    strikeMarchEvent:UpdateData(event_data,refresh_time)
                    self:cancelLocalMarchEventPushIf(strikeMarchEvent)
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

function Alliance:OnStrikeMarchReturnEventsDataChanged(alliance_data,deltaData,refresh_time)
    if not alliance_data.strikeMarchReturnEvents then return end
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.strikeMarchReturnEvents ~= nil
    if is_fully_update then
        self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
            strikeMarchReturnEvent:Reset()
        end)
        self.strikeMarchReturnEvents = {}
        for _,v in ipairs(alliance_data.strikeMarchReturnEvents) do
            local strikeMarchReturnEvent = MarchAttackReturnEvent.new(true)
            strikeMarchReturnEvent:UpdateData(v,refresh_time)
            self.strikeMarchReturnEvents[strikeMarchReturnEvent:Id()] = strikeMarchReturnEvent
            strikeMarchReturnEvent:AddObserver(self)
        end
        self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnMarchEventRefreshed,"OnStrikeMarchReturnEventDataChanged")
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.strikeMarchReturnEvents
            ,function(event_data)
                local strikeMarchReturnEvent = MarchAttackReturnEvent.new(true)
                strikeMarchReturnEvent:UpdateData(event_data,refresh_time)
                self.strikeMarchReturnEvents[strikeMarchReturnEvent:Id()] = strikeMarchReturnEvent
                strikeMarchReturnEvent:AddObserver(self)
                return strikeMarchReturnEvent
            end
            ,function(event_data)
                if self.strikeMarchReturnEvents[event_data.id] then
                    local strikeMarchReturnEvent = self.strikeMarchReturnEvents[event_data.id]
                    strikeMarchReturnEvent:UpdateData(event_data,refresh_time)
                    return strikeMarchReturnEvent
                end
            end
            ,function(event_data)
                if self.strikeMarchReturnEvents[event_data.id] then
                    local strikeMarchReturnEvent = self.strikeMarchReturnEvents[event_data.id]
                    strikeMarchReturnEvent:Reset()
                    self.strikeMarchReturnEvents[event_data.id] = nil
                    strikeMarchReturnEvent = MarchAttackReturnEvent.new(true)
                    strikeMarchReturnEvent:UpdateData(event_data,refresh_time)
                    self:cancelLocalMarchEventPushIf(strikeMarchReturnEvent)
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
    local marchEvents = self:GetAttackMarchEvents("helpDefence")
    for _,attackEvent in ipairs(marchEvents) do
        if attackEvent:GetPlayerRole() == attackEvent.MARCH_EVENT_PLAYER_ROLE.SENDER
            and attackEvent:GetDefenceData().id == memeberId then
            return true
        end
    end
    return false
end

function Alliance:GetSelf()
    return self:GetMemeberById(User:Id())
end

--这里会取敌方的的村落信息，因为可能是占领的敌方村落
------------------------------------------------------------------------------------------
function Alliance:OnVillageEventTimer(villageEvent)
    local village_id = villageEvent:VillageData().id
    local village = self:GetAllianceVillageInfosById(village_id)
    if not village and Alliance_Manager:HaveEnemyAlliance() then
        local enemy_alliance = Alliance_Manager:GetEnemyAlliance()
        village = enemy_alliance:GetAllianceVillageInfosById()[village_id]
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
function Alliance:OnVillageEventsDataChanged(alliance_data,deltaData,refresh_time)
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
            villageEvent:UpdateData(v,refresh_time)
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
                villageEvent:UpdateData(event_data,refresh_time)
                self.villageEvents[villageEvent:Id()] = villageEvent
                villageEvent:AddObserver(self)
                return villageEvent
            end
            ,function(event_data)
                if self.villageEvents[event_data.id] then
                    local villageEvent = self.villageEvents[event_data.id]
                    villageEvent:UpdateData(event_data,refresh_time)
                    return villageEvent
                end
            end
            ,function(event_data)
                if self.villageEvents[event_data.id] then
                    local villageEvent = self.villageEvents[event_data.id]
                    villageEvent:Reset()
                    self.villageEvents[villageEvent:Id()] = nil
                    villageEvent = VillageEvent.new()
                    villageEvent:UpdateData(event_data,refresh_time)
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
function Alliance:IteratorAllianceVillageInfo(func)
    for _,v in pairs(self.villages) do
        func(v)
    end
end

function Alliance:GetAllianceVillageInfosById(id)
    for i,v in pairs(self.villages) do
        if v.id == id then
            return v
        end
    end
end
function Alliance:GetAllianceMonsterInfosById(id)
    for i,v in ipairs(self.monsters) do
        if v.id == id then
            return v
        end
    end
end

function Alliance:SetIsMyAlliance(isMyAlliance)
    self.isMyAlliance = isMyAlliance
end

function Alliance:IsMyAlliance()
    return self.isMyAlliance
end

function Alliance:updateWatchTowerLocalPushIf(marchEvent)
    if marchEvent:GetPlayerRole() == marchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
        if not marchEvent:IsReturnEvent() then
            local marchType = marchEvent:MarchType()
            local msg = marchEvent:IsStrikeEvent() and _("你的城市正被敌军突袭") or _("你的城市正被敌军攻击")
            local warningTime = self:GetAllianceBelvedere():GetWarningTime()
            if marchType == 'city' then
                pushManager_:UpdateWatchTowerPush(marchEvent:ArriveTime() - warningTime,msg,marchEvent:Id())
            end
        end
    end
end
--因为这里添加了音效效果 so 所有的事件删除都要调用此方法
function Alliance:cancelLocalMarchEventPushIf(marchEvent)
    if marchEvent:GetPlayerRole() == marchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
        if marchEvent:IsReturnEvent() then
            if not marchEvent:IsStrikeEvent() then --我的一般进攻部队返回城市
                audioManager_:PlayeEffectSoundWithKey("TROOP_BACK")
            end
        else
            pushManager_:CancelWatchTowerPush(marchEvent:Id())
        end
    end
end
return Alliance




