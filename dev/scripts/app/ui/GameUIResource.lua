--
-- Author: Danny He
-- Date: 2014-09-13 10:30:04
--
local GameUIResource = UIKit:createUIClass("GameUIResource")
local TabButtons = import(".TabButtons")
local ResourceManager = import("..entity.ResourceManager")
local City = City
local MAX_COUNT_DECORATOR = 5

function GameUIResource:ctor(building)
	 GameUIResource.super.ctor(self)
     self.building = building
     self.dataSource = self:GetDataSource()
	 self:CreateUI()
end

function GameUIResource:CreateUI()
	self:CreateHeader()
	self:CreateBG()
	self:CreateInfomation()
	self:createTabButtons()
end

function GameUIResource:createTabButtons()
	local tab_buttons = TabButtons.new({
        {
            label = _("升级"),
            tag = "upgrade",
            default = true,
        },
        {
            label = _("信息"),
            tag = "infomation",
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
    	if tag == 'infomation' then
    		self.infomationLayer:setVisible(true)
    		self:RefreshListView()
    	else
    		self.infomationLayer:setVisible(false)
    	end
    end):addTo(self):pos(display.cx, display.bottom + 50)
end

function GameUIResource:CreateHeader()
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
    	text = _("木工小屋"),
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

function GameUIResource:CreateBG()
	-- body  bg
	local left = display.newScale9Sprite("common_bg_left.png"):align(display.LEFT_TOP, display.left + 20, display.top):addTo(self,-99)
	left:setContentSize(cc.size(left:getContentSize().width,display.height))
	local right = display.newScale9Sprite("common_bg_left.png"):align(display.RIGHT_TOP, display.right - 20, display.top):addTo(self,-99)
	right:setContentSize(cc.size(right:getContentSize().width,display.height))
	display.newScale9Sprite("common_bg_center.png"):align(display.LEFT_TOP, 0,display.height):addTo(self,-100):setContentSize(cc.size(display.width,display.height))
	display.newSprite("common_bg_top.png"):align(display.LEFT_TOP, 30, display.top - 72):addTo(self)
	display.newSprite("common_bg_top.png"):align(display.LEFT_BOTTOM, 30, display.bottom):addTo(self)
end

function GameUIResource:CreateInfomation()
	local infomationLayer = display.newNode():addTo(self)
	self.infomationLayer = infomationLayer
	local iconBg = display.newSprite("resource_icon_background.png"):align(display.LEFT_TOP, display.left+60, display.top - 110):addTo(infomationLayer)
	display.newSprite("resource_icon.png"):align(display.CENTER, iconBg:getContentSize().width/2, iconBg:getContentSize().height/2):addTo(iconBg)
	local lvBg = display.newSprite("LV_background.png"):align(display.LEFT_TOP, display.left+60, iconBg:getPositionY()-iconBg:getContentSize().height-10):addTo(infomationLayer)
	local lvLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = "OWN 998",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x403c2f),
    }):addTo(lvBg):pos(lvBg:getContentSize().width/2,lvBg:getContentSize().height/2-5)

    local titleLable = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = _("拆除这个建筑"),
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x29261c),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer):align(display.LEFT_TOP,iconBg:getPositionX()+iconBg:getContentSize().width+20,iconBg:getPositionY())

    local chaiButton = cc.ui.UIPushButton.new({normal = "resource_butter_red.png",pressed = "resource_butter_red_highlight.png"}, {scale9 = false})
    	:addTo(infomationLayer)
    	:align(display.TOP_RIGHT, display.right-60, iconBg:getPositionY())
    	:setButtonLabel("normal",  cc.ui.UILabel.new({
	    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	    	text = _("拆除"),
	        font = UIKit:getFontFilePath(),
	        size = 22,
	        color = UIKit:hex2c3b(0x29261c),
   	 	}))
   	 	:setButtonLabelOffset(0, -5)
	    :onButtonClicked(function(event)
	    	self:ChaiButtonAction(event)
    	end)
    local fistLine = display.newScale9Sprite("dividing_line.png")
    :align(display.BOTTOM_LEFT, titleLable:getPositionX(),lvBg:getPositionY()+lvBg:getContentSize().height-15)
    :addTo(infomationLayer)

    local firstLable = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = _("返还城民"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x797154),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
    :align(display.LEFT_BOTTOM,fistLine:getPositionX(),fistLine:getPositionY()-5)

    local firstValueLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = "-100",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
    :align(display.RIGHT_BOTTOM,chaiButton:getPositionX(),firstLable:getPositionY())
    self.firstValueLabel = firstValueLabel
    local secondLine = display.newScale9Sprite("dividing_line.png")
    :align(display.BOTTOM_LEFT, firstLable:getPositionX(),lvBg:getPositionY()-lvBg:getContentSize().height)
    :addTo(infomationLayer)

    local secondLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = _("城民增长"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x797154),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
    :align(display.LEFT_BOTTOM,secondLine:getPositionX(),secondLine:getPositionY()-5)
    self.secondLabel = secondLabel
    self.secondValueLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = "-100/h",
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT, 
        dimensions = cc.size(500, 33),
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    }):addTo(infomationLayer)
    :align(display.RIGHT_BOTTOM,chaiButton:getPositionX(),secondLabel:getPositionY())

    local listHeader = display.newScale9Sprite("resources_background_header.png")
	:addTo(infomationLayer)
	:align(display.TOP_LEFT, display.left+45,secondLine:getPositionY()-30)

	cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = _("总计"),
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        dimensions = cc.size(listHeader:getContentSize().width, listHeader:getContentSize().height),
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER
    })
    :addTo(listHeader,5)
    :pos(listHeader:getContentSize().width/2,listHeader:getContentSize().height/2-4)

    self.listView = cc.ui.UIListView.new {
        viewRect = cc.rect(listHeader:getPositionX(), listHeader:getPositionY()-listHeader:getContentSize().height-500, listHeader:getContentSize().width,500),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
    	}
        :addTo(self)
    self.infomationLayer:setVisible(false)
end


function GameUIResource:GetListItem(index,title,val)
	local bgImage = string.format("resource_item_bg%d.png",tonumber(index-1)%2)
	local item = self.listView:newItem()
	local bg = display.newSprite(bgImage)
	local titleLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = title,
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER})
		:addTo(bg)
		:align(display.LEFT_BOTTOM, 10, 0)
	local valLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = val,
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT, 
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER})
		:addTo(bg)
		:align(display.RIGHT_BOTTOM,bg:getContentSize().width -10 , 0)
	item:addContent(bg)
	item:setItemSize(bg:getContentSize().width,bg:getContentSize().height)
	return item
end

function GameUIResource:RefreshListView()
	for i,v in ipairs(table_name) do
		local newItem = self:GetListItem(i,v[1],v[2])
		self.listView:addItem(newItem)
	end
	self.listView:reload()
end

function GameUIResource:GetDataSource()
    local dataSource = {{_('待建地基'),'x' .. #City:GetRuinsNotBeenOccupied()}}
    local decorators = City:GetDecoratorsByType(self.building:GetType())
    table.insert(dataSource,{_('可建造数量'),#decorators .. '/' .. MAX_COUNT_DECORATOR})

    local number = City.resource_manager:GetResourceByType(self.building:GetUpdateResourceType()):GetResourceValueByCurrentTime(app.timer:GetServerTime())
    table.insert(dataSource,{_('当前产出'),string.format('%d',number)})
    local levelTable = {}
    for _,v in ipairs(decorators) do
        if levelTable[tostring(v:GetLevel())] then
            table.insert(levelTable[tostring(v:GetLevel())],v)
        else
            levelTable[tostring(v:GetLevel())] = {v}
        end
    end
    local title = self:GetTitleByType(self.building)
    for k,v in pairs(levelTable) do
        table.insert(dataSource,{title .. ' LV' .. k ,'x' .. #v})
    end
    return dataSource
end


function GameUIResourceCutter:GetTitleByType(building)
    local type = building:GetUpdateResourceType()
    if type == ResourceManager.RESOURCE_TYPE.WOOD then
        return _('木工小屋'),_('木材产量')
    elseif type == ResourceManager.RESOURCE_TYPE.IRON then
        return _('矿工小屋'),_('铁矿产量')
    elseif type == ResourceManager.RESOURCE_TYPE.STONE then
        return _('石匠小屋'),_('石料产量')
    elseif type == ResourceManager.RESOURCE_TYPE.FOOD then
        return _('农夫小屋'),_('粮食产量')
    elseif type == ResourceManager.RESOURCE_TYPE.POPULATION then
        return _('住宅'),_('城民产量')
    else
        assert(false)
    end
end

function GameUIResource:onMovieInStage()
	GameUIResource.super.onMovieInStage(self)
	local resource = City.resource_manager:GetResourceByType(self.building:GetUpdateResourceType())
    local citizen = self.building:GetCitizen()
    self.firstValueLabel:setString(string.format('%d',citizen))
    local _,resource_title = self:GetTitleByType(self.building)
    self.secondLabel:setString(resource_title)
    self.secondValueLabel:setString(string.format("%d/h",resource:GetProductionPerHour()))
end

function GameUIResource:ChaiButtonAction( event )

end

function GameUIResource:onMovieOutStage()
	self.dataSource = nil
	self.building = nil
	self.
end

return GameUIResource