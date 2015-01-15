--
-- Author: Kenny Dai
-- Date: 2015-01-13 17:05:03
--
local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local TradeManager = class("TradeManager", MultiObserver)

TradeManager.LISTEN_TYPE = Enum("MY_DEAL_REFRESH","DEAL_CHANGED")

function TradeManager:ctor()
    TradeManager.super.ctor(self)
    self.my_deals = {}
end
function TradeManager:GetMyDeals()
    return self.my_deals
end
function TradeManager:OnUserDataChanged(user_data)
    local deals = user_data.deals
    if deals then
        self.my_deals = {}
        for k,v in pairs(deals) do
            table.insert(self.my_deals, v)
        end
        self:NotifyListeneOnType(TradeManager.LISTEN_TYPE.MY_DEAL_REFRESH, function(listener)
            listener:OnMyDealsRefresh({
                add=add,
                edit=edit,
                remove=remove,
            })
        end)
    end

    local __deals = user_data.__deals
    local add = {}
    local edit = {}
    local remove = {}
    if __deals then
        for k,v in pairs(__deals) do
            if v.type == "add" then
                table.insert(self.my_deals, v.data)
                table.insert(add, v.data)
            end
            if v.type == "edit" then
                for index,myDeal in pairs(self.my_deals) do
                    if myDeal.id == v.data.id then
                        self.my_deals[index] = v.data
                    end
                end
                table.insert(edit,v.data)
            end
            if v.type == "remove" then
                for index,myDeal in pairs(self.my_deals) do
                    if myDeal.id == v.data.id then
                        self.my_deals[index] = nil
                    end
                end
                table.insert(remove,v.data)
            end
        end
        self:NotifyListeneOnType(TradeManager.LISTEN_TYPE.DEAL_CHANGED, function(listener)
            listener:OnDealChanged(
                {
                    add=add,
                    edit=edit,
                    remove=remove,
                }
            )
        end)
    end
end

return TradeManager





