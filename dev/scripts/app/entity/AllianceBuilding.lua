--
-- Author: Danny He
-- Date: 2014-11-08 10:00:20
--
local AllianceBuilding = class("AllianceBuilding")
local property = import("..utils.property")
local Point = import(".Point")

function AllianceBuilding:ctor(name,location,level)
	property(self,"name",name)
	property(self,"level",level)
	property(self,"location",Point.new(location))
end

--TODO:
function AllianceBuilding:UpdateBuilding(json_data)
	self:SetName(json_data.name)
	self:SetLevel(json_data.level)
end

function AllianceBuilding:SetLocation(location)
	local old_location = self:Location()
	self:Location():Set(location)
	self:OnPropertyChange("location",old_location,self:Location())
end

--TODO:
function AllianceBuilding:OnPropertyChange(property_name, old_value, value)
	
end



return AllianceBuilding