--
-- Author: Danny He
-- Date: 2014-09-11 09:19:55
--
local GameUIChat = UIKit:createUIClass('GameUIChat')
local UIListView = import(".UIListView")
local WidgetBackGroundTabButtons = import('..widget.WidgetBackGroundTabButtons')
local ChatService = import('..service.ChatService')
local ChatCenter = app.chatCenter
local NetService = import('..service.NetService')
local window = import("..utils.window")

GameUIChat.LISTVIEW_WIDTH = 549
GameUIChat.PLAYERMENU_ZORDER = 2
GameUIChat.CELL_BOTTM_TAG = 100
GameUIChat.CELL_MIDDLE_TAG = 101
GameUIChat.CELL_CONTENT_LABEL_TAG = 102
GameUIChat.CELL_HEADER_TAG = 103
GameUIChat.CELL_TITLE_LABEL_TAG = 103
GameUIChat.CELL_PLAYER_ICON_TAG = 104
GameUIChat.CELL_TIME_LABEL_TAG = 105
GameUIChat.CELL_TRANSLATEBUTTON = 106
GameUIChat.CELL_MAIN_CONENT_TAG = 107
GameUIChat.CELL_TITLE_BG_TAG = 108
GameUIChat.CELL_PLAYER_ICON_VIP_BG_TAG = 109
GameUIChat.CELL_PLAYER_ICON_VIP_LABEL_TAG = 110
GameUIChat.CELL_PLAYER_ICON_HERO_TAG = 111

function GameUIChat:onEnter()
	GameUIChat.super.onEnter(self)
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
    rightbutton:pos(window.right,window.top)
   	display.newSprite("chat_setting.png")
   		:addTo(self)
   		:pos(window.right-45, window.top-50)
end

function GameUIChat:CreateTabButtons()
	local tab_buttons = WidgetBackGroundTabButtons.new({
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
    function(tag)
    	self._channelType = string.lower(tag)
        self:RefreshListView()
    end):addTo(self):pos(window.cx, window.bottom + 34)
end

-- response from chatcenter
function GameUIChat:messageEvent( event,data )
    if event == 'onRefresh'  then
        self:RefreshListView()
    elseif event == 'onPush' then
        self.listView:insertCellAtIndex(#self.dataSource_-1)
        --顶部插头
    end
end

function GameUIChat:onMoveInStage()
	GameUIChat.super.onMoveInStage(self)
	self:CreateTextFieldBody()
	self:CreateListView()
	ChatCenter:AddObserver(self)
	self:CreateTabButtons()
end

function GameUIChat:onMoveOutStage()
	self.blackListView = nil
	ChatCenter:RemoveObserver(self)
	GameUIChat.super.onMoveOutStage(self)
end


function GameUIChat:GetChatIcon()
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
            -- dimensions = cc.size(vipBg:getContentSize().width, 0),
            font = UIKit:getFontFilePath(),
    }):addTo(vipBg):align(display.CENTER, math.floor(vipBg:getContentSize().width/2), math.floor(vipBg:getContentSize().height/2))
    vipLabel:setScale(1)
	heroBg:setScale(0.7)
	vipBg:setTag(self.CELL_PLAYER_ICON_VIP_BG_TAG)
	vipLabel:setTag(self.CELL_PLAYER_ICON_VIP_LABEL_TAG)
	return heroBg
end

function GameUIChat:GetChatItemCell()
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
	    -- chat_translation.png
    local translateButton = cc.ui.UIPushButton.new({normal = "chat_translation.png"}, {scale9 = false})
    	:addTo(header,3)
        :align(display.RIGHT_BOTTOM,header:getContentSize().width-10,titleLabel:getPositionY()+titleLabel:getContentSize().height/2)
  --   	:onButtonClicked(function(event)
  --           print("button test----->")
		-- end)
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



function GameUIChat:RefreshListView()
    if not  self._channelType then 
        self._channelType = 'global'
    end
    self.dataSource_ = ChatCenter:getAll(self._channelType)
    self.listView:reloadData()
end

function GameUIChat:CreateListView()
 	local listView  = cc.TableView:create(cc.size(549, 700))
    listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    listView:setDelegate()
    listView:addTo(self):pos(window.left+45,window.bottom+100)
    listView:registerScriptHandler(handler(self,self.cellSizeForTable),cc.TABLECELL_SIZE_FOR_INDEX)
    listView:registerScriptHandler(handler(self,self.tableCellAtIndex),cc.TABLECELL_SIZE_AT_INDEX)
    listView:registerScriptHandler(handler(self,self.numberOfCellsInTableView),cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    listView:registerScriptHandler(handler(self,self.tableCellTouched),cc.TABLECELL_TOUCHED)
    listView:registerScriptHandler(handler(self,self.tableViewScrollBoundTop),cc.SCROLLVIEW_BOUND_TOP)
    listView:registerScriptHandler(handler(self,self.tableViewScrollBoundBottom),cc.SCROLLVIEW_BOUND_BOTTOM)
    self.listView = listView
    listView:setTouchSwallowEnabled(false)
    print("list------>",listView:getLocalZOrder())
end

-----------------------CCTableView adapter
function GameUIChat:tableViewScrollBoundBottom()
    print("tableViewScrollBoundBottom-------->")
end

function GameUIChat:tableViewScrollBoundTop()
    print("tableViewScrollBoundTop-------->")
end

-- 回调被拓展成有
function GameUIChat:tableCellTouched(table,cell,x,y)
    local chat = self.dataSource_[cell:getIdx()+1]
    print("cell touched at index: " .. cell:getIdx(),x,y)
    if not chat then return end
    local isSelf = DataManager:getUserData()._id == chat.fromId
    local mainContent = cell:getChildByTag(self.CELL_MAIN_CONENT_TAG)
    if not isSelf then
        local currentContent = mainContent.other
        local header = currentContent:getChildByTag(self.CELL_HEADER_TAG)
        local buttonTranslate = header:getChildByTag(self.CELL_TRANSLATEBUTTON)
        --计算button的世界坐标
        local  p2world = header:convertToWorldSpace(cc.p(buttonTranslate:getPositionX()-buttonTranslate:getCascadeBoundingBox().width,buttonTranslate:getPositionY())) 
        local buttonRect =  buttonTranslate:getCascadeBoundingBox()
        buttonRect.x = p2world.x
        buttonRect.y = p2world.y
        --如果点中button不处理cell点击事件
        if cc.rectContainsPoint(buttonRect,cc.p(x,y)) then 
            local idx = cell:getIdx()
            --翻译
            if not chat._translate_ then
                GameUtils:Translate(chat.text,function(result,errText)
                    if result then
                        chat._translate_ = result
                        chat._translateMode_ = true
                        self.listView:updateCellAtIndex(idx)
                    else
                        print('Translate error------->',errText)
                    end
                end)
            else
                if chat._translateMode_ then
                    chat._translateMode_ = false
                else
                    chat._translateMode_ = true
                end
                self.listView:updateCellAtIndex(idx)
            end
        elseif not self.listView:isOutOfViewSize(cell) then
            self:CreatePlayerMenu(chat,cell)
        end
    end
end

-- 根据聊天信息的高度 计算cell的高度
function GameUIChat:cellSizeForTable(table,idx)
	local chat = self.dataSource_[idx+1]
	local w,h = 549,83
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
	h = 83 + contentLable:getContentSize().height
	return h,w --height,width
end

function GameUIChat:HandleCellUIData(mainContent,chat,cell)
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
    -- assert(bottom)
    -- assert(header)
    -- assert(middle)
    

    --header node
    local timeLabel = header:getChildByTag(self.CELL_TIME_LABEL_TAG)
    -- assert(timeLabel)
    local titleBg = header:getChildByTag(self.CELL_TITLE_BG_TAG)
    -- assert(titleBg)
    local titleLabel = titleBg:getChildByTag(self.CELL_TITLE_LABEL_TAG)
    -- assert(titleLabel)
    -- middle node
    local contentLable = middle:getChildByTag(self.CELL_CONTENT_LABEL_TAG)
    -- assert(contentLable)
    --bind
    titleLabel:setString(chat.fromName)
    if not chat.timeStr then
        chat.timeStr = NetService:formatTimeAsTimeAgoStyleByServerTime(chat.time)
    end
    timeLabel:setString(chat.timeStr)

    local palyerIcon = currentContent:getChildByTag(self.CELL_PLAYER_ICON_TAG)
    -- assert(palyerIcon)
    local hero = palyerIcon:getChildByTag(self.CELL_PLAYER_ICON_HERO_TAG)
    local vipBg = hero:getChildByTag(self.CELL_PLAYER_ICON_VIP_BG_TAG)
    local vipLabel = vipBg:getChildByTag(self.CELL_PLAYER_ICON_VIP_LABEL_TAG)

    -- assert(hero)
    -- assert(vipBg)
    -- assert(vipLabel)
    vipBg:setVisible(isVip)
    vipLabel:setVisible(isVip)
    vipLabel:setString('VIP ' .. chat.fromVip)
    local labelText = chat.text
    if chat._translate_ and chat._translateMode_ then
        labelText = chat._translate_
    end

    contentLable:setString(labelText) --聊天信息
    if not isSelf then
        --重新布局
        middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
        header:align(display.RIGHT_BOTTOM, 549, bottom:getContentSize().height+middle:getContentSize().height)
        palyerIcon:pos(palyerIcon:getPositionX(),bottom:getContentSize().height+middle:getContentSize().height+header:getContentSize().height-10)
    else
        middle:setContentSize(cc.size(middle:getContentSize().width,contentLable:getContentSize().height))
    end
end


function GameUIChat:tableCellAtIndex(table, idx)
    local chat = self.dataSource_[idx+1]
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local content = self:GetChatItemCell()
        content:setTag(self.CELL_MAIN_CONENT_TAG)
        cell:addChild(content)
    end

   	local mainContent = cell:getChildByTag(self.CELL_MAIN_CONENT_TAG)
    self:HandleCellUIData(mainContent,chat,cell)
    return cell
end


function GameUIChat:numberOfCellsInTableView()
	return #self.dataSource_
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
    editbox:align(display.LEFT_TOP,window.left+46,window.top - 100):addTo(self)
    self.editbox = editbox

    -- body button

	local emojiButton = cc.ui.UIPushButton.new({normal = "chat_expression.png",pressed = "chat_expression_highlight.png",},{scale9 = false})
		:onButtonClicked(function(event)
			 ChatService:sendChat({text = editbox:getText(),type=self._channelType},function(err)
                editbox:setText('')
            end)
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
		:addTo(self,self.PLAYERMENU_ZORDER):zorder(2)
    local bg = display.newSprite("chat_setting_bg.png")
    	:addTo(shieldView)
    	:pos(window.cx,window.cy)
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
	self.editbox:setEnable(b)
    self.listView:setTouchEnabled(b)
end

function GameUIChat:CreatePlayerMenu(chat,cell)
  self:setEditBoxAble(false)
  if DataManager:getUserData()._id == chat.fromId then return end -- if self return 
  local menuLayer = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
  menuLayer:setTouchEnabled(true)
  menuLayer:setTouchSwallowEnabled(true)
  menuLayer:addTo(self,self.PLAYERMENU_ZORDER):pos(0, 0)
    local tabBg = display.newSprite("chat_tab_backgroud.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(menuLayer)
    menuLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function()
      menuLayer:removeFromParent(true)
      self:setEditBoxAble(true)
    end)
    local content = self:GetChatItemCell()
    local x,y = cell:getPosition()
    local p = cell:getParent():convertToWorldSpace(cc.p(x,y))
    local posIntMenuLayer = menuLayer:convertToNodeSpace(p)
    content:addTo(menuLayer)
    content:setPosition(posIntMenuLayer)

    self:HandleCellUIData(content, chat)
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