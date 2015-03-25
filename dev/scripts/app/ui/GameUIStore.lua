--
-- Author: Danny He
-- Date: 2015-03-24 16:04:35
--
local GameUIStore = UIKit:createUIClass("GameUIStore", "GameUIWithCommonHeader")
local UIListView = import(".UIListView")
local window = import("..utils.window")
local config_store = GameDatas.StoreItems.items

function GameUIStore:ctor()
	GameUIStore.super.ctor(self,City,_("获得金龙币"))
end

function GameUIStore:OnMoveInStage()
	GameUIStore.super.OnMoveInStage(self)
	self:CreateUI()
end

function GameUIStore:CreateUI()
	self.listView = UIListView.new({
		bgColor = cc.c4b(13,17,19,255),
        viewRect = cc.rect((window.width - 610)/2, window.bottom + 14, 610,window.betweenHeaderAndTab + 90),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
	}):addTo(self:GetView())
	self:RefreshListView()
end

function GameUIStore:GetStoreData()
	local data = {}
	for __,v in ipairs(config_store) do
		local temp_data = {}
		temp_data['productId'] = v.productId
		temp_data['price'] = string.format("%.2f",v.price)
		temp_data['gem'] = v.gem
		temp_data['name'] = v.name
		temp_data['order'] = v.order
		temp_data['rewards'] = self:FormatGemRewards(v.rewards)
		table.insert(data,temp_data)
	end
	return data
end

function GameUIStore:FormatGemRewards(rewards)
	local result_rewards = {}
	local all_rewards = string.split(rewards, ",")
	for __,v in ipairs(all_rewards) do
		local one_reward = string.split(v,":")
		local category,key,count = unpack(one_reward)
		table.insert(result_rewards,{category = category,key = key,count = count})
	end
	return result_rewards
end

function GameUIStore:RefreshListView()
	self.listView:removeAllItems()
	local data = self:GetStoreData()
	for __,v in ipairs(data) do
		local item = self:GetItem(v)
		self.listView:addItem(item)
	end
	self.listView:reload()
end

function GameUIStore:GetItem(data)
	local item = self.listView:newItem()
	local content_image = "store_item_black_610x514.png"

	if data.order == 1 or data.order == 5 then
		content_image = "store_item_red_610x514.png"
	end
	local content = display.newSprite(content_image)
	
	UIKit:ttfLabel({
		text = data.name,
		color= 0xfed36c,
		size = 24
	}):align(display.CENTER_TOP, 305, 495):addTo(content)

	local logo = display.newSprite(string.format("gem_logo_592x139_%d.png",data.order)):align(display.CENTER_TOP, 305, 450):addTo(content)
	item:addContent(content)
	item:setItemSize(610, 514)
	return item
end

function GameUIStore:RightButtonClicked()
end

return GameUIStore