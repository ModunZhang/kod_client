local DragonSprite = import(".DragonSprite")
local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local DragonEyrieSprite = class("DragonEyrieSprite", FunctionUpgradingSprite)

local DRAGON = 1
function DragonEyrieSprite:ctor(...)
    DragonEyrieSprite.super.ctor(self, ...)
    local x, y = self:GetSpriteOffset()
    self.dragon_sprite = DragonSprite.new(self:GetMapLayer(), self:GetMapLayer():Terrain())
    :addTo(self, DRAGON):scale(0.7):pos(x+20, y+110)
end
function DragonEyrieSprite:ReloadSpriteCauseTerrainChanged()
    self.dragon_sprite:ReloadSpriteCauseTerrainChanged(self:GetMapLayer():Terrain())
end

return DragonEyrieSprite


















