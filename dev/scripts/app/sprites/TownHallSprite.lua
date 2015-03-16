local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local TownHallSprite = class("TownHallSprite", FunctionUpgradingSprite)

function TownHallSprite:OnNewDailyQuestsEvent()
    if LuaUtils:table_empty(self:GetEntity():BelongCity():GetUser():GetDailyQuestEvents()) then
        self:StopAni()
    else
        self:PlayAni()
    end
end
function TownHallSprite:ctor(city_layer, entity, city)
    TownHallSprite.super.ctor(self, city_layer, entity, city)
    city:GetUser():AddListenOnType(self, city:GetUser().LISTEN_TYPE.NEW_DALIY_QUEST_EVENT)
    if LuaUtils:table_empty(city:GetUser():GetDailyQuestEvents()) then
        self:StopAni()
    else
        self:PlayAni()
    end
end
function TownHallSprite:PlayAni()
    local animation = self:GetAniArray()[1]:show():getAnimation()
    animation:stop()
    animation:setSpeedScale(2)
    animation:playWithIndex(0)
end
function TownHallSprite:StopAni()
    self:GetAniArray()[1]:hide():getAnimation():stop()
end


return TownHallSprite










