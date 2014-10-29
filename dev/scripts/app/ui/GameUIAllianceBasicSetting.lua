--
-- Author: Danny He
-- Date: 2014-10-13 10:35:06
--
local window = import('..utils.window')
local contentWidth = window.width - 80
local UIListView = import(".UIListView")
local UIScrollView = import(".UIScrollView")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSequenceButton = import("..widget.WidgetSequenceButton")
local WidgetAllianceLanguagePanel = import("..widget.WidgetAllianceLanguagePanel")
local GameUIAllianceBasicSetting = UIKit:createUIClass('GameUIAllianceBasicSetting')
local modify_height = window.height - 60
local Alliance_Manager = Alliance_Manager
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Flag = import("..entity.Flag")
function GameUIAllianceBasicSetting:ctor(isModify)
	GameUIAllianceBasicSetting.super.ctor(self)
	self.alliance_ui_helper = WidgetAllianceUIHelper.new()
	self.isCreateAction_ = isModify ~= true 
	if self.isCreateAction_ then
		self.flag_info = Flag.new():RandomFlag()
		self.terrain_info = self.alliance_ui_helper:SetTerrain(Alliance_Manager:GetMyAlliance():TerrainType()):RandomTerrain()
		dump(self.flag_info)
		dump(self.terrain_info)
	else
		self.flag_info  = Alliance_Manager:GetMyAlliance():Flag()
		self.terrain_info = Alliance_Manager:GetMyAlliance():TerrainType()
		dump(self.terrain_info)
	end
end

function GameUIAllianceBasicSetting:onMoveInStage()
	assert(not self.isCreateAction_)
	GameUIAllianceBasicSetting.super.onMoveInStage(self)
	self:BuildModifyUI()
end

function GameUIAllianceBasicSetting:BuildModifyUI()
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local bg = WidgetUIBackGround.new({height=modify_height}):addTo(shadowLayer):pos(window.left+10,window.bottom)
	local titleBar = display.newSprite("alliance_blue_title_600x42.png"):align(display.LEFT_BOTTOM,3,modify_height-15):addTo(bg)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(titleBar,2)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+20,0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	UIKit:ttfLabel({
		text = _("联盟设置"),
		size = 22,
		shadow = true,
		color = 0xffedae
	}):addTo(titleBar):align(display.CENTER,300,titleBar:getContentSize().height/2)

	local scrollView = UIScrollView.new({viewRect = cc.rect(0,10,bg:getContentSize().width,titleBar:getPositionY() - 10)})
        :addScrollNode(self:GetContentNode():pos(35,0))
        :setDirection(UIScrollView.DIRECTION_VERTICAL)
        :addTo(bg)
	scrollView:fixResetPostion(-50)
	self.createScrollView = scrollView
end

-- content node
function GameUIAllianceBasicSetting:GetContentNode()
	local createContent = cc.Node:create()
	local buttonText = self.isCreateAction_ and _("创建") or _("修改")
	--button
	local okButton = cc.ui.UIPushButton.new({normal = "green_btn_up_142x39.png",pressed = "green_btn_down_142x39.png"}, {scale9 = true})
    	:addTo(createContent)
    	:align(display.BOTTOM_RIGHT, contentWidth - 10, 10)
    	:setButtonLabel("normal",  cc.ui.UILabel.new({
	    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	    	text = buttonText,
	        font = UIKit:getFontFilePath(),
	        size = 22,
	        color = UIKit:hex2c3b(0xffedae),
   	 	}))
	    :onButtonClicked(function(event)
	    	self:CreateAllianceButtonClicked()
    	end)
	local gemIcon = display.newSprite("gem_66x56.png")
		:addTo(createContent)
		:align(display.LEFT_BOTTOM,okButton:getPositionX() - 220, 20)
		:scale(0.4)
	local gemLabel = UIKit:ttfLabel({
		text = "600",
		size = 16,
		color = 0x797154
		}):addTo(createContent)
		:align(display.LEFT_BOTTOM, gemIcon:getPositionX()+gemIcon:getContentSize().width*0.4 + 4,gemIcon:getPositionY())
	-- flags
    self.createFlagPanel = self:createFlagPanel_():addTo(createContent)
    	:pos(0,okButton:getPositionY()+45)
    -- landform & language
    self.landformPanel = self:createCheckAllianeGroup_():addTo(createContent)
    	:pos(-10,self.createFlagPanel:getCascadeBoundingBox().height+120)
    -- textfield
    self.textfieldPanel = self:createTextfieldPanel_():addTo(createContent)
    	:pos(-10,self.landformPanel:getPositionY()+self.landformPanel:getCascadeBoundingBox().height+360)
    return createContent
end

-- TabButtons event
-- 1.create
-- 1.1 flag
function GameUIAllianceBasicSetting:createFlagPanel_()
	local node = display.newNode()
	-- graphic
	local bottom = display.newSprite("alliance_flag_bg_bottom_386x18.png")
		:align(display.RIGHT_BOTTOM, contentWidth - 10,0):addTo(node)
	local header = display.newSprite("alliance_flag_bg_header_386x38.png")
	local middle = display.newScale9Sprite("alliance_flag_bg_middle_386x1.png")
		:size(386,210 - 36*2)
		:addTo(node)
		:align(display.RIGHT_BOTTOM,bottom:getPositionX(),bottom:getPositionY()+bottom:getContentSize().height)
	header:addTo(node)
		:align(display.RIGHT_BOTTOM, middle:getPositionX(), middle:getPositionY()+middle:getContentSize().height)
	UIKit:ttfLabel({
		text = _("图案"),
		size = 20,
		color = 0xffedae
	}):addTo(header):align(display.CENTER,header:getContentSize().width/2,header:getContentSize().height/2+2)
	local colorButton_right = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"},
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.alliance_ui_helper:GetFlagColors(),
		self:GetFlagInfomation():GetFrontImageColors()[2]
	):addTo(node)
		:pos(bottom:getPositionX()-60,bottom:getPositionY()+45)
		:setButtonEnabled(self:GetFlagInfomation():GetFrontStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
		:onSeqStateChange(handler(self, self.OnGraphicTypeButtonClicked))
	self.colorButton_right = colorButton_right
	local colorButton_left = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.alliance_ui_helper:GetFlagColors(),
		self:GetFlagInfomation():GetFrontImageColors()[1]
	):addTo(node):pos(colorButton_right:getPositionX()-135,colorButton_right:getPositionY())
	:onSeqStateChange(handler(self, self.OnGraphicTypeButtonClicked))
	self.colorButton_left = colorButton_left
	local graphic_right_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false,scale = 0.55},
		self.alliance_ui_helper:GetGraphics(),
		nil,
		self:GetFlagInfomation():GetFrontImagesStyle()[2]
		)
		:addTo(node)
		:pos(colorButton_right:getPositionX(),colorButton_right:getPositionY()+80)
		:setButtonEnabled(self:GetFlagInfomation():GetFrontStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
		:onSeqStateChange(handler(self, self.OnGraphicTypeButtonClicked))
		self.graphic_right_button = graphic_right_button
	local graphic_middle_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false,scale = 0.55},
		self.alliance_ui_helper:GetGraphics(),
		nil,
		self:GetFlagInfomation():GetFrontImagesStyle()[1]
		):addTo(node)
			:pos(colorButton_left:getPositionX(),colorButton_right:getPositionY()+80)
			:onSeqStateChange(handler(self, self.OnGraphicTypeButtonClicked))
		self.graphic_middle_button = graphic_middle_button
	local graphic_type_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		self.alliance_ui_helper:GetFrontStyles(),
		nil,
		self:GetFlagInfomation():GetFrontStyle()
		):addTo(node)
		:pos(colorButton_left:getPositionX() - 135,colorButton_right:getPositionY()+80)
		:onSeqStateChange(handler(self, self.OnGraphicTypeButtonClicked))
	self.graphic_type_button =  graphic_type_button

	-- color body
	--118
	local color_bottom = display.newSprite("alliance_flag_bg_bottom_386x18.png")
		:align(display.RIGHT_BOTTOM, contentWidth - 10,header:getPositionY()+header:getContentSize().height+20)
		:addTo(node)
	local color_header = display.newSprite("alliance_flag_bg_header_386x38.png")
	local color_middle = display.newScale9Sprite("alliance_flag_bg_middle_386x1.png")
		:size(386,130 - 36*2)
		:addTo(node)
		:align(display.RIGHT_BOTTOM,color_bottom:getPositionX(),color_bottom:getPositionY()+color_bottom:getContentSize().height)
	color_header:addTo(node)
		:align(display.RIGHT_BOTTOM, color_middle:getPositionX(), color_middle:getPositionY()+color_middle:getContentSize().height)
	UIKit:ttfLabel({
		text = _("颜色"),
		size = 20,
		color = 0xffedae
	}):addTo(color_header):pos(color_header:getContentSize().width/2 - 10,color_header:getContentSize().height/2+2)

	local color_rightColor_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.alliance_ui_helper:GetFlagColors(),
		self:GetFlagInfomation():GetBackColors()[2]
	):addTo(node):pos(color_bottom:getPositionX()-60,color_bottom:getPositionY()+45)
		:setButtonEnabled(self:GetFlagInfomation():GetBackStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
		:onSeqStateChange(handler(self, self.OnFlagTypeButtonClicked))
	self.color_rightColor_button = color_rightColor_button
	local color_middleColor_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.alliance_ui_helper:GetFlagColors(),
		self:GetFlagInfomation():GetBackColors()[1]
		)
		:addTo(node):pos(color_rightColor_button:getPositionX()-135,color_rightColor_button:getPositionY())
		:onSeqStateChange(handler(self, self.OnFlagTypeButtonClicked))
	self.color_middleColor_button = color_middleColor_button
	local flag_type_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		self.alliance_ui_helper:GetBackStyles(),
		nil,
		self:GetFlagInfomation():GetBackStyle()
	):addTo(node)
	:pos(color_middleColor_button:getPositionX() - 135,color_rightColor_button:getPositionY())
	:onSeqStateChange(handler(self, self.OnFlagTypeButtonClicked))
	self.flag_type_button = flag_type_button

	local flagNode,terrain_node,flag_sprite = self.alliance_ui_helper:CreateFlagWithRectangleTerrain(self.terrain_info,self:GetFlagInfomation())
	flagNode:addTo(node):pos(contentWidth - header:getContentSize().width - flagNode:getCascadeBoundingBox().width + 60,header:getPositionY()+50)
	self.terrain_node = terrain_node
	self.flag_sprite = flag_sprite


	UIKit:ttfLabel({
		text = _("联盟旗帜"),
		size = 22,
		color = 0x403c2f
	}):addTo(node):pos(color_header:getPositionX()-320+10,color_header:getPositionY()+color_header:getContentSize().height+15)
	local random_bg = display.newSprite("alliance_flag_random_bg_182x58.png")
		:align(display.RIGHT_BOTTOM, bottom:getPositionX() - bottom:getContentSize().width - 15, bottom:getPositionY()+10)
		:addTo(node)
		:scale(0.9)
	local randomButton = WidgetPushButton.new({normal = "alliance_sieve_51x45.png"})
		:addTo(random_bg)
		:pos(random_bg:getContentSize().width/2,random_bg:getContentSize().height/2)
		:onButtonClicked(function()
			-- self:RandomFlag()
			self.flag_info = self:GetFlagInfomation():RandomFlag()
			self:RefreshButtonState()
			self:RefrshFlagSprite()
		end)
	return node
end

function GameUIAllianceBasicSetting:createCheckAllianeGroup_()
	local groupNode = display.newNode()
	if self.isCreateAction_ then
		local tipsLabel = UIKit:ttfLabel({
				text = _("草地——产出强化绿龙的材料，更容易培养绿龙，更容易培养绿龙，草地产出绿宝石，建造资源加成类的铺筑建筑"),
				size = 18,
				color = 0x797154,
				dimensions = cc.size(552, 0),
		}):addTo(groupNode):align(display.LEFT_BOTTOM, 0, 0)
		local landSelect = self.CreateBoxPanel(60):addTo(groupNode):pos(0,tipsLabel:getContentSize().height+10)
		local checkbox_image = {
	        off = "checkbox_unselected.png",
	        off_pressed = "checkbox_unselected.png",
	        off_disabled = "checkbox_unselected.png",
	        on = "checkbox_selectd.png",
	        on_pressed = "checkbox_selectd.png",
	        on_disabled = "checkbox_selectd.png",

	    }
		self.landTypeButton = cc.ui.UICheckBoxButtonGroup.new()
	        :addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
	            :setButtonLabel(UIKit:ttfLabel({text = _("草地"),size = 20,color = 0x797154}))
	            :setButtonLabelOffset(40, 0)
	            :align(display.LEFT_CENTER))
	        :addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
	            :setButtonLabel(UIKit:ttfLabel({text = _("沙漠"),size = 20,color = 0x797154}))
	            :setButtonLabelOffset(40, 0)
	            :align(display.LEFT_CENTER))
	        :addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
	            :setButtonLabel(UIKit:ttfLabel({text = _("雪地"),size = 20,color = 0x797154}))
	            :setButtonLabelOffset(40, 0)
	            :align(display.LEFT_CENTER))
	        :setButtonsLayoutMargin(10, 130, 0,10)
	        :onButtonSelectChanged(function(event)
	            self.terrain_info = event.selected
	            self:RefrshFlagSprite(3)
	        end)
	        :addTo(landSelect)
	    local landLabel = UIKit:ttfLabel({
			text = _("联盟地形"),
			size = 22,
			color = 0x403c2f
		}):addTo(groupNode):align(display.CENTER,window.cx-30, landSelect:getPositionY()+landSelect:getCascadeBoundingBox().height+20)

	    self.languageSelected  = WidgetAllianceLanguagePanel.new(260):addTo(groupNode):pos(0,landLabel:getPositionY()+20)
    	self:SelectLandCheckButton(self.terrain_info,true)
	else
   		self.languageSelected  = WidgetAllianceLanguagePanel.new(260):addTo(groupNode):pos(0,0)
   	end
    return groupNode
end

function GameUIAllianceBasicSetting:SelectLandCheckButton( type,selected)
	print("GameUIAlliance:SelectLandCheckButton---->",type,selected)
	self.landTypeButton:getButtonAtIndex(type):setButtonSelected(selected)
end

function GameUIAllianceBasicSetting:createTextfieldPanel_()
	local node = display.newNode()
	local limitLabel = UIKit:ttfLabel({
		text = _("只允许字母、数字和空格，需要3~20个字符"),
		size = 18,
		color = 0x797154
	}):addTo(node):align(display.LEFT_BOTTOM, 0, 0)

	local editbox_tag = cc.ui.UIInput.new({
    	UIInputType = 1,
        image = "alliance_editbox_575x48.png",
        size = cc.size(552,48),
    })
    editbox_tag:setPlaceHolder(_("最多可输入600字符"))
    editbox_tag:setMaxLength(600)
    editbox_tag:setFont(UIKit:getFontFilePath(),18)
    editbox_tag:setFontColor(cc.c3b(0,0,0))
    editbox_tag:setPlaceholderFontColor(UIKit:hex2c3b(0xccc49e))
    editbox_tag:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editbox_tag:align(display.LEFT_BOTTOM,0,limitLabel:getContentSize().height+10):addTo(node)
    self.editbox_tag = editbox_tag
    if not self.isCreateAction_ then
    	editbox_tag:setText(Alliance_Manager:GetMyAlliance():AliasName())
    end
    local tagLabel = UIKit:ttfLabel({
		text = _("联盟标签"),
		size = 22,
		color = 0x403c2f
	}):addTo(node):align(display.CENTER, 552/2, editbox_tag:getPositionY()+editbox_tag:getContentSize().height+20)

	local nameTipLabel = UIKit:ttfLabel({
		text = _("只允许字母、数字和空格，需要3~20个字符"),
		size = 18,
		color = 0x797154
	}):addTo(node):align(display.LEFT_BOTTOM, 0, tagLabel:getPositionY()+40)

	local editbox_name = cc.ui.UIInput.new({
    	UIInputType = 1,
        image = "alliance_editbox_575x48.png",
        size = cc.size(510,48),
    })
    editbox_name:setPlaceHolder(_("最多可输入600字符"))
    editbox_name:setMaxLength(600)
    editbox_name:setFont(UIKit:getFontFilePath(),18)
    editbox_name:setFontColor(cc.c3b(0,0,0))
    editbox_name:setPlaceholderFontColor(UIKit:hex2c3b(0xccc49e))
    editbox_name:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editbox_name:align(display.LEFT_BOTTOM,0,nameTipLabel:getPositionY()+nameTipLabel:getContentSize().height+10):addTo(node)
     if not self.isCreateAction_ then
    	editbox_name:setText(Alliance_Manager:GetMyAlliance():Name())
    end
    self.editbox_name = editbox_name

    local randomButton = WidgetPushButton.new({normal = "alliance_sieve_51x45.png"})
		:addTo(node)
		:align(display.LEFT_BOTTOM, editbox_name:getContentSize().width+editbox_name:getPositionX()+2, editbox_name:getPositionY())
		:onButtonClicked(function()
			self:RandomAllianceName_()
		end):zorder(editbox_name:getLocalZOrder()+10)
	randomButton:setTouchSwallowEnabled(false)

     local nameLabel = UIKit:ttfLabel({
		text = _("联盟名称"),
		size = 22,
		color = 0x403c2f
	}):addTo(node):align(display.CENTER, 552/2, editbox_name:getPositionY()+editbox_name:getContentSize().height+20)
	return node
end


function GameUIAllianceBasicSetting:RandomAllianceName_()
	local name,tag = self.alliance_ui_helper:RandomAlliacneNameAndTag()
	self.editbox_name:setText(name)
	self.editbox_tag:setText(tag)
end

-- where : 1->body 2->graphic other->all
function GameUIAllianceBasicSetting:RefrshFlagSprite(where)
	local box_bounding = self.flag_sprite:getChildByTag(self.alliance_ui_helper.FLAG_BOX_TAG)
	if 1 == where then --body
		local body_node = self.flag_sprite:getChildByTag(self.alliance_ui_helper.FLAG_BODY_TAG)
		body_node:removeFromParent(true)
		body_node = self.alliance_ui_helper:CreateFlagBody(self:GetFlagInfomation(),box_bounding:getContentSize())
		body_node:addTo(self.flag_sprite,self.alliance_ui_helper.FLAG_BODY_ZORDER,self.alliance_ui_helper.FLAG_BODY_TAG)
	elseif 2 == where then --graphic
		local graphic_node = self.flag_sprite:getChildByTag(self.alliance_ui_helper.FLAG_GRAPHIC_TAG)
		graphic_node:removeFromParent(true)
		graphic_node = self.alliance_ui_helper:CreateFlagGraphic(self:GetFlagInfomation(),box_bounding:getContentSize())
		graphic_node:addTo(self.flag_sprite,self.alliance_ui_helper.FLAG_GRAPHIC_ZORDER,self.alliance_ui_helper.FLAG_GRAPHIC_TAG)
	elseif 3 == where then
		self.terrain_node:setTexture(self.alliance_ui_helper:GetAllRectangleTerrains()[self.terrain_info])
	else --all
		self:RefrshFlagSprite(1)
		self:RefrshFlagSprite(2)
	end
end

function GameUIAllianceBasicSetting:GetFlagInfomation()
	return self.flag_info
end

function GameUIAllianceBasicSetting:RefreshButtonState()
	local flag = self:GetFlagInfomation()
	self.flag_type_button:setSeqState(flag:GetBackStyle())
	self.color_middleColor_button:setSeqState(flag:GetBackColors()[1])
	self.color_rightColor_button:setSeqState(flag:GetBackColors()[2])
	self.color_rightColor_button:setButtonEnabled(flag:GetBackStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)

	self.graphic_type_button:setSeqState(flag:GetFrontStyle())
	self.colorButton_right:setSeqState(flag:GetFrontImageColors()[2])
	self.colorButton_left:setSeqState(flag:GetFrontImageColors()[1])
	
	self.graphic_middle_button:setSeqState(flag:GetFrontImagesStyle()[1])
	self.graphic_right_button:setSeqState(flag:GetFrontImagesStyle()[2])
	self.colorButton_right:setButtonEnabled(flag:GetFrontStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
	self.graphic_right_button:setButtonEnabled(flag:GetFrontStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
end

function GameUIAllianceBasicSetting:AdapterCreateData2Server_()
	return {
		name=string.trim(self.editbox_name:getText()),
		tag=string.trim(self.editbox_tag:getText()),
		language=self.languageSelected:getSelectedLanguage(),
		terrain=self.alliance_ui_helper:GetLandFormTypeName(self.terrain_info),
		flag=self:GetFlagInfomation():EncodeToJson()
	}
end

function GameUIAllianceBasicSetting:CreateAllianceButtonClicked()
	local data = self:AdapterCreateData2Server_()
	dump(data)
	--TODO: check data
	if self.isCreateAction_ then
		PushService:createAlliance(data,function(success)end)
	else
		PushService:editAllianceBasicInfo(data,function(success)
			self:leftButtonClicked()
		end)
	end
end

-- flag button event

function GameUIAllianceBasicSetting:OnFlagTypeButtonClicked()
	local flag = self:GetFlagInfomation()
	flag:SetBackStyle(self.flag_type_button:GetSeqState())
	flag:SetBackColors(self.color_middleColor_button:GetSeqState(),self.color_rightColor_button:GetSeqState())
	self.color_rightColor_button:setButtonEnabled(self:GetFlagInfomation():GetBackStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
	self:RefrshFlagSprite(1)
end

function GameUIAllianceBasicSetting:OnGraphicTypeButtonClicked()
	local flag = self:GetFlagInfomation()
	flag:SetFrontStyle(self.graphic_type_button:GetSeqState())
	flag:SetFrontImageColors(self.colorButton_left:GetSeqState(),self.colorButton_right:GetSeqState())
	flag:SetFrontImagesStyle(self.graphic_middle_button:GetSeqState(),self.graphic_right_button:GetSeqState())
	self.colorButton_right:setButtonEnabled(self:GetFlagInfomation():GetFrontStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
	self.graphic_right_button:setButtonEnabled(self:GetFlagInfomation():GetFrontStyle() ~= self.alliance_ui_helper.FLAG_LOCATION_TYPE.ONE)
	self:RefrshFlagSprite(2)
end

-- no instance
-----------------------------------------------------------------------
function GameUIAllianceBasicSetting.CreateBoxPanel(height)
	local node = display.newNode()
	local bottom = display.newSprite("alliance_box_bottom_552x12.png")
		:addTo(node)
		:align(display.LEFT_BOTTOM,0,0)
	local top =  display.newSprite("alliance_box_top_552x12.png")
	local middleHeight = height - bottom:getContentSize().height - top:getContentSize().height
	local next_y = bottom:getContentSize().height
	while middleHeight > 0 do
		local middle = display.newSprite("alliance_box_middle_552x1.png")
			:addTo(node)
			:align(display.LEFT_BOTTOM,0, next_y)
		middleHeight = middleHeight - middle:getContentSize().height
		next_y = next_y + middle:getContentSize().height
	end
	top:addTo(node)
		:align(display.LEFT_BOTTOM,0,next_y)
	return node
end

return GameUIAllianceBasicSetting