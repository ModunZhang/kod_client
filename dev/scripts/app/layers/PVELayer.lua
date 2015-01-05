local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local Enum = import("..utils.Enum")
local MapLayer = import(".MapLayer")
local PVELayer = class("PVELayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "OBJECT", "FOG")
function PVELayer:ctor()
    PVELayer.super.ctor(self, 0.3, 1)
    self.scene_node = display.newNode():addTo(self):pos(500, 500)
    self.background = cc.TMXTiledMap:create("tmxmaps/pve_background.tmx"):addTo(self.scene_node, ZORDER.BACKGROUND)
    self.object_layer = display.newNode():addTo(self.scene_node, ZORDER.OBJECT)
    self.war_fog = cc.TMXTiledMap:create("tmxmaps/pve.tmx"):addTo(self.scene_node, ZORDER.FOG):pos(-80, -80)
    self.war_fog_layer = self.war_fog:getLayer("layer1")
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new({
        tile_w = 80,
        tile_h = 80,
        map_width = 41,
        map_height = 41,
        base_x = 0,
        base_y = 41 * 80,
    })
end
function PVELayer:onEnter()
    self:WalkOn(10, 10)
    self.object = display.newSprite("add_btn_down_50x50.png"):addTo(self.object_layer):pos(self:GetLogicMap():ConvertToMapPosition(10, 10))
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
        self.content_size.width = self.content_size.width * 1.3
        self.content_size.height = self.content_size.height * 1.3
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




