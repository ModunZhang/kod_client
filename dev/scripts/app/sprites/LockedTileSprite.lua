local Sprite = import(".Sprite")
local LockedTileSprite = class("LockedTileSprite", Sprite)
local random = math.random
function LockedTileSprite:ctor(city_layer, entity, x, y)
    LockedTileSprite.super.ctor(self, city_layer, entity, x, y)
end
function LockedTileSprite:ReloadSpriteCauseTerrainChanged()
    self.sprite:removeFromParent()
    self.sprite = self:CreateSprite():addTo(self, SPRITE)
end
function LockedTileSprite:GetSpriteFile()
    return "locked_tile.png"
end
return LockedTileSprite



















