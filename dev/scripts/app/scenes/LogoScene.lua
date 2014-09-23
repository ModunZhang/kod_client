--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
local WidgetRecruitSoldier = import("..widget.WidgetRecruitSoldier")
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)

function LogoScene:ctor()
end

function LogoScene:onEnter()
    self.sprite = display.newScale9Sprite("logos/batcat.png", display.cx, display.cy):addTo(self)
    self.sprite:size(display.width,self.sprite:getContentSize().height)
    self:performWithDelay(function()
    		if CONFIG_IS_DEBUG then
    			app:enterScene("MainScene", nil, "fade", 0.6, display.COLOR_WHITE)
    		else
    			app:enterScene("UpdaterScene", nil, "fade", 0.6, display.COLOR_WHITE)
    		end
    	end, 0.8)

    -- WidgetRecruitSoldier.new("swordsman", 1, 100):addTo(self):align(display.CENTER, display.cx, 500 / 2)
end

function LogoScene:onExit()
    self.sprite = nil
end

return LogoScene

