--
-- Author: Danny He
-- Date: 2014-10-09 20:58:25
--
local UICheckBoxButton = cc.ui.UICheckBoxButton
local WidgetAllianceLanguagePanel = class("WidgetAllianceLanguagePanel", function()
    return display.newNode()
end)
local checkbox_image = {
    off = "checkbox_unselected.png",
    off_pressed = "checkbox_unselected.png",
    off_disabled = "checkbox_unselected.png",
    on = "checkbox_selectd.png",
    on_pressed = "checkbox_selectd.png",
    on_disabled = "checkbox_selectd.png",
}

function WidgetAllianceLanguagePanel:ctor(height)
	self.height_ = height
	self:setNodeEventEnabled(true)
	self.currentIndex_ = 0
end

function WidgetAllianceLanguagePanel:onEnter()
	local height = self.height_
	local bottom = display.newSprite("alliance_box_bottom_552x12.png")
		:addTo(self)
		:align(display.LEFT_BOTTOM,0,0)
	local top =  display.newSprite("alliance_box_top_552x12.png")
	local middleHeight = height - bottom:getContentSize().height - top:getContentSize().height
	local next_y = bottom:getContentSize().height
	while middleHeight > 0 do
		local middle = display.newSprite("alliance_box_middle_552x1.png")
			:addTo(self)
			:align(display.LEFT_BOTTOM,0, next_y)
		middleHeight = middleHeight - middle:getContentSize().height
		next_y = next_y + middle:getContentSize().height
	end
	top:addTo(self)
		:align(display.LEFT_BOTTOM,0,next_y)
	self:createCheckBoxButtons_()
end


function WidgetAllianceLanguagePanel:createCheckBoxButtons_()
	self.buttons_ = {}
	local button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("西班牙语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,0,0)
            :addTo(self)
	table.insert(self.buttons_,button)
	button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("葡萄牙语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width + 140,0)
            :addTo(self)
   table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("韩语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,0,button:getCascadeBoundingBox().height+5)
            :addTo(self)
	table.insert(self.buttons_,button) 
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("日语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width + 140,button:getCascadeBoundingBox().height+5)
            :addTo(self)
    table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("俄语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,(button:getCascadeBoundingBox().width + 140)*2,button:getCascadeBoundingBox().height+5)
            :addTo(self)
    table.insert(self.buttons_,button)    
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("简体中文"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,0,(button:getCascadeBoundingBox().height+5)*2)
            :addTo(self)
    table.insert(self.buttons_,button)   
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("繁体中文"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width + 140,(button:getCascadeBoundingBox().height+5)*2)
            :addTo(self)
    table.insert(self.buttons_,button)
	button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("德语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,(button:getCascadeBoundingBox().width+140)*2,(button:getCascadeBoundingBox().height+5)*2)
            :addTo(self)
    table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("所有语言"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,0,(button:getCascadeBoundingBox().height+5)*3)
            :addTo(self)
    table.insert(self.buttons_,button)
	button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("英语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width+140,(button:getCascadeBoundingBox().height+5)*3)
            :addTo(self)
    table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("法语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,(button:getCascadeBoundingBox().width+140)*2,(button:getCascadeBoundingBox().height+5)*3)
            :addTo(self)
    table.insert(self.buttons_,button)
end

function WidgetAllianceLanguagePanel:buttonEvents()
	
end

return WidgetAllianceLanguagePanel