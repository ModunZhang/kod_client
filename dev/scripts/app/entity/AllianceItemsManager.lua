--
-- Author: Kenny Dai
-- Date: 2015-01-30 15:03:56
--
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local Item = import(".Item")
local AllianceItemsManager = class("AllianceItemsManager", MultiObserver)

AllianceItemsManager.LISTEN_TYPE = Enum("ITEM_CHANGED","OnItemEventTimer")

function AllianceItemsManager:ctor()
    AllianceItemsManager.super.ctor(self)
    self.items = {}
    self.items_buff = {}
    self.items_resource = {}
    self.items_special = {}
    self.items_speedUp = {}
    self:InitAllItems()
end
-- 初始化所有道具，数量 0
function AllianceItemsManager:InitAllItems()
    for k,v in pairs(GameDatas.Items) do
        if k ~= "buffTypes" then
            for item_name,item in pairs(v) do
                if item.isSellInAlliance then
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
end

function AllianceItemsManager:OnItemsChanged(items)
    if items then
        for i,v in ipairs(items) do
            local item = self:GetItemByName(v.name)
            item:SetCount(v.count)
            self:InsertItem(item)
        end
    end
end
function AllianceItemsManager:__OnItemsChanged(__items)
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
        self:NotifyListeneOnType(AllianceItemsManager.LISTEN_TYPE.ITEM_CHANGED, function(listener)
            listener:OnItemsChanged(changed_map)
        end)
    end
end

-- 按照道具类型添加到对应table,并加入总表
function AllianceItemsManager:InsertItem(item)
    self:GetCategoryItems(item)[item:Name()] = item
    self.items[item:Name()] = item
end
function AllianceItemsManager:RemoveItem(item)
    self:GetCategoryItems(item)[item:Name()]:SetCount(0)
    self.items[item:Name()]:SetCount(0)
end
function AllianceItemsManager:GetCategoryItems(item)
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
function AllianceItemsManager:GetItemByName(name)
    return self.items[name]
end
function AllianceItemsManager:GetSpecialItems()
    return self:__order(self.items_special)
end
function AllianceItemsManager:GetBuffItems()
    return self:__order(self.items_buff)

end
function AllianceItemsManager:GetResourcetItems()
    return self:__order(self.items_resource)
end
function AllianceItemsManager:GetSpeedUpItems()
    return self:__order(self.items_speedUp)
end

function AllianceItemsManager:__order(items)
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

return AllianceItemsManager