local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEDialog = import("..widget.WidgetPVEDialog")
local WidgetPVEWoodcutter = class("WidgetPVEWoodcutter", WidgetPVEDialog)

function WidgetPVEWoodcutter:ctor(param)
	param = param or {}
    self.dominate = param.dominate

    WidgetPVEWoodcutter.super.ctor(self, self:GetTitle())
end
function WidgetPVEWoodcutter:GetIcon()
    return SpriteConfig["woodcutter"]:GetConfigByLevel(1).png
end
function WidgetPVEWoodcutter:GetTitle()
    return _('废弃的木工小屋')
end
function WidgetPVEWoodcutter:GetDesc()
    return self:IsDominate() and
        _('你已经除掉了这里的叛军, 这里的居民都向你表示感激!') or
        _('这里被叛军占领, 居民希望你能将他们赶走并愿意向你提供一些报酬。')
end
function WidgetPVEWoodcutter:SetUpButtons()
    return self:IsDominate() and
        { { label = _("离开") } } or
        { { label = _("进攻"), callback = function() 
        	self:removeFromParent()
        end }, { label = _("离开") } }
end
function WidgetPVEWoodcutter:IsDominate()
    return  self.dominate
end

return WidgetPVEWoodcutter

