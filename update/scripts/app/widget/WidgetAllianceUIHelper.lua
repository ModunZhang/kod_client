--
-- Author: Danny He
-- Date: 2014-10-25 10:11:37
--
local WidgetAllianceUIHelper = class("WidgetAllianceUIHelper")

WidgetAllianceUIHelper.LANDFORM_TYPE = {grassLand = 1,desert = 2,iceField = 3}
--enum
local RANDOM_ALLIANCE_NAMES = {
	"Kingdom of Dragon",
	"Tian Chao"
}

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

WidgetAllianceUIHelper.FLAG_LOCATION_TYPE = {
    ONE = 1,
    TWO_LEFT_RIGHT = 2,
    TWO_TOP_BOTTOM = 3,
    TWO_X = 4
}

WidgetAllianceUIHelper.FLAG_BODY = {}
WidgetAllianceUIHelper.FLAG_BODY["1"] = "alliance_flag_body_1.png"
WidgetAllianceUIHelper.FLAG_BODY["2_1"] = "alliance_flag_body_2_1.png"
WidgetAllianceUIHelper.FLAG_BODY["2_2"] = "alliance_flag_body_2_2.png"
WidgetAllianceUIHelper.FLAG_BODY["3_1"] = "alliance_flag_body_3_1.png"
WidgetAllianceUIHelper.FLAG_BODY["3_2"] = "alliance_flag_body_3_2.png"
WidgetAllianceUIHelper.FLAG_BODY["4_1"] = "alliance_flag_body_4.png"
WidgetAllianceUIHelper.FLAG_BODY["4_2"] = "alliance_flag_body_4.png"


--zorder

WidgetAllianceUIHelper.FLAG_BODY_TAG = 1
WidgetAllianceUIHelper.FLAG_BODY_ZORDER = 1
WidgetAllianceUIHelper.FLAG_GRAPHIC_TAG = 2
WidgetAllianceUIHelper.FLAG_GRAPHIC_ZORDER = 2
WidgetAllianceUIHelper.FLAG_BOX_TAG  = 3
WidgetAllianceUIHelper.FLAG_BOX_ZORDER = 3

--methods
function WidgetAllianceUIHelper:ctor()
end

function WidgetAllianceUIHelper:SetTerrain( terrain )
	self.terrain_info = terrain
	return self
end

function WidgetAllianceUIHelper:GetTerrain()
	return self.terrain_info
end

function WidgetAllianceUIHelper:GetFlagColors()
	if not self.colors then
		self.colors = {}
		table.foreach(color_from_excel,function(k,v)
	    	table.insert(self.colors,{name = k,color=UIKit:convertColorToGL_(v)})
		end)
	end
	return self.colors
end
--旗帜的所有图案
function WidgetAllianceUIHelper:GetGraphics()
	if not self.graphics then
		self.graphics = {}
		for i=1,17 do
		    local imageName = string.format("alliance_graphic_%d",i)
		    table.insert(self.graphics,{name = i,image = imageName .. ".png"})
		end
	end
	return self.graphics
end

function WidgetAllianceUIHelper:GetFrontStyles()
	if not self.frontStyles then
		self.frontStyles = {}
		for i=1,4 do
		    local graphicButtonImageName = string.format("alliance_flag_graphic_%d",i)
		    self.frontStyles[i] = {name = i,image = graphicButtonImageName .. ".png"}
		end
	end
	return self.frontStyles
end

function WidgetAllianceUIHelper:GetBackStyles()
	if not self.backStyles then
		self.backStyles = {}
		for i=1,4 do
		    local bodyButtonImageName = string.format("alliance_flag_type_45x45_%d",i)
    		self.backStyles[i] = {name = i,image = bodyButtonImageName .. ".png"}
		end
	end
	return self.backStyles
end
--三种基本地形(菱形)
function WidgetAllianceUIHelper:GetAllRhombusTerrains()
	if not self.terrains then
		self.terrains = {}
		for i=1,3 do
    		self.terrains[i] = "greensward_540x378.png"
		end
	end
	return self.terrains
end
--三种基本地形(矩形)
function WidgetAllianceUIHelper:GetAllRectangleTerrains()
	if not self.terrains then
		self.terrains = {}
		for i=1,3 do
    		self.terrains[i] = "rectangle_terrain_216x282.png"
		end
	end
	return self.terrains
end

function WidgetAllianceUIHelper:RandomTerrain()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	self.terrain_info = math.random(3)
	return self.terrain_info
end


function WidgetAllianceUIHelper:RandomAlliacneNameAndTag()
	local name = RANDOM_ALLIANCE_NAMES[math.random(#RANDOM_ALLIANCE_NAMES)]
	local randomTag = ""
	table.foreachi(string.split(string.trim(name)," "),function (i,v)
		randomTag = randomTag .. string.sub(v,1,1)
	end)
	return name,randomTag
end

function WidgetAllianceUIHelper:GetLandFormTypeName(val)
	for k,v in pairs(self.LANDFORM_TYPE) do
		if val == v then
			return k
		end
	end
	return ""
end

--创建一个自定义颜色的Sprite
function WidgetAllianceUIHelper:CreateColorSprite(image,color)
    print(image,color)
    local customParams = {
        frag = "shaders/customer_color.fsh",
        shaderName = color,
        color = UIKit:convertColorToGL_(color_from_excel[color])
    }
    return display.newFilteredSprite(image, "CUSTOM", json.encode(customParams))
end
--旗帜背景
function WidgetAllianceUIHelper:CreateFlagBody(obj_flag,box_bounding)
    --body
    local body_node = display.newNode() -- :addTo(box,self.FLAG_BODY_ZORDER,self.FLAG_BODY_TAG)
    if obj_flag:GetBackStyle() == self.FLAG_LOCATION_TYPE.ONE then
        local imageName = self.FLAG_BODY["1"]
        local color  = obj_flag:GetBackColors()[1]
        self:CreateColorSprite(imageName,color)
            :addTo(body_node)
            :pos(box_bounding.width/2,box_bounding.height/2)
    elseif obj_flag:GetBackStyle() == self.FLAG_LOCATION_TYPE.TWO_LEFT_RIGHT then
        local imageName_1 = self.FLAG_BODY["2_1"]
        local color_1  = obj_flag:GetBackColors()[1]
        self:CreateColorSprite(imageName_1,color_1)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER_RIGHT,box_bounding.width/2,box_bounding.height/2)
        local imageName_2 = self.FLAG_BODY["2_2"]
        local color_2  = obj_flag:GetBackColors()[2]
        self:CreateColorSprite(imageName_2,color_2)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER_LEFT,box_bounding.width/2,box_bounding.height/2)
    elseif obj_flag:GetBackStyle() == self.FLAG_LOCATION_TYPE.TWO_TOP_BOTTOM then
        local imageName_1 = self.FLAG_BODY["3_1"]
        local color_1  = obj_flag:GetBackColors()[1]
        self:CreateColorSprite(imageName_1,color_1)
            :scale(0.95)
            :addTo(body_node)
            :align(display.BOTTOM_CENTER,box_bounding.width/2,box_bounding.height/2)
        local imageName_2 = self.FLAG_BODY["3_2"]
        local color_2  = obj_flag:GetBackColors()[2]
        self:CreateColorSprite(imageName_2,color_2)
            :scale(0.95)
            :addTo(body_node)
            :align(display.TOP_CENTER,box_bounding.width/2,box_bounding.height/2)
    elseif obj_flag:GetBackStyle() == self.FLAG_LOCATION_TYPE.TWO_X then
        local imageName_1 = self.FLAG_BODY["4_1"]
        local color_1  = obj_flag:GetBackColors()[1]
        self:CreateColorSprite(imageName_1,color_1)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER,box_bounding.width/2,box_bounding.height/2)
        local imageName_2 = self.FLAG_BODY["4_2"]
        local color_2  = obj_flag:GetBackColors()[2]
        self:CreateColorSprite(imageName_2,color_2)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER,box_bounding.width/2-1,box_bounding.height/2)
            :setFlippedX(true)
    end
    return body_node
end
--创建旗帜图案
function WidgetAllianceUIHelper:CreateFlagGraphic(obj_flag,box_bounding)
    local graphic_node = display.newNode()
    if obj_flag:GetFrontStyle() == self.FLAG_LOCATION_TYPE.ONE then

        local color_1 = obj_flag:GetFrontImageColors()[1]
        local imageName_1 = self:GetGraphics()[obj_flag:GetFrontImagesStyle()[1]].image
        local graphic_1 =  self:CreateColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :pos(box_bounding.width/2,box_bounding.height/2)

    elseif obj_flag:GetFrontStyle() == self.FLAG_LOCATION_TYPE.TWO_LEFT_RIGHT then

        local color_1 = obj_flag:GetFrontImageColors()[1]
        local imageName_1 = self:GetGraphics()[obj_flag:GetFrontImagesStyle()[1]].image
        local graphic_1 =  self:CreateColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :pos(box_bounding.width/3*1 - 4,box_bounding.height/2)
            :scale(0.5)
        local color_2 = obj_flag:GetFrontImageColors()[2]
        local imageName_2 = self:GetGraphics()[obj_flag:GetFrontImagesStyle()[2]].image
        local graphic_2 =  self:CreateColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :pos(box_bounding.width/3*2 + 4,box_bounding.height/2)
            :scale(0.5)

    elseif obj_flag:GetFrontStyle() == self.FLAG_LOCATION_TYPE.TWO_TOP_BOTTOM then

        local color_1 = obj_flag:GetFrontImageColors()[1]
        local imageName_1 = self:GetGraphics()[obj_flag:GetFrontImagesStyle()[1]].image
        local graphic_1 =  self:CreateColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :align(display.TOP_CENTER,box_bounding.width/2, box_bounding.height - 20)
            :scale(0.5)
        local color_2 = obj_flag:GetFrontImageColors()[2]
        local imageName_2 = self:GetGraphics()[obj_flag:GetFrontImagesStyle()[2]].image
        local graphic_2 =  self:CreateColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :align(display.CENTER_BOTTOM, box_bounding.width/2, 20)
            :scale(0.5)

    elseif obj_flag:GetFrontStyle() == self.FLAG_LOCATION_TYPE.TWO_X then
        local color_1 = obj_flag:GetFrontImageColors()[1]
        local imageName_1 = self:GetGraphics()[obj_flag:GetFrontImagesStyle()[1]].image
        local graphic_1 =  self:CreateColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :align(display.LEFT_TOP,box_bounding.width/8*1, box_bounding.height/8*7)
            :scale(0.5)
        graphic_1 = self:CreateColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :align(display.RIGHT_BOTTOM,box_bounding.width/8*7, box_bounding.height/8*1+10)
            :scale(0.5)
        local color_2 = obj_flag:GetFrontImageColors()[2]
        local imageName_2 = self:GetGraphics()[obj_flag:GetFrontImagesStyle()[2]].image
        local graphic_2 =  self:CreateColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :align(display.LEFT_BOTTOM,box_bounding.width/8*1, box_bounding.height/8*1 + 10)
            :scale(0.5)
        graphic_2 = self:CreateColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :align(display.RIGHT_TOP,box_bounding.width/8*7, box_bounding.height/8*7)
            :scale(0.5)
    end
    return graphic_node
end

--common api
--旗帜
function WidgetAllianceUIHelper:CreateFlagContentSprite(obj_flag)
	local box_bounding = display.newSprite("alliance_flag_box_119x139.png")
    local box = display.newNode()
    --body
    local body_node = self:CreateFlagBody(obj_flag,box_bounding:getContentSize())
    body_node:addTo(box,self.FLAG_BODY_ZORDER,self.FLAG_BODY_TAG)
    --graphic
    local graphic_node = self:CreateFlagGraphic(obj_flag,box_bounding:getContentSize())
    graphic_node:addTo(box,self.FLAG_GRAPHIC_ZORDER,self.FLAG_GRAPHIC_TAG)
    box_bounding:addTo(box,self.FLAG_BOX_ZORDER,self.FLAG_BOX_TAG):align(display.LEFT_BOTTOM, 0, 0)
    return box
end
--带地形(菱形)的旗帜
function WidgetAllianceUIHelper:CreateFlagWithRhombusTerrain(terrain_info,obj_flag)
    local node = display.newNode()
    if type(terrain_info) == 'string' then terrain_info = self.LANDFORM_TYPE[terrain_info] end
    local terrain = self:GetAllRhombusTerrains()[terrain_info]
    local terrain_sprite = display.newSprite(terrain)
        :addTo(node)
        :scale(0.258)
    local shadow = display.newSprite("alliance_flag_shadow_113x79.png")
        :addTo(node)
        :align(display.RIGHT_BOTTOM, terrain_sprite:getPositionX()+27, terrain_sprite:getPositionY()-23)
        :scale(0.7)
    local base = display.newSprite("alliance_flag_base_84x89.png")
        :addTo(node)
        :align(display.RIGHT_BOTTOM, terrain_sprite:getPositionX()+27, terrain_sprite:getPositionY()-23)
        :scale(0.7)
    local flag_node = self:CreateFlagContentSprite(obj_flag):addTo(node)
        :align(display.RIGHT_BOTTOM, terrain_sprite:getPositionX() - 42, terrain_sprite:getPositionY()+5)
        :scale(0.7)

    return node,terrain_sprite,flag_node
end
--带地形(矩形)的旗帜
function WidgetAllianceUIHelper:CreateFlagWithRectangleTerrain(terrain_info,obj_flag)
	local node = display.newNode()
    if type(terrain_info) == 'string' then terrain_info = self.LANDFORM_TYPE[terrain_info] end
    local terrain = self:GetAllRectangleTerrains()[terrain_info]
    local terrain_sprite = display.newSprite(terrain)
        :addTo(node)
        :scale(0.9)

    local shadow = display.newSprite("alliance_flag_shadow_113x79.png")
        :addTo(node)
        :align(display.RIGHT_BOTTOM, terrain_sprite:getPositionX()+36, terrain_sprite:getPositionY()-80)
        :scale(0.9)
    local base = display.newSprite("alliance_flag_base_84x89.png")
        :addTo(node)
        :align(display.RIGHT_BOTTOM, terrain_sprite:getPositionX()+35, terrain_sprite:getPositionY()-80)
        :scale(0.9)
    local flag_node = self:CreateFlagContentSprite(obj_flag):addTo(node)
        :align(display.RIGHT_BOTTOM, terrain_sprite:getPositionX() - 55, terrain_sprite:getPositionY()-45)
        :scale(0.9)
    local box = display.newSprite("rectangle_terrain_box_216x282.png")
        :addTo(node)
        :scale(0.9)

    return node,terrain_sprite,flag_node
end
return WidgetAllianceUIHelper