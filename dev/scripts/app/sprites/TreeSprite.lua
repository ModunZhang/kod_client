local Enum = import("..utils.Enum")
local Sprite = import(".Sprite")
local TreeSprite = class("TreeSprite", Sprite)
function TreeSprite:ctor(city_layer, entity, x, y)
    TreeSprite.super.ctor(self, city_layer, entity, x, y)
end
function TreeSprite:ReloadSpriteCauseTerrainChanged()
    self.sprite:removeFromParent()
    self.sprite = self:CreateSprite():addTo(self, SPRITE)
end
function TreeSprite:CreateSprite()
    local tile = self:GetEntity()
    local x, y, city = tile.x, tile.y, tile.city
    local xb = city:GetTileByIndex(x - 1, y)
    local yb = city:GetTileByIndex(x, y - 1)
    local xbyn = city:GetTileByIndex(x - 1, y + 1)
    local xnyb = city:GetTileByIndex(x + 1, y - 1)
    local xyb = city:GetTileByIndex(x - 1, y - 1)
    local xn = city:GetTileByIndex(x + 1, y)
    local yn = city:GetTileByIndex(x, y + 1)
    local terrain = self:GetMapLayer():Terrain()
    local ppsprite
    local sprite
    repeat
        if (xb and xb:IsUnlocked()) or 
            (yb and yb:IsUnlocked()) or 
            (xyb and xyb:IsUnlocked()) then
            break
        end
        sprite = display.newSprite(string.format("trees_up_%s.png", terrain))
        ppsprite = sprite
    until true
    repeat
        if (yb and yb:IsUnlocked()) or 
            (xn and xn:IsUnlocked()) or 
            (xnyb and xnyb:IsUnlocked()) then
            break
        end
        if sprite then
            sprite = display.newSprite(string.format("trees_right_%s.png", terrain)):addTo(sprite):align(display.LEFT_BOTTOM)
        else
            sprite = display.newSprite(string.format("trees_right_%s.png", terrain))
            ppsprite = sprite
        end
    until true
    repeat
        if (xb and xb:IsUnlocked()) or 
            (xn and xn:IsUnlocked()) or 
            (yn and yn:IsUnlocked()) or 
            (xbyn and xbyn:IsUnlocked()) then
            break
        end
        if sprite then
            sprite = display.newSprite(string.format("trees_left_%s.png", terrain)):addTo(sprite):align(display.LEFT_BOTTOM)
        else
            sprite = display.newSprite(string.format("trees_left_%s.png", terrain))
            ppsprite = sprite
        end
    until true
    repeat
        if (xn and xn:IsUnlocked()) or 
            (yn and yn:IsUnlocked()) then
            break
        end
        if sprite then
            sprite = display.newSprite(string.format("trees_down_%s.png", terrain)):addTo(sprite):align(display.LEFT_BOTTOM)
        else
            sprite = display.newSprite(string.format("trees_down_%s.png", terrain))
            ppsprite = sprite
        end
    until true
    if not ppsprite then
        ppsprite = display.newSprite("1.png"):hide()
    end
    return ppsprite
end
function TreeSprite:GetSpriteFile()
    -- local tile = self:GetEntity()
    -- local x, y, city = tile.x, tile.y, tile.city
    -- local xb = city:GetTileByIndex(x - 1, y)
    -- local yb = city:GetTileByIndex(x, y - 1)
    -- local xn = city:GetTileByIndex(x + 1, y)
    -- local yn = city:GetTileByIndex(x, y + 1)
    -- local xyb = city:GetTileByIndex(x - 1, y - 1)
    -- -- 路的地块
    -- if x == 2 then
    --     local face_tile = city:GetTileFaceToGate()
    --     return string.format("road_%d_%s.png", y - 3, self:GetMapLayer():Terrain())
    -- end
    -- -- 检查X负方向
    -- if xb and xb:IsUnlocked() then
    --     -- 若X,Y方向都被解锁，则是
    --     if yb and yb:IsUnlocked() then
    --         if yn and yn:IsUnlocked() then
    --             return string.format("unlock_trees_y_%s.png", self:GetMapLayer():Terrain())
    --         end
    --         return string.format("unlock_trees_y_%s.png", self:GetMapLayer():Terrain())
    --     end
    --     --
    --     return string.format("unlock_trees_5_%s.png", self:GetMapLayer():Terrain())
    -- end
    -- -- 检查Y方向
    -- if yb and yb:IsUnlocked() then
    --     if xb and xb:IsUnlocked() then
    --         return string.format("unlock_trees_5_%s.png", self:GetMapLayer():Terrain())
    --     end
    --     return string.format("unlock_trees_3_%s.png", self:GetMapLayer():Terrain())
    -- end
    -- -- 拐角
    -- if xb and xb.locked and yb and yb.locked and xyb and xyb:IsUnlocked() then
    --     return string.format("unlock_trees_4_%s.png", self:GetMapLayer():Terrain())
    -- end
    -- 全覆盖
    return string.format("trees_down_%s.png", self:GetMapLayer():Terrain())
end
function TreeSprite:GetSpriteOffset()
    return 0, 0
end
function TreeSprite:GetLogicZorder()
    local x, y = self:GetLogicPosition()
    return self:GetMapLayer():GetZOrderBy(self, x, y + 3)
end

return TreeSprite




















