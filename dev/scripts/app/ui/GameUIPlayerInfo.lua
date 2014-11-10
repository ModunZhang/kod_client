--
-- Author: Your Name
-- Date: 2014-10-21 22:55:03
--
local GameUIPlayerInfo = UIKit:createUIClass("GameUIPlayerInfo")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local UIListView = import(".UIListView")
local UIScrollView = import(".UIScrollView")
local NetService = import('..service.NetService')
local AllianceMember = import('..entity.AllianceMember')
local GameUIWriteMail = import('.GameUIWriteMail')

function GameUIPlayerInfo:ctor(isOnlyMail,memberId)
	GameUIPlayerInfo.super.ctor(self)
	self.isOnlyMail_ = isOnlyMail or false
	self.memberId_ = memberId
end

function GameUIPlayerInfo:onMoveInStage()
	GameUIPlayerInfo.super.onMoveInStage(self)
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local main_height,main_y = 764,window.bottom + 120
	if self.isOnlyMail_ then
		main_height = 814
		main_y = window.bottom + 70
	end
	local bg = WidgetUIBackGround.new({height=main_height}):addTo(shadowLayer):pos(window.left+20,main_y)
	local title_bar = display.newSprite("alliance_blue_title_600x42.png")
		:addTo(bg)
		:align(display.LEFT_BOTTOM, 0, main_height - 15)
	

	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width+10, 0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	self.bg = bg
	self.title_bar = title_bar
	NetManager:getPlayerInfoPromise(self.memberId_):next(function(data)
       self:OnGetPlayerInfoSuccess(data)
    end):catch(function(err)
    	self:leftButtonClicked()
    end)
end

function GameUIPlayerInfo:BuildUI()
	UIKit:ttfLabel({
		text = self.player_info.name,
		size = 22,
		color = 0xffedae,
	}):align(display.LEFT_BOTTOM, 100, 10):addTo(self.title_bar)
	local icon = UIKit:GetPlayerCommonIcon():addTo(self.bg):align(display.LEFT_TOP, 20, self.title_bar:getPositionY()-10)
	local xp = display.newSprite("upgrade_experience_icon.png")
		:addTo(self.bg,2)
		:align(display.LEFT_TOP, icon:getPositionX()+icon:getContentSize().width+20,icon:getPositionY())
		:scale(0.7)
	local progress_bg = display.newSprite("Progress_bar_1.png")
		:addTo(self.bg)
		:align(display.LEFT_TOP, xp:getPositionX()+xp:getContentSize().width*0.7-10,xp:getPositionY()-5)
	local progress = UIKit:commonProgressTimer("Progress_bar_2.png")
		:addTo(progress_bg)
		:align(display.LEFT_BOTTOM, 0,1)
	progress:setPercentage(30)

	UIKit:ttfLabel({
		text = "LV " .. self.player_info.level,
		size = 20,
		color = 0xfff3c7,
		shadow = true,
	}):addTo(progress_bg,2):align(display.LEFT_BOTTOM, 10,5)
	-- TODO: 玩家经验
	UIKit:ttfLabel({
		text = "100/200000",
		size = 20,
		color = 0xfff3c7,
		shadow = true,
	}):addTo(progress_bg,2):align(display.RIGHT_BOTTOM,progress_bg:getContentSize().width - 10,5)

	--vip
	local vip_icon = display.newSprite("VIP_38x30.png")
		:addTo(self.bg)
		:align(display.LEFT_TOP,xp:getPositionX(),xp:getPositionY()-xp:getContentSize().height*0.7-10)
    -- TODO: 计算Vip等级
	local vip_lable = UIKit:ttfLabel({
		text = "VIP 5",
		size = 20,
		color = 0x403c2f,
	}):addTo(self.bg):align(display.LEFT_BOTTOM, vip_icon:getPositionX()+vip_icon:getContentSize().width + 10, vip_icon:getPositionY() - vip_icon:getContentSize().height)

	local id_label = UIKit:ttfLabel({
		text = "ID " .. self.player_info.id,
		size = 20,
		color = 0x403c2f,
	}):addTo(self.bg):align(display.RIGHT_BOTTOM, progress_bg:getPositionX()+progress_bg:getContentSize().width, vip_lable:getPositionY())

	local line_1 = display.newScale9Sprite("dividing_line_594x2.png"):addTo(self.bg)
		:align(display.LEFT_BOTTOM, vip_icon:getPositionX()+2, vip_icon:getPositionY() - vip_icon:getContentSize().height-5)
		:size(420,2)
	--power
	local power_icon = display.newSprite("upgrade_power_icon.png")
		:align(display.LEFT_TOP,vip_icon:getPositionX()+2,line_1:getPositionY()-2)
		:addTo(self.bg)
		:scale(0.5)

	local power_label = UIKit:ttfLabel({
		text = string.formatnumberthousands(self.player_info.power),
		size = 20,
		color = 0x403c2f,
	}):addTo(self.bg)
		:align(display.LEFT_BOTTOM, vip_lable:getPositionX(), power_icon:getPositionY() - power_icon:getContentSize().height*0.5)

	local line_2 = display.newScale9Sprite("dividing_line_594x2.png"):addTo(self.bg)
		:align(display.LEFT_BOTTOM, power_icon:getPositionX()+2, power_icon:getPositionY() - power_icon:getContentSize().height*0.5-5)
		:size(420,2)
	local listBg = display.newSprite("playerinfo_568x220.png")
		:addTo(self.bg)
		:align(display.LEFT_TOP,icon:getPositionX(),line_2:getPositionY()-10)
	self.listView = UIListView.new {
    	viewRect = cc.rect(0, 0,568,220),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(listBg)
	
	local green_title = display.newSprite("green_title_639x39.png")
		:align(display.LEFT_TOP,-20,listBg:getPositionY() - listBg:getContentSize().height - 5)
		:addTo(self.bg)
	UIKit:ttfLabel({
		text = _("MEDAL"),
		size = 28,
		color = 0xffeca5,
	}):align(display.CENTER, green_title:getContentSize().width/2, green_title:getContentSize().height/2):addTo(green_title)
    

    self.medalListView = UIListView.new {
    	viewRect = cc.rect(0, green_title:getPositionY()-green_title:getContentSize().height - 110,606,110),
        direction = UIScrollView.DIRECTION_HORIZONTAL,
    }:addTo(self.bg)

    for i=1,4 do
    	local item = self.medalListView:newItem()
    	item:addContent(display.newSprite("buff_background_112x110.png"))
    	item:setMargin({left = 20, right = 20, top = 0, bottom = 0})
    	item:setItemSize(112, 110)
    	self.medalListView:addItem(item)
    end

    self.medalListView:reload()
    
    local read_title = display.newSprite("red_title_638x69.png")
		:align(display.LEFT_TOP,-20,green_title:getPositionY()-green_title:getContentSize().height - 110)
		:addTo(self.bg)
	UIKit:ttfLabel({
		text = _("DAMNTION"),
		size = 28,
		color = 0xffeca5,
	}):align(display.CENTER, read_title:getContentSize().width/2, read_title:getContentSize().height/2):addTo(read_title)
    

    self.damntionListView = UIListView.new {
    	viewRect = cc.rect(0, read_title:getPositionY()-read_title:getContentSize().height - 116,606,116),
        direction = UIScrollView.DIRECTION_HORIZONTAL,
    }:addTo(self.bg)

    for i=1,4 do
    	local item = self.damntionListView:newItem()
    	item:addContent(display.newSprite("curse_background_114x116.png"))
    	item:setMargin({left = 20, right = 20, top = 0, bottom = 0})
    	item:setItemSize(114, 116)
    	self.damntionListView:addItem(item)
    end

    self.damntionListView:reload()

    if self.isOnlyMail_ then 
    	cc.ui.UIPushButton.new({normal="yellow_btn_up_149x47.png",pressed = "yellow_btn_down_149x47.png"})
    		:align(display.CENTER_BOTTOM,window.cx,10):addTo(self.bg)
    		:setButtonLabel("normal", UIKit:ttfLabel({
				text = _("邮件"),
				size = 18,
				color = 0xffedae,
			}))
			:onButtonClicked(function( event )
				self:OnPlayerButtonClicked(5)
			end)
    else
		for i=1,5 do
			local button = self:GetPlayerButton(i)
			button:pos((i-1)*128,window.bottom+2):addTo(self)
			button:onButtonClicked(function(event)
				self:OnPlayerButtonClicked(i)
			end)
		end
		display.newSprite("playerinfo_button_box_640x100.png"):align(display.LEFT_BOTTOM, window.left, window.bottom):addTo(self)
    end
end

function GameUIPlayerInfo:OnPlayerButtonClicked( tag )
	if tag == 1 then -- 踢出
        NetManager:getKickAllianceMemberOffPromise(self.memberId_)
           	:next(function(data)
           		self:leftButtonClicked()
           	end)
	elseif tag == 2 then -- 移交盟主
		local member = AllianceMember:DecodeFromJson(self.player_info)
		local alliacne =  Alliance_Manager:GetMyAlliance()
	 	local title = alliacne:GetMemeberById(member:Id()):Title()
        NetManager:getHandOverAllianceArchonPromise(member:Id())
                :next(function(data)
                   	self.player_info.title = title
	 	  			self:RefreshListView()
                end)
                :catch(function(err)
                    dump(err:reason())
                end)
	elseif tag == 3 then --降级
		local member = AllianceMember:DecodeFromJson(self.player_info)
		 if not member:IsTitleLowest() then
		 	  NetManager:getEditAllianceMemberTitlePromise(member:Id(), member:TitleDegrade()):next(function(data)
	 	  		local alliacne =  Alliance_Manager:GetMyAlliance()
	 	  		local title = alliacne:GetMemeberById(member:Id()):Title()
	 	  		self.player_info.title = title
	 	  		self:RefreshListView()
		 	  end)
		 end
	elseif tag == 4 then --晋级
		local member = AllianceMember:DecodeFromJson(self.player_info)
		if not member:IsTitleHighest() then
            NetManager:getEditAllianceMemberTitlePromise(member:Id(), member:TitleUpgrade()):next(function(data)
        		local alliacne =  Alliance_Manager:GetMyAlliance()
	 	  		local title = alliacne:GetMemeberById(member:Id()):Title()
	 	  		self.player_info.title = title
	 	  		self:RefreshListView()
            end)
        end
	elseif tag == 5 then
		local mail = GameUIWriteMail.new()
		mail:SetTitle(_("个人邮件"))
		mail:SetAddressee(self.player_info.name)
		mail:OnSendButtonClicked( GameUIWriteMail.SEND_TYPE.PERSONAL_MAIL)
		mail:addTo(self)
	end
end

function GameUIPlayerInfo:GetPlayerButton( index )
	local tempData = {
		{"shot_off_48x48.png",_("踢出")},
		{"transfer_48x48.png",_("移交盟主")},
		{"downgrade_48x48.png",_("降级")},
		{"promotion_48x48.png",_("晋级")},
		{"mail_48x48.png",_("邮件")}
	}
	local button = cc.ui.UIPushButton.new({normal="player_button_normal_128x94.png",pressed = "player_button_highlight_128x94.png"}
    			,{scale9 = false})
    		:align(display.LEFT_BOTTOM, 0, 0)
    	display.newSprite(tempData[index][1]):addTo(button):pos(64,57)
    	UIKit:ttfLabel({
			text = tempData[index][2],
			size = 18,
			color = 0xffedae,
		}):align(display.CENTER_BOTTOM,64, 10):addTo(button)
	return button
end

function GameUIPlayerInfo:GetIconByTitle( title )
	dump(title)
	local number_image = ""
	if title == 'archon' then
		number_image = "alliance_item_leader_39x39.png"
	elseif title == 'general' then -- 将军
		number_image = "5_23x24.png"
	elseif title == 'quartermaster' then
		number_image = "4_32x24.png"
	elseif title == 'supervisor' then
		number_image = "3_35x24.png"
	elseif title == 'elite' then
		number_image = "2_23x24.png"
	elseif title == 'member' then
		number_image = "1_11x24.png"
	end
	return number_image
end

function GameUIPlayerInfo:RefreshListView()
	local list = self:AdapterPlayerList()
	self.listView:removeAllItems()
	for i,v in ipairs(list) do
		local item = self.listView:newItem()
		local bg = display.newSprite(string.format("playerinfo_item_547x40_%d.png",i%2))
		UIKit:ttfLabel({
			text = v[1],
			size = 20,
			color = 0x797154,
		}):align(display.LEFT_BOTTOM,10,5):addTo(bg)

		local x = 537

		if v[1] == _("职位") then
			local icon = display.newSprite(self:GetIconByTitle(v[2])):align(display.RIGHT_BOTTOM, 537, 5)
			:addTo(bg)
			x = x - icon:getContentSize().width - 2
			v[2] = Alliance_Manager:GetMyAlliance():GetTitles()[v[2]]
		end
		UIKit:ttfLabel({
			text = v[2],
			size = 20,
			color = 0x403c2f,
		}):align(display.RIGHT_BOTTOM,x,5):addTo(bg)
		item:addContent(bg)
		item:setItemSize(547, 40)
		self.listView:addItem(item)
	end
	self.listView:reload()
end

function GameUIPlayerInfo:AdapterPlayerList()
	local player = self.player_info
	local r = {}
	table.insert(r,{_("职位"),player.title})
	table.insert(r,{_("联盟"),player.alliance})
	table.insert(r,{_("最后登陆时间"),NetService:formatTimeAsTimeAgoStyleByServerTime(player.lastLoginTime)})
	table.insert(r,{_("战斗力"),player.power})
	--TODO: 玩家击杀数量

	return r
end

function GameUIPlayerInfo:OnGetPlayerInfoSuccess(data)
	self.player_info = data
	self:BuildUI()
	self:RefreshListView()
end

function GameUIPlayerInfo:onMoveOutStage()
	GameUIPlayerInfo.super.onMoveOutStage(self)
end


return GameUIPlayerInfo