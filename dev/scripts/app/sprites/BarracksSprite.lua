local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local BarracksSprite = class("BarracksSprite", FunctionUpgradingSprite)

function BarracksSprite:OnBeginRecruit()
    self:PlayAni()
end
function BarracksSprite:OnRecruiting()
end
function BarracksSprite:OnEndRecruit()
    self:StopAni()
    app:GetAudioManager():PlayeEffectSoundWithKey("TROOP_COMPLETE")
end

function BarracksSprite:ctor(city_layer, entity, city)
    BarracksSprite.super.ctor(self, city_layer, entity, city)
    entity:AddBarracksListener(self)
    if entity:IsRecruting() then
        self:PlayAni()
    else
        self:StopAni()
    end
end
function BarracksSprite:PlayAni()
    local animation = self:GetAniArray()[1]:show():getAnimation()
    animation:stop()
    animation:setSpeedScale(2)
    animation:playWithIndex(0)
end
function BarracksSprite:StopAni()
    self:GetAniArray()[1]:hide():getAnimation():stop()
end


return BarracksSprite








