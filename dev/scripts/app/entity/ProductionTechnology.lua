--
-- Author: Danny He
-- Date: 2015-01-15 20:06:17
--
local ProductionTechnology = class("ProductionTechnology")
local property = import("..utils.property")
local productionTechs = GameDatas.ProductionTechs.productionTechs

function ProductionTechnology:ctor()
	property(self,"index","")
	property(self,"level","")
	property(self,"name","")
	property(self,"unlockBy","")
	property(self,"unlockLevel","")
	property(self,"effectPerLevel","")
	property(self,"isLock",true)
end

function ProductionTechnology:UpdateData(name,json_data)
	self:SetName(name or "")
	self:SetIndex(json_data.index or 0)
	self:SetLevel(json_data.level or 0)
	local tech = productionTechs[self:Name()]
	self:SetUnlockBy(tech.unlockBy)
	self:SetUnlockLevel(tech.unlockLevel)
	self:SetEffectPerLevel(tech.effectPerLevel)
end

function ProductionTechnology:OnPropertyChange()
end


return ProductionTechnology