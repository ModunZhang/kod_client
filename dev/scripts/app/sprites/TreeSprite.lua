local Sprite = import(".Sprite")
local TreeSprite = class("TreeSprite", Sprite)
local TREE_MAP = {
    grass = {"tree_1_510x362.png", "tree_2_510x412.png"},
    desert = {"tree_1_510x362.png", "tree_2_510x412.png"},
    icefield = {"tree_1_510x362.png", "tree_2_510x412.png"},
}
function TreeSprite:ctor(city_layer, entity, x, y)
    TreeSprite.super.ctor(self, city_layer, entity, x, y)
end
function TreeSprite:ReloadSpriteCauseTerrainChanged()
    self.sprite:removeFromParent()
    self.sprite = self:CreateSprite():addTo(self, SPRITE)
end
local random = math.random
function TreeSprite:GetSpriteFile()
    if not self.png_index then
        self.png_index = random(123456789) % 2 + 1
    end
    return TREE_MAP[self:GetMapLayer():CurrentTerrain()][self.png_index]
end
function TreeSprite:GetSpriteOffset()
    return 0, 0
end

return TreeSprite


















