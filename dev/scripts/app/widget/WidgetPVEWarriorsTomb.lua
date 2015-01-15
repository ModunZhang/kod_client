local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVEWarriorsTomb = class("WidgetPVEWarriorsTomb", WidgetPVEDialog)

function WidgetPVEWarriorsTomb:ctor(...)
    WidgetPVEWarriorsTomb.super.ctor(self, ...)
end
function WidgetPVEWarriorsTomb:GetIcon()
    return "warriors_tomb.png"
end
function WidgetPVEWarriorsTomb:GetTitle()
    return string.format("%s %s%d", _('勇士之墓'), _('等级'), self:GetPVEMap():GetIndex())
end
function WidgetPVEWarriorsTomb:GetDesc()
    return self:GetObject():IsSearched()
        and _('"我已经把一切都给了你, "虚空中灵魂道, "你还是快走吧!"')
        or _('你发现了一具阵亡的巨龙骸骨, 恍惚间, 有声音在低语, "你想获得我的知识, 还是我的生命?"')
end
function WidgetPVEWarriorsTomb:SetUpButtons()
    return self:GetObject():IsSearched() and
        { { label = _("离开") } } or
        {
            {
                label = _("安葬"), callback = function()
                    self:Search()
                    self:removeFromParent()
                end
            },
            {
                label = _("离开")
            }
        }
end

return WidgetPVEWarriorsTomb



















