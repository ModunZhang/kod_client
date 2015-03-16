local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVEKeel = class("WidgetPVEKeel", WidgetPVEDialog)

function WidgetPVEKeel:ctor(...)
    WidgetPVEKeel.super.ctor(self, ...)
end
function WidgetPVEKeel:GetTitle()
    return string.format("%s %s%d", _('龙骨'), _('等级'), self:GetPVEMap():GetIndex())
end
function WidgetPVEKeel:GetDesc()
    return self:GetObject():IsSearched()
        and _('"我已经把一切都给了你, "虚空中灵魂道, "你还是快走吧!"')
        or _('你发现了一具阵亡的巨龙骸骨, 恍惚间, 有声音在低语, "你想获得我的知识, 还是我的生命?"')
end
function WidgetPVEKeel:SetUpButtons()
    return self:GetObject():IsSearched() and
        { { label = _("离开") } } or
        {
            {
                label = _("知识"), callback = function()
                    self:Search()
                    self:GetRewardsFromServer(1)
                    self:removeFromParent()
                end
            },
            {
                label = _("生命"), callback = function()
                    self:Search()
                    self:GetRewardsFromServer(2)
                    self:removeFromParent()
                end
            }
        }
end

return WidgetPVEKeel



















