local PeopleSprite = import(".PeopleSprite")
local SoldierSprite = class("SoldierSprite", PeopleSprite)
function SoldierSprite:ctor(city_layer, soldier_type, x, y)
    SoldierSprite.super.ctor(self, city_layer, x, y)
    self.soldier_type = soldier_type
    ui.newTTFLabel({text = soldier_type, size = 20, x = 0, y = 100}):addTo(self, 10)
end
function SoldierSprite:GetSpriteOffset()
    return 20, 100
end
function SoldierSprite:CreateBase()
    self:GenerateBaseTiles(2, 2)
end
function SoldierSprite:GetSoldierType()
	return self.soldier_type
end
function SoldierSprite:RealScale()
    return 0.5
end

return SoldierSprite



