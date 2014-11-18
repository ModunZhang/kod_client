--
-- Author: Danny He
-- Date: 2014-11-17 17:52:09
--
local ShrineReport = class("ShrineReport")
local property = import("..utils.property")

function ShrineReport:ctor()
	property(self,"id","")
	property(self,"star",0)
	property(self,"stageName","")
	property(self,"fightDatas",{})
	property(self,"playerDatas",{})
	property(self,"stage",{}) -- will be set in
end

function ShrineReport:OnPropertyChange()
end

function ShrineReport:Update(json_data)
	self:SetId(json_data.id)
	self:SetStar(json_data.star)
	self:SetStageName(json_data.stageName)
	self:SetFightDatas(json_data.fightDatas)
	self:SetPlayerDatas(json_data.playerDatas)
end

return ShrineReport