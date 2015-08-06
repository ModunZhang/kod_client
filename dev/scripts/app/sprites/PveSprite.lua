local Sprite = import(".Sprite")
local PveSprite = class("PveSprite", Sprite)
local sections = GameDatas.PvE.sections
local special = GameDatas.Soldiers.special

function PveSprite:ctor(layer, npc_name, lx, ly, gid)
    self.npc_name = npc_name
    self.gid = gid
    self.lx, self.ly = lx, ly
    local x,y = layer:GetLogicMap():ConvertToMapPosition(lx, ly)
    PveSprite.super.ctor(self, layer, nil, x, y)
end
function PveSprite:RefreshSprite()
    PveSprite.super.RefreshSprite(self)
    self.lock = display.newSprite("alliance_stage_lock_icon.png")
    :addTo(self):pos(0, 50)
    if self:IsBoss() then
        self:GetSprite():setAnchorPoint(cc.p(0.45, 0.25))
    elseif self:IsSpecial() then
        self:GetSprite():setAnchorPoint(cc.p(0.51, 0.16))
    else
        self:GetSprite():setAnchorPoint(cc.p(0.51, 0.16))
    end
    if self.gid == 16 then return end

    local h = 120

    local bg = display.newSprite("arrow_green_22x32.png"
        , nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self):setScale(6, 0.8):pos(0, h)

    bg:setFilter(filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/bannerpve.fs",
            shaderName = "banner",
        })
    ))
    self.bg = bg
    self.stars = {}
    self.stars[1] = display.newSprite("alliance_shire_star_60x58_1.png"):addTo(self):scale(0.4):pos(-25,h)
    self.stars[2] = display.newSprite("alliance_shire_star_60x58_1.png"):addTo(self):scale(0.4):pos(0,h)
    self.stars[3] = display.newSprite("alliance_shire_star_60x58_1.png"):addTo(self):scale(0.4):pos(25,h)
end
function PveSprite:GetSpriteFile()
    if self:IsBoss() then
        return "alliance_moonGate.png", 0.8
    end
    if self:IsSpecial() then
        return "tmp_pve_flag_special.png", 1.2
    end
    return "tmp_pve_flag_128x128.png"
end
function PveSprite:IsSpecial()
    if not self:IsBoss() then
        local troops = string.split(sections[self.npc_name].troops, ",")
        for i,v in ipairs(troops) do
            local name = unpack(string.split(v, "_"))
            if special[name] then
                return true
            end
        end
    end
end
function PveSprite:IsBoss()
    return self.gid == 16
end
function PveSprite:GetLogicZorder()
    return self:GetMapLayer():GetZOrderBy(self, self.lx, self.ly)
end
function PveSprite:GetPveName()
    return self.npc_name
end
function PveSprite:SetStars(num)
    if self.gid == 16 then return self end
    for i,v in ipairs(self.stars) do
        v:setTexture(i <= num and "alliance_shire_star_60x58_1.png" or "alliance_shire_star_60x58_0.png")
    end
    return self
end
function PveSprite:SetEnable(isEnable)
    if isEnable then
        self:GetSprite():clearFilter()
    else
        self:GetSprite():setFilter(filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1}))
    end
    self.lock:setVisible(not isEnable)
    
    if self.gid == 16 then return self end
    for i,v in ipairs(self.stars) do
        v:setVisible(isEnable)
    end
    self.bg:setVisible(isEnable)
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





