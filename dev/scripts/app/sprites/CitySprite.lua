local UILib = import("..ui.UILib")
local Sprite = import(".Sprite")
local SpriteConfig = import(".SpriteConfig")
local CitySprite = class("CitySprite", Sprite)
function CitySprite:ctor(city_layer, entity, is_my_alliance)
    self.is_my_alliance = is_my_alliance
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    CitySprite.super.ctor(self, city_layer, entity, x, y)
end
function CitySprite:GetSpriteFile()
    local config
    if self.is_my_alliance then
        config = SpriteConfig["keep"]
    else
        config = SpriteConfig["other_keep"]
    end
    return config:GetConfigByLevel(self:GetEntity():GetAllianceMemberInfo():KeepLevel()).png, 0.3
end
function CitySprite:GetSpriteOffset()
    return self:GetLogicMap():ConvertToLocalPosition(0, 0)
end
function CitySprite:RefreshSprite()
    CitySprite.super.RefreshSprite(self)
    if self.info then
        self.info:removeFromParent()
        self.info = nil
    end
    self.info = display.newNode():addTo(self):pos(0, -50):scale(0.8)
    self.banner = display.newSprite("city_banner.png"):addTo(self.info):align(display.CENTER_TOP)
    self.level = UIKit:ttfLabel({
        size = 22,
        color = 0xffedae,
    }):addTo(self.banner):align(display.CENTER, 30, 30)
    self.name = UIKit:ttfLabel({
        size = 20,
        color = 0xffedae,
    }):addTo(self.banner):align(display.LEFT_CENTER, 60, 32)
    self:RefreshInfo()
end
function CitySprite:RefreshInfo()
    local entity = self:GetEntity()
    local info = entity:GetAllianceMemberInfo()
    local banners = self.is_my_alliance and UILib.my_city_banner or UILib.enemy_city_banner
    self.banner:setTexture(banners[info:HelpedByTroopsCount()])
    self.level:setString(info:KeepLevel())
    self.name:setString(string.format("[%s]%s", entity:GetAlliance():Tag(), info:Name()))
end




---
function CitySprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
function CitySprite:newBatchNode(w, h)
    local start_x, end_x, start_y, end_y = self:GetLocalRegion(w, h)
    local base_node = display.newBatchNode("grass_80x80_.png", 10)
    local map = self:GetLogicMap()
    for ix = start_x, end_x do
        for iy = start_y, end_y do
            display.newSprite(base_node:getTexture()):addTo(base_node):pos(map:ConvertToLocalPosition(ix, iy)):scale(2)
        end
    end
    return base_node
end
return CitySprite




