local Alliance = import(".Alliance")
local AllianceManager = class("AllianceManager")
function AllianceManager:ctor()
    self.my_alliance = Alliance.new()
    self.my_alliance:InitEnemyAlliance()
    self.my_alliance:SetNeedUpdateEnemyAlliance(true)
end
function AllianceManager:GetMyAlliance()
    return self.my_alliance
end

function AllianceManager:OnUserDataChanged(user_data,time,deltaData)
    dump(deltaData,"deltaData--->")
    dump(user_data,"user_data--->")
    local alliance = user_data.alliance
    local my_alliance = self:GetMyAlliance()
    if alliance == json.null then
        my_alliance:Reset()
    else
        my_alliance:SetId(alliance.id)
        my_alliance:SetName(alliance.name)
        my_alliance:SetAliasName(alliance.tag)
    end

end

function AllianceManager:OnAllianceDataChanged(alliance_data,refresh_time,deltaData)
    dump(alliance_data,"alliance_data---->")
    self:GetMyAlliance():OnAllianceDataChanged(alliance_data,deltaData)
    self:RefreshAllianceSceneIf()
end

function AllianceManager:OnTimer(current_time)
    self:GetMyAlliance():OnTimer(current_time)
end

---------------
function AllianceManager:DecodeAllianceFromJson( json_data )
    local alliance = Alliance.new()
    alliance:SetId(json_data._id)
    alliance:SetName(json_data.basicInfo.name)
    alliance:SetAliasName(json_data.basicInfo.tag)
    alliance:OnAllianceDataChanged(json_data)
    return alliance
end

function AllianceManager:RefreshAllianceSceneIf()
    local my_alliance = self:GetMyAlliance()
    if (my_alliance:Status() == 'protect' or my_alliance:Status() == 'peace') and display.getRunningScene().__cname == 'AllianceBattleScene' then
        app:EnterMyAllianceSceneWithTips(_("联盟对战已结束，您将进入自己联盟领地。"))
    end
    if (my_alliance:Status() == 'prepare' or my_alliance:Status() == 'fight') and display.getRunningScene().__cname == 'AllianceScene' then
        app:EnterMyAllianceSceneWithTips(_("联盟对战已开始，您将进入自己联盟对战地图。"))
    end
end

return AllianceManager

