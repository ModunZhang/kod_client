--
-- Author: Danny He
-- Date: 2014-12-02 15:25:58
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local GameUISplash = UIKit:createUIClass('GameUISplash')
local UILib = import(".UILib")
local RandomMapUtil = class("RandomMapUtil")
local Enum = import("..utils.Enum")
RandomMapUtil.TILE_TYPE = Enum("BIG_MOUNTAIN","ALLIANCE_BUILDING","BIG_LAKE","SMALL_MOUNTAIN","SMALL_LAKE","PLAYER_CITY","TREE","FIGHT","WATCHER")

function RandomMapUtil:ctor()
    self.width = 12
    self.height = 16
    self.alliance_decorator_map = {
        {width = 3, height = 3},
        {width = 2, height = 2},
        {width = 2, height = 1},
        {width = 1, height = 1},
    }
    self.rects = {}
end

function RandomMapUtil:iterator_every_point(rect, func)
    self:iterator_every_point_with_size(rect.x, rect.y, rect.w, rect.h, func)
end
function RandomMapUtil:iterator_every_point_with_size(x, y, w, h, func)
    assert(type(func) == "function")
    local sp, ep = self:return_start_end_from_size(x, y, w, h)
    for i = sp.x, ep.x do
        for j = sp.y, ep.y do
            if func(i, j) then
                return
            end
        end
    end
end
function RandomMapUtil:return_start_end_from_size(x, y, w, h)
    return {x = x - w + 1, y = y - h + 1}, {x = x, y = y}
end
function RandomMapUtil:mark_map(map, rects)
    for i = 1, self.width do
        map[i] = {}
        for j = 1, self.height do
            map[i][j] = 0
        end
    end
    for i, v in ipairs(rects) do
        self:mark_map_with_rect(map, v)
    end
end
function RandomMapUtil:mark_map_with_rect(map, rect,num)
    if type(num) ~= 'number' then num = "*" end
    self:iterator_every_point(rect, function(x, y)
        map[y][x] = num
    end)
end
function RandomMapUtil:is_validate_rect(map, x, y, w, h)
    local validate = true
    self:iterator_every_point_with_size(x, y, w, h, function(x, y)
        if map[y] == nil or map[y][x] ~= 0 or map[y][x] == nil then
            validate = false
            return true
        end
    end)
    return validate
end
function RandomMapUtil:random_rect_by_index(index, tmp_index, map)
    local x, y = index % self.height == 0 and self.height or index % self.height,index % self.height == 0 and math.floor(index / self.width) or math.floor(index / self.width) + 1
    local tmp = self.alliance_decorator_map[tmp_index]
    local rect = {w = tmp.width, h = tmp.height}
    for _, v in ipairs{
        {x = x, y = y},
        {x = x + rect.w - 1, y = y},
        {x = x, y = y + rect.h - 1},
        {x = x + rect.w - 1, y = y + rect.h - 1},
    } do
        if self:is_validate_rect(map, v.x, v.y, rect.w, rect.h) then
            rect.x = v.x
            rect.y = v.y
            return rect
        end
    end
    return nil
end
function RandomMapUtil:random_rect(map, w, h)
    local random_map = get_index_from_map(map)
    local max_depth = 5
    local i = 0
    repeat
        i = i + 1
        local index = math.floor(math.random() * 100000) % #random_map + 1
        local rect = self:random_rect_with_index(map, w, h, index)
        if rect then
            return rect
        end
        table.remove(random_map, index)
        if i > max_depth then
            return
        end
    until true
end
function RandomMapUtil:random_rect_with_index(map, w, h, index)
    local x, y = index % self.width, math.floor(index / self.width) + 1
    for _, v in ipairs{
        {x = x, y = y},
        {x = x + w - 1, y = y},
        {x = x, y = y + h - 1},
        {x = x + w - 1, y = y + h - 1},
    } do
        if self:is_validate_rect(map, v.x, v.y, w, h) then
            return {x = v.x, y = v.y, w = w, h = h}
        end
    end
    return nil
end
function RandomMapUtil:get_index_from_map(map)
    local random_map = {}
    for i = 1, self.width do
        for j = 1, self.height do
            if  map[i][j] == 0 then
                table.insert(random_map, (i - 1) * self.height + j)
            end
        end
    end
    return random_map
end

function RandomMapUtil:Random()
    local map = {}
    self:mark_map(map, {})
    self:mark_map_with_rect(map, {w = 16, h = 2, x = 16, y = 9})
    local rects = {}
    local random_map = self:get_index_from_map(map)
    local r_3_1 = math.floor(math.random() * 100000) % 2 + 1 
    --大山
    self:randomRect(map,rects,random_map,1,RandomMapUtil.TILE_TYPE.BIG_MOUNTAIN,r_3_1,true)
    local r_3_2 = math.floor(math.random() * 100000) % 2 + 1
    --联盟建筑
    self:randomRect(map,rects,random_map,1,RandomMapUtil.TILE_TYPE.ALLIANCE_BUILDING,r_3_2)
    -- 大湖
    local r_3_3 = math.floor(math.random() * 100000) % 2 + 1
    self:randomRect(map,rects,random_map,1,RandomMapUtil.TILE_TYPE.BIG_LAKE,r_3_3,true)
    --小山
    local r_2_1 = math.floor(math.random() * 100000 % 5 + 2)
    self:randomRect(map,rects,random_map,2,RandomMapUtil.TILE_TYPE.SMALL_MOUNTAIN,r_2_1,true)
    --小湖
    local r_2_2 = math.floor(math.random() * 100000 % 5 + 2)
    self:randomRect(map,rects,random_map,2,RandomMapUtil.TILE_TYPE.SMALL_LAKE,r_2_2,true)
    --城市
    -- local r_1_1 = math.floor(math.random() * 100000) % 5
    --战斗士兵
    local fight_count = math.floor(math.random() * 100000) % 3 + 2 
    self:randomRect(map,rects,random_map,3,RandomMapUtil.TILE_TYPE.FIGHT,fight_count)
    --玩家城市
    -- self:randomRect(map,rects,random_map,4,RandomMapUtil.TILE_TYPE.PLAYER_CITY,r_1_1)
    --打望的
    self:randomRect(map,rects,random_map,4,RandomMapUtil.TILE_TYPE.WATCHER,1)
    self:randomRect(map,rects,random_map,4,RandomMapUtil.TILE_TYPE.TREE,20)
    self.rects = rects
    if CONFIG_IS_DEBUG then
        -- print("大山------>",RandomMapUtil.TILE_TYPE.BIG_MOUNTAIN,r_3_1)
        -- print("联盟建筑------>",RandomMapUtil.TILE_TYPE.ALLIANCE_BUILDING,r_3_2)
        -- print("大湖------>", RandomMapUtil.TILE_TYPE.BIG_LAKE,r_3_3)
        -- print("小山------>",RandomMapUtil.TILE_TYPE.SMALL_MOUNTAIN,r_2_1)
        -- print("小湖------>",RandomMapUtil.TILE_TYPE.SMALL_LAKE,r_2_2)
        -- print("树------>",RandomMapUtil.TILE_TYPE.TREE,20)
        -- print("战斗士兵------>",RandomMapUtil.TILE_TYPE.FIGHT,fight_count)
        -- self:out_put_map(map)
    end
end


function RandomMapUtil:out_put_map(map)
    print("=========================================")
    for i = 1, self.width do
        local t = {}
        for j = 1, self.height do
            table.insert(t, map[i][j] == 0 and "." or map[i][j])
        end
        print(table.concat(t, " "))
    end
    print("=========================================")
end

function RandomMapUtil:randomRect(map,rects,random_map,tmp_type,result_type,count,flipRandom)
    local find_index = true
    local length = #rects + count
    while (#rects < length) and find_index  do
        local random = math.floor(math.random() * 100000) % #random_map + 1
        local index = random_map[random]
        if not index then 
            find_index = false
        else
            local rect = self:random_rect_by_index(index, tmp_type, map)
            if rect then
                rect['type'] = result_type
                if flipRandom then
                    rect['flipX'] = math.floor(math.random() * 100000) % 2
                end
                table.insert(rects, rect)
                self:mark_map_with_rect(map, rect,result_type)
            end
            table.remove(random_map, random)
        end 
    end
end

function RandomMapUtil:GetRects()
    self:Random()
    return self.rects or {}
end

---------------------------------------------------------------------------------------------------------------------------------------------
-- GameUISplash

local tile_w = math.ceil(display.width/8)
local tile_h = math.ceil(display.height/12)
local scale_tile = math.min(tile_w,tile_h)
local layer_offset_x = tile_w * 16 - display.width * 2

local building_map = {
    {"palace_421x481.png", scale_tile*2/481},
    {"shrine_256x210.png", scale_tile*2/256 * 0.7},
    {"shop_268x274.png", scale_tile*2/274 * 0.5},
    {"orderHall_277x417.png", scale_tile*2/417},
    {"moonGate_200x217.png", scale_tile*2/217},
}

local ZORDER = {
    BOTTOM = 0,
    MIDDLE = 1,
    TOP = 2,
    DECORATE = 3,
    SOLDIER = 10001,
    CLOUD = 10002,
    CLOUD_ANIMATE_LAYER = 10003,
    UI    = 10004
}
local MaxZorder = 10000
local random = math.random
local timer_val = 20
GameUISplash.SOLDIER_2_1_TYPE = Enum("I_VS_I","C_VS_C","C_VS_I")
GameUISplash.WATCHER_ANIMATE = {
    {"Cavalry_1_render",scale_tile/400}, {"Infantry_1_render",scale_tile/336},{"Archer_1_render",scale_tile/340} --,{"Catapult_1_render",scale_tile/200}
}
local function random_indexes_in_rect(number, rect,perRect)
    local indexes = {}
    local count = 0
    local random_map = {}
    repeat
        local x = random(123456789) % (rect.width + 1)
        if x + perRect.width > rect.width then
           x =  rect.width - perRect.width
        end
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

function GameUISplash:ctor()
	GameUISplash.super.ctor(self)
    self.random_map_util = RandomMapUtil.new()
    --加载动画信息
    local manager = ccs.ArmatureDataManager:getInstance()
    audio.playMusic("audios/music_begin.mp3", true)
    local soldier_anmations = {
        {"animations/Infantry_1_render0.plist","animations/Infantry_1_render0.png","animations/Infantry_1_render.ExportJson"},
        {"animations/Cavalry_1_render0.plist","animations/Cavalry_1_render0.png","animations/Cavalry_1_render.ExportJson"},
        {"animations/Archer_1_render0.plist","animations/Archer_1_render0.png","animations/Archer_1_render.ExportJson"},
        {"animations/Catapult_1_render0.plist","animations/Catapult_1_render0.png","animations/Catapult_1_render.ExportJson"},
        {"animations/Cloud_Animation0.plist","animations/Cloud_Animation0.png","animations/Cloud_Animation.ExportJson"},
    }
    for _,v in ipairs(soldier_anmations) do
        local plist,png,export_json = unpack(v)
        display.addSpriteFrames(plist,png)
        manager:addArmatureFileInfo(export_json)
    end
end

function GameUISplash:onEnter()
	GameUISplash.super.onEnter(self)
	local layer_1 = self:CreateOneFullLayer():addTo(self,self:GetMaxZorder())
    local sequence = transition.sequence({
        cc.MoveTo:create(timer_val, cc.p(-display.width, 0)),
        cc.CallFunc:create(handler(self, self.AddLyaer_2)),
        cc.MoveBy:create(timer_val*2, cc.p(-display.width*2, 0)),
        cc.CallFunc:create(function()
            layer_1:removeFromParent()
        end),
    })
    layer_1:runAction(sequence)
	self:InitSoldiersLayer():addTo(self):zorder(ZORDER.SOLDIER)
    self:InitCloudLayer()
    self.ui_layer = self:InitUILayer():addTo(self)
    self.handle_ = scheduler.scheduleGlobal(function()
        self:CreateCloudSpriteAnimate()
    end, timer_val/2) 
end

function GameUISplash:onCleanup()
    scheduler.unscheduleGlobal(self.handle_)
    GameUISplash.super.onCleanup(self)
end

function GameUISplash:AddLyaer_2()
	local layer_2 = self:CreateOneFullLayer():addTo(self,self:GetMaxZorder()):pos(display.width + layer_offset_x - 4,0)
	local sequence = transition.sequence({
    	cc.MoveTo:create(timer_val*2, cc.p(-display.width, 0)),
    	cc.CallFunc:create(handler(self, self.AddLyaer_2)),
    	cc.MoveBy:create(timer_val*2, cc.p(-display.width*2, 0)),
    	cc.CallFunc:create(function()
    		layer_2:removeFromParent()
    	end),
	})
	layer_2:runAction(sequence)
end

function GameUISplash:GetMaxZorder()
    local ret = MaxZorder
    MaxZorder = MaxZorder - 1 
    return ret
end

function GameUISplash:CreateOneFullLayer(png)
	local layer = display.newLayer()
	self:InitBottomBackground():addTo(layer, ZORDER.BOTTOM)
	self:InitMiddleBackground():addTo(layer, ZORDER.MIDDLE)
	self:InitTopBackground():addTo(layer, ZORDER.TOP)
    self:InitDecorateBackground():addTo(layer,ZORDER.DECORATE):pos(0,0)
	return layer
end

function GameUISplash:InitDecorateBackground()
    local layer = display.newLayer()
    local map_data = self.random_map_util:GetRects()
    
    self:BuildDecorateWithiOffset(map_data,layer)
    return layer
end

function GameUISplash:RandomVsSoliders(layer,postion_x,postion_y)
    -- display.newScale9Sprite("grass_80x80_.png"):size(160,80):align(display.RIGHT_BOTTOM, postion_x,postion_y):addTo(layer)
    local vs_type = math.floor(math.random() * 100000) % 3 + 1
    if vs_type == self.SOLDIER_2_1_TYPE.I_VS_I then
        local infantry_1 = ccs.Armature:create("Infantry_1_render")
                :align(display.RIGHT_BOTTOM, postion_x - 40 ,postion_y)
                :addTo(layer)
                :scale(scale_tile/336)
        infantry_1:getAnimation():play("attack", -1, -1)
        local infantry_2 = ccs.Armature:create("Infantry_1_render")
                :align(display.LEFT_BOTTOM, postion_x,postion_y)
                :addTo(layer)
        infantry_2:setScaleY(scale_tile/336)
        infantry_2:setScaleX(-scale_tile/336)
        self:performWithDelay(function()
            infantry_2:getAnimation():play("attack", -1, -1)
        end, 1)
    elseif vs_type == self.SOLDIER_2_1_TYPE.C_VS_C then
        local cavalry_1 = ccs.Armature:create("Cavalry_1_render")
            :align(display.RIGHT_BOTTOM, postion_x - 40 ,postion_y)
            :addTo(layer)
            :scale(scale_tile/400)
        cavalry_1:getAnimation():play("attack", -1, -1)
        local cavalry_2 = ccs.Armature:create("Cavalry_1_render")
            :align(display.LEFT_BOTTOM, postion_x,postion_y)
            :addTo(layer)
        cavalry_2:setScaleY(scale_tile/400)
        cavalry_2:setScaleX(-scale_tile/400)
        self:performWithDelay(function()
            cavalry_2:getAnimation():play("attack", -1, -1)
        end, 1)
    elseif vs_type == self.SOLDIER_2_1_TYPE.C_VS_I then
        local cavalry_1 = ccs.Armature:create("Cavalry_1_render")
            :align(display.RIGHT_BOTTOM, postion_x - 40 ,postion_y)
            :addTo(layer)
            :scale(scale_tile/400)
        cavalry_1:getAnimation():play("attack", -1, -1)
        local infantry_2 = ccs.Armature:create("Infantry_1_render")
                :align(display.LEFT_BOTTOM, postion_x,postion_y)
                :addTo(layer)
        infantry_2:setScaleY(scale_tile/336)
        infantry_2:setScaleX(-scale_tile/336)
        self:performWithDelay(function()
            infantry_2:getAnimation():play("attack", -1, -1)
        end, 1)
    end
end

function GameUISplash:RandomWatcher(layer,postion_x,postion_y)
    local index = math.floor(math.random() * 100000) % (#self.WATCHER_ANIMATE) + 1
    local info = self.WATCHER_ANIMATE[index]
    local watcher = ccs.Armature:create(info[1])
            :align(display.RIGHT_BOTTOM, postion_x ,postion_y)
            :addTo(layer)
            :scale(info[2])
    watcher:getAnimation():play("idle_1", -1, -1)
end

function GameUISplash:BuildDecorateWithiOffset(map_data,layer,offset_x,offset_y)
    for _,v in ipairs(map_data) do
        local postion_x,postion_y = unpack(self:ConvertToLocalPosition(v.x,v.y))
        postion_x = postion_x + (offset_x or 0)
        postion_y = postion_y + (offset_y or 0)
        local text  = v.type
        
        if v.type == RandomMapUtil.TILE_TYPE.PLAYER_CITY then
            --TODO:城市暂时被丢弃
        elseif v.type == RandomMapUtil.TILE_TYPE.TREE then   
            display.newSprite(UILib.decorator_image.decorate_tree_1)
                 :align(display.RIGHT_BOTTOM,postion_x,postion_y)
                :addTo(layer)
                :scale(scale_tile/120)
        elseif v.type == RandomMapUtil.TILE_TYPE.FIGHT then  
           self:RandomVsSoliders(layer,postion_x,postion_y)
        elseif v.type == RandomMapUtil.TILE_TYPE.SMALL_LAKE then
            local sp = display.newSprite(UILib.decorator_image.decorate_lake_2)
                :align(display.RIGHT_BOTTOM,postion_x,postion_y)
                :addTo(layer)
                :scale(scale_tile*2/228)
            if v.flipX then
                sp:setFlippedX(true)
            end
        elseif v.type == RandomMapUtil.TILE_TYPE.SMALL_MOUNTAIN then
            local sp = display.newSprite(UILib.decorator_image.decorate_mountain_2)
                 :align(display.RIGHT_BOTTOM,postion_x,postion_y)
                :addTo(layer)
                :scale(scale_tile*2/228)
            if v.flipX then
                sp:setFlippedX(true)
            end
        elseif v.type == RandomMapUtil.TILE_TYPE.WATCHER then
            
            self:RandomWatcher(layer,postion_x,postion_y)
        elseif v.type == RandomMapUtil.TILE_TYPE.BIG_LAKE then
            local sp = display.newSprite(UILib.decorator_image.decorate_lake_1)
                 :align(display.RIGHT_BOTTOM,postion_x,postion_y)
                :addTo(layer)
                :scale(scale_tile*3/288)
            if v.flipX then
                sp:setFlippedX(true)
            end
        elseif v.type == RandomMapUtil.TILE_TYPE.ALLIANCE_BUILDING then
            local index = math.floor(math.random() * 100000) % (#building_map) + 1 
            local info = building_map[index]
            local sp = display.newSprite(info[1])
                :align(display.RIGHT_BOTTOM,postion_x,postion_y)
                :addTo(layer)
                :scale(info[2])
        elseif v.type == RandomMapUtil.TILE_TYPE.BIG_MOUNTAIN then
            local sp = display.newSprite(UILib.decorator_image.decorate_mountain_1)
                 :align(display.RIGHT_BOTTOM,postion_x,postion_y)
                :addTo(layer)  
                :scale(scale_tile*3/312)
            if v.flipX then
                sp:setFlippedX(true)
            end

        end
     end
end
-- grass_80x80
function GameUISplash:InitBottomBackground()
	local bottom_layer = display.newLayer()
	local numOfRow = 12
	local numOfHor = 16
	local x,y = 0,0
	for col=1,numOfRow do
		for hor=1,numOfHor do
			local sp = display.newSprite("grass_80x80.png"):align(display.LEFT_BOTTOM,x, y):addTo(bottom_layer)
            sp:setScaleX(tile_w/80)
            sp:setScaleY(tile_h/80)
			x = x + tile_w
		end
		y = y + tile_h
		x = 0
	end
	return bottom_layer
end

function GameUISplash:InitMiddleBackground()
    local middle_layer = display.newLayer()
    local png = {
        "grass1_800x560.png",
        "grass2_800x560.png",
        "grass3_800x560.png",
    }
    local indexes = random_indexes_in_rect(4, cc.rect(0, 0, display.width*2, display.height),cc.rect(0,0,800,560))
    for i, v in pairs(indexes) do
        local png_index = random(123456789) % 3 + 1
        display.newSprite(png[png_index]):addTo(middle_layer)
            :align(display.LEFT_CENTER, v.x, v.y):scale(0.8)
    end
    math.randomseed(os.time())
    return middle_layer
end

function GameUISplash:InitTopBackground()
    local png = {
        "grass1_400x280.png",
        "grass2_400x280.png",
        "grass3_400x280.png",
    }
    local top_layer = display.newLayer()
    local indexes = random_indexes_in_rect(8, cc.rect(0, 0, display.width*2, display.height),cc.rect(0,0,400,280))
    for i, v in ipairs(indexes) do
        display.newSprite(png[v.png_index]):addTo(top_layer)
            :align(display.LEFT_CENTER,v.x, v.y)
    end
    return top_layer
end

function GameUISplash:InitSoldiersLayer()
	local soldiers_layer = display.newLayer()
    --骑兵 
    local x,y = unpack(self:ConvertToLocalPosition(6,9))
    local cavalry_1 = ccs.Armature:create("Cavalry_1_render"):addTo(soldiers_layer):pos(x - 40,y + 20 + 20)
    cavalry_1:getAnimation():play("move_2", -1, -1)
    cavalry_1:scale(scale_tile/400)
    x,y = unpack(self:ConvertToLocalPosition(6,8))
    local cavalry_2 = ccs.Armature:create("Cavalry_1_render"):addTo(soldiers_layer):pos(x - 40,y)
    cavalry_2:getAnimation():play("move_2", -1, -1)
    cavalry_2:scale(scale_tile/400)
    --步兵
    x,y = unpack(self:ConvertToLocalPosition(5,8))
    local infantry_1 = ccs.Armature:create("Infantry_1_render"):addTo(soldiers_layer):pos(x - 10,y)
    infantry_1:getAnimation():play("move_2", -1, -1)
    infantry_1:scale(scale_tile/336)
    local infantry_2 = ccs.Armature:create("Infantry_1_render"):addTo(soldiers_layer):pos(x - 40,y)
    infantry_2:getAnimation():play("move_2", -1, -1)
    infantry_2:scale(scale_tile/336)
    x,y = unpack(self:ConvertToLocalPosition(5,9))
    local infantry_3 = ccs.Armature:create("Infantry_1_render"):addTo(soldiers_layer):pos(x - 10,y + 20 + 20)
    infantry_3:getAnimation():play("move_2", -1, -1)
    infantry_3:scale(scale_tile/336)
    local infantry_4 = ccs.Armature:create("Infantry_1_render"):addTo(soldiers_layer):pos(x - 40,y + 20 + 20)
    infantry_4:getAnimation():play("move_2", -1, -1)
    infantry_4:scale(scale_tile/336)
    --弓箭手
    x,y = unpack(self:ConvertToLocalPosition(4,8))
    -- Archer_1_render
    local archer_1 = ccs.Armature:create("Archer_1_render"):addTo(soldiers_layer):pos(x - 10,y)
    archer_1:getAnimation():play("move_2", -1, -1)
    archer_1:scale(scale_tile/340)
    local archer_2 = ccs.Armature:create("Archer_1_render"):addTo(soldiers_layer):pos(x - 40,y)
    archer_2:getAnimation():play("move_2", -1, -1)
    archer_2:scale(scale_tile/340)
    x,y = unpack(self:ConvertToLocalPosition(4,9))
    local archer_3 = ccs.Armature:create("Archer_1_render"):addTo(soldiers_layer):pos(x - 10,y + 20 + 20)
    archer_3:getAnimation():play("move_2", -1, -1)
    archer_3:scale(scale_tile/340)
    local archer_4 = ccs.Armature:create("Archer_1_render"):addTo(soldiers_layer):pos(x - 40,y + 20 + 20)
    archer_4:getAnimation():play("move_2", -1, -1)
    archer_4:scale(scale_tile/340)
    --投石车
    x,y = unpack(self:ConvertToLocalPosition(3,9))
    local catapult = ccs.Armature:create("Catapult_1_render"):addTo(soldiers_layer):pos(x - 40,y + 50)
    catapult:getAnimation():play("move_2", -1, -1)
    catapult:scale(scale_tile/200)
	return soldiers_layer
end

function GameUISplash:ConvertToLocalPosition(map_x, map_y)
    return {map_x * tile_w,display.height - map_y * tile_h}
end

function GameUISplash:InitUILayer()
    local ui_layer = display.newLayer():zorder(ZORDER.UI)
    display.newSprite("gameName.png"):addTo(ui_layer):pos(display.cx,display.height - 120)
    return ui_layer
end

function GameUISplash:InitCloudLayer()
    local x,y = 0,0
    local sprite = display.newSprite("#Cloud.png")
    local width = sprite:getContentSize().width
    --bottom
    for i=1,10 do
        x = math.floor(math.random() * 100000) % display.width
        y = math.floor(math.random() * 100000) % 50 + 10
        local opacity_rand = math.floor(math.random() * 100000) % 255
        local time_rand =  timer_val * 2
        local sp = display.newSprite("#Cloud.png"):addTo(self,ZORDER.CLOUD_ANIMATE_LAYER):align(display.LEFT_CENTER,x,y):opacity(opacity_rand)
        local sequence = transition.sequence({
            cc.MoveTo:create(time_rand, cc.p(-display.cx, y)),
            cc.CallFunc:create(function()
                -- print("sp:removeFromParent....")
                sp:removeFromParent()
            end),
        })
        sp:runAction(sequence) 
    end
    --top
    for i=1,10 do
         x = math.floor(math.random() * 100000) % display.width 
         y = display.height - math.floor(math.random() * 100000) % 40 - 80
         local time_rand =  timer_val * 2
         local opacity_rand = math.floor(math.random() * 100000) % 255
         local sp = display.newSprite("#Cloud.png"):addTo(self,ZORDER.CLOUD_ANIMATE_LAYER):align(display.LEFT_CENTER,x,y):opacity(opacity_rand)
         local sequence = transition.sequence({
            cc.MoveTo:create(time_rand, cc.p(-display.cx, y)),
            cc.CallFunc:create(function()
                -- print("sp:removeFromParent....")
                sp:removeFromParent()
            end),
        })
        sp:runAction(sequence) 
    end
end

function GameUISplash:CreateCloudSpriteAnimate()
    local x,y = 0,0
    local sprite = display.newSprite("#Cloud.png")
    local width = sprite:getContentSize().width
    local count = math.floor(math.random() * 100000) % 20 + 1
    for i=1,count do
        x = math.floor(math.random() * 100000) % display.width + display.width
        y = math.floor(math.random() * 100000) % 50 + 10
        local sp = display.newSprite("#Cloud.png"):addTo(self,ZORDER.CLOUD_ANIMATE_LAYER):align(display.LEFT_CENTER,x,y)
        local time_rand = math.floor(math.random() * 100000) % timer_val + timer_val/2
        local opacity_rand = math.floor(math.random() * 100000) % 255
        local sequence = transition.sequence({
            cc.MoveTo:create(time_rand, cc.p(-display.width, y)),
            cc.CallFunc:create(function()
                -- print("cloud:removeFromParent....")
                sp:removeFromParent()
            end),
        })
        sp:setOpacity(opacity_rand)
        sp:runAction(sequence) 
    end
    count = math.floor(math.random() * 100000) % 20 + 1
    for i=1,count do
        x = math.floor(math.random() * 100000) %  display.width + display.width
        y = display.height - math.floor(math.random() * 100000) % 40 - 80
        local sp = display.newSprite("#Cloud.png"):addTo(self,ZORDER.CLOUD_ANIMATE_LAYER):align(display.LEFT_CENTER,x,y)
        local time_rand = math.floor(math.random() * 100000) % timer_val + timer_val/2
        local opacity_rand = math.floor(math.random() * 100000) % 255
        local sequence = transition.sequence({
            cc.MoveTo:create(time_rand, cc.p(-display.width, y)),
            cc.CallFunc:create(function()
                -- print("cloud:removeFromParent....")
                sp:removeFromParent()
            end),
        })
        sp:setOpacity(opacity_rand)
        sp:runAction(sequence) 
    end
end

return GameUISplash