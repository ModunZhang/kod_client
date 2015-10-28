local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local WorldLayer = class("WorldLayer", MapLayer)


local ui_helper = WidgetAllianceHelper.new()
local TILE_LENGTH = 207
local CORNER_LENGTH = 47
local WIDTH, HEIGHT = 41, 41
local MAX_INDEX = WIDTH * HEIGHT - 1
local SHADER_WIDTH, SHADER_HEIGHT = 42, 42
local width, height = WIDTH * TILE_LENGTH, HEIGHT * TILE_LENGTH
local worldsize = {
width = width + 2 * CORNER_LENGTH + 200, 
height = height + 2 * CORNER_LENGTH + 500,
}
assert(SHADER_WIDTH % 2 == 0)
assert(SHADER_HEIGHT % 2 == 0)


function WorldLayer:ctor(scene)
    WorldLayer.super.ctor(self, scene, 0.4, 1.2)
end
function WorldLayer:onEnter()
    self:CreateBg()
    self.scene_node = display.newNode():addTo(self):pos(15,15)
    self:CreateCorner()
    self:CreateEdge()
    self.map = self:CreateMap()
    self:CreateAllianceLayer()
    self.allainceSprites = {}
    self.flagSprites = {}
end
function WorldLayer:CreateBg()
    local offsetY = - 280
    local sprite = display.newFilteredSprite("world_bg.jpg", "CUSTOM", json.encode({
        frag = "shaders/plane.fs",
        shaderName = "plane1",
        param = {1/14, 1/8, 14, 8}
    })):addTo(self):align(display.LEFT_BOTTOM, 0, offsetY)
    local size = sprite:getContentSize()
    sprite:setScaleX(14)
    sprite:setScaleY(8)
    worldsize.width = size.width * 14 - 265
    worldsize.height = size.height * 8 + offsetY

    display.newFilteredSprite("world_title2.jpg", "CUSTOM", json.encode({
        frag = "shaders/plane.fs",
        shaderName = "plane2",
        param = {1/14, 1, 14, 1}
    })):addTo(self):align(display.LEFT_TOP,0,size.height * 8 + offsetY):setScaleX(14)

    display.newSprite("world_title1.jpg")
    :addTo(self):align(display.LEFT_TOP,0,size.height * 8 + offsetY)
end
function WorldLayer:CreateCorner()
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH/2, CORNER_LENGTH/2)
        :addTo(self.scene_node):scale(1):rotation(-90)
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH/2, CORNER_LENGTH*3/2 + TILE_LENGTH * HEIGHT)
        :addTo(self.scene_node):scale(1):rotation(0)
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH*3/2 + TILE_LENGTH * WIDTH, CORNER_LENGTH/2)
        :addTo(self.scene_node):scale(1):rotation(180)
    display.newSprite("world_tile.png"):pos(CORNER_LENGTH*3/2 + TILE_LENGTH * WIDTH, CORNER_LENGTH*3/2 + TILE_LENGTH * HEIGHT)
        :addTo(self.scene_node):scale(1):rotation(90)
end
function WorldLayer:CreateEdge()
    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex1",
        unit_count = HEIGHT,
        unit_len = 1 / HEIGHT,
    })):pos(CORNER_LENGTH/2+1, CORNER_LENGTH + HEIGHT * TILE_LENGTH * 0.5)
        :addTo(self.scene_node):setScaleY(HEIGHT)

    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex2",
        unit_count = HEIGHT,
        unit_len = 1 / HEIGHT,
    })):pos(CORNER_LENGTH*3/2 + TILE_LENGTH * WIDTH - 1, CORNER_LENGTH + HEIGHT * TILE_LENGTH * 0.5)
        :addTo(self.scene_node):setScaleY(HEIGHT):flipX(true)

    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex3",
        unit_count = WIDTH,
        unit_len = 1 / WIDTH,
    })):pos(CORNER_LENGTH + WIDTH * TILE_LENGTH * 0.5, CORNER_LENGTH*3/2 + TILE_LENGTH * HEIGHT - 1)
        :addTo(self.scene_node):setScaleY(WIDTH):rotation(90)

    display.newFilteredSprite("world_edge.png", "CUSTOM", json.encode({
        frag = "shaders/nolimittex.fs",
        shaderName = "nolimittex4",
        unit_count = WIDTH,
        unit_len = 1 / WIDTH,
    })):pos(CORNER_LENGTH + WIDTH * TILE_LENGTH * 0.5, CORNER_LENGTH/2 + 1)
        :addTo(self.scene_node):setScaleY(WIDTH):rotation(-90)
end
function WorldLayer:CreateMap()
    local clip = display.newClippingRegionNode(cc.rect(0,0, TILE_LENGTH * WIDTH, TILE_LENGTH * HEIGHT))
        :addTo(self.scene_node):align(display.LEFT_BOTTOM,CORNER_LENGTH,CORNER_LENGTH)

    local map = display.newFilteredSprite("world_terrain.jpg", "CUSTOM", json.encode({
        frag = "shaders/maptex.fs",
        shaderName = "maptex",
        size = {
            SHADER_WIDTH/2, -- 
            SHADER_HEIGHT,
            0.5/(SHADER_WIDTH/4),
            1/SHADER_HEIGHT,
        }
    })):align(display.LEFT_BOTTOM, 0, 0):addTo(clip)
    local cache = cc.Director:getInstance():getTextureCache()
    cache:addImage("world_map.png"):setAliasTexParameters()
    map:getGLProgramState():setUniformTexture("terrain", cache:getTextureForKey("world_map.png"):getName())
    map:setScaleX(SHADER_WIDTH/4)
    map:setScaleY(SHADER_HEIGHT/2)

    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_LENGTH,
        tile_h = TILE_LENGTH,
        map_width = WIDTH,
        map_height = HEIGHT,
        base_x = 0,
        base_y = HEIGHT * TILE_LENGTH,
    }
    return clip
end
function WorldLayer:CreateAllianceLayer()
    self.allianceLayer = display.newNode():addTo(self.map)
end
function WorldLayer:LoadAlliance()
    NetManager:getMapAllianceDatasPromise(self:GetAvailableIndex()):done(function(response)
        dump(response.msg.datas)
        for k,v in pairs(response.msg.datas) do
            if v == json.null then
                if self.allainceSprites[k] then
                    self.allainceSprites[k]:removeFromParent()
                    self.allainceSprites[k] = nil
                end
                
                if not self.flagSprites[k] then
                    self:CreateFlag(k)
                end
            else
                if not self.allainceSprites[k] then
                    self:CreateAllianceSprite(k, v)
                else
                    self:UpdateAllianceSprite(k, v)
                end

                if self.flagSprites[k] then
                    self.flagSprites[k]:removeFromParent()
                    self.flagSprites[k] = nil
                end
            end
        end
    end)
end
function WorldLayer:CreateAllianceSprite(index, alliance)
    local node = display.newNode()
    :addTo(self.allianceLayer)
    :pos(self:GetLogicMap():ConvertToMapPosition(self:IndexToLogic(index)))
    local sprite = display.newSprite(string.format("world_alliance_%s.png", alliance.terrain))
    :addTo(node, 0, 1):pos(50 - math.random(50), 50 - math.random(50))
    local size = sprite:getContentSize()
    local banner = display.newSprite("alliance_banner.png"):addTo(sprite):pos(size.width/2, 0)
    sprite.name = UIKit:ttfLabel({
        size = 12,
        color = 0xffedae,
        text = string.format("[%s]%s", alliance.tag, alliance.name),
        ellipsis = true,
        dimensions = cc.size(100,15),
    }):addTo(sprite):align(display.CENTER, size.width/2, 0)
    sprite.alliance = alliance
    sprite.flagstr = alliance.flag
    sprite.flag = ui_helper:CreateFlagContentSprite(alliance.flag)
        :addTo(sprite):align(display.CENTER, 80, 60):scale(0.3)

    self.allainceSprites[index] = node
end
function WorldLayer:UpdateAllianceSprite(index, alliance)
    local sprite = self.allainceSprites[index]:getChildByTag(1)
    sprite:setTexture(string.format("world_alliance_%s.png", alliance.terrain))
    sprite.name:setString(string.format("[%s]%s", alliance.tag, alliance.name))
    if sprite.flagstr ~= alliance.flag then
        sprite.flag:SetFlag(alliance.flag)
    end
end
function WorldLayer:CreateFlag(index)
    local node = display.newNode():addTo(self.allianceLayer)
    :pos(self:GetLogicMap():ConvertToMapPosition(self:IndexToLogic(index)))
    local sprite = ccs.Armature:create("daqizi"):addTo(node)
    :scale(0.4):pos(100 - math.random(100), 100 - math.random(100))
    local ani = sprite:getAnimation()
    ani:playWithIndex(0)
    ani:gotoAndPlay(math.random(71) - 1)
    self.flagSprites[index] = node
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
    return self.map:getParent():convertToNodeSpace(self.map:convertToWorldSpace(cc.p(self.normal_map:ConvertToMapPosition(lx, ly))))
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
    if logic_x < 0 or logic_x >= WIDTH or logic_y < 0 or logic_y >= HEIGHT then
        return nil, false
    end
    local index = self:LogicToIndex(logic_x, logic_y)
    return self.allainceSprites[tostring(index)] , index
end
function WorldLayer:getContentSize()
    return worldsize
end


return WorldLayer







