--
-- Author: Kenny Dai
-- Date: 2015-02-11 11:13:18
--
local WidgetSpeedUp = import("..widget.WidgetSpeedUp")
local SoldierManager = import("..entity.SoldierManager")
local Localize = import("..utils.Localize")
local GameUIBuildingSpeedUp = class("GameUIBuildingSpeedUp",WidgetSpeedUp)
local GameUtils = GameUtils
local DataUtils = DataUtils
local timer = app.timer

function GameUIBuildingSpeedUp:ctor(building)
    GameUIBuildingSpeedUp.super.ctor(self)
    self.building = building
    self:SetAccBtnsGroup(building:EventType(),building:UniqueUpgradingKey())
    self:SetUpgradeTip(string.format(_("正在升级 %s 到等级 %d"),Localize.getBuildingLocalizedKeyByBuildingType(building:GetType()),building:GetLevel()+1))
    self:CheckCanSpeedUpFree()
    self:OnFreeButtonClicked(handler(self, self.FreeSpeedUpAction))
    building:AddUpgradeListener(self)
end
function GameUIBuildingSpeedUp:FreeSpeedUpAction()
    local event_type = self.building:EventType()
    local unique_key = self.building:UniqueUpgradingKey()
    self:leftButtonClicked()
    NetManager:getFreeSpeedUpPromise(event_type,unique_key)
end
function GameUIBuildingSpeedUp:onExit()
    GameUIBuildingSpeedUp.super.onExit(self)
    self.building:RemoveUpgradeListener(self)
    GameUIBuildingSpeedUp.super.onCleanup(self)
end

function GameUIBuildingSpeedUp:CheckCanSpeedUpFree()
    self:SetFreeButtonEnabled(self.building:GetUpgradingLeftTimeByCurrentTime(timer:GetServerTime()) <= DataUtils:getFreeSpeedUpLimitTime())
end
function GameUIBuildingSpeedUp:OnBuildingUpgradingBegin( building, current_time )
    self:SetProgressInfo(GameUtils:formatTimeStyle1(building:GetUpgradingLeftTimeByCurrentTime(current_time)),building:GetElapsedTimeByCurrentTime(current_time)/building:GetUpgradeTimeToNextLevel()*100)
end
function GameUIBuildingSpeedUp:OnBuildingUpgradeFinished( building )
    self:leftButtonClicked()
end
function GameUIBuildingSpeedUp:OnBuildingUpgrading( building, current_time )
    self:SetProgressInfo(GameUtils:formatTimeStyle1(building:GetUpgradingLeftTimeByCurrentTime(current_time)),building:GetElapsedTimeByCurrentTime(current_time)/building:GetUpgradeTimeToNextLevel()*100)
    self:CheckCanSpeedUpFree()
end
return GameUIBuildingSpeedUp




