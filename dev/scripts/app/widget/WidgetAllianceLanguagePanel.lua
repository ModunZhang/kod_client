--
-- Author: Danny He
-- Date: 2014-10-09 20:58:25
--
local UICheckBoxButton = cc.ui.UICheckBoxButton
local WidgetAllianceLanguagePanel = class("WidgetAllianceLanguagePanel", function()
    return display.newNode()
end)
local ALL_LANGUAGE = {
    "all",
    "en",
    "fr",
    "cn",
    "tw",
    "de",
    "ko",
    "ja",
    "ru",
    "es",
    "pt"
}

local checkbox_image = {
    off = "checkbox_unselected.png",
    off_pressed = "checkbox_unselected.png",
    off_disabled = "checkbox_unselected.png",
    on = "checkbox_selectd.png",
    on_pressed = "checkbox_selectd.png",
    on_disabled = "checkbox_selectd.png",
}
WidgetAllianceLanguagePanel.BUTTON_SELECT_CHANGED = "BUTTON_SELECT_CHANGED"

function WidgetAllianceLanguagePanel:ctor(height)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.height_ = height
	self:setNodeEventEnabled(true)
	self.currentSelectedIndex_ = 0
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
    self:buttonEvents_()
    self:getButtonByIndex()
end


function WidgetAllianceLanguagePanel:createCheckBoxButtons_()
	self.buttons_ = {}
	local button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("西班牙语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,10,0)
            :addTo(self)
    button:setTag(10)
	table.insert(self.buttons_,button)
	button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("葡萄牙语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width + 150,0)
            :addTo(self)
    button:setTag(11)
   table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("韩语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,10,button:getCascadeBoundingBox().height+5)
            :addTo(self)
    button:setTag(7)
	table.insert(self.buttons_,button) 
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("日语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width + 150,button:getCascadeBoundingBox().height+5)
            :addTo(self)
    button:setTag(8)
    table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("俄语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,(button:getCascadeBoundingBox().width + 150)*2,button:getCascadeBoundingBox().height+5)
            :addTo(self)
    button:setTag(9)
    table.insert(self.buttons_,button)    
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("简体中文"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,10,(button:getCascadeBoundingBox().height+5)*2)
            :addTo(self)
    button:setTag(4)
    table.insert(self.buttons_,button)   
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("繁体中文"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width + 150,(button:getCascadeBoundingBox().height+5)*2)
            :addTo(self)
    button:setTag(5)
    table.insert(self.buttons_,button)
	button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("德语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,(button:getCascadeBoundingBox().width+150)*2,(button:getCascadeBoundingBox().height+5)*2)
            :addTo(self)
    button:setTag(6)
    table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("所有语言"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,10,(button:getCascadeBoundingBox().height+5)*3)
            :addTo(self)
    button:setTag(1)
    table.insert(self.buttons_,button)
	button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("英语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,button:getCascadeBoundingBox().width+150,(button:getCascadeBoundingBox().height+5)*3)
            :addTo(self)
    button:setTag(2)
    table.insert(self.buttons_,button)
    button = UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("法语"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_BOTTOM,(button:getCascadeBoundingBox().width+150)*2,(button:getCascadeBoundingBox().height+5)*3)
            :addTo(self)
    button:setTag(3)
    table.insert(self.buttons_,button)

    UIKit:ttfLabel({
        text = _("联盟的语言"),
        size = 22,
        color = 0x403c2f
    }):addTo(self):align(display.CENTER,self:getCascadeBoundingBox().width/2,button:getPositionY()+90)
end

function WidgetAllianceLanguagePanel:buttonEvents_()
	for i,button in ipairs(self.buttons_) do
        button:onButtonStateChanged(handler(self, self.onButtonStateChanged_))
        button:onButtonClicked(handler(self, self.onButtonStateChanged_))
    end
end

function WidgetAllianceLanguagePanel:onButtonStateChanged_(event)
    if event.name == UICheckBoxButton.STATE_CHANGED_EVENT and event.target:isButtonSelected() == false then
        return
    end
    self:updateButtonState_(event.target)
end

function WidgetAllianceLanguagePanel:getButtonByIndex( index )
    self:getChildByTag(1):setButtonSelected(true)
end

function WidgetAllianceLanguagePanel:updateButtonState_(clickedButton)
    local currentSelectedIndex = 0
    for index, button in ipairs(self.buttons_) do
        if button == clickedButton then
            currentSelectedIndex = button:getTag()
            if not button:isButtonSelected() then
                button:setButtonSelected(true)
            end
        else
            if button:isButtonSelected() then
                button:setButtonSelected(false)
            end
        end
    end
    if self.currentSelectedIndex_ ~= currentSelectedIndex then
        local last = self.currentSelectedIndex_
        self.currentSelectedIndex_ = currentSelectedIndex
        self:dispatchEvent({name = WidgetAllianceLanguagePanel.BUTTON_SELECT_CHANGED,
            selected = currentSelectedIndex,
            last = last,
            language = self:getSelectedLanguage()}
        )
    end
end

function WidgetAllianceLanguagePanel:getSelectedIndex()
    return self.currentSelectedIndex_
end

function WidgetAllianceLanguagePanel:addButtonSelectChangedEventListener(callback)
    return self:addEventListener(WidgetAllianceLanguagePanel.BUTTON_SELECT_CHANGED, callback)
end

function WidgetAllianceLanguagePanel:onButtonSelectChanged(callback)
    self:addButtonSelectChangedEventListener(callback)
    return self
end

function WidgetAllianceLanguagePanel:getSelectedLanguage()
    return ALL_LANGUAGE[self:getSelectedIndex()]
end

return WidgetAllianceLanguagePanel