local Flag = import(".Flag")
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
end

function AllianceManager:OnAllianceDataChanged(alliance_data)
	self:GetMyAlliance():OnAllianceDataChanged(alliance_data)
end
function AllianceManager:OnAllianceBasicInfoAndMemberDataChanged(basic_and_member)
    local my_alliance = self:GetMyAlliance()
    local basicInfo = basic_and_member.basicInfo
    local memberDoc = basic_and_member.memberDoc
    if my_alliance:IsDefault() then return end
    if basicInfo then
        my_alliance:SetName(basicInfo.name)
        my_alliance:SetAliasName(basicInfo.tag)
        my_alliance:SetDefaultLanguage(basicInfo.language)
        my_alliance:SetFlag(Flag:DecodeFromJson(basicInfo.flag))
        my_alliance:SetTerrainType(basicInfo.terrain)
        my_alliance:SetJoinType(basicInfo.joinType)
        my_alliance:SetKills(basicInfo.kill)
        my_alliance:SetPower(basicInfo.power)
        my_alliance:SetExp(basicInfo.exp)
        my_alliance:SetLevel(basicInfo.level)
        my_alliance:SetCreateTime(basicInfo.createTime)
    end
    if memberDoc then
        my_alliance:OnAllianceMemberDataChanged(memberDoc)
    end
end



return AllianceManager

