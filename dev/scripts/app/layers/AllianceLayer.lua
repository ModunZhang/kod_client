local AllianceBuildingSprite = import("..sprites.AllianceBuildingSprite")
local AllianceDecoratorSprite = import("..sprites.AllianceDecoratorSprite")
local CitySprite = import("..sprites.CitySprite")
local Observer = import("..entity.Observer")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local AllianceLayer = class("AllianceLayer", MapLayer)
----
function AllianceLayer:ctor(city)
    Observer.extend(self)
    AllianceLayer.super.ctor(self, 0.3, 1)
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = 80,
        tile_h = 80,
        map_width = 21,
        map_height = 21,
        base_x = 0,
        base_y = 21 * 80
    }

    self:InitBackground()

    local floor = math.floor
    local random = math.random
    math.randomseed(1985423439857)

    local png = {
        "grass1_800x560.png",
        "grass2_800x560.png",
        "grass3_800x560.png",
    }
    local bottom_layer = display.newNode():addTo(self)
    for i, v in pairs{
        {x = 4.5, y = 4.5},
        {x = 4.5, y = 14.5},
        {x = 14.5, y = 4.5},
        {x = 14.5, y = 14.5},
    } do
        local png_index = random(123456789) % 3 + 1
        display.newSprite(png[png_index], nil, nil, {class=cc.FilteredSpriteWithOne}):addTo(bottom_layer)
            :align(display.CENTER, self.normal_map:ConvertToMapPosition(v.x, v.y))
            :setFilter(filter)
    end
    local function random_indexes_in_rect(number, rect)
        local indexes = {}
        local count = 0
        local random_map = {}
        repeat
            local x = random(123456789) % (rect.width + 1)
            if not random_map[x] then
                random_map[x] = {}
            end
            local y = random(123456789) % (rect.height + 1)
            if not random_map[x][y] then
                random_map[x][y] = true

                local png_index = random(123456789) % 3 + 1
                table.insert(indexes, {x = x + rect.x, y = y + rect.y, png_index = png_index})
                count = count + 1
            end
        until number < count
        return indexes
    end

    local png = {
        "grass1_400x280.png",
        "grass2_400x280.png",
        "grass3_400x280.png",
    }
    local middle_layer = display.newNode():addTo(self)
    local indexes = random_indexes_in_rect(20, cc.rect(0, 0, 21, 21))
    for i, v in ipairs(indexes) do
        display.newSprite(png[v.png_index], nil, nil, {class=cc.FilteredSpriteWithOne}):addTo(middle_layer)
            :align(display.CENTER, self.normal_map:ConvertToMapPosition(v.x, v.y))
            :setFilter(filter)
    end


    local filter = filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/mask_layer.fs",
            shaderName = "mask_layer",
            iResolution = {display.widthInPixels, display.heightInPixels}
        })
    )

    --
    CitySprite.new(self, 11, 11):addTo(self)
    CitySprite.new(self, 14, 11):addTo(self)
    CitySprite.new(self, 11, 14):addTo(self)
    CitySprite.new(self, 8, 11):addTo(self)
    CitySprite.new(self, 11, 8):addTo(self)


    local function return_start_end_from(decorator)
        return {x = decorator.x - decorator.width + 1, y = decorator.y - decorator.height + 1},
            {x = decorator.x, y = decorator.y}
    end
    local function iterator_every_point(decorator, func)
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
    local alliance_decorator_map = {
        {width = 1, height = 1},
        {width = 2, height = 1},
        {width = 2, height = 2},
        {width = 3, height = 2},
    }
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
    local function random_decorator_by_index(index, tmp_index, map)
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
    local function update_map_with_decorator(map, decorator)
        iterator_every_point(decorator, function(x, y)
            map[y][x] = true
        end)
    end
    local function get_index_from_map(map)
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
    local map = {}
    for i = 1, 21 do
        map[i] = {}
        for j = 1, 21 do
            map[i][j] = false
        end
    end
    update_map_with_decorator(map, {width = 3, height = 3, x = 12, y = 12})
    update_map_with_decorator(map, {width = 3, height = 3, x = 15, y = 12})
    update_map_with_decorator(map, {width = 3, height = 3, x = 12, y = 15})
    update_map_with_decorator(map, {width = 3, height = 3, x = 9, y = 12})
    update_map_with_decorator(map, {width = 3, height = 3, x = 12, y = 9})
    -- math.randomseed(23590239)
    local random_map = get_index_from_map(map)
    local decorators = {}
    while #decorators < 20 do
        local index = random(123456789) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 1, map)
        if decorator then
            table.insert(decorators, decorator)
            update_map_with_decorator(map, decorator)
        end
        table.remove(random_map, index)
    end
    while #decorators < 39 do
        local index = random(123456789) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 2, map)
        if decorator then
            table.insert(decorators, decorator)
            update_map_with_decorator(map, decorator)
        end
        table.remove(random_map, index)
    end
    while #decorators < 50 do
        local index = random(123456789) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 3, map)
        if decorator then
            table.insert(decorators, decorator)
            update_map_with_decorator(map, decorator)
        end
        table.remove(random_map, index)
    end
    while #decorators < 60 do
        local index = random(123456789) % #random_map + 1
        local decorator = random_decorator_by_index(random_map[index], 4, map)
        if decorator then
            table.insert(decorators, decorator)
            update_map_with_decorator(map, decorator)
        end
        table.remove(random_map, index)
    end

    for i, v in pairs(decorators) do
        if v.width == 3 and v.height == 2 then
            AllianceDecoratorSprite.new(self, v.x - 1, v.y - 1, 3, 2, "lake2"):addTo(self)
        elseif v.width == 2 and v.height == 2 then
            AllianceDecoratorSprite.new(self, v.x - 1, v.y - 1, 2, 2, "lake1"):addTo(self)
        elseif v.width == 2 and v.height == 1 then
            AllianceDecoratorSprite.new(self, v.x - 1, v.y - 1, 2, 1, "hill1"):addTo(self)
        elseif v.width == 1 and v.height == 1 then
            AllianceDecoratorSprite.new(self, v.x - 1, v.y - 1, 1, 1, "hill2"):addTo(self)
        end
    end
    -- AllianceBuildingSprite.new(self, 5, 15):addTo(self)
    -- AllianceBuildingSprite.new(self, 15, 5):addTo(self)
    -- AllianceBuildingSprite.new(self, 10, 18):addTo(self)
    -- AllianceBuildingSprite.new(self, 1, 15):addTo(self)
    -- display.newSprite("grass_80x80_.png"):addTo(self):align(display.CENTER, self.normal_map:ConvertToMapPosition(10, 10))
end
function AllianceLayer:GetMapSize()
    return 21, 21
end
function AllianceLayer:GetLogicMap()
    return self.normal_map
end
function AllianceLayer:ConvertLogicPositionToMapPosition(lx, ly)
    local map_pos = cc.p(self.normal_map:ConvertToMapPosition(lx, ly))
    return self:convertToNodeSpace(self.background:convertToWorldSpace(map_pos))
end
function AllianceLayer:InitBackground()
    self.background = cc.TMXTiledMap:create("tmxmaps/alliance_background.tmx"):addTo(self)
end
function AllianceLayer:InitBuildingNode()
    self.building_node = display.newNode():addTo(self)
end

function AllianceLayer:GetBuildingNode()
    return self.building_node
end


----- override
function AllianceLayer:getContentSize()
    if not self.content_size then
        local layer = self.background:getLayer("layer1")
        self.content_size = layer:getContentSize()
    end
    return self.content_size
end


function AllianceLayer:OnSceneMove()

end

return AllianceLayer

































