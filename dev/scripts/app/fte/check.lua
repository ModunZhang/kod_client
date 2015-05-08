

local function is_finish_upgrade_building_by_level(building_type, level)
    local building = City:GetFirstBuildingByType(building_type)
    return building:GetLevel() > level or (building:GetLevel() == level and building:IsUpgrading())
end
local function is_finish_speedup_building_by_level(building_type, level)
    local building = City:GetFirstBuildingByType(building_type)
    return building:GetLevel() > level
end
local function is_finish_built_at(x_, y_)
    for k,v in pairs(City:GetAllDecorators()) do
        local x,y = v:GetLogicPosition()
        if x == x_ and y == y_ then
            return true
        end
    end
    return false
end
local function is_finish_upgrade_at(x_, y_, level)
    for k,v in pairs(City:GetAllDecorators()) do
        local x,y = v:GetLogicPosition()
        if x == x_ and y == y_ then
            return v:GetLevel() > level or (v:GetLevel() == level and v:IsUpgrading())
        end
    end
    return false
end
local function is_finish_speed_at(x_, y_, level)
    local house = City:GetDecoratorByPosition(x_, y_)
    return house and house:GetLevel() > level
end
local function is_finish_recruit_soldiers(type_, count)
    return City:GetSoldierManager():GetCountBySoldierType(type_) >= count
end
local function is_fight_in_pve()
    return User:GetPVEDatabase():GetMapByIndex(1):SearchedObjectsCount() > 0
end
local check_map = {
    ["HateDragon"] = function()
        local dragon_manger = City:GetDragonEyrie():GetDragonManager()
        return dragon_manger:GetDragon("redDragon"):Ishated() or
            dragon_manger:GetDragon("greenDragon"):Ishated() or
            dragon_manger:GetDragon("blueDragon"):Ishated()
    end,
    ["DefenceDragon"] = function()
        local dragon_manger = City:GetDragonEyrie():GetDragonManager()
        return dragon_manger:GetDragon("redDragon"):IsDefenced() or
            dragon_manger:GetDragon("greenDragon"):IsDefenced() or
            dragon_manger:GetDragon("blueDragon"):IsDefenced() or
            City:GetFirstBuildingByType("keep"):GetLevel() > 1 or
            #City:GetAllDecorators() > 0 or
            is_finish_recruit_soldiers("swordsman", 1)
    end,
    ["BuildDwelling_18x12"] = function()
        return is_finish_built_at(18, 12)
    end,
    ["FreeSpeedUpDwelling_18x12"] = function()
        return is_finish_speed_at(18, 12, 0)
    end,
    ["UpgradeKeep1"] = function()
        return is_finish_upgrade_building_by_level("keep", 1)
    end,
    ["FreeSpeedUpKeep1"] = function()
        return is_finish_speedup_building_by_level("keep", 1)
    end,
    ["UnlockBarracks0"] = function()
        return is_finish_upgrade_building_by_level("barracks", 0)
    end,
    ["SpeedupBarracks0"] = function()
        return is_finish_speedup_building_by_level("barracks", 0)
    end,
    ["RecruitSoldiers"] = function()
        return is_finish_recruit_soldiers("swordsman", 10) or is_fight_in_pve()
    end,
    ["BuildFarmer_8x22"] = function()
        return is_finish_built_at(8, 22)
    end,
    ["FreeSpeedUpFarmer_8x22"] = function()
        return is_finish_speed_at(8, 22, 0)
    end,
    ["UpgradeFarmer1_8x22"] = function()
        return is_finish_upgrade_at(8, 22, 1)
    end,
    ["FreeSpeedUpFarmer1_8x22"] = function()
        return is_finish_speed_at(8, 22, 1)
    end,
    ["ExplorePve"] = function()
        return is_fight_in_pve() or
                City:GetFirstBuildingByType("keep"):GetLevel() > 2
    end,
    ["ActiveVip"] = function()
        return User:IsVIPActived() or 
                City:GetFirstBuildingByType("keep"):GetLevel() > 2
    end,
    ["UpgradeKeep2"] = function()
        return is_finish_upgrade_building_by_level("keep", 2)
    end,
    ["FreeSpeedUpKeep2"] = function()
        return is_finish_speedup_building_by_level("keep", 2)
    end,
    ["UpgradeKeep3"] = function()
        return is_finish_upgrade_building_by_level("keep", 3)
    end,
    ["FreeSpeedUpKeep3"] = function()
        return is_finish_speedup_building_by_level("keep", 3)
    end,
    ["UpgradeKeep4"] = function()
        return is_finish_upgrade_building_by_level("keep", 4)
    end,
    ["FreeSpeedUpKeep4"] = function()
        return is_finish_speedup_building_by_level("keep", 4)
    end,
    ["UnlockHospital0"] = function()
        return is_finish_upgrade_building_by_level("hospital", 0)
    end,
    ["SpeedupHospital0"] = function()
        return is_finish_speedup_building_by_level("hospital", 0)
    end,
    ["UnlockAcademy0"] = function()
        return is_finish_upgrade_building_by_level("academy", 0)
    end,
    ["SpeedupAcademy0"] = function()
        return is_finish_speedup_building_by_level("academy", 0)
    end,
    ["UnlockMaterialDepot0"] = function()
        return is_finish_upgrade_building_by_level("materialDepot", 0)
    end,
    ["SpeedupMaterialDepot0"] = function()
        return is_finish_speedup_building_by_level("materialDepot", 0)
    end,
    ["BuildWoodcutter_18x22"] = function()
        return is_finish_built_at(18, 22)
    end,
    ["FreeSpeedUpWoodcutter_18x22"] = function()
        return is_finish_speed_at(18, 22, 0)
    end,
    ["BuildQuarrier_28x22"] = function()
        return is_finish_built_at(28, 22)
    end,
    ["FreeSpeedUpQuarrier_28x22"] = function()
        return is_finish_speed_at(28, 22, 0)
    end,
    ["BuildMiner_28x12"] = function()
        return is_finish_built_at(28, 12)
    end,
    ["FreeSpeedUpMiner_28x12"] = function()
        return is_finish_speed_at(28, 12, 0)
    end,
    ["GetRewards"] = function()
        return User:GetTaskManager():IsGetAnyCityBuildRewards()
    end,
    ["ALL"] = function()
        local count = 0
        for i,v in ipairs(City:GetAllBuildings()) do
            if v:GetLevel() > 1 then
                count = count + 1
            end
        end
        return not (count > 1 or User:GetTaskManager():IsGetAnyCityBuildRewards())
    end
}


return function(key)
    if not check_map[key] then return assert(false, key) end
    local is_finished = not check_map[key]()
    print(string.format("check [ %s ] : %s", key, is_finished and "true" or "false"))
    return is_finished
end





