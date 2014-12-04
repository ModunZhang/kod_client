-- local Game = require("Game")
-- module( "test_alliance_map", lunit.testcase, package.seeall )

local width = 12
local height = 16
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
            map[i][j] = 0
        end
    end
    for i, v in ipairs(rects) do
        mark_map_with_rect(map, v)
    end
end
function mark_map_with_rect(map, rect,num)
    if type(num) ~= 'number' then num = "*" end
    iterator_every_point(rect, function(x, y)
        map[y][x] = num
    end)
end
function is_validate_rect(map, x, y, w, h)
    local validate = true
    iterator_every_point_with_size(x, y, w, h, function(x, y)
        if map[y] == nil or map[y][x] ~= 0 or map[y][x] == nil then
            validate = false
            return true
        end
    end)
    return validate
end
local alliance_decorator_map = {
    {width = 3, height = 3},
    {width = 2, height = 2},
    {width = 2, height = 1},
    {width = 1, height = 1},
}
function random_rect_by_index(index, tmp_index, map)
    local x, y = index % height == 0 and height or index % height,index % height == 0 and math.floor(index / width) or math.floor(index / width) + 1
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
    for i = 1, width do
        for j = 1, height do
            if  map[i][j] == 0 then
                table.insert(random_map, (i - 1) * height + j)
            end
        end
    end
    return random_map
end

function test_alliance_map()
    math.randomseed(os.time())
    local map = {}
    mark_map(map, {})
    mark_map_with_rect(map, {w = 16, h = 2, x = 16, y = 9})
    local rects = {}
    local random_map = get_index_from_map(map)
    
    print(#random_map)
     local r_3_1 = math.floor(math.random() * 100000) % 2 
    print("大山------>",r_3_1)
    randomRect(map,rects,random_map,1,1,r_3_1,true)
    local r_3_2 = math.floor(math.random() * 100000) % 2
    print("联盟建筑------>",r_3_2)
    randomRect(map,rects,random_map,1,2,r_3_2)
    -- -- 大湖
    local r_3_3 = math.floor(math.random() * 100000) % 2
    print("大湖------>",r_3_3)
     randomRect(map,rects,random_map,1,3,r_3_3,true)
    -- --小山
    local r_2_1 = math.floor(math.random() * 100000 % 3 + 1)
    print("小山------>",r_2_1)
    randomRect(map,rects,random_map,2,4,r_2_1,true)
    -- --小湖
    local r_2_2 = math.floor(math.random() * 100000 % 3 + 1)
    print("小湖------>",r_2_2)
    randomRect(map,rects,random_map,2,5,r_2_2,true)
    local fight = math.floor(math.random() * 100000) % 3 + 2 
    print("战斗士兵------>",fight)
    randomRect(map,rects,random_map,3,8,fight)
    --城市
    local r_1_1 = math.floor(math.random() * 100000) % 3
    print("城市------>",r_1_1)
    randomRect(map,rects,random_map,4,6,r_1_1)
    print("树------>",20)
    randomRect(map,rects,random_map,4,7,20)
    out_put_map(map)
end

function randomRect(map,rects,random_map,tmp_type,result_type,count,flipRandom)
    local find_index = true
    local length = #rects + count
    while (#rects < length) and find_index  do
        local random = math.floor(math.random() * 100000) % #random_map + 1
        local index = random_map[random]
        if not index then 
            find_index = false -- 找不到了
            assert(false)
            -- print("找不到了---->",random,tmp_type,result_type,count)
        else
            local rect = random_rect_by_index(index, tmp_type, map)
            if rect then
                rect['type'] = result_type
                if flipRandom then
                    rect['flipX'] = math.floor(math.random() * 100000) % 2
                end
                table.insert(rects, rect)
                mark_map_with_rect(map, rect,result_type)
                -- print("找到了---->",random,tmp_type,result_type,count)
            end
            table.remove(random_map, random)
        end 
    end
end

function out_put_map(map)
    print("=========================================")
    for i = 1, width do
        local t = {}
        for j = 1, height do
            table.insert(t, map[i][j] == 0 and "." or map[i][j])
        end
        print(table.concat(t, " "))
    end
    print("=========================================")
end








for i=1,1000 do
    test_alliance_map()
    -- print(i)
end







