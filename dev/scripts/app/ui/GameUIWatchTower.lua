local Localize = import("..utils.Localize")
local GameUIWatchTower = UIKit:createUIClass('GameUIWatchTower',"GameUIUpgradeBuilding")
local AllianceBelvedere = import("..entity.AllianceBelvedere")

function GameUIWatchTower:ctor(city,building)
    local bn = Localize.building_name
    GameUIWatchTower.super.ctor(self,city,bn[building:GetType()],building)
    self.belvedere = Alliance_Manager:GetMyAlliance():GetAllianceBelvedere()
end

function GameUIWatchTower:onEnter()
	GameUIWatchTower.super.onEnter(self)
	self:GetAllianceBelvedere():GetMyEvents()
	self:GetAllianceBelvedere():GetOtherEvents()
	self:AddOrRemoveListener(true)
end


function GameUIWatchTower:AddOrRemoveListener(isAdd)
	if isAdd then
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventDataChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnVillageEventsDataChanged)
	else
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventDataChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnVillageEventsDataChanged)
	end
end


function GameUIWatchTower:onCleanup()
	self:AddOrRemoveListener(false)
	GameUIWatchTower.super.onCleanup(self)
end

function GameUIWatchTower:GetAllianceBelvedere()
	return self.belvedere
end

return GameUIWatchTower