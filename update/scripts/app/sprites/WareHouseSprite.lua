local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local WareHouseSprite = class("WareHouseSprite", FunctionUpgradingSprite)

function WareHouseSprite:ctor(city_layer, entity, city)
    WareHouseSprite.super.ctor(self, city_layer, entity, city)
    self.action_node = display.newNode():addTo(self)
    self:PlayAni()
end
function WareHouseSprite:PlayAni()
    local animation = self:GetAniArray()[1]:getAnimation()
    animation:stop()
    animation:setSpeedScale(2)
    animation:playWithIndex(0, -1, 0)
    self.action_node:performWithDelay(function()
        self:PlayAni()
    end, math.random(3, 6))
end


return WareHouseSprite








