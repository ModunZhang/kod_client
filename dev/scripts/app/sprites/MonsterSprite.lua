local UILib = import("..ui.UILib")
local Localize = import("..utils.Localize")
local SpriteConfig = import(".SpriteConfig")
local WithInfoSprite = import(".WithInfoSprite")
local MonsterSprite = class("MonsterSprite", WithInfoSprite)

local monsterConfig = GameDatas.AllianceInitData.monster

function MonsterSprite:ctor(city_layer, entity, is_my_alliance)
    MonsterSprite.super.ctor(self, city_layer, entity, is_my_alliance)
    -- self:CreateBase()
end
function MonsterSprite:GetSpriteFile()
    -- return monsterConfig[self:GetEntity():GetAlslianceMonsterInfo().level].icon
    return "ironIngot_128x128.png"
end
function MonsterSprite:GetInfo()
    return 1, "yeguai"
end





---
function MonsterSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
function MonsterSprite:newBatchNode(w, h)
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
return MonsterSprite