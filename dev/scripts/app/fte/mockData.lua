local DiffFunction = import("..utils.DiffFunction")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local BuildingLevelUp = GameDatas.BuildingLevelUp
local HouseLevelUp = GameDatas.HouseLevelUp
local locations = GameDatas.ClientInitGame.locations
local normal = GameDatas.Soldiers.normal

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



local function FinishBuildHouseAt(building_location_id, level)
    remove_global_shceduler()
    mock{
        {"houseEvents.0", json.null},
        {string.format("buildings.location_%d.houses.1.level", building_location_id), level}
    }
end
local function BuildHouseAt(building_location_id, house_location_id, house_type)
    local start_time = NetManager:getServerTime()
    local buildTime = HouseLevelUp[house_type][1].buildTime
    mock{
        {
            "houseEvents.0",
            {
                id  = 1,
                buildingLocation = building_location_id,
                houseLocation = house_location_id,
                startTime = start_time,
                finishTime = start_time + buildTime * 1000
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
    end, buildTime)
end
local function UpgradeHouseTo(building_location_id, house_location_id, house_type, level)
    local start_time = NetManager:getServerTime()
    local buildTime = HouseLevelUp[house_type][level].buildTime
    mock{
        {
            "houseEvents.0",
            {
                id = 1,
                buildingLocation = building_location_id,
                houseLocation = house_location_id,
                startTime = start_time,
                finishTime = start_time + buildTime * 1000
            }
        }
    }

    DataManager.handle__ = scheduler.performWithDelayGlobal(function()
        if DataManager:getFteData().houseEvents and #DataManager:getFteData().houseEvents > 0 then
            FinishBuildHouseAt(building_location_id, level)
        end
    end, buildTime)
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


local function FinishRecruitSoldier()
    if DataManager.handle_soldier__ then
        scheduler.unscheduleGlobal(DataManager.handle_soldier__)
        DataManager.handle_soldier__ = nil
    end
    local soldierEvents = DataManager:getFteData().soldierEvents
    if soldierEvents and #soldierEvents > 0 then
        mock{
            {"soldierEvents.0", json.null},
            {"soldiers.name", soldierEvents.count}
        }
    end
end

local function RecruitSoldier(type_, count)
    local recruitTime = normal[type_.."_1"].recruitTime * count
    mock{
        {
            "soldierEvents.0",
            {
                id = 1,
                name = type_,
                count = count,
                startTime = NetManager:getServerTime(),
                finishTime = NetManager:getServerTime() + recruitTime * 1000
            }
        }
    }
    DataManager.handle_soldier__ = scheduler.performWithDelayGlobal(function()
        if DataManager:getFteData().soldierEvents and #DataManager:getFteData().soldierEvents > 0 then
            FinishRecruitSoldier()
        end
    end, recruitTime)
end



local function GetSoldier()
    mock{
        {"soldiers.swordsman", 100},
        {"soldiers.ranger", 100}
    }
end

local function ActiveVip()
    local start_time = NetManager:getServerTime()
    mock{
        {
            "vipEvents.0",
            {
                id = 1,
                startTime = start_time,
                finishTime = start_time + 4 * 60 * 60 * 1000
            }
        }
    }

end




return {
    HateDragon = HateDragon,
    DefenceDragon = DefenceDragon,
    BuildHouseAt = BuildHouseAt,
    UpgradeHouseTo = UpgradeHouseTo,
    FinishBuildHouseAt = FinishBuildHouseAt,
    UpgradeBuildingTo = UpgradeBuildingTo,
    FinishUpgradingBuilding = FinishUpgradingBuilding,
    RecruitSoldier = RecruitSoldier,
    GetSoldier = GetSoldier,
    ActiveVip = ActiveVip,
}

















