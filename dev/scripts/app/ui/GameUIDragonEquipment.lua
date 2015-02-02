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
local LISTVIEW_WIDTH = 546
local cocos_promise = import("..utils.cocos_promise")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local DragonManager = import("..entity.DragonManager")
local GameUIDragonEyrieDetail = import(".GameUIDragonEyrieDetail")
local MaterialManager = import("..entity.MaterialManager")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")

function GameUIDragonEquipment:ctor(building,dragon,equipment_obj)
	GameUIDragonEquipment.super.ctor(self)
	self.dragon = dragon
  self.equipment = equipment_obj
  self.building = building
  self.dragon_manager = building:GetDragonManager()
  self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
end

function GameUIDragonEquipment:onMoveOutStage()
    self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
    GameUIDragonEquipment.super.onMoveOutStage(self)
end


function GameUIDragonEquipment:onEnter()
    GameUIDragonEquipment.super.onEnter(self)
    UIKit:shadowLayer():addTo(self,-1)
	  local backgroundImage = WidgetUIBackGround.new({height = BODY_HEIGHT}):addTo(self)
	  self.background = backgroundImage:pos((display.width-backgroundImage:getContentSize().width)/2,display.height - backgroundImage:getContentSize().height - 80)
	  local titleBar = display.newSprite("alliance_blue_title_600x42.png")
		  :align(display.BOTTOM_LEFT, 2,backgroundImage:getContentSize().height - 15)
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
    :align(display.CENTER, 300, 21)
    self.titleBar = titleBar
    UIKit:closeButton()
      :addTo(titleBar)
      :align(display.BOTTOM_RIGHT,titleBar:getContentSize().width, 0)
      :onButtonClicked(function ()
          self:leftButtonClicked()
      end)
  local mainEquipment = self:GetEquipmentItem()
    :addTo(backgroundImage)
    :align(display.LEFT_TOP,(backgroundImage:getContentSize().width-LISTVIEW_WIDTH)/2,self.titleBar:getPositionY() - 10)
    self.mainEquipment = mainEquipment
    local titleLable = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "护甲1",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(backgroundImage):align(display.LEFT_TOP, mainEquipment:getPositionX()+mainEquipment:getContentSize().width*mainEquipment:getScale()+20, mainEquipment:getPositionY()-10)
    self.titleLable = titleLable
    local countLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "数量 1/4",
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(backgroundImage):align(display.LEFT_BOTTOM, mainEquipment:getPositionX()+mainEquipment:getContentSize().width*mainEquipment:getScale()+20, mainEquipment:getPositionY()-mainEquipment:getContentSize().height*mainEquipment:getScale()+10)
    self.countLabel = countLabel
    local resetButton = WidgetPushButton.new(
      {
        normal = "dragon_yellow_button.png",
        pressed = "dragon_yellow_button_h.png",
      }, 
      {scale9 = false},{disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}})
      :setButtonLabel("normal",cc.ui.UILabel.new({
          UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
          text = _("装备"),
          font = UIKit:getFontFilePath(),
          size = 24,
          align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
          color = UIKit:hex2c3b(0xfff3c7)
      }))
      :addTo(backgroundImage)
      :align(display.LEFT_BOTTOM,mainEquipment:getPositionX()+mainEquipment:getContentSize().width*mainEquipment:getScale()+260,mainEquipment:getPositionY()-mainEquipment:getContentSize().height*mainEquipment:getScale())
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
	local bg = display.newSprite(string.format("box_bg_item_520x48_%d.png",index%2))
	local icon = "dragon_vitality_33x42.png"
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
      if percent >= 100 then
          self.intensify_ui.vitality_val_label_add:setString("+" .. equipment:GetNextStarDetailConfig().vitality)
          self.intensify_ui.vitality_val_label_add:show()
          self.intensify_ui.strength_val_label_add:setString("+" .. equipment:GetNextStarDetailConfig().strength)
          self.intensify_ui.strength_val_label_add:show()
          
      else
          self.intensify_ui.vitality_val_label_add:hide()
          self.intensify_ui.strength_val_label_add:hide()
      end
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
  if #equipments == 0 then 
    local dialog = FullScreenPopDialogUI.new()
        dialog:SetTitle(_("提示"))
        dialog:SetPopMessage(_("请选择用来强化的装备!"))
        dialog:AddToCurrentScene()
        return  
  end 
  local equipment = self:GetEquipment()
  NetManager:getEnhanceDragonEquipmentPromise(self.dragon:Type(),equipment:Body(),equipments):next(function(result)
      self:RefreshIntensifyUI()
  end)
end


function GameUIDragonEquipment:BuildIntensifyUI()
  self.intensify_ui = {}
  local mainEquipment = self.mainEquipment
  local body = display.newNode():addTo(self):pos((display.width-self.background:getContentSize().width)/2,display.height - self.background:getContentSize().height - 80)
 
  local vitality_icon = display.newSprite("dragon_vitality_33x42.png")
    :align(display.LEFT_BOTTOM,mainEquipment:getPositionX(),mainEquipment:getPositionY()-mainEquipment:getContentSize().height*mainEquipment:getScale()-60)
    :addTo(body)

  local vitality_title_label = UIKit:ttfLabel({
    text = _("龙的活力"),
    size = 22,
    color = 0x615b44,
    align = cc.TEXT_ALIGNMENT_LEFT
  }):align(display.LEFT_CENTER,vitality_icon:getPositionX()+vitality_icon:getContentSize().width + 5,vitality_icon:getPositionY() + vitality_icon:getContentSize().height/2)
    :addTo(body)
  self.intensify_ui.vitality_val_label = UIKit:ttfLabel({
    text = "120",
    size = 20,
    color = 0x403c2f,
    align = cc.TEXT_ALIGNMENT_RIGHT
  }):addTo(body):align(display.RIGHT_CENTER,540,vitality_title_label:getPositionY())
  self.intensify_ui.vitality_val_label_add = UIKit:ttfLabel({
    text = "+120",
    size = 20,
    color = 0x309700,
    align = cc.TEXT_ALIGNMENT_LEFT
  }):addTo(body):align(display.LEFT_CENTER,self.intensify_ui.vitality_val_label:getPositionX()+2,vitality_title_label:getPositionY())
  local line1 = display.newScale9Sprite("dividing_line_594x2.png")
    :size(554,2)
    :align(display.LEFT_TOP,vitality_icon:getPositionX(),vitality_icon:getPositionY()+5)
    :addTo(body)
  local strength_icon = display.newSprite("dragon_strength_27x31.png")
    :align(display.LEFT_TOP,vitality_icon:getPositionX(),line1:getPositionY()-8)
    :addTo(body)

  local strength_title_label = UIKit:ttfLabel({
    text = _("龙的力量"),
    size = 22,
    color = 0x615b44,
    align = cc.TEXT_ALIGNMENT_LEFT
  }):align(display.LEFT_CENTER,vitality_title_label:getPositionX(),strength_icon:getPositionY() - strength_icon:getContentSize().height/2)
    :addTo(body)

  self.intensify_ui.strength_val_label = UIKit:ttfLabel({
    text = "120",
    size = 20,
    color = 0x403c2f,
    align = cc.TEXT_ALIGNMENT_RIGHT
  }):addTo(body):align(display.RIGHT_CENTER,540,strength_title_label:getPositionY())

  self.intensify_ui.strength_val_label_add = UIKit:ttfLabel({
    text = "+120",
    size = 20,
    color = 0x309700,
    align = cc.TEXT_ALIGNMENT_LEFT
  }):addTo(body):align(display.LEFT_CENTER,self.intensify_ui.strength_val_label:getPositionX()+2,strength_title_label:getPositionY())
  local line2 = display.newScale9Sprite("dividing_line_594x2.png")
    :size(554,2)
    :align(display.LEFT_TOP,strength_icon:getPositionX(),strength_icon:getPositionY()-strength_icon:getContentSize().height)
    :addTo(body)
  local progressBg = display.newSprite("balckbar_555x44.png")
    :addTo(body)
    :align(display.LEFT_TOP, mainEquipment:getPositionX(), line2:getPositionY()-10)
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
      viewRect = cc.rect(mainEquipment:getPositionX(), 60, 555, 300),
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
        local tempNode = WidgetDragonEquipIntensify.new(self,perData[1],0,perData[2],equipment:Name())
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
  return equipment:GetDetailConfig()
end


function GameUIDragonEquipment:RefreshEquipmentItem()
    self.mainEquipment:removeFromParent()
    local mainEquipment = self:GetEquipmentItem()
    :addTo(self.background)
    :align(display.LEFT_TOP,(self.background:getContentSize().width-LISTVIEW_WIDTH)/2,self.titleBar:getPositionY() - 10)
    self.mainEquipment = mainEquipment
end

function GameUIDragonEquipment:RefreshIntensifyUI()
  self:RefreshEquipmentItem()
  local equipment = self:GetEquipment()
  self.adornOrResetButton.labels_['normal']:setString(_("强化"))
  if equipment:Star() < self.dragon:Star() then 
    self.adornOrResetButton:setButtonEnabled(true)
    self.intensify_ui.expLabel:setString(equipment.exp .. "/" .. self:GetEquipmentCategory().enhanceExp)
    self.intensify_ui.yellowProgress:setPercentage((equipment:Exp() or 0)/self:GetEquipmentCategory().enhanceExp * 100)
    self.intensify_ui.greenProgress:setPercentage((equipment:Exp() or 0)/self:GetEquipmentCategory().enhanceExp * 100)
  else
    self.intensify_ui.yellowProgress:setPercentage(100)
    self.intensify_ui.greenProgress:setPercentage(100)
    self.adornOrResetButton:setButtonEnabled(false)
    self.intensify_ui.expLabel:setString(_("装备已达到最大星级"))
  end
  local vitality,strength = equipment:GetVitalityAndStrengh()
  self.intensify_ui.vitality_val_label:setString(vitality)
  self.intensify_ui.strength_val_label:setString(strength)
  self.intensify_ui.vitality_val_label_add:hide()
  self.intensify_ui.strength_val_label_add:hide()
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
  }):addTo(background):align(display.LEFT_TOP, mainEquipment:getPositionX(), mainEquipment:getPositionY()-mainEquipment:getContentSize().height*mainEquipment:getScale()-30)
 	self.info_ui.descLabel = descLabel
  local list_bg = display.newScale9Sprite("box_bg_546x214.png")
    :size(LISTVIEW_WIDTH, 250)
    :align(display.LEFT_BOTTOM, (self.background:getContentSize().width-LISTVIEW_WIDTH)/2, 180)
    :addTo(background)
  self.info_ui.listView = UIListView.new({
      viewRect = cc.rect(0, 10, LISTVIEW_WIDTH, 230),
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
  }):addTo(list_bg,2)

 	local makeButton  = WidgetPushButton.new(
      {
   	    normal = "dragon_yellow_button.png",
   	    pressed = "dragon_yellow_button_h.png"
      },
      {scale9 = false},{disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}})
   		:setButtonLabel("normal",cc.ui.UILabel.new({
	        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	        text = _("制作"),
	        font = UIKit:getFontFilePath(),
	        size = 24,
	        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
	        color = UIKit:hex2c3b(0xffedae)
    	})):addTo(background):pos(self.background:getContentSize().width/2, 80)
      :onButtonClicked(function(event)
          self:OnMakeButtonClicked()
      end)
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

function GameUIDragonEquipment:OnMakeButtonClicked()
    local blackSmith = City:GetFirstBuildingByType("blackSmith")
    if blackSmith:IsUnlocked() then
         UIKit:newGameUI('GameUIBlackSmith', City, blackSmith):addToCurrentScene(true)
    end
end

function GameUIDragonEquipment:GetEquipment()
  return self.equipment
end


function GameUIDragonEquipment:AdornOrResetButtonClicked()
  if self.infoButton.selected_ then -- 信息界面
    local equipment = self:GetEquipment()
    if not equipment:IsLoaded() then --来自配置 装备
      NetManager:getLoadDragonEquipmentPromise(equipment:Type(),equipment:Body(),equipment:GetCanLoadConfig().name):next(function()
          self:RefreshInfoUI()
      end)
    else -- 重置
      NetManager:getResetDragonEquipmentPromise(equipment:Type(),equipment:Body()):next(function()
         self:RefreshInfoUI()
      end)
    end
  else -- 强化界面
      self:IntensifyEvent()
  end
end

function GameUIDragonEquipment:GetCurrentEquipmentCount()
    local player_equipments = City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.EQUIPMENT)
    local equipment = self:GetEquipment()
    local eq_name = equipment:IsLoaded() and equipment:Name() or equipment:GetCanLoadConfig().name
    return player_equipments[eq_name] or 0
end

-- 调用龙巢详情界面的函数获取道具图标
function GameUIDragonEquipment:GetEquipmentItem()
    -- dump(self:GetEquipment())
    return GameUIDragonEyrieDetail:GetEquipmentItem(self:GetEquipment())
end

function GameUIDragonEquipment:RefreshInfoUI()
    self:RefreshEquipmentItem()
    local equipment = self:GetEquipment()
    self.mainTitleLabel:setString(Localize.body[equipment:Body()])
  	if not equipment:IsLoaded() then -- 没有装备
      dump(equipment:GetCanLoadConfig().name)
        self.adornOrResetButton.labels_['normal']:setString(_("装备"))
        self.intensifyButton:hide()
	      self.titleLable:setString(Localize.equip[equipment:GetCanLoadConfig().name])
        -- self.countLabel:setString(_("数量") .. " " .. (DataManager:getUserData().dragonEquipments[equipment:Name()] or 0) .. "/" ..  City:GetFirstBuildingByType("materialDepot"):GetMaxMaterial())
        -- if DataManager:getUserData().dragonEquipments[equipment:GetCanLoadConfig().name] > 0 then
        --   self.adornOrResetButton:setButtonEnabled(true)
        -- else
        --  self.adornOrResetButton:setButtonEnabled(false)
        -- end
    else -- 已经装备
      self.titleLable:setString(Localize.equip[equipment:Name()])
      -- self.countLabel:setString(_("数量") .. " " .. (DataManager:getUserData().dragonEquipments[equipment:Name()] or 0) .. "/" ..  City:GetFirstBuildingByType("materialDepot"):GetMaxMaterial())
      self.adornOrResetButton.labels_['normal']:setString(_("重置"))
      self.intensifyButton:show()
       -- if DataManager:getUserData().dragonEquipments[equipment:GetCanLoadConfig().name] > 0 then
       --    self.adornOrResetButton:setButtonEnabled(true)
       --  else
       --   self.adornOrResetButton:setButtonEnabled(false)
       --  end
    end
    self.countLabel:setString(_("数量") .. " " .. self:GetCurrentEquipmentCount() .. "/" ..  City:GetFirstBuildingByType("materialDepot"):GetMaxMaterial())
    if self:GetCurrentEquipmentCount() > 0 then
      self.adornOrResetButton:setButtonEnabled(true)
    else
     self.adornOrResetButton:setButtonEnabled(false)
    end
    self:RefreshInfoListView()
    local blackSmith = City:GetFirstBuildingByType("blackSmith")
    self.info_ui.makeButton:setButtonEnabled(blackSmith:IsUnlocked())
end

function GameUIDragonEquipment:GetPlayerEquipments()
    local t = {}
    local player_equipments = City:GetMaterialManager():GetMaterialsByType(MaterialManager.MATERIAL_TYPE.EQUIPMENT)
    local r = LuaUtils:table_filter(player_equipments,function(equipment,count)
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

function GameUIDragonEquipment:OnBasicChanged()
  self.equipment = self.dragon_manager:GetDragon(self.equipment:Type()):GetEquipmentByBody(self.equipment:Body())
  if self.infoButton.selected_ then
    self:RefreshInfoUI()
  else
    self:RefreshIntensifyUI()
  end
end

function GameUIDragonEquipment:GetEquipmentEffect()
  local r = {}
  local equipment = self:GetEquipment()
  local vitality,strength = equipment:GetVitalityAndStrengh()
  table.insert(r,{1,_("活力"),vitality})
  table.insert(r,{2,_("力量"),strength})
  local buffers = equipment:GetBufferAndEffect()
  for __,v in ipairs(buffers) do
      table.insert(r,{3,Localize.dragon_buff_effection[v[1]],string.format("%d%%",v[2]*100)})
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

function GameUIDragonEquipment:Find()
    return cocos_promise.defer(function()
        return self.adornOrResetButton
    end)
end

return GameUIDragonEquipment