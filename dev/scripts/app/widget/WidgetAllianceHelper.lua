--
-- Author: Danny He
-- Date: 2015-04-10 15:04:46
--
local WidgetAllianceHelper = class("WidgetAllianceHelper")
-- local  = 1
function WidgetAllianceHelper:ctor()
	self.colors = {
		0x000000,
		0xffffff,
		0x209b5c,
		0x673499,
		0xa82128,
		0x30529c,
		0xbfac12,
		0x494949,
		0x349bc4,
		0xc061ef,
		0xd05e15,
		0x209a9b
	}
	self.landforms = {
		grassLand = 1,desert = 2,iceField = 3
	}
	self.count_of_landforms = 3
	self.terrain_info = math.random(self.count_of_landforms)
	--旗帜的所有图案
	self.images_of_graphics = {}
	for i=1,19 do
	    local imageName = string.format("alliance_graphic_88x88_%d",i)
	    table.insert(self.images_of_graphics,{name = i,image = imageName .. ".png"})
	end
	--旗帜背景布局样式
	self.images_of_category = {}
	for i=1,9 do
	    local bodyButtonImageName = string.format("alliance_flag_type_48x46_%d",i)
		self.images_of_category[i] = {name = i,image = bodyButtonImageName .. ".png"}
	end
	--对应三种地形
	self.images_of_terrain_rhombus = {"greensward_540x378.png","greensward_540x378.png","greensward_540x378.png"}
	self.images_of_terrain_rectangle = {"rectangle_terrain_216x282.png","rectangle_terrain_216x282.png","rectangle_terrain_216x282.png"}

end

function WidgetAllianceHelper:GetRectangleTerrainImageByIndex(index)
	return self.images_of_terrain_rectangle[index]
end

function WidgetAllianceHelper:GetRhombusTerrainImageByIndex(index)
	return self.images_of_terrain_rhombus[index]
end

function WidgetAllianceHelper:GetGraphicImageNameByIndex(index)
	return self.images_of_graphics[index].image
end

function WidgetAllianceHelper:GetAllGraphicsForSeqButton()
	return self.images_of_graphics
end

function WidgetAllianceHelper:GetAllColors()
	return self.colors
end

function WidgetAllianceHelper:GetAllColorsForSeqButton()
	if not self.seq_colors then
		self.seq_colors = {}
		table.foreachi(self:GetAllColors(),function(index,v)
	    	table.insert(self.seq_colors,{name = "colors_" .. tostring(index),color=UIKit:convertColorToGL_(v)})
		end)
	end
	return self.seq_colors
end

function WidgetAllianceHelper:GetBackStylesForSeqButton()
	return self.images_of_category
end

function WidgetAllianceHelper:GetColorByIndex(index)
	checkint(index)
	return self.colors[index]
end

function WidgetAllianceHelper:GetTerrainIndex(name)
	return self.landforms[name]
end

function WidgetAllianceHelper:RandomTerrain()
	self.terrain_info = math.random(self.count_of_landforms)
	return self.terrain_info
end

function WidgetAllianceHelper:RandomAlliacneNameAndTag()
	return DataUtils:randomAllianceNameTag()
end

function WidgetAllianceHelper:GetTerrain()
	return self.terrain_info
end

--旗帜

--创建一个自定义颜色的Sprite
function WidgetAllianceHelper:CreateColorSprite(image,color_index)
    local customParams = {
        frag = "shaders/customer_color.fsh",
        shaderName = "colors_" .. color_index,
        color = UIKit:convertColorToGL_(self:GetColorByIndex(color_index))
    }
    return display.newFilteredSprite(image, "CUSTOM", json.encode(customParams))
end
--创建旗帜
function WidgetAllianceHelper:CreateFlagContentSprite(obj_flag)
	local box_bounding = display.newSprite("alliance_flag_box_119x139.png")
	local size = box_bounding:getContentSize()
    local box = display.newNode()
    --body
    local body_node = self:CreateFlagBody(obj_flag,size)
    body_node:addTo(box)
    --graphic
    local graphic_node = self:CreateFlagGraphic(obj_flag,size)
    graphic_node:addTo(box)
   	box_bounding:addTo(box):align(display.LEFT_BOTTOM, 0, 0)
    return box
end
--旗帜背景
function WidgetAllianceHelper:CreateFlagBody(obj_flag,box_bounding)
	local body_node = display.newNode() 
	local color_1,color_2 = obj_flag:GetBackColors()
	local bg = self:CreateColorSprite("alliance_flag_body_106x126_1.png",color_1)
		:addTo(body_node)
        :pos(box_bounding.width/2,box_bounding.height/2)
    if obj_flag:GetBackStyle() > 1 then
    	local content = self:CreateColorSprite(string.format("alliance_flag_body_106x126_%d.png",obj_flag:GetBackStyle()),color_2)
    		:addTo(body_node)
        	:pos(box_bounding.width/2,box_bounding.height/2)
    end
	return body_node
end
--旗帜图案
function WidgetAllianceHelper:CreateFlagGraphic(obj_flag,box_bounding)
	local filename = self:GetGraphicImageNameByIndex(obj_flag:GetFrontStyle())
	local color = UIKit:hex2c3b(self:GetColorByIndex(obj_flag:GetFrontColor()))
	local sprite = display.newSprite(filename):pos(box_bounding.width/2,box_bounding.height/2)
	sprite:setColor(color)
	return sprite
end
--带地形(矩形)的旗帜
function WidgetAllianceHelper:CreateFlagWithRectangleTerrain(terrain_info,obj_flag)
	if type(terrain_info) == 'string' then terrain_info = self:GetTerrainIndex(terrain_info) end
	local terrain_file = self:GetRectangleTerrainImageByIndex(terrain_info)
	local node = display.newNode()
	local terrain_sprite = display.newSprite(terrain_file)
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
--带地形(菱形)的旗帜
function WidgetAllianceHelper:CreateFlagWithRhombusTerrain(terrain_info,obj_flag)
    if type(terrain_info) == 'string' then terrain_info = self:GetTerrainIndex(terrain_info)  end
    local node = display.newNode()
    local terrain = self:GetRhombusTerrainImageByIndex(terrain_info)
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

return WidgetAllianceHelper