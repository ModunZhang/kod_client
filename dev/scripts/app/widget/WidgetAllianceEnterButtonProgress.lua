--
-- Author: Kenny Dai
-- Date: 2015-03-28 11:11:27
--
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local WidgetAllianceEnterButtonProgress = class("WidgetAllianceEnterButtonProgress", function ()
    return display.newProgressTimer("progress_bg_116x89.png", display.PROGRESS_TIMER_RADIAL)
end)
function WidgetAllianceEnterButtonProgress:ctor()
    self:setNodeEventEnabled(true)
    self:setRotationSkewY(180)
end
function WidgetAllianceEnterButtonProgress:OnTimer()
    local current_time = app.timer:GetServerTime()
    local my_allaince = Alliance_Manager:GetMyAlliance()
    local status = my_allaince:Status()
    if status == "prepare" then
        local statusStartTime = math.floor(my_allaince:StatusStartTime()/1000)
        local statusFinishTime = math.floor(my_allaince:StatusFinishTime()/1000)

        local percent = math.floor((statusFinishTime-current_time)/(statusFinishTime-statusStartTime)*100)
        self:setPercentage(percent)

        if statusFinishTime>current_time then
            self.time_label:setString(GameUtils:formatTimeStyle1(statusFinishTime-current_time))
        end
        if percent<=0 then
            self:removeFromParent()
        end
    end
end
function WidgetAllianceEnterButtonProgress:onEnter()
    local my_allaince = Alliance_Manager:GetMyAlliance()
    local status = my_allaince:Status()
    if status == "prepare" then
        local statusStartTime = math.floor(my_allaince:StatusStartTime()/1000)
        local statusFinishTime = math.floor(my_allaince:StatusFinishTime()/1000)

        local percent = math.floor((statusFinishTime-app.timer:GetServerTime())/(statusFinishTime-statusStartTime)*100)
        self:setPercentage(percent)
        self.time_label = UIKit:ttfLabel(
            {
                text = GameUtils:formatTimeStyle1(statusFinishTime-app.timer:GetServerTime()),
                size = 20,
                color = 0x7e0000
            }):align(display.CENTER, 58, 64)
            :addTo(self)
        self.time_label:setRotationSkewY(180)
        self.handle = scheduler.scheduleGlobal(handler(self, self.OnTimer), 1.0, false)

    end
end
function WidgetAllianceEnterButtonProgress:onExit()
    if self.handle then
        scheduler.unscheduleGlobal(self.handle)
        self.handle = nil
    end
end
return WidgetAllianceEnterButtonProgress







