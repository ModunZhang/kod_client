local DragonSprite = import(".DragonSprite")
local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local DragonEyrieSprite = class("DragonEyrieSprite", FunctionUpgradingSprite)

local DRAGON = 1
function DragonEyrieSprite:ctor(...)
    DragonEyrieSprite.super.ctor(self, ...)
    local x, y = self:GetSpriteOffset()
    self.dragon_sprite = DragonSprite.new(self:GetMapLayer(), self:GetMapLayer():CurrentTerrain())
    :addTo(self, DRAGON):pos(x-70, y+70)
end
function DragonEyrieSprite:ReloadSpriteCauseTerrainChanged()
    self.dragon_sprite:ReloadSpriteCauseTerrainChanged(self:GetMapLayer():CurrentTerrain())
end

return DragonEyrieSprite


















