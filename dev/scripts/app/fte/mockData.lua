local DiffFunction = import("..utils.DiffFunction")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local BuildingLevelUp = GameDatas.BuildingLevelUp
local house_levelup_config = GameDatas.HouseLevelUp
local locations = GameDatas.ClientInitGame.locations

local function mock(t)
    local delta = DiffFunction(DataManager:getFteData(), t)
    dump(t)
    dump(delta)
    DataManager:setFteUserDeltaData(delta)
end
local function remove_global_shceduler()
    if DataManager.handle__ then
        scheduler.unscheduleGlobal(DataManager.handle__)
        DataManager.handle__ = nil
    end
end



local function HateDragon(type_)
    local dragon_str = string.format("dragons.%s", type_)
    mock{
        {dragon_str..".hpRefreshTime", NetManager:getServerTime()},
        {dragon_str..".star", 1},
        {dragon_str..".exp", 0},
        {dragon_str..".level", 1},
        {dragon_str..".hp", 60},
    }
end
local function DefenceDragon(type_)
    local dragon_str = string.format("dragons.%s", type_)
    mock{
        {dragon_str..".status", "defence"},
    }
end



local function FinishBuildHouseAt(building_location_id)
    remove_global_shceduler()
    mock{
        {"houseEvents.0", json.null},
        {string.format("buildings.location_%d.houses.1.level", building_location_id), 1}
    }
end
local function BuildHouseAt(building_location_id, house_location_id, house_type)
    local start_time = NetManager:getServerTime()
    local build_time = house_levelup_config[house_type][1].buildTime
    mock{
        {
            "houseEvents.0",
            {
                id  = 1,
                buildingLocation = building_location_id,
                houseLocation = house_location_id,
                startTime = start_time,
                finishTime = start_time + build_time * 1000
            }
        },
        {
            string.format("buildings.location_%d.houses.1", building_location_id),
            {
                type = house_type,
                level = 0,
                location = house_location_id
            }
        }
    }

    DataManager.handle__ = scheduler.performWithDelayGlobal(function()
        if DataManager:getFteData().houseEvents and #DataManager:getFteData().houseEvents > 0 then
            FinishBuildHouseAt(building_location_id)
        end
    end, build_time)
end



local function FinishUpgradingBuilding(type, level)
    remove_global_shceduler()
    local location_id
    for i,v in ipairs(locations) do
        if v.building_type == type then
            location_id = v.index
            break
        end
    end
    assert(location_id)
    mock{
        {
            "buildingEvents.0", json.null
        },
        {
            string.format("buildings.location_%d.level", location_id), level
        }
    }
end
local function UpgradeBuildingTo(type, level)
    local location_id
    for i,v in ipairs(locations) do
        if v.building_type == type then
            location_id = v.index
            break
        end
    end
    assert(location_id)
    local start_time = NetManager:getServerTime()
    local buildTime = BuildingLevelUp[type][level].buildTime
    mock{
        {"buildingEvents.0",
            {
                id = 1,
                startTime = start_time,
                finishTime = start_time + buildTime * 1000,
                location = location_id,
            }
        }
    }

    DataManager.handle__ = scheduler.performWithDelayGlobal(function()
        if DataManager:getFteData().buildingEvents and #DataManager:getFteData().buildingEvents > 0 then
            FinishUpgradingBuilding(type, level)
        end
    end, buildTime)
end


return {
    HateDragon = HateDragon,
    DefenceDragon = DefenceDragon,
    BuildHouseAt = BuildHouseAt,
    FinishBuildHouseAt = FinishBuildHouseAt,
    UpgradeBuildingTo = UpgradeBuildingTo,
    FinishUpgradingBuilding = FinishUpgradingBuilding,
}









