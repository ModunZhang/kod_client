local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local HospitalSprite = class("HospitalSprite", FunctionUpgradingSprite)

function HospitalSprite:OnBeginTreat()
    self:PlayAni()
end
function HospitalSprite:OnTreating()
end
function HospitalSprite:OnEndTreat()
    self:StopAni()
end

function HospitalSprite:ctor(city_layer, entity, city)
    HospitalSprite.super.ctor(self, city_layer, entity, city)
    entity:AddHospitalListener(self)
    if entity:IsTreating() then
        self:PlayAni()
    else
        self:StopAni()
    end
end
function HospitalSprite:PlayAni()
    local animation = self:GetAniArray()[1]:show():getAnimation()
    animation:stop()
    animation:setSpeedScale(2)
    animation:playWithIndex(0)
end
function HospitalSprite:StopAni()
    self:GetAniArray()[1]:hide():getAnimation():stop()
end


return HospitalSprite








