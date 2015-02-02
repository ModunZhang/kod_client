local Sprite = import(".Sprite")
local RuinSprite = class("RuinSprite", Sprite)
local random = math.random
function RuinSprite:ctor(city_layer, entity)
    self.png_index = random(3)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    RuinSprite.super.ctor(self, city_layer, entity, x, y)
end
function RuinSprite:GetSpriteFile()
	return string.format("ruin_%d.png", self.png_index)
end
function RuinSprite:GetSpriteOffset()
	if self.png_index == 3 then
		return 0, 40
	end
    return 0, 35
end
function RuinSprite:EnterEditMode()
    self:stopAllActions()
    self:runAction(cc.RepeatForever:create(transition.sequence{
        cc.TintTo:create(0.8, 180, 180, 180),
        cc.TintTo:create(0.8, 255, 255, 255)
    }))
end
function RuinSprite:LeaveEditMode()
	self:stopAllActions()
    self:setColor(display.COLOR_WHITE)
end
function RuinSprite:IsEditMode()
	return self:getNumberOfRunningActions() > 0
end

return RuinSprite



