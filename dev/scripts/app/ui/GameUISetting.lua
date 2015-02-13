--
-- Author: Danny He
-- Date: 2015-02-10 09:54:53
--
local GameUISetting = UIKit:createUIClass("GameUISetting","GameUIWithCommonHeader")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")

function GameUISetting:ctor(city)
	 GameUISetting.super.ctor(self,city, _("设置"))
end

function GameUISetting:onEnter()
	GameUISetting.super.onEnter(self)
	self:BuildUI()
end


function GameUISetting:BuildUI()
	UIKit:ttfLabel({
		text = "世界时间:" ..  os.date('!%Y-%m-%d %H:%M:%S', app.timer:GetServerTime())
	}):align(display.TOP_CENTER, window.cx, window.top_bottom):addTo(self)
	local buttons = {
		{text = "账号绑定"},
		{text = "选择服务器"},
		{text = "语言"},
		{text = "游戏说明"},
		{text = "个人排行榜"},
		{text = "联盟排行榜"},
		{text = "声音"},
		{text = "音效"},
		{text = "推送通知"},
		{text = "已屏蔽用户"},
		{text = "遇到问题"},
	}
	local index = 0
	local x,y = window.left + 50,window.top_bottom - 100
	for i,v in ipairs(buttons) do
		if index % 3 == 0 and index ~= 0 then
			x = window.left + 50
			y = y - 100
		end
		WidgetPushButton.new(
	        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
	        {scale9 = false}
    	):setButtonLabel(UIKit:commonButtonLable({
    		color = 0xfff3c7,
    		text = v.text
    	}))
        :addTo(self)
        :align(display.LEFT_TOP,x, y)
        :onButtonClicked(function(event)
           
        end)
		x = x + 180
		index = index + 1
	end
end

return GameUISetting