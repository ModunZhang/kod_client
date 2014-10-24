local Sprite = import(".Sprite")
local TreeSprite = class("TreeSprite", Sprite)
local TREE_MAP = {
    grass = {"trees_1_624x645.png", "trees_2_697x578.png"},
    desert = {"tree_desert_751x539.png", "tree_desert_763x582.png"},
    icefield = {"tree_icefield_785x643.png", "tree_icefield_721x568.png"},
}
function TreeSprite:ctor(city_layer, entity, x, y)
    TreeSprite.super.ctor(self, city_layer, entity, x, y)
end
function TreeSprite:ReloadSpriteCauseTerrainChanged()
    self.sprite:removeFromParent()
    self.sprite = self:CreateSprite():addTo(self, SPRITE)
end
-- function TreeSprite:GetLogicZorder(width)
--     local x, y = self:GetLogicPosition()
--     return x + y * width + 100
-- end
local random = math.random
function TreeSprite:GetSpriteFile()
    if not self.png_index then
        self.png_index = random(123456789) % 2 + 1
    end
    return TREE_MAP[self:GetMapLayer():CurrentTerrain()][self.png_index], 0.8
end
function TreeSprite:GetSpriteOffset()
    return 0, 0
end

return TreeSprite


















