--
-- Author: Your Name
-- Date: 2014-10-21 16:33:31
--
local WidgetPushButton = import(".WidgetPushButton")
local WidgetPushTransparentButton = class("WidgetPushTransparentButton",WidgetPushButton)

function WidgetPushTransparentButton:ctor(rect)
	WidgetPushTransparentButton.super.ctor(self,{normal = "transparent_1x1.png"},{scale9 = true})
	self:setButtonSize(rect.width, rect.height)
end

return WidgetPushTransparentButton