--
-- Author: Danny He
-- Date: 2014-09-22 19:44:50
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIDragonEquipment = UIKit:createUIClass("GameUIDragonEquipment")
local StarBar = import(".StarBar")
local UIListView = import(".UIListView")
local config_category = GameDatas.DragonEyrie
local WidgetDragonEquipIntensify = import("..widget.WidgetDragonEquipIntensify")
local BODY_HEIGHT = 664
local LISTVIEW_WIDTH = 547

function GameUIDragonEquipment:ctor(owner,dragon,equipmentCategory)
	GameUIDragonEquipment.super.ctor(self)
	self.isFromConfig = dragon.equipments[equipmentCategory].name == ""
	self.owner = owner
	self.dragon = dragon
	self.equipmentCategory = equipmentCategory
end

function GameUIDragonEquipment:onEnter()
  GameUIDragonEquipment.super.onEnter(self)
	local backgroundImage = WidgetUIBackGround.new(BODY_HEIGHT):addTo(self)
	self.background = backgroundImage:pos((display.width-backgroundImage:getContentSize().width)/2,display.height - backgroundImage:getContentSize().height - 80)
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

  local closeButton = cc.ui.UIPushButton.new({normal = "X_2.png",pressed = "X_1.png"}, {scale9 = false})
	   	:addTo(titleBar)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+25, 10)
	   	:onButtonClicked(function ()
	   		self:CloseButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
  local mainEquipment = self:GetEquipmentItem()
    :addTo(backgroundImage)
    :align(display.LEFT_TOP,(backgroundImage:getContentSize().width-LISTVIEW_WIDTH)/2,self.titleBar:getPositionY()-self.titleBar:getContentSize().height - 10)
    self.mainEquipment = mainEquipment
    local titleLable = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "护甲1",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(backgroundImage):align(display.LEFT_TOP, mainEquipment:getPositionX()+mainEquipment:getContentSize().width+20, mainEquipment:getPositionY()-10)
    self.titleLable = titleLable
    local countLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "数量 1/4",
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(backgroundImage):align(display.LEFT_BOTTOM, mainEquipment:getPositionX()+mainEquipment:getContentSize().width+20, mainEquipment:getPositionY()-mainEquipment:getContentSize().height+10)
    self.countLabel = countLabel
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
      :addTo(backgroundImage)
      :align(display.LEFT_BOTTOM,mainEquipment:getPositionX()+mainEquipment:getContentSize().width+260,mainEquipment:getPositionY()-mainEquipment:getContentSize().height)
      :onButtonClicked(function()
        self:AdornOrResetButtonClicked()
      end)
  self.adornOrResetButton = resetButton
	self:BuildInfoUI()
	
	local infoButton = self:GetButton(1)
		:addTo(backgroundImage)
		:align(display.LEFT_BOTTOM, 20, -57)
	infoButton.selected_ = true
	local intensifyButton = self:GetButton(2)
		:addTo(backgroundImage)
		:align(display.LEFT_BOTTOM, 190, -57)
  
  self.infoButton = infoButton
  self.intensifyButton = intensifyButton

	infoButton.setEvent(function( ... )
		  self:InfoButtonAction()
	end)
	intensifyButton.setEvent(function( ... )
	   self:IntensifyButtonAction()
	end)
  self:RefreshInfoUI()
end

function GameUIDragonEquipment:InfoButtonAction()
    if self.infoButton.selected_ then return end
    self.infoButton.setSelected(true)
    self.intensifyButton.setSelected(false)
    self:RefreshInfoUI()
    self.info_ui.main:show()
    self.intensify_ui.main:hide()
end

function GameUIDragonEquipment:IntensifyButtonAction()
    if self.intensifyButton.selected_ then return end
    self.intensifyButton.setSelected(true)
    self.infoButton.setSelected(false)
    if not self.intensify_ui then
      self:BuildIntensifyUI()
    end
    self:RefreshIntensifyUI()
    self.intensify_ui.main:show()
    self.info_ui.main:hide()
end


--type 为活力 力量 buffer 1 2 3
function GameUIDragonEquipment:GetListItem(index,type,title,value)
	local bg = display.newSprite(string.format("resource_item_bg%d.png",index%2))
	local icon = "dragon_vitality_33x42.png"
  -- print("GetListItem---->",index,type,title,value)
  if type == 2 then
    icon = "dragon_strength_27x31.png"
  elseif type == 3 then
    icon = "dragon_buffs_34x31.png"
  end
  local iconImage = display.newSprite(icon):pos(25, bg:getContentSize().height/2):addTo(bg)
  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = title,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x615b44)
    }):addTo(bg):pos(iconImage:getPositionX()+20,iconImage:getPositionY())

  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = value,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(bg):align(display.RIGHT_BOTTOM, bg:getContentSize().width-10, 10)
	return bg
end

function GameUIDragonEquipment:WidgetDragonEquipIntensifyEvent(widgetDragonEquipIntensify)
    local equipment = self:GetEquipment()
    --如果装备星级达到最高星级 无条件回滚
    if equipment.star >= self.dragon.star then return true end
    local exp = 0
    table.foreach(self.allEquipemnts,function(index,v)
        exp = exp + v:GetTotalExp()
    end)
    local oldExp = exp - widgetDragonEquipIntensify:GetExpPerEq()
    local oldPercent = (oldExp + (equipment.exp or 0))/self:GetEquipmentCategory().enhanceExp * 100
    print("exp----->",oldExp,exp,self:GetEquipmentCategory().enhanceExp,oldPercent)
    if oldPercent >= 100 then
      return true
    else
      local percent = (exp + (equipment.exp or 0))/self:GetEquipmentCategory().enhanceExp * 100
      local str = equipment.exp .. "/" .. self:GetEquipmentCategory().enhanceExp
      if exp > 0 then
        str = str .. " +" .. exp
      end
      self.intensify_ui.expLabel:setString(str)
      self.intensify_ui.greenProgress:setPercentage(percent)
    end
end

function GameUIDragonEquipment:IntensifyEvent()

  local equipments = {}
  table.foreach(self.allEquipemnts,function(index,v)
      local name,count = v:GetNameAndCount()
      if count > 0 then
        table.insert(equipments,{name=name,count=count})
      end
  end)

  PushService:enhanceDragonEquipment(self.dragon.type,self.equipmentCategory,equipments,function()
  end)
end


function GameUIDragonEquipment:BuildIntensifyUI()
  self.intensify_ui = {}
  local mainEquipment = self.mainEquipment
  local body = display.newNode():addTo(self):pos((display.width-self.background:getContentSize().width)/2,display.height - self.background:getContentSize().height - 80)
  local progressBg = display.newSprite("balckbar_555x44.png")
    :addTo(body)
    :align(display.LEFT_TOP, mainEquipment:getPositionX(), mainEquipment:getPositionY()-mainEquipment:getContentSize().height-30)
  local greenProgress = UIKit:commonProgressTimer("greenbar_550x38.png")
    :addTo(progressBg)
    :align(display.LEFT_BOTTOM,1,3)
  greenProgress:setPercentage(50)
  local yellowProgress = UIKit:commonProgressTimer("yellowbar_551x38.png")
    :addTo(progressBg)
    :align(display.LEFT_BOTTOM,1,3)
  yellowProgress:setPercentage(30)

  local descLabel =   cc.ui.UILabel.new({
    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    text = "",
    font = UIKit:getFontFilePath(),
    size = 20,
    align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
    color = UIKit:hex2c3b(0xfff3c7)
  }):addTo(yellowProgress)
    :align(display.LEFT_BOTTOM, 5, 5)
  self.intensify_ui.expLabel = descLabel
  self.intensify_ui.yellowProgress = yellowProgress
  self.intensify_ui.greenProgress = greenProgress
  --- listview
  self.intensify_ui.main = body
  self.intensify_ui.listView = UIListView.new {
      viewRect = cc.rect(mainEquipment:getPositionX(), 60, 555, 350),
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
      alignment = cc.ui.UIListView.ALIGNMENT_LEFT,
  }
  :addTo(body)
  self.allEquipemnts = {}
  local equipment = self:GetEquipment()
  local lineCount = self:GetPlayerEquipmentsListData(5)
  for i=1,lineCount do
      local item = self.intensify_ui.listView:newItem()
      local node = display.newNode()
      local lineData = self:GetPlayerEquipmentsListData(5,i)
      for j=1,#lineData do
        local perData = lineData[j]
        local tempNode = WidgetDragonEquipIntensify.new(self,perData[1],0,perData[2],equipment.name)
        :addTo(node)
        local x = tempNode:getCascadeBoundingBox().width/2 + (j-1) * (tempNode:getCascadeBoundingBox().width +6)
        tempNode:pos(x,tempNode:getCascadeBoundingBox().height/2)
        table.insert(self.allEquipemnts,tempNode)
      end
      item:addContent(node)
      item:setItemSize(node:getCascadeBoundingBox().width, node:getCascadeBoundingBox().height+10)
      self.intensify_ui.listView:addItem(item)
  end
  self.intensify_ui.listView:reload()
end

function GameUIDragonEquipment:GetEquipmentCategory()
  local equipment = self:GetEquipment()
  local equipment_category = config_category[self.equipmentCategory][self.dragon.star .. "_" .. self.dragon.equipments[self.equipmentCategory].star]
  return equipment_category
end


function GameUIDragonEquipment:RefreshEquipmentItem()
     self.mainEquipment:removeFromParentAndCleanup(true)
    local mainEquipment = self:GetEquipmentItem()
    :addTo(self.background)
    :align(display.LEFT_TOP,(self.background:getContentSize().width-LISTVIEW_WIDTH)/2,self.titleBar:getPositionY()-self.titleBar:getContentSize().height - 10)
    self.mainEquipment = mainEquipment
end

function GameUIDragonEquipment:RefreshIntensifyUI()
  self:RefreshEquipmentItem()
  local equipment = self:GetEquipment()
  self.adornOrResetButton.labels_['normal']:setString(_("强化"))
  if equipment.star < self.dragon.star then 
    self.adornOrResetButton:setButtonEnabled(true)
    self.intensify_ui.expLabel:setString(equipment.exp .. "/" .. self:GetEquipmentCategory().enhanceExp)
    self.intensify_ui.yellowProgress:setPercentage((equipment.exp or 0)/self:GetEquipmentCategory().enhanceExp * 100)
    self.intensify_ui.greenProgress:setPercentage((equipment.exp or 0)/self:GetEquipmentCategory().enhanceExp * 100)
  else
    self.intensify_ui.yellowProgress:setPercentage(100)
    self.intensify_ui.greenProgress:setPercentage(100)
    self.adornOrResetButton:setButtonEnabled(false)
    self.intensify_ui.expLabel:setString(_("装备已达到最大星级"))

  end
    table.foreach(self.allEquipemnts,function(index,v)
        v:Reset()
    end)
end

function GameUIDragonEquipment:BuildInfoUI()
	self.info_ui = {}
	local background = display.newNode():addTo(self):pos((display.width-self.background:getContentSize().width)/2,display.height - self.background:getContentSize().height - 80)
  local mainEquipment = self.mainEquipment
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
    	})):addTo(background):pos(self.background:getContentSize().width/2, 80)
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

function GameUIDragonEquipment:GetEquipment()
  local config_equipments = self.owner.building:GetEquipmentsByStarAndType(self.dragon.star,self.dragon.type)
  local  equipment = config_equipments[self.equipmentCategory]
  self.isFromConfig = self.dragon.equipments[self.equipmentCategory].name == ""
  if not self.isFromConfig then
      equipment = self.dragon.equipments[self.equipmentCategory]
  end
  return equipment
end

function GameUIDragonEquipment:AdornOrResetButtonClicked()
  if self.infoButton.selected_ then -- 信息界面
    local equipment = self:GetEquipment()
    if self.isFromConfig then --来自配置 装备
  		PushService:setDragonEquipment(self.dragon.type,self.equipmentCategory,equipment.name,function( success)

  		end)
    else -- 重置
      PushService:resetDragonEquipment(self.dragon.type,self.equipmentCategory,function(success)

      end)
    end
  else -- 强化界面
      self:IntensifyEvent()
  end
end

function GameUIDragonEquipment:GetEquipmentItem()
    local equipment = self:GetEquipment()
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

function GameUIDragonEquipment:RefreshInfoUI()
  self:RefreshEquipmentItem()
  local equipment = self:GetEquipment()
    self.mainTitleLabel:setString(self.equipmentCategory)
	if self.isFromConfig then -- 没有装备
    self.adornOrResetButton.labels_['normal']:setString(_("装备"))
    self.intensifyButton:hide()
    if DataManager:getUserData().dragonEquipments[equipment.name] > 0 then
      self.adornOrResetButton:setButtonEnabled(true)
		else
			self.adornOrResetButton:setButtonEnabled(false)
    end
  else -- 已经装备
    self.adornOrResetButton.labels_['normal']:setString(_("重置"))
    self.intensifyButton:show()
    self.adornOrResetButton:setButtonEnabled(true)
  end
	self.titleLable:setString(equipment.name)
	self.countLabel:setString(DataManager:getUserData().dragonEquipments[equipment.name] .. "/" ..  City:GetFirstBuildingByType("materialDepot"):GetMaxMaterial())
  self:RefreshInfoListView()
end

function GameUIDragonEquipment:GetPlayerEquipments()
    local t = {}
    local r = LuaUtils:table_filter(DataManager:getUserData().dragonEquipments,function(equipment,count)
        return count > 0 
    end)
    for k,v in pairs(r) do
      table.insert(t,{k,v})
    end
    return t
end

function GameUIDragonEquipment:GetPlayerEquipmentsListData(perLineCount,page)
  local data = self:GetPlayerEquipments()
  local pageCount =  math.ceil(#data/perLineCount)
  if not page then return pageCount end
  return LuaUtils:table_slice(data,1+(page - 1)*perLineCount,perLineCount*page)
end

-- function GameUIDragonEquipment:SliceTable(t, s,e)
--     local r = {}
--     for i= s,e do
--         if t[i] then
--             table.insert(r,t[i])
--         end
--     end
--     return r
-- end

function GameUIDragonEquipment:GetButton(index)
	local button = display.newSprite(index == 1 and "equipemt_sort_170x73.png" or "equipemt_sort_169x67.png")
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
      button.selected_ = b
    	if b then
    		button:setTexture("equipemt_sort_170x73.png")
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
  self.owner.dragonEquipment = nil
end

function GameUIDragonEquipment:DragonDataChanged()
  self.dragon = self.owner:GetCurrentDragon()
  self.isFromConfig = self.dragon.equipments[self.equipmentCategory].name == ""
  if self.infoButton.selected_ then
    self:RefreshInfoUI()
  else
    self:RefreshIntensifyUI()
  end
end

function GameUIDragonEquipment:GetEquipmentEffect()
  local r = {}
  local equipment = self:GetEquipment()
  local config_equipment_buffs = GameDatas.DragonEyrie.equipmentBuff

  if not equipment.star then return nil end

  local config_category = GameDatas.DragonEyrie[self.equipmentCategory][self.dragon.star .. "_" .. equipment.star]
  table.insert(r,{1,_("活力"),config_category.vitality})
  table.insert(r,{2,_("力量"),config_category.strength})
  for _,v in ipairs(self.dragon.equipments[self.equipmentCategory].buffs) do
    table.insert(r,{3,UIKit:getBuffsDescWithKey(v),string.format("%d%%",config_equipment_buffs[v].buffEffect*100)})
  end
  return r
end

function GameUIDragonEquipment:RefreshInfoListView()
  local data = self:GetEquipmentEffect()
  if not data then return end
  self.info_ui.listView:removeAllItems()
  table.foreach(data,function(index,dataItem)
    local item = self.info_ui.listView:newItem()
    local content = self:GetListItem(index,tonumber(dataItem[1]),dataItem[2],dataItem[3])
    item:addContent(content)
    item:setItemSize(LISTVIEW_WIDTH, 46)
    self.info_ui.listView:addItem(item)
  end)
  self.info_ui.listView:reload()
end

return GameUIDragonEquipment