--
-- Author: Danny He
-- Date: 2015-01-21 16:07:41
--
local GameUIChatChannel = UIKit:createUIClass('GameUIChatChannel')
local WidgetBackGroundTabButtons = import('..widget.WidgetBackGroundTabButtons')
local NetService = import('..service.NetService')
local window = import("..utils.window")
local UIListView = import(".UIListView")
local ChatManager = import("..entity.ChatManager")
local RichText = import("..widget.RichText")

GameUIChatChannel.LISTVIEW_WIDTH = 549
GameUIChatChannel.PLAYERMENU_ZORDER = 2
GameUIChatChannel.CELL_BOTTM_TAG = 100
GameUIChatChannel.CELL_MIDDLE_TAG = 101
GameUIChatChannel.CELL_CONTENT_LABEL_TAG = 102
GameUIChatChannel.CELL_HEADER_TAG = 103
GameUIChatChannel.CELL_TITLE_LABEL_TAG = 103
GameUIChatChannel.CELL_PLAYER_ICON_TAG = 104
GameUIChatChannel.CELL_TIME_LABEL_TAG = 105
GameUIChatChannel.CELL_TRANSLATEBUTTON = 106
GameUIChatChannel.CELL_MAIN_CONENT_TAG = 107
GameUIChatChannel.CELL_TITLE_BG_TAG = 108
GameUIChatChannel.CELL_PLAYER_ICON_VIP_BG_TAG = 109
GameUIChatChannel.CELL_PLAYER_ICON_VIP_LABEL_TAG = 110
GameUIChatChannel.CELL_PLAYER_ICON_HERO_TAG = 111


function GameUIChatChannel:ctor(default_tag)
	GameUIChatChannel.super.ctor(self)
	self.default_tag = default_tag
    self.chatManager = app:GetChatManager()
end

function GameUIChatChannel:GetChatManager()
    return self.chatManager
end

function GameUIChatChannel:onEnter()
	GameUIChatChannel.super.onEnter(self)
	self:CreateBackGround()
    self:CreateTitle(_("聊天"))
    self:CreateHomeButton()
    self:CreateSettingButton()
    self:CreateTextFieldBody()
    self:CreateListView()
    self:CreateTabButtons()
    self:GetChatManager():AddListenOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
end

function GameUIChatChannel:onMoveOutStage()
    self:GetChatManager():RemoveListenerOnType(self,ChatManager.LISTEN_TYPE.TO_TOP)
    GameUIChatChannel.super.onMoveOutStage(self)    
end

function GameUIChatChannel:TO_TOP(data)
    local isLastMessageInViewRect = false
    local count = #data
    if count > 0 then
        isLastMessageInViewRect = self.listView:isItemInViewRectWithLogicIndex(count)
    end
    if #self:GetDataSource() == 0 or isLastMessageInViewRect then
        self:RefreshListView()
    else
        -- table.insertto(data,self.dataSource_)
        -- self.dataSource_ = data
        LuaUtils:table_insert_top(self.dataSource_,data)
        self.listView:offsetItemsIdx(#data)
        -- self.listView:updateAllItemInViewRect(#data)
    end
end

function GameUIChatChannel:GetDataSource()
    return self.dataSource_
end

function GameUIChatChannel:CreateTextFieldBody()
	local function onEdit(event, editbox)
        if event == "return" then
            local msg = editbox:getText()
            if not msg or string.len(string.trim(msg)) == 0 then 
                UIKit:showMessageDialog(_("错误"), _("聊天内容不能为空"),function()end)
                return 
            end  
            editbox:setText('')
            self:GetChatManager():SendChat(self._channelType,msg)
        end
    end
    local editbox = cc.ui.UIInput.new({
    	UIInputType = 1,
        image = "chat_Input_box.png",
        size = cc.size(427,57),
        listener = onEdit,
    })
    editbox:setPlaceHolder(_("最多可输入140字符"))
    editbox:setMaxLength(140)
    editbox:setFont(UIKit:getFontFilePath(),22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox:align(display.LEFT_TOP,window.left+46,window.top - 100):addTo(self)
    self.editbox = editbox

    -- body button

	local emojiButton = cc.ui.UIPushButton.new({normal = "chat_expression.png",pressed = "chat_expression_highlight.png",},{scale9 = false})
		:onButtonClicked(function(event)
            if CONFIG_IS_DEBUG then
                local msg = editbox:getText()
                if not msg or string.len(string.trim(msg)) == 0 then 
                    UIKit:showMessageDialog(_("错误"), _("聊天内容不能为空"),function()end)
                    return 
                end  
                editbox:setText('')
                self:GetChatManager():SendChat(self._channelType,msg)
            end
    	end)
    	:addTo(self)
    	:align(display.LEFT_TOP,self.editbox:getPositionX()+self.editbox:getContentSize().width+10, window.top - 100)
        :zorder(2)
    local plusButton = cc.ui.UIPushButton.new({normal = "chat_add.png",pressed = "chat_add_highlight.png",}, {scale9 = false})
    	:onButtonClicked(function(event)

		end)
		:addTo(self)
		:align(display.LEFT_TOP, emojiButton:getPositionX()+emojiButton:getCascadeBoundingBox().size.width+10,emojiButton:getPositionY()-2)
        :zorder(2)
end

function GameUIChatChannel:CreateSettingButton()
	--right button
	local rightbutton = cc.ui.UIPushButton.new({normal = "home_btn_up.png",pressed = "home_btn_down.png"}, {scale9 = false})
		:onButtonClicked(function(event)
			self:CreatShieldView()
    	end)
    	:align(display.TOP_RIGHT, 0, 0)
    	:addTo(self)
    rightbutton:pos(window.right-5,window.top-5)
   	display.newSprite("chat_setting.png")
   		:addTo(rightbutton):scale(0.8)
        :pos(-49,-30)

end

function GameUIChatChannel:FetchCurrentChannelMessages()
    dump(self:GetChatManager():FetchChannelMessage(self._channelType),"self:GetChatManager():FetchChannelMessage(self._channelType)--->")
    return self:GetChatManager():FetchChannelMessage(self._channelType)
end

function GameUIChatChannel:CreateTabButtons()
	local tab_buttons = WidgetBackGroundTabButtons.new({
        {
            label = _("世界"),
            tag = "global",
            default = self.default_tag == "global",
        },
        {
            label = _("联盟"),
            tag = "alliance",
            default = self.default_tag == "alliance",
        }
    },
    function(tag)
        self._channelType = tag == 'global' and ChatManager.CHANNNEL_TYPE.GLOBAL or ChatManager.CHANNNEL_TYPE.ALLIANCE
        self:RefreshListView()
    end):addTo(self):pos(window.cx, window.bottom + 34)
end



function GameUIChatChannel:GetChatIcon()
	local heroBg = display.newSprite("chat_hero_background.png")
	local hero = display.newSprite("Hero_1.png"):align(display.CENTER, math.floor(heroBg:getContentSize().width/2), math.floor(heroBg:getContentSize().height/2)+5)
	hero:addTo(heroBg)
	hero:setTag(self.CELL_PLAYER_ICON_HERO_TAG)
	local vipBg = display.newSprite("chat_vip_background.png"):addTo(hero):align(display.CENTER, math.floor(heroBg:getContentSize().width/2)-4, 12)
	local vipLabel = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = 'VIP ',
            size = 15,
            color = UIKit:hex2c3b(0xff9200),
            align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
            font = UIKit:getFontFilePath(),
    }):addTo(vipBg):align(display.CENTER, math.floor(vipBg:getContentSize().width/2), math.floor(vipBg:getContentSize().height/2))
    vipLabel:setScale(1)
	heroBg:setScale(0.7)
	vipBg:setTag(self.CELL_PLAYER_ICON_VIP_BG_TAG)
	vipLabel:setTag(self.CELL_PLAYER_ICON_VIP_LABEL_TAG)
	return heroBg
end

function GameUIChatChannel:GetChatItemCell()
	local main = display.newNode()
	--other
	local content = display.newNode()
	local bottom = display.newScale9Sprite("chat_bubble_bottom.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, 0)
	bottom:setTag(self.CELL_BOTTM_TAG)
	local middle = display.newScale9Sprite("chat_bubble_middle.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height)
	middle:setTag(self.CELL_MIDDLE_TAG)
	local labelText = "内容x"
	local contentLable = cc.ui.UILabel.new({
		UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = labelText,
        size = 20,
    	color = UIKit:hex2c3b(0x403c2f),
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        valign = cc.ui.UILabel.TEXT_VALIGN_TOP,
        dimensions = cc.size(430, 0),
        font = UIKit:getFontFilePath(),
	})
	contentLable:setTag(self.CELL_CONTENT_LABEL_TAG)
	--1
	middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
	contentLable:align(display.LEFT_BOTTOM, 25, 0):addTo(middle,2)
	local header = display.newScale9Sprite("chat_bubble_header.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height+middle:getContentSize().height)
	header:setTag(self.CELL_HEADER_TAG)
	local imageName = isVip and "chat_green.png" or "chat_gray.png"
	local titleBg = display.newScale9Sprite(imageName):align(display.BOTTOM_LEFT, 12,18):addTo(header,3)
	titleBg:setContentSize(cc.size(300,titleBg:getContentSize().height))
	titleBg:setTag(self.CELL_TITLE_BG_TAG)
	local titleLabel = cc.ui.UILabel.new({
		UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "玩家名",
        size = 22,
        color = UIKit:hex2c3b(0xffedae),
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
        -- dimensions = cc.size(0, 40),
        font = UIKit:getFontFilePath(),
    }):align(display.LEFT_BOTTOM, 10, 0):addTo(titleBg,2)
    titleLabel:setTag(self.CELL_TITLE_LABEL_TAG)
	 local playerIcon = self:GetChatIcon()
	 playerIcon:setTag(self.CELL_PLAYER_ICON_TAG)
    local timeLabel =  cc.ui.UILabel.new({
    		UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = "聊天时间",
            size = 16,
            color = UIKit:hex2c3b(0x403c2f),
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
            font = UIKit:getFontFilePath(),
    }):align(display.LEFT_BOTTOM,titleBg:getPositionX()+titleBg:getContentSize().width+20, titleBg:getPositionY()-2):addTo(header,3)
    timeLabel:setTag(self.CELL_TIME_LABEL_TAG)
    local translateButton = cc.ui.UIPushButton.new({normal = "chat_translation.png"}, {scale9 = false})
    	:addTo(header,3)
        :align(display.RIGHT_BOTTOM,header:getContentSize().width-10,titleLabel:getPositionY()+titleLabel:getContentSize().height/2)
	playerIcon:addTo(content):align(display.LEFT_TOP, 1, bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
	translateButton:setTag(self.CELL_TRANSLATEBUTTON)
	main.other = content
	main:addChild(content)
	--self
	local selfContent = display.newNode()
	local bottom = display.newScale9Sprite("chat_bubble_bottom.png"):addTo(selfContent):align(display.LEFT_BOTTOM, -10, 0)
	local middle = display.newScale9Sprite("chat_bubble_middle.png"):addTo(selfContent):align(display.LEFT_BOTTOM, -10, bottom:getContentSize().height)
	bottom:setTag(self.CELL_BOTTM_TAG)
	middle:setTag(self.CELL_MIDDLE_TAG)
	local contentLable = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = "聊天信息",
            size = 20,
            color = UIKit:hex2c3b(0x403c2f),
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            valign = cc.ui.UILabel.TEXT_VALIGN_TOP,
            dimensions = cc.size(430, 0),
            font = UIKit:getFontFilePath(),
    })
    contentLable:setTag(self.CELL_CONTENT_LABEL_TAG)
	middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
	contentLable:align(display.LEFT_BOTTOM, 25, 0):addTo(middle,2)
	local header = display.newSprite("chat_bubble_header.png"):addTo(selfContent)
	header:setFlippedX(true)
	header:align(display.LEFT_BOTTOM, -1, bottom:getContentSize().height+middle:getContentSize().height)
	local titleBg = display.newScale9Sprite("chat_blue.png"):align(display.BOTTOM_RIGHT, header:getContentSize().width-12,18):addTo(header,3)
	titleBg:setTag(self.CELL_TITLE_BG_TAG)
	local titleLabel = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = "玩家名称",
            size = 22,
            color = UIKit:hex2c3b(0xffedae),
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
            font = UIKit:getFontFilePath(),
    }):align(display.LEFT_BOTTOM, 30, 0):addTo(titleBg,2)
	header:setTag(self.CELL_HEADER_TAG)
	titleLabel:setTag(self.CELL_TITLE_LABEL_TAG)
	--  timeLable
	local timeLabel =  cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = "时间",
            size = 16,
            color = UIKit:hex2c3b(0x403c2f),
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
            font = UIKit:getFontFilePath(),
    }):align(display.LEFT_BOTTOM,20, titleBg:getPositionY()):addTo(header,3)
    timeLabel:setTag(self.CELL_TIME_LABEL_TAG)
	local playerIcon = self:GetChatIcon()
	playerIcon:setTag(self.CELL_PLAYER_ICON_TAG)
	playerIcon:addTo(selfContent):align(display.RIGHT_TOP, 549, bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
	main.self = selfContent
	main:addChild(selfContent)
	return main
end

function GameUIChatChannel:CreateListView()
	self.listView = UIListView.new {
        bg = "chat_list_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(window.left+45, window.bottom+90, 549, 700),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT,
        async = true
    }:onTouch(handler(self, self.listviewListener)):addTo(self)
    self.listView:setDelegate(handler(self, self.sourceDelegate))
    self.listView:setUpdateItemDelegate(handler(self, self.updateItemDelegate))
end

function GameUIChatChannel:RefreshListView()
    if not  self._channelType then 
        self._channelType = ChatManager.CHANNNEL_TYPE.GLOBAL
    end
    self.dataSource_ = clone(self:FetchCurrentChannelMessages())
    self.listView:reload()
    return item
end

function GameUIChatChannel:updateItemDelegate(item,idx)
    local content = item:getContent()
    local data = self.dataSource_[idx]
    local height = self:HandleCellUIData(content,data)
    item:setItemSize(549,83 + height)

end

function GameUIChatChannel:sourceDelegate(listView, tag, idx)
 if cc.ui.UIListView.COUNT_TAG == tag then
        return #self.dataSource_
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        local data = self.dataSource_[idx]
        item = self.listView:dequeueItem()
        if not item then
            item = self.listView:newItem()
            content = self:GetChatItemCell()
            item:addContent(content)
        else
            content = item:getContent()
        end
        local height = self:HandleCellUIData(content,data)
        item:setItemSize(549,83 + height)
        return item
    else
    end
end

function GameUIChatChannel:HandleCellUIData(mainContent,chat)
    if not chat then return end
    local isSelf = DataManager:getUserData()._id == chat.fromId
    local isVip = chat.fromVip and chat.fromVip > 0
    local currentContent = nil
    if isSelf then
      mainContent.other:hide()
      currentContent = mainContent.self
    else
      mainContent.self:hide()
      currentContent = mainContent.other
    end
    currentContent:show()

    local bottom = currentContent:getChildByTag(self.CELL_BOTTM_TAG)
    local middle = currentContent:getChildByTag(self.CELL_MIDDLE_TAG)
    local header = currentContent:getChildByTag(self.CELL_HEADER_TAG)
    
    --header node
    local timeLabel = header:getChildByTag(self.CELL_TIME_LABEL_TAG)

    local titleBg = header:getChildByTag(self.CELL_TITLE_BG_TAG)

    local titleLabel = titleBg:getChildByTag(self.CELL_TITLE_LABEL_TAG)

    -- middle node
    local contentLable = middle:getChildByTag(self.CELL_CONTENT_LABEL_TAG)

    --bind
    titleLabel:setString(chat.fromName)
    if not chat.timeStr then
        chat.timeStr = NetService:formatTimeAsTimeAgoStyleByServerTime(chat.time)
    end
    timeLabel:setString(chat.timeStr)

    local palyerIcon = currentContent:getChildByTag(self.CELL_PLAYER_ICON_TAG)

    local hero = palyerIcon:getChildByTag(self.CELL_PLAYER_ICON_HERO_TAG)
    local vipBg = hero:getChildByTag(self.CELL_PLAYER_ICON_VIP_BG_TAG)
    local vipLabel = vipBg:getChildByTag(self.CELL_PLAYER_ICON_VIP_LABEL_TAG)

    vipBg:setVisible(isVip)
    vipLabel:setVisible(isVip)
    vipLabel:setString('VIP ' .. chat.fromVip)
    local labelText = chat.text
    if chat._translate_ and chat._translateMode_ then
        labelText = chat._translate_
    end

    contentLable:setString(labelText) -- 聊天信息
    if not isSelf then
        --重新布局
        middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
        header:align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height+middle:getContentSize().height)
        palyerIcon:pos(palyerIcon:getPositionX(),bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
    else
        middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
    end
    local height = contentLable:getContentSize().height or 0
    mainContent.other:size(549,83 + height)
    mainContent.self:size(549,83 + height)
    mainContent:size(549,83 + height)
    return height
end

function GameUIChatChannel:CreatShieldView()
    self.listView:dumpListView()
    dump(self.dataSource_,"self.dataSource_")
end

function GameUIChatChannel:listviewListener(event)
	-- if event.name == 'SCROLLVIEW_EVENT_BOUNCE_BOTTOM' then
	-- 	  print('get more message!')
 --            self.page = self.page + 1
 --            local data = ChatCenter:getAllMessages(self._channelType,self.page)
 --            if #data == 0 and self.page > 1 then
 --                self.page = self.page - 1
 --                return
 --            end
 --            for i,v in ipairs(data) do
 --                local newItem  = self:getChatItem(v)
 --                self.listView:addItem(newItem)
 --            end
 --            self.listView:resetPosition()
 --            self.listView:reload()
 --            self.listView:resetPosition()
	-- 	return
	-- end
	-- if not event.listView:isItemInViewRect(event.itemPos) then
 --        return
 --    end

 --    print("GameUIChat:listviewListener event:" .. event.name .. " pos:" .. event.itemPos)
 --    local listView = event.listView
 --    if "clicked" == event.name then
 --    	self:CreatePlayerMenu(event)
 --    end
end

return GameUIChatChannel