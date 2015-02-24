--
-- Author: Danny He
-- Date: 2015-02-24 15:14:22
--
local GameUISettingServer = UIKit:createUIClass("GameUISettingServer")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")

function GameUISettingServer:onEnter()
	GameUISettingServer.super.onEnter(self)
	self.server_code = 1
	self:BuildUI()
end

function GameUISettingServer:BuildUI()
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local bg = WidgetUIBackGround.new({height=762}):addTo(shadowLayer)
	bg:pos(((display.width - bg:getContentSize().width)/2),window.bottom_top)
	local titleBar = display.newSprite("alliance_blue_title_600x42.png"):align(display.LEFT_BOTTOM,3,747):addTo(bg)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(titleBar)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width,0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	UIKit:ttfLabel({
		text = _("选择服务器"),
		size = 22,
		shadow = true,
		color = 0xffedae
	}):addTo(titleBar):align(display.CENTER,300,24)
	WidgetPushButton.new({normal = 'yellow_btn_up_185x65.png',pressed = 'yellow_btn_down_185x65.png'})
		:align(display.BOTTOM_CENTER, 304, 16)
		:addTo(bg)
		:setButtonLabel("normal", UIKit:commonButtonLable({
			text = _("切换服务器"),
		}))
		:onButtonClicked(function()
			GameGlobalUI:showTips("提示","功能还未实现")
		end)
	self.list_view = UIListView.new{
        viewRect = cc.rect(26,90,556,650),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        -- bgColor = UIKit:hex2c4b(0x7a000000),
    }:addTo(bg):onTouch(handler(self, self.listviewListener))
    self:FetchServers()
end

function GameUISettingServer:FetchServers()
	local servers = {
		{name = "世界01",isNew = true,isIn = true,isOwn = true,code = 1},
		{name = "世界02",isNew = true,isIn = false,isOwn = true,code = 2},
		{name = "世界03",isNew = true,isIn = false,isOwn = false,code = 3},
	}
	self.data = servers
	self:RefreshList()
end

function GameUISettingServer:RefreshList()
	self.list_view:removeAllItems()
	for __,v in ipairs(self.data) do
		local item = self:GetItem(v)
		self.list_view:addItem(item)
	end
	self.list_view:reload()
end

function GameUISettingServer:GetItem(v)
	local item = self.list_view:newItem()
	local content = UIKit:CreateBoxPanelWithBorder({width = 556,height = 96})
	local name_label = UIKit:ttfLabel({
		text = v.name,
		size = 24,
		color= 0x514d3e
	}):align(display.LEFT_TOP,16, 80):addTo(content)
	if v.isNew then
		UIKit:ttfLabel({
			text = _("(新!)"),
			size = 22,
			color= 0x318200
		}):align(display.LEFT_TOP,name_label:getPositionX()+name_label:getContentSize().width + 10, 80):addTo(content)
	end
	if v.isIn then
		UIKit:ttfLabel({
			text = _("您在这里"),
			size = 22,
			color= 0x318200
		}):align(display.LEFT_BOTTOM,16,15):addTo(content)
	elseif v.isOwn then
		UIKit:ttfLabel({
			text = _("您拥有一片领地"),
			size = 22,
			color= 0x076886
		}):align(display.LEFT_BOTTOM,16,15):addTo(content)
	else
		UIKit:ttfLabel({
			text = _("未开垦"),
			size = 22,
			color= 0x514d3e
		}):align(display.LEFT_BOTTOM,16,15):addTo(content)
	end
	local check_bg = display.newSprite("activity_check_bg_55x51.png"):align(display.RIGHT_CENTER, 542,48):addTo(content)
	local check_body = display.newSprite("activity_check_body_55x51.png"):addTo(check_bg):pos(27,25)
	check_body:setVisible(self.server_code == v.code)
	item:addContent(content)
	item:setMargin({left = 0, right = 0, top = 0, bottom = 8})
	item:setItemSize(556,96,false)
	return item
end

function GameUISettingServer:listviewListener(event)
    local listView = event.listView
    if "clicked" == event.name then
    	local server = self.data[event.itemPos]
    	self.server_code = server.code
		self:RefreshList()    	
    end
end

return GameUISettingServer