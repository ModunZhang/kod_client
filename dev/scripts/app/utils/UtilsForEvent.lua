UtilsForEvent = {}

local Localize = import(".Localize")

function UtilsForEvent:GetEventInfo(event)
    local start = event.startTime/1000
    local finish = event.finishTime/1000
    local time = app.timer:GetServerTime()
    return math.ceil(finish - time), (time - start) * 100.0 / (finish - start)
end
function UtilsForEvent:GetMilitaryTechEventLocalize(tech_name, level)
    local category, tech_type = unpack(string.split(tech_name, "_"))
    if not tech_type then
        return string.format(_("晋升%s的星级 star %d"),
            Localize.soldier_name[tech_name], level + 1)
    end
    if tech_type == "hpAdd" then
        return string.format(
        	_("研发科技-%s血量增加到 Lv %d"),
        	Localize.soldier_category[category],
        	level + 1)
    end
    return string.format(
    	_("研发科技-%s对%s的攻击到 Lv %d"),
    	Localize.soldier_category[category],
    	Localize.soldier_category[tech_type],
    	level + 1)
end