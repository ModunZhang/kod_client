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
function AllianceMember:CreatFromData(data)
    local member = AllianceMember.new(data.id)
    member:SetLevel(data.level)
    member:SetKill(data.kill)
    member:SetIcon(data.icon)
    member:SetTitle(data.title)
    member:SetName(data.name)
    member:SetPower(data.power)
    member:SetLastLoginTime(data.lastLoginTime)
    member:SetLoyalty(data.loyalty)
    return member
end
function AllianceMember:IsSameDataWith(member)
	if not member then return false end
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




