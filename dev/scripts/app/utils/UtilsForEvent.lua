UtilsForEvent = {}
local Localize = import(".Localize")

function UtilsForEvent:GetEventInfo(event)
    local start = event.startTime/1000
    local finish = (event.finishTime or event.arriveTime) / 1000
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


function UtilsForEvent:GetMarchEventPrefix(event, eventType)
    if eventType == "shrineEvents" then
        local target_str = Localize.shrine_desc[event.stageName][1]
        local location = event.playerTroops[1].location
        local target_pos = string.format("%s,%s", location.x, location.y)
        return string.format(_("正在参加圣地战 %s(%s)"), target_str, target_pos)
    end
    local target_pos = string.format("%s,%s", 
            event.toAlliance.location.x, 
            event.toAlliance.location.y)
    if event.marchType == "village" then
        local target_str = string.format("%sLv%s", 
            Localize.village_name[event.defenceVillageData.name], 
            event.defenceVillageData.level)
        return string.format(_("正在进攻 %s(%s)"), target_str, target_pos)
    elseif event.marchType == "monster" then
        local soldier_name = unpack(string.split(event.defenceMonsterData.name, "_"))
        local target_str = string.format("%sLv%s", 
             Localize.soldier_name[soldier_name], 
            event.defenceMonsterData.level)
        return string.format(_("正在进攻 %s(%s)"), target_str, target_pos)
    elseif event.marchType == "helpDefence" then
        return string.format(_("前往协防 %s (%s)"), 
                event.defencePlayerData.name, target_pos)
    elseif event.marchType == "city" then
        local target_str = event.defencePlayerData.name
        return string.format(_("正在进攻 %s(%s)"), target_str, target_pos)
    elseif event.marchType == "shrine" then
        return string.format(_("进军圣地 (%s)"), target_pos)
    end
    -- if self:GetType() == self.ENTITY_TYPE.HELPTO then
    --     return  string.format(_("正在协防 %s (%s)"),self:WithObject().beHelpedPlayerData.name,self:GetDestinationLocation())
    -- elseif self:GetType() == self.ENTITY_TYPE.COLLECT then
    --     return string.format(_("正在采集%sLv%s (%s)"), 
    --         Localize.village_name[self:WithObject():VillageData().name],
    --         self:WithObject():VillageData().level,
    --         self:GetDestinationLocation())
    -- elseif self:GetType() == self.ENTITY_TYPE.MARCH_OUT then
    --     local march_type = self:WithObject():MarchType()
    --     if march_type == 'shrine' then 
    --         return string.format(_("进军圣地 (%s)"),self:GetDestinationLocation())
    --     elseif  march_type == 'helpDefence' then
    --         return string.format(_("前往协防 %s(%s)"),self:GetDestination(),self:GetDestinationLocation())
    --     else
    --         return string.format(_("正在进攻 %s(%s)"),self:GetDestination(),self:GetDestinationLocation())
    --     end
    -- elseif self:GetType() == self.ENTITY_TYPE.MARCH_RETURN then
    --     return string.format(_("返回中 (%s)"),self:GetDestinationLocation())
    -- elseif self:GetType() == self.ENTITY_TYPE.STRIKE_OUT then
    --     return string.format(_("正在突袭 %s(%s)"),self:GetDestination(),self:GetDestinationLocation())
    -- elseif self:GetType() == self.ENTITY_TYPE.STRIKE_RETURN then
    --     return string.format(_("返回中 (%s)"),self:GetDestinationLocation())
    -- elseif self:GetType() == self.ENTITY_TYPE.SHIRNE then
    --     return string.format(_("正在参加圣地战 %s(%s)"),self:WithObject():Stage():GetDescStageName(),self:GetDestinationLocation())
    -- end
end
function UtilsForEvent:GetMarchReturnEventPrefix(event)
    local target_pos = string.format("%s,%s", 
        event.toAlliance.location.x, 
        event.toAlliance.location.y)
    return string.format(_("返回中 (%s)"), target_pos)
end

function UtilsForEvent:GetCollectPercent(event)
    local collectTime = app.timer:GetServerTime() - event.startTime / 1000
    local time = (event.finishTime - event.startTime) / 1000
    local speed = event.villageData.collectTotal / time
    local collectCount = math.floor(speed * collectTime)
    local collectPercent = math.floor(collectCount / event.villageData.collectTotal * 100)
    return collectCount, collectPercent
end

function UtilsForEvent:GetVillageEventPrefix(event)
    local target_pos = string.format("%s,%s", 
            event.toAlliance.location.x, 
            event.toAlliance.location.y)
    return string.format(_("正在采集%sLv%s (%s)"), 
            Localize.village_name[event.villageData.name],
            event.villageData.level,target_pos)
end
function UtilsForEvent:IsMyVillageEvent(event)
    return event.playerData.id == User._id
end
function UtilsForEvent:IsMyMarchEvent(event)
    return event.attackPlayerData.id == User._id
end



