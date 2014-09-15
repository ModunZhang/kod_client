--
-- Author: Danny He
-- Date: 2014-09-11 09:19:55
--
local GameUIChat = UIKit:createUIClass('GameUIChat')
local TabButtons = import('.TabButtons')
local ChatService = import('..service.ChatService')
local ChatCenter = app.chatCenter
local NetService = import('..service.NetService')



GameUIChat.LISTVIEW_WIDTH = 549
GameUIChat.PLAYERMENU_ZORDER = 2

function GameUIChat:ctor()
	 GameUIChat.super.ctor(self)
	 self:createUI()
end

function GameUIChat:createUI()
	self:createHeader()
	self:createTextFieldBody()
	self:createListView()
	self:createTabButtons()
end

function GameUIChat:createTabButtons()
	local tab_buttons = TabButtons.new({
        {
            label = _("世界"),
            tag = "global",
            default = true,
        },
        {
            label = _("联盟"),
            tag = "Alliance",
        }
    },
    {
        gap = -4,
        margin_left = -2,
        margin_right = -2,
        margin_up = -6,
        margin_down = 1
    },
    function(tag)
    	self._channelType = string.lower(tag)
        self.page = 1
        self:refreshListView()
    end):addTo(self):pos(display.cx, display.bottom + 50)
end

-- response from chatcenter
function GameUIChat:messageEvent( event,data )
    if event == 'onRefresh' or event == 'onPush' then
        self.page = 1
        self:refreshListView()
    end
end

function GameUIChat:onMovieInStage()
	GameUIChat.super.onMovieInStage(self)
	ChatCenter:AddObserver(self)
end

function GameUIChat:onMovieOutStage()
	ChatCenter:RemoveObserver(self)
	GameUIChat.super.onMovieOutStage(self)
end

function GameUIChat:listviewListener(event)
	if not event.listView:isItemInViewRect(event.itemPos) then
        return
    end

    print("GameUIChat:listviewListener event:" .. event.name .. " pos:" .. event.itemPos)
    local listView = event.listView
    if "clicked" == event.name then
    	self:createPlayerMenu(event)
    end
end

function GameUIChat:getChatIcon( chat )
	local isVip = chat.fromVip and chat.fromVip > 0
	local heroBg = display.newSprite("chat_hero_background.png")
	local hero = display.newSprite("Hero_1.png"):align(display.CENTER, math.floor(heroBg:getContentSize().width/2), math.floor(heroBg:getContentSize().height/2)+5)
	hero:addTo(heroBg)
	if isVip then
		local vipBg = display.newSprite("chat_vip_background.png"):addTo(hero):align(display.CENTER, math.floor(heroBg:getContentSize().width/2)-4, 12)
		local vipLabel = cc.ui.UILabel.new({
				UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	            text = 'VIP ' .. chat.fromVip,
	            size = 15,
	            color = UIKit:hex2c3b(0xff9200),
	            align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
	            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
	            dimensions = cc.size(vipBg:getContentSize().width, 0),
	            font = UIKit:getFontFilePath(),
	    }):addTo(vipBg):align(display.CENTER, math.floor(vipBg:getContentSize().width/2), math.floor(vipBg:getContentSize().height/2))
	    vipLabel:setScale(1)
	end
	heroBg:setScale(0.7)
	return heroBg
end

function GameUIChat:getChatItem(chat)
	local isSelf = DataManager:getUserData()._id == chat.fromId
    local isVip = chat.fromVip and chat.fromVip > 0
    
	local content = display.newNode()
	if not isSelf then
		local item = self.listView:newItem()
		local bottom = display.newScale9Sprite("chat_bubble_bottom.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, 0)
		local middle = display.newScale9Sprite("chat_bubble_middle.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height)
		local labelText = chat.text
        if chat._translate_ and chat._translateMode_ then
            labelText = chat._translate_
        end
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
		middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
		contentLable:align(display.LEFT_BOTTOM, 25, 0):addTo(middle,2)
		local header = display.newScale9Sprite("chat_bubble_header.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height+middle:getContentSize().height)
		local imageName = isVip and "chat_green.png" or "chat_gray.png"
		local titleBg = display.newScale9Sprite(imageName):align(display.BOTTOM_LEFT, 12,18):addTo(header,3)
		titleBg:setContentSize(cc.size(300,titleBg:getContentSize().height))
		local titleLabel = cc.ui.UILabel.new({
			UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = chat.fromName or  "name",
            size = 22,
            color = UIKit:hex2c3b(0xffedae),
            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
            dimensions = cc.size(0, titleBg:getContentSize().height),
            font = UIKit:getFontFilePath(),
	    }):align(display.LEFT_BOTTOM, 10, -5):addTo(titleBg,2)
		local playerIcon = self:getChatIcon(chat)
		local timeStr = NetService:formatTimeAsTimeAgoStyleByServerTime(chat.time)
		if chat.timeStr then 
            timeStr = chat.timeStr
        else
           	chat.timeStr = timeStr
        end
	    local timeLabel =  cc.ui.UILabel.new({
	    		UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	            text = timeStr,
	            size = 16,
	            color = UIKit:hex2c3b(0x403c2f),
	            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
	            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
	            font = UIKit:getFontFilePath(),
	    }):align(display.LEFT_BOTTOM,titleBg:getPositionX()+titleBg:getContentSize().width+20, titleBg:getPositionY()-2):addTo(header,3)
	  --   --adjustFunc
	    local adjustFunc = function()
	    	middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
	    	header:align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height+middle:getContentSize().height)
	    	item:setItemSize(549,bottom:getContentSize().height+header:getContentSize().height+middle:getContentSize().height)
	    end
	    --button
	    -- chat_translation.png
	    local translateButton = cc.ui.UIPushButton.new({normal = "chat_translation.png"}, {scale9 = false})
	    translateButton:addTo(header,3)
	    translateButton:onButtonClicked(function(event)
	    	local oldHight = contentLable:getContentSize().height
			contentLable:setString("hello1213123123123hello1213123123123hello1213123123123hello1213123123123hello1213123123123hello1213123123123")
			local offsetY = contentLable:getContentSize().height - oldHight
			playerIcon:pos(playerIcon:getPositionX(),playerIcon:getPositionY()+offsetY)
			adjustFunc()
			item:pos(item:getPositionX(),item:getPositionY()-offsetY/2)
    	end)
    	translateButton:align(display.RIGHT_BOTTOM,timeLabel:getPositionX()+timeLabel:getContentSize().width+60,titleLabel:getPositionY()+titleLabel:getContentSize().height/2)
    	playerIcon:addTo(content):align(display.LEFT_TOP, 1, bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
		item:addContent(content)
		item:setItemSize(549,bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height)
		content:pos(0,0)
		return item
	else
		--mine
		local bottom = display.newScale9Sprite("chat_bubble_bottom.png"):addTo(content):align(display.LEFT_BOTTOM, -10, 0)
		local middle = display.newScale9Sprite("chat_bubble_middle.png"):addTo(content):align(display.LEFT_BOTTOM, -10, bottom:getContentSize().height)
		local contentLable = cc.ui.UILabel.new({
				UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	            text = chat.text,
	            size = 20,
	            color = UIKit:hex2c3b(0x403c2f),
	            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
	            valign = cc.ui.UILabel.TEXT_VALIGN_TOP,
	            dimensions = cc.size(430, 0),
	            font = UIKit:getFontFilePath(),
	    })
		middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
		contentLable:align(display.LEFT_BOTTOM, 25, 0):addTo(middle,2)
		local header = display.newSprite("chat_bubble_header.png"):addTo(content)
		header:setFlippedX(true)
		header:align(display.LEFT_BOTTOM, -1, bottom:getContentSize().height+middle:getContentSize().height)
		local titleBg = display.newScale9Sprite("chat_blue.png"):align(display.BOTTOM_RIGHT, header:getContentSize().width-12,18):addTo(header,3)
			local titleLabel = cc.ui.UILabel.new({
				UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	            text = chat.fromName or  "name",
	            size = 22,
	            color = UIKit:hex2c3b(0xffedae),
	            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
	            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
	            dimensions = cc.size(0, titleBg:getContentSize().height),
	            font = UIKit:getFontFilePath(),
	    }):align(display.LEFT_BOTTOM, 30, -5):addTo(titleBg,2)
		--  timeLable
		local timeLabel =  cc.ui.UILabel.new({
				UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	            text = NetService:formatTimeAsTimeAgoStyleByServerTime(chat.time),
	            size = 16,
	            color = UIKit:hex2c3b(0x403c2f),
	            align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
	            valign = cc.ui.UILabel.TEXT_VALIGN_CENTER,
	            font = UIKit:getFontFilePath(),
	    }):align(display.LEFT_BOTTOM,20, titleBg:getPositionY()-2):addTo(header,3)

		self:getChatIcon(chat):addTo(content):align(display.RIGHT_TOP, 549, bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
		local item = self.listView:newItem()
		item:addContent(content)
		item:setItemSize(549,bottom:getContentSize().height+header:getContentSize().height+middle:getContentSize().height)
		return item
	end
		return nil
end

function GameUIChat:refreshListView()
    if not  self._channelType then 
        self._channelType = 'global'
    end
    -- self.listView:removeAllItems()
    for i,v in ipairs(ChatCenter:getAllMessages(self._channelType)) do
    	v.text = "32332"
        local newItem  = self:getChatItem(v)
        self.listView:addItem(newItem)
    end
    self.listView:reload()
    self.listView:resetPosition()
end

function GameUIChat:createListView()
	self.listView = cc.ui.UIListView.new {
        bg = "chat_list_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.left+45, display.bottom+100, 549, display.height - self.header:getCascadeBoundingBox().size.height - self.editbox:getContentSize().height - 100 - 20),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
    	}
        :onTouch(handler(self, self.listviewListener))
        :addTo(self)
end

function GameUIChat:createHeader()
	local header = display.newNode()
	local bg = display.newSprite("common_header_bg.png"):align(display.LEFT_BOTTOM, 0,0):addTo(header)
	display.newSprite("common_bg_top.png"):align(display.LEFT_TOP, 30, display.top - 72):addTo(self)
	display.newSprite("common_bg_top.png"):align(display.LEFT_BOTTOM, 30, display.bottom):addTo(self)
	--left button
	local backbutton = cc.ui.UIPushButton.new({normal = "common_back_button.png",pressed = "common_back_button_highlight.png"}, {scale9 = false})
	backbutton:onButtonClicked(function(event)
			self:leftButtonClicked()
    end)
    backbutton:align(display.TOP_LEFT, 0,bg:getContentSize().height):addTo(header)
    local backIcon = display.newSprite("common_back_button_icon.png"):addTo(header):pos(display.left+45,bg:getContentSize().height/2)
    --right button
	local rightbutton = cc.ui.UIPushButton.new({normal = "common_back_button.png",pressed = "common_back_button_highlight.png"}, {scale9 = false})
	rightbutton:onButtonClicked(function(event)

    end)
    rightbutton:align(display.TOP_LEFT, 0, 0):addTo(header)
    rightbutton:setRotation(90)
    rightbutton:pos(display.right,bg:getContentSize().height)
    local rightIcon = display.newSprite("chat_setting.png"):addTo(header):pos(display.right-45, bg:getContentSize().height/2)
    -- titile
    local titleLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = _("聊天"),
        font = UIKit:getFontFilePath(),
        size = 30,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0xffedae),
    }):addTo(header)
    titleLabel:pos(display.cx,bg:getContentSize().height/2 + 12)
    header:addTo(self):pos(0,display.top-bg:getContentSize().height)
    self.header = header
end

function GameUIChat:createTextFieldBody()
	-- body  bg
	local left = display.newScale9Sprite("common_bg_left.png"):align(display.LEFT_TOP, display.left + 20, display.top):addTo(self,-99)
	left:setContentSize(cc.size(left:getContentSize().width,display.height))
	local right = display.newScale9Sprite("common_bg_left.png"):align(display.RIGHT_TOP, display.right - 20, display.top):addTo(self,-99)
	right:setContentSize(cc.size(right:getContentSize().width,display.height))
	display.newScale9Sprite("common_bg_center.png"):align(display.LEFT_TOP, 0,display.height):addTo(self,-100):setContentSize(cc.size(display.width,display.height))
	
	local function onEdit(event, editbox)
        if event == "return" then
            ChatService:sendChat({text = editbox:getText(),type=self._channelType},function(err)
                editbox:setText('')
            end)
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
    editbox:align(display.LEFT_TOP,display.left+46,display.height - self.header:getCascadeBoundingBox().size.height+10):addTo(self)
    self.editbox = editbox

    -- body button

	local emojiButton = cc.ui.UIPushButton.new({normal = "chat_expression.png",pressed = "chat_expression_highlight.png",},{scale9 = false})
	emojiButton:onButtonClicked(function(event)

    end)
    emojiButton:addTo(self):pos(self.editbox:getPositionX()+self.editbox:getContentSize().width+30, display.height - self.header:getCascadeBoundingBox().size.height - 20)
    local plusButton = cc.ui.UIPushButton.new({normal = "chat_add.png",pressed = "chat_add_highlight.png",}, {scale9 = false})
	plusButton:onButtonClicked(function(event)

	end)
	plusButton:addTo(self):pos(emojiButton:getPositionX()+emojiButton:getCascadeBoundingBox().size.width+5,emojiButton:getPositionY()+2)
end

function GameUIChat:createPlayerMenu(event)
	local item = event.item
	local menuLayer = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    menuLayer:setTouchEnabled(true)
    menuLayer:addTo(self,self.PLAYERMENU_ZORDER):pos(0, 0)
    local tabBg = display.newSprite("chat_tab_backgroud.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(menuLayer)
    menuLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function()
    	menuLayer:removeFromParent(true)
    end)
    print("fuck select index ---->",self.listView:getItemPos(item),event.itemPos)
	local chat = ChatCenter:getMessage(self.listView:getItemPos(item)-1,self.page,self._channelType)
	local x,y = item:getPosition()
    local p = item:getParent():getParent():convertToWorldSpace(cc.p(x,y))
    local targetP = menuLayer:convertToNodeSpace(p)
    local newItem = self:getChatItem(chat)
    newItem:setPosition(targetP)
    newItem:addTo(menuLayer)
    --copy
    local copyButton = cc.ui.UIPushButton.new({normal="chat_tab_button.png",pressed="chat_tab_button_highlight.png"}, {scale9 = false})
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = _("复制"),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }))
        :onButtonClicked(function(event)
            
        end)
        :align(display.LEFT_BOTTOM, 0, 2)
        :addTo(tabBg)
    local label = copyButton:getButtonLabel()
    display.newSprite("chat_copy.png"):align(display.CENTER,label:getPositionX(), label:getPositionY()+20):addTo(copyButton)
    copyButton:setButtonLabelOffset(0,-30)

    --chat_check_out
    local checkButton = cc.ui.UIPushButton.new({normal="chat_tab_button.png",pressed="chat_tab_button_highlight.png"}, {scale9 = false})
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = _("查看信息"),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }))
        :onButtonClicked(function(event)
            
        end)
        :align(display.LEFT_BOTTOM, tabBg:getContentSize().width/5, 2)
        :addTo(tabBg)
    local label = checkButton:getButtonLabel()
    display.newSprite("chat_check_out.png"):align(display.CENTER,label:getPositionX(), label:getPositionY()+20):addTo(checkButton)
    checkButton:setButtonLabelOffset(0,-30)

    --chat_shield
    local shieldButton = cc.ui.UIPushButton.new({normal="chat_tab_button.png",pressed="chat_tab_button_highlight.png"}, {scale9 = false})
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = _("屏蔽"),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }))
        :onButtonClicked(function(event)
            
        end)
        :align(display.LEFT_BOTTOM, tabBg:getContentSize().width/5 * 2 , 2)
        :addTo(tabBg)
    local label = shieldButton:getButtonLabel()
    display.newSprite("chat_shield.png"):align(display.CENTER,label:getPositionX(), label:getPositionY()+20):addTo(shieldButton)
    shieldButton:setButtonLabelOffset(0,-30)

    --chat_report
    local reportButton = cc.ui.UIPushButton.new({normal="chat_tab_button.png",pressed="chat_tab_button_highlight.png"}, {scale9 = false})
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = _("举报"),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }))
        :onButtonClicked(function(event)
            
        end)
        :align(display.LEFT_BOTTOM, tabBg:getContentSize().width/5 * 3 , 2)
        :addTo(tabBg)
    local label = reportButton:getButtonLabel()
    display.newSprite("chat_report.png"):align(display.CENTER,label:getPositionX(), label:getPositionY()+20):addTo(reportButton)
    reportButton:setButtonLabelOffset(0,-30)
    --chat_mail
    local mailButton = cc.ui.UIPushButton.new({normal="chat_tab_button.png",pressed="chat_tab_button_highlight.png"}, {scale9 = false})
        :setButtonLabel("normal", cc.ui.UILabel.new({
            UILabelType = 2,
            text = _("邮件"),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }))
        :onButtonClicked(function(event)
            
        end)
        :align(display.LEFT_BOTTOM, tabBg:getContentSize().width/5 * 4 , 2)
        :addTo(tabBg)
    local label = mailButton:getButtonLabel()
    display.newSprite("chat_mail.png"):align(display.CENTER,label:getPositionX(), label:getPositionY()+20):addTo(mailButton)
    mailButton:setButtonLabelOffset(0,-30)
end

return GameUIChat