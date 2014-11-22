-- local Flag = import(".Flag")
local Alliance = import(".Alliance")
local AllianceManager = class("AllianceManager")
function AllianceManager:ctor()
    self.my_alliance = Alliance.new()
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
    -- dump(self:GetMyAlliance())
end

function AllianceManager:OnAllianceDataChanged(alliance_data)
	self:GetMyAlliance():OnAllianceDataChanged(alliance_data)
end
function AllianceManager:OnAllianceBasicInfoAndMemberDataChanged(basic_and_member)
    local my_alliance = self:GetMyAlliance()
    if my_alliance:IsDefault() then return end
    if basic_and_member.basicInfo then
        my_alliance:OnAllianceBasicInfoChanged(basic_and_member.basicInfo)
    end
    if basic_and_member.memberDoc then
        my_alliance:OnOneAllianceMemberDataChanged(basic_and_member.memberDoc)
    end
    -- dump(self:GetMyAlliance())
end
function AllianceManager:OnAllianceHelpDataChanged(help_event)
    self:GetMyAlliance():ReFreashOneHelpEvent(help_event)
end

function AllianceManager:OnTimer(current_time)
    self:GetMyAlliance():OnTimer(current_time)
    if self:GetEnemyAlliance() then
        self:GetEnemyAlliance():OnTimer(current_time)
    end
end
--对手联盟
---------------
function AllianceManager:SetEnemyAllianceData( json_data )
    dump(json_data)
    if not self.enemy_alliance then
        self.enemy_alliance = Alliance.new()
    end
    local enemy_alliance = self:GetEnemyAlliance()
    enemy_alliance:SetId(json_data._id)
    enemy_alliance:SetName(json_data.basicInfo.name)
    enemy_alliance:SetAliasName(json_data.basicInfo.tag)
    enemy_alliance:OnAllianceDataChanged(json_data)
end

function AllianceManager:GetEnemyAlliance()
    return self.enemy_alliance
end

function AllianceManager:ResetEnemyAlliance()
    self.enemy_alliance = nil
end
return AllianceManager

