local UILib = import("..ui.UILib")
local Localize = import("..utils.Localize")
local SpriteConfig = import(".SpriteConfig")
local WithInfoSprite = import(".WithInfoSprite")
local MonsterSprite = class("MonsterSprite", WithInfoSprite)

local monsterConfig = GameDatas.AllianceInitData.monster
local soldier_config = {
    ["swordsman"] = {
        {"heihua_bubing_2"},
        {"heihua_bubing_2"},
        {"heihua_bubing_3"},
    },
    ["ranger"] = {
        {"heihua_gongjianshou_2"},
        {"heihua_gongjianshou_2"},
        {"heihua_gongjianshou_3"},
    },
    ["lancer"] = {
        {"heihua_qibing_2"},
        {"heihua_qibing_2"},
        {"heihua_qibing_3"},
    },
    ["catapult"] = {
        {"heihua_toushiche_2"},
        {"heihua_toushiche_2"},
        {"heihua_toushiche_3"},
    },

    -----
    ["sentinel"] = {
        {"heihua_shaobing_2"},
        {"heihua_shaobing_2"},
        {"heihua_shaobing_3"},
    },
    ["crossbowman"] = {
        {"heihua_nugongshou_2"},
        {"heihua_nugongshou_2"},
        {"heihua_nugongshou_3"},
    },
    ["horseArcher"] = {
        {"heihua_youqibing_2"},
        {"heihua_youqibing_2"},
        {"heihua_youqibing_3"},
    },
    ["ballista"] = {
        {"heihua_nuche_2"},
        {"heihua_nuche_2"},
        {"heihua_nuche_3"},
    },


    ["skeletonWarrior"] = {
        {"kulouyongshi"},
        {"kulouyongshi"},
        {"kulouyongshi"},
    },
    ["skeletonArcher"] = {
        {"kulousheshou"},
        {"kulousheshou"},
        {"kulousheshou"},
    },
    ["deathKnight"] = {
        {"siwangqishi"},
        {"siwangqishi"},
        {"siwangqishi"},
    },
    ["meatWagon"] = {
        {"jiaorouche"},
        {"jiaorouche"},
        {"jiaorouche"},
    },
}


function MonsterSprite:ctor(city_layer, entity, is_my_alliance)
    self.entity = entity
    MonsterSprite.super.ctor(self, city_layer, entity, is_my_alliance)
end
function MonsterSprite:CreateSprite()
    local soldier_type, star = unpack(string.split(self:GetConfig().icon, '_'))
    local ani = unpack(soldier_config[soldier_type][tonumber(star)])
    -- ani = "heihua_bubing_2"
    local sprite = ccs.Armature:create(ani)
    sprite:getAnimation():play("idle_45")
    sprite:align(display.CENTER)
    return sprite
end
function MonsterSprite:GetInfo()
    local soldier_type, star = unpack(string.split(self:GetConfig().icon, '_'))
    return 1, Localize.soldier_name[soldier_type]
end
function MonsterSprite:GetConfig()
    print(self:GetEntity())
    print(self:GetEntity():GetAllianceMonsterInfo())
    return monsterConfig[self:GetEntity():GetAllianceMonsterInfo().level]
end
function MonsterSprite:Flash(time)
    self:GetSprite():stopAllActions()
    self:GetSprite():runAction(transition.sequence{
        cc.ScaleTo:create(time/2, 1.2),
        cc.ScaleTo:create(time/2, 1)
    })
end




---
function MonsterSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
function MonsterSprite:newBatchNode(w, h)
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
return MonsterSprite