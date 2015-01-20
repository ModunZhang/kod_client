local Sprite = import(".Sprite")
local TreeSprite = class("TreeSprite", Sprite)
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
    return string.format("unlock_trees_%d_%s.png", self.png_index, self:GetMapLayer():Terrain())
end
function TreeSprite:GetSpriteOffset()
    return 0, 0
end

return TreeSprite


















