local property = import("..utils.property")
local AllianceMember = class("AllianceMember")
property(AllianceMember, "level", 0)
property(AllianceMember, "kill", 0)
property(AllianceMember, "power", 0)
property(AllianceMember, "loyalty", 0)
property(AllianceMember, "lastLoginTime", 0)
property(AllianceMember, "icon", "")
property(AllianceMember, "title")
property(AllianceMember, "name")
function AllianceMember:ctor(id)
    property(self, "id", id)
end
function AllianceMember:CreatFromJsonData(json_data)
    local member = AllianceMember.new(json_data.id)
    member:SetLevel(json_data.level)
    member:SetKill(json_data.kill)
    member:SetIcon(json_data.icon)
    member:SetTitle(json_data.title)
    member:SetName(json_data.name)
    member:SetPower(json_data.power)
    member:SetLastLoginTime(json_data.lastLoginTime)
    member:SetLoyalty(json_data.loyalty)
    return member
end
function AllianceMember:IsSameDataWith(member)
    for _, v in ipairs{
        "Level",
        "Kill",
        "Power",
        "Loyalty",
        "LastLoginTime",
        "Icon",
        "Title",
        "Name"
    } do
    	if self[v](self) ~= member[v](member) then
    		return false
    	end
    end
    return true
end
function AllianceMember:IsTheSamePerson(member)
    return self:IsTheSameId(member:Id())
end
function AllianceMember:IsTheSameId(id)
    return self:Id() == id
end



return AllianceMember




