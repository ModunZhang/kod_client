local Sprite = import(".Sprite")
local PveSprite = class("PveSprite", Sprite)


function PveSprite:ctor(layer, npc_name, lx, ly, gid)
    self.npc_name = npc_name
    self.gid = gid
    self.lx, self.ly = lx, ly
    local x,y = layer:GetLogicMap():ConvertToMapPosition(lx, ly)
    PveSprite.super.ctor(self, layer, nil, x, y)
end
function PveSprite:RefreshSprite()
    PveSprite.super.RefreshSprite(self)
    local bg = display.newSprite("arrow_green_22x32.png"
        , nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self):setScale(6, 0.8):pos(0, 60)

    bg:setFilter(filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/bannerpve.fs",
            shaderName = "banner",
        })
    ))
    self.stars = {}
    self.stars[1] = display.newSprite("alliance_shire_star_60x58_1.png"):addTo(self):scale(0.4):pos(-25,60)
    self.stars[2] = display.newSprite("alliance_shire_star_60x58_1.png"):addTo(self):scale(0.4):pos(0,60)
    self.stars[3] = display.newSprite("alliance_shire_star_60x58_1.png"):addTo(self):scale(0.4):pos(25,60)
end
function PveSprite:GetSpriteFile()
    if self.gid == 15 then
        return "tmp_pve_flag_80x80.png"
    else
        return "alliance_moonGate.png", 0.5
    end
end
function PveSprite:GetLogicZorder()
    return self:GetMapLayer():GetZOrderBy(self, self.lx, self.ly)
end
function PveSprite:GetPveName()
    return self.npc_name
end
function PveSprite:SetStars(num)
    for i,v in ipairs(self.stars) do
        v:setTexture(i <= num and "alliance_shire_star_60x58_1.png" or "alliance_shire_star_60x58_0.png")
    end
    return self
end
---
function PveSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
function PveSprite:newBatchNode(w, h)
    local start_x, end_x, start_y, end_y = self:GetLocalRegion(w, h)
    local base_node = display.newBatchNode("grass_80x80_.png", 10)
    local map = self:GetLogicMap()
    for ix = start_x, end_x do
        for iy = start_y, end_y do
            display.newSprite(base_node:getTexture()):addTo(base_node):pos(map:ConvertToLocalPosition(ix, iy)):scale(2)
        end
    end
    return base_node
end
return PveSprite

