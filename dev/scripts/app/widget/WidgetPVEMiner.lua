local promise = import("..utils.promise")
local SpriteConfig = import("..sprites.SpriteConfig")
local WidgetPVEResource = import("..widget.WidgetPVEResource")
local WidgetPVEMiner = class("WidgetPVEMiner", WidgetPVEResource)

function WidgetPVEMiner:ctor(...)
    WidgetPVEMiner.super.ctor(self, ...)
end
function WidgetPVEMiner:GetTitle()
    return string.format("%s %s%d", _('废弃的矿工小屋'), _('等级'), self:GetPVEMap():GetIndex())
end

-- fte
local WidgetFteArrow = import("..widget.WidgetFteArrow")
function WidgetPVEMiner:PormiseOfFte()
	local r = self.btns[1]:getCascadeBoundingBox()
	if self:GetFteLayer().arrow then
		self:GetFteLayer().arrow:removeFromParent()
		self:GetFteLayer().arrow = nil
	end
	self:GetFteLayer().arrow = WidgetFteArrow.new(_("点击进攻"))
	:addTo(self:GetFteLayer()):TurnUp():align(display.TOP_CENTER, r.x + r.width/2, r.y - 10)
	self:GetFteLayer():SetTouchObject(self.btns[1]):Enable()

	return UIKit:PromiseOfOpen("GameUIPVESendTroop"):next(function(ui)
			if self:GetFteLayer().arrow then
				self:GetFteLayer().arrow:removeFromParent()
			end
			self:GetFteLayer().arrow = nil
			self:GetFteLayer():Reset()
			return ui:PormiseOfFte()
		end):next(function()
			return self:PromiseOfExit()
		end)
end
function WidgetPVEMiner:PromiseOfExit()
	local r = self.btns[2]:getCascadeBoundingBox()
	if self:GetFteLayer().arrow then
		self:GetFteLayer().arrow:removeFromParent()
		self:GetFteLayer().arrow = nil
	end
	self:GetFteLayer().arrow = WidgetFteArrow.new(_("点击离开"))
	:addTo(self:GetFteLayer()):TurnRight():align(display.RIGHT_CENTER, r.x - 20, r.y + r.height/2)
	self:GetFteLayer():SetTouchObject(self.btns[2]):Enable()
	return UIKit:PromiseOfClose("WidgetPVEMiner")
end

return WidgetPVEMiner















