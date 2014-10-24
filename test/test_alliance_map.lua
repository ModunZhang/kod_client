-- local Game = require("Game")
-- module( "test_alliance_map", lunit.testcase, package.seeall )

local width = 21
local height = 21
function iterator_every_point(rect, func)
    iterator_every_point_with_size(rect.x, rect.y, rect.w, rect.h, func)
end
function iterator_every_point_with_size(x, y, w, h, func)
    assert(type(func) == "function")
    local sp, ep = return_start_end_from_size(x, y, w, h)
    for i = sp.x, ep.x do
        for j = sp.y, ep.y do
            if func(i, j) then
                return
            end
        end
    end
end
function return_start_end_from_size(x, y, w, h)
    return {x = x - w + 1, y = y - h + 1}, {x = x, y = y}
end
function mark_map(map, rects)
    for i = 1, width do
        map[i] = {}
        for j = 1, height do
            map[i][j] = false
        end
    end
    for i, v in ipairs(rects) do
        mark_map_with_rect(map, v)
    end
end
function mark_map_with_rect(map, rect)
    iterator_every_point(rect, function(x, y)
        map[y][x] = true
    end)
end
function is_validate_rect(map, x, y, w, h)
    local validate = true
    iterator_every_point_with_size(x, y, w, h, function(x, y)
        if map[y] == nil or map[y][x] or map[y][x] == nil then
            validate = false
            return true
        end
    end)
    return validate
end
local alliance_decorator_map = {
    {width = 1, height = 1},
    {width = 2, height = 1},
    {width = 2, height = 2},
    {width = 3, height = 2},
}
function random_rect_by_index(index, tmp_index, map)
    local x, y = index % width, math.floor(index / width) + 1
    local tmp = alliance_decorator_map[tmp_index]
    local rect = {w = tmp.width, h = tmp.height}
    for _, v in ipairs{
        {x = x, y = y},
        {x = x + rect.w - 1, y = y},
        {x = x, y = y + rect.h - 1},
        {x = x + rect.w - 1, y = y + rect.h - 1},
    } do
        if is_validate_rect(map, v.x, v.y, rect.w, rect.h) then
            rect.x = v.x
            rect.y = v.y
            return rect
        end
    end
    return nil
end
function random_rect(map, w, h)
    local random_map = get_index_from_map(map)
    local max_depth = 5
    local i = 0
    repeat
    	i = i + 1
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local rect = random_rect_with_index(map, w, h, index)
        if rect then
        	return rect
        end
        table.remove(random_map, index)
        if i > max_depth then
        	return
        end
    until true
end
function random_rect_with_index(map, w, h, index)
	local x, y = index % width, math.floor(index / width) + 1
    for _, v in ipairs{
        {x = x, y = y},
        {x = x + w - 1, y = y},
        {x = x, y = y + h - 1},
        {x = x + w - 1, y = y + h - 1},
    } do
        if is_validate_rect(map, v.x, v.y, w, h) then
            return {x = v.x, y = v.y, w = w, h = h}
        end
    end
    return nil
end
function get_index_from_map(map)
    local random_map = {}
    for j = 1, width do
        for i = 1, height do
            if not map[i][j] then
                table.insert(random_map, (j - 1) * width + i)
            end
        end
    end
    return random_map
end

function test_alliance_map()
    math.randomseed(23590239)
    local map = {}
    mark_map(map, {})
    mark_map_with_rect(map, {w = 3, h = 3, x = 12, y = 12})
    mark_map_with_rect(map, {w = 3, h = 3, x = 15, y = 12})
    mark_map_with_rect(map, {w = 3, h = 3, x = 12, y = 15})
    mark_map_with_rect(map, {w = 3, h = 3, x = 9, y = 12})
    mark_map_with_rect(map, {w = 3, h = 3, x = 12, y = 9})

    local rects = {}
    local random_map = get_index_from_map(map)
    while #rects < 10 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local rect = random_rect_by_index(random_map[index], 1, map)
        if rect then
            table.insert(rects, rect)
            mark_map_with_rect(map, rect)
        end
        table.remove(random_map, index)
    end
    while #rects < 15 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local rect = random_rect_by_index(random_map[index], 2, map)
        if rect then
            table.insert(rects, rect)
            mark_map_with_rect(map, rect)
        end
        table.remove(random_map, index)
    end
    while #rects < 20 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local rect = random_rect_by_index(random_map[index], 3, map)
        if rect then
            table.insert(rects, rect)
            mark_map_with_rect(map, rect)
        end
        table.remove(random_map, index)
    end
    while #rects < 25 do
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local rect = random_rect_by_index(random_map[index], 4, map)
        if rect then
            table.insert(rects, rect)
            mark_map_with_rect(map, rect)
        end
        table.remove(random_map, index)
    end
    local rect = random_rect(map, 1, 1)
    print(rect.x, rect.y, rect.w, rect.h)
    out_put_map(map)
end


function out_put_map(map)
    print("=========================================")
    for i = 1, width do
        local t = {}
        for j = 1, height do
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









test_alliance_map()







