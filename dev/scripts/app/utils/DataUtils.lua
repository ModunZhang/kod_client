local BuildingLevelUp = GameDatas.BuildingLevelUp
local GemsPayment = GameDatas.GemsPayment
local HouseLevelUp = GameDatas.HouseLevelUp

DataUtils = {}

--[[
  获取建筑升级时,需要的资源和道具
]]
function DataUtils:getBuildingUpgradeRequired(buildingType, buildingLevel)
    local config = BuildingLevelUp[buildingType][buildingLevel]
    local required = {
        resources={
            wood=config.wood,
            stone=config.stone,
            iron=config.iron,
            citizen=config.citizen
        },
        materials={
            blueprints=config.blueprints,
            tools=config.tools,
            tiles=config.tiles,
            pulley=config.pulley
        },
        buildTime=config.buildTime
    }
    return required
end
--[[
  获取house升级时,需要的资源和道具
]]
function DataUtils:getHouseUpgradeRequired(buildingType, buildingLevel)
    local config = HouseLevelUp[buildingType][buildingLevel]
    local required = {
        resources={
            wood=config.wood,
            stone=config.stone,
            iron=config.iron,
            citizen=config.citizen
        },
        materials={
            blueprints=config.blueprints,
            tools=config.tools,
            tiles=config.tiles,
            pulley=config.pulley
        },
        buildTime=config.buildTime
    }
    return required
end
--[[
  购买资源
  @param need
  @param has
]]
function DataUtils:buyResource(need, has)
    local usedGem = 0
    table.foreach(need,function( key,value )
        local payment = GemsPayment[key]
        if payment then
            if type(has[key]) == "number" then
                value = value - has[key]
            end
            -- print("需要购买",key,value)
            for i=#payment,1,-1 do
                if value>0 then
                    while payment[i].min<value do
                        value = value - payment[i].resource
                        usedGem = usedGem + payment[i].gem
                        -- print("买了",payment[i].resource,"花费",payment[i].gem)
                    end
                end
            end
        end
    end)
    return usedGem
end

--[[
  购买材料
  @param need
  @param has
]]
function DataUtils:buyMaterial(need, has)
    local usedGem = 0
    table.foreach(need,function( key,value )
        local payment = GemsPayment.material[1]
        if has then
            if type(has[key]) == "number" then
                value = value - has[key]
            end
        end
        -- print(" 需要 购买 ",key,value)
        if value>0 then
            usedGem = usedGem+payment[key]*value
            -- print("买了",value,"花费",payment[key]*value)
        end
    end)
    return usedGem
end

--[[
  根据所缺时间换算成宝石,并返回宝石数量
  @param interval
  @returns {number}
]]
function DataUtils:getGemByTimeInterval(interval)
    local gem = 0
    local config = GemsPayment.time
    while interval > 0 do
        for i = #config,1,-1 do
            while config[i].min<interval do
                interval = interval - config[i].speedup
                gem = gem + config[i].gem
            end
        end
    end
    return gem
end
--龙相关计算
local config_dragonAttribute = GameDatas.Dragons.dragonAttributes
local config_dragonSkill = GameDatas.Dragons.dragonSkills
local config_equipments = GameDatas.DragonEquipments.equipments
local config_dragoneyrie = GameDatas.DragonEquipments

function DataUtils:getDragonTotalStrengthFromJson(star,level,skills,equipments)
    local strength,__ = self:getDragonBaseStrengthAndVitality(star,level)
    local buff = self:__getDragonStrengthBuff(skills)
    strength = strength + math.floor(strength * buff)
    for body,equipemt in pairs(equipments) do
        if equipemt.name ~= "" then
            local config = self:getDragonEquipmentConfig(equipemt.name)
            local attribute = self:getDragonEquipmentAttribute(body,config.maxStar,equipemt.star)
            strength = attribute and (strength + attribute.strength) or strength
        end
    end
    return strength
end

function DataUtils:getTotalVitalityFromJson(star,level,skills,equipments)
    local __,vitality = self:getDragonBaseStrengthAndVitality(star,level)
    local buff = self:__getDragonVitalityBuff(skills)
    vitality = vitality + math.floor(vitality * buff)
    for body,equipemt in pairs(equipments) do
        if equipemt.name ~= "" then
            local config = self:getDragonEquipmentConfig(equipemt.name)
            local attribute = self:getDragonEquipmentAttribute(body,config.maxStar,equipemt.star)
            vitality = attribute and (vitality + attribute.vitality) or vitality
        end
    end
    return vitality
end

function DataUtils:getDragonSkillEffect(skillName,level)
    level = checkint(level)
    if config_dragonSkill[skillName] then
        return level * config_dragonSkill[skillName].effectPerLevel
    end
    return 0
end

function DataUtils:getDragonBaseStrengthAndVitality(star,level)
    star = checkint(star)
    level = checkint(level)
    return config_dragonAttribute[star].initStrength + level * config_dragonAttribute[star].perLevelStrength,
        config_dragonAttribute[star].initVitality + level * config_dragonAttribute[star].perLevelVitality 
end

function DataUtils:getDragonEquipmentAttribute(body,max_star,star)
    return config_dragoneyrie[body][max_star .. "_" .. star]
end

function DataUtils:getDragonEquipmentConfig(name)
    return config_equipments[name]
end

function DataUtils:__getDragonStrengthBuff(skills)
    for __,v in pairs(skills) do
        if v.name == 'dragonBreath' then
            return self:getDragonSkillEffect(v.name,v.level)
        end
    end
    return 0
end

function DataUtils:__getDragonVitalityBuff(skills)
    for __,v in pairs(skills) do
        if v.name == 'dragonBlood' then
            return self:getDragonSkillEffect(v.name,v.level)
        end
    end
    return 0
end
--TODO:如果有道具加龙属性 这里就还未完成
function DataUtils:getDragonMaxHp(star,level,skills,equipments)
    local vitality = self:getTotalVitalityFromJson(star,level,skills,equipments)
    return vitality * 2
end
