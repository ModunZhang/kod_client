local Enum = import("..utils.Enum")
local property = import("..utils.property")
local AllianceMember = class("AllianceMember")
property(AllianceMember, "id")
property(AllianceMember, "level", 0)
property(AllianceMember, "kill", 0)
property(AllianceMember, "power", 0)
property(AllianceMember, "loyalty", 0)
property(AllianceMember, "lastLoginTime", 0)
property(AllianceMember, "icon", "")
property(AllianceMember, "title")
property(AllianceMember, "name")
property(AllianceMember, "helpTroopsCount")
local titles_enum = Enum("member",
    "elite",
    "supervisor",
    "quartermaster",
    "general",
    "archon")
function AllianceMember:ctor(id)
    self.id = id
    self.location = {x = 0, y = 0}
    self.donateStatus = {}
    self.allianceExp = {}
end
function AllianceMember:IsArchon()
    return self:Title() == "archon"
end
function AllianceMember:IsTitleHighest()
    return self:Title() == titles_enum[#titles_enum - 1]
end
function AllianceMember:TitleUpgrade()
    local cur = self:Title()
    return titles_enum[titles_enum[cur] + 1] or cur
end
function AllianceMember:IsTitleLowest()
    return self:Title() == titles_enum[1]
end
function AllianceMember:GetDonateStatus()
    return self.donateStatus
end
-- 职位权限是否大于等于某个职位
-- @parm eq_title 比较的职位
function AllianceMember:IsTitleEqualOrGreaterThan(eq_title)
    local self_title_level , eq_title_level
    for k,v in pairs(titles_enum) do
        if self:Title()==titles_enum[k] then
            self_title_level = k
        end
        if eq_title == titles_enum[k] then
            eq_title_level = k
        end
    end
    return self_title_level >= eq_title_level
end
function AllianceMember:TitleDegrade()
    local cur = self:Title()
    return titles_enum[titles_enum[cur] - 1] or cur
end
function AllianceMember:DecodeFromJson(data)
    local member = AllianceMember.new(data.id)
    for k, v in pairs(data) do
        member[k] = v 
    end
    return member
end
function AllianceMember:IsSameDataWith(member)
    return not self:IsDifferentWith(member)
end
function AllianceMember:IsDifferentWith(member)
    if not member then return false end
    for _, v in ipairs{
        "level",
        "kill",
        "power",
        "loyalty",
        "lastlogintime",
        "icon",
        "title",
        "name"
    } do
        if self[v] ~= member[v] then
            return true
        end
    end
    for _, key in ipairs{
        "location",
        "donateStatus",
        "allianceExp",
    } do
        local value = member[key]
        for k, v in pairs(self[key]) do
            if v ~= value[k] then
                return true
            end
        end
    end
    return false
end
function AllianceMember:IsTheSamePerson(member)
    return self:IsTheSameId(member:Id())
end
function AllianceMember:IsTheSameId(id)
    return self:Id() == id
end



return AllianceMember










