local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local WorldLayer = class("WorldLayer", MapLayer)


local ui_helper = WidgetAllianceHelper.new()
local TILE_LENGTH = 207
local CORNER_LENGTH = 47
local WIDTH, HEIGHT = 41, 41
local MAX_INDEX = WIDTH * HEIGHT - 1
local SHADER_WIDTH = 42
local width, height = WIDTH * TILE_LENGTH, HEIGHT * TILE_LENGTH
local worldsize = {width = width + 2 * CORNER_LENGTH, height = height + 2 * CORNER_LENGTH}
assert(SHADER_WIDTH % 2 == 0)


function WorldLayer:ctor(scene)
    WorldLayer.super.ctor(self, scene, 0.4, 1.2)
end
function WorldLayer:onEnter()
    self:CreateCorner()
    self:CreateEdge()
    self.map = self:CreateMap()
    self:CreateAllianceLayer()
    self.allainceSprites = {}
end
function WorldLayer:CreateCorner()
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH/2, CORNER_LENGTH/2)
        :addTo(self):scale(1):rotation(-90)
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH/2, CORNER_LENGTH*3/2 + TILE_LENGTH * HEIGHT)
        :addTo(self):scale(1):rotation(0)
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH*3/2 + TILE_LENGTH * WIDTH, CORNER_LENGTH/2)
        :addTo(self):scale(1):rotation(180)
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH*3/2 + TILE_LENGTH * WIDTH, CORNER_LENGTH*3/2 + TILE_LENGTH * HEIGHT)
        :addTo(self):scale(1):rotation(90)
end
function WorldLayer:CreateEdge()
    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex1",
        unit_count = HEIGHT,
        unit_len = 1 / HEIGHT,
    })):pos(CORNER_LENGTH/2, CORNER_LENGTH + HEIGHT * TILE_LENGTH * 0.5)
        :addTo(self):setScaleY(HEIGHT)

    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex2",
        unit_count = HEIGHT,
        unit_len = 1 / HEIGHT,
    })):pos(CORNER_LENGTH*3/2 + TILE_LENGTH * WIDTH, CORNER_LENGTH + HEIGHT * TILE_LENGTH * 0.5)
        :addTo(self):setScaleY(HEIGHT):flipX(true)

    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex3",
        unit_count = WIDTH,
        unit_len = 1 / WIDTH,
    })):pos(CORNER_LENGTH + WIDTH * TILE_LENGTH * 0.5, CORNER_LENGTH*3/2 + TILE_LENGTH * HEIGHT)
        :addTo(self):setScaleY(WIDTH):rotation(90)

    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex4",
        unit_count = WIDTH,
        unit_len = 1 / WIDTH,
    })):pos(CORNER_LENGTH + WIDTH * TILE_LENGTH * 0.5, CORNER_LENGTH/2)
        :addTo(self):setScaleY(WIDTH):rotation(-90)
end
function WorldLayer:CreateMap()
    local clip = display.newClippingRegionNode(cc.rect(0,0, TILE_LENGTH * 41, TILE_LENGTH * 41))
        :addTo(self):align(display.LEFT_BOTTOM,CORNER_LENGTH,CORNER_LENGTH)

    local map = display.newFilteredSprite("world_terrain1.jpg", "CUSTOM", json.encode({
        frag = "shaders/maptex.fs",
        shaderName = "maptex",
        size = {SHADER_WIDTH/2, HEIGHT, 1/(SHADER_WIDTH/2), 1/HEIGHT}
    })):pos(SHADER_WIDTH * TILE_LENGTH * 0.5, HEIGHT * TILE_LENGTH * 0.5):addTo(clip)
    local cache = cc.Director:getInstance():getTextureCache()
    cache:addImage("world_terrain2.jpg")
    cache:addImage("world_terrain3.jpg")
    cache:addImage("world_terrain4.jpg")
    cache:addImage("world_map.png"):setAliasTexParameters()
    map:getGLProgramState():setUniformTexture("textures5", cache:getTextureForKey("world_map.png"):getName())
    map:setScaleX(SHADER_WIDTH/2)
    map:setScaleY(HEIGHT)

    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_LENGTH,
        tile_h = TILE_LENGTH,
        map_width = WIDTH,
        map_height = HEIGHT,
        base_x = 0,
        base_y = 41 * TILE_LENGTH,
    }
    return clip
end
function WorldLayer:CreateAllianceLayer()
    self.allianceLyaer = display.newNode():addTo(self.map)
end
function WorldLayer:LoadAlliance()
    dump(self:GetAvailableIndex())
    NetManager:getMapAllianceDatasPromise(self:GetAvailableIndex()):done(function(response)
        dump(response.msg.datas)
        for k,v in pairs(response.msg.datas) do
            if v == json.null then
                if self.allainceSprites[index] then
                    self.allainceSprites[index]:removeFromParent()
                    self.allainceSprites[index] = nil
                end
            else
                if not self.allainceSprites[k] then
                    self:CreateAllianceSprite(k, v)
                else
                    self:UpdateAllianceSprite(k, v)
                end
            end
        end
    end)
end
function WorldLayer:CreateAllianceSprite(index, alliance)
    local sprite = display.newSprite(string.format("world_alliance_%s.png", alliance.terrain)):addTo(self.allianceLyaer)
        :pos(self:GetLogicMap():ConvertToMapPosition(self:IndexToLogic(index)))
    local size = sprite:getContentSize()
    local banner = display.newSprite("alliance_banner.png"):addTo(sprite):pos(size.width/2, 0)
    sprite.name = UIKit:ttfLabel({
        size = 12,
        color = 0xffedae,
        text = string.format("[%s]%s", alliance.tag, alliance.name),
        ellipsis = true,
        dimensions = cc.size(100,15),
    }):addTo(sprite):align(display.CENTER, size.width/2, 0)
    sprite.flagstr = alliance.flag
	sprite.flag = ui_helper:CreateFlagContentSprite(alliance.flag)
				:addTo(sprite):align(display.CENTER, 80, 60):scale(0.3)
    self.allainceSprites[index] = sprite
end
function WorldLayer:UpdateAllianceSprite(index, alliance)
    local sprite = self.allainceSprites[index]
    sprite:setTexture(string.format("world_alliance_%s.png", alliance.terrain))
    sprite.name:setString(string.format("[%s]%s", alliance.tag, alliance.name))
    if sprite.flagstr ~= alliance.flag then
    	sprite.flag:SetFlag(alliance.flag)
	end
end
function WorldLayer:IndexToLogic(index)
    return index % WIDTH, math.floor(index / WIDTH)
end
function WorldLayer:LogicToIndex(x, y)
    return x + y * WIDTH
end
function WorldLayer:GetLogicMap()
    return self.normal_map
end
function WorldLayer:ConvertLogicPositionToMapPosition(lx, ly)
    return self:convertToNodeSpace(self.map:convertToWorldSpace(cc.p(self.normal_map:ConvertToMapPosition(lx, ly))))
end
function WorldLayer:GetAvailableIndex()
    local t = {}
    local x,y = self:GetLeftTopLogicPosition()
    for i = x, x + 4 do
        for j = y, y + 4 do
            if i >= 0 and i < WIDTH and j >= 0 and j < HEIGHT then
                table.insert(t, self:LogicToIndex(i,j))
            end
        end
    end
    return t
end
function WorldLayer:GetLeftTopLogicPosition()
    local point = self.map:convertToNodeSpace(cc.p(0, display.height))
    return self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
end
function WorldLayer:GetClickedObject(world_x, world_y)
    local point = self.map:convertToNodeSpace(cc.p(world_x, world_y))
    local logic_x, logic_y = self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
    print(point.x, point.y, logic_x, logic_y)
end
function WorldLayer:getContentSize()
    return worldsize
end


return WorldLayer






