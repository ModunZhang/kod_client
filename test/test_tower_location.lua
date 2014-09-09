local Game = require("Game")
import("app.utils.LuaUtils")
local Orient = import("app.entity.Orient")
local City = import("app.entity.City")

function UpdateWalls(city)
    local width = 54
    local offset = 3
    local map = {}
    function clear()
        for i = 1, width do
            map[i] = {}
            for j = 1, width do
                map[i][j] = false
            end
        end
    end
    clear()
    for k, v in pairs(city.walls) do
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

    for k, v in pairs(city.towers) do
        map[v.y + offset][v.x + offset] = v.id
    end

    for k, v in pairs(city.ruins) do
        if not city:GetTileWhichBuildingBelongs(v).locked and not v.has_been_occupied then
            for i = 1, v.w do
                for j = 1, v.h do
                    map[v.y + offset + 1 - j][v.x + offset + 1 - i] = -1
                end
            end
        end
    end

    for k, v in pairs(city:GetAllDecorators()) do
        for i = 1, v.w do
            for j = 1, v.h do
                map[v.y + offset + 1 - j][v.x + offset + 1 - i] = 100
            end
        end
    end

    function ouputWalls()
        print("")
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
                            local a = string.byte('A')
                            local l = map[i][j] + a - 1
                            table.insert(t, string.char(l))
                        end
                    else
                        local s = map[i][j] and "g" or "."
                        table.insert(t, s)
                    end
                end
            end
            print(table.concat(t, " "))
        end
    end
    ouputWalls()
end



module( "test_tower_location1", lunit.testcase, package.seeall )
function test_tower_location1()
    local test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
    })
    test_city:GenerateWalls()
    UpdateWalls(test_city)

    assert_equal(5, #test_city:GetCanUpgradingTowers())
    for k, v in pairs(test_city:GetCanUpgradingTowers()) do
        print(k, v.x, v.y)
    end
end
function test_tower_location1_1()
    local test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
        { x = 2, y = 3},
    })
    test_city:GenerateWalls()
    UpdateWalls(test_city)
    assert_equal(5, #test_city:GetCanUpgradingTowers())
    for k, v in pairs(test_city:GetCanUpgradingTowers()) do
        print(k, v.x, v.y)
    end
end


module( "test_tower_location2", lunit.testcase, package.seeall )
function test_tower_location2()
    local test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},
        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
        { x = 1, y = 3},
        { x = 2, y = 3},
        { x = 3, y = 3},
        { x = 3, y = 1},
        { x = 3, y = 2},
    })
    test_city:GenerateWalls()
    UpdateWalls(test_city)

    assert_equal(7, #test_city:GetCanUpgradingTowers())
    for k, v in pairs(test_city:GetCanUpgradingTowers()) do
        print(k, v.x, v.y)
    end
end

module( "test_tower_location3", lunit.testcase, package.seeall )
function test_tower_location3()
    local test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},

        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
        
        { x = 1, y = 3},
        { x = 2, y = 3},
        { x = 3, y = 3},
        { x = 3, y = 1},
        { x = 3, y = 2},
        
        { x = 1, y = 4},
        { x = 2, y = 4},
        { x = 3, y = 4},
        { x = 4, y = 4},
        { x = 4, y = 1},
        { x = 4, y = 2},
        { x = 4, y = 3},
    })
    test_city:GenerateWalls()
    UpdateWalls(test_city)
    assert_equal(9, #test_city:GetCanUpgradingTowers())
    for k, v in pairs(test_city:GetCanUpgradingTowers()) do
        print(k, v.x, v.y)
    end
end

module( "test_tower_location3", lunit.testcase, package.seeall )
function test_tower_location3()
    local test_city = City.new()
    test_city:InitTiles(5, 5, {
        { x = 1, y = 1},

        { x = 1, y = 2},
        { x = 2, y = 1},
        { x = 2, y = 2},
        
        { x = 1, y = 3},
        { x = 2, y = 3},
        { x = 3, y = 3},
        { x = 3, y = 1},
        { x = 3, y = 2},
        
        { x = 1, y = 4},
        { x = 2, y = 4},
        { x = 3, y = 4},
        { x = 4, y = 4},
        { x = 4, y = 1},
        { x = 4, y = 2},
        { x = 4, y = 3},
        
        { x = 1, y = 5},
        { x = 2, y = 5},
        { x = 3, y = 5},
        { x = 4, y = 5},
        { x = 5, y = 5},
        { x = 5, y = 4},
        { x = 5, y = 3},
        { x = 5, y = 2},
        { x = 5, y = 1},

    })
    test_city:GenerateWalls()
    UpdateWalls(test_city)
    assert_equal(11, #test_city:GetCanUpgradingTowers())
    for k, v in pairs(test_city:GetCanUpgradingTowers()) do
        print(k, v.x, v.y)
    end
end

