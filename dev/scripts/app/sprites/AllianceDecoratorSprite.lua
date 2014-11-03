local Sprite = import(".Sprite")
local AllianceDecoratorSprite = class("AllianceDecoratorSprite", Sprite)
local decorator_map = {
    decorate_lake_1 = { png = "lake_240x160.png", w = 3, h = 2},
    decorate_lake_2 = { png = "lake_160x160.png", w = 2, h = 2},
    decorate_mountain_1 = { png = "hill_160x80.png", w = 2, h = 1},
    decorate_mountain_2 = { png = "hill_1_80x80.png", w = 1, h = 1},
    decorate_tree_1 = { png = "tree_1_120x120.png", w = 1, h = 1},
    decorate_tree_2 = { png = "tree_2_120x120.png", w = 1, h = 1},
}
function AllianceDecoratorSprite:ctor(city_layer, x, y, decorator_type)
    self.decorator_type = decorator_type
    local config = decorator_map[self.decorator_type]
    self.w, self.h = config.w, config.h
    self.x, self.y = x, y
    AllianceDecoratorSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    self:CreateBase()
end
function AllianceDecoratorSprite:GetSpriteFile()
    return decorator_map[self.decorator_type].png
end
function AllianceDecoratorSprite:GetSpriteOffset()
    return self:GetLogicMap():ConvertToLocalPosition((self.w-1)/2, (self.h - 1)/2)
end
function AllianceDecoratorSprite:SetPositionWithZOrder(x, y)
    self.x, self.y = self:GetLogicMap():ConvertToLogicPosition(x, y)
    AllianceDecoratorSprite.super.SetPositionWithZOrder(self, x, y)
end
function AllianceDecoratorSprite:GetMidLogicPosition()
    return self.x, self.y
end
function AllianceDecoratorSprite:CreateBase()
    self:GenerateBaseTiles(self.w, self.h)
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





