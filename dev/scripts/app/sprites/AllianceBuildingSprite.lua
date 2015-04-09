local UILib = import("..ui.UILib")
local Sprite = import(".Sprite")
local AllianceBuildingSprite = class("AllianceBuildingSprite", Sprite)

local building_map = {
    palace = {UILib.alliance_building.palace, 1},
    shrine = {UILib.alliance_building.shrine, 1},
    shop = {UILib.alliance_building.shop, 1},
    orderHall = {UILib.alliance_building.orderHall, 1},
    moonGate = {UILib.alliance_building.moonGate, 1},
}
local other_building_map = {
    palace = {UILib.other_alliance_building.palace, 1},
    shrine = {UILib.other_alliance_building.shrine, 1},
    shop = {UILib.other_alliance_building.shop, 1},
    orderHall = {UILib.other_alliance_building.orderHall, 1},
    moonGate = {UILib.other_alliance_building.moonGate, 1},
}
function AllianceBuildingSprite:ctor(city_layer, entity, is_my_alliance)
    self.is_my_alliance = is_my_alliance
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    AllianceBuildingSprite.super.ctor(self, city_layer, entity, x, y)
    -- self:CreateBase()
end
function AllianceBuildingSprite:GetSpriteFile()
    if self.is_my_alliance then
        return unpack(building_map[self:GetEntity():GetAllianceBuildingInfo().name])
    else
        return unpack(other_building_map[self:GetEntity():GetAllianceBuildingInfo().name])
    end
end
function AllianceBuildingSprite:GetSpriteOffset()
    return self:GetLogicMap():ConvertToLocalPosition(1, 1)
end




---
function AllianceBuildingSprite:CreateBase()
    self:GenerateBaseTiles(3, 3)
end
function AllianceBuildingSprite:newBatchNode(w, h)
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
return AllianceBuildingSprite




