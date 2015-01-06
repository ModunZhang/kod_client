-- local Flag = import(".Flag")
local Alliance = import(".Alliance")
local AllianceManager = class("AllianceManager")
function AllianceManager:ctor()
    self.my_alliance = Alliance.new()
    self.enemyAlliance = Alliance.new()
end
function AllianceManager:GetMyAlliance()
    return self.my_alliance
end

function AllianceManager:OnUserDataChanged(user_data, time)
    local alliance = user_data.alliance
    local my_alliance = self:GetMyAlliance()
    if alliance then
        if alliance.id == nil then
            my_alliance:Reset()
        else
            my_alliance:SetId(alliance.id)
            my_alliance:SetName(alliance.name)
            my_alliance:SetAliasName(alliance.tag)
        end
    end
end

function AllianceManager:OnAllianceDataChanged(alliance_data)
    self:UpdateEnemyAlliance(alliance_data.enemyAllianceDoc,alliance_data.basicInfo.status)
    self:GetMyAlliance():OnAllianceDataChanged(alliance_data)
    self:RefreshAllianceSceneIf()
end

function AllianceManager:OnTimer(current_time)
    self:GetMyAlliance():OnTimer(current_time)
    local enemy_alliance = self:GetEnemyAlliance()
    if not enemy_alliance:IsDefault() then
        enemy_alliance:OnTimer(current_time)
    end
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

function AllianceManager:HaveEnemyAlliance()
    return not self:GetEnemyAlliance():IsDefault()
end

function AllianceManager:GetEnemyAlliance()
    return self.enemyAlliance
end

function AllianceManager:UpdateEnemyAlliance(json_data,my_alliance_status)
    if not json_data then return end
    if my_alliance_status == 'protect' or my_alliance_status == 'peace' then
        self:GetEnemyAlliance():Reset()
    else
        local enemy_alliance = self:GetEnemyAlliance()
        if enemy_alliance:IsDefault() then
            local my_belvedere = self:GetMyAlliance():GetAllianceBelvedere()
            local enemy_belvedere = enemy_alliance:GetAllianceBelvedere()
            enemy_belvedere:AddListenOnType(my_belvedere, enemy_belvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged)
            enemy_belvedere:AddListenOnType(my_belvedere, enemy_belvedere.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
            enemy_belvedere:AddListenOnType(my_belvedere, enemy_belvedere.LISTEN_TYPE.OnAttackMarchEventDataChanged)
            --瞭望塔coming不需要知道敌方对自己联盟的村落事件和返回事件 reset 会自动去掉所有监听
        end
        if json_data._id then
            enemy_alliance:SetId(json_data._id)
        end
        if json_data.basicInfo then
            enemy_alliance:SetName(json_data.basicInfo.name)
            enemy_alliance:SetAliasName(json_data.basicInfo.tag)
        end
        enemy_alliance:OnAllianceDataChanged(json_data)
    end
end

function AllianceManager:RefreshAllianceSceneIf()
    local my_alliance = self:GetMyAlliance()
    if my_alliance:Status() == 'protect' and display.getRunningScene().__cname == 'AllianceBattleScene' then
        app:EnterMyAllianceSceneWithTips(_("联盟对战已结束，您将进入自己联盟领地。"))
    end
    if my_alliance:Status() == 'prepare' and display.getRunningScene().__cname == 'AllianceScene' then
        app:EnterMyAllianceSceneWithTips(_("联盟对战已开始，您将进入自己联盟对战地图。"))
    end
end

return AllianceManager

