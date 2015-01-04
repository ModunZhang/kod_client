local SpriteConfig = import(".SpriteConfig")
local Sprite = import(".Sprite")
local UpgradingSprite = class("UpgradingSprite", Sprite)
----

function UpgradingSprite:OnSceneMove()
    local world_point, bottom_world_point = self:GetWorldPosition()
    self:NotifyObservers(function(listener)
        listener:OnPositionChanged(world_point.x, world_point.y, bottom_world_point.x, bottom_world_point.y)
    end)
end
function UpgradingSprite:GetWorldPosition()
    -- local x, y = self:GetLogicMap():ConvertToMapPosition(self:GetLogicPosition())
    -- self:getParent():convertToWorldSpace(cc.p(x, y))
    return self:convertToWorldSpace(cc.p(self:GetSpriteOffset())),
        self:convertToWorldSpace(cc.p(self:GetSpriteButtomPosition()))
end
function UpgradingSprite:OnOrientChanged()
end
function UpgradingSprite:OnLogicPositionChanged(x, y)
    self:SetPositionWithZOrder(self:GetLogicMap():ConvertToMapPosition(x, y))
end
function UpgradingSprite:OnBuildingUpgradingBegin(building, time)
    if self.label then
        self.label:setString(building:GetType().." "..building:GetLevel())
    end
    self:NotifyObservers(function(listener)
        listener:OnBuildingUpgradingBegin(building, time)
    end)

    -- animation
    self:StartBuildingAnimation()
end
function UpgradingSprite:OnBuildingUpgradeFinished(building, time)
    if self.label then
        self.label:setString(building:GetType().." "..building:GetLevel())
    end
    self:NotifyObservers(function(listener)
        listener:OnBuildingUpgradeFinished(building, time)
    end)
    self:RefreshSprite()
    -- self:RefreshShadow()
    self:OnSceneMove()

    -- animation
    self:StopBuildingAnimation()
end
function UpgradingSprite:OnBuildingUpgrading(building, time)
    if self.label then
        self.label:setString("upgrading "..building:GetLevel().."\n"..math.round(building:GetUpgradingLeftTimeByCurrentTime(time)))
    end
    self:NotifyObservers(function(listener)
        listener:OnBuildingUpgrading(building, time)
    end)

    -- animation
    self:StartBuildingAnimation()
end
function UpgradingSprite:StartBuildingAnimation()
    if self.building_animation then return end
    local sequence = transition.sequence{
        cc.TintTo:create(0.8, 180, 180, 180),
        cc.TintTo:create(0.8, 255, 255, 255)
    }
    self:stopAllActions()
    self.building_animation = self:runAction(cc.RepeatForever:create(sequence))
end
function UpgradingSprite:StopBuildingAnimation()
    self:stopAllActions()
    self:setColor(display.COLOR_WHITE)
    self.building_animation = nil
end
function UpgradingSprite:CheckCondition()
    self:NotifyObservers(function(listener)
        listener:OnCheckUpgradingCondition(self)
    end)
end
function UpgradingSprite:ctor(city_layer, entity)
    self.config = SpriteConfig[entity:GetType()]
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    UpgradingSprite.super.ctor(self, city_layer, entity, x, y)
    entity:AddBaseListener(self)
    entity:AddUpgradeListener(self)

    -- if entity:IsUnlocked() and self:GetShadowConfig() then
    --     self:CreateShadow(self:GetShadowConfig())
    -- end

    self.handle = self:schedule(function() self:CheckCondition() end, 1)
    -- self:InitLabel(entity)
    -- self:CreateBase()
end
function UpgradingSprite:DestorySelf()
    self:GetEntity():RemoveBaseListener(self)
    self:GetEntity():RemoveUpgradeListener(self)
    self:removeFromParent()
end
function UpgradingSprite:InitLabel(entity)
    local label = ui.newTTFLabel({ text = "text" , x = 0, y = 0 })
    self:addChild(label, 101)
    label:setPosition(cc.p(self:GetSpriteOffset()))
    label:setFontSize(50)
    self.label = label
    level = entity:GetLevel()
    label:setString(entity:GetType().." "..level)
end
function UpgradingSprite:GetSpriteFile()
    local config = self:GetCurrentConfig()
    return config.png, config.scale
end
function UpgradingSprite:GetSpriteOffset()
    local offset = self:GetCurrentConfig().offset
    return offset.x, offset.y
end
-- function UpgradingSprite:GetShadowConfig()
--     local config = self:GetCurrentConfig()
--     if config then
--         return config.shadow
--     else
--         return nil
--     end
-- end
function UpgradingSprite:GetCurrentConfig()
    if self.config then
        return self.config:GetConfigByLevel(self.entity:GetLevel())
    else
        return nil
    end
end
function UpgradingSprite:GetBeforeConfig()
    if self.config then
        return self.config:GetConfigByLevel(self.entity:GetBeforeLevel())
    else
        return nil
    end
end
function UpgradingSprite:GetLogicZorder(width)
    if self:GetEntity():GetType() == "watchTower" then
        local x, y = self:GetLogicPosition()
        return self:GetMapLayer():GetZOrderBy(self, x, y) + 100
    else
        return UpgradingSprite.super.GetLogicZorder(self, width)
    end
end
function UpgradingSprite:GetCenterPosition()
    return self:GetLogicMap():ConvertToMapPosition(self:GetEntity():GetMidLogicPosition())
end


return UpgradingSprite


















