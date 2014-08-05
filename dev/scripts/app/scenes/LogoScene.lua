--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)

function LogoScene:ctor()

end

function LogoScene:onEnter()
	self.sprite = display.newSprite("images/batcat.png", display.cx, display.cy):addTo(self)
	self:performWithDelay(function()
		app:enterScene("UpdaterScene", nil, "fade", 0.6, display.COLOR_WHITE)
	end, 0.8)	
end

function LogoScene:onExit()
	self.sprite = nil
	print('LogoScene:onExit')
end

return LogoScene