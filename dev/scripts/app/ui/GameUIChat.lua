--
-- Author: Danny He
-- Date: 2014-09-11 09:19:55
--
local GameUIChat = UIKit:createUIClass('GameUIChat')
local UIListView = import(".UIListView")
local TabButtons = import('.TabButtons')
local ChatService = import('..service.ChatService')
local ChatCenter = app.chatCenter
local NetService = import('..service.NetService')
local window = import("..utils.window")

GameUIChat.LISTVIEW_WIDTH = 549
GameUIChat.PLAYERMENU_ZORDER = 2


function GameUIChat:onEnter()
	self:CreateBackGround()
    self:CreateTitle(_("聊天"))
    self:CreateHomeButton()
    self:CreateSettingButton()
end

function GameUIChat:CreateSettingButton()
	--right button
	local rightbutton = cc.ui.UIPushButton.new({normal = "common_back_button.png",pressed = "common_back_button_highlight.png"}, {scale9 = false})
		:onButtonClicked(function(event)
			self:CreatShieldView()
    	end)
    	:align(display.TOP_LEFT, 0, 0)
    	:addTo(self)
    rightbutton:setRotation(90)
    rightbutton:pos(display.right,display.top)
   	display.newSprite("chat_setting.png")
   		:addTo(self)
   		:pos(display.right-45, display.top-50)
end

function GameUIChat:CreateTabButtons()
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
    	-- self._channelType = string.lower(tag)
     --    self.page = 1
     --    self:RefreshListView()
    end):addTo(self):pos(display.cx, display.bottom + 50)
end

-- response from chatcenter
function GameUIChat:messageEvent( event,data )
    if event == 'onRefresh' or event == 'onPush' then
        self.page = 1
        self:RefreshListView()
    end
end

function GameUIChat:onMovieInStage()
	GameUIChat.super.onMovieInStage(self)
	self:CreateTextFieldBody()
	self:CreateListView()
	self:CreateTabButtons()
	ChatCenter:AddObserver(self)
end

function GameUIChat:onMovieOutStage()
	self.blackListView = nil
	ChatCenter:RemoveObserver(self)
	GameUIChat.super.onMovieOutStage(self)
end

function GameUIChat:listviewListener(event)
	if event.name == 'SCROLLVIEW_EVENT_BOUNCE_BOTTOM' then
		  print('get more message!')
            self.page = self.page + 1
            local data = ChatCenter:getAllMessages(self._channelType,self.page)
            if #data == 0 and self.page > 1 then
                self.page = self.page - 1
                return
            end
            for i,v in ipairs(data) do
                local newItem  = self:getChatItem(v)
                self.listView:addItem(newItem)
            end
            self.listView:resetPosition()
            self.listView:reload()
            self.listView:resetPosition()
		return
	end
	if not event.listView:isItemInViewRect(event.itemPos) then
        return
    end

    print("GameUIChat:listviewListener event:" .. event.name .. " pos:" .. event.itemPos)
    local listView = event.listView
    if "clicked" == event.name then
    	self:CreatePlayerMenu(event)
    end
end

function GameUIChat:GetChatIcon( chat )
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
		-- local item = self.listView:newItem()
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
		local playerIcon = self:GetChatIcon(chat)
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
	 	--adjustFunc
	    local adjustFunc = function()
	    	middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
	    	header:align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height+middle:getContentSize().height)
	    	playerIcon:pos(playerIcon:getPositionX(),bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
	    	item:setItemSize(549,bottom:getContentSize().height+header:getContentSize().height+middle:getContentSize().height)
	    end
	    --button
	    -- chat_translation.png
	    local translateButton = cc.ui.UIPushButton.new({normal = "chat_translation.png"}, {scale9 = false})
	    	:addTo(header,3)
	    	:onButtonClicked(function(event)
		    	-- local oldHight = contentLable:getContentSize().height
	            if not chat._translate_ then
	                GameUtils:Translate(chat.text,function(result,errText)
	                    if result then
	                        chat._translate_ = result
	                        chat._translateMode_ = true
	                        contentLable:setString(chat._translate_)
	                    else
	                        print('Translate error------->',errText)
	                    end
	                end)
	            else
	                if chat._translateMode_ then
	                    chat._translateMode_ = false
	                    contentLable:setString(chat.text)
	                else
	                    chat._translateMode_ = true
	                    contentLable:setString(chat._translate_)
	                end
	            end
				-- local offsetY = contentLable:getContentSize().height - oldHight
				adjustFunc()
    		end)
    		:align(display.RIGHT_BOTTOM,header:getContentSize().width-10,titleLabel:getPositionY()+titleLabel:getContentSize().height/2)
    	playerIcon:addTo(content):align(display.LEFT_TOP, 1, bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
		-- item:addContent(content)
		-- item:setItemSize(549,bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height)
		return content
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

		self:GetChatIcon(chat):addTo(content):align(display.RIGHT_TOP, 549, bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
		-- local item = self.listView:newItem()
		-- item:addContent(content)
		-- item:setItemSize(549,bottom:getContentSize().height+header:getContentSize().height+middle:getContentSize().height)
		return content
	end
		return nil
end

function GameUIChat:RefreshListView()
    if not  self._channelType then 
        self._channelType = 'global'
    end
    self.listView:removeAllItems()
    for i,v in ipairs(ChatCenter:getAllMessages(self._channelType)) do
    	print("add item listview---->")
        local newItem  = self:getChatItem(v)
        self.listView:addItem(newItem)
    end
    self.listView:reload()
end

function GameUIChat:CreateListView()
	-- self.listView = UIListView.new {
 --        bg = "chat_list_bg.png",
 --        bgScale9 = true,
 --        viewRect = cc.rect(display.left+45, display.bottom+110, 549, self.editbox:getPositionY() - self.editbox:getContentSize().height - 130),
 --        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
 --        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
 --    	}
 --        :onTouch(handler(self, self.listviewListener))
 --        :addTo(self)
 	local listView  = cc.TableView:create(cc.size(549, self.editbox:getPositionY() - self.editbox:getContentSize().height - 130))
    listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    listView:setDelegate()
    listView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    listView:addTo(self):pos(window.left+45,window.bottom+110)

    listView:registerScriptHandler(handler(self,self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    listView:registerScriptHandler(handler(self,self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    listView:registerScriptHandler(handler(self,self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.listView = listView
    listView:reloadData()
end

-----------------------CCTableView adapter

function GameUIChat:cellSizeForTable(table,idx)
	return 60,549 --height,width
end

function GameUIChat:tableCellAtIndex(table, idx)
	local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
    	print("create new cell------->")
        cell = cc.TableViewCell:new()
        local sprite = cc.Sprite:create("chat_bubble_bottom.png")
        sprite:setAnchorPoint(cc.p(0,0))
        sprite:setPosition(cc.p(0, 0))
        cell:addChild(sprite)

        label = cc.Label:createWithSystemFont(strValue, "Helvetica", 20.0)
        label:setPosition(cc.p(0,0))
        label:setAnchorPoint(cc.p(0,0))
        label:setTag(123)
        cell:addChild(label)
    else
        label = cell:getChildByTag(123)
        if nil ~= label then
            label:setString(strValue)
        end
    end

    return cell

end


function GameUIChat:numberOfCellsInTableView()
	print("------>")
	return 25
end



-----------------------end
function GameUIChat:CreateTextFieldBody()
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
    editbox:align(display.LEFT_TOP,display.left+46,display.height - 100):addTo(self)
    self.editbox = editbox

    -- body button

	local emojiButton = cc.ui.UIPushButton.new({normal = "chat_expression.png",pressed = "chat_expression_highlight.png",},{scale9 = false})
		:onButtonClicked(function(event)
			 ChatService:sendChat({text = editbox:getText(),type=self._channelType},function(err)
                editbox:setText('')
            end)
    	end)
    	:addTo(self)
    	:align(display.LEFT_TOP,self.editbox:getPositionX()+self.editbox:getContentSize().width+10, display.height - 100)
    local plusButton = cc.ui.UIPushButton.new({normal = "chat_add.png",pressed = "chat_add_highlight.png",}, {scale9 = false})
    	:onButtonClicked(function(event)

		end)
		:addTo(self)
		:align(display.LEFT_TOP, emojiButton:getPositionX()+emojiButton:getCascadeBoundingBox().size.width+10,emojiButton:getPositionY()-2)
end


function GameUIChat:RefreshBlockedList(widthOfList)
	self.blackListView:removeAllItems()
	local blockListDataSource = ChatCenter:getBlockedList()
	for _,v in ipairs(blockListDataSource) do
		local newItem = self:GetBlackListItem(v,widthOfList)
    	self.blackListView:addItem(newItem)
	end
	self.blackListView:reload()
end


function GameUIChat:GetBlackListItem(chat,width)
	local item = self.blackListView:newItem()
	local bg = display.newScale9Sprite("chat_setting_item_bg.png")
	bg:size(width,bg:getContentSize().height)
	--content
	local iconBg = display.newSprite("chat_hero_background.png")
		:addTo(bg,2)
		:pos(60,math.floor(bg:getContentSize().height/2))
	iconBg:setScale(0.8)
	display.newSprite("Hero_1.png")
		:addTo(iconBg)
		:pos(math.floor(iconBg:getContentSize().width/2),math.floor(iconBg:getContentSize().height/2)+4)
		:setScale(1)
	local nameLabel = cc.ui.UILabel.new({
        UILabelType = 2,
        text = chat.fromName or "player" ,
        size = 22,
        color = UIKit:hex2c3b(0x403c2f),
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
	}):addTo(bg,2)
	  :pos(iconBg:getPositionX()+50,iconBg:getPositionY()+20)

	local allianceLabel = cc.ui.UILabel.new({
        UILabelType = 2,
        text = chat.fromAlliance or "",
        size = 16,
        color = UIKit:hex2c3b(0x403c2f),
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
	}):addTo(bg,2)
	  :pos(iconBg:getPositionX()+50,iconBg:getPositionY()-10)

	cc.ui.UIPushButton.new({normal="chat_setting_item_yellow.png",pressed="chat_setting_item_yellow_h.png"}, {scale9 = false})
        :onButtonClicked(function(event)
        	local success,index = ChatCenter:removeItemFromBlockList(chat.fromId)
   			if success then
        		self.blackListView:removeItem(item,false)
   			end
        end)
        :setButtonLabel("normal",cc.ui.UILabel.new({
	        UILabelType = 2,
	        text = _("取消屏蔽"),
	        size = 22,
	        color = UIKit:hex2c3b(0xfff3c7),
	        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
		}))
        :align(display.RIGHT_TOP,bg:getContentSize().width - 30, allianceLabel:getPositionY()+10)
        :addTo(bg,2)
	---
	item:addContent(bg)
	item:setItemSize(width,bg:getContentSize().height)
	return item
end


function GameUIChat:CreatShieldView()
	self:setEditBoxAble(false)
	local shieldView = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
		:addTo(self,self.PLAYERMENU_ZORDER)
    local bg = display.newSprite("chat_setting_bg.png")
    	:addTo(shieldView)
    	:pos(display.cx,display.cy)
    local header = display.newSprite("chat_setting_Title_blue.png")
    	:addTo(bg)
    	:align(display.TOP_LEFT,8,bg:getContentSize().height-8)
    cc.ui.UIPushButton.new({normal="chat_setting_x.png",pressed="chat_setting_x_highlight.png"}, {scale9 = false})
        :onButtonClicked(function(event)
        	shieldView:removeFromParent(true)
        	self:setEditBoxAble(true)
        end)
        :pos(bg:getContentSize().width-12, bg:getContentSize().height-8)
        :addTo(bg)
    display.newSprite("chat_setting_x_btn.png")
    	:addTo(bg)
    	:pos(bg:getContentSize().width-12, bg:getContentSize().height-10)
   local translation = display.newSprite("chat_translation.png")
    	:addTo(bg)
    	:pos(50,bg:getContentSize().height-100)
   	cc.ui.UILabel.new({
            UILabelType = 2,
            text = _("设置"),
            size = 24,
            color = UIKit:hex2c3b(0xffedae),
            dimensions = cc.size(bg:getContentSize().width - translation:getPositionX() - 50 - translation:getContentSize().width, 0),
	}):addTo(header):pos(10,25)
   	local descLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text = _("点击后，会根据你的系统语言，将其他玩家发言翻译成你熟悉的语种。若要修改翻译的语种，请修改你当前的系统语种。"),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f),
            dimensions = cc.size(bg:getContentSize().width - translation:getPositionX() - 50 - translation:getContentSize().width, 0),
	}):addTo(bg)
	:pos(translation:getPositionX() + 50,translation:getPositionY())

   	local line = display.newScale9Sprite("dividing_line.png")
   		:addTo(bg)
   		line:size(bg:getContentSize().width - 40,line:getContentSize().height)
   		:align(display.TOP_LEFT, 20, translation:getPositionY() - descLabel:getContentSize().height)

   	local heightOfList,widthOfList = line:getPositionY() - 30,bg:getContentSize().width - 40
   	self.blackListView = UIListView.new {
        bg = "chat_setting_listview_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(20, 20, bg:getContentSize().width - 40,heightOfList),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
    	} 
    	:addTo(bg)
    self:RefreshBlockedList(widthOfList)
end

function GameUIChat:setEditBoxAble( b )
	self.editbox:setEnabled(b)
end

function GameUIChat:CreatePlayerMenu(event)
	self:setEditBoxAble(false)
	local item = event.item
	local chat = ChatCenter:getMessage(self.listView:getItemPos(item)-1,self.page,self._channelType)
	if DataManager:getUserData()._id == chat.fromId then return end -- if self return 
	local menuLayer = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    menuLayer:setTouchEnabled(true)
    menuLayer:addTo(self,self.PLAYERMENU_ZORDER):pos(0, 0)
    local tabBg = display.newSprite("chat_tab_backgroud.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(menuLayer)
    menuLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function()
    	menuLayer:removeFromParent(true)
    	self:setEditBoxAble(true)
    end)
	local x,y = item:getContent():getPosition()
    local p = item:convertToWorldSpace(cc.p(x,y))
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
        	local labelText = chat.text
            if chat._translate_ and chat._translateMode_ then
            	labelText = chat._translate_
        	end
        	ext.copyText(labelText)
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
            ChatCenter:add2BlockedList(chat)
            menuLayer:removeFromParent(true)
            self:setEditBoxAble(true)
            self:RefreshListView()
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