--
-- Author: Kenny Dai
-- Date: 2015-10-21 22:32:40
--
local window = import("..uitils.window")

local WidgetShortcutButtons = function ()
	local layer = display.newLayer()
    layer:setContentSize(cc.size(display.width, display.height))
    layer:setNodeEventEnabled(true)
	return layer
end

function WidgetShortcutButtons:ctor()
	
end

function WidgetShortcutButtons:onEnter()
end
function WidgetShortcutButtons:onExit()
end


return WidgetShortcutButtons