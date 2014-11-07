local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetAllianceBuildingUpgrade = import("..widget.WidgetAllianceBuildingUpgrade")
local GameUIAlliancePalace = UIKit:createUIClass('GameUIAlliancePalace', "GameUIAllianceBuilding")
local Flag = import("..entity.Flag")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Localize = import("..utils.Localize")


function GameUIAlliancePalace:ctor(city,default_tab,building)
    GameUIAlliancePalace.super.ctor(self, city, _("联盟宫殿"),default_tab,building)
    self.default_tab = default_tab
    self.building = building
    -- self.alliance = Alliance_Manager:GetMyAlliance()
end

function GameUIAlliancePalace:onEnter()
    GameUIAlliancePalace.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("征税"),
            tag = "impose",
            default = "impose" == self.default_tab,
        },
        {
            label = _("信息"),
            tag = "info",
            default = "info" == self.default_tab,
        },
    }, function(tag)
        if tag == 'impose' then
            self.impose_layer:setVisible(true)
        else
            self.impose_layer:setVisible(false)
        end
        if tag == 'info' then
            self.info_layer:setVisible(true)
        else
            self.info_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
    -- impose_layer
    self:InitImposePart()
    --info_layer
    self:InitInfoPart()

end
function GameUIAlliancePalace:CreateBetweenBgAndTitle()
    GameUIAlliancePalace.super.CreateBetweenBgAndTitle(self)

    -- upgrade_layer
    self.upgrade_layer = WidgetAllianceBuildingUpgrade.new(self.building)
    self:addChild(self.upgrade_layer)
    -- impose_layer
    self.impose_layer = display.newLayer()
    self:addChild(self.impose_layer)
    -- info_layer
    self.info_layer = display.newLayer()
    self:addChild(self.info_layer)
end
function GameUIAlliancePalace:onExit()
    GameUIAlliancePalace.super.onExit(self)
end


-- 初始化占领联盟征税部分
function GameUIAlliancePalace:InitImposePart()
    self.impose_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-304, display.top-800, 612, 700),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.impose_layer)
    -- 征收荣耀值
    display.newSprite("honour.png"):align(display.CENTER, window.cx-80, window.top-850):addTo(self.impose_layer)
    local honour_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER, window.cx, window.top-850):addTo(self.impose_layer)
    self.levy_honour = UIKit:ttfLabel({
        text = "10000",
        size = 20,
        color = 0x403c2f,
    }):addTo(honour_bg):align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)
    -- 全部收取按钮
    WidgetPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("全部收取"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER, window.right-150, window.top-850):addTo(self.impose_layer)


    self.impose_listview:addItem(self:CreateHonourItem())
    self.impose_listview:reload()
end

function GameUIAlliancePalace:CreateHonourItem()
    local item = self.impose_listview:newItem()
    local item_width, item_height = 608,168
    item:setItemSize(item_width, item_height)
    local body = WidgetUIBackGround.new({height=item_height})
    local bg_size = body:getContentSize()
    -- 被占领联盟的联盟旗帜左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, 30, bg_size.height/2)
        :addTo(body):setFlippedX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.CENTER, 135, bg_size.height/2)
        :addTo(body)
    -- 联盟旗帜
    local a_helper = WidgetAllianceUIHelper.new()
    local flag_sprite = a_helper:CreateFlagWithRhombusTerrain("grassLand",Flag.new():DecodeFromJson("{\"flagColor\":[\"green\",\"white\"],\"flag\":1,\"graphic\":4,\"graphicColor\":[\"blue\",\"babyBlue\"],\"graphicContent\":[12,4]}"))
    flag_sprite:scale(0.8)
    flag_sprite:align(display.CENTER, 80, bg_size.height/2-20)
        :addTo(body)
    -- 玩家名字，等级
    UIKit:ttfLabel({
        text = "PlayerName [LV 12]",
        size = 24,
        color = 0x514d3e,
    }):addTo(body):align(display.LEFT_CENTER,160,item_height-30)
    -- 联盟名字
    UIKit:ttfLabel({
        text = "AllianceName",
        size = 20,
        color = 0x797154,
    }):addTo(body):align(display.LEFT_CENTER,160,item_height-65)
    -- 当前征收荣誉
    local tem_label = UIKit:ttfLabel({
        text = "当前征收荣誉",
        size = 20,
        color = 0x797154,
    }):addTo(body):align(display.LEFT_CENTER,160,item_height-100)
    UIKit:ttfLabel({
        text = "1200",
        size = 20,
        color = 0x403c2f,
    }):addTo(body):align(display.LEFT_CENTER,175+tem_label:getContentSize().width,item_height-100)
    -- 剩余占领时间
    local tem_label = UIKit:ttfLabel({
        text = "剩余占领时间",
        size = 20,
        color = 0x797154,
    }):addTo(body):align(display.LEFT_CENTER,160,item_height-140)
    -- 剩余占领时间
    local tem_label = UIKit:ttfLabel({
        text = "00:20:60",
        size = 20,
        color = 0x007c23,
    }):addTo(body):align(display.LEFT_CENTER,175+tem_label:getContentSize().width,item_height-140)
    -- 放弃按钮
    WidgetPushButton.new(
        {normal = "resource_butter_red.png", pressed = "resource_butter_red_highlight.png"},
        {scale9 = false}
    ):setButtonLabel(UIKit:ttfLabel({
        text = _("放弃"),
        size = 20,
        color = 0xffedae,
        shadow= true
    })):addTo(body):align(display.CENTER, item_width-100, 40)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end)
    item:addContent(body)
    return item
end

function GameUIAlliancePalace:InitInfoPart()
    local terrain = self:CreateBackGroundWithTitle({title_1=_("地形定义"),title_2=_("需要职位是联盟盟主"),
        height=400}):align(display.CENTER, window.cx, window.top-320):addTo(self.info_layer)
    local bg1 = WidgetUIBackGround.new({
        width = 580,
        height = 314,
        top_img = "back_ground_580x12_top.png",
        bottom_img = "back_ground_580X12_bottom.png",
        mid_img = "back_ground_580X1_mid.png",
        u_height = 12,
        b_height = 12,
        m_height = 1,
    }):align(display.CENTER,304, 220):addTo(terrain)

    -- 草地
    display.newSprite("grass_ground1_800x560.png")
        :align(display.CENTER, 110, 250):addTo(bg1):scale(0.2)
    -- 雪地
    display.newSprite("desert1_800x560.png")
        :align(display.CENTER, 295, 250):addTo(bg1):scale(0.2)
    -- 沙漠
    display.newSprite("icefield1_800x560.png")
        :align(display.CENTER, 485, 250):addTo(bg1):scale(0.2)

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
        :align(display.CENTER, 80 , 120)
        :addTo(bg1)
    group:getButtonAtIndex(1):setButtonSelected(true)

    -- 介绍
    local intro_bg = WidgetUIBackGround2.new(98):align(display.BOTTOM_CENTER, 290, 5):addTo(bg1)
    UIKit:ttfLabel({
        text = _("草地地形能产出绿龙装备材料，每当在自己的领土上完成任务，或者击杀一点战斗力的敌方单位，就由一定几率获得装备材料。"),
        size = 18,
        color = 0x514d3e,
        dimensions = cc.size(566, 0),
    }):align(display.LEFT_CENTER, 4, intro_bg:getContentSize().height/2):addTo(intro_bg)
    -- 消耗荣耀值更换地形
    display.newSprite("honour.png"):align(display.CENTER, 274, 35):addTo(terrain)
    local honour_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER, 354, 35):addTo(terrain)
    self.levy_honour = UIKit:ttfLabel({
        text = "10000",
        size = 20,
        color = 0x403c2f,
    }):addTo(honour_bg):align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)
    -- 购买使用按钮
    WidgetPushButton.new({normal = "green_btn_up_142x39.png",pressed = "green_btn_down_142x39.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("购买使用"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER, 520, 35):addTo(terrain)

    local info = self:CreateBackGroundWithTitle({title_1=_("信息"),
        height=334}):align(display.CENTER, window.cx, window.top-720):addTo(self.info_layer)
    local info_bg = WidgetUIBackGround.new({
        width = 568,
        height = 302,
        top_img = "back_ground_568X14_top.png",
        bottom_img = "back_ground_568X14_top.png",
        mid_img = "back_ground_568X1_mid.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):align(display.CENTER,304, 165):addTo(info)
    self.info_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(9, 10, 550, 282),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(info_bg)
    local info_message = {
        {_("名城占领时间"),"2D 24H 4M"},
        {_("消灭的战斗力"),"23,444,333"},
        {_("阵亡的部队人口"),"23,444,333"},
        {_("占领过的城市"),"23,444,333"},
        {_("联盟战胜利"),"23,444,333"},
        {_("联盟战失败"),"23,444,333"},
        {_("胜率"),"33%"},
    }
    self:CreateInfoItem(info_message)
end

function GameUIAlliancePalace:CreateInfoItem(info_message)
    local meetFlag = true

    local item_width, item_height = 550,46
    for k,v in pairs(info_message) do
        local item = self.info_listview:newItem()
        item:setItemSize(item_width, item_height)
        local content 
        if meetFlag then
            content = display.newSprite("upgrade_resources_background_3.png"):scale(550/520)
        else
            content = display.newSprite("upgrade_resources_background_2.png"):scale(550/520)
        end
        UIKit:ttfLabel({
            text = v[1],
            size = 20,
            color = 0x5d563f,
        }):align(display.LEFT_CENTER, 10, item_height/2):addTo(content)
         UIKit:ttfLabel({
            text = v[2],
            size = 20,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER, 510, item_height/2):addTo(content)
        meetFlag =  not meetFlag
        item:addContent(content)
        self.info_listview:addItem(item)
    end
    self.info_listview:reload()
end

function GameUIAlliancePalace:CreateBackGroundWithTitle(params)
    local body = WidgetUIBackGround.new({height=params.height}):align(display.TOP_CENTER,display.cx,display.top-200)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = params.title_1,
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    if params.title_2 then
        title_label:align(display.LEFT_CENTER, 60, title:getContentSize().height/2+2)
        UIKit:ttfLabel({
            text = params.title_2,
            size = 20,
            color = 0xb7af8e,
        }):align(display.RIGHT_CENTER, title:getContentSize().width-60, title:getContentSize().height/2+2)
            :addTo(title)
    end
    return body
end
return GameUIAlliancePalace








