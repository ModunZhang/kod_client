--
-- Author: Your Name
-- Date: 2014-10-21 22:55:03
--
local GameUIAllianceMemberInfo = UIKit:createUIClass("GameUIAllianceMemberInfo")
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
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")

function GameUIAllianceMemberInfo:ctor(isMyAlliance,memberId)
	GameUIAllianceMemberInfo.super.ctor(self)
	self.isMyAlliance = isMyAlliance or false
	self.memberId_ = memberId
end

function GameUIAllianceMemberInfo:onMoveInStage()
	GameUIAllianceMemberInfo.super.onMoveInStage(self)
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
    	dump(err,"err--->")
    	self:leftButtonClicked()
    end)
end

function GameUIAllianceMemberInfo:BuildUI()
	if self.isMyAlliance then
		if not Alliance_Manager:GetMyAlliance():GetSelf():CanHandleAllianceApply() then
			  WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
	            :setButtonLabel(
	                UIKit:ttfLabel({
	                    text = _("邮件"),
	                    size = 20,
	                    shadow = true,
	                    color = 0xfff3c7
	                })
	            )
	            :align(display.CENTER_BOTTOM,self.bg:getContentSize().width/2,15)
	            :onButtonClicked(function(event)
	            	self:OnPlayerButtonClicked(5)
	            end)
	            :addTo(self.bg)
		else
			local titles =  {_("逐出"),_("移交盟主"),_("降级"),_("晋级"),_("邮件"),}
			local x,y = 15,15
			for i = 1,5 do
				WidgetPushButton.new({normal = "player_operate_n_116x64.png",pressed = "player_operate_h_116x64.png"})
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
		end
	else
		WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
	            :setButtonLabel(
	                UIKit:ttfLabel({
	                    text = _("邮件"),
	                    size = 20,
	                    shadow = true,
	                    color = 0xfff3c7
	                })
	            )
	            :align(display.CENTER_BOTTOM,self.bg:getContentSize().width/2,15)
	            :onButtonClicked(function(event)
	            	self:OnPlayerButtonClicked(5)
	            end)
	            :addTo(self.bg)
	end
	local player_node = WidgetPlayerNode.new(cc.size(564,760),self)
		:addTo(self.bg):pos(22,79)
	self.player_node = player_node
end

function GameUIAllianceMemberInfo:OnPlayerButtonClicked( tag )
	local can_do,msg = self:CheckPlayerAuthor(tag)
	if not can_do then
		self:ShowMessage(msg)
		return
	end
	local member = AllianceMember:DecodeFromJson(self.player_info)
	if tag == 1 then -- 踢出
       self:ShowSureDialog(string.format(_("您确定逐出玩家:%s?"),member:Name()),function()
       		self:SendToServerWithTag(tag,member)
       end)
	elseif tag == 2 then -- 移交盟主
	   self:ShowSureDialog(string.format(_("您确定移交盟主职位给:%s?"),member:Name()),function()
       		self:SendToServerWithTag(tag,member)
       end)
	elseif tag == 3 then --降级
	  self:ShowSureDialog(string.format(_("您确定设置玩家%s职位为:%s?"),member:Name(),Localize.alliance_title[member:TitleDegrade()]),function()
       		self:SendToServerWithTag(tag,member)
       end)
	elseif tag == 4 then --晋级
		self:ShowSureDialog(string.format(_("您确定设置玩家%s职位为:%s?"),member:Name(),Localize.alliance_title[member:TitleUpgrade()]),function()
       		self:SendToServerWithTag(tag,member)
       end)
	else
		self:SendToServerWithTag(tag,member)
	end
	
end

function GameUIAllianceMemberInfo:SendToServerWithTag(tag,member)
	if tag == 1 then -- 踢出
        NetManager:getKickAllianceMemberOffPromise(member:Id())
           	:next(function(data)
           		self:leftButtonClicked()
           	end)
	elseif tag == 2 then -- 移交盟主
        NetManager:getHandOverAllianceArchonPromise(member:Id())
                :next(function(data)
                	local alliacne =  Alliance_Manager:GetMyAlliance()
	 	  			local title = alliacne:GetMemeberById(member:Id()):Title()
                   	self.player_info.title = title
	 	  			self:RefreshListView()
	 	  			self:leftButtonClicked()	
                end)
                :catch(function(err)
                    dump(err:reason())
                end)
	elseif tag == 3 then --降级
		 if not member:IsTitleLowest() then
		 	  NetManager:getEditAllianceMemberTitlePromise(member:Id(), member:TitleDegrade()):next(function(data)
	 	  		local alliacne =  Alliance_Manager:GetMyAlliance()
	 	  		local title = alliacne:GetMemeberById(member:Id()):Title()
	 	  		self.player_info.title = title
	 	  		self:RefreshListView()
		 	  end)
		 end
	elseif tag == 4 then --晋级
		if not member:IsTitleHighest() then
            NetManager:getEditAllianceMemberTitlePromise(member:Id(), member:TitleUpgrade()):next(function(data)
        		local alliacne =  Alliance_Manager:GetMyAlliance()
	 	  		local title = alliacne:GetMemeberById(member:Id()):Title()
	 	  		self.player_info.title = title
	 	  		self:RefreshListView()
            end)
        end
	elseif tag == 5 then
		local mail = GameUIWriteMail.new(GameUIWriteMail.SEND_TYPE.PERSONAL_MAIL)
		mail:SetTitle(_("个人邮件"))
		mail:SetAddressee(self.player_info.name)
		-- mail:OnSendButtonClicked( GameUIWriteMail.SEND_TYPE.PERSONAL_MAIL)
		mail:addTo(self)
	end
end

function GameUIAllianceMemberInfo:RefreshListView()
	self.player_node:RefreshUI()
end

function GameUIAllianceMemberInfo:AdapterPlayerList()
	local player = self.player_info
	local r = {}
	table.insert(r,{_("职位"),Localize.alliance_title[player.title]})
	table.insert(r,{_("联盟"),player.alliance})
	table.insert(r,{_("最后登陆时间"),NetService:formatTimeAsTimeAgoStyleByServerTime(player.lastLoginTime)})
	table.insert(r,{_("战斗力"),player.power})
	table.insert(r,{_("击杀"),player.kill})

	return r
end

function GameUIAllianceMemberInfo:OnGetPlayerInfoSuccess(data)
	self.player_info = data
	self:BuildUI()
	self:RefreshListView()
end

function GameUIAllianceMemberInfo:onMoveOutStage()
	GameUIAllianceMemberInfo.super.onMoveOutStage(self)
end



--WidgetPlayerNode的回调方法
--点击勋章
function GameUIAllianceMemberInfo:WidgetPlayerNode_OnMedalButtonClicked(index)
end
-- 点击头衔
function GameUIAllianceMemberInfo:WidgetPlayerNode_OnTitleButtonClicked()
end
--修改头像
function GameUIAllianceMemberInfo:WidgetPlayerNode_OnPlayerIconCliked()
end
--修改玩家名
function GameUIAllianceMemberInfo:WidgetPlayerNode_OnPlayerNameCliked()
end
--决定按钮是否可以点击
function GameUIAllianceMemberInfo:WidgetPlayerNode_PlayerCanClickedButton(name,args)
	if name == 'Medal' then --点击勋章
		return true
	elseif name == 'PlayerIcon' then --修改头像
		return false
	elseif name == 'PlayerTitle' then -- 点击头衔
		return true
	elseif name == 'PlayerIDCopy' then --复制玩家ID
	    return true
	elseif name == 'PlayerName' then --修改玩家名
		return false
	end

end
--数据回调
function GameUIAllianceMemberInfo:WidgetPlayerNode_DataSource(name)
	if name == 'BasicInfoData' then
		return {
			name = self.player_info.name,
			lv = User:GetPlayerLevelByExp(self.player_info.levelExp),
			currentExp = 50,
			maxExp = 100,
			power = self.player_info.power,
			playerId = self.player_info.id,
			playerIcon = "xxx.png",
			vip = "88"
		}
	elseif name == "MedalData"  then
		return {} 
	elseif name == "TitleData"  then
		return {} 
	elseif name == "DataInfoData"  then
		return self:AdapterPlayerList() 
	end
end

function GameUIAllianceMemberInfo:CheckPlayerAuthor(button_tag)
	local can_do,msg = true,""
	local me = Alliance_Manager:GetMyAlliance():GetSelf()
	local member = AllianceMember:DecodeFromJson(self.player_info)
	if button_tag == 1 then
		local auth,title_can = me:CanKickOutMember(member:Title())
		can_do = auth and title_can
		if not title_can then
			msg = _("您不能操作此等级成员")
		end
		if not auth then
			msg = _("您没有此权限")
		end
	elseif button_tag == 2 then
		can_do = me:CanGiveUpArchon()
		msg = _("您不是盟主")
	elseif button_tag == 3 then
		local auth,title_can = me:CanDemotionMemberLevel(member:Title())
		local isLow = member:IsTitleLowest()
		can_do = auth and title_can and not isLow
		if not title_can then
			msg = _("您不能操作此等级成员")
		end
		if isLow then
			msg = _("该成员已经是最低等级")
		end
		if not auth then
			msg = _("您没有此权限")
		end
	elseif button_tag == 4 then
		local auth,title_can = me:CanUpgradeMemberLevel(member:TitleUpgrade())
		local isHighest = member:IsTitleHighest()
		can_do = auth and title_can and not isHighest
		
		if not title_can then
			msg = _("您不能操作此等级成员")
		end
		if isHighest then
			msg = _("该成员已经是最高等级")
		end
		if not auth then
			msg = _("您没有此权限")
		end
	end
	return can_do,msg
end

function GameUIAllianceMemberInfo:ShowMessage(msg)
	local dialog = FullScreenPopDialogUI.new()
    dialog:SetTitle(_("提示"))
    dialog:SetPopMessage(msg)
    dialog:AddToCurrentScene()
end

function GameUIAllianceMemberInfo:ShowSureDialog(msg,ok_func,cancel_func)
	cancel_func = cancel_func or function()end
	local dialog = FullScreenPopDialogUI.new()
    dialog:SetTitle(_("提示"))
    dialog:SetPopMessage(msg)
    dialog:CreateOKButton( {
        listener =  function ()
          	ok_func()
        end
	})
    dialog:CreateCancelButton({
    	listener = function()
    		cancel_func()
    	end
    })
    dialog:AddToCurrentScene()
end

return GameUIAllianceMemberInfo
