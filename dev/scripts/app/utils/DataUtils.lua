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
        if type(has[key]) == "number" then
            value = value - has[key]
        end
        print("需要购买",key,value)
        for i=#payment,1,-1 do
            if value>0 then
                while payment[i].min<value do
                    value = value - payment[i].resource
                    usedGem = usedGem + payment[i].gem
                    print("买了",payment[i].resource,"花费",payment[i].gem)
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
        if type(has[key]) == "number" then
            value = value - has[key]
        end
        print(" 需要 购买 ",key,value)
        if value>0 then
	        usedGem = usedGem+payment[key]*value
	        print("买了",value,"花费",payment[key]*value)
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






