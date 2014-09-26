
local config_function = GameDatas.BuildingFunction.hospital
local UpgradeBuilding = import(".UpgradeBuilding")
local HospitalUpgradeBuilding = class("HospitalUpgradeBuilding", UpgradeBuilding)

function HospitalUpgradeBuilding:ctor(building_info)
    HospitalUpgradeBuilding.super.ctor(self, building_info)
end
--获取伤病最大上限
function HospitalUpgradeBuilding:GetMaxCasualty()
	return config_function[self:GetLevel()].maxCasualty
end
--获取战斗伤病比例
function HospitalUpgradeBuilding:GetCasualtyRate()
	return config_function[self:GetLevel()].casualtyRate
end

return HospitalUpgradeBuilding


