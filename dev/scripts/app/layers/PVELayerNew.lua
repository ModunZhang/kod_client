local pvemap = import("..map.pvemap")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local PveSprite = import("..sprites.PveSprite")
local MapLayer = import(".MapLayer")
local PVELayerNew = class("PVELayerNew", MapLayer)



local map = {
    {"image", "hill_1_grassLand.png"      ,3,3,1},
    {"image", "hill_2_grassLand.png"      ,3,2,1},
    {"image", "lake_1_grassLand.png"      ,3,2,1},
    {"image", "lake_2_grassLand.png"      ,2,2,1},
    {"image", "tree_1_grassLand.png"      ,1,1,0.7},
    {"image", "tree_2_grassLand.png"      ,1,1,0.7},
    {"image", "tree_3_grassLand.png"      ,1,1,0.7},
    {"image", "tree_4_grassLand.png"      ,1,1,0.7},
    {"image", "crashed_airship_80x70.png" ,1,1,1},
    {"image", "warriors_tomb_80x72.png"   ,1,1,1},
    {"animation", "yewaiyindi"            ,1,1,1},
    {"image", "keel_189x86.png"           ,1,1,1},
    {"image", "keel_189x86.png"           ,1,1,1},
    {"animation", "zhihuishi"             ,1,1,1},
    {"image", "tmp_pve_flag_80x80.png"    ,1,1,1.5},
    {"image", "alliance_moonGate.png"     ,1,1,1.5},
}



local function bezierat(a,b,c,d,t)
    return (math.pow(1-t,3) * a +
        3*t*(math.pow(1-t,2))*b +
        3*math.pow(t,2)*(1-t)*c +
        math.pow(t,3)*d)
end

local function linerat(a,b,t)
    return a + (b - a) * t
end


function PVELayerNew:ctor(scene, user, level)
    PVELayerNew.super.ctor(self, scene, 0.5, 1.5)
    self.user = user
    self.level = level

    GameUtils:LoadImagesWithFormat(function()
        self.background = cc.TMXTiledMap:create("tmxmaps/pve_10x42.tmx"):addTo(self)
    end, cc.TEXTURE2_D_PIXEL_FORMAT_RGB5_A1)

    self.normal_map = NormalMapAnchorBottomLeftReverseY.new({
        tile_w = pvemap.tilewidth,
        tile_h = pvemap.tileheight,
        map_width = pvemap.width,
        map_height = pvemap.height,
        base_x = 0,
        base_y = pvemap.height * pvemap.tileheight,
    })


    self.seq_npc = {}
    assert(#pvemap.layers[2].objects == 1)
    for i,v in ipairs(pvemap.layers[2].objects) do
        local lines = {}
        for i,line in ipairs(v.polyline) do
            local lx,ly = math.floor((line.x + v.x)/80) - 1, math.floor((line.y + v.y)/80) - 1
            local x,y = self.normal_map:ConvertToMapPosition(lx,ly)
            table.insert(lines, {x = x, y = y})
            table.insert(self.seq_npc, {x = lx, y = ly})
        end
        while #lines >= 2 do
            local dx,dy = math.abs(lines[2].x - lines[1].x), math.abs(lines[2].y - lines[1].y)
            local f = 100
            local ux1,uy1,ux2,uy2
            if dy / dx <= 1 then
                ux1 = linerat(lines[1].x, lines[2].x, 0.33)
                uy1 = linerat(lines[1].y, lines[2].y, 0.33) + math.random(f) - f*0.5

                ux2 = linerat(lines[1].x, lines[2].x, 0.66)
                uy2 = linerat(lines[1].y, lines[2].y, 0.66) + math.random(f) - f*0.5
            else
                ux1 = linerat(lines[1].x, lines[2].x, 0.33) + math.random(f) - f*0.5
                uy1 = linerat(lines[1].y, lines[2].y, 0.33)

                ux2 = linerat(lines[1].x, lines[2].x, 0.66) + math.random(f) - f*0.5
                uy2 = linerat(lines[1].y, lines[2].y, 0.66)
            end
            local g = math.ceil(math.sqrt((lines[2].x - lines[1].x)^2 + (lines[2].y - lines[1].y)^2) / 30)
            for i = 2, g-2 do
                local x = bezierat(lines[1].x, ux1, ux2, lines[2].x, i * 1/g)
                local y = bezierat(lines[1].y, uy1, uy2, lines[2].y, i * 1/g)
                display.newSprite("road_22x24.png"):addTo(self):pos(x,y)
            end
            table.remove(lines, 1)
        end
    end
    table.remove(self.seq_npc, 1)





    self.npcs = {}
    local data = pvemap.layers[1].data
    for ly = 1, pvemap.height do
        for lx = 1, pvemap.width do
            local index = (ly-1) * pvemap.width + lx
            local gid = data[index]
            if map[gid] then
                local type,png,w,h,s = unpack(map[gid])
                local obj
                if gid == 15 or gid == 16 then
                    obj = PveSprite.new(self, string.format("%d_%d", level, self:GetNpcIndex(lx - 1, ly - 1)), lx - 1, ly - 1, gid)
                elseif type == "image" then
                    obj = display.newSprite(png)
                elseif type == "animation" then
                    obj = ccs.Armature:create(png)
                    obj:getAnimation():playWithIndex(0)
                end
                local x,y = self.normal_map:ConvertToMapPosition(lx - 1, ly - 1)
                local ox,oy = self.normal_map:ConvertToLocalPosition((w - 1)/2, (h - 1)/2)
                obj:addTo(self):pos(x+ox, y+oy):scale(s)

                if gid == 15 or gid == 16 then
                    self:RegisterNpc(obj, lx - 1, ly - 1)
                end
            end
        end
    end
    self:RefreshPve()
end
function PVELayerNew:ConvertLogicPositionToMapPosition(lx, ly)
    return self:convertToNodeSpace(self.background:convertToWorldSpace(cc.p(self.normal_map:ConvertToMapPosition(lx, ly))))
end
function PVELayerNew:GetZOrderBy(sprite, x, y)
    return 0
end
function PVELayerNew:GetLogicMap()
    return self.normal_map
end
function PVELayerNew:GetClickedObject(world_x, world_y)
    local point = self.background:convertToNodeSpace(cc.p(world_x, world_y))
    local logic_x, logic_y = self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
    local npc = self:GetNpcBy(logic_x, logic_y)
    for _,v in pairs(self.npcs) do
        if v:IsContainWorldPoint(world_x, world_y) then
            npc = v
        end
    end
    if npc and self.user:IsPveNameEnable(npc:GetPveName()) then
        return npc
    end
end
function PVELayerNew:RegisterNpc(obj,X,Y)
    local w,h = self.normal_map:GetSize()
    self.npcs[string.format("%d_%d", X, Y)] = obj
end
function PVELayerNew:GetNpcBy(X, Y)
    local w,h = self.normal_map:GetSize()
    return self.npcs[string.format("%d_%d", X, Y)]
end
function PVELayerNew:GetNpcIndex(X,Y)
    for i,v in ipairs(self.seq_npc) do
        if v.x == X and v.y == Y then
            return i
        end
    end
end
function PVELayerNew:RefreshPve()
    for i = 1, #self.seq_npc do
        local be = self.seq_npc[i - 1]
        local v = self.seq_npc[i]
        self:GetNpcBy(v.x, v.y)
        :SetStars(self.user:GetPveSectionStarByName(self:GetNpcBy(v.x, v.y):GetPveName()))
        if be then 
            if self.user:GetPveSectionStarByName(self:GetNpcBy(be.x, be.y):GetPveName()) > 0 then
                self:GetNpcBy(v.x, v.y):SetEnable(true)
            else
                self:GetNpcBy(v.x, v.y):SetEnable(false)
            end
        else
            self:GetNpcBy(v.x, v.y):SetEnable(true)
        end
    end
end
---
function PVELayerNew:getContentSize()
    if not self.content_size then
        local layer = self.background:getLayer("layer1")
        self.content_size = layer:getContentSize()
    end
    return self.content_size
end

return PVELayerNew


