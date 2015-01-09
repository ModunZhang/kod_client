--
-- Author: Danny He
-- Date: 2015-01-08 16:21:15
--
local BelvedereEntity = class("BelvedereEntity")
local property = import("..utils.property")
local Enum = import("..utils.Enum")
local Localize = import("..utils.Localize")

BelvedereEntity.ENTITY_TYPE = Enum("NONE","MARCH_OUT","MARCH_RETURN","COLLECT","HELPTO","SHIRNE","STRIKE_OUT","STRIKE_RETURN")
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
	elseif self:GetType() == self.ENTITY_TYPE.MARCH_OUT then
		local march_type = self:WithObject():MarchType()
		if march_type == 'city' then
			return _("进攻玩家城市(行军中)")
		elseif march_type == 'helpDefence' then
			return _("协防玩家城市(行军中)")
		elseif march_type == 'village' then
			return _("占领村落(行军中)")
		elseif march_type == 'shrine' then
			return _("攻打联盟圣地(行军中)")
		end
	elseif self:GetType() == self.ENTITY_TYPE.MARCH_RETURN then
		local march_type = self:WithObject():MarchType()
		if march_type == 'city' then
			return _("进攻玩家城市(返回中)")
		elseif march_type == 'helpDefence' then
			return _("协防玩家城市(返回中)")
		elseif march_type == 'village' then
			return _("占领村落(返回中)")
		elseif march_type == 'shrine' then
			return _("攻打联盟圣地(返回中)")
		end
	elseif self:GetType() == self.ENTITY_TYPE.STRIKE_OUT then
		local march_type = self:WithObject():MarchType()
		if march_type == 'city' then
			return _("突袭玩家城市(行军中)")
		elseif march_type == 'village' then
			return _("突袭村落(行军中)")
		end
	elseif self:GetType() == self.ENTITY_TYPE.STRIKE_RETURN then
		local march_type = self:WithObject():MarchType()
		if march_type == 'city' then
			return _("突袭玩家城市(返回中)")
		elseif march_type == 'village' then
			return _("突袭村落(返回中)")
		end
	elseif self:GetType() == self.ENTITY_TYPE.SHIRNE then
		return self:WithObject():Stage():GetDescStageName()
	end
end

function BelvedereEntity:GetDestination()
	if self:GetType() == self.ENTITY_TYPE.HELPTO then

		return self:WithObject().beHelpedPlayerData.cityName
	elseif self:GetType() == self.ENTITY_TYPE.COLLECT then

		return Localize.village_name[self:WithObject():VillageData().type] .. "Lv" .. self:WithObject():VillageData().level
	elseif self:GetType() == self.ENTITY_TYPE.MARCH_OUT  
		or self:GetType() == self.ENTITY_TYPE.MARCH_RETURN 
		or self:GetType() == self.ENTITY_TYPE.STRIKE_OUT 
		or self:GetType() == self.ENTITY_TYPE.STRIKE_RETURN 
		then

		if self:WithObject():MarchType() == 'city' or self:WithObject():MarchType() == 'helpDefence' then
			return self:WithObject():GetDefenceData().cityName
		elseif self:WithObject():MarchType() == 'village' then
			local village_data = self:WithObject():GetDefenceData() 
			return Localize.village_name[village_data.type] .. "Lv" .. village_data.level
		elseif self:WithObject():MarchType() == 'shrine' then
			return _("攻打联盟圣地")
		end
	elseif self:GetType() == self.ENTITY_TYPE.SHIRNE then
		return _("圣地事件")
	end
end

function BelvedereEntity:GetDestinationLocation()
	if self:GetType() == self.ENTITY_TYPE.HELPTO then

		return "0,0"
	elseif self:GetType() == self.ENTITY_TYPE.COLLECT then

		local location = self:WithObject():TargetLocation()
		return location.x .. "," .. location.y
	elseif self:GetType() == self.ENTITY_TYPE.MARCH_OUT  
		or self:GetType() == self.ENTITY_TYPE.MARCH_RETURN 
		or self:GetType() == self.ENTITY_TYPE.STRIKE_OUT 
		or self:GetType() == self.ENTITY_TYPE.STRIKE_RETURN 
		then

		return self:WithObject():GetDefenceData().location.x .. "," .. self:WithObject():GetDefenceData().location.y
	elseif self:GetType() == self.ENTITY_TYPE.SHIRNE then
		local location =  self:FindShrinePlayerTroops().location
		return location.x .. "," .. location.y
	end
end

function BelvedereEntity:GetDragonType()
	if self:GetType() == self.ENTITY_TYPE.HELPTO then
		return self:WithObject().playerDragon
	elseif self:GetType() == self.ENTITY_TYPE.MARCH_OUT  
		or self:GetType() == self.ENTITY_TYPE.MARCH_RETURN 
		or self:GetType() == self.ENTITY_TYPE.STRIKE_OUT 
		or self:GetType() == self.ENTITY_TYPE.STRIKE_RETURN 
		then
		return self:WithObject():AttackPlayerData().dragon.type
	elseif self:GetType() == self.ENTITY_TYPE.SHIRNE then
		return self:FindShrinePlayerTroops().dragon.type
	end
end

function BelvedereEntity:FindShrinePlayerTroops()
	if  self:GetType() == self.ENTITY_TYPE.SHIRNE then 
		local troops = self:WithObject():PlayerTroops()
		for _,v in ipairs(troops) do
			if v.id == DataManager:getUserData()._id then
				return v
			end
		end

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
		NetManager:getRetreatFromVillagePromise(self:WithObject():VillageData().alliance.id,self:WithObject():Id()):next(function()
			cb(true)
		end):catch(function()
			cb(false)
		end)
	elseif self:GetType() == self.ENTITY_TYPE.MARCH_OUT then
		cb(true)	
	end
end

function BelvedereEntity:SpeedAction(cb)
	if self:GetType() == self.ENTITY_TYPE.MARCH_OUT then
		cb(true)
	elseif self:GetType() == self.ENTITY_TYPE.STRIKE_OUT then
		cb(true)
	else
		assert(false)
	end
end

return BelvedereEntity