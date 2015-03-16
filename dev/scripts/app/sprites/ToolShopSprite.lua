local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local ToolShopSprite = class("ToolShopSprite", FunctionUpgradingSprite)


function ToolShopSprite:OnBeginMakeMaterialsWithEvent()
    self:PlayAni()
end
function ToolShopSprite:OnMakingMaterialsWithEvent()
end
function ToolShopSprite:OnEndMakeMaterialsWithEvent()
    self:StopAni()
end
function ToolShopSprite:OnGetMaterialsWithEvent()
end

function ToolShopSprite:ctor(city_layer, entity, city)
    ToolShopSprite.super.ctor(self, city_layer, entity, city)
    entity:AddToolShopListener(self)
    if entity:IsMakingAny(app.timer:GetServerTime()) then
        self:PlayAni()
    else
        self:StopAni()
    end
end
function ToolShopSprite:PlayAni()
    for _,v in pairs(self:GetAniArray()) do
        local animation = v:show():getAnimation()
        animation:setSpeedScale(2)
        animation:playWithIndex(0)
    end
end
function ToolShopSprite:StopAni()
    for _,v in pairs(self:GetAniArray()) do
        v:hide():getAnimation():stop()
    end
end


return ToolShopSprite








