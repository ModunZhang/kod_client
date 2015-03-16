local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local AcademySprite = class("AcademySprite", FunctionUpgradingSprite)

function AcademySprite:OnProductionTechnologyEventDataChanged(changed_map)
    if self:GetEntity():BelongCity():HaveProductionTechEvent() then
        self:PlayAni()
    else
        self:StopAni()
    end
end
function AcademySprite:ctor(city_layer, entity, city)
    AcademySprite.super.ctor(self, city_layer, entity, city)
        city:AddListenOnType(self, city.LISTEN_TYPE.PRODUCTION_EVENT_CHANGED)
        if city:HaveProductionTechEvent() then
            self:PlayAni()
        else
            self:StopAni()
        end
end
function AcademySprite:PlayAni()
    local animation = self:GetAniArray()[1]:show():getAnimation()
    animation:stop()
    animation:setSpeedScale(2)
    animation:playWithIndex(0)
end
function AcademySprite:StopAni()
    self:GetAniArray()[1]:hide():getAnimation():stop()
end


return AcademySprite








