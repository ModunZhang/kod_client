--
-- Author: Kenny Dai
-- Date: 2015-02-11 11:13:18
--
local WidgetSpeedUp = import("..widget.WidgetSpeedUp")
local SoldierManager = import("..entity.SoldierManager")
local Localize = import("..utils.Localize")
local GameUIBuildingSpeedUp = class("GameUIBuildingSpeedUp",WidgetSpeedUp)

function GameUIBuildingSpeedUp:ctor(building)
    GameUIBuildingSpeedUp.super.ctor(self)
    self.building = building
    self:SetAccBtnsGroup(self:GetEventType(),building:UniqueUpgradingKey())
    self:SetAccTips(_("小于5min时可以使用免费加速"))
    self:SetUpgradeTip(string.format(_("正在升级 %s 到等级 %d"),Localize.getBuildingLocalizedKeyByBuildingType(building:GetType()),building:GetLevel()+1))
    self:CheckCanSpeedUpFree()
    self:OnFreeButtonClicked(handler(self, self.FreeSpeedUpAction))
    building:AddUpgradeListener(self)
end
function GameUIBuildingSpeedUp:GetEventType()
    local building = self.building
    local city = City
    local eventType = city:IsHouse(self.building) and "houseEvents" or "buildingEvents"
    return eventType
end
function GameUIBuildingSpeedUp:FreeSpeedUpAction()
    NetManager:getFreeSpeedUpPromise(self:GetEventType(),self.building:UniqueUpgradingKey()):next(function()
        self:leftButtonClicked()
    end)
end

function GameUIBuildingSpeedUp:onCleanup()
    self.building:RemoveUpgradeListener(self)
end

function GameUIBuildingSpeedUp:OnMilitaryTechEventsTimer(event)
    if self.progress and event:Id() == self.militaryEvent:Id() then
        self:SetProgressInfo(GameUtils:formatTimeStyle1(event:GetTime()),event:Percent())
        self:CheckCanSpeedUpFree()
    end
end

function GameUIBuildingSpeedUp:CheckCanSpeedUpFree()
    self:SetFreeButtonEnabled(self.building:GetUpgradingLeftTimeByCurrentTime(app.timer:GetServerTime()) <= DataUtils:getFreeSpeedUpLimitTime())
end
function GameUIBuildingSpeedUp:OnBuildingUpgradingBegin( building, current_time )
    self:SetProgressInfo(GameUtils:formatTimeStyle1(building:GetUpgradingLeftTimeByCurrentTime(current_time)),building:GetElapsedTimeByCurrentTime(current_time)/building:GetUpgradeTimeToNextLevel()*100)
end
function GameUIBuildingSpeedUp:OnBuildingUpgradeFinished( building, finish_time )
    self:leftButtonClicked()
end
function GameUIBuildingSpeedUp:OnBuildingUpgrading( building, current_time )
    self:SetProgressInfo(GameUtils:formatTimeStyle1(building:GetUpgradingLeftTimeByCurrentTime(current_time)),building:GetElapsedTimeByCurrentTime(current_time)/building:GetUpgradeTimeToNextLevel()*100)
end
return GameUIBuildingSpeedUp




