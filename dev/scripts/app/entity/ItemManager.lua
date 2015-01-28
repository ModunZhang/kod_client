--
-- Author: Kenny Dai
-- Date: 2015-01-22 11:58:43
--
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local Item = import(".Item")
local ItemManager = class("ItemManager", MultiObserver)

ItemManager.LISTEN_TYPE = Enum("ITEM_CHANGED")

function ItemManager:ctor()
    ItemManager.super.ctor(self)
    self.items = {}
    self.items_buff = {}
    self.items_resource = {}
    self.items_special = {}
    self.items_speedUp = {}
    self:InitAllItems()
end
-- 初始化所有道具，数量 0
function ItemManager:InitAllItems()
    for k,v in pairs(GameDatas.Items) do
        if k ~= "buffTypes" then
            for item_name,item in pairs(v) do
                local item = Item.new()
                item:UpdateData(
                    {
                        name = item_name,
                        count = 0
                    }
                )
                self:InsertItem(item)
            end
        end
    end
end
function ItemManager:OnUserDataChanged(user_data)
    self:OnItemsChanged(user_data.items)
    self:__OnItemsChanged(user_data.__items)
end
function ItemManager:OnItemsChanged(items)
    if items then
        for i,v in ipairs(items) do
            local item = self:GetItemByName(v.name)
            item:SetCount(v.count)
            self:InsertItem(item)
        end
    end
end
function ItemManager:__OnItemsChanged(__items)
    if __items then
        local changed_map = GameUtils:Event_Handler_Func(
            __items
            ,function(data)
                -- add
                local item = self:GetItemByName(data.name)
                item:SetCount(data.count)
                self:InsertItem(item)
                print("__OnItemsChanged add",data.name,data.count)
                return item
            end
            ,function(data)
                -- eidt 更新
                local item = self:GetItemByName(data.name)
                item:SetCount(data.count)
                self:InsertItem(item)
                print("__OnItemsChanged edit",data.name,data.count)
                return item
            end
            ,function(data)
                -- remove
                local item = self:GetItemByName(data.name)
                self:RemoveItem(item)
                return item
            end
        )
        self:NotifyListeneOnType(ItemManager.LISTEN_TYPE.ITEM_CHANGED, function(listener)
            listener:OnItemsChanged(changed_map)
        end)
    end
end
-- 按照道具类型添加到对应table,并加入总表
function ItemManager:InsertItem(item)
    self:GetCategoryItems(item)[item:Name()] = item
    self.items[item:Name()] = item
end
function ItemManager:RemoveItem(item)
    self:GetCategoryItems(item)[item:Name()]:SetCount(0)
    self.items[item:Name()]:SetCount(0)
end
function ItemManager:GetCategoryItems(item)
    if item:Category() == Item.CATEGORY.BUFF then
        return self.items_buff
    elseif item:Category() == Item.CATEGORY.RESOURCE then
        return self.items_resource
    elseif item:Category() == Item.CATEGORY.SPECIAL then
        return self.items_special
    elseif item:Category() == Item.CATEGORY.SPEEDUP then
        return self.items_speedUp
    end
end
function ItemManager:GetItemByName(name)
    return self.items[name]
end
function ItemManager:GetSpecialItems()
    return self:__order(self.items_special)
end
function ItemManager:GetBuffItems()
    return self:__order(self.items_buff)

end
function ItemManager:GeResourcetItems()
    return self:__order(self.items_resource)
end
function ItemManager:GetSpeedUpItems()
    return self:__order(self.items_speedUp)
end
function ItemManager:__order(items)
    local found_keys = {}
    local order_items = {}
    for k,v in pairs(items) do
        local area_types = string.split(v:Name(),"_")
        if #area_types == 2 and not found_keys[area_types[1]] then
            for i=1,math.huge do
                local same_item = items[area_types[1].."_"..i]
                if same_item then
                    table.insert(order_items, same_item)
                else
                    break
                end
            end
            -- 已经找出的同类型道具，缓存类型key值，之后不再处理
            found_keys[area_types[1]] = true
        elseif #area_types == 1 then
            table.insert(order_items, v)
        end
    end
    return order_items
end
function ItemManager:GetSameTypeItems(item)
    local same_items = {}
    local find_area = self:GetCategoryItems(item)
    local area_type = string.split(item:Name(),"_")
    if #area_type == 2 then
        for i=1,math.huge do
            local same_item = find_area[area_type[1].."_"..i]
            if same_item then
                table.insert(same_items, same_item)
            else
                break
            end
        end
    end
    return same_items
end
return ItemManager








