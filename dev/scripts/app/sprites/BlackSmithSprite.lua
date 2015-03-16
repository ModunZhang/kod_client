local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local BlackSmithSprite = class("BlackSmithSprite", FunctionUpgradingSprite)

function BlackSmithSprite:OnBeginMakeEquipmentWithEvent()
    self:PlayAni()
end
function BlackSmithSprite:OnMakingEquipmentWithEvent()
end
function BlackSmithSprite:OnEndMakeEquipmentWithEvent()
    self:StopAni()
end

function BlackSmithSprite:ctor(city_layer, entity, city)
    BlackSmithSprite.super.ctor(self, city_layer, entity, city)
    entity:AddBlackSmithListener(self)
    if entity:IsMakingEquipment() then
        self:PlayAni()
    else
        self:StopAni()
    end
end
function BlackSmithSprite:PlayAni()
    for _,v in pairs(self:GetAniArray()) do
        local animation = v:show():getAnimation()
        animation:setSpeedScale(2)
        animation:playWithIndex(0)
    end
end
function BlackSmithSprite:StopAni()
    for _,v in pairs(self:GetAniArray()) do
        v:hide():getAnimation():stop()
    end
end


return BlackSmithSprite








