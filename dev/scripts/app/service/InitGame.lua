local Orient = import("..entity.Orient")
local Building = import("..entity.Building")
local UpgradeBuilding = import("..entity.UpgradeBuilding")
local KeepUpgradeBuilding = import("..entity.KeepUpgradeBuilding")
local WarehouseUpgradeBuilding = import("..entity.WarehouseUpgradeBuilding")
local WoodResourceUpgradeBuilding = import("..entity.WoodResourceUpgradeBuilding")
local FoodResourceUpgradeBuilding = import("..entity.FoodResourceUpgradeBuilding")
local IronResourceUpgradeBuilding = import("..entity.IronResourceUpgradeBuilding")
local StoneResourceUpgradeBuilding = import("..entity.StoneResourceUpgradeBuilding")
local PopulationResourceUpgradeBuilding = import("..entity.PopulationResourceUpgradeBuilding")
local ResourceManager = import("..entity.ResourceManager")
local city = import("..entity.City")
return function(userData)
    City = city.new()
    local init_buildings = {}
    local init_unlock_tiles = {}

    local building_events = userData.buildingEvents
    local function get_building_event_by_location(location_id)
        for k, v in pairs(building_events) do
            if v.location == location_id then
                return v
            end
        end
    end

    table.foreach(userData.buildings, function(key, location)
        local location_config = City:GetLocationById(location.location)
        local event = get_building_event_by_location(location.location)
        local finishTime
        if event then
            finishTime = event.finishTime / 1000
        end
        if location_config.building_type == "keep" then
            table.insert(init_buildings, KeepUpgradeBuilding.new({
                x = location_config.x,
                y = location_config.y,
                w = location_config.w,
                h = location_config.h,

                building_type = location_config.building_type,
                level = location.level,
                finishTime = finishTime 
            }))
        elseif location_config.building_type == "warehouse" then
            table.insert(init_buildings, WarehouseUpgradeBuilding.new({
                x = location_config.x,
                y = location_config.y,
                w = location_config.w,
                h = location_config.h,

                building_type = location_config.building_type,
                level = location.level,
                finishTime = finishTime 
            }))
        else
            table.insert(init_buildings, UpgradeBuilding.new({
                x = location_config.x,
                y = location_config.y,
                w = location_config.w,
                h = location_config.h,

                building_type = location_config.building_type,
                level = location.level,
                finishTime = finishTime 
            }))
        end
        if location.level > 0 then
            table.insert(init_unlock_tiles, {x = location_config.tile_x, y = location_config.tile_y})
        end
    end)
    City:InitBuildings(init_buildings)

    -- table.insert(init_unlock_tiles, {x = 3, y = 2})
    -- table.insert(init_unlock_tiles, {x = 4, y = 2})
    -- table.insert(init_unlock_tiles, {x = 5, y = 2})
    City:InitTiles(5, 5, init_unlock_tiles)


    local hosue_events = userData.houseEvents
            local function get_house_event_by_location(building_location, sub_id)
                for k, v in pairs(hosue_events) do
                    if v.buildingLocation == building_location and
                        v.houseLocation == sub_id then
                        return v
                    end
                end
            end

    local init_decorators = {}
    table.foreach(userData.buildings, function(_, location)
        if #location.houses > 0 then
            table.foreach(location.houses, function(_, house)
                local tile_x = City:GetLocationById(location.location).tile_x
                local tile_y = City:GetLocationById(location.location).tile_y
                local tile = City:GetTileByIndex(tile_x, tile_y)
                local ax, ay = tile:GetAbsolutePositionByLocation(house.location)

                local event = get_house_event_by_location(location.location, house.location)
                finishTime = event == nil and 0 or event.finishTime / 1000

                if house.type == "woodcutter" then
                    table.insert(init_decorators, WoodResourceUpgradeBuilding.new({
                        x = ax, y = ay,
                        w = 3, h = 3,

                        building_type = house.type,
                        level = house.level,
                        finishTime = finishTime
                    }))
                elseif house.type == "farmer" then
                    table.insert(init_decorators, FoodResourceUpgradeBuilding.new({
                        x = ax, y = ay,
                        w = 3, h = 3,

                        building_type = house.type,
                        level = house.level,
                        finishTime = finishTime
                    }))
                elseif house.type == "miner" then
                    table.insert(init_decorators, IronResourceUpgradeBuilding.new({
                        x = ax, y = ay,
                        w = 3, h = 3,

                        building_type = house.type,
                        level = house.level,
                        finishTime = finishTime
                    }))
                elseif house.type == "quarrier" then
                    table.insert(init_decorators, StoneResourceUpgradeBuilding.new({
                        x = ax, y = ay,
                        w = 3, h = 3,

                        building_type = house.type,
                        level = house.level,
                        finishTime = finishTime
                    }))
                elseif house.type == "dwelling" then
                    table.insert(init_decorators, PopulationResourceUpgradeBuilding.new({
                        x = ax, y = ay,
                        w = 3, h = 3,

                        building_type = house.type,
                        level = house.level,
                        finishTime = finishTime
                    }))
                end
            end)
        end
    end)
    City:InitDecorators(init_decorators)
    City:GenerateWalls()

    DataManager:setUserData(userData)

    local app = app
    local timer = app.timer
    timer:AddListener(City)
    timer:Start()
    
    ext.localpush.cancelAll()
    --read userdefaults about local push
    ext.localpush.switchNotification('BUILDING_PUSH_UPGRADE',true) 
end














