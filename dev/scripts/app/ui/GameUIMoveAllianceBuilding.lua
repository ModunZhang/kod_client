--
-- Author: Danny He
-- Date: 2015-03-20 10:35:58
--
local window = import('..utils.window')
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIMoveAllianceBuilding = UIKit:createUIClass("GameUIMoveAllianceBuilding")
local WidgetPushButton = import("..widget.WidgetPushButton")
local config_alliance_building = GameDatas.AllianceBuilding
local Localize = import("..utils.Localize")

function GameUIMoveAllianceBuilding:ctor(params)
	GameUIMoveAllianceBuilding.super.ctor(self,params)
	self.target_location = params.location or {x = 0,y = 0}
end

function GameUIMoveAllianceBuilding:onEnter()
	GameUIMoveAllianceBuilding.super.onEnter(self)
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local bg = WidgetUIBackGround.new({height=700}):addTo(shadowLayer):pos(window.left+20,window.bottom_top + 80)
	local titleBar = display.newSprite("title_blue_600x52.png"):align(display.LEFT_BOTTOM,3,685):addTo(bg)
	local closeButton = UIKit:closeButton()
	   	:addTo(titleBar)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width,0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	UIKit:ttfLabel({
		text = _("迁移联盟建筑"),
		size = 22,
		shadow = true,
		color = 0xffedae
	}):addTo(titleBar):align(display.CENTER,300,titleBar:getContentSize().height/2)
	local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0,0,568,630),
    })
    list_node:addTo(bg):pos(20,40)
    self.listView = list
    self:RefreshListView()
end

function GameUIMoveAllianceBuilding:GetListData()
	local list_data = {}
    Alliance_Manager:GetMyAlliance():GetAllianceMap():IteratorAllianceBuildings(function(__,alliance_object)
    	local info = alliance_object:GetAllianceBuildingInfo()
    	if info then
    		local x,y = alliance_object:GetLogicPosition()
    		local w,h = alliance_object:GetSize()
    		table.insert(list_data,{
				image = UIKit:getImageByBuildingType(info.name),
				title = Localize.alliance_buildings[info.name],
				moveNeedHonour = self:GetMoveNeedHonour(info.name,info.level),
				location = {x = x,y = y},
				size = w*h,
				key = info.name
			})
    	end
    end)
	return list_data
end

function GameUIMoveAllianceBuilding:GetMoveNeedHonour(buildingKey,level)
	if config_alliance_building[buildingKey] and config_alliance_building[buildingKey][level] then 
		return config_alliance_building[buildingKey][level].moveNeedHonour
	else
		return 0
	end
end

function GameUIMoveAllianceBuilding:RefreshListView()
	local building_infos = self:GetListData()
	self.listView:removeAllItems()
	for __,v in ipairs(building_infos) do
		local item = self:GetItem(v)
		self.listView:addItem(item)
	end
	self.listView:reload()
end

function GameUIMoveAllianceBuilding:GetItem(data)
	local item = self.listView:newItem()
	local content = WidgetUIBackGround.new({width = 568,height = 154},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
	local box = display.newSprite("bg_134x134.png"):align(display.LEFT_CENTER, 10, 77):addTo(content)
	local icon = display.newSprite(data.image, 67, 67):addTo(box)
	icon:scale(100/icon:getContentSize().width)

	local title_bar = display.newScale9Sprite("alliance_event_type_darkblue_222x30.png",0,0, cc.size(406,30), cc.rect(7,7,190,16))
		:addTo(content)
		:align(display.LEFT_TOP, box:getPositionX() + 140, box:getPositionY() + 67)
	UIKit:ttfLabel({
		text = data.title,
		size = 22,
		color= 0xffedae
	}):align(display.LEFT_CENTER, 16, 15):addTo(title_bar)
	local area_info_line = display.newScale9Sprite("dividing_line_352x2.png", 0, 0,cc.size(244,2))
		:align(display.LEFT_BOTTOM,title_bar:getPositionX(), 20)
		:addTo(content)
	local area_info_label = UIKit:ttfLabel({
			text = _("占地"),
			size = 20,
			color= 0x797154
		})
		:align(display.LEFT_BOTTOM,area_info_line:getPositionX(), area_info_line:getPositionY() + 2)
		:addTo(content)
	local area_info_val = UIKit:ttfLabel({
			text = data.size,
			size = 22,
			color= 0x403c2f
		})
		:align(display.RIGHT_BOTTOM, area_info_line:getPositionX()+area_info_line:getContentSize().width, area_info_label:getPositionY())
		:addTo(content)

	local location_info_line = display.newScale9Sprite("dividing_line_352x2.png", 0, 0,cc.size(244,2))
		:align(display.LEFT_BOTTOM,title_bar:getPositionX(), 55)
		:addTo(content)

	local location_info_label = UIKit:ttfLabel({
			text = _("坐标"),
			size = 20,
			color= 0x797154
		})
		:align(display.LEFT_BOTTOM,location_info_line:getPositionX(), location_info_line:getPositionY() + 2)
		:addTo(content)
	local location = data.location
	local location_info_val = UIKit:ttfLabel({
			text = location.x .. "," ..  location.y,
			size = 22,
			color= 0x403c2f
		})
		:align(display.RIGHT_BOTTOM,location_info_line:getPositionX()+location_info_line:getContentSize().width,location_info_label:getPositionY())
		:addTo(content)

	local button = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
		:addTo(content)
		:align(display.LEFT_BOTTOM, area_info_val:getPositionX() + 10, 15)
		:setButtonLabel("normal", UIKit:commonButtonLable({
			text = _("迁移")
		}))
		:onButtonClicked(function()
			self:OnMoveButtonClick(data.key,data.moveNeedHonour)
		end)
	local icon = display.newSprite("honour_128x128.png")
		:align(display.LEFT_BOTTOM,area_info_val:getPositionX() + 34, 70)
		:addTo(content)
		:scale(0.25)
	UIKit:ttfLabel({
		text = data.moveNeedHonour,
		size = 20,
		color= 0x423f32
		})
		:align(display.LEFT_CENTER,icon:getPositionX() + icon:getCascadeBoundingBox().width + 2, icon:getPositionY() + icon:getCascadeBoundingBox().width/2)
		:addTo(content)


	content:size(568,154)
	item:addContent(content)
	item:setItemSize(568, 154)
	return item
end

function GameUIMoveAllianceBuilding:OnMoveButtonClick(buildingKey,moveNeedHonour)
	if moveNeedHonour <= Alliance_Manager:GetMyAlliance():Honour() then
		NetManager:getMoveAllianceBuildingPromise(buildingKey,self.target_location.x,self.target_location.y)
			:next(function(msg)
				self:leftButtonClicked()
			end)
	else
		UIKit:showMessageDialog(nil, _("联盟荣誉值不足"),function()end)
	end
end

return GameUIMoveAllianceBuilding