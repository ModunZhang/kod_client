--
-- Author: Danny He
-- Date: 2014-10-06 18:18:26
--
local Enum = import("..utils.Enum")
local window = import('..utils.window')
local UIScrollView = import(".UIScrollView")
local UIListView = import(".UIListView")
local WidgetBackGroundTabButtons = import("..widget.WidgetBackGroundTabButtons")
local GameUIAlliance = UIKit:createUIClass("GameUIAlliance","GameUIWithCommonHeader")
local WidgetPushButton = import("..widget.WidgetPushButton")
local contentWidth = window.width - 80
local AllianceManager = import("..service.AllianceManager")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIAllianceBasicSetting = import(".GameUIAllianceBasicSetting")

GameUIAlliance.COMMON_LIST_ITEM_TYPE = Enum("JOIN","INVATE","APPLY")
local SEARCH_ALLIAN_TO_JOIN_TAG = "join_alliance"
-- 
--------------------------------------------------------------------------------
function GameUIAlliance:ctor()
	GameUIAlliance.super.ctor(self,City,_("联盟"))
	self.alliance_manager = DataManager:GetManager("AllianceManager")
	self.alliance_manager:onAllianceDataEvent(SEARCH_ALLIAN_TO_JOIN_TAG,handler(self, self.OnAllianceServerData))
end

function GameUIAlliance:onEnter()
	GameUIAlliance.super.onEnter(self)
	self:RefreshMainUI()
end

function GameUIAlliance:RefreshMainUI()
	self.main_content:removeAllChildren()
	if not self.alliance_manager:haveAlliance() then
		self:CreateNoAllianceUI()
		if not self.alliance_manager.open_alliance then
			self:CreateAllianceTips()
		end
	else
		self:CreateHaveAlliaceUI()
	end
end

function GameUIAlliance:CreateBetweenBgAndTitle()
	self.main_content = display.newNode():addTo(self):pos(window.left,window.bottom+68)
	self.main_content:setContentSize(cc.size(window.width,window.betweenHeaderAndTab))
end

function GameUIAlliance:onMovieInStage()
	GameUIAlliance.super.onMovieInStage(self)
	self.alliance_manager:onAllianceDataChanged(function(event)
		if event.allianceEvent == self.alliance_manager.ALLIANCE_EVENT_TYPE.CREATE_OR_JOIN 
		 	or event.allianceEvent == self.alliance_manager.ALLIANCE_EVENT_TYPE.QUIT then
	 		self:RefreshMainUI()
	 	elseif event.allianceEvent == self.alliance_manager.ALLIANCE_EVENT_TYPE.NORMAL then -- normal alliance data

		end

		--refresh list
		if self.tab_buttons:GetSelectedButtonTag() == 'join' then
			self:RefreshJoinListView()
		elseif self.tab_buttons:GetSelectedButtonTag() == 'apply' then
			self:RefreshApplyListView()
		elseif self.tab_buttons:GetSelectedButtonTag() == 'invate' then
			self:RefreshInvateListView()
		end
	end)
end

function GameUIAlliance:onMovieOutStage()
	self.alliance_manager:cancelAllianceDataChanged()
	self.alliance_manager:cancelAllianceDataEvent(SEARCH_ALLIAN_TO_JOIN_TAG)
	self.alliance_manager = nil
	GameUIAlliance.super.onMovieOutStage(self)
end

------------------------------------------------------------------------------------------------
---- I did not have a alliance
------------------------------------------------------------------------------------------------

function GameUIAlliance:CreateNoAllianceUI()
	self.tab_buttons = self:CreateTabButtons(
	{
		{
			label = _("创建"),
        	tag = "create",
        	default = true,
        },
        {
        	label = _("加入"),
        	tag = "join",
    	},
    	{
        	label = _("邀请"),
        	tag = "invite",
    	},
    	{
        	label = _("申请"),
        	tag = "apply",
    	},
    },
	function(tag)
		--call common tabButtons event
		if self["NoAllianceTabEvent_" .. tag .. "If"] then
			if self.currentContent then
				self.currentContent:hide()
			end
			self.currentContent = self["NoAllianceTabEvent_" .. tag .. "If"](self)
			self.currentContent:show()
		end
	end
	):pos(window.cx, window.bottom + 34)
end

function GameUIAlliance:CreateAllianceTips()
	self.alliance_manager.open_alliance = true 
	local shadowLayer = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
		:addTo(self)
    local backgroundImage = WidgetUIBackGround.new(500):addTo(shadowLayer):pos(window.left+20,window.top - 600)
    local titleBar = display.newSprite("title_blue_596x49.png")
		:align(display.TOP_LEFT, 6,backgroundImage:getContentSize().height - 6)
		:addTo(backgroundImage)
	local mainTitleLabel =  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("创建联盟"),
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xffedae)
	})
    :addTo(titleBar)
    :align(display.LEFT_BOTTOM, 10, 10)

    local closeButton = cc.ui.UIPushButton.new({normal = "X_2.png",pressed = "X_1.png"}, {scale9 = false})
	   	:addTo(titleBar)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+25, 10)
	   	:onButtonClicked(function ()
	   		shadowLayer:removeFromParent(true)
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)

	local title_bg = display.newSprite("alliance_green_title_639x69.png")
		:addTo(backgroundImage)
		:align(display.LEFT_TOP, -15, titleBar:getPositionY()-titleBar:getContentSize().height-5)   
	UIKit:ttfLabel({
		text = _("联盟的强大功能！"),
		size = 24,
		color = 0xffeca5
	}):addTo(title_bg):align(display.CENTER,title_bg:getContentSize().width/2,title_bg:getContentSize().height/2+5)

	local list_bg = GameUIAllianceBasicSetting.CreateBoxPanel(260)
	list_bg:pos(window.left+25,100):addTo(backgroundImage)
	closeButton = cc.ui.UIPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"}, {scale9 = false})
	   	:addTo(backgroundImage)
	   	:pos(window.cx,50)
	   	:setButtonLabel("normal",UIKit:ttfLabel({
			text = _("确定"),
			size = 20,
			color = 0xfff3c7,
			shadow = true,
		}))
	   	:onButtonClicked(function ()
	   		shadowLayer:removeFromParent(true)
	   	end)

	local scrollView = UIListView.new {
    	viewRect = cc.rect(0, 5, 552,250),
        direction = UIScrollView.DIRECTION_VERTICAL,
        alignment = UIListView.ALIGNMENT_LEFT
    }:addTo(list_bg)

    local tips = {_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),}
    for i,v in ipairs(tips) do
    	local item = scrollView:newItem()
    	local content = display.newNode()
		local star = display.newSprite("alliance_star_23x23.png"):addTo(content):align(display.LEFT_BOTTOM, 10, 10)
		UIKit:ttfLabel({
			text = v,
			size = 20,
			color = 0x403c2f,
			align = cc.TEXT_ALIGNMENT_LEFT
		}):addTo(content):align(display.LEFT_BOTTOM, star:getPositionX()+star:getContentSize().width+10, star:getPositionY()-2)
    	item:addContent(content)
    	item:setItemSize(552,content:getCascadeBoundingBox().height+20)
    	scrollView:addItem(item)
    end
    scrollView:reload()
end

-- TabButtons event

--1 main
function GameUIAlliance:NoAllianceTabEvent_createIf()
	if self.createScrollView then 
		return self.createScrollView
	end
	local basic_setting = GameUIAllianceBasicSetting.new()

	local scrollView = UIScrollView.new({viewRect = cc.rect(10,0,contentWidth+50,window.betweenHeaderAndTab)})
        :addScrollNode(basic_setting:GetContentNode():pos(40,0))
        :setDirection(UIScrollView.DIRECTION_VERTICAL)
        -- :onScroll(handler(self, self.CreateAllianceScrollListener))
        :addTo(self.main_content)
	scrollView:fixResetPostion(-50)
	self.createScrollView = scrollView
	return self.createScrollView
end

--2.join 
function GameUIAlliance:NoAllianceTabEvent_joinIf()
	if self.joinNode then
		self:RefreshJoinListView()
		return self.joinNode
	end
	local joinNode = display.newNode():addTo(self.main_content)
	self.joinNode = joinNode
	local searchIcon = display.newSprite("alliacne_search_29x33.png"):addTo(joinNode)
	:align(display.LEFT_TOP,window.left+40,self.main_content:getCascadeBoundingBox().height - 30)
    local function onEdit(event, editbox)
        if event == "return" then
          self:SearchAllianAction(self.editbox_tag_search:getText())
        end
    end

	local editbox_tag_search = cc.ui.UIInput.new({
    	UIInputType = 1,
        image = "alliance_editbox_575x48.png",
        size = cc.size(510,48),
        listener = onEdit,
    })

    editbox_tag_search:setPlaceHolder(_("搜索联盟标签"))
    editbox_tag_search:setMaxLength(600)
    editbox_tag_search:setFont(UIKit:getFontFilePath(),18)
    editbox_tag_search:setFontColor(cc.c3b(0,0,0))
    editbox_tag_search:setPlaceholderFontColor(UIKit:hex2c3b(0xccc49e))
    editbox_tag_search:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox_tag_search:align(display.LEFT_TOP,searchIcon:getPositionX()+searchIcon:getContentSize().width+10,self.main_content:getCascadeBoundingBox().height - 10):addTo(joinNode)
    self.editbox_tag_search = editbox_tag_search


    -- local bg = GameUIAllianceBasicSetting.CreateBoxPanel(710):addTo(joinNode):pos(5,10)
    self.joinListView = UIListView.new {
    	viewRect = cc.rect(20, 0,608,710),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(joinNode)
    self:RefreshJoinListView()
	return joinNode
end

function GameUIAlliance:OnAllianceServerData(event)
	if event.eventType == "onSearchAllianceSuccess" then
		local data = event.data
		self:RefreshJoinListView(data.alliances)
	end
end

function GameUIAlliance:RefreshJoinListView(data)
	if not data then 
		self:SearchAllianAction("K") -- 页面默认数据
		return 
	end
  	self.joinListView:removeAllItems()
	for i,v in ipairs(data) do
		local newItem = self:getCommonListItem_(self.COMMON_LIST_ITEM_TYPE.JOIN,v)
		self.joinListView:addItem(newItem)
	end
	self.joinListView:reload()
end

function GameUIAlliance:SearchAllianAction(tag)
	PushService:searchAllianceByTag(tag,function(success)
	end)
end

--3.invite
function GameUIAlliance:NoAllianceTabEvent_inviteIf()
	if self.invateNode then 
		self:RefreshInvateListView()
		return self.invateNode
	end
	local invateNode = display.newNode():addTo(self.main_content)
	self.invateNode = invateNode
   self.invateListView = UIListView.new {
    	viewRect = cc.rect(20, 0,608,710),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(invateNode)
    self:RefreshInvateListView()
	return invateNode
end

function GameUIAlliance:RefreshInvateListView()
	local list = self.alliance_manager:GetAllianceEvents(self.COMMON_LIST_ITEM_TYPE.INVATE)
	self.invateListView:removeAllItems()
	for i,v in ipairs(list) do
		local item = self:getCommonListItem_(self.COMMON_LIST_ITEM_TYPE.INVATE,v)
		self.invateListView:addItem(newItem)
	end
	self.invateListView:reload()
end

function GameUIAlliance:NoAllianceTabEvent_applyIf()
	if self.applyNode then 
		self:RefreshApplyListView()
		return self.applyNode
	end
	local applyNode = display.newNode():addTo(self.main_content)
	self.applyNode = applyNode
	self.applyListView = UIListView.new {
    	viewRect = cc.rect(20, 0,608,790),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(applyNode)
    self:RefreshApplyListView()
	return applyNode
end

function GameUIAlliance:RefreshApplyListView()
	local list = self.alliance_manager:GetAllianceEvents(self.COMMON_LIST_ITEM_TYPE.APPLY)
	self.applyListView:removeAllItems()
	for i,v in ipairs(list) do
		local item = self:getCommonListItem_(self.COMMON_LIST_ITEM_TYPE.APPLY,v)
		self.applyListView:addItem(item)
	end
	self.applyListView:reload()
end

function GameUIAlliance:getAllianceArchonName( alliance )
	for _,v in ipairs(alliance.members) do
		if v.title == 'archon' then
			return v.name
		end
	end
end


--  listType:join appy invate
function GameUIAlliance:getCommonListItem_(listType,alliance)
	local targetListView = nil
	local item = nil
	local terrain,flag_info = nil,nil
	if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
		targetListView = self.joinListView
		terrain = alliance.basicInfo.terrain
		flag_info = alliance.basicInfo.flag
	elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then
		targetListView = self.invateListView
	else
		targetListView = self.applyListView
		terrain = alliance.terrain
		flag_info = alliance.flag
	end

	local item = targetListView:newItem()
	local bg = display.newSprite("alliance_search_item_bg_608x164.png"):align(display.LEFT_BOTTOM,0,0)
	local titleBg = display.newScale9Sprite("alliance_item_title_bg_588x30.png")
		:size(448,30)
		:addTo(bg)
		:align(display.RIGHT_TOP,590, 150)
	local nameLabel = UIKit:ttfLabel({
		text = "allianceName", -- alliance name
		size = 22,
		color = 0xffedae
	}):addTo(titleBg,2):align(display.LEFT_BOTTOM, 10, 5)

	local flag_box = display.newSprite("alliance_item_flag_box_126X126.png"):addTo(bg):align(display.LEFT_BOTTOM, 10, 22)
	local flag_sprite = self.alliance_manager:CreateFlagWithLawn(terrain,flag_info)
	flag_sprite:addTo(flag_box):scale(0.8)
	flag_sprite:pos(60,40)
	local memberTitleLabel = UIKit:ttfLabel({
				text = _("成员"),
				size = 18,
				color = 0x797154
	}):addTo(bg):align(display.LEFT_TOP,flag_box:getPositionX()+flag_box:getContentSize().width+10,titleBg:getPositionY()-titleBg:getContentSize().height - 10)

	local memberValLabel = UIKit:ttfLabel({
				text = "14/50", --count of members
				size = 18,
				color = 0x403c2f
	}):addTo(bg):align(display.LEFT_TOP, memberTitleLabel:getContentSize().width+memberTitleLabel:getPositionX()+15, memberTitleLabel:getPositionY())


	local fightingTitleLabel = UIKit:ttfLabel({
				text = _("战斗力"),
				size = 18,
				color = 0x797154
	}):addTo(bg):align(display.LEFT_TOP, memberValLabel:getContentSize().width+memberValLabel:getPositionX()+200, memberValLabel:getPositionY())

	local fightingValLabel = UIKit:ttfLabel({
				text = "100", 
				size = 18,
				color = 0x403c2f
	}):addTo(bg):align(display.LEFT_TOP, fightingTitleLabel:getContentSize().width+fightingTitleLabel:getPositionX()+15, fightingTitleLabel:getPositionY())


	local languageTitleLabel = UIKit:ttfLabel({
				text = _("语言"),
				size = 18,
				color = 0x797154
	}):addTo(bg):align(display.LEFT_TOP,memberTitleLabel:getPositionX(), memberTitleLabel:getPositionY() - memberTitleLabel:getContentSize().height-5)

	local languageValLabel = UIKit:ttfLabel({
				text = "all", -- language
				size = 18,
				color = 0x403c2f
	}):addTo(bg):align(display.LEFT_BOTTOM,languageTitleLabel:getPositionX()+languageTitleLabel:getContentSize().width+15,languageTitleLabel:getPositionY()-languageTitleLabel:getContentSize().height)


	local killTitleLabel = UIKit:ttfLabel({
				text = _("击杀"),
				size = 18,
				color = 0x797154,
				align = ui.TEXT_ALIGN_RIGHT,
	}):addTo(bg):align(display.RIGHT_BOTTOM, fightingTitleLabel:getPositionX()+fightingTitleLabel:getContentSize().width, languageValLabel:getPositionY())

	local killValLabel = UIKit:ttfLabel({
				text = "100",
				size = 18,
				color = 0x403c2f
	}):addTo(bg):align(display.LEFT_BOTTOM, killTitleLabel:getPositionX()+15, killTitleLabel:getPositionY())


	if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
		local leaderIcon = display.newSprite("alliance_item_leader_39x39.png")
			:addTo(bg)
			:align(display.LEFT_TOP,languageTitleLabel:getPositionX(), languageTitleLabel:getPositionY()-20)
		local leaderLabel = UIKit:ttfLabel({
			text = self:getAllianceArchonName(alliance),
			size = 22,
			color = 0x403c2f
		}):addTo(bg):align(display.LEFT_TOP,leaderIcon:getPositionX()+leaderIcon:getContentSize().width+15, languageTitleLabel:getPositionY()-30)
		local buttonNormalPng,buttonHighlightPng,buttonText
		if alliance.basicInfo.joinType == 'all' then 
			buttonNormalPng = "yellow_button_146x42.png"
			buttonHighlightPng = "yellow_button_highlight_146x42.png"
			buttonText = _("加入")

		else
			buttonNormalPng = "blue_btn_up_142x39.png"
			buttonHighlightPng = "blue_btn_down_142x39.png"
			buttonText = _("申请")
		end

		WidgetPushButton.new({normal = buttonNormalPng,pressed = buttonHighlightPng},{scale9 = true})
        :setButtonLabel(
        	UIKit:ttfLabel({
				text = buttonText,
				size = 20,
				shadow = true,
				color = 0xfff3c7
			})
		)
		:setButtonSize(147,45)
		:align(display.RIGHT_TOP,titleBg:getPositionX(),languageTitleLabel:getPositionY()-25)
		:onButtonClicked(function(event)
			self:commonListItemAction(listType,item,alliance)
		end)
		:addTo(bg)
		nameLabel:setString(alliance.basicInfo.name)
		memberValLabel:setString(#alliance.members .. "/50")
		fightingValLabel:setString(alliance.basicInfo.power)
		languageValLabel:setString(alliance.basicInfo.language)
		killValLabel:setString(alliance.basicInfo.kill)

	elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then
		local rejectButton = WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"},{scale9 = true})
        :setButtonLabel(
        	UIKit:ttfLabel({
				text = _("拒绝"),
				size = 20,
				shadow = true,
				color = 0xfff3c7
			})
		)
		:setButtonSize(146,42)
		:align(display.LEFT_TOP,languageTitleLabel:getPositionX(), languageTitleLabel:getPositionY()-25)
		:onButtonClicked(function(event)
			self:commonListItemAction(listType,item,alliance,1)
		end)
		:addTo(bg)

		local argreeButton = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"},{scale9 = true})
        :setButtonLabel(
        	UIKit:ttfLabel({
				text = _("同意"),
				size = 20,
				shadow = true,
				color = 0xfff3c7
			})
		)
		:setButtonSize(146,42)
		:align(display.RIGHT_TOP,titleBg:getPositionX(), languageTitleLabel:getPositionY()-25)
		:onButtonClicked(function(event)
			self:commonListItemAction(listType,item,alliance,2)
		end)
		:addTo(bg)
	elseif listType == self.COMMON_LIST_ITEM_TYPE.APPLY then
		local info_bg = display.newScale9Sprite("alliance_info_587x34.png")
			:size(220,34)
			:addTo(bg)
			:align(display.LEFT_TOP,languageTitleLabel:getPositionX(), languageTitleLabel:getPositionY()-30)

		UIKit:ttfLabel({
				text = _("等待对方审核"),
				size = 18,
				color = 0x797154,
		}):addTo(info_bg,2):align(display.CENTER, 110, 17)
		WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"},{scale9 = true})
        :setButtonLabel(
        	UIKit:ttfLabel({
				text = _("撤销"),
				size = 20,
				shadow = true,
				color = 0xfff3c7
			})
		)
		:setButtonSize(146,42)
		:align(display.RIGHT_TOP,titleBg:getPositionX(), languageTitleLabel:getPositionY()-25)
		:onButtonClicked(function(event)
			self:commonListItemAction(listType,item,alliance)
		end)
		:addTo(bg)
		nameLabel:setString(alliance.name)
		memberValLabel:setString(alliance.members .. "/50")
		fightingValLabel:setString(alliance.power)
		languageValLabel:setString(alliance.language)
		killValLabel:setString(alliance.kill)
	end
	item:addContent(bg)
	item:setItemSize(bg:getContentSize().width,bg:getContentSize().height)
	return item
	-- end
end


function GameUIAlliance:commonListItemAction( listType,item,alliance,tag)
	if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
		if  alliance.basicInfo.joinType == 'all' then --如果是直接加入
			PushService:joinAllianceDirectly(alliance._id,function(success)
			end)
		else
			PushService:requestToJoinAlliance(alliance._id,function(success)
				if success then 
					local dialog = FullScreenPopDialogUI.new()
	        		dialog:SetTitle(_("申请成功"))
	        		dialog:SetPopMessage(string.format(_("您的申请已发送至%s,如果被接受将加入该联盟,如果被拒绝,将收到一封通知邮件."),alliance.basicInfo.name))
	        		dialog:AddToCurrentScene()
				end
			end)
		end
	elseif  listType == self.COMMON_LIST_ITEM_TYPE.APPLY then
		PushService:cancelJoinAllianceRequest(alliance.id,function(success)
		end)
	elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then

	end
end

------------------------------------------------------------------------------------------------
---- I have join in a alliance
------------------------------------------------------------------------------------------------
function GameUIAlliance:CreateHaveAlliaceUI()
	self:CreateTabButtons(
	{
		{
			label = _("总览"),
        	tag = "overview",
        	default = true,
        },
        {
        	label = _("成员"),
        	tag = "members",
    	},
    	{
        	label = _("信息"),
        	tag = "infomation",
    	}
    },
	function(tag)

	end
	):pos(window.cx, window.bottom + 34)
end
return GameUIAlliance