--
-- Author: Danny He
-- Date: 2014-09-22 19:44:50
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIDragonEquipment = UIKit:createUIClass("GameUIDragonEquipment")
local StarBar = import(".StarBar")
local UIListView = import(".UIListView")
local BODY_HEIGHT = 664
local LISTVIEW_WIDTH = 547
function GameUIDragonEquipment:ctor(equipment,isFromConfig,owner,dragon,equipmentCategory)
	GameUIDragonEquipment.super.ctor(self)
	self.equipment = equipment
	self.isFromConfig = isFromConfig
	self.owner = owner
	self.dragon = dragon
	self.equipmentCategory = equipmentCategory
end

function GameUIDragonEquipment:onEnter()
	local backgroundImage = WidgetUIBackGround.new(BODY_HEIGHT):addTo(self)
	self.background = backgroundImage:pos((display.width-backgroundImage:getContentSize().width)/2,300)
	local titleBar = display.newSprite("title_blue_596x49.png")
		:align(display.TOP_LEFT, 6,backgroundImage:getContentSize().height - 6)
		:addTo(backgroundImage)
	self.mainTitleLabel =  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "护甲",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xffedae)
	})
    :addTo(titleBar)
    :align(display.LEFT_BOTTOM, 10, 10)
    self.titleBar = titleBar

    local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(titleBar)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+25, 10)
	   	:onButtonClicked(function ()
	   		self:CloseButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	self:BuildInfoUI()
	self:RefreshInfoUI()
	local infoButton = self:GetButton(1)
		:addTo(backgroundImage)
		:align(display.LEFT_BOTTOM, 20, -55)
	infoButton.selected_ = true
	local intensifyButton = self:GetButton(2)
		:addTo(backgroundImage)
		:align(display.LEFT_BOTTOM, 183, -55)

	infoButton.setEvent(function( ... )
		if infoButton.selected_ then return end
		infoButton.selected_ = true
		infoButton.setSelected(true)
		intensifyButton.setSelected(false)
		self:RefreshInfoUI()
		self.info_ui.main:show()
	end)
	intensifyButton.setEvent(function( ... )
		if intensifyButton.selected_ then return end
		infoButton.selected_ = false
		intensifyButton.setSelected(true)
		infoButton.setSelected(false)
		self.info_ui.main:hide()
	end)
end

--type 为活力 力量 buffer 1 2 3
function GameUIDragonEquipment:GetListItem(index,type)
	local bg = display.newSprite(string.format("resource_item_bg%d.png",index%2))
	local icon = ""
	return bg
end


function GameUIDragonEquipment:BuildInfoUI()
	self.info_ui = {}
	local background = display.newNode():addTo(self):pos((display.width-self.background:getContentSize().width)/2,300)
	background:setContentSize(cc.size(self.background:getContentSize().width,self.background:getContentSize().height))
   	local mainEquipment = self:GetEquipmentItem()
   	:addTo(background)
   	:align(display.LEFT_TOP,(self.background:getContentSize().width-LISTVIEW_WIDTH)/2,self.titleBar:getPositionY()-self.titleBar:getContentSize().height - 10)

   	local titleLable = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "护甲1",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(background):align(display.LEFT_TOP, mainEquipment:getPositionX()+mainEquipment:getContentSize().width+20, mainEquipment:getPositionY()-10)
    self.info_ui.titleLable = titleLable
   	local countLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "数量 1/4",
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(background):align(display.LEFT_BOTTOM, mainEquipment:getPositionX()+mainEquipment:getContentSize().width+20, mainEquipment:getPositionY()-mainEquipment:getContentSize().height+10)
   	self.info_ui.countLabel = countLabel
   	local resetButton = cc.ui.UIPushButton.new({
   	normal = "dragon_yellow_button.png",
   	pressed = "dragon_yellow_button_h.png",
   	disabled="yellow_disable_185x65.png"}, {scale9 = false})
   		:setButtonLabel("normal",cc.ui.UILabel.new({
	        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	        text = _("装备"),
	        font = UIKit:getFontFilePath(),
	        size = 24,
	        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
	        color = UIKit:hex2c3b(0xfff3c7)
    	}))
   		:addTo(background)
   		:align(display.LEFT_BOTTOM,mainEquipment:getPositionX()+mainEquipment:getContentSize().width+260,mainEquipment:getPositionY()-mainEquipment:getContentSize().height)
   		:onButtonClicked(function()
   			self:AdornOrResetButtonClicked()
   		end)
   	self.info_ui.adornOrResetButton = resetButton
   	local descLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("消耗相同一个装备，重新随机装备的加成属性"),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(background):align(display.LEFT_TOP, mainEquipment:getPositionX(), mainEquipment:getPositionY()-mainEquipment:getContentSize().height-30)
   	self.info_ui.descLabel = descLabel
    self.info_ui.listView = UIListView.new {
        viewRect = cc.rect((self.background:getContentSize().width-LISTVIEW_WIDTH)/2, 180, LISTVIEW_WIDTH, 250),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    }
    :addTo(background)
    --test
    for i=1,10 do
    	local item = self.info_ui.listView:newItem()
    	local content = self:GetListItem(i)
    	item:addContent(content)
    	item:setItemSize(LISTVIEW_WIDTH, 40)

   	 self.info_ui.listView:addItem(item)
    end
 	self.info_ui.listView:reload()

 	local makeButton  = cc.ui.UIPushButton.new({
   	normal = "dragon_yellow_button.png",
   	pressed = "dragon_yellow_button_h.png",
   	disabled="yellow_disable_185x65.png"}, {scale9 = false})
   		:setButtonLabel("normal",cc.ui.UILabel.new({
	        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	        text = _("制作"),
	        font = UIKit:getFontFilePath(),
	        size = 24,
	        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
	        color = UIKit:hex2c3b(0xffedae)
    	})):addTo(background):pos(background:getContentSize().width/2, 80)
    local descLabel2 = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("立即前往铁匠铺制作"),
        font = UIKit:getFontFilePath(),
        size = 18,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER,makeButton:getPositionX(),makeButton:getPositionY()-50):addTo(background)
    self.info_ui.makeButton = makeButton
    self.info_ui.descLabel2 = descLabel2
    self.info_ui.main = background
end


function GameUIDragonEquipment:AdornOrResetButtonClicked()
	local config_equipments = self.owner.building:GetEquipmentsByStarAndType(self.dragon.star,self.dragon.type)
	local  equipment = config_equipments[self.equipmentCategory]
    if self.isFromConfig then --来自服务器
		PushService:setDragonEquipment(self.dragon.type,self.equipmentCategory,equipment.name,function( success)

		end)
    end
end

function GameUIDragonEquipment:GetEquipmentItem()
    local config_equipments = self.owner.building:GetEquipmentsByStarAndType(self.dragon.star,self.dragon.type)
    local  equipment = config_equipments[self.equipmentCategory]
    if not self.isFromConfig then --来自服务器
        equipment = self.dragon.equipments[self.equipmentCategory]
    end
    local bgImage,equipmentIcon = self.owner:GetEquipmentItemImageInfo(self.dragon.type,self.equipmentCategory,self.dragon.star)
    local bg = display.newSprite(bgImage)
    if not self.isFromConfig then 
    	display.newSprite(equipmentIcon):addTo(bg):align(display.LEFT_BOTTOM, 0, 0):setScale(0.8)
    	local stars_bg = display.newSprite("dragon_eq_stars_bg.png"):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width,0)
    	StarBar.new({
	        max = self.dragon.star,
	        bg = "Stars_bar_bg.png",
	        fill = "Stars_bar_highlight.png", 
	        num = equipment.star,
	        margin = 0,
	        direction = StarBar.DIRECTION_VERTICAL,
	        scale = 0.6,
    	}):addTo(stars_bg):align(display.LEFT_BOTTOM,5, 3)
    else
    	display.newFilteredSprite(equipmentIcon,"GRAY", {0.2, 0.3, 0.5, 0.1}):addTo(bg):opacity(23):align(display.LEFT_BOTTOM, 0, 0):setScale(0.8)
    end
    return bg
end

function GameUIDragonEquipment:AdornOrResetButtonClicked()
	local config_equipments = self.owner.building:GetEquipmentsByStarAndType(self.dragon.star,self.dragon.type)
	local  equipment = config_equipments[self.equipmentCategory]
    if self.isFromConfig then --来自服务器
		PushService:setDragonEquipment(self.dragon.type,self.equipmentCategory,equipment.name,function( success)

		end)
	else
		PushService:resetDragonEquipment(self.dragon.type,self.equipmentCategory,function(success)

		end)
    end
end



function GameUIDragonEquipment:RefreshInfoUI()
	local config_equipments = self.owner.building:GetEquipmentsByStarAndType(self.dragon.star,self.dragon.type)
	local  equipment = config_equipments[self.equipmentCategory]
    if not self.isFromConfig then --来自服务器
        equipment = self.dragon.equipments[self.equipmentCategory]
    end
    self.mainTitleLabel:setString(self.equipmentCategory)
	if self.isFromConfig then -- 没有装备
		self.info_ui.adornOrResetButton.labels_['normal']:setString(_("装备"))
		if DataManager:getUserData().dragonEquipments[equipment.name] > 0 then
			self.info_ui.makeButton:hide()
			self.info_ui.descLabel2:hide()
		else
			self.info_ui.adornOrResetButton:setButtonEnabled(false)
			self.info_ui.makeButton:show()
			self.info_ui.descLabel2:show()
		end
	else -- 已经装备
		self.info_ui.adornOrResetButton.labels_['normal']:setString(_("重置"))
	end
	self.info_ui.titleLable:setString(equipment.name)
	self.info_ui.countLabel:setString(DataManager:getUserData().dragonEquipments[equipment.name] .. "/" ..  City:GetFirstBuildingByType("materialDepot"):GetMaxMaterial())
end

function GameUIDragonEquipment:GetBuffWithEquipment()

end

function GameUIDragonEquipment:GetButton(index)
	local button = display.newSprite(index == 1 and "equipemt_sort_170x87.png" or "equipemt_sort_169x67.png")
	button.index_ = index
	cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text =  index == 1 and _("信息") or _("强化"),
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(button):align(display.CENTER,button:getContentSize().width/2, 35)
    button.setSelected = function(b)
    	if b then
    		button:setTexture("equipemt_sort_170x87.png")
    	else
    		button:setTexture("equipemt_sort_169x67.png")
    	end
   	end
    -- setTexture
    button.setEvent = function(func)
	    button:setTouchEnabled(true)
	  	button:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
	    local name, x, y = event.name, event.x, event.y
	    	if name == "ended" and button:getCascadeBoundingBox():containsPoint(cc.p(x,y)) then
	            func()
	        end
	        return button:getCascadeBoundingBox():containsPoint(cc.p(x,y))
	    end)
	end
	return button
end

function GameUIDragonEquipment:CloseButtonClicked()
	self:removeFromParentAndCleanup(true)
end

return GameUIDragonEquipment