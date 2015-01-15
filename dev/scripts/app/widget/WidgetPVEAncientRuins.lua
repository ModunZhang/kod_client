local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVEAncientRuins = class("WidgetPVEAncientRuins", WidgetPVEDialog)

function WidgetPVEAncientRuins:ctor(...)
    WidgetPVEAncientRuins.super.ctor(self, ...)
end
function WidgetPVEAncientRuins:GetIcon()
    return "warriors_tomb.png"
end
function WidgetPVEAncientRuins:GetTitle()
    return string.format("%s %s%d", _('勇士之墓'), _('等级'), self:GetPVEMap():GetIndex())
end
function WidgetPVEAncientRuins:GetDesc()
    return self:GetObject():IsSearched()
        and _('你还想进入上古遗迹, 一名僧侣却拦住了你说道, "我们正在祈福, 无关人等还是赶紧离开!"')
        or _('一群僧侣正在上古遗迹中进行仪式。见你走近, 其中一名僧侣小声告诉你, 只要你捐献20个金龙币, 他们便赐予你一件宝物。')
end
function WidgetPVEAncientRuins:SetUpButtons()
    return self:GetObject():IsSearched() and
        { { label = _("离开") } } or
        {
            {
                label = _("捐献"), callback = function()
                    self:Search()
                    self:removeFromParent()
                end
            },
            {
                label = _("离开")
            }
        }
end

return WidgetPVEAncientRuins



















