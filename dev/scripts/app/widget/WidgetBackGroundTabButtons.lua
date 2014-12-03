local WidgetTab = import(".WidgetTab")
local WidgetBackGroundTabButtons = class("WidgetBackGroundTabButtons", function()
    return display.newNode()
end)

function WidgetBackGroundTabButtons:ctor(buttons, listener)
    self.tabListener = listener
    local width = 578
    local node = display.newNode():addTo(self)
    self.node = node

    local unit_width = width / #buttons
    local origin_x = - width / 2
    local tabs = {}
    local default
    for i, v in ipairs(buttons) do
        local widget = WidgetTab.new({
            on = "tab_btn_down_140x60.png", 
            off = "tab_btn_up_140x60.png",
        }, unit_width, 60)
            :addTo(node)
            :align(display.LEFT_CENTER, origin_x + unit_width * (i - 1), 18)
            :OnTabPress(handler(self, self.OnTabClicked))

        widget.tag = v.tag
        widget.label = cc.ui.UILabel.new({text = v.label, size = 22, color = UIKit:hex2c3b(0xa0956e)})
            :addTo(widget)
            :align(display.CENTER, unit_width/2, 0)
        if v.default then
            default = widget
        end
        table.insert(tabs, widget)
    end
    self.tabs = tabs
    -- cc.ui.UIImage.new("decorator_21x62.png"):addTo(node):align(display.LEFT_CENTER, -width/2, 0)
    -- cc.ui.UIImage.new("decorator_21x62.png"):addTo(node):align(display.RIGHT_CENTER, width/2, 0):flipX(true)

    if default then
        self:PushButton(default)
    end
end
function WidgetBackGroundTabButtons:SelectTab(tag)
    for _, tab in pairs(self.tabs) do
        if button.tag == tag then
            self:PushButton(button)
            return
        end
    end
end
function WidgetBackGroundTabButtons:PushButton(tab)
    for _, v in pairs(self.tabs) do
        if v ~= tab then
            v:Enable(true)
            v:SetStatus(false)
            v.label:setColor(UIKit:hex2c3b(0xa0956e))
        else
            v:Enable(false)
            v:SetStatus(true)
            v.label:setColor(UIKit:hex2c3b(0xffedae))
        end
    end
    self:OnSelectTag(tab.tag)
end
function WidgetBackGroundTabButtons:OnTabClicked(widget, is_pressed)
    self:PushButton(widget)
end
function WidgetBackGroundTabButtons:OnSelectTag(tag)
    if type(self.tabListener) == "function" then
        self.tabListener(tag)
    end
end

function WidgetBackGroundTabButtons:GetSelectedButtonTag()
    for _, v in pairs(self.tabs) do
        if v.pressed then
            return v.tag
        end
    end
end

return WidgetBackGroundTabButtons



















































