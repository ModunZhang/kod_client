local CommonUpgradeUI = class("CommonUpgradeUI", function ()
    return display.newLayer()
end)

function CommonUpgradeUI:ctor(city,building)
    self:setNodeEventEnabled(true)
    self.city = city
    self.building = building
end

-- Node Event
function CommonUpgradeUI:onEnter()
    print("CommonUpgradeUI onEnter->")
    self:InitCommonPart()
end

function CommonUpgradeUI:onExit()
    print("CommonUpgradeUI onExit--->")
end

function CommonUpgradeUI:InitCommonPart()
    -- building level
    local level_bg = display.newSprite("upgrade_level_bg.png", display.cx, display.top-125):addTo(self)
    self.builging_level = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 26,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.RIGHT_BOTTOM, 540, 0)
        :addTo(level_bg)
    self:SetBuildingLevel()
    -- 建筑功能介绍
    local building_introduces_bg = display.newSprite("upgrade_introduce_bg.png", display.cx, display.top-190):addTo(self)
    self.building_image = display.newScale9Sprite(self.building:GetType()..".png", 0, 0):addTo(building_introduces_bg)
    self.building_image:setAnchorPoint(cc.p(0,0))
    self.building_image:setScale(164/self.building_image:getContentSize().height)
    self:SetBuildingIntroduces()
    --升级奖励部分
    -- title
    cc.ui.UIImage.new("upgrade_decoration.png"):align(display.CENTER, display.cx-145, display.top-260):addTo(self):setFlippedX(true)
    cc.ui.UIImage.new("upgrade_decoration.png"):align(display.CENTER, display.cx+145, display.top-260):addTo(self)
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("升级奖励"),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, display.cx, display.top-260)
        :addTo(self)
    -- reward list bg
    display.newScale9Sprite("upgrade_introduce_bg.png", display.cx, display.top-330, cc.size(549,100)):addTo(self)
    self:SetUpgradeReward()
end

function CommonUpgradeUI:SetBuildingLevel()
    self.builging_level:setString(_("等级 ")..self.building:GetLevel())
end

function CommonUpgradeUI:SetBuildingIntroduces()
    local building_introduces_table = {
        ["keep"] = _("提升建筑等级上限\n可解锁地块数量:%d"),
        ["watchTower"] ={
            [1] = _("能够看到来袭部队，NPC titles，自己的出征部队，告诉你前来的部队的行军目的，达到时间"),
            [2] = _("显示敌方突袭你部队的龙的类型(之前显示“?”)"),
            [3] = _("显示突袭的龙的等级"),
            [4] = _("显示进攻的龙的等级"),
            [5] = _("显示突袭的龙的装备信息"),
            [6] = _("显示进攻的龙的装备信息"),
            [7] = _("显示突袭的龙的技能信息"),
            [8] = _("显示进攻的龙的技能信息"),
            [9] = _("显示进攻部队的兵种类型和排序"),
            [10] = _("显示进攻部队的兵种星级"),
            [11] = _("可以在敌方领土上预警到敌方部队来袭(之前只会在敌方穿过传送门后才预警，现在还会显示传送门到敌方玩家城市的路径)"),
            [12] = _("可以查看突袭的龙的力量和活力属性"),
            [13] = _("可以查看进攻的龙的力量和活力属性"),
            [14] = _("显示进攻部队的大致数量"),
            [15] = _("显示进攻敌方的科技水平(训练营地，猎手大厅，马厩，车间的科技研发值)"),
            [16] = _("可以在敌方领地上查看敌方玩家的城市布局和建筑等级等信息(不能点击建筑)"),
            [17] = _("显示进攻部队兵种的准确数量"),
            [18] = _("显示敌方进攻部队的战斗力预估(之前显示“?”)"),
            [19] = _("减少敌方行军速度10%"),
            [20] = _("增加己方行军速度10%"),
        },
        ["warehouse"] = _("提供木材, 石料, 铁矿, 粮食存储上限\n资源存放上限%d"),
        ["dragonEyrie"] = _("提升龙的体力恢复速度\n体力恢复速度+%d"),
        ["toolShop"] = _("提升每次生产材料的数量\n材料数量%d"),
        ["materialDepot"] = _("提供材料的存储上限\n每种材料存放上限%d"),
        ["armyCamp"] = _("提供出兵时派兵上限\n派兵上限%d"),
        ["barracks"] = _("增加每次招募数量\n每次可招募%d"),
        ["blackSmith"] = _("提升装备打造速度\n装备打造速度+%d"),
        ["foundry"] = _("可建造矿工小屋%d\n铁矿产量+%d"),
        ["stoneMason"] = _("可建造石匠小屋%d\n石料产量+%d"),
        ["lumbermill"] = _("可建造木工小屋%d\n木材产量+%d"),
        ["mill"] = _("可建造农夫小屋%d\n粮食产量+%d"),
        ["hospital"] = _("增加治愈伤兵的人数上限\n伤兵人数上限%d"),
        ["townHall"] = _("可建造住宅%d\n每次税收影响城民%d"),
        ["academy"] = _("提升科技研发速度\n研发速度+%d"),
        ["trainingGround"] = _("提升步兵招募速度\n步兵招募速度+%d"),
        ["hunterhall"] = _("提升猎手招募速度\n猎手招募速度+%d"),
        ["stable"] = _("提升骑兵招募速度\n骑兵招募速度+%d"),
        ["workshop"] = _("提升攻城器械速度\n攻城器械招募速度+%d"),
        ["wall"] = _("提升城墙生命值\n城墙生命值+%d"),
        ["tower"] = _("提升城墙攻击力\n城墙攻击力+%d"),
        ["prison"] = _("捕获敌军的几率%d\n关押敌军的时间%d"),
        ["tradeGuild"] = _("运输小车总数%d\n运输小车生产速度%d"),
        ["dwelling"] = _("提供城民上限%d\n城民恢复速度+%d"),
        ["woodcutter"] = _("占用城民%d\n木材产量+%d/每小时"),
        ["farmer"] = _("占用城民%d\n粮食产量+%d/每小时"),
        ["quarrier"] = _("占用城民%d\n石料产量+%d/每小时|"),
        ["miner"] = _("占用城民%d\n铁矿产量+%d/每小时|"),
    }
    local building_introduces = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 22,
        dimensions = cc.size(400, 90),
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.left+180, display.top-190):addTo(self)
    if self.building:GetType()=="keep" then
        building_introduces:setString(string.format(building_introduces_table["keep"],self.building:GetUnlockPoint()))
    end
end

-- set upgrade reward
function CommonUpgradeUI:SetUpgradeReward()
	-- TODO 暂时模拟升级奖励类型和数据
	local reward_table = {
		{reward_type = "surface",icon="upgrade_surface.png",value="X 100"},
		{reward_type = "exp",icon="upgrade_experience_icon.png",value="X 10000"},
		{reward_type = "power",icon="upgrade_power_icon.png",value="X 1000000"},
	}
    local reward_listview_width ,reward_listview_height= 545,95
    local item_icon_height = 62
    local reward_listview = cc.ui.UIListView.new{
        -- bg = "common_tips_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.left+47, display.top-378, reward_listview_width, reward_listview_height),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL}
        :addTo(self)
    local function createItem(icon,value)
        local item = reward_listview:newItem()
        local content = cc.ui.UIGroup.new()
        local item_icon = display.newSprite(icon):align(display.CENTER, 0, 10)
        item_icon:setScale(item_icon_height/item_icon:getContentSize().height)
        item_icon:addTo(content)
        local num_label = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER,0,-item_icon_height/2):addTo(content)
        local content_width = math.max(num_label:getContentSize().width,item_icon:getContentSize().width*item_icon_height/item_icon:getContentSize().height)
    	item:setItemSize(content_width,num_label:getContentSize().height+item_icon_height+10)
        print(content:getCascadeBoundingBox().size.width,content:getCascadeBoundingBox().size.height,"==========")
        item:addContent(content)

        return item
    end
    local created_item_table = {}
    local used_width = 0
    for k,v in pairs(reward_table) do
    	local item = createItem(v.icon,v.value)
    	created_item_table[k] = item
    	local item_width = item:getItemSize()
    	used_width = used_width + item_width
    end
    -- 计算出合理的各个item之间的间距，再添加进listview
    local usable_width = reward_listview_width - used_width
    for k,v in pairs(created_item_table) do
    	local item_width,item_height = v:getItemSize()
    	print("  添加的节点数量=",#created_item_table,item_width,item_height,usable_width,item_width+usable_width/#created_item_table)
    	v:setItemSize(item_width+usable_width/#created_item_table,item_height)
    	reward_listview:addItem(v)
    end


    reward_listview:reload()

end
return CommonUpgradeUI







