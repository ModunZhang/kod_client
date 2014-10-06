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
    -- local x, y = self:GetMap():ConvertToMapPosition(self:GetLogicPosition())
    -- self:getParent():convertToWorldSpace(cc.p(x, y))
    return self:convertToWorldSpace(cc.p(self:GetSpriteOffset())),
        self:convertToWorldSpace(cc.p(self:GetSpriteButtomPosition()))
end
function UpgradingSprite:OnOrientChanged()
end
function UpgradingSprite:OnLogicPositionChanged(x, y)
    self:SetPositionWithLogic(self:GetMap():ConvertToMapPosition(x, y))
end
function UpgradingSprite:OnBuildingUpgradingBegin(building, time)
    if self.label then
        self.label:setString(building:GetType().." "..building:GetLevel())
    end
    self:NotifyObservers(function(listener)
        listener:OnBuildingUpgradingBegin(building, time)
    end)
end
function UpgradingSprite:OnBuildingUpgradeFinished(building, time)
    if self.label then
        self.label:setString(building:GetType().." "..building:GetLevel())
    end
    self:NotifyObservers(function(listener)
        listener:OnBuildingUpgradeFinished(building, time)
    end)
    self:UpdateSprite()
    self:RefreshShadow()
    self:OnSceneMove()
end
function UpgradingSprite:OnBuildingUpgrading(building, time)
    if self.label then
        self.label:setString("upgrading "..building:GetLevel().."\n"..math.round(building:GetUpgradingLeftTimeByCurrentTime(time)))
    end
    self:NotifyObservers(function(listener)
        listener:OnBuildingUpgrading(building, time)
    end)
end
function UpgradingSprite:CheckCondition()
    self:NotifyObservers(function(listener)
        listener:OnCheckUpgradingCondition(self)
    end)
end
function UpgradingSprite:ctor(city_layer, entity)
    self.config = SpriteConfig[entity:GetType()]
    local x, y = city_layer.iso_map:ConvertToMapPosition(entity:GetLogicPosition())
    UpgradingSprite.super.ctor(self, city_layer, entity, x, y)
    entity:AddBaseListener(self)
    entity:AddUpgradeListener(self)
    
    if entity:IsUnlocked() and self:GetShadowConfig() then
        self:CreateShadow(self:GetShadowConfig())
    end

    self.handle = self:schedule(function() self:CheckCondition() end, 1)
    -- self:InitLabel(entity)
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
    local entity = self:GetEntity()
    if self:HasConfig() then
        local config = self:GetCurrentConfig()
        return config.png, config.scale
    elseif entity:GetType() == "dragonEyrie" then
        return "sprites/buildings/dragonEyrie.png"
    elseif entity:GetType() == "academy" then
        return "sprites/buildings/academy.png"
    elseif entity:GetType() == "hunterHall" then
        return "sprites/buildings/hunterHall.png"
    elseif entity:GetType() == "stable" then
        return "sprites/buildings/stable.png"
    elseif entity:GetType() == "trainGround" then
        return "sprites/buildings/trainGround.png"
    elseif entity:GetType() == "workShop" then
        return "sprites/buildings/workShop.png"
    elseif entity:GetType() == "watchTower" then
        return "sprites/buildings/watchTower.png"
    elseif entity:GetType() == "blackSmith" or
        entity:GetType() == "academy" or
        entity:GetType() == "workShop" or
        entity:GetType() == "warehouse" or
        entity:GetType() == "townHall" or
        entity:GetType() == "stable" or
        entity:GetType() == "hospital" or
        entity:GetType() == "materialDepot" or
        entity:GetType() == "armyCamp" or
        entity:GetType() == "toolShop" or
        entity:GetType() == "trainingGround" or
        entity:GetType() == "foundry" or
        entity:GetType() == "stoneMason" or
        entity:GetType() == "lumbermill" or
        entity:GetType() == "hunterHall" or
        entity:GetType() == "tradeGuild" or
        entity:GetType() == "barracks" or
        entity:GetType() == "mill" or
        entity:GetType() == "prison"
    then
        return "sprites/buildings/armyCamp.png"
    elseif entity:GetType() == "woodcutter" then
        return "woodCutter_1_312x250.png", 0.6
    elseif entity:GetType() == "woodcutter" or
        entity:GetType() == "quarrier" or
        entity:GetType() == "farmer" or
        entity:GetType() == "dwelling" or
        entity:GetType() == "miner"
    then
        return "sprites/houses/waterWell.png"
    end
end
function UpgradingSprite:GetSpriteOffset()
    local entity = self:GetEntity()
    if self:HasConfig() then
        local offset = self:GetCurrentConfig().offset
        return offset.x, offset.y
    elseif entity:GetType() == "dragonEyrie" then
        return 0, 350
    elseif entity:GetType() == "academy" then
        return 0, 250
    elseif entity:GetType() == "hunterHall" then
        return 0, 250
    elseif entity:GetType() == "stable" then
        return 0, 250
    elseif entity:GetType() == "trainGround" then
        return 0, 250
    elseif entity:GetType() == "workShop" then
        return 0, 250
    elseif entity:GetType() == "watchTower" then
        return 0, 320
    elseif entity:GetType() == "blackSmith" or
        entity:GetType() == "academy" or
        entity:GetType() == "workShop" or
        entity:GetType() == "warehouse" or
        entity:GetType() == "townHall" or
        entity:GetType() == "stable" or
        entity:GetType() == "hospital" or
        entity:GetType() == "materialDepot" or
        entity:GetType() == "armyCamp" or
        entity:GetType() == "toolShop" or
        entity:GetType() == "trainingGround" or
        entity:GetType() == "foundry" or
        entity:GetType() == "stoneMason" or
        entity:GetType() == "lumbermill" or
        entity:GetType() == "hunterHall" or
        entity:GetType() == "tradeGuild" or
        entity:GetType() == "barracks" or
        entity:GetType() == "mill" or
        entity:GetType() == "prison"
    then
        return 0, 180
    elseif entity:GetType() == "woodcutter" or
        entity:GetType() == "quarrier" or
        entity:GetType() == "farmer" or
        entity:GetType() == "dwelling" or
        entity:GetType() == "miner"
    then
        return 0, 100
    end
end
function UpgradingSprite:HasConfig()
    local entity = self:GetEntity()
    return entity:GetType() == "keep"
        or entity:GetType() == "watchTower"
        or entity:GetType() == "warehouse"
        or entity:GetType() == "dragonEyrie"
        or entity:GetType() == "toolShop"
        or entity:GetType() == "materialDepot"
        or entity:GetType() == "armyCamp"
        or entity:GetType() == "barracks"
        or entity:GetType() == "blackSmith"
        or entity:GetType() == "foundry"
        or entity:GetType() == "stoneMason"
        or entity:GetType() == "lumbermill"
        or entity:GetType() == "mill"
        or entity:GetType() == "hospital"
        or entity:GetType() == "townHall"
        or entity:GetType() == "tradeGuild"
        --
        or entity:GetType() == "dwelling"
        or entity:GetType() == "farmer"
        or entity:GetType() == "woodcutter"
        or entity:GetType() == "quarrier"
        or entity:GetType() == "miner"
end
function UpgradingSprite:UpdateSprite()
    local next_config, next_i = self:GetCurrentConfig()
    local before_config, before_i = self:GetBeforeConfig()
    if next_i ~= before_i then
        self:GetSprite():setTexture(display.newSprite(next_config.png):getTexture())
    end
end
function UpgradingSprite:GetShadowConfig()
    local config = self:GetCurrentConfig()
    if config then
        return config.shadow
    else
        return nil
    end
end
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
        return x + y * width + 200
    else
        return UpgradingSprite.super.GetLogicZorder(self, width)
    end
end
function UpgradingSprite:GetCenterPosition()
    return self:GetMap():ConvertToMapPosition(self:GetEntity():GetMidLogicPosition())
end


return UpgradingSprite
















