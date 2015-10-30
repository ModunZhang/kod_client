local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local WorldLayer = class("WorldLayer", MapLayer)

local bigMapLength_value = GameDatas.AllianceInitData.intInit.bigMapLength.value
local ui_helper = WidgetAllianceHelper.new()
local TILE_LENGTH = 207
local CORNER_LENGTH = 47
local WIDTH, HEIGHT = bigMapLength_value, bigMapLength_value
local MAX_INDEX = WIDTH * HEIGHT - 1
local width, height = WIDTH * TILE_LENGTH, HEIGHT * TILE_LENGTH
local worldsize = {
    width = width + 2 * CORNER_LENGTH + 200, 
    height = height + 2 * CORNER_LENGTH + 500,
}


function WorldLayer:ctor(scene)
    WorldLayer.super.ctor(self, scene, 0.4, 1.2)
end
function WorldLayer:onEnter()
    self:CreateBg()
    self.scene_node = display.newNode():addTo(self)
                      :align(display.LEFT_BOTTOM, 15,15)
    self:CreateCorner()
    self:CreateEdge()
    self.map = self:CreateMap()
    self.allianceLayer = display.newNode():addTo(self.map,0)
    self.moveLayer = display.newNode():addTo(self.map,1)
    local size = self.scene_node:getCascadeBoundingBox()
    self.scene_node:setContentSize(cc.size(size.width, size.height))
    self.allainceSprites = {}
    self.flagSprites = {}
    math.randomseed(1)
end
function WorldLayer:onExit()
    local cache = cc.Director:getInstance():getTextureCache()
    cache:removeTextureForKey("world_bg.jpg")
    cache:removeTextureForKey("world_title2.jpg")
    cache:removeTextureForKey("world_title1.jpg")
    cache:removeTextureForKey("world_terrain.jpg")
end
function WorldLayer:CreateBg()
    local sx, sy = 12, 7
    local offsetY = - 350
    local sprite = display.newFilteredSprite("world_bg.jpg", "CUSTOM", json.encode({
        frag = "shaders/plane.fs",
        shaderName = "plane1",
        param = {1/sx, 1/sy, sx, sy}
    })):addTo(self):align(display.LEFT_BOTTOM, 0, offsetY)
    local size = sprite:getContentSize()
    sprite:setScaleX(sx)
    sprite:setScaleY(sy)
    worldsize.width = size.width * sx - 235
    worldsize.height = size.height * sy + offsetY

    display.newFilteredSprite("world_title2.jpg", "CUSTOM", json.encode({
        frag = "shaders/plane.fs",
        shaderName = "plane2",
        param = {1/sx, 1, sx, 1}
    })):addTo(self):align(display.LEFT_TOP,0,size.height * sy + offsetY):setScaleX(sx)

    display.newSprite("world_title1.jpg")
    :addTo(self):align(display.LEFT_TOP,0,size.height * sy + offsetY)
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
    local clip = display.newNode():addTo(self.scene_node)
                 :align(display.LEFT_BOTTOM,CORNER_LENGTH,CORNER_LENGTH)

    local map = display.newFilteredSprite("world_terrain.jpg", "CUSTOM", json.encode({
        frag = "shaders/maptex.fs",
        shaderName = "maptex",
        size = {
            WIDTH/2, -- 
            HEIGHT,
            0.5/(WIDTH/4),
            1/HEIGHT,
        }
    })):align(display.LEFT_BOTTOM, 0, 0):addTo(clip)
    local cache = cc.Director:getInstance():getTextureCache()
    cache:addImage("world_map.png"):setAliasTexParameters()
    map:getGLProgramState():setUniformTexture("terrain", cache:getTextureForKey("world_map.png"):getName())
    map:setScaleX(WIDTH/4)
    map:setScaleY(HEIGHT/2)

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
local screen_rect = cc.rect(0, 0, display.width, display.height)
function WorldLayer:MoveAllianceFromTo(fromIndex, toIndex)
    self:RemoveAllianceBy(fromIndex)
    self:RemoveAllianceBy(toIndex)
    local sour = self:ConvertLogicPositionToMapPosition(self:IndexToLogic(fromIndex))
    local dest = self:ConvertLogicPositionToMapPosition(self:IndexToLogic(toIndex))

    local degree = math.deg(cc.pGetAngle(cc.pSub(dest, sour), cc.p(0, 1)))
    local normal = cc.pNormalize(cc.pSub(dest, sour))
    local distance = cc.pGetLength(cc.pSub(dest, sour))
    local roads = {}
    for i = 0, math.huge do
        local length = 50 * i
        local x = dest.x - normal.x * length
        local y = dest.y - normal.y * length
        if length >= distance or
            not cc.rectContainsPoint(screen_rect, self.map:convertToWorldSpace(cc.p(x, y))) 
        then
            break
        end
        sour.x, sour.y = x, y
        local sprite = display.newSprite("pve_road_point.png")
        :addTo(self.moveLayer):pos(x, y):rotation(degree):hide()
        table.insert(roads, 1, sprite)
    end

    local actions = {}
    local step_time = 1.0
    for i,v in ipairs(roads) do
        table.insert(actions, cc.CallFunc:create(function()
            v:show()
        end))
        table.insert(actions, cc.DelayTime:create(step_time))
    end
    local gap, scal, ft, offset = -65, 0.8, 0.5, -40
    UIKit:CreateMoveSoldiers(degree, {name = "ranger", star = 3}, scal)
    :addTo(self.moveLayer)
    :pos(sour.x + normal.x * (2 * gap + offset), sour.y + normal.y * (2 * gap + offset))
    :runAction(transition.sequence{
        cc.MoveTo:create(#roads * step_time, {
            x = dest.x + normal.x * (2 * gap + offset), y = dest.y + normal.y * (2 * gap + offset)
        }),
        cc.FadeOut:create(ft),
        cc.RemoveSelf:create(),
    })

    UIKit:CreateMoveSoldiers(degree, {name = "swordsman", star = 3}, scal)
    :addTo(self.moveLayer)
    :pos(sour.x + normal.x * (gap + offset), sour.y + normal.y * (gap + offset))
    :runAction(transition.sequence{
        cc.MoveTo:create(#roads * step_time, {
            x = dest.x + normal.x * (gap + offset), y = dest.y + normal.y * (gap + offset)
        }),
        cc.FadeOut:create(ft),
        cc.RemoveSelf:create(),
    })

    UIKit:CreateMoveSoldiers(degree, {name = "lancer", star = 3}, scal)
    :addTo(self.moveLayer)
    :pos(sour.x + normal.x * (offset + 10), sour.y + normal.y * (offset + 10))
    :runAction(transition.sequence{
        cc.MoveTo:create(#roads * step_time, {
            x = dest.x + normal.x * (offset + 10), y = dest.y + normal.y * (offset + 10)
        }),
        cc.FadeOut:create(ft),
        cc.RemoveSelf:create(),
    })

    table.insert(actions, cc.CallFunc:create(function()
        for i,v in ipairs(roads) do
            v:runAction(transition.sequence{
                cc.FadeOut:create(ft),
                cc.RemoveSelf:create(),
            })
        end
        self:LoadAllianceBy(toIndex, Alliance_Manager:GetMyAlliance().basicInfo)
    end))
    table.insert(actions, cc.DelayTime:create(0.5))
    table.insert(actions, cc.CallFunc:create(function()
        UIKit:newGameUI("GameUIMoveSuccess",0,0):AddToCurrentScene(true)
        app:lockInput(false)
    end))
    table.insert(actions, cc.RemoveSelf:create())
    app:lockInput(true)
    display.newNode():addTo(self):runAction(transition.sequence(actions))
end

function WorldLayer:LoadAlliance()
    local flagSprites = {}
    local mapIndexStr = tostring(Alliance_Manager:GetMyAlliance().mapIndex)
    local allainceSprites = {
        [mapIndexStr] = self.allainceSprites[mapIndexStr]
    }
    LuaUtils:outputTable(allainceSprites)
    self.allainceSprites[mapIndexStr] = nil
    
    local indexes = self:GetAvailableIndex()
    for k,v in pairs(self.currentIndexs or {}) do
        if indexes[k] then
            if self.flagSprites[k] then
                flagSprites[k] = self.flagSprites[k]
            end
            self.flagSprites[k] = nil
            if self.allainceSprites[k] then
                allainceSprites[k] = self.allainceSprites[k]
            end
            self.allainceSprites[k] = nil
        end
    end
    for k,v in pairs(self.flagSprites) do
        v:removeFromParent()
    end
    for k,v in pairs(self.allainceSprites) do
        v:removeFromParent()
    end
    self.flagSprites = flagSprites
    self.allainceSprites = allainceSprites


    self.currentIndexs = indexes
    local request_body = {}
    for k,v in pairs(indexes) do
        table.insert(request_body, tonumber(k))
    end
    NetManager:getMapAllianceDatasPromise(request_body):done(function(response)
        dump(response.msg.datas)
        for k,v in pairs(response.msg.datas) do
            self:LoadAllianceBy(k,v)
        end
        if UIKit:GetUIInstance("GameUIWorldMap") then
            UIKit:GetUIInstance("GameUIWorldMap"):HideLoading()
        end
    end)
end
function WorldLayer:LoadAllianceBy(mapIndex, alliance)
    if alliance == json.null then
        self:RemoveAllianceBy(mapIndex)
    else
        self:CreateOrUpdateAllianceBy(mapIndex, alliance)
    end
end
function WorldLayer:RemoveAllianceBy(mapIndex)
    local mapIndex = tostring(mapIndex)
    if self.allainceSprites[mapIndex] then
        self.allainceSprites[mapIndex]:removeFromParent()
        self.allainceSprites[mapIndex] = nil
    end
    if not self.flagSprites[mapIndex] then
        self:CreateFlag(mapIndex)
    end
end
function WorldLayer:CreateOrUpdateAllianceBy(mapIndex, alliance)
    local mapIndex = tostring(mapIndex)
    if not self.allainceSprites[mapIndex] then
        self:CreateAllianceSprite(mapIndex, alliance)
    else
        self:UpdateAllianceSprite(mapIndex, alliance)
    end

    if self.flagSprites[mapIndex] then
        self.flagSprites[mapIndex]:removeFromParent()
        self.flagSprites[mapIndex] = nil
    end
    return self.allainceSprites[mapIndex]
end
function WorldLayer:CreateAllianceSprite(index, alliance)
    local index = tostring(index)
    local p = self:ConvertLogicPositionToMapPosition(self:IndexToLogic(index))
    local node = display.newNode():addTo(self.allianceLayer):pos(p.x, p.y)
    node.alliance = alliance
    
    local sprite = display.newSprite(string.format("world_alliance_%s.png", alliance.terrain))
    :addTo(node, 0, 1)
    if index ~= Alliance_Manager:GetMyAlliance().mapIndex then
        sprite:pos(30 - math.random(30), 30 - math.random(30))
    end
    local size = sprite:getContentSize()
    local banner = display.newSprite("alliance_banner.png")
                   :addTo(sprite):pos(size.width/2, 0)
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
    if Alliance_Manager:GetMyAlliance().mapIndex == tonumber(index) then
        display.newSprite("icon_current_position_46x68.png")
            :addTo(node, 0, 2):pos(sprite:getPositionX(), sprite:getPositionY() + sprite:getContentSize().height / 2 + 15)
    end
    self.allainceSprites[index] = node
end
function WorldLayer:UpdateAllianceSprite(index, alliance)
    local index = tostring(index)
    local sprite = self.allainceSprites[index]:getChildByTag(1)
    sprite:setTexture(string.format("world_alliance_%s.png", alliance.terrain))
    sprite.name:setString(string.format("[%s]%s", alliance.tag, alliance.name))
    if sprite.flagstr ~= alliance.flag then
        sprite.flag:SetFlag(alliance.flag)
    end
end
function WorldLayer:CreateFlag(index)
    local index = tostring(index)
    local p = self:ConvertLogicPositionToMapPosition(self:IndexToLogic(index))
    local node = display.newNode():addTo(self.allianceLayer):pos(p.x, p.y)
    local sprite = ccs.Armature:create("daqizi"):addTo(node)
    :scale(0.4):pos(60 - math.random(60), 30 - math.random(30))
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
function WorldLayer:ConverToScenePosition(lx, ly)
    return self.map:getParent():convertToNodeSpace(self.map:convertToWorldSpace(cc.p(self.normal_map:ConvertToMapPosition(lx, ly))))
end
function WorldLayer:ConvertScreenPositionToLogicPosition(sx, sy)
    local p = self.map:convertToNodeSpace(cc.p(sx, sy))
    return self.normal_map:ConvertToLogicPosition(p.x, p.y)
end
function WorldLayer:ConverToWorldSpace(lx, ly)
    return self.map:convertToWorldSpace(cc.p(self.normal_map:ConvertToMapPosition(lx, ly)))
end
function WorldLayer:ConvertLogicPositionToMapPosition(lx, ly)
    return self.map:convertToNodeSpace(self.map:convertToWorldSpace(cc.p(self.normal_map:ConvertToMapPosition(lx, ly))))
end
function WorldLayer:GetAvailableIndex()
    local t = {}
    local x,y = self:GetLeftTopLogicPosition()
    for i = x, x + 5 do
        for j = y, y + 5 do
            if i >= 0 and i < WIDTH and j >= 0 and j < HEIGHT then
                t[tostring(self:LogicToIndex(i,j))] = true
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







