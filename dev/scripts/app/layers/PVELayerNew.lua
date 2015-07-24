local pvemap = import("..map.pvemap")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local PVELayerNew = class("PVELayerNew", MapLayer)



local map = {
    [1] = {"image", "hill_1_grassLand.png",3,3,0.7},
    [2] = {"image", "hill_2_grassLand.png",3,3,0.7},
    [3] = {"image", "lake_1_grassLand.png",3,3,0.7},
    [4] = {"image", "lake_2_grassLand.png",3,3,0.7},
    [5] = {"image", "tree_1_grassLand.png",1,1,0.5},
    [6] = {"image", "tree_2_grassLand.png",1,1,0.5},
    [7] = {"image", "tree_3_grassLand.png",1,1,0.5},
    [8] = {"image", "tree_4_grassLand.png",1,1,0.5},
    [9] = {"image", "crashed_airship_80x70.png",1,1,1},
    [10] = {"image", "warriors_tomb_80x72.png",1,1,1},
    [11] = {"animation", "yewaiyindi",1,1,1},
    [12] = {"image", "keel_189x86.png",1,1,1},
    [13] = {"animation", "zhihuishi",1,1,1},
    [14] = {"image", "warehouse.png",1,1,0.5},
    [15] = {"image", "barracks.png",1,1,0.5},
    [16] = {"image", "watchTower.png",1,1,0.5},
    [17] = {"image", "hospital.png",1,1,0.5},
    [18] = {"image", "townHall.png",1,1,0.5},
    [19] = {"image", "materialDepot.png",1,1,0.5},
    [20] = {"image", "mill.png",1,1,0.5},
    [21] = {"image", "lumbermill.png",1,1,0.5},
    [22] = {"image", "stoneMason.png",1,1,0.5},
    [23] = {"image", "foundry.png",1,1,0.5},
    [24] = {"image", "academy.png",1,1,0.5},
    [25] = {"image", "dragonEyrie.png",1,1,0.5},
    [26] = {"image", "tradeGuild.png",1,1,0.5},
    [27] = {"image", "toolShop.png",1,1,0.5},
    [28] = {"image", "blackSmith.png",1,1,0.5},
    [29] = {"image", "trainingGround.png",1,1,0.5},
    [30] = {"image", "hunterHall.png",1,1,0.5},
    [31] = {"image", "stable.png",1,1,0.5},
    [32] = {"image", "workShop.png",1,1,0.5},
    [33] = {"image", "alliance_moonGate.png",1,1,1},
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


function PVELayerNew:ctor(scene, user)
    PVELayerNew.super.ctor(self, scene, 0.5, 1)
    GameUtils:LoadImagesWithFormat(function()
        self.background = cc.TMXTiledMap:create("tmxmaps/pve_background_21x21.tmx"):addTo(self)
    end, cc.TEXTURE2_D_PIXEL_FORMAT_RGB5_A1)

    self.normal_map = NormalMapAnchorBottomLeftReverseY.new({
        tile_w = 80,
        tile_h = 80,
        map_width = 21,
        map_height = 21,
        base_x = 0,
        base_y = 21 * 80,
    })


    for i,v in ipairs(pvemap.layers[2].objects) do
        local lines = {}
        for i,line in ipairs(v.polyline) do
            local x,y = self.normal_map:ConvertToMapPosition((line.x + v.x)/80 - 1, (line.y + v.y)/80 - 1)
            table.insert(lines, {x = x, y = y})
        end
        while #lines >= 2 do
            local dx,dy = math.abs(lines[2].x - lines[1].x), math.abs(lines[2].y - lines[1].y)
            local f = 300
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
            local g = 8
            for i = 2, g-2 do
                local x = bezierat(lines[1].x, ux1, ux2, lines[2].x, i * 1/g)
                local y = bezierat(lines[1].y, uy1, uy2, lines[2].y, i * 1/g)
                display.newCircle(10, {
                    fillColor = cc.c4f(1, 0, 0, 1),
                    borderColor = cc.c4f(0, 1, 0, 1),
                    borderWidth = 2
                }):addTo(self, 1):pos(x,y)
            end
            table.remove(lines, 1)
        end
    end



    local data = pvemap.layers[1].data
    for y = 1, 21 do
        for x = 1, 21 do
            local gid = data[ (y-1) * 21 + x ]
            if map[gid] then
                local type,png,w,h,s = unpack(map[gid])
                local obj
                if type == "image" then
                    obj = display.newSprite(png)
                elseif type == "animation" then
                    obj = ccs.Armature:create(png)
                    obj:getAnimation():playWithIndex(0)
                end
                local x,y = self.normal_map:ConvertToMapPosition(x-1, y-1)
                local ox,oy = self.normal_map:ConvertToLocalPosition((w - 1)/2, (h - 1)/2)
                obj:addTo(self):pos(x+ox, y+oy):scale(s)
            end
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

































