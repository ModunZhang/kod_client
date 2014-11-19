local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetBuyGoods = import("..widget.WidgetBuyGoods")
local WidgetStockGoods = import("..widget.WidgetStockGoods")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIOrderHall = UIKit:createUIClass('GameUIOrderHall', "GameUIAllianceBuilding")
local Flag = import("..entity.Flag")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Localize = import("..utils.Localize")


function GameUIOrderHall:ctor(city,default_tab,building)
    GameUIOrderHall.super.ctor(self, city, _("秩序大厅"),default_tab,building)
    self.default_tab = default_tab
    self.building = building
end

function GameUIOrderHall:onEnter()
    GameUIOrderHall.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("村落管理"),
            tag = "village",
            default = "village" == self.default_tab,
        },
        {
            label = _("熟练度"),
            tag = "proficiency",
            default = "proficiency" == self.default_tab,
        },
    }, function(tag)
        if tag == 'village' then
            self.village_layer:setVisible(true)
        else
            self.village_layer:setVisible(false)
        end
        if tag == 'proficiency' then
            self.proficiency_layer:setVisible(true)
        else
            self.proficiency_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
    self:InitVillagePart()
    self:InitProficiencyPart()
end
function GameUIOrderHall:CreateBetweenBgAndTitle()
    GameUIOrderHall.super.CreateBetweenBgAndTitle(self)

    -- village_layer
    self.village_layer = display.newLayer()
    self:addChild(self.village_layer)
    -- proficiency_layer
    self.proficiency_layer = display.newLayer()
    self:addChild(self.proficiency_layer)
end

function GameUIOrderHall:InitVillagePart()
    self.village_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-304, display.top-880, 608, 780),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.village_layer)
    self:CreateVillageItem()
    self:CreateVillageItem()
    self.village_listview:reload()

end

function GameUIOrderHall:CreateVillageItem()
    local item = self.village_listview:newItem()
    local item_width,item_height = 608 , 220
    item:setItemSize(item_width, item_height)
    local content = WidgetUIBackGround.new({height=210})
    display.newSprite("back_ground_606x16.png"):align(display.CENTER, item_width/2, 200):addTo(content)
    display.newSprite("back_ground_606x16.png"):align(display.CENTER, item_width/2, 10):addTo(content):flipY(true)
    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.LEFT_CENTER, 30, 120)
        :addTo(content):flipX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.RIGHT_CENTER, 163, 120)
        :addTo(content)

    local building_image = display.newSprite("farmer_1_315x281.png")
        :addTo(content):pos(95, 120)
    building_image:setAnchorPoint(cc.p(0.5,0.5))
    building_image:setScale(113/building_image:getContentSize().height)
    local level_bg = display.newSprite("back_ground_138x34.png")
        :addTo(content):pos(96, 34)
    UIKit:ttfLabel({
        text = "Level 20",
        size = 20,
        color = 0x514d3e,
    }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height/2)
        :addTo(level_bg)
    -- 村落名字
    local title_bg = display.newSprite("title_blue_402x48.png")
        :align(display.LEFT_CENTER, 170, 175)
        :addTo(content)
    UIKit:ttfLabel({
        text = "木材村落",
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 20 , title_bg:getContentSize().height/2)
        :addTo(title_bg)
    -- 村落介绍
    UIKit:ttfLabel({
        text = "提升木材村落的产量,同时也增加了放逐者的战斗力",
        size = 20,
        color = 0x797154,
        dimensions = cc.size(400,0)
    }):align(display.LEFT_TOP, 170 , 150)
        :addTo(content)

    -- 荣耀值
    display.newSprite("honour.png"):align(display.CENTER, 200, 40):addTo(content)
    local honour_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER, 300, 40):addTo(content)
    self.loyalty_label = UIKit:ttfLabel({
        text = "10000",
        size = 20,
        color = 0x403c2f,
    }):addTo(honour_bg):align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)
    -- 升级按钮
    WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("升级"),
            size = 22,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER, 500, 40):addTo(content)


    item:addContent(content)
    self.village_listview:addItem(item)
end

function GameUIOrderHall:InitProficiencyPart()
    local desc_bg = WidgetUIBackGround2.new(106):align(display.TOP_CENTER, window.cx, window.top - 110)
        :addTo(self.proficiency_layer)
        :scale(0.9)
    UIKit:ttfLabel({
        text = "显示联盟成员的村落采集资源熟练度,每采集一定的村落资源,就会增加一定的熟练度,熟练度越高,采集相应村落资源的速度就会越快",
        size = 20,
        color = 0x797154,
        dimensions = cc.size(500,0)
    }):align(display.CENTER, desc_bg:getContentSize().width/2 , desc_bg:getContentSize().height/2)
        :addTo(desc_bg)

    self.proficiency_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-267, display.top-890, 534, 680),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.proficiency_layer)
    self:CreateProficiencyItem()
    self:CreateProficiencyItem()
    self:CreateProficiencyItem()
    self:CreateProficiencyItem()
    self.proficiency_listview:reload()
end
function GameUIOrderHall:CreateProficiencyItem()
    local item = self.proficiency_listview:newItem()
    local item_width,item_height = 534 , 205
    item:setItemSize(item_width, item_height)
    local content = WidgetUIBackGround.new({
        width = 534,
        height = 196,
        top_img = "back_ground_580x12_top.png",
        bottom_img = "back_ground_580X12_bottom.png",
        mid_img = "back_ground_580X1_mid.png",
        u_height = 12,
        b_height = 12,
        m_height = 1,
    })

    local title_bg = display.newSprite("title_blue_588X30.png"):align(display.LEFT_TOP, 0, 187)
        :addTo(content)
    title_bg:setScaleX(534/588)
    local level_bg = display.newSprite("back_ground_44X44.png")
        :align(display.CENTER, 30, title_bg:getContentSize().height/2)
        :addTo(title_bg)
    display.newSprite("leader.png")
        :align(display.CENTER, level_bg:getContentSize().width/2, level_bg:getContentSize().height/2)
        :addTo(level_bg)
    UIKit:ttfLabel({
        text = "PlayerName LV 32",
        size = 20,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 60 , title_bg:getContentSize().height/2)
        :addTo(title_bg)
    -- 各项采集熟料度
    local function createItem(params)
        local item = display.newSprite("back_ground_162x62.png")
        local size = item:getContentSize()
        -- 采集资源对应图片
        local image = display.newSprite(params.image)
            :align(display.CENTER, 30, size.height/2)
            :addTo(item)
            :scale(0.5)
        UIKit:ttfLabel({
            text = params.level,
            size = 18,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER, 60 , 50)
            :addTo(item)
        UIKit:ttfLabel({
            text = params.proficiency,
            size = 18,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER, 60 , 20)
            :addTo(item)
        return item
    end

    local r_table = {
        {
            image = "wood_icon.png",
            level = "LV 12",
            proficiency = "3000/5000",
        },
        {
            image = "stone_icon.png",
            level = "LV 12",
            proficiency = "3000/5000",
        },
        {
            image = "food_icon.png",
            level = "LV 12",
            proficiency = "3000/5000",
        },
        {
            image = "iron_icon.png",
            level = "LV 12",
            proficiency = "3000/5000",
        },
        {
            image = "coin_icon.png",
            level = "LV 12",
            proficiency = "3000/5000",
        },
    }

    local margin_x = (item_width - 3 * 162)/2 - 10
    local original_x = 90
    local count = 0
    for k,v in pairs(r_table) do
        count = count + 1
        createItem(v)
        :align(display.CENTER, original_x +  math.mod(count-1,3)*162 + math.mod(count-1,3)*margin_x, math.floor((count-1)/3)==0 and 110 or 40)
            :addTo(content)
    end


    item:addContent(content)
    self.proficiency_listview:addItem(item)
end
function GameUIOrderHall:onExit()
    GameUIOrderHall.super.onExit(self)

end

return GameUIOrderHall













