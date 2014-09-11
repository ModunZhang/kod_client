local TabButtons = class("TabButtons", function()
    return display.newNode()
end)
local origin_x = 20
local origin_y = 20
function TabButtons:ctor(buttons, tab_param, listener)
    local count = #buttons
    local tab_param = tab_param ~= nil and tab_param or {}
    local gap = tab_param.gap ~= nil and tab_param.gap or 0
    local margin_left = tab_param.margin_left ~= nil and tab_param.margin_left or 0
    local margin_right = tab_param.margin_right ~= nil and tab_param.margin_right or 0
    local margin_up = tab_param.margin_up ~= nil and tab_param.margin_up or 0
    local margin_down = tab_param.margin_down ~= nil and tab_param.margin_down or 0
    self.tabListener = listener

    
    local tab_bg = cc.ui.UIImage.new("tabs/tab_bg.png", {scale9 = true}):addTo(self):align(display.CENTER, 0, 0)
    tab_bg:setCapInsets(cc.rect(origin_x, origin_y, tab_bg:getContentSize().width - origin_x * 2, tab_bg:getContentSize().height - origin_y * 2))
    tab_bg:setContentSize(cc.size(tab_bg:getContentSize().width, tab_bg:getContentSize().height))

    local unit_len = tab_bg:getContentSize().width / count
    local unit_height = tab_bg:getContentSize().height
    local height = unit_height - margin_up - margin_down
    local y = -margin_up/2 + margin_down/2 + unit_height/2
    for i = 1, count do
        local tag = buttons[i].tag
        local label = buttons[i].label
        local is_default = buttons[i].default
        local x = unit_len/2 + unit_len * (i - 1)
        local button
        if i == 1 then
            x = x - gap/2 + margin_left
            button = cc.ui.UIPushButton.new(
                {normal = "tabs/tab_right.png",pressed = "tabs/tab_blank.png"}, 
                {scale9 = true})
            :addTo(tab_bg, 100)
            button:setScaleX(-1)
            button:setButtonSize(unit_len - gap/2 - margin_left, height)
        elseif i == count then
            x = x + gap/2 - margin_right
            button = cc.ui.UIPushButton.new(
                {normal = "tabs/tab_right.png", pressed = "tabs/tab_blank.png"}, 
                {scale9 = true})
            :addTo(tab_bg, 100)
            button:setButtonSize(unit_len - gap/2 - margin_right, height)
        else
            button = cc.ui.UIPushButton.new(
                {normal = "tabs/tab_middle.png", pressed = "tabs/tab_blank.png"}, 
                {scale9 = true})
            :addTo(tab_bg, 100)
            button:setButtonSize(unit_len - gap, height)
        end
        button:pos(x, y)
        button.tag = tag

        button.label = cc.ui.UILabel.new({text = label, size = 22, color = display.COLOR_BLACK})
        :addTo(tab_bg, 101)
        :align(display.CENTER, x, y)

        button:onButtonPressed(function(event)
            self:PushButton(event.target)
        end)
        if is_default then
            self:PushButton(button)
        end
    end
end
function TabButtons:PushButton(button)
    if self.push_button then
        if self.push_button == button then
            return 
        end
        self.push_button.label:setColor(display.COLOR_BLACK)
        self.push_button:setOpacity(255)
    end
    button.label:setColor(display.COLOR_WHITE)
    button:setOpacity(0)
    self.push_button = button
    if type(self.tabListener) == "function" then
        print("check")
        self.tabListener(self.push_button.tag)
    end
end

return TabButtons




