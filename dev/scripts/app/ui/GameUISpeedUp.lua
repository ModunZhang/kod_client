--
-- Author: Kenny Dai
-- Date: 2015-02-10 19:58:38
--
local WidgetSpeedUp = import("..widget.WidgetSpeedUp")
local window = import("..utils.window")
local GameUISpeedUp = class("GameUISpeedUp", WidgetSpeedUp)

function GameUISpeedUp:ctor(event)
	GameUISpeedUp.super.ctor(self)
	
end

return GameUISpeedUp