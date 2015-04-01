--
-- Author: Danny He
-- Date: 2014-11-28 08:56:14
--
local Sprite = import(".Sprite")
local VillageSprite = class("VillageSprite", Sprite)
local UILib = import("..ui.UILib")
local SpriteConfig = import(".SpriteConfig")

function VillageSprite:ctor(city_layer, entity)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    VillageSprite.super.ctor(self, city_layer, entity, x, y)
    -- self:CreateBase()
end
function VillageSprite:GetSpriteFile()
    local village_info = self:VillageInfo()
    if not village_info  then
        local village_name = self:GetEntity():GetName()
        if village_name == 'woodVillage' then
            local decorate_tree = UILib.decorator_image[self:GetMapLayer():Terrain()].decorate_tree_1
            return decorate_tree
        elseif village_name == 'ironVillage' then
            return "iron_ruins_276x200.png",120/276
        elseif village_name == 'stoneVillage' then
            local stone_mountain = UILib.decorator_image[self:GetMapLayer():Terrain()].stone_mountain
            return stone_mountain
        elseif village_name == 'foodVillage' then
            local farmland = UILib.decorator_image[self:GetMapLayer():Terrain()].farmland
            return farmland
        end
    else
        local build_png = SpriteConfig[village_info.name]:GetConfigByLevel(village_info.level).png
	    return build_png
    end
end
function VillageSprite:GetSpriteOffset()
	return self:GetLogicMap():ConvertToLocalPosition(0, 0)
end


function VillageSprite:VillageInfo()
    return self:GetEntity():GetAllianceVillageInfo() 
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