
module( "test_alliance_map", lunit.testcase, package.seeall )

local alliance_decorator_map = {
    {width = 1, height = 1},
    {width = 2, height = 1},
    {width = 2, height = 2},
    {width = 3, height = 2},
}
-- 6 * 5
-- 4 * 5
-- 2 * 5
-- 1 * 5
-- 13 * 5 = 65
local width = 21
local height = 21

local map = {}
local function_building = {}
local decorator = {width = 3, height = 3, x = 3, y = 3}
function return_start_end_from(decorator)
    return {x = decorator.x - decorator.width + 1, y = decorator.y - decorator.height + 1},
        {x = decorator.x, y = decorator.y}
end
function iterator_every_point(decorator, func)
    assert(type(func) == "function")
    local sp, ep = return_start_end_from(decorator)
    for i = sp.x, ep.x do
        for j = sp.y, ep.y do
            if func(i, j) then
                return
            end
        end
    end
end
function update_map()
    for i = 1, 21 do
        map[i] = {}
        for j = 1, 21 do
            map[i][j] = false
        end
    end
    for i, v in ipairs(function_building) do
        iterator_every_point(v, function(x, y)
            map[y][x] = true
        end)
    end
end
function update_map_with_decorator(decorator)
    iterator_every_point(decorator, function(x, y)
        map[y][x] = true
    end)
end
function out_put_map()
    print("=========================================")
    for i = 1, 21 do
        local t = {}
        for j = 1, 21 do
            if not map[i][j] then
                table.insert(t, ".")
            else
                table.insert(t, "*")
            end
        end
        print(table.concat(t, " "))
    end
    print("=========================================")
end

local function is_validate_position(decorator, map)
    local validate = true
    iterator_every_point(decorator, function(x, y)
        if map[y] == nil or map[y][x] or map[y][x] == nil then
            validate = false
            return true
        end
    end)
    return validate
end
function random_decorator_by_index(index, tmp_index, map)
    local x, y = index % 21, math.floor(index / 21) + 1
    local tmp = alliance_decorator_map[tmp_index]
    local decorator = {width = tmp.width, height = tmp.height}
    for _, v in ipairs{
        {x = x, y = y},
        {x = x + decorator.width - 1, y = y},
        {x = x, y = y + decorator.height - 1},
        {x = x + decorator.width - 1, y = y + decorator.height - 1},
    } do
        decorator.x = v.x
        decorator.y = v.y
        if is_validate_position(decorator, map) then
            return decorator
        end
    end
    return nil
end
function get_index_from_map(map)
    local random_map = {}
    for j = 1, 21 do
        for i = 1, 21 do
            if not map[i][j] then
                table.insert(random_map, (j - 1) * 21 + i)
            end
        end
    end
    return random_map
end

function test_alliance_map()
    math.randomseed(23590239)
    update_map()
    update_map_with_decorator{width = 3, height = 3, x = 12, y = 12}
    update_map_with_decorator{width = 3, height = 3, x = 15, y = 12}
    update_map_with_decorator{width = 3, height = 3, x = 12, y = 15}
    update_map_with_decorator{width = 3, height = 3, x = 9, y = 12}
    update_map_with_decorator{width = 3, height = 3, x = 12, y = 9}

    local random_map = get_index_from_map(map)
    while #function_building < 10 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 1, map)
        if decorator then
            table.insert(function_building, decorator)
            update_map_with_decorator(decorator)
        end
        table.remove(random_map, index)
    end
    while #function_building < 15 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 2, map)
        if decorator then
            table.insert(function_building, decorator)
            update_map_with_decorator(decorator)
        end
        table.remove(random_map, index)
    end
    while #function_building < 20 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 3, map)
        if decorator then
            table.insert(function_building, decorator)
            update_map_with_decorator(decorator)
        end
        table.remove(random_map, index)
    end
    while #function_building < 25 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 4, map)
        if decorator then
            table.insert(function_building, decorator)
            update_map_with_decorator(decorator)
        end
        table.remove(random_map, index)
    end
    out_put_map()
end
















