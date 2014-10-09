--
-- Author: Danny He
-- Date: 2014-10-06 18:18:26
--
local Enum = import("..utils.Enum")
local window = import('..utils.window')
local UIScrollView = import(".UIScrollView")
local WidgetSequenceButton = import("..widget.WidgetSequenceButton")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetBackGroundTabButtons = import("..widget.WidgetBackGroundTabButtons")
local GameUIAlliance = UIKit:createUIClass("GameUIAlliance","GameUIWithCommonHeader")
local IsoMapAnchorBottomLeft = import("..map.IsoMapAnchorBottomLeft")
local contentWidth = window.width - 80
GameUIAlliance.FLAG_BODY_TAG = 1
GameUIAlliance.FLAG_BODY_ZORDER = 1
GameUIAlliance.FLAG_GRAPHIC_TAG = 2
GameUIAlliance.FLAG_GRAPHIC_ZORDER = 2
GameUIAlliance.FLAG_BOX_TAG  = 3
GameUIAlliance.FLAG_BOX_ZORDER = 3


GameUIAlliance.flagData_ = {
	color = {}, -- 颜色
	graphic = {}, -- 图案
	body = {}, -- 背景
	bodyButton = {}, -- 背景类型按钮
	graphicButton = {}, -- 图案类型按钮
}

--flag data
local color_from_excel =  
{
	red = 0x8b0000,
	yellow = 0xd8bc00,
	green = 0x0d8b00,
	babyBlue = 0x008b89,
	darkBlue = 0x000d8b,
	purple = 0x8b0080,
	orange = 0xd58200,
	white = 0xffffff,
	black = 0x000000,
	charmRed = 0xc10084,
	blue = 0x005ea7,
	orangeRed = 0xa74b00,
}


table.foreach(color_from_excel,function(k,v)
	table.insert(GameUIAlliance.flagData_.color,{name = k,color=UIKit:convertColorToGL_(v)})
end)

local FLAG_LOCATION_TYPES = {
	"ONE",
    "TWO_LEFT_RIGHT",
    "TWO_TOP_BOTTOM",
    "TWO_X"
}

GameUIAlliance.FLAG_LOCATION_TYPE = {
	ONE = 1,
	TWO_LEFT_RIGHT = 2,
	TWO_TOP_BOTTOM = 3,
	TWO_X = 4
}

-- graphicButton & bodyButton
for i=1,4 do
	local graphicButtonImageName = string.format("alliance_flag_graphic_%d",i)
	GameUIAlliance.flagData_.graphicButton[i] = {name = i,image = graphicButtonImageName .. ".png"}
	local bodyButtonImageName = string.format("alliance_flag_type_45x45_%d",i)
	GameUIAlliance.flagData_.bodyButton[i] = {name = i,image = bodyButtonImageName .. ".png"}
end


--body image
GameUIAlliance.flagData_.body["1"] = "alliance_flag_body_1.png"
GameUIAlliance.flagData_.body["2_1"] = "alliance_flag_body_2_1.png"
GameUIAlliance.flagData_.body["2_2"] = "alliance_flag_body_2_2.png"
GameUIAlliance.flagData_.body["3_1"] = "alliance_flag_body_3_1.png"
GameUIAlliance.flagData_.body["3_2"] = "alliance_flag_body_3_2.png"
GameUIAlliance.flagData_.body["4_1"] = "alliance_flag_body_4.png"
GameUIAlliance.flagData_.body["4_2"] = "alliance_flag_body_4.png"

--graphic

for i=1,17 do
	local imageName = string.format("alliance_graphic_%d",i)
	table.insert(GameUIAlliance.flagData_.graphic,{name = i,image = imageName .. ".png"})
end

--------------------------------------------------------------------------------
function GameUIAlliance:ctor()
	GameUIAlliance.super.ctor(self,City,_("联盟"))
	self.isJoinAlliance = false
	self.flag_info = {
		flag = self.FLAG_LOCATION_TYPE.ONE,
		flagColor = {"red","yellow"}, 
		graphic = self.FLAG_LOCATION_TYPE.TWO_LEFT_RIGHT,
		graphicColor = {"charmRed","blue"},
		graphicContent = {1,3}, --graphic image is index
	}
	dump(self.flag_info)
	--fisrt 
	self:RandomFlag()
end

function GameUIAlliance:onEnter()
	GameUIAlliance.super.onEnter(self)
	self:CreateBetweenBgAndTitle()
	if not self.isJoinAlliance then
		self:CreateNoAllianceUI()
		if not DataManager.open_alliance then
			self:CreateAllianceTips()
		end
	else
		self:CreateNoAllianceUI()
	end
end

function GameUIAlliance:CreateBetweenBgAndTitle()
	self.main_content = display.newNode():addTo(self):pos(window.left+40,window.bottom+68)
	self.main_content:setContentSize(cc.size(window.width - 80,window.betweenHeaderAndTab))
end

------------------------------------------------------------------------------------------------
---- I did not have a alliance
------------------------------------------------------------------------------------------------

function GameUIAlliance:CreateNoAllianceUI()
	self:CreateTabButtons(
	{
		{
			label = _("创建"),
        	tag = "create",
        	default = true,
        },
        {
        	label = _("加入"),
        	tag = "join",
    	},
    	{
        	label = _("邀请"),
        	tag = "invite",
    	},
    	{
        	label = _("申请"),
        	tag = "apply",
    	},
    },
	function(tag)
		--call common tabButtons event
		if self["NoAllianceTabEvent_" .. tag .. "If"] then
			if self.currentContent then
				self.currentContent:hide()
			end
			self.currentContent = self["NoAllianceTabEvent_" .. tag .. "If"](self)
			self.currentContent:show()
		end
	end
	):pos(window.cx, window.bottom + 34)
end

function GameUIAlliance:CreateAllianceTips()
	DataManager.open_alliance = true --已打开过联盟界面
end

-- TabButtons event
-- 1.create
-- 1.1 flag
function GameUIAlliance:_createFlagPanel()
	local node = display.newNode()
	-- graphic
	local bottom = display.newSprite("alliance_flag_bg_bottom_404x36.png")
		:align(display.RIGHT_BOTTOM, contentWidth - 10,0):addTo(node)
	local header = display.newSprite("alliance_flag_bg_header_404x36.png")
	local middle = display.newScale9Sprite("alliance_flag_bg_middle_404x1.png")
		:size(404,210 - 36*2)
		:addTo(node)
		:align(display.RIGHT_BOTTOM,bottom:getPositionX(),bottom:getPositionY()+bottom:getContentSize().height)
	header:addTo(node)
		:align(display.RIGHT_BOTTOM, middle:getPositionX(), middle:getPositionY()+middle:getContentSize().height)
	UIKit:ttfLabel({
		text = _("图案"),
		size = 20,
		color = 0x797154
	}):addTo(header):pos(header:getContentSize().width/2 - 10,header:getContentSize().height/2)
	local colorButton_right = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"},
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.flagData_.color,
		self:GetFlagInfomation().graphicColor[2]
	):addTo(node)
		:pos(bottom:getPositionX()-60,bottom:getPositionY()+50)
		:setButtonEnabled(self:GetFlagInfomation().graphic ~= self.FLAG_LOCATION_TYPE.ONE)
		:onButtonClicked(handler(self, self.OnGraphicTypeButtonClicked))
	self.colorButton_right = colorButton_right
	local colorButton_left = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.flagData_.color,
		self:GetFlagInfomation().graphicColor[1]
	):addTo(node):pos(colorButton_right:getPositionX()-135,colorButton_right:getPositionY())
	:onButtonClicked(handler(self, self.OnGraphicTypeButtonClicked))
	self.colorButton_left = colorButton_left
	local graphic_right_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false,scale = 0.55},
		self.flagData_.graphic,
		nil,
		self:GetFlagInfomation().graphicContent[2]
		):addTo(node)
			:pos(colorButton_right:getPositionX(),colorButton_right:getPositionY()+80)
			:setButtonEnabled(self:GetFlagInfomation().graphic ~= self.FLAG_LOCATION_TYPE.ONE)
			:onButtonClicked(handler(self, self.OnGraphicTypeButtonClicked))
		self.graphic_right_button = graphic_right_button
	local graphic_middle_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false,scale = 0.55},
		self.flagData_.graphic,
		nil,
		self:GetFlagInfomation().graphicContent[1]
		):addTo(node)
			:pos(colorButton_left:getPositionX(),colorButton_right:getPositionY()+80)
			:onButtonClicked(handler(self, self.OnGraphicTypeButtonClicked))
		self.graphic_middle_button = graphic_middle_button
	local graphic_type_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		self.flagData_.graphicButton,
		nil,
		self:GetFlagInfomation().graphic
		):addTo(node)
		:pos(colorButton_left:getPositionX() - 135,colorButton_right:getPositionY()+80)
		:onButtonClicked(handler(self, self.OnGraphicTypeButtonClicked))

	self.graphic_type_button =  graphic_type_button
	-- color body
	--118
	local color_bottom = display.newSprite("alliance_flag_bg_bottom_404x36.png")
		:align(display.RIGHT_BOTTOM, contentWidth - 10,header:getPositionY()+header:getContentSize().height+20)
		:addTo(node)
	local color_header = display.newSprite("alliance_flag_bg_header_404x36.png")
	local color_middle = display.newScale9Sprite("alliance_flag_bg_middle_404x1.png")
		:size(404,130 - 36*2)
		:addTo(node)
		:align(display.RIGHT_BOTTOM,color_bottom:getPositionX(),color_bottom:getPositionY()+color_bottom:getContentSize().height)
	color_header:addTo(node)
		:align(display.RIGHT_BOTTOM, color_middle:getPositionX(), color_middle:getPositionY()+color_middle:getContentSize().height)
	UIKit:ttfLabel({
		text = _("颜色"),
		size = 20,
		color = 0x797154
	}):addTo(color_header):pos(color_header:getContentSize().width/2 - 10,color_header:getContentSize().height/2)

	local color_rightColor_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.flagData_.color,
		self:GetFlagInfomation().flagColor[2]
	):addTo(node):pos(color_bottom:getPositionX()-60,color_bottom:getPositionY()+50)
		:setButtonEnabled(self:GetFlagInfomation().flag ~= self.FLAG_LOCATION_TYPE.ONE)
		:onButtonClicked(handler(self, self.OnFlagTypeButtonClicked))
	self.color_rightColor_button = color_rightColor_button
	local color_middleColor_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		{{image="alliance_flag_color_44x44.png"}},
		self.flagData_.color,
		self:GetFlagInfomation().flagColor[1]
	)
		:addTo(node):pos(color_rightColor_button:getPositionX()-135,color_rightColor_button:getPositionY())
		:onButtonClicked(handler(self, self.OnFlagTypeButtonClicked))
	self.color_middleColor_button = color_middleColor_button
	local flag_type_button = WidgetSequenceButton.new(
		{normal = "alliance_flag_button_normal.png",pressed = "alliance_flag_button_highlight.png"}, 
		{scale9 = false},
		self.flagData_.bodyButton,
		nil,
		self:GetFlagInfomation().flag
	):addTo(node)
	:pos(color_middleColor_button:getPositionX() - 135,color_rightColor_button:getPositionY())
	:onButtonClicked(handler(self, self.OnFlagTypeButtonClicked))
	self.flag_type_button = flag_type_button

	local upgrade_surface = display.newSprite("greensward_540x378.png")
		:addTo(node)
		:align(display.RIGHT_BOTTOM, contentWidth - header:getContentSize().width - 15, header:getPositionY() - 20)
		:scale(0.258)
	local shadow = display.newSprite("alliance_flag_shadow_113x79.png")
		:addTo(node)
		:align(display.RIGHT_BOTTOM, upgrade_surface:getPositionX() - 42, upgrade_surface:getPositionY()+28)
		:scale(0.7)
	display.newSprite("alliance_flag_base_84x89.png")
		:addTo(node)
		:align(display.RIGHT_BOTTOM, upgrade_surface:getPositionX() - 42, upgrade_surface:getPositionY()+28)
		:scale(0.7)
	--get flag sprite
	self.flag_sprite = self:GetFlagSprite():addTo(node)
	:align(display.RIGHT_BOTTOM, upgrade_surface:getPositionX() - 112, upgrade_surface:getPositionY()+68)
	:scale(0.7)
	UIKit:ttfLabel({
		text = _("联盟旗帜"),
		size = 20,
		color = 0x797154
	}):addTo(node):pos(color_header:getPositionX()-320,color_header:getPositionY()+color_header:getContentSize().height+15)

	local randomButton = WidgetPushButton.new({normal = "alliance_sieve_51x45.png"})
		:addTo(node)
		:pos(upgrade_surface:getPositionX() - 50,upgrade_surface:getPositionY()-20)
		:onButtonClicked(function()
			self:RandomFlag()
			self:RefreshButtonState()
			self:RefrshFlagSprite()
		end)
	return node
end

function GameUIAlliance:getColorSprite(image,color)
	print(image,color)
	dump(UIKit:convertColorToGL_(color_from_excel[color]))
	local customParams = {
		frag = "shaders/customer_color.fsh",
		shaderName = color,
		color = UIKit:convertColorToGL_(color_from_excel[color])
	}
	return display.newFilteredSprite(image, "CUSTOM", json.encode(customParams))
end

function GameUIAlliance:GetFlagSprite(flagInfo)
	flagInfo = self:GetFlagInfomation()

	local box_bounding = display.newSprite("alliance_flag_box_119x139.png")
	local box = display.newNode()
	--body
	local body_node = self:GetFlagBody(flagInfo,box_bounding)
	body_node:addTo(box,self.FLAG_BODY_ZORDER,self.FLAG_BODY_TAG)
	--graphic
	local graphic_node = self:GetGraphic(flagInfo,box_bounding)
	graphic_node:addTo(box,self.FLAG_GRAPHIC_ZORDER,self.FLAG_GRAPHIC_TAG)
	box_bounding:addTo(box,self.FLAG_BOX_ZORDER,self.FLAG_BOX_TAG):align(display.LEFT_BOTTOM, 0, 0)
	return box
end

function GameUIAlliance:GetGraphic(flagInfo,box_bounding)
	local graphic_node = display.newNode() 
	if flagInfo.graphic == self.FLAG_LOCATION_TYPE.ONE then

		local color_1 = flagInfo.graphicColor[1]
		local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
		local graphic_1 =  self:getColorSprite(imageName_1,color_1)
			:addTo(graphic_node)
			:pos(box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)

	elseif flagInfo.graphic == self.FLAG_LOCATION_TYPE.TWO_LEFT_RIGHT then

		local color_1 = flagInfo.graphicColor[1]
		local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
		local graphic_1 =  self:getColorSprite(imageName_1,color_1)
			:addTo(graphic_node)
			:pos(box_bounding:getContentSize().width/3*1 - 4,box_bounding:getContentSize().height/2)
			:scale(0.5)
		local color_2 = flagInfo.graphicColor[2]
		local imageName_2 = self.flagData_.graphic[flagInfo.graphicContent[2]].image
		local graphic_2 =  self:getColorSprite(imageName_2,color_2)
			:addTo(graphic_node)
			:pos(box_bounding:getContentSize().width/3*2 + 4,box_bounding:getContentSize().height/2)
			:scale(0.5)

	elseif flagInfo.graphic == self.FLAG_LOCATION_TYPE.TWO_TOP_BOTTOM then

		local color_1 = flagInfo.graphicColor[1]
		local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
		local graphic_1 =  self:getColorSprite(imageName_1,color_1)
			:addTo(graphic_node)
			:align(display.TOP_CENTER,box_bounding:getContentSize().width/2, box_bounding:getContentSize().height - 20)
			:scale(0.5)
		local color_2 = flagInfo.graphicColor[2]
		local imageName_2 = self.flagData_.graphic[flagInfo.graphicContent[2]].image
		local graphic_2 =  self:getColorSprite(imageName_2,color_2)
			:addTo(graphic_node)
			:align(display.CENTER_BOTTOM, box_bounding:getContentSize().width/2, 20)
			:scale(0.5)

	elseif flagInfo.graphic == self.FLAG_LOCATION_TYPE.TWO_X then
		local color_1 = flagInfo.graphicColor[1]
		local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
		local graphic_1 =  self:getColorSprite(imageName_1,color_1)
			:addTo(graphic_node)
			:align(display.LEFT_TOP,box_bounding:getContentSize().width/8*1, box_bounding:getContentSize().height/8*7)
			:scale(0.5)
		graphic_1 = self:getColorSprite(imageName_1,color_1)
			:addTo(graphic_node)
			:align(display.RIGHT_BOTTOM,box_bounding:getContentSize().width/8*7, box_bounding:getContentSize().height/8*1+10)
			:scale(0.5)
		local color_2 = flagInfo.graphicColor[2]
		local imageName_2 = self.flagData_.graphic[flagInfo.graphicContent[2]].image
		local graphic_2 =  self:getColorSprite(imageName_2,color_2)
			:addTo(graphic_node)
			:align(display.LEFT_BOTTOM,box_bounding:getContentSize().width/8*1, box_bounding:getContentSize().height/8*1 + 10)
			:scale(0.5)
		graphic_2 = self:getColorSprite(imageName_2,color_2)
			:addTo(graphic_node)
			:align(display.RIGHT_TOP,box_bounding:getContentSize().width/8*7, box_bounding:getContentSize().height/8*7)
			:scale(0.5)
	end
	return graphic_node
end


function GameUIAlliance:GetFlagBody(flagInfo,box_bounding)
	 --body
    local body_node = display.newNode() -- :addTo(box,self.FLAG_BODY_ZORDER,self.FLAG_BODY_TAG)
	if flagInfo.flag == self.FLAG_LOCATION_TYPE.ONE then
    	local imageName = self.flagData_.body["1"]
    	local color  = flagInfo.flagColor[1]
		self:getColorSprite(imageName,color)
			:addTo(body_node)
			:pos(box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
	elseif flagInfo.flag == self.FLAG_LOCATION_TYPE.TWO_LEFT_RIGHT then
		local imageName_1 = self.flagData_.body["2_1"]
    	local color_1  = flagInfo.flagColor[1]
    	self:getColorSprite(imageName_1,color_1)
    		:scale(0.95)
    		:addTo(body_node)
    		:align(display.CENTER_RIGHT,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    	local imageName_2 = self.flagData_.body["2_2"]
    	local color_2  = flagInfo.flagColor[2]
    	self:getColorSprite(imageName_2,color_2)
    		:scale(0.95)
    		:addTo(body_node)
    		:align(display.CENTER_LEFT,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    elseif flagInfo.flag == self.FLAG_LOCATION_TYPE.TWO_TOP_BOTTOM then
    	local imageName_1 = self.flagData_.body["3_1"]
    	local color_1  = flagInfo.flagColor[1]
    	self:getColorSprite(imageName_1,color_1)
    		:scale(0.95)
    		:addTo(body_node)
    		:align(display.BOTTOM_CENTER,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    	local imageName_2 = self.flagData_.body["3_2"]
    	local color_2  = flagInfo.flagColor[2]
    	self:getColorSprite(imageName_2,color_2)
    		:scale(0.95)
    		:addTo(body_node)
    		:align(display.TOP_CENTER,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    elseif flagInfo.flag == self.FLAG_LOCATION_TYPE.TWO_X then
    	local imageName_1 = self.flagData_.body["4_1"]
    	local color_1  = flagInfo.flagColor[1]
    	self:getColorSprite(imageName_1,color_1)
    		:scale(0.95)
    		:addTo(body_node)
    		:align(display.CENTER,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    	local imageName_2 = self.flagData_.body["4_2"]
    	local color_2  = flagInfo.flagColor[2]
    	self:getColorSprite(imageName_2,color_2)
    		:scale(0.95)
    		:addTo(body_node)
    		:align(display.CENTER,box_bounding:getContentSize().width/2-1,box_bounding:getContentSize().height/2)
    		:setFlippedX(true)
	end
	return body_node
end
-- where : 1 body 2 graphic
function GameUIAlliance:RefrshFlagSprite(where)
	local box_bounding = self.flag_sprite:getChildByTag(self.FLAG_BOX_TAG)
	if 1 == where then --body
		local body_node = self.flag_sprite:getChildByTag(self.FLAG_BODY_TAG)
		body_node:removeFromParent(true)
		body_node = self:GetFlagBody(self:GetFlagInfomation(),box_bounding)
		body_node:addTo(self.flag_sprite,self.FLAG_BODY_ZORDER,self.FLAG_BODY_TAG)
	elseif 2 == where then --graphic
		local graphic_node = self.flag_sprite:getChildByTag(self.FLAG_GRAPHIC_TAG)
		graphic_node:removeFromParent(true)
		graphic_node = self:GetGraphic(self:GetFlagInfomation(),box_bounding)
		graphic_node:addTo(self.flag_sprite,self.FLAG_GRAPHIC_ZORDER,self.FLAG_GRAPHIC_TAG)
	else --all
		self:RefrshFlagSprite(1)
		self:RefrshFlagSprite(2)
	end
end

function GameUIAlliance:GetFlagInfomation()
	return self.flag_info
end

function GameUIAlliance:RandomFlag()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	self.flag_info.flag = math.random(#FLAG_LOCATION_TYPES)
	self.flag_info.flagColor[1] = self.flagData_.color[math.random(#self.flagData_.color)].name
	self.flag_info.flagColor[2] = self.flagData_.color[math.random(#self.flagData_.color)].name
	self.flag_info.graphic = math.random(#FLAG_LOCATION_TYPES)
	self.flag_info.graphicColor[1] = self.flagData_.color[math.random(#self.flagData_.color)].name
	self.flag_info.graphicColor[2] = self.flagData_.color[math.random(#self.flagData_.color)].name
	self.flag_info.graphicContent[1] = self.flagData_.graphic[math.random(#self.flagData_.graphic)].name
	self.flag_info.graphicContent[2] = self.flagData_.graphic[math.random(#self.flagData_.graphic)].name
	-- dump(self.flag_info)
end

function GameUIAlliance:RefreshButtonState()
	self.flag_type_button:setSeqState(self:GetFlagInfomation().flag)
	self.color_middleColor_button:setSeqState(self:GetFlagInfomation().flagColor[1])
	self.color_rightColor_button:setSeqState(self:GetFlagInfomation().flagColor[2])
	self.color_rightColor_button:setButtonEnabled(self:GetFlagInfomation().flag ~= self.FLAG_LOCATION_TYPE.ONE)

	self.graphic_type_button:setSeqState(self:GetFlagInfomation().graphic)
	self.colorButton_right:setSeqState(self:GetFlagInfomation().graphicColor[2])
	self.colorButton_left:setSeqState(self:GetFlagInfomation().graphicColor[1])
	
	self.graphic_middle_button:setSeqState(self:GetFlagInfomation().graphicContent[1])
	self.graphic_right_button:setSeqState(self:GetFlagInfomation().graphicContent[2])
	self.colorButton_right:setButtonEnabled(self:GetFlagInfomation().graphic ~= self.FLAG_LOCATION_TYPE.ONE)
	self.graphic_right_button:setButtonEnabled(self:GetFlagInfomation().graphic ~= self.FLAG_LOCATION_TYPE.ONE)
end

-- flag button event

function GameUIAlliance:OnFlagTypeButtonClicked()
	self.flag_info.flag = self.flag_type_button:GetSeqState()
	self.flag_info.flagColor[1] = self.color_middleColor_button:GetSeqState() 
	self.flag_info.flagColor[2] = self.color_rightColor_button:GetSeqState()
	self.color_rightColor_button:setButtonEnabled(self:GetFlagInfomation().flag ~= self.FLAG_LOCATION_TYPE.ONE)
	self:RefrshFlagSprite(1)
end

function GameUIAlliance:OnGraphicTypeButtonClicked()
	self.flag_info.graphic = self.graphic_type_button:GetSeqState()
	self.flag_info.graphicColor[2] = self.colorButton_right:GetSeqState()
	self.flag_info.graphicColor[1] = self.colorButton_left:GetSeqState()
	self.flag_info.graphicContent[1] = self.graphic_middle_button:GetSeqState()  
	self.flag_info.graphicContent[2] = self.graphic_right_button:GetSeqState()
	self.colorButton_right:setButtonEnabled(self:GetFlagInfomation().graphic ~= self.FLAG_LOCATION_TYPE.ONE)
	self.graphic_right_button:setButtonEnabled(self:GetFlagInfomation().graphic ~= self.FLAG_LOCATION_TYPE.ONE)
	self:RefrshFlagSprite(2)
end


--1.2 landform

--1 main
function GameUIAlliance:NoAllianceTabEvent_createIf()
	if self.createScrollView then 
		return self.createScrollView
	end
	self.createAllianceUI = {}
	local createContent = cc.Node:create():pos(0,0)
	--button
	local okButton = cc.ui.UIPushButton.new({normal = "green_btn_up_142x39.png",pressed = "green_btn_down_142x39.png"}, {scale9 = true})
    	:addTo(createContent)
    	:align(display.BOTTOM_RIGHT, contentWidth - 10, 10)
    	:setButtonLabel("normal",  cc.ui.UILabel.new({
	    	UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
	    	text = _("确定"),
	        font = UIKit:getFontFilePath(),
	        size = 22,
	        color = UIKit:hex2c3b(0xffedae),
   	 	}))
	    :onButtonClicked(function(event)

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
	self.createAllianceUI.gemLabel = gemLabel
	-- flags
    self.createFlagPanel = self:_createFlagPanel():addTo(createContent):pos(0,okButton:getPositionY()+45)
    -- landform

    -- test 
    --
	
	local scrollView = UIScrollView.new({viewRect = cc.rect(0,0,contentWidth,window.betweenHeaderAndTab)})
        :addScrollNode(createContent)
        :setDirection(UIScrollView.DIRECTION_VERTICAL)
        :onScroll(handler(self, self.CreateAllianceScrollListener))
        :addTo(self.main_content)
	scrollView:fixResetPostion()
	self.createScrollView = scrollView
	return self.createScrollView
end

function GameUIAlliance:CreateBoxPanel(height)
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

--2.join 
function GameUIAlliance:NoAllianceTabEvent_joinIf()

end

function GameUIAlliance:NoAllianceTabEvent_inviteIf()

end

function GameUIAlliance:NoAllianceTabEvent_applyIf()

end

--scroll callback
function GameUIAlliance:CreateAllianceScrollListener()

end

------------------------------------------------------------------------------------------------
---- I have join in a alliance
------------------------------------------------------------------------------------------------

return GameUIAlliance