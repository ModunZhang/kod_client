--
-- Author: Kenny Dai
-- Date: 2015-02-09 19:46:14
--
local Observer = import(".Observer")
local HelpEvent = class("HelpEvent",Observer)
local property = import("..utils.property")

function HelpEvent:ctor()
    HelpEvent.super.ctor(self)
    property(self,"id","")
    local playerData = {}
    property(playerData,"id","")
    property(playerData,"name","")
    property(playerData,"vipExp",0)
    function playerData:OnPropertyChange()
    end
    self.playerData = playerData

    local eventData = {}
    property(eventData,"type","")
    property(eventData,"id","")
    property(eventData,"name","")
    property(eventData,"level",0)
    property(eventData,"maxHelpCount",0)
    property(eventData,"helpedMembers",{})
    function eventData:OnPropertyChange()
    end
    self.eventData = eventData
end

function HelpEvent:OnPropertyChange()
end

function HelpEvent:UpdateData(json_data)
    self:SetId(json_data.id)
    local playerData = json_data.playerData
    self.playerData:SetId(playerData.id)
    self.playerData:SetName(playerData.name)
    self.playerData:SetVipExp(playerData.vipExp)
    local eventData = json_data.eventData
    self.eventData:SetType(eventData.type)
    self.eventData:SetId(eventData.id)
    self.eventData:SetName(eventData.name)
    self.eventData:SetLevel(eventData.level)
    self.eventData:SetMaxHelpCount(eventData.maxHelpCount)
    self.eventData:SetHelpedMembers(eventData.helpedMembers)
    return self
end

function HelpEvent:GetPlayerData()
    return self.playerData
end
function HelpEvent:GetEventData()
    return self.eventData
end
function HelpEvent:IsHelpedByMe()
    local _id = User:Id()
    local helpedMembers = self.eventData:HelpedMembers()
    for k,id in pairs(helpedMembers) do
        if id == _id then
            return true
        end
    end
end
return HelpEvent

