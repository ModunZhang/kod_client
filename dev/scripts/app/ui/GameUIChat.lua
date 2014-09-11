--
-- Author: Danny He
-- Date: 2014-09-11 09:19:55
--
local GameUIChat = UIKit:createUIClass('GameUIChat')
GameUIChat.LISTVIEW_WIDTH = 549

function GameUIChat:ctor()
	 GameUIChat.super.ctor(self)
	 self:createUI()
end

function GameUIChat:createUI()
	self:createHeader()
	self:createTextFieldBody()
	
end

function GameUIChat:onMovieInStage()
	GameUIChat.super.onMovieInStage(self)
	self:createListView()
end

function GameUIChat:listviewListener(event)

end

function GameUIChat:getChatIcon( chat )
	local isVip = true
	local heroBg = display.newSprite("chat_hero_background.png")
	local hero = display.newSprite("Hero_1.png"):align(display.CENTER, math.floor(heroBg:getContentSize().width/2), math.floor(heroBg:getContentSize().height/2)+5)
	hero:addTo(heroBg)
	if isVip then
		local vipBg = display.newSprite("chat_vip_background.png"):addTo(hero):align(display.CENTER, math.floor(heroBg:getContentSize().width/2)-4, 12)
		local vipLabel = ui.newTTFLabel({
	            text = "VIP 99",
	            size = 15,
	            color = UIKit:hex2c3b(0xff9200),
	            align = ui.TEXT_ALIGN_CENTER,
	            valign = ui.TEXT_VALIGN_CENTER,
	            dimensions = cc.size(vipBg:getContentSize().width, 0),
	            font = UIKit:getFontFilePath(),
	    }):addTo(vipBg):align(display.CENTER, math.floor(vipBg:getContentSize().width/2), math.floor(vipBg:getContentSize().height/2))
	    vipLabel:setScale(1)
	end
	heroBg:setScale(0.7)
	return heroBg
end

function GameUIChat:getChatItem(chat)
	local isSelf = false
    local isVip = true
    
	local content = display.newNode()
	if not isSelf then
		local bottom = display.newScale9Sprite("chat_bubble_bottom.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, 0)
		local middle = display.newScale9Sprite("chat_bubble_middle.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height)
		local label = ui.newTTFLabel({
	            text = "hello1213123123123hello1213123123123hello1213123123123hello1213123123123hello1213123123123hello1213123123123",
	            size = 20,
	            color = UIKit:hex2c3b(0x403c2f),
	            align = ui.TEXT_ALIGN_LEFT,
	            valign = ui.TEXT_VALIGN_TOP,
	            dimensions = cc.size(430, 0),
	            font = UIKit:getFontFilePath(),
	    })
		middle:setContentSize(cc.size(middle:getContentSize().width,label:getContentSize().height))
		label:align(display.LEFT_BOTTOM, 25, 0):addTo(middle,2)
		local header = display.newScale9Sprite("chat_bubble_header.png"):addTo(content):align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height+middle:getContentSize().height)
		local imageName = isVip and "chat_green.png" or "chat_gray.png"
		local titleBg = display.newScale9Sprite(imageName):align(display.BOTTOM_LEFT, 12,18):addTo(header,3)
		titleBg:setContentSize(cc.size(300,titleBg:getContentSize().height))
		local titleLabel = ui.newTTFLabel({
	            text = "Dannyhe",
	            size = 22,
	            color = UIKit:hex2c3b(0xffedae),
	            align = ui.TEXT_ALIGN_LEFT,
	            valign = ui.TEXT_VALIGN_CENTER,
	            dimensions = cc.size(0, titleBg:getContentSize().height),
	            font = UIKit:getFontFilePath(),
	    }):align(display.LEFT_BOTTOM, 10, -5):addTo(titleBg,2)

	    local timeLabel =  ui.newTTFLabel({
	            text = "1 sec ago",
	            size = 16,
	            color = UIKit:hex2c3b(0x403c2f),
	            align = ui.TEXT_ALIGN_LEFT,
	            valign = ui.TEXT_VALIGN_CENTER,
	            font = UIKit:getFontFilePath(),
	    }):align(display.LEFT_BOTTOM,titleBg:getPositionX()+titleBg:getContentSize().width+20, titleBg:getPositionY()-2):addTo(header,3)
	    --button
	    -- chat_translation.png
	    local translateButton = cc.ui.UIPushButton.new({normal = "chat_translation.png"}, {scale9 = false})
	    translateButton:onButtonClicked(function(event)
			-- self:leftButtonClicked()
    	end):addTo(header,3)
    	translateButton:align(display.RIGHT_BOTTOM,timeLabel:getPositionX()+timeLabel:getContentSize().width+60,titleLabel:getPositionY()+titleLabel:getContentSize().height/2)
    	self:getChatIcon():addTo(content):align(display.LEFT_TOP, 1, bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
		local item = self.lv:newItem()
		item:addContent(content)
		item:setItemSize(549,bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height)
		return item
	else

	end
		return nil
end

function GameUIChat:createListView()
	self.lv = cc.ui.UIListView.new {
        bg = "chat_list_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.left+45, display.bottom+150, 549, display.height - self.header:getCascadeBoundingBox().size.height - self.editbox:getContentSize().height - 150 - 20),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
    	}
        :onTouch(handler(self, self.listviewListener))
        :addTo(self)

        local item = self:getChatItem()
        self.lv:addItem(item,1)

    self.lv:reload()
end

function GameUIChat:createHeader()
	local header = display.newNode()
	local bg = display.newSprite("common_header_bg.png"):align(display.LEFT_BOTTOM, 0,0):addTo(header)
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
    local titleLabel = ui.newTTFLabelWithShadow({
    	text = _("聊天"),
        font = UIKit:getFontFilePath(),
        size = 30,
        align = ui.TEXT_ALIGN_CENTER, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0xffedae),
        -- shadowColor = cc.c3b(255,0,0)
    }):addTo(header)
    titleLabel:pos(display.cx,bg:getContentSize().height/2 + 12)
    header:addTo(self):pos(0,display.top-bg:getContentSize().height)
    self.header = header
end

function GameUIChat:createTextFieldBody()
	-- body  bg
	display.newSprite("common_background.png"):align(display.LEFT_TOP, 0,display.height):addTo(self,-100)
	local function onEdit(event, editbox)
        if event == "returnSend" then
            ChatService:sendChat({text = editbox:getText(),type=self._channelType},function(err)
                editbox:setText('')
            end)
        end
    end
    local editbox = ui.newEditBox({
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

return GameUIChat