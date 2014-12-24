local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")

local WidgetPopDialog = UIKit:createUIClass("WidgetPopDialog", "UIAutoClose")

function WidgetPopDialog:ctor(height,title_text,y,title_bg)
    self.body = WidgetUIBackGround.new({height=height,isFrame="no"}):align(display.TOP_CENTER,display.cx,y or display.top-140)
    local body = self.body
    self:addTouchAbleChild(body)
    local rb_size = body:getContentSize()
    local title = display.newSprite(title_bg or "report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+10)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = title_text,
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    -- close button
    self.close_btn = WidgetPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width-36,rb_size.height+12):addTo(body)
end

function WidgetPopDialog:GetBody()
    return self.body
end
return WidgetPopDialog

