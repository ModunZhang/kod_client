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
    -- dump(self:GetMyAlliance())
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
function AllianceManager:OnAllianceHelpDataChanged(...)
    self:GetMyAlliance():OnHelpEventsChanged(...)
end



return AllianceManager

