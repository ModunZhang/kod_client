--
-- Author: Danny He
-- Date: 2014-10-27 21:33:54
--
local Enum = import("app.utils.Enum")
local property = import("app.utils.property")
local MultiObserver = import("app.entity.MultiObserver")
local DragonManager = class("DragonManager", MultiObserver)
local AutomaticUpdateResource = import(".AutomaticUpdateResource")
local Dragon = import(".Dragon")

DragonManager.DRAGON_TYPE_INDEX = Enum("redDragon","greenDragon","blueDragon")
DragonManager.LISTEN_TYPE = Enum("OnHPChanged","OnBasicChanged","OnDragonHatched")

function DragonManager:ctor()
	DragonManager.super.ctor(self)
	self.dragons_hp = {}
end

function DragonManager:Dragon_Index_To_Type(type_index)
	for k,v in pairs(DragonManager.DRAGON_TYPE_INDEX) do
		if type_index == v then
			return k
		end
	end
	return nil
end

function DragonManager:GetDragonByIndex(index)
	local dragon_type = self:Dragon_Index_To_Type(index)
	return self:GetDragon(dragon_type)
end

function DragonManager:GetDragon(dragon_type)
	if not dragon_type then return nil end
	return self.dragons_[dragon_type]
end

function DragonManager:AddDragon(dragon)
	self.dragons_[dragon:Type()] = dragon
end

function DragonManager:OnUserDataChanged(user_data, current_time, location_id, sub_location_id,hp_recovery_perHour)
    self:RefreshDragonData(user_data.dragons,current_time,hp_recovery_perHour)
end


function DragonManager:RefreshDragonData( dragons,resource_refresh_time,hp_recovery_perHour)
	if not self.dragons_ then -- 初始化龙信息
		self.dragons_ = {}
		for k,v in pairs(dragons) do
			local dragon = Dragon.new(k,v.strength,v.vitality,v.status,v.star,v.level,v.exp,v.hp or 0)
			dragon:UpdateEquipmetsAndSkills(v)
			self:AddDragon(dragon)
			self:checkHPRecoveryIf_(dragon,resource_refresh_time,hp_recovery_perHour)
		end
	else
		 --遍历更新龙信息
		if not dragons then return end
        for k,v in pairs(dragons) do
          	local dragon = self:GetDragon(k)
          	if dragon then
          		local dragonIsHated_ = dragon:Ishated()
          		dragon:Update(v) -- include UpdateEquipmetsAndSkills
				if dragonIsHated_ ~= dragon:Ishated() then
					self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnDragonHatched,function(lisenter)
						lisenter.OnDragonHatched(lisenter)
					end)
				else
	  				self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnBasicChanged,function(lisenter)
						lisenter.OnBasicChanged(lisenter)
					end)
				end
          	end
          	self:checkHPRecoveryIf_(dragon,resource_refresh_time,hp_recovery_perHour)
        end
	end
end


function DragonManager:checkHPRecoveryIf_(dragon,resource_refresh_time,hp_recovery_perHour)
	if dragon:Ishated() then
		local hp_resource = self:AddHPResource(dragon:Type())
		hp_resource:UpdateResource(resource_refresh_time,dragon:Hp())
        hp_resource:SetProductionPerHour(resource_refresh_time,hp_recovery_perHour)
        hp_resource:SetValueLimit(dragon:GetMaxHP())
	end
end

-- HP
function DragonManager:AddHPResource(dragon_type)
	if not self:GetHPResource(dragon_type) then
		 self.dragons_hp[dragon_type] = AutomaticUpdateResource.new()
	end
	return self:GetHPResource(dragon_type) 
end


function DragonManager:GetHPResource(dragon_type)
	return self.dragons_hp[dragon_type]
end

function DragonManager:GetCurrentHPValueByDragonType(dragon_type)
	if not self:GetHPResource(dragon_type) then
		return -1
	end
	return self:GetHPResource(dragon_type):GetResourceValueByCurrentTime(app.timer:GetServerTime())
end

function DragonManager:UpdateHPResourceByTime(current_time)
    for _, v in pairs(self.dragons_hp) do
        v:OnTimer(current_time)
    end
end

function DragonManager:OnTimer(current_time)
    self:UpdateHPResourceByTime(current_time)
    self:OnHPChanged()
end

function DragonManager:OnHPChanged()
	self:NotifyListeneOnType(DragonManager.LISTEN_TYPE.OnHPChanged,function(lisenter)
		lisenter.OnHPChanged(lisenter)
	end)
end

--充能每次消耗的能量值
function DragonManager:GetEnergyCost()
	return 20
end

return DragonManager