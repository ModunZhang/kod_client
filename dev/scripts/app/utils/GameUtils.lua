GameUtils = {
	
}

function GameUtils:formatTimeStyle1(time)
    local seconds = time % 60
    time = time / 60
    local minutes = time % 60
    time = time / 60
    local hours = time
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function GameUtils:formatTimeStyle2(time)
	return os.date("%Y-%m-%d %H:%M:%S",time)
end

function GameUtils:formatTimeStyle3(time)
	return os.date("%Y/%m/%d/ %H:%M:%S",time)
end

function GameUtils:formatTimeStyle4(time)
	return os.date("%y-%m-%d %H:%M",time)
end

function GameUtils:formatTimeAsTimeAgoStyle( time )
	local timeText = nil
	if(time <= 0) then
		timeText = GameLoader:GetGameText("LC_TIME_JustNow")
	elseif(time == 1) then
		timeText = GameLoader:GetGameText("LC_TIME_ASecondAgo")
	elseif(time < 60) then
		timeText = string.format(GameLoader:GetGameText("LC_TIME_SomeSecondsAgo"), time)
	elseif(time == 60) then
		timeText = GameLoader:GetGameText("LC_TIME_AMinuteAgo")
	elseif(time < 3600) then
		time = math.ceil(time / 60)
		timeText = string.format(GameLoader:GetGameText("LC_TIME_SomeMinutesAgo"), time)
	elseif(time == 3600) then
		timeText = GameLoader:GetGameText("LC_TIME_AHourAgo")
	elseif(time < 86400) then
		time = math.ceil(time / 3600)
		timeText = string.format(GameLoader:GetGameText("LC_TIME_SomeHourAgo"), time)
	elseif(time == 86400) then
		timeText = GameLoader:GetGameText("LC_TIME_ADayAgo")
	else
		time = math.ceil(time / 86400)
		timeText = string.format(GameLoader:GetGameText("LC_TIME_SomeDaysAgo"), time)
	end

	return timeText
end

function GameUtils:getUpdatePath(  )
	return device.writablePath .. "update/" .. CONFIG_APP_VERSION .. "/"
end