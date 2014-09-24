--
-- Author: Danny He
-- Date: 2014-09-13 10:30:04
--
local GameUIResource = UIKit:createUIClass("GameUIResource","GameUIUpgradeBuilding")
local ResourceManager = import("..entity.ResourceManager")
local City = City
local MAX_COUNT_DECORATOR = 5
local UIListView = import(".UIListView")
function GameUIResource:ctor(building)
	 GameUIResource.super.ctor(self, City, self:GetTitleByType(building),building)
     self.building = building
     self.dataSource = self:GetDataSource()
end


function GameUIResource:onEnter()
    GameUIResource.super.onEnter(self)
    self:CreateUI()
end
function GameUIResource:CreateUI()
	self:CreateInfomation()
	self:createTabButtons()
end

function GameUIResource:createTabButtons()
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "infomation",
        }
    },
    function(tag)
        if tag == 'infomation' then
            self.infomationLayer:setVisible(true)
            self:RefreshListView()
        else
            self.infomationLayer:setVisible(false)
        end
    end):pos(display.cx, display.bottom + 50)
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
    }):addTo(lvBg):pos(lvBg:getContentSize().width/2,lvBg:getContentSize().height/2)

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
	        color = UIKit:hex2c3b(0xffedae),
   	 	}))
   	 	:setButtonLabelOffset(0, 2)
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

    self.listView = UIListView.new {
        viewRect = cc.rect(listHeader:getPositionX(), listHeader:getPositionY()-listHeader:getContentSize().height-500, listHeader:getContentSize().width,500),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
    	}
        :addTo(self.infomationLayer)
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
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x797154),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER})
		:addTo(bg)
        :pos(10,20)
	local valLabel = cc.ui.UILabel.new({
    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    	text = val,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT, 
        color = UIKit:hex2c3b(0x403c2f),
        valign = cc.ui.UILabel.TEXT_VALIGN_CENTER})
		:addTo(bg)
		:pos(bg:getContentSize().width -10 , 20)
	item:addContent(bg)
	item:setItemSize(bg:getContentSize().width,bg:getContentSize().height)
	return item
end

function GameUIResource:RefreshListView()
    self.listView:removeAllItems()
	for i,v in ipairs(self.dataSource) do
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
        table.insert(dataSource,{title .. ' LV ' .. k ,'x' .. #v})
    end
    return dataSource
end


function GameUIResource:GetTitleByType(building)
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
    if self.building:IsUpgrading() then 
                local message = "正在升级"
                local dialog = PopDialogUI.new()
                dialog:setTitle("提示")
                dialog:setPopMessage(message)
                display.getRunningScene():addChild(dialog,1000000)
                return 
            end
            if tonumber(City:GetResourceManager():GetGemResource():GetValue()) < 100 then
                local message = "宝石不足"
                local dialog = PopDialogUI.new()
                dialog:setTitle("提示")
                dialog:setPopMessage(message)
                dialog:setNeedGems(100)
                display.getRunningScene():addChild(dialog,1000000)
                return
            end
            local tile = self.city:GetTileWhichBuildingBelongs(self.building)
            local house_location = tile:GetBuildingLocation(self.building)
            NetManager:destroyHouseByLocation(tile.location_id, house_location, 
            NOT_HANDLE)
            self:leftButtonClicked(nil)
end

function GameUIResource:onMovieOutStage()
    self.dataSource = nil
    self.building = nil
    GameUIResource.super.onMovieOutStage(self)
end

function GameUIResource:OnResourceChanged(resource_manager)
    GameUIResource.super.OnResourceChanged(self,resource_manager)
    -- if self.listView:getItems():count() < 2 then return end
    local number = City.resource_manager:GetResourceByType(self.building:GetUpdateResourceType()):GetResourceValueByCurrentTime(app.timer:GetServerTime())
    print("update cout:",number)
end

return GameUIResource