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
--如果有道具加龙属性 这里就还未完成
function DataUtils:getDragonMaxHp(star,level,skills,equipments)
    local vitality = self:getTotalVitalityFromJson(star,level,skills,equipments)
    return vitality * 2
end

-- 获取兵相关的buff信息  
-- solider_config:兵详情的配置信息
function DataUtils:getAllSoldierBuffValue(solider_config)
    local result = {}
    local soldier_type = solider_config.type
    local item_buff = ItemManager:GetAllSoldierBuffData()
    local military_technology_buff = City:GetSoldierManager():GetAllMilitaryBuffData()
    table.insertto(item_buff,military_technology_buff)
    for __,v in ipairs(item_buff) do
        local effect_soldier,buff_field,buff_value = unpack(v)
        if effect_soldier == soldier_type or effect_soldier == '*' then
            local buff_realy_value = (solider_config[buff_field] or 0 ) * buff_value
            if result[buff_field] then
                result[buff_field] = result[buff_field] + buff_realy_value
            else
                result[buff_field] = buff_realy_value
            end
        end
    end
    if ItemManager:IsBuffActived("quarterMaster") then
        local buff_realy_value = (solider_config['consumeFoodPerHour'] or 0 ) * ItemManager:GetBuffEffect("quarterMaster")
        if result['consumeFoodPerHour'] then
            result['consumeFoodPerHour'] = result['consumeFoodPerHour'] + buff_realy_value
        else
           result['consumeFoodPerHour'] = buff_realy_value
        end
    end
    return result
end
--获取建筑时间的buff
--buildingTime:升级或建造原来的时间
function DataUtils:getBuildingBuff(buildingTime)
    local tech = City:FindTechByName('crane')
    if tech and tech:Level() > 0 then
        return math.ceil(buildingTime * (1 - tech:GetBuffEffectVal()))
    else
        return 0
    end
end

local config_intInit = GameDatas.AllianceInitData.intInit
local AllianceMapSize = {
    width = config_intInit.allianceRegionMapWidth.value,
    height= config_intInit.allianceRegionMapHeight.value
}
local PlayerInitData = GameDatas.PlayerInitData
function DataUtils:getDistance(width,height)
    return math.ceil(math.sqrt(math.pow(width, 2) + math.pow(height, 2)))
end

function DataUtils:getAllianceLocationDistance(fromAllianceDoc, fromLocation, toAllianceDoc, toLocation)
    local width,height = 0,0
    if fromAllianceDoc == toAllianceDoc then
        dump(fromLocation,"fromLocation--->")
        dump(toLocation,"toLocation--->")
        width = math.abs(fromLocation.x - toLocation.x)
        height =  math.abs(fromLocation.y - toLocation.y)
        return DataUtils:getDistance(width,height)
    end
    if fromAllianceDoc:GetAllianceFight()['attackAllianceId'] == fromAllianceDoc:Id() then
        local allianceMergeStyle = fromAllianceDoc:GetAllianceFight()['mergeStyle']
        if allianceMergeStyle == 'left' then
            width = AllianceMapSize.width - fromLocation.x + toLocation.x
            height= math.abs(fromLocation.y - toLocation.y)
            return DataUtils:getDistance(width,height)
        elseif allianceMergeStyle == 'right' then
            width = AllianceMapSize.width - toLocation.x + fromLocation.x
            height= math.abs(fromLocation.y - toLocation.y)
            return DataUtils:getDistance(width,height)
        elseif allianceMergeStyle == 'top' then
            width = math.abs(fromLocation.x - toLocation.x)
            height= AllianceMapSize.height - fromLocation.y + toLocation.y
            return DataUtils:getDistance(width,height)
        elseif allianceMergeStyle == 'bottom' then
            width = math.abs(fromLocation.x - toLocation.x)
            height= AllianceMapSize.height - toLocation.y + fromLocation.y
            return DataUtils:getDistance(width,height)
        else
            return 0
        end
    else
        local allianceMergeStyle = fromAllianceDoc:GetAllianceFight()['mergeStyle']
        if allianceMergeStyle == 'left' then
            width = AllianceMapSize.width - toLocation.x + fromLocation.x
            height = math.abs(fromLocation.y - toLocation.y)
            return DataUtils:getDistance(width,height)
        elseif allianceMergeStyle == 'right' then
            width = AllianceMapSize.width - fromLocation.x + toLocation.x
            height = math.abs(fromLocation.y - toLocation.y)
            return DataUtils:getDistance(width,height)
        elseif allianceMergeStyle == 'top' then
            width = math.abs(fromLocation.x - toLocation.x)
            height = AllianceMapSize.height - toLocation.y + fromLocation.y
            return DataUtils:getDistance(width,height)
        elseif allianceMergeStyle == 'bottom' then
            width = math.abs(fromLocation.x - toLocation.x)
            height = AllianceMapSize.height - fromLocation.y + toLocation.y
            return DataUtils:getDistance(width,height)
        else
            return 0
        end
    end
end
--[[ 
    -->
    math.ceil(DataUtils:getPlayerSoldiersMarchTime(...) * (1 - DataUtils:getPlayerMarchTimeBuffEffectValue()))
    ---> 行军的真实时间
]]--
--获取攻击行军总时间
function DataUtils:getPlayerSoldiersMarchTime(soldiers,fromAllianceDoc, fromLocation, toAllianceDoc, toLocation)
    local distance = DataUtils:getAllianceLocationDistance(fromAllianceDoc, fromLocation, toAllianceDoc, toLocation)
    local baseSpeed,totalSpeed,totalCitizen = 2400,0,0
    for __,soldier_info in ipairs(soldiers) do
        totalCitizen = totalCitizen + soldier_info.soldier_citizen
        totalSpeed = totalSpeed + baseSpeed / soldier_info.soldier_march * soldier_info.soldier_citizen
    end
    return math.ceil(totalSpeed / totalCitizen * distance)
end

function DataUtils:getPlayerMarchTimeBuffEffectValue()
    if ItemManager:IsBuffActived("marchSpeedBonus") then
        return ItemManager:GetBuffEffect("marchSpeedBonus")
    end
    return 0
end
--获取攻击行军的buff时间
function DataUtils:getPlayerMarchTimeBuffTime(fullTime)
    local buff_value = DataUtils:getPlayerMarchTimeBuffEffectValue()
    if buff_value > 0 then
        return  math.ceil(fullTime * (1 - buff_value))
    else
        return 0
    end
end
--TODO:界面上添加
--获得龙的行军时间（突袭）
function DataUtils:getPlayerDragonMarchTime(fromAllianceDoc, fromLocation, toAllianceDoc, toLocation)
    local distance = DataUtils:getAllianceLocationDistance(fromAllianceDoc, fromLocation, toAllianceDoc, toLocation)
    local baseSpeed = 2400 
    local marchSpeed = PlayerInitData.intInit.dragonMarchSpeed.value
    local time = math.ceil(baseSpeed / marchSpeed * distance)
    return time
end
--获取科技升级的buff时间
local config_academy = GameDatas.BuildingFunction.academy
function DataUtils:getTechnilogyUpgradeBuffTime(time)
    local academy = City:GetFirstBuildingByType("academy")
    local level = academy:GetLevel()
    local config = config_academy[level]
    local efficiency = config and config.efficiency or 0 
    if efficiency > 0 then
        return math.ceil(time/(1 + efficiency))
    else
        return 0
    end
end
--获取兵种招募的buff时间
local config_BuildingFunction = GameDatas.BuildingFunction
function DataUtils:getSoldierRecruitBuffTime(soldier_type,time)
    local soldier_type_map_building = {
        infantry = "trainingGround",
        cavalry = "stable",
        archer = "hunterHall",
        siege = "workshop"
    }
    local building_type = soldier_type_map_building[soldier_type]
    if not time or not building_type then
        return 0
    end
    local build = City:GetFirstBuildingByType(building_type)
    if not build then return 0 end
    local config = config_BuildingFunction[building_type][build:GetLevel()]
    local efficiency = config.efficiency
    if efficiency > 0 then
        return math.ceil(time/(1 + efficiency)) 
    else
        return 0
    end
end