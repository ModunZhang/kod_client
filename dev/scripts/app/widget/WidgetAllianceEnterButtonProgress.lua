--
-- Author: Kenny Dai
-- Date: 2015-03-28 11:11:27
--
local WidgetAllianceEnterButtonProgress = class("WidgetAllianceEnterButtonProgress", function ()
    local progress =display.newProgressTimer("progress_bg_116x89.png", display.PROGRESS_TIMER_RADIAL)
    progress:setRotationSkewY(180)
    local my_allaince = Alliance_Manager:GetMyAlliance()
    local status = my_allaince:Status()
    if status == "prepare" then
        local statusStartTime = math.floor(my_allaince:StatusStartTime()/1000)
        local statusFinishTime = math.floor(my_allaince:StatusFinishTime()/1000)

        local percent = math.floor((statusFinishTime-app.timer:GetServerTime())/(statusFinishTime-statusStartTime)*100)
        progress:setPercentage(percent)
    end
    app.timer:AddListener(progress)
    progress:setNodeEventEnabled(true)
    progress.time_label = UIKit:ttfLabel(
        {
            text = "",
            size = 20,
            color = 0x7e0000
        }):align(display.CENTER, 58, 64)
        :addTo(progress)
    progress.time_label:setRotationSkewY(180)

    return progress
end)

function WidgetAllianceEnterButtonProgress:OnTimer(current_time)
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
    else
        app.timer:RemoveListener(self)
        self:removeFromParent()
    end
end
function WidgetAllianceEnterButtonProgress:onExit()
    app.timer:RemoveListener(self)
end
return WidgetAllianceEnterButtonProgress




