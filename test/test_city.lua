local Game = require("Game")
local Orient = import("app.entity.Orient")
local UpgradeBuilding = import("app.entity.UpgradeBuilding")
local KeepUpgradeBuilding = import("app.entity.KeepUpgradeBuilding")
local WarehouseUpgradeBuilding = import("app.entity.WarehouseUpgradeBuilding")
local DragonEyrieUpgradeBuilding = import("app.entity.DragonEyrieUpgradeBuilding")
local City_ = import("app.entity.City")
local City = City_.new()




map = {}
local offset = 5
function clear()
    for i = 1, 70 do
        map[i] = {}
        for j = 1, 70 do
            map[i][j] = false
        end
    end
end
function UpdateWalls()
    clear()
    for k, v in pairs(City.walls) do
        if v.orient == Orient.Y then
            for i = 1, v.len do
                map[v.y + offset][v.x + offset + 1 - i] = true
            end
        elseif v.orient == Orient.NEG_Y then
            for i = 1, v.len do
                map[v.y + offset][v.x + offset + 1 - i] = true
            end
        elseif v.orient == Orient.X then
            if v:IsGate() then
                for i = 1, math.floor(v.len / 2 - 1) do
                    map[v.y + offset + 1 - i][v.x + offset] = true
                end
                for i = math.ceil(v.len / 2), math.ceil(v.len / 2 + 1) do
                    map[v.y + offset + 1 - i][v.x + offset] = 0
                end
                for i = math.ceil(v.len / 2 + 2), v.len do
                    map[v.y + offset + 1 - i][v.x + offset] = true
                end
            else
                for i = 1, v.len do
                    map[v.y + offset + 1 - i][v.x + offset] = true
                end
            end

        elseif v.orient == Orient.NEG_X then
            for i = 1, v.len do
                map[v.y + offset + 1 - i][v.x + offset] = true
            end
        end
    end

    for k, v in pairs(City.visible_towers) do
        map[v.y + offset][v.x + offset] = 101
    end

    -- for k, v in pairs(City.ruins) do
    --     if not City:GetTileWhichBuildingBelongs(v).locked and not v.has_been_occupied then
    --         for i = 1, v.w do
    --             for j = 1, v.h do
    --                 map[v.y + 3 - j][v.x + 3 - i] = -1
    --             end
    --         end
    --     end
    -- end

    -- for k, v in pairs(City:GetAllDecorators()) do
    --     for i = 1, v.w do
    --         for j = 1, v.h do
    --             map[v.y + 3 - j][v.x + 3 - i] = 100
    --         end
    --     end
    -- end
end
function outputTiles()
    print(string.format("\n%s", string.rep("-", 41)))
    for i, r in ipairs(City.tiles) do
        local t = {}
        table.insert(t, "")
        for j, c in ipairs(r) do
            local str = string.format("%-6s", not c.locked and "true" or "false")
            table.insert(t, str)
        end
        table.insert(t, "")
        print(table.concat(t, "| "))
    end
    print(string.format("%s", string.rep("-", 41)))
end
function ouputWall()
end
function ouputWalls()
    print("")
    local map = _G["map"]
    for i, r in ipairs(map) do
        local t = {}
        for j, c in ipairs(r) do
            if i == offset and j == offset then
                table.insert(t, "#")
            elseif i == offset and j == offset + 1 then
                table.insert(t, "—")
            elseif i == offset + 1 and j == offset then
                table.insert(t, "|")
            elseif i == offset and j == offset + 49 then
                table.insert(t, "#")
            elseif i == offset and j == offset + 48 then
                table.insert(t, "—")
            elseif i == offset + 1 and j == offset + 49 then
                table.insert(t, "|")
            elseif i == offset + 49 and j == offset then
                table.insert(t, "#")
            elseif i == offset + 49 and j == offset + 1 then
                table.insert(t, "—")
            elseif i == offset + 48 and j == offset then
                table.insert(t, "|")
            elseif i == offset + 49 and j == offset + 49 then
                table.insert(t, "#")
            elseif i == offset + 49 and j == offset + 48 then
                table.insert(t, "—")
            elseif i == offset + 48 and j == offset + 49 then
                table.insert(t, "|")
            else
                if type(map[i][j]) == "number" then
                    if map[i][j] == 0 then
                        table.insert(t, "|")
                    elseif map[i][j] == -1 then
                        table.insert(t, "*")
                    elseif map[i][j] == 100 then
                        table.insert(t, "o")
                    else
                        local a = string.byte('a')
                        local l = map[i][j] + a - 1
                        table.insert(t, string.char(l))
                    end
                else
                    local s = map[i][j] and "@" or "."
                    table.insert(t, s)
                end
            end
        end
        print(table.concat(t, " "))
    end
end


-- module( "test_city_up", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--     })
--     City:InitBuildings({
--         KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 10, h = 10 }),
--         WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
--         DragonEyrieUpgradeBuilding.new({ x = 9, y = 9, building_type = "dragonEyrie", level = 1, w = 9, h = 10 }),
--     })
--     City:InitDecorators({})
-- end

-- function teardown()

-- end
-- function test_get_keep()
--     assert_true(City:GetFirstBuildingByType("keep") ~= nil)
--     assert_true(City:GetFirstBuildingByType("keep"):GetType() == "keep")
--     assert_true(City:GetFirstBuildingByType("keep"):GetLevel() == 1)
--     City:GetFirstBuildingByType("keep"):InstantUpgradeBy(1)
--     assert_true(City:GetFirstBuildingByType("keep"):GetLevel() == 2)
--     City:GetFirstBuildingByType("keep"):InstantUpgradeTo(3)
--     assert_true(City:GetFirstBuildingByType("keep"):GetLevel() == 3)
--     City:GetFirstBuildingByType("keep"):InstantUpgradeTo(100)
--     assert_true(City:GetFirstBuildingByType("keep"):GetLevel() == 100)
-- end

-- module( "test_unlock", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--     })
-- end

-- function teardown()
-- end
-- function test_lock()
--     assert_true(City:IsUnLockedAtIndex(1, 1))
--     assert_true(City:IsUnLockedAtIndex(1, 2))
--     assert_true(City:IsUnLockedAtIndex(1, 5) == false)
--     assert_true(City:IsUnLockedAtIndex(5, 5) == false)
--     local success, ret_code = City:UnlockTilesByIndex(1, 5)
--     assert_true(ret_code == City.RETURN_CODE.INNER_ROUND_NOT_UNLOCKED)
--     assert_true(City:IsUnLockedAtIndex(1, 5) == false)
--     success, ret_code = City:UnlockTilesByIndex(3, 3)
--     assert_true(ret_code == City.RETURN_CODE.EDGE_BESIDE_NOT_UNLOCKED)
--     assert_true(City:IsUnLockedAtIndex(3, 3) == false)
-- end

-- module( "test_unlock_around", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         -- { x = 1, y = 2},
--         -- { x = 2, y = 1},
--         -- { x = 2, y = 2},
--     })
--     City:InitBuildings({
--         KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 9, h = 10 }),
--     })
--     City:InitDecorators({})
-- end

-- function teardown()
-- end
-- function test_unlock_around()

-- local keep = City:GetFirstBuildingByType("keep")
-- keep:InstantUpgradeTo(25)

-- assert_true(City:IsUnlockedInAroundNumber(1))
-- assert_true(City:IsUnlockedInAroundNumber(2))
-- assert_true(City:IsUnlockedInAroundNumber(3) == false)

-- assert_true(City:UnlockTilesByIndex(3, 1) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 1) == true)

-- assert_true(City:UnlockTilesByIndex(3, 2) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 2) == true)

-- assert_true(City:UnlockTilesByIndex(1, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(1, 3) == true)

-- assert_true(City:UnlockTilesByIndex(2, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(2, 3) == true)

-- assert_true(City:UnlockTilesByIndex(3, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 3) == true)


-- assert_true(City:IsUnlockedInAroundNumber(3) == true)


-- assert_true(City:UnlockTilesByIndex(4, 1) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 1) == true)

-- assert_true(City:UnlockTilesByIndex(4, 2) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 2) == true)

-- assert_true(City:UnlockTilesByIndex(4, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 3) == true)

-- assert_true(City:UnlockTilesByIndex(4, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 4) == true)

-- assert_true(City:UnlockTilesByIndex(1, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(1, 4) == true)

-- assert_true(City:UnlockTilesByIndex(2, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(2, 4) == true)

-- assert_true(City:UnlockTilesByIndex(3, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 4) == true)


-- assert_true(City:IsUnlockedInAroundNumber(4) == true)
-- end

module( "test_walls", lunit.testcase, package.seeall )
function setup()
    City = City_.new()
    City:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
        { x = 3, y = 2},
        { x = 2, y = 3},
        { x = 3, y = 3},
        { x = 1, y = 3},
        { x = 3, y = 1},
        -- { x = 4, y = 1},
        -- { x = 4, y = 2},
        -- { x = 4, y = 3},
        -- { x = 4, y = 4},
        { x = 3, y = 4},
        -- { x = 2, y = 4},
        -- { x = 1, y = 4},
        -- { x = 1, y = 5},
        -- { x = 2, y = 5},
        -- { x = 3, y = 5},
        -- { x = 4, y = 5},
        -- { x = 5, y = 5},
        -- { x = 5, y = 1},
        -- { x = 5, y = 2},
        -- { x = 5, y = 3},
        -- { x = 5, y = 4},
    })
    City:InitDecorators({})
end

function teardown()
end


function test_walls()
    City:GenerateWalls()
    UpdateWalls()
    ouputWalls()

-- assert_true(City:UnlockTilesByIndex(3, 1) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 1) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(1, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(1, 3) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(2, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(2, 3) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(3, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 3) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(3, 2) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 2) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(3, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 4) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


-- assert_true(City:UnlockTilesByIndex(2, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(2, 4) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(1, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(1, 4) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


-- assert_true(City:UnlockTilesByIndex(4, 1) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 1) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(4, 2) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 2) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


-- assert_true(City:UnlockTilesByIndex(4, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 4) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


-- assert_true(City:UnlockTilesByIndex(4, 3) == true)
-- assert_true(City:IsUnLockedAtIndex(4, 3) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


-- assert_true(City:UnlockTilesByIndex(5, 1) == true)
-- assert_true(City:IsUnLockedAtIndex(5, 1) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


-- assert_true(City:UnlockTilesByIndex(1, 5) == true)
-- assert_true(City:IsUnLockedAtIndex(1, 5) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(5, 2) == true)
-- assert_true(City:IsUnLockedAtIndex(5, 2) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()

-- assert_true(City:UnlockTilesByIndex(3, 5) == true)
-- assert_true(City:IsUnLockedAtIndex(3, 5) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


-- assert_true(City:UnlockTilesByIndex(5, 4) == true)
-- assert_true(City:IsUnLockedAtIndex(5, 4) == true)

-- City:GenerateWalls()
-- UpdateWalls()
-- ouputWalls()


end



-- module( "test_tower", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--     })
-- end

-- function teardown()
-- end


-- function test_tower()
--     City:GenerateWalls()
--     -- UpdateWalls()
--     -- ouputWalls()
-- end

-- module( "test_position", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--         { x = 1, y = 3},
--         { x = 2, y = 3},
--         { x = 3, y = 3},
--         { x = 3, y = 1},
--         { x = 3, y = 2},
--     })
--     City:InitDecorators({})
-- end

-- function test_pos()
--     --
--     local tile = City:GetTileByIndex(1, 1)
--     local x, y = tile:GetStartPos()
--     assert_true(x == 0 and y == 0)
--     x, y = tile:GetEndPos()
--     assert_true(x == 9 and y == 9)

--     local tile = City:GetTileByIndex(2, 2)
--     local x, y = tile:GetStartPos()
--     assert_true(x == 10 and y == 10)
--     x, y = tile:GetEndPos()
--     assert_true(x == 19 and y == 19)
-- end



-- module( "test_tiles", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--     })
--     City:InitBuildings({
--         KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 10, h = 10 }),
--         UpgradeBuilding.new({ x = 9, y = 29, building_type = "hospital", level = 1, w = 6, h = 6 }),
--         UpgradeBuilding.new({ x = 19, y = 29, building_type = "materail_depot", level = 1, w = 6, h = 6 }),
--         WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
--     })
-- end

-- function test_tiles()
--     local keep = City:GetFirstBuildingByType("keep")
--     local tile = City:GetTileWhichBuildingBelongs(keep)
--     assert_true(tile.locked == false)
--     local start_x, start_y = tile:GetStartPos()
--     assert_true(start_x == 0 and start_y == 0)
--     local end_x, end_y = tile:GetEndPos()
--     assert_true(end_x == 9 and end_y == 9)


--     local hospital = City:GetFirstBuildingByType("hospital")
--     local tile = City:GetTileWhichBuildingBelongs(hospital)
--     assert_true(tile.locked == true)
--     local start_x, start_y = tile:GetStartPos()
--     assert_true(start_x == 0)
--     assert_true(start_y == 20)
--     local end_x, end_y = tile:GetEndPos()
--     assert_true(end_x == 9 and end_y == 29)
-- end


-- module( "test_city_ruins", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--         -- { x = 1, y = 3},
--         -- { x = 2, y = 3},
--         -- { x = 3, y = 3},
--         -- { x = 3, y = 1},
--         -- { x = 3, y = 2},
--         -- { x = 1, y = 4},
--         -- { x = 2, y = 4},
--         -- { x = 3, y = 4},
--         -- { x = 4, y = 4},
--         -- { x = 4, y = 1},
--         -- { x = 4, y = 2},
--         -- { x = 4, y = 3},
--         -- { x = 1, y = 5},
--         -- { x = 2, y = 5},
--         -- { x = 3, y = 5},
--         -- { x = 4, y = 5},
--         -- { x = 5, y = 5},
--         -- { x = 5, y = 1},
--         -- { x = 5, y = 2},
--         -- { x = 5, y = 3},
--         -- { x = 5, y = 4},
--     })
--     City:InitBuildings({
--         -- KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 10, h = 10 }),
--         -- UpgradeBuilding.new({ x = 19, y = 9, building_type = "dragon_eyrie", level = 1, w = 10, h = 10 }),
--         -- UpgradeBuilding.new({ x = 29, y = 9, building_type = "black_smith", level = 1, w = 6, h = 6 }),
--         -- UpgradeBuilding.new({ x = 39, y = 9, building_type = "academy", level = 1, w = 6, h = 6 }),
--         -- UpgradeBuilding.new({ x = 49, y = 9, building_type = "workshop", level = 1, w = 6, h = 6 }),

--         -- UpgradeBuilding.new({ x = 3, y = 19, building_type = "watch_tower", level = 1, w = 4, h = 4}),
--         -- UpgradeBuilding.new({ x = 19, y = 19, building_type = "warehouse_1", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 29, y = 19, building_type = "barracks", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 39, y = 19, building_type = "townhall", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 49, y = 19, building_type = "stable", level = 1, w = 6, h = 6}),

--         -- UpgradeBuilding.new({ x = 9, y = 29, building_type = "hospital", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 19, y = 29, building_type = "material_depot_1", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 29, y = 29, building_type = "army_camp_1", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 39, y = 29, building_type = "toolshop", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 49, y = 29, building_type = "training_ground", level = 1, w = 6, h = 6}),

--         -- UpgradeBuilding.new({ x = 9, y = 39, building_type = "foundry", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 19, y = 39, building_type = "stone_mason", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 29, y = 39, building_type = "lumber_mill", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 39, y = 39, building_type = "mill", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 49, y = 39, building_type = "hunter_hall", level = 1, w = 6, h = 6}),

--         -- UpgradeBuilding.new({ x = 9, y = 49, building_type = "material_depot_2", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 19, y = 49, building_type = "warehouse_2", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 29, y = 49, building_type = "trade_guild", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 39, y = 49, building_type = "army_camp_2", level = 1, w = 6, h = 6}),
--         -- UpgradeBuilding.new({ x = 49, y = 49, building_type = "prison", level = 1, w = 6, h = 6}),
--     })
-- City:InitDecorators({})
-- end

-- function test_city_ruins()
--     City:GenerateWalls()
--     -- UpdateWalls()
--     -- ouputWall()
-- end



-- module( "test_city_listener", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--     })
--     City:InitBuildings({
--         UpgradeBuilding.new({ x = 9, y = 29, building_type = "hospital", level = 1, w = 6, h = 6 }),
--         WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
--     })
-- end

-- function test_city_UNLOCK_TILE()
--     City:AddListenOnType({
--         OnTileUnlocked = function(self, city, x, y)
--             assert_true(x == 3)
--             assert_true(y == 1)
--         end}, City.LISTEN_TYPE.UNLOCK_TILE)
--     City:AddListenOnType({
--         OnTileLocked = function(self, city, x, y)
--             assert_true(x == 3)
--             assert_true(y == 1)
--         end}, City.LISTEN_TYPE.LOCK_TILE)
--     City:UnlockTilesByIndex(3, 1)
--     City:LockTilesByIndex(3, 1)
-- end

-- function test_city_UNLOCK_ROUND()
--     City:AddListenOnType({OnRoundUnlocked = function(self, round)
--         assert_equal(3, round)
--     end}, City.LISTEN_TYPE.UNLOCK_ROUND)
--     City:UnlockTilesByIndex(3, 1)
--     City:UnlockTilesByIndex(3, 2)
--     City:UnlockTilesByIndex(3, 3)
--     City:UnlockTilesByIndex(1, 3)
--     City:UnlockTilesByIndex(2, 3)
-- end





-- module( "test_orient", lunit.testcase, package.seeall )
-- function setup()
--     City:InitBuildings({
--         KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 10, h = 1 }),
--         WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
--     })
--     City:InitDecorators({})
-- end

-- function test_orient()
--     assert_true(City:GetFirstBuildingByType("keep"):GetOrient() == Orient.X)
--     assert_true(City:GetFirstBuildingByType("keep").w == 10)
--     assert_true(City:GetFirstBuildingByType("keep").h == 1)
--     City:GetFirstBuildingByType("keep"):SetOrient(Orient.Y)
--     assert_true(City:GetFirstBuildingByType("keep"):GetOrient() == Orient.Y)
--     assert_true(City:GetFirstBuildingByType("keep").w == 1)
--     assert_true(City:GetFirstBuildingByType("keep").h == 10)
--     City:GetFirstBuildingByType("keep"):SetOrient(Orient.X)
--     assert_true(City:GetFirstBuildingByType("keep"):GetOrient() == Orient.X)
--     assert_true(City:GetFirstBuildingByType("keep").w == 10)
--     assert_true(City:GetFirstBuildingByType("keep").h == 1)
-- end



-- module( "test_building_listener", lunit.testcase, package.seeall )
-- function setup()
--     City = City_.new()
--     City:InitTiles(5, 5, {
--         { x = 1, y = 1},
--         { x = 1, y = 2},
--         { x = 2, y = 1},
--         { x = 2, y = 2},
--     })
--     City:InitBuildings({
--         KeepUpgradeBuilding.new({ x = 9, y = 9, building_type = "keep", level = 1, w = 9, h = 10 }),
--         WarehouseUpgradeBuilding.new({ x = 9, y = 9, building_type = "warehouse", level = 1, w = 9, h = 10 }),
--     })
--     City:InitDecorators({})
-- end

-- end









