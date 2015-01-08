local SpriteConfig = import("..sprites.SpriteConfig")
local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local Enum = import("..utils.Enum")
local MapLayer = import(".MapLayer")
local PVELayer = class("PVELayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "BUILDING", "OBJECT", "FOG")

local OBJECT_TYPE =
    Enum("START_AIRSHIP",
        "WOODCUTTER",
        "QUARRIER",
        "MINER",
        "FARMER",
        "CAMP",
        "CRASHED_AIRSHIP",
        "CONSTRUCTION_RUINS",
        "KEEL",
        "WARRIORS_TOMB",
        "OBELISK",
        "ANCIENT_RUINS",
        "ENTRANCE_DOOR",
        "TREE",
        "HILL",
        "LAKE")

local OBJECT_IMAGE = {}
print(SpriteConfig["woodcutter"]:GetConfigByLevel(1).png)
OBJECT_IMAGE[OBJECT_TYPE.START_AIRSHIP] = "airship_106x81.png"
OBJECT_IMAGE[OBJECT_TYPE.WOODCUTTER] = SpriteConfig["woodcutter"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.QUARRIER] = SpriteConfig["quarrier"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.MINER] = SpriteConfig["miner"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.FARMER] = SpriteConfig["farmer"]:GetConfigByLevel(1).png
OBJECT_IMAGE[OBJECT_TYPE.CAMP] = "camp_137x80.png"
OBJECT_IMAGE[OBJECT_TYPE.CRASHED_AIRSHIP] = "crashed_airship_94x80.png"
OBJECT_IMAGE[OBJECT_TYPE.CONSTRUCTION_RUINS] = "ruin_1_136x92.png"
OBJECT_IMAGE[OBJECT_TYPE.KEEL] = "keel_95x80.png"
OBJECT_IMAGE[OBJECT_TYPE.WARRIORS_TOMB] = "warriors_tomb.png"
OBJECT_IMAGE[OBJECT_TYPE.OBELISK] = "obelisk.png"
OBJECT_IMAGE[OBJECT_TYPE.ANCIENT_RUINS] = "ancient_ruins.png"
OBJECT_IMAGE[OBJECT_TYPE.ENTRANCE_DOOR] = "entrance_door.png"
OBJECT_IMAGE[OBJECT_TYPE.TREE] = "tree_2_120x120.png"
OBJECT_IMAGE[OBJECT_TYPE.HILL] = "hill_228x146.png"
OBJECT_IMAGE[OBJECT_TYPE.LAKE] = "lake_220x174.png"

    

function PVELayer:ctor()
    PVELayer.super.ctor(self, 0.5, 1)
    self.scene_node = display.newNode():addTo(self)
    self.background = cc.TMXTiledMap:create("tmxmaps/pve_background.tmx"):addTo(self.scene_node, ZORDER.BACKGROUND)
    self.building_layer = display.newNode():addTo(self.scene_node, ZORDER.BUILDING)
    self.object_layer = display.newNode():addTo(self.scene_node, ZORDER.OBJECT)
    self.war_fog = cc.TMXTiledMap:create("tmxmaps/pve.tmx"):addTo(self.scene_node, ZORDER.FOG):pos(-80, -80)
    self.war_fog_layer = self.war_fog:getLayer("layer1")

    self.pve_layer = cc.TMXTiledMap:create("tmxmaps/pve_1.tmx"):addTo(self):hide():getLayer("layer1")
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
end
function PVELayer:onEnter()
    self:WalkOn(10, 10)
    local size = self.pve_layer:getLayerSize()
    for x = 0, size.width - 1 do
        for y = 0, size.height - 1 do
            local gid = (self.pve_layer:getTileGIDAt(cc.p(x, y)))
            if gid > 0 then
                display.newSprite(OBJECT_IMAGE[gid]):addTo(self.building_layer):pos(self:GetLogicMap():ConvertToMapPosition(x, y))
            end
        end
    end
    self.object = display.newSprite("pve_char_bg_104x106.png"):addTo(self.object_layer):pos(self:GetLogicMap():ConvertToMapPosition(10, 10))
end
function PVELayer:GetSceneNode()
    return self.scene_node
end
function PVELayer:GetLogicMap()
    return self.normal_map
end
function PVELayer:WalkOn(x, y)
    local width, height = self:GetLogicMap():GetSize()
    for _, v in pairs{
        {x, y},
        {x + 1, y + 1},
        {x, y + 1},
        {x + 1, y},
        {x - 1, y - 1},
        {x - 1, y},
        {x, y - 1},
        {x + 1, y - 1},
        {x - 1, y + 1},
    } do
        local x_, y_ = unpack(v)
        if x_ >= 0 and x_ < width and y_ >= 0 and y_ < height then
            self.war_fog_layer:getTileAt(cc.p(x_, y_)):hide()
        end
    end
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
    return cocos_promise.deffer()
end
function PVELayer:GotoLogicPoint(x, y, s)
    local point = self:ConvertLogicPositionToMapPosition(x, y)
    return self:PromiseOfMove(point.x, point.y, s)
end

return PVELayer






