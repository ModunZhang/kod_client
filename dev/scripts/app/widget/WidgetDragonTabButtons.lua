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
	UIKit:shadowLayer():addTo(self,-2):size(600,58):pos(16,42)
	local bg = display.newSprite("dragon_tab_bg_624x102.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(self)
	local buttons = {}
	local back_button = cc.ui.UIPushButton.new({
    	normal = "home_btn_up.png",
    	pressed = "home_btn_down.png"
      }):align(display.LEFT_TOP,6, 100)
      :addTo(bg,-1)
      :onButtonClicked(handler(self, self.onButtonAction))
    local back_icon = display.newSprite("dragon_next_icon_28x31.png"):addTo(back_button):pos(49,-30)
	back_icon:setRotation(180)
    back_button.tag = "back"
    table.insert(buttons,back_button)
	local button1 = cc.ui.UIPushButton.new({
			normal = "dragon_tab_buttons_normal_172x54.png",
			disabled = "dragon_tab_buttons_light_172x54.png",
			pressed = "dragon_tab_buttons_light_172x54.png",
		})
		:align(display.LEFT_TOP,100,96)
		:addTo(bg,-1)
		:onButtonClicked(handler(self, self.onButtonAction))
		:setButtonLabel("normal",UIKit:ttfLabel({
    		text = _("装备"),
    		size = 20,
    		color = 0x403c2f
		}))
		button1.tag = "equipment"
	table.insert(buttons,button1)
	local button2 = cc.ui.UIPushButton.new({
			normal = "dragon_tab_buttons_normal_172x54.png",
			disabled = "dragon_tab_buttons_light_172x54.png",
			pressed = "dragon_tab_buttons_light_172x54.png",
		})
		:align(display.LEFT_TOP,button1:getPositionX()+172,96)
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
			normal = "dragon_tab_buttons_normal_172x54.png",
			disabled = "dragon_tab_buttons_light_172x54.png",
			pressed = "dragon_tab_buttons_light_172x54.png",
		})
		:align(display.LEFT_TOP,button2:getPositionX()+172,96)
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
	self.bg = bg
end

function WidgetDragonTabButtons:SetTitleString(str)
	if LuaUtils:isString(str) then
		if not self.titleLabel then
			self.titleLabel = UIKit:ttfLabel({
				text = str,
				size = 28,
				color= 0xebdba0,
			}):addTo(self.bg):align(display.CENTER,312,73)
		else
			self.titleLabel:setString(str)
		end
	end
end

function WidgetDragonTabButtons:onButtonAction(event)
	for _,v in ipairs(self.buttons) do
		if v.tag ~= 'back' and event.target.tag ~= "back" then
			v:setButtonEnabled(v.tag ~= event.target.tag)
		end
	end
	if event.target.tag ~= "back" then 
		self.current_tag = event.target.tag
	end
	self.listener_(event.target.tag)
end

function WidgetDragonTabButtons:SelectButtonByTag(tag)
	for _,v in ipairs(self.buttons) do
		if v.tag ~= 'back' and tag ~= "back" then
			v:setButtonEnabled(v.tag ~= tag)
		end
	end
	if tag ~= "back" then 
		self.current_tag = tag
	end
	self.listener_(tag)
end

function WidgetDragonTabButtons:VisibleFunctionButtons(visible)
	for _,v in ipairs(self.buttons) do
		if v.tag ~= 'back' then
			v:setVisible(visible)
		end
	end
end

function WidgetDragonTabButtons:GetCurrentTag()
	return self.current_tag or ""
end
return WidgetDragonTabButtons