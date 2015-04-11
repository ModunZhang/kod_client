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
    local alliance = user_data.alliance
    local my_alliance = self:GetMyAlliance()
    if alliance == json.null or not alliance then
        my_alliance:Reset()
        DataManager:setUserAllianceData(json.null)
    else
        my_alliance:SetId(alliance.id)
        my_alliance:SetName(alliance.name)
        my_alliance:SetAliasName(alliance.tag)
    end
end

function AllianceManager:OnAllianceDataChanged(alliance_data,refresh_time,deltaData)
    self:GetMyAlliance():OnAllianceDataChanged(alliance_data,refresh_time,deltaData)
    self:RefreshAllianceSceneIf()
end

function AllianceManager:OnTimer(current_time)
    self:GetMyAlliance():OnTimer(current_time)
end

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
    local my_alliance_status = my_alliance:Status()
    local scene_name = display.getRunningScene().__cname
    if (my_alliance_status == 'protect' or my_alliance_status == 'peace') and scene_name == 'AllianceBattleScene' then
        app:EnterMyAllianceSceneWithTips(_("联盟对战已结束，您将进入自己联盟领地。"))
    end
    if (my_alliance_status == 'prepare' or my_alliance_status == 'fight') then
        if scene_name == 'AllianceScene' then
            app:EnterMyAllianceSceneWithTips(_("联盟对战已开始，您将进入自己联盟对战地图。"))
        elseif scene_name == 'CityScene' then
            UIKit:showMessageDialogCanCanleNotAutoClose(
                nil,
                _("联盟对战已开始，您将进入自己联盟对战地图。"),
                function()
                    app:EnterMyAllianceScene()
                end,
                function()
                end
            )
        end
    end
    
end

return AllianceManager

