local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local Enum = import("..utils.Enum")
local PVEDefine = import(".PVEDefine")
local MapLayer = import(".MapLayer")
local PVELayer = class("PVELayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "BUILDING", "OBJECT", "FOG")

local OBJECT_TYPE = PVEDefine.object_type
local OBJECT_IMAGE = PVEDefine.object_image
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
    self:LightOn(12, 12, 4)
    local size = self.pve_layer:getLayerSize()
    for x = 0, size.width - 1 do
        for y = 0, size.height - 1 do
            local gid = (self.pve_layer:getTileGIDAt(cc.p(x, y)))
            if gid > 0 then
                display.newSprite(OBJECT_IMAGE[gid]):addTo(self.building_layer):pos(self:GetLogicMap():ConvertToMapPosition(x, y))
            end
        end
    end
    self.object = display.newSprite("pve_char_bg_104x106.png")
    :addTo(self.object_layer):pos(self:GetLogicMap():ConvertToMapPosition(12, 12))
    
    display.newSprite("Hero_1.png"):addTo(self.object):pos(104*0.5, 106*0.5):scale(0.8)
end
function PVELayer:GetSceneNode()
    return self.scene_node
end
function PVELayer:GetLogicMap()
    return self.normal_map
end
function PVELayer:GetTileInfo(x, y)
    local gid = (self.pve_layer:getTileGIDAt(cc.p(x, y)))
    return gid > 0 and gid or nil
end
function PVELayer:LightOn(x, y, size)
    local width, height = self:GetLogicMap():GetSize()
    size = size or 1
    local sx, sy, ex, ey = x - size, y - size, x + size, y + size
    for x_ = sx, ex do
        for y_ = sy, ey do
            if x_ >= 1 and x_ < width - 1 and y_ >= 1 and y_ < height - 1 then
                self.war_fog_layer:getTileAt(cc.p(x_, y_)):hide()
            end
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
    return cocos_promise.deffer()
end
function PVELayer:GotoLogicPoint(x, y, s)
    local point = self:ConvertLogicPositionToMapPosition(x, y)
    return self:PromiseOfMove(point.x, point.y, s)
end

return PVELayer







