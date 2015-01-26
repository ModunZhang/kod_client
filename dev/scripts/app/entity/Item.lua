--
-- Author: Kenny Dai
-- Date: 2015-01-22 12:07:37
--
local ITEMS = GameDatas.Items
local BUFF = ITEMS.buff
local RESOURCE = ITEMS.resource
local SPECIAL = ITEMS.special
local SPEEDUP = ITEMS.speedup
local Enum = import("..utils.Enum")
local Localize_item = import("..utils.Localize_item")

local Item = class("Item")
local property = import("..utils.property")
Item.CATEGORY = Enum("BUFF",
    "RESOURCE",
    "SPECIAL",
    "SPEEDUP")



local function get_config(name)
    if BUFF[name] then
        return BUFF
    elseif RESOURCE[name] then
        return RESOURCE
    elseif SPECIAL[name] then
        return SPECIAL
    elseif SPEEDUP[name] then
        return SPEEDUP
    end
end

local function get_category(name)
    if BUFF[name] then
        return Item.CATEGORY.BUFF
    elseif RESOURCE[name] then
        return Item.CATEGORY.RESOURCE
    elseif SPECIAL[name] then
        return Item.CATEGORY.SPECIAL
    elseif SPEEDUP[name] then
        return Item.CATEGORY.SPEEDUP
    end
end

function Item:ctor()
    property(self,"name","")
    property(self,"category","")
    property(self,"buffType","")
    property(self,"count",0)
    property(self,"effect",0)
    property(self,"order",0)
    property(self,"isSell",0)
    property(self,"price",0)
    property(self,"isSellInAlliance",false)
    property(self,"priceInAlliance",0)
end

function Item:UpdateData(json_data)
    local name = json_data.name
    self:SetName(name)
    self:SetCount(json_data.count)
    local config = get_config(name)
    local category = get_category(name)
    self:SetCategory(category)
    self:SetEffect(config.effect)
    self:SetOrder(config.order)
    self:SetIsSell(config.isSell)
    self:SetPrice(config.price)
    self:SetIsSellInAlliance(config.isSellInAlliance)
    self:SetPriceInAlliance(config.priceInAlliance)
    if category == Item.CATEGORY.BUFF then
    	self:SetBuffType(config.type)
    end
end
function Item:GetLocalizeName()
	return Localize_item.item_name[self.name]
end
function Item:GetLocalizeDesc()
	return Localize_item.item_desc[self.name]
end
function Item:OnPropertyChange()
end

return Item


