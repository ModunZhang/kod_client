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
	self.sprite = display.newSprite("logos/batcat.png", display.cx, display.cy):addTo(self)
	NetManager:connectGateServer(function(success)
		if not success then
			print("连接网关失败")
			return
		end
		print("连接网关成功")
	end)
end

function LogoScene:onExit()
	self.sprite = nil
end

return LogoScene