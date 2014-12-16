local cocos_promise = import('..utils.cocos_promise')
local promise = import('..utils.promise')
local TabButtons = import('.TabButtons')
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2= import("..widget.WidgetUIBackGround2")
local FullScreenPopDialogUI= import(".FullScreenPopDialogUI")
local Localize = import("..utils.Localize")
local window = import('..utils.window')
local GameUIKeep = UIKit:createUIClass('GameUIKeep',"GameUIUpgradeBuilding")

local building_config_map = {
    ["keep"] = {scale = 0.15, offset = {x = 10, y = -10}},
    ["watchTower"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["warehouse"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["dragonEyrie"] = {scale = 0.2, offset = {x = 0, y = -10}},
    ["toolShop"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["materialDepot"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["armyCamp"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["barracks"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["blackSmith"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["foundry"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["stoneMason"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["lumbermill"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["mill"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["hospital"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["townHall"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["tradeGuild"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["academy"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["prison"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["hunterHall"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["trainingGround"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["stable"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["workShop"] = {scale = 0.2, offset = {x = 10, y = -10}},
    ["wall"] = {scale = 0.4, offset = {x = 0, y = -10}},
    ["tower"] = {scale = 1, offset = {x = 0, y = -10}},
    --
    ["dwelling"] = {scale = 0.35, offset = {x = 0, y = -10}},
    ["farmer"] = {scale = 0.35, offset = {x = 0, y = -10}},
    ["woodcutter"] = {scale = 0.35, offset = {x = 0, y = -10}},
    ["quarrier"] = {scale = 0.35, offset = {x = 0, y = -10}},
    ["miner"] = {scale = 0.35, offset = {x = 0, y = -10}},
}

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
    }, function(tag)
        if tag == 'info' then
            self.info_layer:setVisible(true)
        else
            self.info_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
    self:CreateCanBeUnlockedBuildingBG()
    self:CreateCanBeUnlockedBuildingListView()
    self:CreateCityBasicInfo()
    self.city:AddListenOnType(self, City.LISTEN_TYPE.CITY_NAME)

end
function GameUIKeep:OnCityNameChanged(cityName)
    self.city_name_item:SetValue(cityName)
end
function GameUIKeep:onExit()
    self.city:RemoveListenerOnType(self, City.LISTEN_TYPE.CITY_NAME)
    GameUIKeep.super.onExit(self)
end

function GameUIKeep:CreateCityBasicInfo()

    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-250, display.top-175)
        :addTo(self.info_layer):setFlippedX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, display.cx-145, display.top-175)
        :addTo(self.info_layer)

    local building_image = display.newSprite(UIKit:getImageByBuildingType( self.building:GetType() ,self.building:GetLevel()), 0, 0)
        :addTo(self.info_layer):pos(display.cx-196, display.top-158)
    building_image:setAnchorPoint(cc.p(0.5,0.5))
    if self.building:GetType()=="watchTower" or self.building:GetType()=="tower" then
        building_image:setScale(150/building_image:getContentSize().height)
    else
        building_image:setScale(124/building_image:getContentSize().width)
    end
    -- 修改城市名字item
    self.city_name_item = self:CreateLineItem({
        title_1 =  _("城市名字"),
        title_2 =  City:GetCityName(),
        button_label =  _("修改"),
        listener =  function ()
            self:CreateModifyCityNameWindow()
        end,
    }):align(display.LEFT_CENTER, display.cx-120, display.top-160)
        :addTo(self.info_layer)
    -- 修改地形
    self:CreateLineItem({
        title_1 =  _("城市地形"),
        title_2 =  _("草原"),
        button_label =  _("修改"),
        listener =  function ()
            self:CreateChangeTerrainWindow()
        end,
    }):align(display.LEFT_CENTER, display.cx-120, display.top-240)
        :addTo(self.info_layer)
end

function GameUIKeep:CreateLineItem(params)
    -- 分割线
    local line = display.newSprite("dividing_line.png")
    local line_size = line:getContentSize()
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = params.title_1,
            font = UIKit:getFontFilePath(),
            size = 16,
            color = UIKit:hex2c3b(0x665f49)
        }):align(display.LEFT_BOTTOM, 0, 40)
        :addTo(line)
    local value_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = params.title_2,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x29261c)
        }):align(display.LEFT_BOTTOM, 0, 10)
        :addTo(line)
    local button = WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = params.button_label,
            size = 20,
            color = 0xffedae,
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                params.listener()
            end
        end)
        :align(display.RIGHT_BOTTOM, line_size.width, 5)
        :addTo(line)
    function line:SetValue(value)
        value_label:setString(value)
    end
    return line
end

function GameUIKeep:CreateCanBeUnlockedBuildingBG()
    -- 主背景
    -- self.main_building_listview_bg = WidgetUIBackGround.new({
    --     width = 538,
    --     height = 508,
    --     top_img = "back_ground_538x14_top.png",
    --     bottom_img = "back_ground_538x20_bottom.png",
    --     mid_img = "back_ground_538x1_mid.png",
    --     u_height = 14,
    --     b_height = 20,
    --     m_height = 1,
    -- }):align(display.CENTER, display.cx, display.top-824)
    --     :addTo(self.info_layer)
    -- -- display.newScale9Sprite("keep_unlock_building_listview_bg.png", display.cx, display.top-844, cc.size(549, 551))

    -- self.main_building_listview_bg:setAnchorPoint(cc.p(0.5,0))
    -- -- title 背景
    -- local title_bg = cc.ui.UIImage.new("alliance_evnets_title_548x50.png")
    --     :align(display.LEFT_BOTTOM, -5, self.main_building_listview_bg:getContentSize().height)
    --     :addTo(self.main_building_listview_bg,10)
    -- title label
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("可解锁建筑"),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0x403c2f)})
        :align(display.CENTER,window.cx, window.bottom_top+600)
        :addTo(self.info_layer)
    -- tips
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("提示:升级城堡获得解锁建筑机会!"),
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)})
        :align(display.CENTER, display.cx,display.top-850)
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
        ["tradeGuild"] = _("贸易行会提供玩家资源和材料的交易平台。消耗运输小车挂出自己的资源需求，升级提升运输小车总量和生产速度。"),

    }

    -- unlock building listview
    -- self.building_listview = cc.ui.UIListView.new{
    --     -- bg = "common_tips_bg.png",
    --     bgScale9 = true,
    --     viewRect = cc.rect(self.main_building_listview_bg:getContentSize().width/2-258, 10, 516, 495),
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
    --     :addTo(self.main_building_listview_bg)
    self.building_listview ,self.listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 0, 568, 495),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    self.listnode:addTo(self.info_layer):pos(window.cx,window.bottom_top + 60)
    self.listnode:align(display.BOTTOM_CENTER)
    local buildings = GameDatas.Buildings.buildings
    for i,v in ipairs(buildings) do
        if v.location<17 then
            local unlock_building = City:GetBuildingByLocationId(v.location)
            local b_x,b_y =City:GetTileWhichBuildingBelongs(unlock_building).x,City:GetTileWhichBuildingBelongs(unlock_building).y
            -- 建筑是否可解锁
            local canUnlock = City:IsTileCanbeUnlockAt(b_x,b_y)
            -- 建筑已经解锁
            local isUnlocked = City:IsUnLockedAtIndex(b_x,b_y)
            if canUnlock or  isUnlocked then
                local item = self.building_listview:newItem()
                item:setItemSize(568, 144)
                local item_width, item_height = item:getItemSize()
                local content = cc.ui.UIGroup.new()
                content:addWidget( WidgetUIBackGround.new({
                    width = 568,
                    height = 142,
                    top_img = "back_ground_568x16_top.png",
                    bottom_img = "back_ground_568x80_bottom.png",
                    mid_img = "back_ground_568x28_mid.png",
                    u_height = 16,
                    b_height = 80,
                    m_height = 28,
                }):align(display.CENTER))
                local title_bg = display.newSprite("title_blue_412x30.png"):pos(70,50)
                content:addWidget(title_bg)
                -- building name
                UIKit:ttfLabel({
                    text = _(Localize.building_name[unlock_building:GetType()]),
                    size = 22,
                    color = 0xffedae}):align(display.CENTER_LEFT, 10, title_bg:getContentSize().height/2)
                    :addTo(title_bg)
                if canUnlock then

                    WidgetPushButton.new({normal = "dragon_next_icon_28x31.png",pressed = "dragon_next_icon_28x31.png"})
                        -- :setButtonLabel(UIKit:ttfLabel({
                        --     text = _("可解锁"),
                        --     size = 24,
                        --     color = 0xffedae,
                        -- }))
                        :onButtonClicked(function(event)
                            if event.name == "CLICKED_EVENT" then
                                self:leftButtonClicked()
                                display.getRunningScene():GotoLogicPoint(unlock_building:GetLogicPosition())
                            end
                        end):align(display.CENTER, 260, 0):addTo(content, 10)
                end

                UIKit:ttfLabel({
                    text = canUnlock and _("未解锁") or _("已解锁"),
                    size = 22,
                    color = canUnlock and 0xffedae or 0x0db13c}):align(display.CENTER_RIGHT, title_bg:getContentSize().width-30, title_bg:getContentSize().height/2)
                    :addTo(title_bg)

                -- building introduce
                local building_tip = cc.ui.UILabel.new({
                    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = building_introduces[unlock_building:GetType()],
                    font = UIKit:getFontFilePath(),
                    size = 20,
                    aglin = ui.TEXT_ALIGN_LEFT,
                    valign = ui.TEXT_VALIGN_CENTER,
                    dimensions = cc.size(354, 65),
                    color = UIKit:hex2c3b(0x797154)}):align(display.TOP_LEFT, -120, 10)
                content:addWidget(building_tip)

                -- 建筑图片 放置区域左右边框
                local filp_bg = cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, -item_width/2+20, 0)
                filp_bg:setFlippedX(true)
                content:addWidget(filp_bg)
                content:addWidget(cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, -item_width/2+115, 0))
                local building_image = display.newScale9Sprite(UIKit:getImageByBuildingType( unlock_building:GetType() ,unlock_building:GetLevel()), -item_width/2+70, 0)
                    :scale(building_config_map[unlock_building:GetType()].scale)
                content:addWidget(building_image)
                -- 边框
                -- local bg_1 =display.newScale9Sprite("vip_bg_3.png", -item_width/2+135, 0,cc.size(376,126)):align(display.LEFT_CENTER)
                -- content:addWidget(bg_1)
                item:addContent(content)
                self.building_listview:addItem(item)
            end
        end
    end
    self.building_listview:reload()
end

function GameUIKeep:CreateModifyCityNameWindow()
    local layer = self:CreateBackGroundWithTitle(_("城市名称修改")):addTo(self)
    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(576,48),
        font = UIKit:getFontFilePath(),
    })
    editbox:setPlaceHolder(_("输入新的城市名字"))
    editbox:setMaxLength(14)
    editbox:setFont(UIKit:getFontFilePath(),22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.LEFT_TOP,16, 420)
    layer:addToBody(editbox)

    local bg2 = WidgetUIBackGround2.new(140)
    layer:addToBody(bg2):align(display.CENTER, 304, 280)

    local prop_bg = display.newSprite("background_prop_100_100.png")
        :align(display.LEFT_CENTER, 10, 82):addTo(bg2)
    display.newSprite("change_city_name.png")
        :align(display.CENTER, 50, 50):addTo(prop_bg):scale(0.5)
    local num_bg = display.newSprite("number_bg_100x40.png")
        :align(display.CENTER_TOP, 50, 12):addTo(prop_bg)
    self.number = cc.ui.UILabel.new({
        size = 20,
        text = "10000",
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x423f32)
    }):addTo(num_bg):align(display.CENTER, 50, 20)

    local label_1 = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("城市名称变更"),
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x514d3e)
        }):align(display.LEFT_CENTER, 120, 100)
        :addTo(bg2)

    local label_2 = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("提供兵种招募，升级增加每次招募的最大数量"),
            font = UIKit:getFontFilePath(),
            size = 20,
            dimensions = cc.size(300,100),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_TOP, 120, 70)
        :addTo(bg2)
    -- 购买使用按钮
    local buy_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("购买使用"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})

    buy_label:enableShadow()
    WidgetPushButton.new(
        {normal = "green_btn_up_142x39.png", pressed = "green_btn_down_142x39.png"},
        {scale9 = false}
    ):setButtonLabel(buy_label)
        :addTo(bg2):align(display.CENTER, 480, 100)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local cityName = string.trim(editbox:getText())
                if string.len(cityName) == 0 then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("请输入城市名称"))
                        :CreateOKButton(function()end)
                        :AddToCurrentScene()
                    return
                end
                NetManager:getEditPlayerCityNamePromise(cityName)
                layer:removeFromParent(true)
            end
        end)
end

function GameUIKeep:CreateChangeTerrainWindow()
    local layer = self:CreateBackGroundWithTitle(_("城市地形修改")):addTo(self)
    local bg1 = WidgetUIBackGround.new({
        width = 580,
        height = 264,
        top_img = "back_ground_580x12_top.png",
        bottom_img = "back_ground_580X12_bottom.png",
        mid_img = "back_ground_580X1_mid.png",
        u_height = 12,
        b_height = 12,
        m_height = 1,
    }):align(display.CENTER,304, 294)

    layer:addToBody(bg1)

    self.terrain_eff_label = cc.ui.UILabel.new({
        size = 18,
        text = "草地地形能提升50% 绿龙的活力回复速度",
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x514d3e)
    }):addTo(bg1):align(display.CENTER,304,30)

    -- 草地
    display.newSprite("grass_ground1_800x560.png")
        :align(display.CENTER, 110, 180):addTo(bg1):scale(0.2)
    -- 雪地
    display.newSprite("desert1_800x560.png")
        :align(display.CENTER, 295, 180):addTo(bg1):scale(0.2)
    -- 沙漠
    display.newSprite("icefield1_800x560.png")
        :align(display.CENTER, 485, 180):addTo(bg1):scale(0.2)

    local checkbox_image = {
        off = "checkbox_unselected.png",
        off_pressed = "checkbox_unselected.png",
        off_disabled = "checkbox_unselected.png",
        on = "checkbox_selectd.png",
        on_pressed = "checkbox_selectd.png",
        on_disabled = "checkbox_selectd.png",

    }
    local group = cc.ui.UICheckBoxButtonGroup.new(display.LEFT_TO_RIGHT):addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
        :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
            :align(display.LEFT_CENTER))
        :addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
            :align(display.LEFT_CENTER))
        :setButtonsLayoutMargin(0, 130, 0, 0)
        :onButtonSelectChanged(function(event)
            -- self.selected_rebuild_to_building = rebuild_list[event.selected]
            end)
        :align(display.CENTER, 80 , 50)
        :addTo(bg1)
    group:getButtonAtIndex(1):setButtonSelected(true)

    local bg2 = WidgetUIBackGround2.new(140)
    layer:addToBody(bg2):align(display.CENTER, 304, 84)

    local prop_bg = display.newSprite("background_prop_100_100.png")
        :align(display.LEFT_CENTER, 10, 82):addTo(bg2)
    display.newSprite("change_city_name.png")
        :align(display.CENTER, 50, 50):addTo(prop_bg):scale(0.5)
    local num_bg = display.newSprite("number_bg_100x40.png")
        :align(display.CENTER_TOP, 50, 12):addTo(prop_bg)
    local gem_img = display.newSprite("gem_66x56.png")
        :align(display.LEFT_CENTER, 10, 20):addTo(num_bg):scale(0.4)
    self.number = cc.ui.UILabel.new({
        size = 20,
        text = "500",
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x423f32)
    }):addTo(num_bg):align(display.LEFT_CENTER,40,20)

    local label_1 = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("变换地形"),
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x514d3e)
        }):align(display.LEFT_CENTER, 120, 100)
        :addTo(bg2)

    local label_2 = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("提供兵种招募，升级增加每次招募的最大数量"),
            font = UIKit:getFontFilePath(),
            size = 20,
            dimensions = cc.size(300,100),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_TOP, 120, 70)
        :addTo(bg2)
    -- 回复按钮
    local buy_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("购买使用"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})

    buy_label:enableShadow()
    WidgetPushButton.new(
        {normal = "green_btn_up_142x39.png", pressed = "green_btn_down_142x39.png"},
        {scale9 = false}
    ):setButtonLabel(buy_label)
        :addTo(bg2):align(display.CENTER, 480, 100)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
            end
        end)
end

function GameUIKeep:CreateBackGroundWithTitle(title_string)
    local leyer = display.newColorLayer(cc.c4b(0,0,0,127))
    local body = WidgetUIBackGround.new({height=450}):align(display.TOP_CENTER,display.cx,display.top-200)
        :addTo(leyer)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height)
        :addTo(body)
    local title_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = title_string,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2)
        :addTo(title)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            leyer:removeFromParent()
        end):align(display.CENTER, title:getContentSize().width-10, title:getContentSize().height-10)
        :addTo(title)
    function leyer:addToBody(node)
        node:addTo(body)
        return node
    end
    return leyer
end



---
function GameUIKeep:Find()
    return cocos_promise.deffer(function()
        return self.upgrade_layer.upgrade_btn
    end)
end







return GameUIKeep











