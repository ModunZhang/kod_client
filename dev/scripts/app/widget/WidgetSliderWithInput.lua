local WidgetSlider = import("..widget.WidgetSlider")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetInput = import("..widget.WidgetInput")
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


    -- local function edit(event, editbox)
    --     local text = tonumber(editbox:getText()) or min
    --     if event == "began" then
    --         if min==text then
    --             editbox:setText("")
    --         end
    --     elseif event == "changed" then
    --         if text then
    --             if text > max then
    --                 editbox:setText(max)
    --             end
    --         end
    --     elseif event == "ended" then
    --         if editbox:getText()=="" or min>text then
    --             editbox:setText(min)
    --         end
    --         local edit_value = tonumber(editbox:getText())
    --         editbox:setText(edit_value)

    --         local slider_value = slider:getSliderValue()
    --         print("edit_value=",edit_value,"slider_value=",slider_value)
    --         if edit_value ~= slider_value then
    --             slider.fsm_:doEvent("press")
    --             slider:setSliderValue(edit_value)
    --             slider.fsm_:doEvent("release")
    --             if self.sliderReleaseEventListener then
    --                 self.sliderReleaseEventListener()
    --             end
    --         end
    --     end
    -- end

    local text_btn = WidgetPushButton.new({normal = "back_ground_83x32.png",pressed = "back_ground_83x32.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local p = {
                    current = math.floor(slider:getSliderValue()),
                    max=max,
                    min=min,
                    unit=unit,
                    callback = function ( edit_value )
                        if edit_value ~= slider_value then
                            slider.fsm_:doEvent("press")
                            slider:setSliderValue(edit_value)
                            slider.fsm_:doEvent("release")
                            if self.sliderReleaseEventListener then
                                self.sliderReleaseEventListener()
                            end
                        end
                    end
                }
                WidgetInput.new(p):addToCurrentScene()
            end
        end):align(display.CENTER, slider:getCascadeBoundingBox().size.width,30):addTo(self)
    self.btn_text = UIKit:ttfLabel({
        text = min,
        size = 22,
        color = 0x403c2f,
    }):addTo(text_btn):align(display.CENTER)
    self.text_btn = text_btn

    slider:onSliderValueChanged(function(event)
        self.btn_text:setString(math.floor(event.value))
    end)
    slider:setSliderValue(min)

    local soldier_total_count = UIKit:ttfLabel({
        text = string.format(unit.."/ %d"..unit, max),
        size = 20,
        color = 0x403c2f
    }):addTo(slider)
        :align(display.RIGHT_CENTER, slider:getCascadeBoundingBox().size.width,0)
    self:setContentSize(cc.size(slider:getCascadeBoundingBox().size.width,slider:getCascadeBoundingBox().size.height))
    self.soldier_total_count = soldier_total_count
end
function WidgetSliderWithInput:SetValue(value)
    self.slider:setSliderValue(value)
end
function WidgetSliderWithInput:GetValue()
    return tonumber(math.floor(self.slider:getSliderValue()))
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
        self.btn_text:setString(math.floor(event.value))
        func(event)
    end)
    return self
end
function WidgetSliderWithInput:LayoutValueLabel(layout,offset)
    if WidgetSliderWithInput.STYLE_LAYOUT.TOP == layout then
        self.soldier_total_count:setPosition(self:getContentSize().width,offset)
        self.text_btn:setPosition(self:getContentSize().width-self.soldier_total_count:getContentSize().width-10-60,offset)
    else
        self.soldier_total_count:setPosition(self.slider.scale9Size_[1]+80,0)
        self.text_btn:setPosition(self.slider.scale9Size_[1]+60,30)
    end
    return self
end
function WidgetSliderWithInput:SetSliderSize(width, height)
    self.slider:setSliderSize(width, height)
    return self
end
function WidgetSliderWithInput:GetEditBoxPostion()
    return self.text_btn:getPosition()
end

return WidgetSliderWithInput










