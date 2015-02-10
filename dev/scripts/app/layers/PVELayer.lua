local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local Enum = import("..utils.Enum")
local Observer = import("..entity.Observer")
local PVEObject = import("..entity.PVEObject")
local PVEDefine = import("..entity.PVEDefine")
local SpriteConfig = import("..sprites.SpriteConfig")
local MapLayer = import(".MapLayer")
local PVELayer = class("PVELayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "BUILDING", "OBJECT", "FOG")

local OBJECT_IMAGE = {}
OBJECT_IMAGE[PVEDefine.START_AIRSHIP] = "airship_106x81.png"
OBJECT_IMAGE[PVEDefine.WOODCUTTER] = SpriteConfig["woodcutter"]:GetConfigByLevel(1).png
OBJECT_IMAGE[PVEDefine.QUARRIER] = SpriteConfig["quarrier"]:GetConfigByLevel(1).png
OBJECT_IMAGE[PVEDefine.MINER] = SpriteConfig["miner"]:GetConfigByLevel(1).png
OBJECT_IMAGE[PVEDefine.FARMER] = SpriteConfig["farmer"]:GetConfigByLevel(1).png
OBJECT_IMAGE[PVEDefine.CAMP] = "camp_137x80.png"
OBJECT_IMAGE[PVEDefine.CRASHED_AIRSHIP] = "crashed_airship_94x80.png"
OBJECT_IMAGE[PVEDefine.CONSTRUCTION_RUINS] = "ruin_1.png"
OBJECT_IMAGE[PVEDefine.KEEL] = "keel_95x80.png"
OBJECT_IMAGE[PVEDefine.WARRIORS_TOMB] = "warriors_tomb.png"
OBJECT_IMAGE[PVEDefine.OBELISK] = "obelisk.png"
OBJECT_IMAGE[PVEDefine.ANCIENT_RUINS] = "ancient_ruins.png"
OBJECT_IMAGE[PVEDefine.ENTRANCE_DOOR] = "entrance_door.png"
OBJECT_IMAGE[PVEDefine.TREE] = "tree_2_138x110.png"
OBJECT_IMAGE[PVEDefine.HILL] = "hill_228x146.png"
OBJECT_IMAGE[PVEDefine.LAKE] = "lake_220x174.png"

function PVELayer:ctor(user)
    PVELayer.super.ctor(self, 0.5, 1)
    self.pve_listener = Observer.new()
    self.user = user
    self.pve_map = user:GetCurrentPVEMap()
    self.scene_node = display.newNode():addTo(self)
    self.background = cc.TMXTiledMap:create(string.format("tmxmaps/pve_%d_background.tmx", self.pve_map:GetIndex())):addTo(self.scene_node, ZORDER.BACKGROUND)
    self.war_fog_layer = cc.TMXTiledMap:create(string.format("tmxmaps/pve_%d_fog.tmx", self.pve_map:GetIndex())):addTo(self.scene_node, ZORDER.FOG):pos(-80, -80):getLayer("layer1")
    self.pve_layer = cc.TMXTiledMap:create(string.format("tmxmaps/pve_%d_info.tmx", self.pve_map:GetIndex())):addTo(self):hide():getLayer("layer1")
    self.building_layer = display.newNode():addTo(self.scene_node, ZORDER.BUILDING)
    self.object_layer = display.newNode():addTo(self.scene_node, ZORDER.OBJECT)
    local size = self.pve_layer:getLayerSize()
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new({
        tile_w = 80,
        tile_h = 80,
        map_width = size.width,
        map_height = size.height,
        base_x = 0,
        base_y = size.height * 80,
    })
    local size_in = self.background:getContentSize()
    local size_out = self:getContentSize()
    local x, y = size_out.width * 0.5 - size_in.width * 0.5, size_out.height * 0.5 - size_in.height * 0.5
    self.scene_node:pos(x, y)


    local layer = self.background:getLayer("layer1")
    local color = cc.c3b(tonumber(layer:getProperty("r")) or 0, tonumber(layer:getProperty("g")) or 0, tonumber(layer:getProperty("b")) or 0)
    for x = 0, size.width - 1 do
        for y = 0, size.height - 1 do
            local tile = layer:getTileAt(cc.p(x, y))
            tile:setColor(color + cc.c3b(tile:getColor()))
        end
    end
end
function PVELayer:onEnter()
    PVELayer.super.onEnter(self)
    local w, h = self.normal_map:GetSize()
    -- 点亮中心
    self:LightOn((w - 1) * 0.5, (h - 1) * 0.5, 4)
    self:LoadFog()
    -- 加载地图数据
    local objects = {}
    self:IteratorObjectsGID(function(x, y, gid)
        local obj = display.newSprite(OBJECT_IMAGE[gid]):addTo(self.building_layer)
            :pos(self:GetLogicMap():ConvertToMapPosition(x, y))
        objects[#objects + 1] = {sprite = obj, x = x, y = y}
    end)
    self.objects = objects

    -- 加载玩家
    self.char = display.newSprite("pve_char_bg_104x106.png"):addTo(self.object_layer)
    display.newSprite("Hero_1.png"):addTo(self.char):pos(104*0.5, 106*0.5):scale(0.8)

    -- 加载标记
    self.pve_map:IteratorObjects(handler(self, self.SetObjectStatus))
    self.pve_map:AddObserver(self)
end
function PVELayer:onExit()
    self.pve_map:RemoveObserver(self)
    PVELayer.super.onExit(self)
end
function PVELayer:AddPVEListener(l)
    self.pve_listener:AddObserver(l)
end
function PVELayer:RemovePVEListener(l)
    self.pve_listener:RemoveObserver(l)
end
function PVELayer:OnObjectChanged(object)
    self:SetObjectStatus(object)
    if object:Searched() > 0 then
        self:NotifyExploring()
    end
end
function PVELayer:SetObjectStatus(object)
    if not object:Type() then
        object:SetType(self:GetTileInfo(object:Position()))
    end
    if object:IsSearched() then
        local sprite = self:GetSpriteBy(object:Position())
        if sprite then
            local size1 = sprite:getContentSize()
            local flag = display.newSprite("alliacne_search_29x33.png")
            local size2 = flag:getContentSize()
            local x = size1.width - size2.width*0.5
            local y = size2.height * 0.5
            flag:pos(x, y):addTo(sprite)
        end
    end
end
function PVELayer:GetSpriteBy(x, y)
    for _, v in pairs(self.objects) do
        if v.x == x and v.y == y then
            return v.sprite
        end
    end
end
function PVELayer:PromiseOfTrap()
    local p = promise.new()
    local t = 0.025
    local r = 5
    self.char:runAction(transition.sequence({
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, -r),
        cc.RotateBy:create(t, r),
        cc.CallFunc:create(function() p:resolve() end),
    }))
    return p
end
function PVELayer:GetChar()
    return self.char
end
function PVELayer:CanMove(x, y)
    local width, height = self:GetLogicMap():GetSize()
    return x >= 2 and x < width - 2 and y >= 2 and y < height - 2
end
function PVELayer:MoveCharTo(x, y)
    self:LightOn(x, y)
    self.char:pos(self:GetLogicMap():ConvertToMapPosition(x, y))
    self:GotoLogicPoint(x, y, 10)
    self.user:GetPVEDatabase():SetCharPosition(x, y)
    self:NotifyExploring()
end
function PVELayer:NotifyExploring()
    self.pve_listener:NotifyObservers(function(v)
        v:OnExploreChanged(self)
    end)
end
function PVELayer:GetSceneNode()
    return self.scene_node
end
function PVELayer:GetLogicMap()
    return self.normal_map
end
function PVELayer:GetTileInfo(x, y)
    return (self.pve_layer:getTileGIDAt(cc.p(x, y)))
end
function PVELayer:LightOn(x, y, size)
    local width, height = self:GetLogicMap():GetSize()
    size = size or 1
    local sx, sy, ex, ey = x - size, y - size, x + size, y + size
    for x_ = sx, ex do
        for y_ = sy, ey do
            if x_ >= 1 and x_ < width - 1 and y_ >= 1 and y_ < height - 1 then
                self.war_fog_layer:getTileAt(cc.p(x_, y_)):hide()
                self.pve_map:InsertFog(x_, y_)
            end
        end
    end
end
function PVELayer:LoadFog()
    local war_fog_layer = self.war_fog_layer
    self.pve_map:IteratorFogs(function(x, y)
        war_fog_layer:getTileAt(cc.p(x, y)):hide()
    end)
end
function PVELayer:LockTileAt(x, y)
    self.war_fog_layer:getTileAt(cc.p(x, y)):show()
end
function PVELayer:UnLockTileAt(x, y)
    self.war_fog_layer:getTileAt(cc.p(x, y)):hide()
end
function PVELayer:UnLockTileAt(x, y)
    self.war_fog_layer:getTileAt(cc.p(x, y)):hide()
end
function PVELayer:ConvertLogicPositionToMapPosition(lx, ly)
    local map_pos = cc.p(self.normal_map:ConvertToMapPosition(lx, ly))
    return self:convertToNodeSpace(self.background:convertToWorldSpace(map_pos))
end
function PVELayer:ExploreDegree()
    return self.pve_map:ExploreDegree()
end
function PVELayer:IteratorObjectsGID(func)
    local pve_layer = self.pve_layer
    local size = pve_layer:getLayerSize()
    for x = 0, size.width - 1 do
        for y = 0, size.height - 1 do
            local gid = (pve_layer:getTileGIDAt(cc.p(x, y)))
            if gid > 0 then
                func(x, y, gid)
            end
        end
    end
end

---
function PVELayer:getContentSize()
    if not self.content_size then
        local layer = self.background:getLayer("layer1")
        self.content_size = layer:getContentSize()
        self.content_size.width = self.content_size.width * 2
        self.content_size.height = self.content_size.height * 3
    end
    return self.content_size
end
function PVELayer:OnSceneMove()

end
function PVELayer:OnSceneScale()

end
function PVELayer:GotoLogicPointInstant(x, y)
    local point = self:ConvertLogicPositionToMapPosition(x, y)
    self:GotoMapPositionInMiddle(point.x, point.y)
    return cocos_promise.defer()
end
function PVELayer:GotoLogicPoint(x, y, s)
    local point = self:ConvertLogicPositionToMapPosition(x, y)
    return self:PromiseOfMove(point.x, point.y, s)
end

return PVELayer















