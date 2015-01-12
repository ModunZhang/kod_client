local config_function = GameDatas.BuildingFunction.townHall
local config_levelup = GameDatas.BuildingLevelUp.townHall
local PResourceUpgradeBuilding = import(".PResourceUpgradeBuilding")
local TownHallUpgradeBuilding = class("TownHallUpgradeBuilding", PResourceUpgradeBuilding)

function TownHallUpgradeBuilding:ctor(building_info)
    TownHallUpgradeBuilding.super.ctor(self, building_info)
end

function TownHallUpgradeBuilding:GetNextLevelDwellingNum()
    return config_function[self:GetNextLevel()].dwelling
end
return TownHallUpgradeBuilding