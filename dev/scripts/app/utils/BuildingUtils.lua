BuildingUtils = {}
local config_house_function = GameDatas.HouseFunction
local config_house_levelup = GameDatas.HouseLevelUp
function BuildingUtils:GetCitizenMap(userData)
	local house_citizen = {
		miner = 0,
		farmer = 0,
		quarrier = 0,
		woodcutter = 0,
	}
	for _,building in pairs(userData.buildings) do
		for _,house in pairs(building.houses) do
			local value = house_citizen[house.type]
			if value then
				local citizen = house.level == 0 and 0 or config_house_levelup[house.type][house.level].citizen
				house_citizen[house.type] = value + citizen
			end
		end
	end
	for _,event in pairs(userData.houseEvents) do
		local location_key = string.format("location_%d", event.buildingLocation)
		for _,house in pairs(userData.buildings[location_key].houses) do
			if house.location == event.houseLocation then
				local value = house_citizen[house.type]
				if value then
					local config = config_house_levelup[house.type]
					local citizen = house.level == 0 and 0 or config[house.level].citizen
					house_citizen[house.type] = value + config[house.level + 1].citizen - citizen
				end
				break
			end
		end
	end
	house_citizen.food = house_citizen.farmer 
	house_citizen.wood = house_citizen.woodcutter
	house_citizen.iron = house_citizen.miner 
	house_citizen.stone= house_citizen.quarrier 
	house_citizen.total = house_citizen.miner 
						+ house_citizen.farmer 
						+ house_citizen.quarrier 
						+ house_citizen.woodcutter
	return house_citizen
end

local warehouse_function = GameDatas.BuildingFunction.warehouse
local buildings_location = GameDatas.Buildings.buildings
local initCitizen_value = GameDatas.PlayerInitData.intInit.initCitizen.value
function BuildingUtils:GetWarehouseLimit(userData)
	local limit = {
		wood = 0,
		food = 0,
		iron = 0,
		stone= 0,
	}
	local locations = {}
	for _,building in ipairs(buildings_location) do
		if building.name == "warehouse" then
			table.insert(locations, building.location)
		end
	end
	local buildings = userData.buildings
	for _,location in ipairs(locations) do
		local location_key = string.format("location_%d", location)
		local config = warehouse_function[buildings[location_key].level]
		limit.wood = limit.wood + (config == nil and 0 or config.maxWood)
		limit.food = limit.food + (config == nil and 0 or config.maxFood)
		limit.iron = limit.iron + (config == nil and 0 or config.maxIron)
		limit.stone= limit.stone+ (config == nil and 0 or config.maxStone)
	end
	return limit
end











