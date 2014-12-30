local Enum = import("..utils.Enum")
local property = import("..utils.property")

local Report = class("Report")
Report.REPORT_TYPE = Enum("strikeCity","cityBeStriked","strikeVillage","villageBeStriked","attackCity","attackVillage")
local STRIKECITY,CITYBESTRIKED,STRIKEVILLAGE,VILLAGEBESTRIKED,ATTACKCITY,ATTACKVILLAGE = 1,2,3,4,5,6
function Report:ctor(id,type,createTime,isRead,isSaved)
    property(self, "id", id)
    property(self, "type", type)
    property(self, "createTime", createTime)
    property(self, "isRead", isRead)
    property(self, "isSaved", isSaved)
    self.player_id = DataManager:getUserData()._id
end
function Report:OnPropertyChange(property_name, old_value, new_value)

end
function Report:DecodeFromJsonData(json_data)
    local report = Report.new(json_data.id, json_data.type, json_data.createTime, json_data.isRead, json_data.isSaved)
    report:SetData(json_data[json_data.type])
    return report
end
function Report:SetData(data)
    self.data = data
end
function Report:GetData()
    return self.data
end
-- 进攻玩家城市战报api BEGIN --
function Report:GetReportStar()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    return self.player_id == data.attackPlayerData.id and data.attackStar or data.defenceStar
end
function Report:IsRenamed()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    return data.isRenamed
end
function Report:GetAttackTarget()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    return data.attackTarget
end
function Report:GetMyHelpFightPlayerData()
    local data = self:GetData()
    return self.player_id == data.attackPlayerData.id and data.attackPlayerData or data.helpDefencePlayerData
end
function Report:GetEnemyHelpFightPlayerData()
    local data = self:GetData()
    return self.player_id == data.attackPlayerData.id and data.helpDefencePlayerData or data.attackPlayerData
end

function Report:GetMyHelpFightTroop()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        if data.attackPlayerData.fightWithHelpDefenceTroop then
            return data.attackPlayerData.fightWithHelpDefenceTroop.soldiers
        end
    else
        if data.helpDefencePlayerData then
            return data.helpDefencePlayerData.soldiers
        end
    end
end
function Report:GetEnemyHelpFightTroop()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        if data.helpDefencePlayerData then
            return data.helpDefencePlayerData.soldiers
        end
    else
        if data.attackPlayerData.fightWithHelpDefenceTroop then
            return data.attackPlayerData.fightWithHelpDefenceTroop.soldiers
        end
    end
end
function Report:GetMyHelpFightDragon()
    local data = self:GetData()
    if self.type == Report.REPORT_TYPE[ATTACKCITY] then
        if self.player_id == data.attackPlayerData.id then
            if data.attackPlayerData.fightWithHelpDefenceTroop then
                return data.attackPlayerData.fightWithHelpDefenceTroop.dragon
            end
        else
            if data.helpDefencePlayerData then
                return data.helpDefencePlayerData.dragon
            end
        end
    elseif self.type == Report.REPORT_TYPE[CITYBESTRIKED] or
        self.type == Report.REPORT_TYPE[STRIKECITY]
    then
        if self.player_id == data.attackPlayerData.id then
            if data.attackPlayerData.dragon then
                return data.attackPlayerData.dragon
            end
        else
            if data.helpDefencePlayerData then
                return data.helpDefencePlayerData.dragon
            end
        end
    end
end
function Report:GetEnemyHelpFightDragon()
    local data = self:GetData()
    if self.type == Report.REPORT_TYPE[ATTACKCITY] then
        if self.player_id == data.attackPlayerData.id then
            if data.helpDefencePlayerData then
                return data.helpDefencePlayerData.dragon
            end
        else
            if data.attackPlayerData.fightWithHelpDefenceTroop then
                return data.attackPlayerData.fightWithHelpDefenceTroop.dragon
            end
        end
    elseif self.type == Report.REPORT_TYPE[CITYBESTRIKED] or
        self.type == Report.REPORT_TYPE[STRIKECITY]
    then
        if self.player_id == data.attackPlayerData.id then
            if data.helpDefencePlayerData then
                return data.helpDefencePlayerData.dragon
            end
        else
            if data.attackPlayerData then
                return data.attackPlayerData.dragon
            end
        end
    end
end
function Report:GetMyDefenceFightPlayerData()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        return data.attackPlayerData
    else
        return data.defencePlayerData
    end
end
function Report:GetEnemyDefenceFightPlayerData()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        return data.defencePlayerData
    else
        return data.attackPlayerData
    end
end
function Report:GetMyDefenceFightTroop()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        if data.attackPlayerData.fightWithDefenceTroop then
            return data.attackPlayerData.fightWithDefenceTroop.soldiers
        end
    else
        if data.defencePlayerData then
            return data.defencePlayerData.soldiers
        end
    end
end
function Report:GetEnemyDefenceFightTroop()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        if data.defencePlayerData then
            return data.defencePlayerData.soldiers
        end
    else
        if data.attackPlayerData.fightWithDefenceTroop then
            return data.attackPlayerData.fightWithDefenceTroop.soldiers
        end
    end
end
function Report:GetMyDefenceFightDragon()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        if data.attackPlayerData.fightWithDefenceTroop then
            return data.attackPlayerData.fightWithDefenceTroop.dragon
        end
    else
        if data.defencePlayerData then
            return data.defencePlayerData.dragon
        end
    end
end
function Report:GetEnemyDefenceFightDragon()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if self.player_id == data.attackPlayerData.id then
        if data.defencePlayerData then
            return data.defencePlayerData.dragon
        end
    else
        if data.attackPlayerData.fightWithDefenceTroop then
            return data.attackPlayerData.fightWithDefenceTroop.dragon
        end
    end
end
function Report:GetMyRewards()
    local data = self:GetData()
    if self.type == Report.REPORT_TYPE[ATTACKCITY]
        or self.type == Report.REPORT_TYPE[CITYBESTRIKED]
        or self.type == Report.REPORT_TYPE[STRIKECITY]
    then
        if data.attackPlayerData.id == self.player_id then
            return data.attackPlayerData.rewards
        elseif data.helpDefencePlayerData and data.helpDefencePlayerData.id == self.player_id then
            return data.helpDefencePlayerData.rewards
        elseif data.defencePlayerData and data.defencePlayerData.id == self.player_id then
            return data.defencePlayerData.rewards
        end
    end
end
function Report:GetWallData()
    assert(self.type == Report.REPORT_TYPE[ATTACKCITY],"非攻打城市战报")
    local data = self:GetData()
    if data.defencePlayerData and data.defencePlayerData.wall then
        return {
            wall = data.defencePlayerData.wall,
            soldiers = data.attackPlayerData.fightWithDefenceWall.soldiers
        }
    end
end
function Report:IsAttackCamp()
    local data = self:GetData()
    return data.attackPlayerData.id == self.player_id
end
-- 进攻玩家城市战报api END --


-- 突袭战报api BEGIN --
function Report:GetStrikeLevel()
    assert(self.type == Report.REPORT_TYPE[CITYBESTRIKED] or Report.REPORT_TYPE[STRIKECITY],"非突袭战报")
    local data = self:GetData()
    return data.level
end
function Report:GetStrikeTarget()
    assert(self.type == Report.REPORT_TYPE[CITYBESTRIKED] or Report.REPORT_TYPE[STRIKECITY],"非突袭战报")
    local data = self:GetData()
    return data.strikeTarget
end
-- 获取突袭情报的对象
function Report:GetStrikeIntelligence()
    assert(self.type == Report.REPORT_TYPE[CITYBESTRIKED] or Report.REPORT_TYPE[STRIKECITY],"非突袭战报")
    local data = self:GetData()
    if data.helpDefencePlayerData then
        return data.helpDefencePlayerData
    elseif data.defencePlayerData then
        return data.defencePlayerData
    end
end
-- 突袭战报api END --


function Report:GetReportTitle()
    local data = self:GetData()
    local report_type = self.type
    print("======report_type===",report_type)
    LuaUtils:outputTable("data", data)
    if report_type == "strikeCity" then
        if data.level>1 then
            return _("突袭成功")
        else
            return _("突袭失败")
        end
    elseif report_type== "cityBeStriked" then
        if data.level>1 then
            return _("防守突袭失败")
        else
            return _("防守突袭成功")
        end
    elseif report_type=="attackCity" then
        if data.attackPlayerData.id == self.player_id then
            return data.attackStar > 0 and _("进攻城市成功") or _("进攻城市失败")
        elseif data.defencePlayerData.id == self.player_id then
            return data.defenceStar > 0 and _("防守城市成功") or _("防守城市失败")
        elseif data.helpDefencePlayerData and
            data.helpDefencePlayerData.id == DataManager:getUserData()._id then
            return data.defenceStar > 0 and _("协助防守城市成功") or _("协助防守城市失败")
        end
    end
end
function Report:IsHasHelpDefencePlayer()
    local data = self:GetData()
    return data.helpDefencePlayerData
end
return Report







