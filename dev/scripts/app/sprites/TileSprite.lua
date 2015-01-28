local Sprite = import(".Sprite")
local TileSprite = class("TileSprite", Sprite)
local random = math.random
function TileSprite:ctor(city_layer, entity, x, y)
    TileSprite.super.ctor(self, city_layer, entity, x, y)
    if entity:NeedWalls() then
        self:hide()
    end
end
function TileSprite:ReloadSpriteCauseTerrainChanged()
    self.sprite:removeFromParent()
    self.sprite = self:CreateSprite():addTo(self, SPRITE)
end
function TileSprite:GetSpriteFile()
    local tile = self:GetEntity()
    local x, y, city = tile.x, tile.y, tile.city
    -- 路的地块
    if x == 2 then
        return string.format("road_%d_%s.png", y - 3, self:GetMapLayer():Terrain())
    end
    if not self.png_index then
        self.png_index = random(2)
    end
    return string.format("unlock_tile_%d_%s.png", self.png_index, self:GetMapLayer():Terrain())
end
-- function TileSprite:GetSpriteOffset()
--     local tile = self:GetEntity()
--     local x, y, city = tile.x, tile.y, tile.city
--     -- 路的地块
--     if x == 2 then
--         return 0, 0
--     end
--     return -120, -30
-- end
function TileSprite:GetLogicZorder()
    return - 1
end
return TileSprite



















