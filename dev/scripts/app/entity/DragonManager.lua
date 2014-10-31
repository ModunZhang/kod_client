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

function DragonManager:ctor()
	self.dragon_vatalitys_ = {}
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

-- vitality_recovery_perHour:从龙巢获取活力的增长的速度 TODO: vitality_recovery_perHour
function DragonManager:OnUserDataChanged(user_data, current_time, location_id, sub_location_id,vitality_recovery_perHour)
    self:RefreshDragonData(user_data.dragons)
end


function DragonManager:RefreshDragonData( dragons )
	printInfo("%s","DragonManager:RefreshDragonData....")
	if not self.dragons_ then -- 初始化龙信息
		self.dragons_ = {}
		for k,v in pairs(dragons) do
			local dragon = Dragon.new(k,v.strength,v.vitality,v.status,v.star,v.level,v.exp)
			dragon:UpdateEquipmetsAndSkills(v)
			self:AddDragon(dragon)
		end
	else
		 --遍历更新的龙信息
        for k,v in pairs(dragons) do
          	local dragon = self:GetDragon(k)
          	if dragon then
          		dragon:Update(v)
          	end
        end
	end

end

-- vitality

function DragonManager:AddVitalityResource(dragon_type)
	if not self:GetVitalityResource(dragon_type) then
		 self.dragon_vatalitys_[dragon_type] = AutomaticUpdateResource.new()
	end
	return self:GetVitalityResource(dragon_type) 
end


function DragonManager:GetVitalityResource(dragon_type)
	return self.dragon_vatalitys_[dragon_type]
end


function DragonManager:UpdateVitalityByTime(current_time)
    for _, v in pairs(self.dragon_vatalitys_) do
        v:OnTimer(current_time)
    end
end

function DragonManager:OnTimer(current_time)
    self:UpdateVitalityByTime(current_time)
end

return DragonManager