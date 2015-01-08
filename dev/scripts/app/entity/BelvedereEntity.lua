--
-- Author: Danny He
-- Date: 2015-01-08 16:21:15
--
local BelvedereEntity = class("BelvedereEntity")
local property = import("..utils.property")
local Enum = import("..utils.Enum")
local Localize = import("..utils.Localize")

BelvedereEntity.ENTITY_TYPE = Enum("NONE","MARCHING","COLLECT","HELPTO","SHIRNE","STRIKE")
function BelvedereEntity:OnPropertyChange()
end

function BelvedereEntity:ctor(object)
	property(self,"withObject",object)
end

function BelvedereEntity:SetType(entity_type)
	self.entity_type = entity_type
end

function BelvedereEntity:GetTypeStr()
	return self.ENTITY_TYPE[self:GetType()]
end
function BelvedereEntity:GetType()
	return self.entity_type
end

function BelvedereEntity:GetFrom()
end

function BelvedereEntity:GetTitle()
	if self:GetType() == self.ENTITY_TYPE.HELPTO then
		return  string.format(_("正在协防玩家%s"),self:WithObject().beHelpedPlayerData.name)
	elseif self:GetType() == self.ENTITY_TYPE.COLLECT then
		return _("正在进行村落采集")
	end
end

function BelvedereEntity:GetDestination()
	if self:GetType() == self.ENTITY_TYPE.HELPTO then
		return self:WithObject().beHelpedPlayerData.cityName
	elseif self:GetType() == self.ENTITY_TYPE.COLLECT then
		return Localize.village_name[self:WithObject():VillageData().type] .. "Lv" .. self:WithObject():VillageData().level
	end
end

function BelvedereEntity:GetDestinationLocation()
	if self:GetType() == self.ENTITY_TYPE.HELPTO then
		return "0,0"
	elseif self:GetType() == self.ENTITY_TYPE.COLLECT then
		-- return "村落 " .. self:WithObject():VillageData().type .. "LV" .. self:WithObject():VillageData().level
		local location = self:WithObject():TargetLocation()
		return location.x .. "," .. location.y
	end
end

function BelvedereEntity:GetDragonType()
	if self:GetType() == self.ENTITY_TYPE.HELPTO then
		return self:WithObject().playerDragon
	end
end

function BelvedereEntity:RetreatAction(cb)
	if self:GetType() == self.ENTITY_TYPE.HELPTO then
		NetManager:getRetreatFromHelpedAllianceMemberPromise(self:WithObject().beHelpedPlayerData.id)
			:next(function()
				cb(true)
			end)
			:catch(function(err)
				cb(false)
			end)
	elseif self:GetType() == self.ENTITY_TYPE.COLLECT then
		cb(true)
	end
end

return BelvedereEntity