local Sprite = import(".Sprite")
local AllianceDecoratorSprite = class("AllianceDecoratorSprite", Sprite)
local allianceBuildingType = GameDatas.AllianceInitData.buildingType
local decorator_map = {
    decorate_lake_1 = { "lake_288x240.png", 1 },
    decorate_lake_2 = { "lake_220x174.png", 1 },
    decorate_mountain_1 = { "hill_312x296.png", 1 },
    decorate_mountain_2 = { "hill_228x146.png", 1 },
    decorate_tree_1 = { "tree_1_120x120.png", 0.8 },
    decorate_tree_2 = { "tree_2_120x120.png", 0.8 },
}
function AllianceDecoratorSprite:ctor(city_layer, entity)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    AllianceDecoratorSprite.super.ctor(self, city_layer, entity, x, y)
    -- self:CreateBase()
    -- self:GetSprite():setVisible(false)
end
function AllianceDecoratorSprite:GetSpriteFile()
    return unpack(decorator_map[self:GetEntity():GetType()])
end
function AllianceDecoratorSprite:GetSpriteOffset()
    local w, h = self:GetSize()
    return self:GetLogicMap():ConvertToLocalPosition((w - 1)/2, (h - 1)/2)
end




---- override
function AllianceDecoratorSprite:CreateBase()
    self:GenerateBaseTiles(self:GetEntity():GetSize())
end
function AllianceDecoratorSprite:newBatchNode(w, h)
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
return AllianceDecoratorSprite





