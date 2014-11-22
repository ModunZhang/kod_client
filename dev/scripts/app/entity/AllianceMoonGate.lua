local MultiObserver = import(".MultiObserver")
local property = import("..utils.property")
local AllianceMoonGate = class("AllianceMoonGate",MultiObserver)
local Enum = import("..utils.Enum")

AllianceMoonGate.LISTEN_TYPE = Enum(
    "OnMoonGateOwnerChanged",
    "OnOurTroopsChanged",
    "OnEnemyTroopsChanged",
    "OnCurrentFightTroopsChanged",
    "OnFightReportsChanged",
    "OnMoonGateMarchEventsChanged",
    "OnMoonGateMarchReturnEventsChanged",
    "OnMoonGateDataReset"
)
-- 数据处理函数
--------------------------------------------------------------------------------
local Event_Handler_Func = function(events,add_func,edit_func,remove_func)
    local not_hanler = function(...)end
    add_func = add_func or not_hanler
    remove_func = remove_func or not_hanler
    edit_func = edit_func or not_hanler

    local add,edit,remove = {},{},{}
    for _,event in ipairs(events) do
        if event.type == 'add' then
            table.insert(add,add_func(event.data))
        elseif event.type == 'edit' then
            table.insert(edit,edit_func(event.data))
        elseif event.type == 'remove' then
            table.insert(remove,remove_func(event.data))
        end
    end
    return {add,edit,remove} -- each of return is a table
end

local pack_map = function(map)
    local ret = {}
    local add,edit,remove = unpack(map)
    if #add > 0 then ret.add = checktable(add) end
    if #edit > 0 then ret.edit = checktable(edit) end
    if #remove > 0 then ret.remove = checktable(remove) end
    return ret
end
--------------------------------------------------------------------------------
property(AllianceMoonGate, "moonGateOwner", "")
property(AllianceMoonGate, "activeBy", "")

function AllianceMoonGate:ctor(alliance)
    AllianceMoonGate.super.ctor(self)
    self.alliance = alliance
    self.ourTroops = {}
    self.enemyTroops = {}
    self.currentFightTroops = {}
    self.fightReports = {}
    self.moonGateMarchEvents = {}
    self.moonGateMarchReturnEvents = {}
    self.enemyAlliance = {}
end

function AllianceMoonGate:GetAlliance()
    return self.alliance
end
function AllianceMoonGate:GetOurTroops()
    return self.ourTroops
end
function AllianceMoonGate:GetEnemyTroops()
    return self.enemyTroops
end
function AllianceMoonGate:GetCurrentFightTroops()
    return self.currentFightTroops
end
function AllianceMoonGate:GetFightReports()
    return self.fightReports
end
function AllianceMoonGate:GetMoonGateMarchEvents()
    return self.moonGateMarchEvents
end
function AllianceMoonGate:GetMoonGateMarchReturnEvents()
    return self.moonGateMarchReturnEvents
end
function AllianceMoonGate:GetEnemyAlliance()
    return self.enemyAlliance
end
function AllianceMoonGate:GetOurTroopsNum()
	local count = 0 
	for k,v in pairs(self.ourTroops) do
		count = count + 1
	end
    return count
end
function AllianceMoonGate:GetEnemyTroopsNum()
    local count = 0 
	for k,v in pairs(self.enemyTroops) do
		count = count + 1
	end
    return count
end

function AllianceMoonGate:Reset()
    self.ourTroops = {}
    self.enemyTroops = {}
    self.currentFightTroops = {}
    self.fightReports = {}
    self.moonGateMarchEvents = {}
    self.moonGateMarchReturnEvents = {}

    self.moonGateOwner = ""
    self.enemyAlliance = {}
    self.activeBy = ""
    self:NotifyListeneOnType(self.LISTEN_TYPE.OnMoonGateDataReset,function(listener)
        listener.OnMoonGateDataReset(listener)
    end)
end

function AllianceMoonGate:OnAllianceDataChanged(alliance_data)
    if alliance_data.moonGateData then
        -- 联盟战结束，清空月门数据, 返回的moonGateData为空表的时候代表联盟战结束
        local isOver = true
        for k,v in pairs(alliance_data.moonGateData) do
        	isOver = false
        	break
        end
        if isOver then
            self:Reset()
            return
        end
        if alliance_data.moonGateData.enemyAlliance then
            self.enemyAlliance = alliance_data.moonGateData.enemyAlliance
        end
        if alliance_data.moonGateData.activeBy then
            self.activeBy = alliance_data.moonGateData.activeBy
        end


        self:UpdateMoonGateOwner(alliance_data)
        self:UpdateOurTroops(alliance_data)
        self:UpdateEnemyTroops(alliance_data)
        self:UpdateCurrentFightTroops(alliance_data)
        self:UpdateFightReports(alliance_data)
    end
    self:UpdateMoonGateMarchEvents(alliance_data)
    self:UpdateMoonGateMarchReturnEvents(alliance_data)
end

function AllianceMoonGate:OnMoonGateOwnerChanged(moonGateOwner)
    self:NotifyListeneOnType(self.LISTEN_TYPE.OnMoonGateOwnerChanged,function(listener)
        listener.OnMoonGateOwnerChanged(listener,moonGateOwner)
    end)
end

function AllianceMoonGate:UpdateMoonGateOwner(alliance_data)
    if alliance_data.moonGateData.moonGateOwner then
        self.moonGateOwner = alliance_data.moonGateData.moonGateOwner
        self:OnMoonGateOwnerChanged(self.moonGateOwner)
    end
end

function AllianceMoonGate:UpdateOurTroops(alliance_data)
    if alliance_data.moonGateData.ourTroops then
        for k,v in pairs(alliance_data.moonGateData.ourTroops) do
            self.ourTroops[v.id] = v
        end
    end
    if alliance_data.moonGateData.__ourTroops then
        local changed_map = {
            add = {},
            edit = {},
            remove = {}
        }

        for _,v in ipairs(alliance_data.moonGateData.__ourTroops) do
            if changed_map[v.type] then
                table.insert(changed_map[v.type],v.data)
            end
        end
        self:RefreshOurTroops(changed_map)
    end
end

function AllianceMoonGate:RefreshOurTroops(changed_map)
    for k,v in pairs(changed_map.add) do
        self.ourTroops[v.id] = v
    end
    for k,v in pairs(changed_map.edit) do
        self.ourTroops[v.id] = v
    end
    for k,v in pairs(changed_map.remove) do
        self.ourTroops[v.id] = nil
    end
    self:OnOurTroopsChanged(changed_map)
end

function AllianceMoonGate:OnOurTroopsChanged(changed_map)
    self:NotifyListeneOnType(self.LISTEN_TYPE.OnOurTroopsChanged,function(listener)
        listener.OnOurTroopsChanged(listener,changed_map)
    end)
end

function AllianceMoonGate:RefreshEnemyTroops(changed_map)
    for k,v in pairs(changed_map.add) do
        self.enemyTroops[v.id] = v
    end
    for k,v in pairs(changed_map.edit) do
        self.enemyTroops[v.id] = v
    end
    for k,v in pairs(changed_map.remove) do
        self.enemyTroops[v.id] = nil
    end
    self:OnEnemyTroopsChanged(changed_map)
end

function AllianceMoonGate:OnEnemyTroopsChanged(changed_map)
    self:NotifyListeneOnType(self.LISTEN_TYPE.OnEnemyTroopsChanged,function(listener)
        listener.OnEnemyTroopsChanged(listener,changed_map)
    end)
end

function AllianceMoonGate:UpdateEnemyTroops(alliance_data)
    if alliance_data.moonGateData.enemyTroops then
        for k,v in pairs(alliance_data.moonGateData.enemyTroops) do
            self.enemyTroops[v.id] = v
        end
    end
    if alliance_data.moonGateData.__enemyTroops then
        local changed_map = {
            add = {},
            edit = {},
            remove = {}
        }

        for _,v in ipairs(alliance_data.moonGateData.__enemyTroops) do
            if changed_map[v.type] then
                table.insert(changed_map[v.type],v.data)
            end
        end

        self:RefreshEnemyTroops(changed_map)
    end
end

function AllianceMoonGate:UpdateCurrentFightTroops(alliance_data)
    if alliance_data.moonGateData.currentFightTroops then
        self.currentFightTroops = alliance_data.moonGateData.currentFightTroops
        self:NotifyListeneOnType(self.LISTEN_TYPE.OnCurrentFightTroopsChanged,function(listener)
            listener.OnCurrentFightTroopsChanged(listener,self.currentFightTroops)
        end)
    end
end

function AllianceMoonGate:OnFightReportsChanged(changed_map)
    self:NotifyListeneOnType(self.LISTEN_TYPE.OnFightReportsChanged,function(listener)
        listener.OnFightReportsChanged(listener,changed_map)
    end)
end

function AllianceMoonGate:UpdateFightReports(alliance_data)
    if alliance_data.moonGateData.fightReports then
        self.fightReports = alliance_data.moonGateData.fightReports
    end
    if alliance_data.moonGateData.__fightReports then
        local changed_map = {
            add = {},
        }-- 战报只会增加

        for _,v in ipairs(alliance_data.moonGateData.__fightReports) do
            if changed_map[v.type] then
                table.insert(changed_map[v.type],v.data)
                table.insert(self.fightReports,v.data)
            end
        end

        self:OnFightReportsChanged(changed_map)
    end
end

function AllianceMoonGate:RefreshMoonGateMarchEvents(changed_map)
    for k,v in pairs(changed_map) do
        if k=="add" or k=="edit" then
            for _,event in pairs(v) do
                self.moonGateMarchEvents[event.id] = event
            end
        elseif k=="remove" then
            for _,event in pairs(v) do
                self.moonGateMarchEvents[event.id] = nil
            end
        end
    end
    self:OnMoonGateMarchEventsChanged(changed_map)
end

function AllianceMoonGate:OnMoonGateMarchEventsChanged(changed_map)
    self:NotifyListeneOnType(self.LISTEN_TYPE.OnMoonGateMarchEventsChanged,function(listener)
        listener.OnMoonGateMarchEventsChanged(listener,changed_map)
    end)
end

function AllianceMoonGate:UpdateMoonGateMarchEvents(alliance_data)
    if alliance_data.moonGateMarchEvents then
        self.moonGateMarchEvents = alliance_data.moonGateMarchEvents
    end
    if alliance_data.__moonGateMarchEvents then
        local changed_map = {
            add = {},
            edit = {},
            remove = {}
        }

        for _,v in ipairs(alliance_data.__moonGateMarchEvents) do
            if changed_map[v.type] then
                table.insert(changed_map[v.type],v.data)
            end
        end
        self:RefreshMoonGateMarchEvents(changed_map)
    end
end
function AllianceMoonGate:RefreshMoonGateMarchReturnEvents(changed_map)
    for k,v in pairs(changed_map) do
        if k=="add" or k=="edit" then
            for _,event in pairs(v) do
                self.moonGateMarchReturnEvents[event.id] = event
            end
        elseif k=="remove" then
            for _,event in pairs(v) do
                self.moonGateMarchReturnEvents[event.id] = nil
            end
        end
    end
    self:OnMoonGateMarchReturnEventsChanged(changed_map)
end
function AllianceMoonGate:OnMoonGateMarchReturnEventsChanged(changed_map)
    self:NotifyListeneOnType(self.LISTEN_TYPE.OnMoonGateMarchReturnEventsChanged,function(listener)
        listener.OnMoonGateMarchReturnEventsChanged(listener,changed_map)
    end)
end

function AllianceMoonGate:UpdateMoonGateMarchReturnEvents(alliance_data)
    if alliance_data.moonGateMarchReturnEvents then
        self.moonGateMarchReturnEvents = alliance_data.moonGateMarchReturnEvents
    end
    if alliance_data.__moonGateMarchReturnEvents then
        local changed_map = {
            add = {},
            edit = {},
            remove = {}
        }

        for _,v in ipairs(alliance_data.__moonGateMarchReturnEvents) do
            if changed_map[v.type] then
                table.insert(changed_map[v.type],v.data)
            end
        end
        self:RefreshMoonGateMarchReturnEvents(changed_map)
    end
end


return AllianceMoonGate