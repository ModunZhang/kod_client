local MultiObserver = import(".MultiObserver")
local property = import("..utils.property")
local AllianceMoonGate = class("AllianceMoonGate",MultiObserver)
local Enum = import("..utils.Enum")

AllianceMoonGate.LISTEN_TYPE = Enum(
	"OnPerceotionChanged",
	"OnNewStageOpened",
	"OnFightEventTimerChanged",
	"OnShrineEventsChanged",
	"OnMarchEventsChanged",
	"OnMarchReturnEventsChanged",
	"OnMarchEventTimerChanged",
	"OnShrineReportsChanged"
)
-- 数据处理函数
--------------------------------------------------------------------------------
local Event_Handler_Func = function(events,add_func,edit_func,remove_func)
	local not_hanler = function(...)end
	add_func = add_func or not_hanler
	remove_func = remove_func or not_hanler
	edit_func = edit_func or not_hanler

	local added,edited,removed = {},{},{}
	for _,event in ipairs(events) do
		if event.type == 'add' then
			table.insert(added,add_func(event.data))
		elseif event.type == 'edit' then
			table.insert(edited,edit_func(event.data))
		elseif event.type == 'remove' then
			table.insert(removed,remove_func(event.data))
		end
	end
	return {added,edited,removed} -- each of return is a table
end

local pack_map = function(map)
	local ret = {}
	local added,edited,removed = unpack(map)
	if #added > 0 then ret.added = checktable(added) end
	if #edited > 0 then ret.edited = checktable(edited) end
	if #removed > 0 then ret.removed = checktable(removed) end
	return ret
end
--------------------------------------------------------------------------------
property(AllianceMoonGate, "moonGateOwner", "__NONE__")
property(AllianceMoonGate, "enemyAllianceId", "")
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
end

function AllianceMoonGate:GetAlliance()
	return self.alliance
end

function AllianceMoonGate:Reset()
	self.ourTroops = {}
	self.enemyTroops = {}
	self.currentFightTroops = {}
	self.fightReports = {}
	self.moonGateMarchEvents = {}
	self.moonGateMarchReturnEvents = {}

	self.moonGateOwner = "__NONE__"
	self.enemyAllianceId = ""
	self.activeBy = ""
end

function AllianceMoonGate:OnAllianceDataChanged(alliance_data)
	
end

return AllianceMoonGate