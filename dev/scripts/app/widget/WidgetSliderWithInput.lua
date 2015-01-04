local WidgetSlider = import("..widget.WidgetSlider")
local Enum = import("..utils.Enum")

local WidgetSliderWithInput = class("WidgetSliderWithInput", function ( ... )
    return display.newNode(...)
end)
WidgetSliderWithInput.STYLE_LAYOUT = Enum("LEFT","RIGHT","TOP","BOTTOM")


function WidgetSliderWithInput:ctor(params)
    local max = params.max
    local min = params.min or 0
    local unit = params.unit or ""
    local bar = params.bar or "slider_bg_554x24.png"
    local progress = params.progress or "slider_progress_538x24.png"
    -- progress
    self.slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = bar,
        progress = progress,
        button = "slider_btn_66x66.png"}, {max = max,min = min,scale9=true}):addTo(self)
    local slider = self.slider


    local function edit(event, editbox)
        local text = tonumber(editbox:getText()) or min
        if event == "began" then
            if min==text then
                editbox:setText("")
            end
        elseif event == "changed" then
            if text then
                if text > max then
                    editbox:setText(max)
                end
            end
        elseif event == "ended" then
            if text=="" or min>text then
                editbox:setText(min)
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
    editbox:setText(min)
    editbox:setFont(UIKit:getFontFilePath(),20)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.CENTER, slider:getCascadeBoundingBox().size.width+60,30):addTo(self)


    slider:onSliderValueChanged(function(event)
        editbox:setText(math.floor(event.value))
    end)
    slider:setSliderValue(min)

    local soldier_total_count = UIKit:ttfLabel({
        text = string.format(unit.."/ %d"..unit, max),
        size = 20,
        color = 0x403c2f
    }):addTo(slider)
        :align(display.LEFT_CENTER, slider:getCascadeBoundingBox().size.width+30,0)
    self:setContentSize(cc.size(slider:getCascadeBoundingBox().size.width,slider:getCascadeBoundingBox().size.height))
    self.soldier_total_count = soldier_total_count
end

function WidgetSliderWithInput:GetValue()
    return tonumber(self.editbox:getText())
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
function WidgetSliderWithInput:LayoutValueLabel(layout,offset)
    if WidgetSliderWithInput.STYLE_LAYOUT.TOP == layout then
        self.soldier_total_count:setPosition(self:getContentSize().width-self.soldier_total_count:getContentSize().width-10,offset)
        self.editbox:setPosition(self:getContentSize().width-self.soldier_total_count:getContentSize().width-10-60,offset)
    else
        self.soldier_total_count:setPosition(self.slider.scale9Size_[1]+30,0)
        self.editbox:setPosition(self.slider.scale9Size_[1]+60,30)
    end
    return self
end
function WidgetSliderWithInput:SetSliderSize(width, height)
    self.slider:setSliderSize(width, height)
    return self
end
function WidgetSliderWithInput:GetEditBoxPostion()
    return self.editbox:getPosition()
end

return WidgetSliderWithInput







