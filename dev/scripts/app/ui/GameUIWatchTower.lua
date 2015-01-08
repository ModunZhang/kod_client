local Localize = import("..utils.Localize")
local GameUIWatchTower = UIKit:createUIClass('GameUIWatchTower',"GameUIUpgradeBuilding")
local AllianceBelvedere = import("..entity.AllianceBelvedere")
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UILib = import(".UILib")

function GameUIWatchTower:ctor(city,building)
    local bn = Localize.building_name
    GameUIWatchTower.super.ctor(self,city,bn[building:GetType()],building)
    self.belvedere = Alliance_Manager:GetMyAlliance():GetAllianceBelvedere()

end

function GameUIWatchTower:onEnter()
	GameUIWatchTower.super.onEnter(self)
	self:AddOrRemoveListener(true)
	self:CreateUI()
end

function GameUIWatchTower:GetTabButton()
	return self.tabButton
end


function GameUIWatchTower:CreateUI()
	local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0,0,window.width - 70, window.betweenHeaderAndTab - 10),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    },false)
	list_node:addTo(self)
	list_node:pos(window.left+35, window.bottom_top+20)
	self.list_node = list_node
	self.listView  = list
	self.tabButton = self:CreateTabButtons({
       	{
            label = _("来袭"),
            tag = "comming",
        },
        {
            label = _("进军"),
            tag = "march",
        }
    },
    function(tag)
        self:TabButtonsAction(tag)
    end):pos(window.cx, window.bottom + 34)
end

function GameUIWatchTower:TabButtonsAction(tag)
	if tag == 'comming' then
		self.list_node:show()
		self:RefreshListView(tag)
	elseif tag == 'march' then
		self.list_node:show()
		self:RefreshListView(tag)
	else
		self.list_node:hide()
	end
end

function GameUIWatchTower:AddOrRemoveListener(isAdd)
	if isAdd then
		City:AddListenOnType(self,City.LISTEN_TYPE.HELPED_TO_TROOPS)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnCommingDataChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged)
		self:GetAllianceBelvedere():AddListenOnType(self, AllianceBelvedere.LISTEN_TYPE.OnVillageEventTimer)
	else
		City:RemoveListenerOnType(self,City.LISTEN_TYPE.HELPED_TO_TROOPS)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnCommingDataChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnMarchDataChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnAttackMarchEventTimerChanged)
		self:GetAllianceBelvedere():RemoveListenerOnType(self, AllianceBelvedere.LISTEN_TYPE.OnVillageEventTimer)
	end
end


--ui
function GameUIWatchTower:RefreshListView(tag)
	self.listView:removeAllItems()
	if tag == 'march' then
		self:RefreshMyEvents()
	else
		self:RefreshOtherEvents()
	end
	self.listView:reload()
end


function GameUIWatchTower:RefreshMyEvents()
	local my_events = self:GetAllianceBelvedere():GetMyEvents()
	for index = 1,2 do
		local item
		if index == 1 then
			if my_events[1] then
				item = self:GetMyEventItemWithIndex(1,true,my_events[1])
			else
				item = self:GetMyEventItemWithIndex(1,true)
			end
		else
			if self:GetAllianceBelvedere():GetMarchLimit() == 1 then -- 只有一条队列
				item = self:GetMyEventItemWithIndex(2,false)
			else
				if my_events[2] then
					item = self:GetMyEventItemWithIndex(2,true,my_events[2])
				else
					item = self:GetMyEventItemWithIndex(2,true,nil)
				end
			end
		end
		self.listView:addItem(item)
	end
end
--data === nil and isOpen == true --->待命
function GameUIWatchTower:GetMyEventItemWithIndex(index,isOpen,entity)
	local item = self.listView:newItem()
	local bg = WidgetUIBackGround.new({width = 568,height = 204},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
	local title_bg  = display.newSprite("title_blue_558x34.png")
			:align(display.TOP_CENTER,284, 198)
			:addTo(bg)
	local tile_label = UIKit:ttfLabel({
			text = "",
			size = 20,
			color= 0xffedae,
		}):addTo(title_bg):align(display.LEFT_CENTER, 20, 17)
    local event_bg = display.newScale9Sprite("alliance_item_flag_box_126X126.png")
    	:size(134,134)
    	:addTo(bg)
    	:align(display.LEFT_BOTTOM, 10, 19)
	if not isOpen then
		tile_label:setString(_("未解锁"))
		WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
            :setButtonLabel(
               UIKit:commonButtonLable({
               		text = _("签到")
               })
            )
            :align(display.RIGHT_BOTTOM,555,10)
            :onButtonClicked(function(event)
                self:OnSignButtonClikced()
            end)
            :addTo(bg)
        UIKit:ttfLabel({
        	text = string.format(_("累计签到%s天，永久+1进攻队列"),"5/30"),
        	size = 22,
        	color= 0x403c2f
        }):addTo(bg):align(display.LEFT_TOP, 164, event_bg:getPositionY() + 104)
        display.newSprite(string.format("player_queue_seq_%d_112x112.png",index), 67, 67):addTo(event_bg)
	else
		if not entity then
			tile_label:setString(_("待命中"))
			WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
            :setButtonLabel(
               UIKit:commonButtonLable({
               		text = _("前往")
               })
            )
            :align(display.RIGHT_BOTTOM,555,10)
            :onButtonClicked(function(event)
                app:EnterMyAllianceScene()
            end)
            :addTo(bg)
	        UIKit:ttfLabel({
	        	text = _("去联盟领地搜索目标"),
	        	size = 22,
	        	color= 0x403c2f
	        }):addTo(bg):align(display.LEFT_TOP, 164, event_bg:getPositionY() + 104)
	        display.newSprite(string.format("player_queue_seq_%d_112x112.png",index), 67, 67):addTo(event_bg)
		else
			local desctition_label = UIKit:ttfLabel({
					text = _("目的地"),
					size = 20,
					color= 0x797154
				}):align(display.LEFT_TOP,164,153):addTo(bg)
			local line_1 = display.newScale9Sprite("dividing_line.png"):size(390,2):addTo(bg):align(display.LEFT_TOP,164, 125)
			local desctition_label_val =  UIKit:ttfLabel({
					text = entity:GetDestination(),
					size = 20,
					color= 0x797154
				}):align(display.RIGHT_TOP,554,153):addTo(bg)
			local localtion_label = UIKit:ttfLabel({
					text = _("坐标"),
					size = 20,
					color= 0x797154
				}):align(display.LEFT_TOP,164,115):addTo(bg)
			local line_2 = display.newScale9Sprite("dividing_line.png"):size(390,2):addTo(bg):align(display.LEFT_TOP,164, 87)
			local localtion_label_val =  UIKit:ttfLabel({
					text = entity:GetDestinationLocation(),
					size = 20,
					color= 0x797154
				}):align(display.RIGHT_TOP,554,115):addTo(bg)
			tile_label:setString(entity:GetTitle())
			if entity:GetTypeStr() == 'HELPTO' then
	            local button = self:GetYellowRetreatButton():pos(558,15):addTo(bg)
	            	:onButtonClicked(function(event)
		                entity:RetreatAction(function(success)
		                	if success then
		                		-- self:RefreshCurrentList()
		                		self:RefreshListView('march')
		                	end
		                end)
		            end)
		     	local dragon_png = UILib.dragon_head[entity:GetDragonType()]
		     	if dragon_png then
		     		local icon_bg = display.newSprite("dragon_bg_114x114.png", 67, 67):addTo(event_bg)
		     		display.newSprite(dragon_png, 57, 60):addTo(icon_bg)
		     	end
			elseif entity:GetTypeStr() == 'COLLECT' then
				self:GetYellowRetreatButton():pos(558,15):addTo(bg)
	            	:onButtonClicked(function(event)
		                entity:RetreatAction(function(success)
		                	if success then
		                		-- self:RefreshCurrentList()
		                		self:RefreshListView('march')
		                	end
		                end)
		            end)
			end
			--display data info
			--TODO:
		end
	end
	item:addContent(bg)
	item:setItemSize(568, 204)
	return item
end

function GameUIWatchTower:GetYellowRetreatButton()
	local button = WidgetPushButton.new({normal = "retreat_yellow_button_n_52x50.png",pressed = "retreat_yellow_button_h_52x50.png"})
		:align(display.RIGHT_BOTTOM,0,0)
	display.newSprite("retreat_button_icon_22x18.png", -26,25):addTo(button)
	return button
end

function GameUIWatchTower:RefreshOtherEvents()
	local other_events = self:GetAllianceBelvedere():GetOtherEvents()

end

function GameUIWatchTower:RefreshCurrentList()
	local tag = self:GetTabButton():GetSelectedButtonTag()
	if tag == 'comming' or tag == 'march' then
		self:RefreshListView(tag)
	end
end

function GameUIWatchTower:GetItem()
	local item = self.listView:newItem()
	local bg = WidgetUIBackGround.new({width = 568,height = 204},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
	item:addContent(bg)
	item:setItemSize(568, 204)
	return item
end

--Observer Methods
function GameUIWatchTower:OnHelpToTroopsChanged(changed_map)
	print("GameUIWatchTower:OnHelpToTroopsChanged--->")
end

function GameUIWatchTower:OnCommingDataChanged()
	print("GameUIWatchTower:OnCommingDataChanged-->")
end

function GameUIWatchTower:OnMarchDataChanged()
	print("GameUIWatchTower:OnMarchDataChanged-->")
end

function GameUIWatchTower:OnAttackMarchEventTimerChanged(attackMarchEvent)
	print("GameUIWatchTower:OnAttackMarchEventTimerChanged-->")
end

function GameUIWatchTower:OnVillageEventTimer(villageEvent)
	print("GameUIWatchTower:OnVillageEventTimer-->")
end

function GameUIWatchTower:onCleanup()
	self:AddOrRemoveListener(false)
	GameUIWatchTower.super.onCleanup(self)
end

function GameUIWatchTower:GetAllianceBelvedere()
	return self.belvedere
end

--event

function GameUIWatchTower:OnSignButtonClikced()
end

return GameUIWatchTower