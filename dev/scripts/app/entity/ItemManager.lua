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
                return item
            end
            ,function(data)
                -- eidt 更新
                local item = self:GetItemByName(data.name)
                item:SetCount(data.count)
                self:InsertItem(item)
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
            listener:OnUserDataChanged(changed_map)
        end)
    end
end
-- 按照道具类型添加到对应table,并加入总表
function ItemManager:InsertItem(item)
    if item:Category() == Item.CATEGORY.BUFF then
        self.items_buff[item:Name()] = item
    elseif item:Category() == Item.CATEGORY.RESOURCE then
        self.items_resource[item:Name()] = item
    elseif item:Category() == Item.CATEGORY.SPECIAL then
        self.items_special[item:Name()] = item
    elseif item:Category() == Item.CATEGORY.SPEEDUP then
        self.items_speedUp[item:Name()] = item
    end
    self.items[item:Name()] = item
end
function ItemManager:RemoveItem(item)
    if item:Category() == Item.CATEGORY.BUFF then
        self.items_buff[item:Name()]:SetCount(0)
    elseif item:Category() == Item.CATEGORY.RESOURCE then
        self.items_resource[item:Name()]:SetCount(0)
    elseif item:Category() == Item.CATEGORY.SPECIAL then
        self.items_special[item:Name()]:SetCount(0)
    elseif item:Category() == Item.CATEGORY.SPEEDUP then
        self.items_speedUp[item:Name()]:SetCount(0)
    end
    self.items[item:Name()]:SetCount(0)
end
function ItemManager:GetItemByName(name)
    return self.items[name]
end

return ItemManager