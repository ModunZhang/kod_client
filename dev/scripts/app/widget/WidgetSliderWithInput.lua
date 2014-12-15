local WidgetSlider = import("..widget.WidgetSlider")

local WidgetSliderWithInput = class("WidgetSliderWithInput", function ( ... )
    return display.newNode(...)
end)

function WidgetSliderWithInput:ctor(params)
    local max = params.max
    -- progress
    self.slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
        progress = "slider_progress_445x14.png",
        button = "slider_btn_66x66.png"}, {max = max}):addTo(self)
    local slider = self.slider

    local function edit(event, editbox)
        local text = tonumber(editbox:getText()) or 0
        if event == "began" then
            if 0==text then
                editbox:setText("")
            end
        elseif event == "changed" then
            if text and text > max then
                editbox:setText(max)
            end
        elseif event == "ended" then
            if text=="" or 0==text then
                editbox:setText(0)
            end
            local edit_value = tonumber(editbox:getText())
            editbox:setText(edit_value)

            local slider_value = slider:getSliderValue()
            if edit_value ~= slider_value then
                slider.fsm_:doEvent("press")
                slider:setSliderValue(edit_value)
                slider.fsm_:doEvent("release")
                if self.sliderReleaseEventListener then
                	self.sliderReleaseEventListener()
                end
            end
        end
    end
    -- soldier current
    self.editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "back_ground_83x32.png",
        size = cc.size(100,32),
        font = UIKit:getFontFilePath(),
        listener = edit
    })
    local editbox = self.editbox
    editbox:setMaxLength(10)
    editbox:setText(0)
    editbox:setFont(UIKit:getFontFilePath(),20)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.CENTER, slider:getCascadeBoundingBox().size.width+60,30):addTo(self)


    slider:onSliderValueChanged(function(event)
        editbox:setText(math.floor(event.value))
    end)


    local soldier_total_count = UIKit:ttfLabel({
        text = string.format("/ %d", max),
        size = 20,
        color = 0x403c2f
    }):addTo(self)
        :align(display.LEFT_CENTER, slider:getCascadeBoundingBox().size.width+20,-10)
    self:setContentSize(cc.size(slider:getCascadeBoundingBox().size.width,slider:getCascadeBoundingBox().size.height))

end

function WidgetSliderWithInput:GetValue()
    return math.floor(slider:getSliderValue())
end
function WidgetSliderWithInput:AddSliderReleaseEventListener(func)
	self.sliderReleaseEventListener = func
    self.slider:addSliderReleaseEventListener(function(event)
        func(event)
    end)
    return self
end
function WidgetSliderWithInput:OnSliderValueChanged(func)
	self.slider:onSliderValueChanged(function(event)
        self.editbox:setText(math.floor(event.value))
        func(event)
    end)
    return self
end
return WidgetSliderWithInput



