--
-- Author: Kenny Dai
-- Date: 2015-04-10 14:45:34
--
local promise = import("..utils.promise")
local WidgetTab = import(".WidgetTab")
local WidgetRoundTabButtons = class("WidgetRoundTabButtons", function()
    return display.newSprite("back_ground_564x74.png")
end)

function WidgetRoundTabButtons:ctor(buttons, listener)
    self.callbacks = {}
    self.tabListener = listener
    local width = 548
    local node = display.newNode():addTo(self)
    self.node = node

    local unit_width = width / #buttons
    local origin_x = 7
    local tabs = {}
    local default

    for i, v in ipairs(buttons) do
    	local images = i ==1 and {
            on = "tab_btn_up_106x58.png", 
            off = "tab_btn_down_106x58.png",
        } or i == #buttons and {
            on = "tab_btn_up_106x58_1.png", 
            off = "tab_btn_down_106x58_1.png",
        }
        or {
            on = "tab_btn_up_110x58.png", 
            off = "tab_btn_down_110x58.png",
        } 
        
        local widget = WidgetTab.new(images, unit_width, 60)
            :addTo(node)
            :align(display.LEFT_CENTER, origin_x + unit_width * (i - 1)+(i~=1 and 1 or 0), 37)
            :OnTabPress(handler(self, self.OnTabClicked))
        widget.tag = v.tag
        widget.label = UIKit:ttfLabel({text = v.label, size = 22, color = 0xa0956e})
            :addTo(widget)
            :align(display.CENTER, unit_width/2, 0)
        if v.default then
            default = widget
        end
        table.insert(tabs, widget)
    end
    self.tabs = tabs

    if default then
        self:PushButton(default)
    end
end

function WidgetRoundTabButtons:PushButton(tab)
    for _, v in pairs(self.tabs) do
        if v ~= tab then
            v:Enable(true):Active(false)
            v.label:setColor(UIKit:hex2c3b(0x403c2f))
        else
            v:Enable(false):Active(true)
            v.label:setColor(UIKit:hex2c3b(0x00c0ff))
        end
    end
    self:OnSelectTag(tab.tag)
end
function WidgetRoundTabButtons:OnTabClicked(widget, is_pressed)
    if self.tab_button_will_select_event_listener 
        and type(self.tab_button_will_select_event_listener) == 'function' and is_pressed then
        if self.tab_button_will_select_event_listener(widget.tag) then
            self:PushButton(widget)
        else
            widget:Enable(true):Active(false)
            widget.label:setColor(UIKit:hex2c3b(0x403c2f))
        end
    else
        self:PushButton(widget)
    end
end
function WidgetRoundTabButtons:OnSelectTag(tag)
    if type(self.tabListener) == "function" then
        self.tabListener(tag)
    end
    self:CheckTag(tag)
end

function WidgetRoundTabButtons:GetSelectedButtonTag()
    for _, v in pairs(self.tabs) do
        if v.pressed then
            return v.tag
        end
    end
end
function WidgetRoundTabButtons:GetTabByTag(tag)
    for _, v in pairs(self.tabs) do
        if v.tag == tag then
            return v
        end
    end
    return nil
end
function WidgetRoundTabButtons:CheckTag(tag)
    local callbacks = self.callbacks
    if #callbacks > 0 and callbacks[1](tag) then
        table.remove(callbacks, 1)
    end
end

function WidgetRoundTabButtons:SetTabButtonWillSelectListener(func)
    self.tab_button_will_select_event_listener = func
    return self
end
return WidgetRoundTabButtons


