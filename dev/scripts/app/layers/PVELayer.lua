local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local Enum = import("..utils.Enum")
local Observer = import("..entity.Observer")
local PVEObject = import("..entity.PVEObject")
local PVEDefine = import("..entity.PVEDefine")
local SpriteConfig = import("..sprites.SpriteConfig")
local UILib = import("..ui.UILib")
local MapLayer = import(".MapLayer")
local PVELayer = class("PVELayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "BUILDING", "OBJECT", "FOG")


local pve_color = {
    cc.c3b(125,0,125),
    cc.c3b(0,0,0),
    cc.c3b(0,0,125),
    cc.c3b(0,0,0),
    cc.c3b(125,125,125),
    cc.c3b(125,125,0),
    cc.c3b(125,125,0),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
    cc.c3b(125,125,125),
}


function PVELayer:ctor(user)
    PVELayer.super.ctor(self, 0.5, 1)
    self.pve_listener = Observer.new()
    self.user = user
    self.pve_map = user:GetCurrentPVEMap()

    self.pve_layer = cc.TMXTiledMap:create(string.format("tmxmaps/pve_%d_info.tmx", self.pve_map:GetIndex())):addTo(self):hide():getLayer("layer1")
    local size = self.pve_layer:getLayerSize()
    local w, h = size.width, size.height


    self.scene_node = display.newNode():addTo(self)
    self.background = cc.TMXTiledMap:create(string.format("tmxmaps/pve_background_%s_%dx%d.tmx", self.pve_map:Terrain(), w, h)):addTo(self.scene_node, ZORDER.BACKGROUND)
    self.war_fog_layer = cc.TMXTiledMap:create(string.format("tmxmaps/pve_fog_%dx%d.tmx", w, h)):addTo(self.scene_node, ZORDER.FOG):pos(-80, -80):getLayer("layer1")

    self.building_layer = display.newNode():addTo(self.scene_node, ZORDER.BUILDING)
    self.object_layer = display.newNode():addTo(self.scene_node, ZORDER.OBJECT)
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new({
        tile_w = 80,
        tile_h = 80,
        map_width = w,
        map_height = h,
        base_x = 0,
        base_y = h * 80,
    })
    local size_in = self.background:getContentSize()
    local size_out = self:getContentSize()
    local x, y = size_out.width * 0.5 - size_in.width * 0.5, size_out.height * 0.5 - size_in.height * 0.5
    self.scene_node:pos(x, y)

    -- local layer = self.background:getLayer("layer1")
    -- local color = pve_color[self.pve_map.index]
    -- for x = 0, w - 1 do
    --     for y = 0, h - 1 do
    --         local tile = layer:getTileAt(cc.p(x, y))
    --         tile:setColor(color + cc.c3b(tile:getColor()))
    --     end
    -- end
end
function PVELayer:onEnter()
    PVELayer.super.onEnter(self)
    local w, h = self.normal_map:GetSize()
    -- 点亮中心
    local start = self.pve_map:GetStartPoint()
    self:LightOn(start.x, start.y, 4)
    self:LoadFog()
    -- 加载地图数据
    local objects = {}
    self:IteratorObjectsGID(function(x, y, gid)
        local config = UILib.pve[gid]
        local type,image,s = unpack(config)
        local obj
        if config[1] == "image" then
            image = config[self.pve_map:Terrain()] or image
            obj = display.newSprite(image)
        else
            obj = ccs.Armature:create(config[2])
            obj:getAnimation():playWithIndex(0)
        end
        local zorder = 0
        if PVEDefine.TREE ~= gid and PVEDefine.HILL ~= gid and PVEDefine.LAKE ~= gid then
            zorder = 10
        end
        obj:addTo(self.building_layer, zorder):pos(self:GetLogicMap():ConvertToMapPosition(x, y)):scale(s or 1)
        objects[#objects + 1] = {sprite = obj, x = x, y = y}
    end)
    self.objects = objects

    -- 加载玩家
    self:LoadPlayer()

    -- 加载标记
    self.pve_map:IteratorObjects(handler(self, self.SetObjectStatus))
    self.pve_map:AddObserver(self)
end
function PVELayer:LoadPlayer()
    self.char = display.newNode():addTo(self.object_layer)
    self.char:setContentSize(cc.size(80, 80))
    local ariship = display.newSprite("airship.png"):addTo(self.char):scale(0.5)
    local armature = ccs.Armature:create("feiting"):addTo(ariship)
    local p = ariship:getAnchorPointInPoints()
    armature:align(display.CENTER, p.x, p.y):getAnimation():playWithIndex(0)
    armature:getAnimation():setSpeedScale(2)
    ariship:setAnchorPoint(cc.p(0.4, 0.5))
    ariship:runAction(cc.RepeatForever:create(transition.sequence{
        cc.MoveBy:create(5, cc.p(0, 10)),
        cc.MoveBy:create(5, cc.p(0, -10))
    }))
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
    local exclamation_time = 0.5
    local exclamation_scale = 0.2
    local size = self.char:getContentSize()
    local s = display.newSprite("exclamation.png")
        :addTo(self.char):pos(size.width*0.4, size.height*0.4):scale(0)
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
        cc.CallFunc:create(function()
            transition.scaleTo(s, {
                scale = exclamation_scale,
                time = exclamation_time,
                easing = "backout",
            })
        end),
        cc.DelayTime:create(exclamation_time),
        cc.CallFunc:create(function()
            s:removeFromParent()
            p:resolve()
        end),
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
function PVELayer:ResetCharPos()
    local start = self.pve_map:GetStartPoint()
    self:MoveCharTo(start.x, start.y)
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
                local fog = self.war_fog_layer:getTileAt(cc.p(x_, y_))
                if fog:isVisible() then
                    fog:hide()
                    self.pve_map:InsertFog(x_, y_)
                end
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
function PVELayer:CurrentPVEMap()
    return self.pve_map
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


















