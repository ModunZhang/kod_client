UtilsForItem = {}

function UtilsForItem:GetItemEventTime(itemEvent)
    return math.ceil(itemEvent.finishTime/1000 - app.timer:GetServerTime())
end

local Localize_item = import(".Localize_item")
function UtilsForItem:GetItemLocalize(item_name)
    return Localize_item.item_name[item_name]
end
function UtilsForItem:GetItemDesc(item_name)
    return Localize_item.item_desc[item_name]
end
local config_items_buff     = GameDatas.Items.buff
local config_items_resource = GameDatas.Items.resource
local config_items_speedup  = GameDatas.Items.speedup
local config_items_special  = GameDatas.Items.special
function UtilsForItem:GetItemInfoByName(item_name)
    local config = config_items_buff[item_name] 
                or config_items_resource[item_name] 
                or config_items_speedup[item_name] 
                or config_items_special[item_name]
    assert(config)
    return config
end
function UtilsForItem:IsBuffItem(item_name)
    return config_items_buff[item_name] 
end
function UtilsForItem:IsResourceItem(item_name)
    return config_items_resource[item_name] 
end
function UtilsForItem:IsSpeedUpItem(item_name)
    return config_items_speedup[item_name] 
end
function UtilsForItem:IsSpecialItem(item_name)
    return config_items_special[item_name]
end
function UtilsForItem:GetBuffItemsInfo()
    local t = {}
    for _,v in pairs(config_items_buff) do
        table.insert(t, v)
    end
    return self:__order(t)
end
function UtilsForItem:GetResourcetItemsInfo()
    local t = {}
    for _,v in pairs(config_items_resource) do
        table.insert(t, v)
    end
    return self:__order(t)
end
function UtilsForItem:GetSpeedUpItemsInfo()
    local t = {}
    for _,v in pairs(config_items_speedup) do
        table.insert(t, v)
    end
    return self:__order(t)
end
function UtilsForItem:GetSpecialItemsInfo()
    local t = {}
    for _,v in pairs(config_items_special) do
        table.insert(t, v)
    end
    return self:__order(t)
end
function UtilsForItem:__order(items_info)
    local order_items_info = {}
    for k,v in pairs(items_info) do
        table.insert(order_items_info, v)
    end
    table.sort(order_items_info,function ( a,b )
        return a.order < b.order
    end)
    return order_items_info
end
function UtilsForItem:GetItemCount(items, name)
    for k,v in pairs(items) do
        if v.name == name then
            return v.count
        end
    end
    return 0
end

local buffTypes = GameDatas.Items.buffTypes
function UtilsForItem:GetItemBuff(type)
    return buffTypes[type].effect1 , buffTypes[type].effect2
end


local resource_buff_key = {
    woodBonus   = {"wood"   ,"product"},
    stoneBonus  = {"stone"  ,"product"},
    ironBonus   = {"iron"   ,"product"},
    foodBonus   = {"food"   ,"product"},
    coinBonus   = {"coin"   ,"product"},
    citizenBonus= {"citizen","product"},
}
function UtilsForItem:GetAllResourceBuffData(userData)
    local all_resource_buff = {}
    for _,v in pairs(userData.itemEvents) do
        if resource_buff_key[v.type] then
            local res_type,buff_type = unpack(resource_buff_key[v.type])
            local buff_value = self:GetItemBuff(v.type)
            table.insert(all_resource_buff,{res_type,buff_type,buff_value})
        end
    end
    return all_resource_buff
end

local soldier_buff_key = {
    marchSpeedBonus = 			   "*_march",
    unitHpBonus 	= 				  "*_hp",
    infantryAtkBonus= 			"*_infantry",
    archerAtkBonus 	= 			  "*_archer",
    cavalryAtkBonus = 			 "*_cavalry",
    siegeAtkBonus 	= 			   "*_siege",
    quarterMaster 	= "*_consumeFoodPerHour",
}
function UtilsForItem:GetAllSoldierBuffData(userData)
    local all_soldier_buff = {}
    for _,v in pairs(userData.itemEvents) do
        if soldier_buff_key[v.type] then
            local effect_soldier,buff_field = unpack(string.split(soldier_buff_key[v.type],"_"))
            local buff_value = self:GetItemBuff(v.type)
            table.insert(all_soldier_buff,{effect_soldier,buff_field,buff_value})
        end
    end
    return all_soldier_buff
end

function UtilsForItem:GetAllCityBuffTypes()
    return {
        "masterOfDefender",
        "quarterMaster",
        "fogOfTrick",
        "woodBonus",
        "stoneBonus",
        "ironBonus",
        "foodBonus",
        "coinBonus",
        "citizenBonus",
    }
end
function UtilsForItem:GetAllWarBuffTypes()
    return {
        "dragonExpBonus",
        "troopSizeBonus",
        "dragonHpBonus",
        "marchSpeedBonus",
        "unitHpBonus",
        "infantryAtkBonus",
        "archerAtkBonus",
        "cavalryAtkBonus",
        "siegeAtkBonus",
    }
end




