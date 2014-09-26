local WidgetTab = class("WidgetTab", function()
    return display.newNode()
end)


function WidgetTab:ctor(param, width, height)
    self.pressed = false
    local png = param.tab

    self.back_ground = display.newLayer():addTo(self)
    self.tab = cc.ui.UICheckBoxButton.new(param)
        :addTo(self.back_ground)
        :align(display.LEFT_BOTTOM)
        :setButtonSelected(self.pressed)
    self.tab:setTouchEnabled(false)

    if png then
        cc.ui.UIImage.new(png):addTo(self):align(display.CENTER, width/2, height/2)
    end

    self.back_ground:setContentSize(cc.size(width, height))
    self.back_ground:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" and
            self.back_ground:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then
            self.pressed = not self.pressed
            self:SetStatus(self.pressed)
            if type(self.tab_press) == "function" then
                self:tab_press(self.pressed)
            end
            return false
        end
    end)
end
function WidgetTab:OnTabPress(func)
    self.tab_press = func
    return self
end
function WidgetTab:Enable(trueOrFlase)
    self.back_ground:setTouchEnabled(trueOrFlase)
    return self
end
function WidgetTab:SetStatus(is_pressed)
    self.tab:setButtonSelected(is_pressed)
    self.pressed = is_pressed
    return self
end
function WidgetTab:IsPressed()
    return self.pressed
end

function WidgetTab:align(anchorPoint, x, y)
    local size = self.back_ground:getContentSize()
    local point = display.ANCHOR_POINTS[anchorPoint]
    local offset_x, offset_y = size.width * point.x, size.height * point.y
    self.back_ground:setPosition(- offset_x, - offset_y)
    if x and y then self:setPosition(x, y) end
    return self
end





return WidgetTab






