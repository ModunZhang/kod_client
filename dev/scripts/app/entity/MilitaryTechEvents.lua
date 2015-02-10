--
-- Author: Kenny Dai
-- Date: 2015-02-10 15:01:34
--
local Observer = import(".Observer")
local Localize = import("..utils.Localize")
local MilitaryTechEvents = class("MilitaryTechEvents",Observer)
local property = import("..utils.property")

function MilitaryTechEvents:ctor()
    MilitaryTechEvents.super.ctor(self)
    property(self,"id","")
    property(self,"name","")
    property(self,"startTime",0)
    property(self,"finishTime",0)
end

function MilitaryTechEvents:OnPropertyChange()
end

function MilitaryTechEvents:UpdateData(json_data)
    self:SetId(json_data.id or "")
    self:SetName(json_data.name or  "")
    self:SetStartTime(json_data.startTime/1000 or 0)
    self:SetFinishTime(json_data.finishTime/1000 or 0)
end

function MilitaryTechEvents:Reset()
    self:RemoveAllObserver()
end

function MilitaryTechEvents:OnTimer(current_time)
    self.times_ = math.ceil(self:FinishTime() - current_time)
    if self.times_ >= 0 then
        self:NotifyObservers(function(listener)
            listener:OnMilitaryTechEventsTimer(self)
        end)
    end
end
function MilitaryTechEvents:Percent(current_time)
    local start_time = self:StartTime()
    local elapse_time = current_time - start_time
    local total_time = self.finishTime - start_time
    return elapse_time * 100.0 / total_time
end
function MilitaryTechEvents:GetTime()
    return self.times_ or 0
end
function MilitaryTechEvents:GetLocalizeDesc()
    local name = self.name
    local level = City:GetSoldierManager():GetMilitaryTechsLevelByName(name)
    return string.format(_("研发%s对%s的攻击到 Lv %d"),Localize.soldier_category[string.split(name, "_")[1]],Localize.soldier_category[string.split(name, "_")[2]],level+1)
end
function MilitaryTechEvents:GetEventType()
    return "militaryTechEvents"
end
return MilitaryTechEvents

