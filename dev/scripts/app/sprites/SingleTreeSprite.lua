local Sprite = import(".Sprite")
local SingleTreeSprite = class("SingleTreeSprite", Sprite)

local TREE_MAP = {
	grassLand = {"tree_grass_148x246.png", "tree_grass_109x172.png"},
	desert = {"tree_desert_183x171.png", "tree_desert_182x175.png"},
	iceField = {"tree_icefield_150x209.png", "tree_icefield_166x221.png"},
}

function SingleTreeSprite:ctor(city_layer, x, y)
    self.x, self.y = x, y
    local ax, ay = city_layer:GetLogicMap():ConvertToMapPosition(x, y)
    SingleTreeSprite.super.ctor(self, city_layer, nil, ax, ay)
    self:GetSprite():align(display.BOTTOM_CENTER)
    -- self:CreateBase()
end
function SingleTreeSprite:ReloadSpriteCauseTerrainChanged()
	self.sprite:removeFromParent()
    self.sprite = self:CreateSprite():addTo(self, SPRITE):align(display.BOTTOM_CENTER)
end
function SingleTreeSprite:GetSpriteFile()
	if not self.png_index then
    	self.png_index = (math.floor(math.random() * 1000) % 2) + 1
	end
    return TREE_MAP[self:GetMapLayer():CurrentTerrain()][self.png_index], 0.6
end
function SingleTreeSprite:GetSpriteOffset()
    return 5, -55
end
function SingleTreeSprite:GetMidLogicPosition()
    return self.x, self.y
end
function SingleTreeSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end

return SingleTreeSprite


















