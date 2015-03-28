--
-- Author: Kenny Dai
-- Date: 2015-03-28 11:11:27
--
local WidgetAllianceEnterButtonProgress = class("WidgetAllianceEnterButtonProgress", function ()
    local progress =display.newProgressTimer("progress_bg_116x89.png", display.PROGRESS_TIMER_RADIAL)
    progress:setRotationSkewY(180)
    app.timer:AddListener(progress)
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
    else
        self:removeFromParent()
        app.timer:RemoveListener(self)
    end
end

return WidgetAllianceEnterButtonProgress


