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
local WidgetPlayerNode = import("..widget.WidgetPlayerNode")
local WidgetPushButton = import("..widget.WidgetPushButton")
local Localize = import("..utils.Localize")
function GameUIPlayerInfo:ctor(isOnlyMail,memberId)
	GameUIPlayerInfo.super.ctor(self)
	self.isOnlyMail_ = isOnlyMail or false
	self.memberId_ = memberId
end

function GameUIPlayerInfo:onMoveInStage()
	GameUIPlayerInfo.super.onMoveInStage(self)
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local main_height,min_y = 860,window.bottom + 10


	local bg = WidgetUIBackGround.new({height=main_height}):addTo(shadowLayer):pos(window.left+20,min_y)
	local title_bar = display.newSprite("alliance_blue_title_600x42.png")
		:addTo(bg)
		:align(display.LEFT_BOTTOM, 0, main_height - 15)
	
	UIKit:closeButton():align(display.RIGHT_BOTTOM,600,0):addTo(title_bar):onButtonClicked(function()
		self:leftButtonClicked()
	end)
	UIKit:ttfLabel({
		text = _("玩家信息"),
		size = 24,
		color = 0xffedae,
	}):align(display.CENTER, 300, 21):addTo(title_bar)
	self.bg = bg
	self.title_bar = title_bar

	NetManager:getPlayerInfoPromise(self.memberId_):next(function(data)
       self:OnGetPlayerInfoSuccess(data)
    end):catch(function(err)
    	self:leftButtonClicked()
    end)
end

function GameUIPlayerInfo:BuildUI()
	-- self.mail_button = 
	local titles =  {_("逐出"),_("移交盟主"),_("降级"),_("晋级"),_("邮件"),}
	local x,y = 15,15
	for i = 1,5 do
		WidgetPushButton.new({normal = "player_ operate_n_116x64.png",pressed = "player_ operate_h_116x64.png"})
			:align(display.LEFT_BOTTOM, x + (i - 1)*116, y)
			:addTo(self.bg)
			:setButtonLabel("normal", UIKit:ttfLabel({
               	text = titles[i],
               	size = 18,
               	color= 0xffedae,
               	shadow= true
			}))
			:onButtonClicked(function()
				self:OnPlayerButtonClicked(i)
			end)
	end
	local player_node = WidgetPlayerNode.new(cc.size(564,760),self)
		:addTo(self.bg):pos(22,79)
	self.player_node = player_node
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
	self.player_node:RefreshUI()
end

function GameUIPlayerInfo:AdapterPlayerList()
	local player = self.player_info
	local r = {}
	table.insert(r,{_("职位"),Localize.alliance_title[player.title]})
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



--WidgetPlayerNode的回调方法
--点击勋章
function GameUIPlayerInfo:WidgetPlayerNode_OnMedalButtonClicked(index)
	print("OnMedalButtonClicked-->",index)
end
-- 点击头衔
function GameUIPlayerInfo:WidgetPlayerNode_OnTitleButtonClicked()
	print("OnTitleButtonClicked-->")
end
--修改头像
function GameUIPlayerInfo:WidgetPlayerNode_OnPlayerIconCliked()
	print("WidgetPlayerNode_OnPlayerIconCliked-->")
end
--修改玩家名
function GameUIPlayerInfo:WidgetPlayerNode_OnPlayerNameCliked()
	print("WidgetPlayerNode_OnPlayerNameCliked-->")
end
--决定按钮是否可以点击
function GameUIPlayerInfo:WidgetPlayerNode_PlayerCanClickedButton(name,args)
	print("WidgetPlayerNode_PlayerCanClickedButton-->",name)
	if name == 'Medal' then --点击勋章
		return true
	elseif name == 'PlayerIcon' then --修改头像
		return false
	elseif name == 'PlayerTitle' then -- 点击头衔
		return true
	elseif name == 'PlayerName' then --修改玩家名
		return false
	end

end
--数据回调
function GameUIPlayerInfo:WidgetPlayerNode_DataSource(name)
	if name == 'BasicInfoData' then
		return {
			name = self.player_info.name,
			lv = self.player_info.level,
			currentExp = 50,
			maxExp = 100,
			power = self.player_info.power,
			playerId = self.player_info.id,
			playerIcon = "xxx.png",
			vip = "88"
		}
	elseif name == "MedalData"  then
		return {} -- {"xx.png","xx.png"}
	elseif name == "TitleData"  then
		return {} -- {image = "xxx.png",desc = "我是头衔"} 
	elseif name == "DataInfoData"  then
		return self:AdapterPlayerList() -- {{"职位","将军"},{"职位","将军"},{"职位","将军"}}
	end
end

return GameUIPlayerInfo
