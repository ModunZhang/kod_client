--
-- Author: Danny He
-- Date: 2014-11-03 19:14:11
--
local WidgetTab = import(".WidgetTab")
local WidgetDragonTabButtons = class("WidgetDragonTabButtons",function()
	return display.newNode()
end)


function WidgetDragonTabButtons:ctor(listener)
	self.listener_ = listener or function(tag)end
	local bg = display.newSprite("dragon_tab_bg_482x54.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(self)
	local buttons = {}
	local button1 = cc.ui.UIPushButton.new({
			normal = "dragon_tab_buttons_normal_152x42.png",
			disabled = "dragon_tab_buttons_light_152x42.png",
			pressed = "dragon_tab_buttons_light_152x42.png",
		})
		:align(display.LEFT_BOTTOM,9,7)
		:addTo(bg)
		:onButtonClicked(handler(self, self.onButtonAction))
		:setButtonLabel("normal",UIKit:ttfLabel({
    		text = _("装备"),
    		size = 20,
    		color = 0x403c2f
		}))
		button1.tag = "equipment"
	table.insert(buttons,button1)
	local button2 = cc.ui.UIPushButton.new({
			normal = "dragon_tab_buttons_middle_normal_152x42.png",
			disabled = "dragon_tab_buttons_middle_light_152x42.png",
			pressed = "dragon_tab_buttons_middle_light_152x42.png",
		})
		:align(display.LEFT_BOTTOM,button1:getPositionX()+152+6,7)
		:addTo(bg)
		:onButtonClicked(handler(self, self.onButtonAction))
		:setButtonLabel("normal",UIKit:ttfLabel({
    		text = _("技能"),
    		size = 20,
    		color = 0x403c2f
		}))
		button2.tag = "skill"
	table.insert(buttons,button2)

	local button3 = cc.ui.UIPushButton.new({
			normal = "dragon_tab_right_normal_152x42.png",
			disabled = "dragon_tab_right_light_152x42.png",
			pressed = "dragon_tab_right_light_152x42.png",
		})
		:align(display.LEFT_BOTTOM,button2:getPositionX()+152+2,7)
		:onButtonClicked(handler(self, self.onButtonAction))
		:setButtonLabel("normal",UIKit:ttfLabel({
    		text = _("信息"),
    		size = 20,
    		color = 0x403c2f
		}))
		:addTo(bg)
		button3.tag = "info"
	table.insert(buttons,button3)
	self.buttons = buttons
end

function WidgetDragonTabButtons:onButtonAction(event)
	for _,v in ipairs(self.buttons) do
		v:setButtonEnabled(v.tag ~= event.target.tag)
	end
	self.current_tag = event.target.tag
	self.listener_(event.target.tag)
end

function WidgetDragonTabButtons:SelectButtonByTag(tag)
	for _,v in ipairs(self.buttons) do
		v:setButtonEnabled(v.tag ~= tag)
	end
	self.current_tag = tag
	self.listener_(tag)
end

function WidgetDragonTabButtons:GetCurrentTag()
	return self.current_tag or ""
end
return WidgetDragonTabButtons