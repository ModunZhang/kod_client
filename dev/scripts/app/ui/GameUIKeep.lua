local TabButtons = import('.TabButtons')
local GameUIKeep = UIKit:createUIClass('GameUIKeep',"GameUIUpgradeBuilding")

function GameUIKeep:ctor(city,building)
    GameUIKeep.super.ctor(self,city,_("城堡"),building)
    -- self.city = city
    -- self.building = building
end

function GameUIKeep:CreateBetweenBgAndTitle()
    GameUIKeep.super.CreateBetweenBgAndTitle(self)

    -- 加入城堡info_layer
    self.info_layer = display.newLayer()
    self:addChild(self.info_layer)
end

function GameUIKeep:onEnter()
    GameUIKeep.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "info",
        },
    },{
        ["info"] = self.info_layer
    }):pos(display.cx, display.bottom + 40)
    self:CreateCanBeUnlockedBuildingBG()
    self:CreateCanBeUnlockedBuildingListView()
    self:CreateCityBasicInfo()
end


function GameUIKeep:CreateCityBasicInfo()
    -- city icon bg
    cc.ui.UIImage.new("keep_city_icon_bg.png")
        :align(display.TOP_LEFT, display.left+46, display.top-120)
        :addTo(self.info_layer)
    -- city icon
    cc.ui.UIImage.new("keep_city_icon.png")
        :align(display.TOP_LEFT, display.left+52, display.top-127)
        :addTo(self.info_layer)
    -- 修改城市名字道具拥有数量显示背景框
    local change_city_name_prop_bg = cc.ui.UIImage.new("LV_background.png")
        :align(display.TOP_LEFT, display.left+46, display.top-235)
        :addTo(self.info_layer)
    local bg_width, bg_height = change_city_name_prop_bg:getCascadeBoundingBox().size.width,
        change_city_name_prop_bg:getCascadeBoundingBox().size.height
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("未定义"),
            font = UIKit:getFontFilePath(),
            size = 18,
            color = UIKit:hex2c3b(0xf403c2f)
        }):align(display.CENTER, bg_width/2, bg_height/2)
        :addTo(change_city_name_prop_bg)
    -- 城市名字
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("城市名字"),
            font = UIKit:getFontFilePath(),
            size = 16,
            color = UIKit:hex2c3b(0x665f49)
        }):align(display.CENTER, display.left+200, display.top-130)
        :addTo(self.info_layer)
    self.city_name_label  = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("未定义"),
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x29261c)
        }):align(display.LEFT_CENTER, display.left+167, display.top-160)
        :addTo(self.info_layer)
    self.change_city_name_button = cc.ui.UIPushButton.new({normal = "green_button_normal.png",pressed = "green_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("修改"), size = 20, color = display.COLOR_WHITE}))
        :onButtonClicked(function(event)
            print("使用道具改变城市名字未实现")
        end)
        :align(display.CENTER, display.right-120, display.top-136)
        :addTo(self.info_layer)
    -- 分割线
    local terrain_line = display.newScale9Sprite("dividing_line.png", display.right-260, display.top-216, cc.size(display.width-213,2))
        :addTo(self.info_layer)
    -- 地形标签
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("地形"),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 0, 12)
        :addTo(terrain_line)
    -- 玩家城市所处地形属性值
    self.terrain = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("未匹配服务器值"),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.RIGHT_CENTER, terrain_line:getCascadeBoundingBox().size.width, 12)
        :addTo(terrain_line)
    -- 分割线
    local location_line = display.newScale9Sprite("dividing_line.png", display.right-260, display.top-260, cc.size(display.width-213,2))
        :addTo(self.info_layer)

    -- 坐标标签
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("坐标"),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 0, 12)
        :addTo(location_line)
    -- 玩家城市坐标值
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("未匹配服务器值"),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.RIGHT_CENTER, location_line:getCascadeBoundingBox().size.width, 12)
        :addTo(location_line)
end

function GameUIKeep:CreateCanBeUnlockedBuildingBG()
    -- 主背景
    self.main_building_listview_bg = display.newScale9Sprite("keep_unlock_building_listview_bg.png", display.cx, display.bottom+116, cc.size(display.width-91, display.height-409))
        :addTo(self.info_layer)
    self.main_building_listview_bg:setAnchorPoint(cc.p(0.5,0))
    -- title 背景
    local title_bg = cc.ui.UIImage.new("keep_blue_title.png")
        :align(display.LEFT_TOP, 1, self.main_building_listview_bg:getCascadeBoundingBox().size.height)
        :addTo(self.main_building_listview_bg,10)
    -- title label
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("可解锁建筑"),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)})
        :align(display.CENTER, title_bg:getCascadeBoundingBox().size.width/2,title_bg:getCascadeBoundingBox().size.height/2)
        :addTo(title_bg)
    -- tips
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("提示:升级瞭望塔等级,可以获得更详细的敌军部队信息"),
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)})
        :align(display.CENTER, display.cx,display.bottom+90)
        :addTo(self.info_layer)
end

function GameUIKeep:CreateCanBeUnlockedBuildingListView()
    local building_introduces = {
        ["keep"] = _("城堡是权利的象征，城市的核心建筑，升级能够解锁更多的地块，提供更高的建筑等级。"),
        ["watchTower"] = _("瞭望塔可以让你查看到自己部队的情况，并提供敌方来袭时的信息，等级越高信息越详细。"),
        ["warehouse"] = _("资源仓库存放木材，石料，铁矿，粮食。等级越高，每种资源存放的上限越大。"),
        ["dragonEyrie"] = _("龙巢可以查看龙的信息，强化龙的装备并晋级。升级能够提升龙的体力恢复速度。"),
        ["toolShop"] = _("工具作坊提供常用材料的制作，升级能够提升每次制作的工具数量。"),
        ["materialDepot"] = _("材料库房能够存储各种材料，等级越高，每种材料的存放上限越高。"),
        ["armyCamp"] = _("军帐提供出兵时的带兵上限，等级越高，每次出兵和防御时可派出的部队人口上限越大。"),
        ["barracks"] = _("兵营提供军事单位的招募，将城民转换成各种作战单位。升级提升每次招募的最大数量。"),
        ["blackSmith"] = _("铁匠铺打造和强化龙的装备。升级建筑提升装备打造速度。"),
        ["foundry"] = _("铸造坊提升可建造的矿工小屋和铁矿生产效率。周围建立更多的矿工小屋，可获得额外的铁矿产量。"),
        ["stoneMason"] = _("石匠作坊提升可建造的石匠小屋和石料的生产效率。周围建立更多的石匠小屋，可获得额外的石料产量。"),
        ["lumbermill"] = _("锯木坊提升可建造的木工小屋和木材生产效率。周围建立更多的木工小屋，可获得额外的木材产量。"),
        ["mill"] = _("磨坊提升可建造的农夫小屋和粮食生产效率。周围建立更多的农夫小屋，可获得额外的粮食产量。"),
        ["hospital"] = _("医院提供治愈伤兵的功能，升级能够提升伤兵的最大容量。"),
        ["townHall"] = _("市政厅提升可建造的住宅的数量，并提升城民的增长速度。周围建立更多的住宅，可获得额外的城民增长。"),
        ["academy"] = _("学院提供的科技能够提升城市生产和防御能力，等级越过研发速度越快。"),
    }

    -- unlock building listview
    self.building_listview = cc.ui.UIListView.new{
        -- bg = "common_tips_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.left+47, display.bottom+118, 545, display.height-460),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self.info_layer)
    local allBuildings = City:GetAllBuildings()
    for i,v in ipairs(allBuildings) do
        local item = self.building_listview:newItem()
        item:setItemSize(540, 135)
        local item_width, item_height = item:getItemSize()
        local content = cc.ui.UIGroup.new()
        local flag = false
        -- 建筑是否可解锁 ，或者已经解锁
        if v:GetLevel()>=1 then
            flag = true
            -- 已解锁
            local unlocked_label = cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = _("已解锁"),
                font = UIKit:getFontFilePath(),
                size = 24,
                color = UIKit:hex2c3b(0x403c2f)}):align(display.CENTER_RIGHT, 260, 40):addTo(content,10)
        elseif City:IsTileCanbeUnlockAt(City:GetTileWhichBuildingBelongs(v).x,City:GetTileWhichBuildingBelongs(v).y) then
            flag = true
            cc.ui.UIPushButton.new({normal = "keep_unlocked_button_normal.png",pressed = "keep_unlocked_button_pressed.png"})
                :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("可解锁"), size = 24, color = display.COLOR_WHITE}))
                :onButtonClicked(function(event)
                    self:leftButtonClicked()
                    goto_logic(v:GetLogicPosition())
                end):align(display.CENTER, 190, 40):addTo(content, 10)
        end
        if flag then
            content:addWidget(display.newSprite("keep_building_element_bg.png",  0, 0))
            -- building name
            content:addWidget(cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = _(v:GetType()),
                font = UIKit:getFontFilePath(),
                size = 24,
                dimensions = cc.size(384, 35),
                color = UIKit:hex2c3b(0x403c2f)}):align(display.CENTER_LEFT, -120, 40))
            -- building introduce
            local building_tip = cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = building_introduces[v:GetType()],
                font = UIKit:getFontFilePath(),
                size = 20,
                aglin = ui.TEXT_ALIGN_LEFT,
                valign = ui.TEXT_VALIGN_CENTER,
                dimensions = cc.size(384, 65),
                color = UIKit:hex2c3b(0x797154)}):align(display.TOP_LEFT, -120, 10)
            content:addWidget(building_tip)
            local building_image = display.newScale9Sprite(v:GetType()..".png", -item_width/2+70, 0)
            building_image:setScale(133/building_image:getContentSize().height)
            content:addWidget(building_image)
            item:addContent(content)
            self.building_listview:addItem(item)
        end
    end
    self.building_listview:reload()
end

return GameUIKeep


