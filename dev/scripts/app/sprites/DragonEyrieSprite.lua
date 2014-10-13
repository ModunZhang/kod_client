local DragonSprite = import(".DragonSprite")
local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local DragonEyrieSprite = class("DragonEyrieSprite", FunctionUpgradingSprite)

local DRAGON = 2
function DragonEyrieSprite:ctor(...)
    DragonEyrieSprite.super.ctor(self, ...)
    local x, y = self:GetSpriteOffset()
    self.dragon_sprite = DragonSprite.new(self:GetMapLayer():CurrentTerrain())
    :addTo(self, DRAGON):pos(x-40, y+70)
end
function DragonEyrieSprite:ReloadSprite()
    self.dragon_sprite:ReloadSprite(self:GetMapLayer():CurrentTerrain())
end

return DragonEyrieSprite


















