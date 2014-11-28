--
-- Author: Danny He
-- Date: 2014-11-28 08:56:14
--
local Sprite = import(".Sprite")
local VillageSprite = class("VillageSprite", Sprite)
function VillageSprite:ctor(city_layer, entity)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    VillageSprite.super.ctor(self, city_layer, entity, x, y)
    -- self:CreateBase()
end
function VillageSprite:GetSpriteFile()
	return "woodcutter_1_342x250.png",0.33
end
function VillageSprite:GetSpriteOffset()
	return self:GetLogicMap():ConvertToLocalPosition(0, 0)
end




---
function VillageSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
function VillageSprite:newBatchNode(w, h)
    local start_x, end_x, start_y, end_y = self:GetLocalRegion(w, h)
    local base_node = display.newBatchNode("grass_80x80_.png", 10)
    local map = self:GetLogicMap()
    for ix = start_x, end_x do
        for iy = start_y, end_y do
			display.newSprite(base_node:getTexture()):addTo(base_node):pos(map:ConvertToLocalPosition(ix, iy))
        end
    end
    return base_node
end
return VillageSprite