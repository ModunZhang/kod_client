--
-- Author: Danny He
-- Date: 2014-10-25 10:11:37
--
local WidgetAllianceUIHelper = class("WidgetAllianceUIHelper")

WidgetAllianceUIHelper.LANDFORM_TYPE = {grassLand = 1,desert = 2,iceField = 3}

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


return WidgetAllianceUIHelper