

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
            dragon_manger:GetDragon("blueDragon"):IsDefenced()
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
        return is_finish_built_at(8, 22) or is_finish_recruit_soldiers("swordsman", 10)
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
        return false
    end,
}


return function(key)
    if not check_map[key] then return assert(false, key) end
    return not check_map[key]()
end





