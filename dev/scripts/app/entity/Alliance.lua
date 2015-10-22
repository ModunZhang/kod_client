local Enum = import("..utils.Enum")
local memberMeta = import(".memberMeta")
local Localize = import("..utils.Localize")
local property = import("..utils.property")
local MultiObserver = import(".MultiObserver")
local Alliance = class("Alliance", MultiObserver)
local buildingName = GameDatas.AllianceMap.buildingName
Alliance.LISTEN_TYPE = Enum(
    "operation", -- 自己加的

    "basicInfo",
    "members",

    "shrineDatas",
    "shrineReports",
    "shrineEvents",

    "items",
    "itemLogs",

    "mapObjects",
    "villageLevels",
    "events",
    "joinRequestEvents",
    "helpEvents",
    "marchEvents")
property(Alliance, "_id", nil)
property(Alliance, "mapIndex", nil)
property(Alliance, "desc", "")
property(Alliance, "titles", {})

property(Alliance, "members", {})

property(Alliance, "items", {})
property(Alliance, "itemLogs", {})

property(Alliance, "basicInfo", {})
property(Alliance, "countInfo", {})

property(Alliance, "events", {})
property(Alliance, "joinRequestEvents", {})
property(Alliance, "helpEvents", {})

property(Alliance, "villages", {})
property(Alliance, "monsters", {})
property(Alliance, "villageLevels", {})

property(Alliance, "allianceFight", nil)
property(Alliance, "allianceFightReports", nil)
property(Alliance, "lastAllianceFightReport", nil)
function Alliance:ctor()
    Alliance.super.ctor(self)
    self.resources_cache = {
        perception  = {limit = math.huge, output = 0},
    }
end

--[[resourse begin]]
function Alliance:GetPerceptionRes()
    return self.resources_cache.perception
end
function Alliance:GetPerception()
    local res = self.resources_cache.perception
    return GameUtils:GetCurrentProduction(
        self.basicInfo.perception,
        self.basicInfo.perceptionRefreshTime / 1000,
        res.limit,
        res.output,
        app.timer:GetServerTime()
    )
end
--[[end]]

function Alliance:AddListenOnType(listener, listenerType)
    if type(listenerType) == "string" then
        listenerType = Alliance.LISTEN_TYPE[listenerType]
    end
    Alliance.super.AddListenOnType(self, listener, listenerType)
end
function Alliance:RemoveListenerOnType(listener, listenerType)
    if type(listenerType) == "string" then
        listenerType = Alliance.LISTEN_TYPE[listenerType]
    end
    Alliance.super.RemoveListenerOnType(self, listener, listenerType)
end
-- function Alliance:GetAllianceBelvedere()
--     return self.alliance_belvedere
-- end
-- function Alliance:GetAllianceShrine()
--     return self.alliance_shrine
-- end
function Alliance:GetVillageLevels()
    return self.villageLevels
end
function Alliance:ResetAllListeners()
    self:ClearAllListener()
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
    return self._id == nil or self._id == json.null
end
function Alliance:OnPropertyChange(property_name, old_value, new_value)

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
local palace = GameDatas.AllianceBuilding.palace
function Alliance:GetMembersCountInfo()
    local count,online,maxCount = 0,0,0
    for __,v in pairs(self:GetAllMembers()) do
        count = count + 1
        if type(v.online) == 'boolean' and v.online  then
            online = online + 1
        end
    end
    local maxmembers = palace[1].memberCount
    for _,v in ipairs(self.buildings) do
        if v.name == 'palace' then
            maxmembers = palace[v.level].memberCount
            break
        end
    end
    return count,online,maxmembers
end
-- 获取战争期敌对联盟信息
function Alliance:GetEnemyAlliance()
   local allianceFight = self:AllianceFight()
   if allianceFight then
       return self._id == allianceFight.attacker.alliance.id and allianceFight.defencer or allianceFight.attacker
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
        return self._id == last.attackAllianceId and last.attackAlliance or last.defenceAlliance
    end
end
function Alliance:GetEnemyLastAllianceFightReportsData()
    local last = self:GetLastAllianceFightReports()
    if last then
        return self._id == last.attackAllianceId and last.defenceAlliance or last.attackAlliance
    end
end
function Alliance:GetCouldShowHelpEvents()
    local User = User
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
                    for _,event in ipairs(User[type] or {}) do
                        if event.id == event_id then
                            isFinished = true
                        end
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
function Alliance:GetMapObjectType(mapobj)
    return buildingName[mapobj.name].type
end
function Alliance:GetSizeWithMapObj(mapobj)
    local size = buildingName[mapobj.name]
    return size.width, size.height
end
function Alliance:GetLogicPositionWithMapObj(mapobj)
    local location = mapobj.location
    return location.x, location.y
end
function Alliance:GetMidLogicPositionWithMapObj(mapobj)
    local w,h = Alliance:GetSizeWithMapObj(mapobj)
    local x,y = Alliance:GetLogicPositionWithMapObj(mapobj)
    return (2 * x - w + 1) / 2, (2 * y - h + 1) / 2
end
-- function Alliance:GetMidLogicPosition()
--     local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
--     return (start_x + end_x) / 2, (start_y + end_y) / 2
-- end
-- function Alliance:GetTopLeftPoint()
--     local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
--     return start_x, start_y
-- end
-- function Alliance:GetTopRightPoint()
--     local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
--     return end_x, start_y
-- end
-- function Alliance:GetBottomLeftPoint()
--     local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
--     return start_x, end_y
-- end
-- function Alliance:GetBottomRightPoint()
--     local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
--     return end_x, end_y
-- end
function Alliance:IsContainPointWithMapObj(mapobj, x, y)
    local start_x, end_x, start_y, end_y = Alliance:GetGlobalRegionWithMapObj(mapobj)
    return x >= start_x and x <= end_x and y >= start_y and y <= end_y
end
-- function Alliance:IsIntersect(building)
--     local start_x, end_x, start_y, end_y = building:GetGlobalRegion()
--     if self:IsContainPoint(start_x, start_y) then
--         return true
--     end
--     if self:IsContainPoint(start_x, end_y) then
--         return true
--     end
--     if self:IsContainPoint(end_x, start_y) then
--         return true
--     end
--     if self:IsContainPoint(end_x, end_y) then
--         return true
--     end
-- end
function Alliance:GetGlobalRegionWithMapObj(mapobj)
    local w, h = Alliance:GetSizeWithMapObj(mapobj)
    local x, y = Alliance:GetLogicPositionWithMapObj(mapobj)

    local start_x, end_x, start_y, end_y

    local is_orient_x = w > 0
    local is_orient_neg_x = not is_orient_x
    local is_orient_y = h > 0
    local is_orient_neg_y = not is_orient_y

    if is_orient_x then
        start_x, end_x = x - w + 1, x
    elseif is_orient_neg_x then
        start_x, end_x = x, x + math.abs(w) - 1
    end

    if is_orient_y then
        start_y, end_y = y - h + 1, y
    elseif is_orient_neg_y then
        start_y, end_y = y, y + math.abs(h) - 1
    end
    return start_x, end_x, start_y, end_y
end

function Alliance:IteratorAllianceBuildings(func)
    for k,v in pairs(self:GetMapObjectsByType("building")) do
        if func(k,v) then
            return
        end
    end
end
function Alliance:IteratorCities(func)
    for k,v in pairs(self:GetMapObjectsByType("member")) do
        if func(k,v) then
            return
        end
    end
end
function Alliance:IteratorVillages(func)
    for k,v in pairs(self:GetMapObjectsByType("village")) do
        if func(k,v) then
            return
        end
    end
end
function Alliance:GetMapObjectsByType(type_)
    local t = {}
    for _,v in pairs(self.mapObjects) do
        if buildingName[v.name].type == type_ then
            table.insert(t, v)
        end
    end
    return t
end
function Alliance:IteratorAllObjects(func)
    for k, v in pairs(self.mapObjects) do
        if func(k, v) then
            return
        end
    end
end
function Alliance:FindMapObjectById(id)
    for i,v in ipairs(self.mapObjects) do
        if v.id == id then
            return v
        end
    end
end
function Alliance:FindAllianceBuildingInfoByObjects(object)
    if buildingName[object.name].type == "building" then
        local id = object.id
        for _,v in ipairs(self.buildings) do
            if v.id == id then
                return v
            end
        end
    end
end
function Alliance:FindAllianceVillagesInfoByObject(object)
    if buildingName[object.name].type == "village" then
        local village_info = self:GetAllianceVillageInfosById(object.id)
        if village_info then
            return village_info
        end
    end
end
function Alliance:FindAllianceMonsterInfoByObject(object)
    if buildingName[object.name].type == "monster" then
        local monster_info = self:GetMapObjectInfoByObject(object)
        if monster_info then
            for i,v in ipairs(self.monsters) do
                if v.id == monster_info.id then
                    return v
                end
            end
        end
    end
end
function Alliance:FindAllianceBuildingInfoByName(name)
    for k, v in pairs(self.buildings) do
        if v.name == name then
            return v
        end
    end
end
function Alliance:GetMapObjectInfoByObject(mapObj)
    for k,v in pairs(self.mapObjects) do
        local location = v.location
        if location.x == mapObj.x and location.y == mapObj.y then
            return v
        end
    end
    return self:GetAllianceBuildingInfoByName(mapObj.name)
end
function Alliance:Reset()
    print("===================>Reset")
    print(debug.traceback("", 2))
    property(self, "RESET")
    self:OnOperation("quit")
end

--[[itemLogs begin]]
function Alliance:SetNewGoodsCome(b)
    self.isNewGoodsCome = b
end
function Alliance:GetItemCount(item_name)
    return UtilsForItem:GetItemCount(self.items, item_name)
end
--[[end]]


--[[shrine begin]]
local shrineStage = GameDatas.AllianceInitData.shrineStage
function Alliance:GetMaxStage()
    local maxStages = 0
    table.foreach(shrineStage,function(key, config)
        if config.stage > maxStages then
            maxStages = config.stage
        end
    end)
    return maxStages
end
function Alliance:GetSubStagesByMainStage()

end
function Alliance:GetStageInfoBy(key)
    if type(key) == "string" then
        return shrineStage[key]
    elseif type(key) == "number" then
        for _,v in pairs(shrineStage) do
            if v.index == index then
                return v
            end
        end
    end
end
function Alliance:CanSendTroopToShrine(member_id)
    if self:GetShrineEventByPlayerId(member_id) then
        printInfo("%s","已经驻防的部队检查到玩家信息")
        return false
    end
    --check 正在行军的部队
    for i,v in ipairs(self.marchEvents.attackMarchEvents) do
        if v.marchType == "shrine" then
            if member_id == self.attackPlayerData.id then
                printInfo("%s","正在行军的部队检查到玩家信息")
                return false
            end
        end
    end
    return true
end
function Alliance:GetShrineEventByPlayerId(id)
    for _,event in ipairs(self.shrineEvents) do
        for _,player in ipairs(event.playerTroops) do
            if player.id == id then
                return event
            end
        end
    end
end
function Alliance:GetShrineEventsBySeq()
    local r = {}
    for _,v in pairs(self.shrineEvents) do
        table.insert(r,v)
    end
    table.sort(r, function(a,b)
        return a.startTime > b.startTime
    end)
    return r
end
function Alliance:GetShrineEventByStageName(stageName)
    for _,event in pairs(self.shrineEvents) do
        if event.stageName == stageName then
            return event
        end
    end
end
function Alliance:GetShrineEventByid(id)
    for _,v in ipairs(self.shrineEvents) do
        if v.id == id then
            return v
        end
    end
end
--[[end]]

local shrine = GameDatas.AllianceBuilding.shrine
local before_map = {
    items = function(allianceData, deltaData)
        
    end,
    basicInfo = function(allianceData, deltaData)
        local building = allianceData:FindAllianceBuildingInfoByName("shrine")
        local config = shrine[building.level]
        self.resources_cache.perception.limit = config.perception
        self.resources_cache.perception.output= config.pRecoveryPerHour
    end,
    members = function()end,

    items = function()end,
    itemLogs = function(allianceData, deltaData)
        if deltaData("itemLogs.add") then
            allianceData:SetNewGoodsCome(true)
        end
    end,

    mapObjects = function()end,
    villageLevels = function()end,

    shrineDatas = function()end,
    shrineReports = function()end,
    shrineEvents = function()end,

    events = function()end,
    joinRequestEvents = function()end,
    helpEvents = function(allianceData, deltaData)
        if allianceData:IsMyAlliance() then
            allianceData:NotifyHelpEvents(deltaData)
        end
    end,
    marchEvents = function()end,
}
function Alliance:OnAllianceDataChanged(allianceData,refresh_time,deltaData)
    local is_join, is_quit
    if self._id ~= allianceData._id then
        if (self._id == nil or self._id == json.null) and allianceData._id ~= nil and allianceData._id ~= json.null then
            is_join = true
        elseif self._id ~= nil and self._id ~= json.null and (allianceData._id == nil or allianceData._id == json.null) then
            is_quit = true
        end
    end
    for k,v in pairs(allianceData) do
        self[k] = v
    end
    for _,v in ipairs(self.members) do
        setmetatable(v, memberMeta)
    end
    if is_join then
        self:OnOperation("join")
    end
    dump(allianceData.shrineDatas)

    if deltaData then
        for i,k in ipairs(Alliance.LISTEN_TYPE) do
            local before_func = before_map[k]
            if type(k) == "string" and before_func then
                if deltaData(k) then
                    before_func(self, deltaData)
                    local notify_function_name = string.format("OnAllianceDataChanged_%s", k)
                    self:NotifyListeneOnType(Alliance.LISTEN_TYPE[k], function(listener)
                        local func = listener[notify_function_name]
                        if func then
                            func(listener, self, deltaData)
                        end
                    end)
                end
            end
        end
    end
end
function Alliance:NotifyHelpEvents(deltaData)
    local ok, value = deltaData("helpEvents")
    if ok then
        for k,v in pairs(value) do
            if type(k) == "number" then
                if v.eventData and v.eventData.helpedMembers and v.eventData.helpedMembers.add then
                    local event = self.helpEvents[k]
                    if event.playerData.id == User:Id() then
                        self:NotifyMemberHelp(v.eventData.helpedMembers.add[1], event.eventData)
                    end
                end
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
function Alliance:OnOperation(operation_type)
    self:NotifyListeneOnType(Alliance.LISTEN_TYPE.operation, function(listener)
        listener["OnAllianceDataChanged_operation"](listener, self, operation_type)
    end)
end
function Alliance:OnTimer(current_time)
    -- self:GetAllianceShrine():OnTimer(current_time)
    -- self:IteratorAttackMarchEvents(function(attackMarchEvent)
    --     attackMarchEvent:OnTimer(current_time)
    -- end)
    -- self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
    --     attackMarchReturnEvent:OnTimer(current_time)
    -- end)
    -- self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
    --     strikeMarchEvent:OnTimer(current_time)
    -- end)
    -- self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
    --     strikeMarchReturnEvent:OnTimer(current_time)
    -- end)
    -- self:IteratorVillageEvents(function(villageEvent)
    --     villageEvent:OnTimer(current_time)
    -- end)
    -- if self.basicInfo.status == "prepare" and math.floor(self.basicInfo.statusFinishTime / 1000) == math.floor(current_time) then
    --     app:GetAudioManager():PlayeEffectSoundWithKey("BATTLE_START")
    -- end

end

--行军事件
--------------------------------------------------------------------------------
function Alliance:OnMarchEventTimer(attackMarchEvent)
    -- self:CallEventsChangedListeners(Alliance.LISTEN_TYPE.OnAttackMarchEventTimerChanged,attackMarchEvent)
    -- if self:GetAllianceBelvedere()['OnAttackMarchEventTimerChanged'] then
    --     self:GetAllianceBelvedere():OnAttackMarchEventTimerChanged(attackMarchEvent)
    -- end
end

function Alliance:CallEventsChangedListeners(LISTEN_TYPE,changed_map)
    -- self:NotifyListeneOnType(LISTEN_TYPE, function(listener)
    --     listener[Alliance.LISTEN_TYPE[LISTEN_TYPE]](listener,changed_map,self)
    -- end)
    -- if self:GetAllianceBelvedere()[Alliance.LISTEN_TYPE[LISTEN_TYPE]] then
    --     self:GetAllianceBelvedere()[Alliance.LISTEN_TYPE[LISTEN_TYPE]](self:GetAllianceBelvedere(),changed_map,self)
    -- end
end

function Alliance:GetAttackMarchEvents(march_type)
    local r = {}
    -- if not march_type then
    --     self:IteratorAttackMarchEvents(function(attackMarchEvent)
    --         table.insert(r,attackMarchEvent)
    --     end)
    -- else
    --     self:IteratorAttackMarchEvents(function(attackMarchEvent)
    --         if attackMarchEvent:MarchType() == march_type then
    --             table.insert(r,attackMarchEvent)
    --         end
    --     end)
    -- end
    return r
end

function Alliance:GetAttackMarchReturnEvents(march_type)
    local r = {}
    -- if not march_type then
    --     self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
    --         table.insert(r,attackMarchReturnEvent)
    --     end)
    -- else
    --     self:IteratorAttackMarchReturnEvents(function(attackMarchReturnEvent)
    --         if attackMarchReturnEvent:MarchType() == march_type then
    --             table.insert(r,attackMarchReturnEvent)
    --         end
    --     end)
    -- end
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
    -- if not march_type then
    --     self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
    --         table.insert(r,strikeMarchEvent)
    --     end)
    -- else
    --     self:IteratorStrikeMarchEvents(function(strikeMarchEvent)
    --         if strikeMarchEvent:MarchType() == march_type then
    --             table.insert(r,strikeMarchEvent)
    --         end
    --     end)
    -- end
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
    -- if not march_type then
    --     self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
    --         table.insert(r,strikeMarchReturnEvent)
    --     end)
    -- else
    --     self:IteratorStrikeMarchReturnEvents(function(strikeMarchReturnEvent)
    --         if strikeMarchReturnEvent:MarchType() == march_type then
    --             table.insert(r,strikeMarchReturnEvent)
    --         end
    --     end)
    -- end
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
    -- local village_id = villageEvent:VillageData().id
    -- local village = self:GetAllianceVillageInfosById(village_id)
    -- if not village and Alliance_Manager:HaveEnemyAlliance() then
    --     local enemy_alliance = Alliance_Manager:GetEnemyAlliance()
    --     village = enemy_alliance:GetAllianceVillageInfosById()[village_id]
    -- end
    -- if village then
    --     if villageEvent:GetTime() >= 0 then
    --         local left_resource = village.resource - villageEvent:CollectCount()
    --         self:NotifyListeneOnType(Alliance.LISTEN_TYPE.OnVillageEventTimer, function(listener)
    --             listener:OnVillageEventTimer(villageEvent,left_resource)
    --         end)
    --         if self:GetAllianceBelvedere()['OnVillageEventTimer'] then
    --             self:GetAllianceBelvedere():OnVillageEventTimer(villageEvent,left_resource)
    --         end
    --     end
    -- end
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
function Alliance:OnAllianceFightReportsChanged(alliance_data, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.allianceFightReports ~= nil
    if is_fully_update or is_delta_update then
        self.allianceFightReports = alliance_data.allianceFightReports
    end
end
function Alliance:IteratorVillageEvents(func)
    -- for _,v in pairs(self.villageEvents) do
    --     func(v)
    -- end
end

--有id为指定事件 没有id时获取所有采集事件
function Alliance:GetVillageEvent(id)
    if id then
        -- return self.villageEvents[id]
    else
        local r = {}
        -- self:IteratorVillageEvents(function(villageEvent)
        --     table.insert(r, villageEvent)
        -- end)
        return r
    end
end
function Alliance:FindVillageEventByVillageId(village_id)
    dump(self.villageEvents,"self.villageEvents")
    for _,v in pairs(self.villageEvents) do
        if v.villageData.id == village_id then
            return v
        end
    end
    -- return nil
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
function Alliance:GetAllianceBuildingInfoByName(name)
    for i,v in pairs(self.buildings) do
        if v.name == name then
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
    -- if marchEvent:GetPlayerRole() == marchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
    --     if not marchEvent:IsReturnEvent() then
    --         local marchType = marchEvent:MarchType()
    --         local msg = marchEvent:IsStrikeEvent() and _("你的城市正被敌军突袭") or _("你的城市正被敌军攻击")
    --         local warningTime = self:GetAllianceBelvedere():GetWarningTime()
    --         if marchType == 'city' then
    --             app:GetPushManager():UpdateWatchTowerPush(marchEvent:ArriveTime() - warningTime,msg,marchEvent:Id())
    --         end
    --     end
    -- end
end
--因为这里添加了音效效果 so 所有的事件删除都要调用此方法
function Alliance:cancelLocalMarchEventPushIf(marchEvent)
    if marchEvent:GetPlayerRole() == marchEvent.MARCH_EVENT_PLAYER_ROLE.RECEIVER then
        if marchEvent:IsReturnEvent() then
            if not marchEvent:IsStrikeEvent() then --我的一般进攻部队返回城市
                app:GetAudioManager():PlayeEffectSoundWithKey("TROOP_BACK")
            end
        else
            app:GetPushManager():CancelWatchTowerPush(marchEvent:Id())
        end
    end
end
return Alliance




