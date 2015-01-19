--
-- Author: Danny He
-- Date: 2015-01-15 20:06:17
--
local config_productiontechlevelup = GameDatas.ProductionTechLevelUp
local ProductionTechnology = class("ProductionTechnology")
local property = import("..utils.property")
local productionTechs = GameDatas.ProductionTechs.productionTechs
local Localize = import("..utils.Localize")
function ProductionTechnology:ctor()
	property(self,"index","")
	property(self,"level","")
	property(self,"name","")
	property(self,"unlockBy","")
	property(self,"unlockLevel","")
	property(self,"effectPerLevel","")
	property(self,"enable",true)
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

function ProductionTechnology:GetLevelUpCost()
	if self:IsOpen() and config_productiontechlevelup[self:Name()] and config_productiontechlevelup[self:Name()][self:GetNextLevel()] then
		return config_productiontechlevelup[self:Name()][self:GetNextLevel()]
	end
	return nil
end

function ProductionTechnology:GetNextLevel()
	if self:Level() < 15 then
		return self:Level() + 1
	end
end

function ProductionTechnology:GetImageName()
	return "technology_icon_123x123.png"
end

function ProductionTechnology:GetLocalizedName()
	return Localize.productiontechnology_name[self:Name()] or ""
end

function ProductionTechnology:GetBuffLocalizedDesc()
	return Localize.productiontechnology_buffer[self:Name()] or ""
end

function ProductionTechnology:GetBuffEffectVal()
	return self:Level() * self:EffectPerLevel()
end
function ProductionTechnology:GetNextLevelBuffEffectVal()
	if self:GetNextLevel() then
		return self:GetNextLevel() * self:EffectPerLevel()
	end
end
function ProductionTechnology:IsReachLimitLevel()
	return self:Level() >= 15
end

function ProductionTechnology:IsOpen()
	return self:Index() < 10
end

return ProductionTechnology