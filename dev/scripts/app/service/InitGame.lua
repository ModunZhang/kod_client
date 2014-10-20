local BuildingRegister = import("..entity.BuildingRegister")
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
        local finishTime = event == nil and 0 or event.finishTime / 1000
        table.insert(init_buildings,
            City:NewBuildingWithType(location_config.building_type,
                location_config.x,
                location_config.y,
                location_config.w,
                location_config.h,
                location.level,
                finishTime)
        )


        if location.level > 0 then
            table.insert(init_unlock_tiles, {x = location_config.tile_x, y = location_config.tile_y})
        end
    end)
    City:InitBuildings(init_buildings)


    -- table.insert(init_unlock_tiles, {x = 1, y = 3})
    -- table.insert(init_unlock_tiles, {x = 2, y = 3})
    -- table.insert(init_unlock_tiles, {x = 3, y = 3})
    -- table.insert(init_unlock_tiles, {x = 3, y = 2})
    -- table.insert(init_unlock_tiles, {x = 3, y = 1})

    -- table.insert(init_unlock_tiles, {x = 1, y = 4})
    -- table.insert(init_unlock_tiles, {x = 2, y = 4})
    -- table.insert(init_unlock_tiles, {x = 3, y = 4})
    -- table.insert(init_unlock_tiles, {x = 4, y = 4})
    -- table.insert(init_unlock_tiles, {x = 4, y = 3})
    -- table.insert(init_unlock_tiles, {x = 4, y = 2})
    -- table.insert(init_unlock_tiles, {x = 4, y = 1})

    -- table.insert(init_unlock_tiles, {x = 1, y = 5})

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
                local city_location = City:GetLocationById(location.location)
                local tile_x = city_location.tile_x
                local tile_y = city_location.tile_y
                local tile = City:GetTileByIndex(tile_x, tile_y)
                local absolute_x, absolute_y = tile:GetAbsolutePositionByLocation(house.location)
                local event = get_house_event_by_location(location.location, house.location)
                local finishTime = event == nil and 0 or event.finishTime / 1000
                table.insert(init_decorators,
                    City:NewBuildingWithType(house.type,
                        absolute_x,
                        absolute_y,
                        3,
                        3,
                        house.level,
                        finishTime)
                )
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
























