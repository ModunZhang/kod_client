local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetPages = import("..widget.WidgetPages")
local WidgetInfo = import("..widget.WidgetInfo")
local UIListView = import(".UIListView")
local Flag = import("..entity.Flag")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")


local GameUIAllianceBattle = UIKit:createUIClass('GameUIAllianceBattle', "GameUIWithCommonHeader")
local img_dir = "allianceHome/"

function GameUIAllianceBattle:ctor(city)
    GameUIAllianceBattle.super.ctor(self, city, _("联盟会战"))
    self.alliance = Alliance_Manager:GetMyAlliance()
end

function GameUIAllianceBattle:onEnter()
    GameUIAllianceBattle.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("战争统计"),
            tag = "statistics",
            default = true
        },
        {
            label = _("历史记录"),
            tag = "history",
        },
        {
            label = _("其他联盟"),
            tag = "other_alliance",
        },
    }, function(tag)
        if tag == 'statistics' then
            self.statistics_layer:setVisible(true)
        else
            self.statistics_layer:setVisible(false)
        end
        if tag == 'history' then
            self.history_layer:setVisible(true)
        else
            self.history_layer:setVisible(false)
        end
        if tag == 'other_alliance' then
            self.other_alliance_layer:setVisible(true)
        else
            self.other_alliance_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)

    self:InitBattleStatistics()
    self:InitHistoryRecord()
    self:InitOtherAlliance()

end

function GameUIAllianceBattle:CreateBetweenBgAndTitle()
    GameUIAllianceBattle.super.CreateBetweenBgAndTitle(self)

    -- statistics_layer
    self.statistics_layer = display.newLayer()
    self:addChild(self.statistics_layer)
    -- history_layer
    self.history_layer = display.newLayer()
    self:addChild(self.history_layer)
    -- other_alliance_layer
    self.other_alliance_layer = display.newLayer()
    self:addChild(self.other_alliance_layer)
    
end

function GameUIAllianceBattle:InitBattleStatistics()
    local layer = self.statistics_layer

    local period_label = UIKit:ttfLabel({
        text = _("准备期"),
        size = 22,
        color = 0x403c2f,
    }):addTo(layer):align(display.LEFT_CENTER,window.cx-50,window.top-100)

    local time_label = UIKit:ttfLabel({
        text = "04:42:44",
        size = 22,
        color = 0x7e0000,
    }):addTo(layer)
        :align(display.LEFT_CENTER,period_label:getPositionX()+period_label:getContentSize().width+20,window.top-100)

    local i_icon = WidgetPushButton.new({normal = "info_26x26.png",
        pressed = "info_26x26.png"})
        :onButtonClicked(function()
            self:OpenWarDetails()
        end)
        :align(display.CENTER,period_label:getPositionX()-30, window.top-100)
        :addTo(layer)
    if false then
        -- 介绍
        UIKit:ttfLabel({
            text = _("由于你的联盟战斗力太弱，未能匹配到对手，你可以通过以下方式提升联盟战斗战斗力"),
            size = 22,
            color = 0x797154,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.CENTER,window.cx,window.top-170)

        local tip_1 = UIKit:ttfLabel({
            text = _("1，招募更多的玩家加入联盟"),
            size = 22,
            color = 0x403c2f,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.LEFT_CENTER,window.left+60,window.top-260)

        local tip_2 = UIKit:ttfLabel({
            text = _("2，在城市中招募更多的部队"),
            size = 22,
            color = 0x403c2f,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.LEFT_CENTER,window.left+60,tip_1:getPositionY()-50)

        local tip_3 = UIKit:ttfLabel({
            text = _("3，努力提升城市建筑等级"),
            size = 22,
            color = 0x403c2f,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.LEFT_CENTER,window.left+60,tip_2:getPositionY()-50)
    else
        local self_alliance_bg = WidgetPushButton.new({normal = "allianceHome/button_blue_normal_320X94.png",
            pressed = "allianceHome/button_blue_pressed_320X94.png"})
            :onButtonClicked(function()
                self:OpenAllianceDetails()
            end)
            :align(display.RIGHT_CENTER,window.cx,window.top-180)
            :addTo(layer)
            :scale(0.85)
        local enemy_alliance_bg = WidgetPushButton.new({normal = "allianceHome/button_red_normal_320X94.png",
            pressed = "allianceHome/button_red_pressed_320X94.png"})
            :onButtonClicked(function()
                self:OpenAllianceDetails()
            end)
            :align(display.LEFT_CENTER,window.cx,window.top-180)
            :addTo(layer)
            :scale(0.85)
        UIKit:ttfLabel({
            text = _("Alliance Name"),
            size = 22,
            color = 0xffedae,
        }):addTo(self_alliance_bg)
            :align(display.CENTER,-180,0)
        UIKit:ttfLabel({
            text = _("Alliance Name"),
            size = 22,
            color = 0xffedae,
        }):addTo(enemy_alliance_bg)
            :align(display.CENTER,180,0)
        local period_bg = display.newSprite(img_dir.."back_ground_123x102.png")
            :align(display.CENTER, window.cx,window.top-180)
            :addTo(layer)
            :scale(0.85)
        display.newSprite(img_dir.."VS_.png")
            :align(display.CENTER, window.cx,window.top-180)
            :addTo(layer)
        UIKit:ttfLabel({
            text = _("本次联盟会战结束后奖励，总击杀越高奖励越高\n（宝石由联盟击杀榜的玩家平分）"),
            size = 20,
            color = 0x797154,
            align = cc.ui.TEXT_ALIGN_CENTER,
            dimensions = cc.size(500,0),
        }):addTo(layer)
            :align(display.TOP_CENTER,window.cx,window.top-240)
        -- 荣耀值奖励
        local honour_bg = display.newScale9Sprite("back_ground_138x34.png",window.left+70,window.top-320,cc.size(188,34))
            :align(display.LEFT_CENTER)
            :addTo(layer)
        display.newSprite("honour.png"):align(display.CENTER,0,honour_bg:getContentSize().height/2)
            :addTo(honour_bg,2)
            :scale(1.2)
        UIKit:ttfLabel({
            text = string.formatnumberthousands(2384028014),
            size = 20,
            color = 0x514d3e,
        }):addTo(honour_bg,2)
            :align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)

        -- 宝石奖励
        local gem_bg = display.newScale9Sprite("back_ground_138x34.png",window.right-60,window.top-320,cc.size(188,34))
            :align(display.RIGHT_CENTER)
            :addTo(layer)
        display.newSprite("gem_66x56.png"):align(display.CENTER,0,gem_bg:getContentSize().height/2)
            :addTo(gem_bg,2)
            :scale(0.7)
        UIKit:ttfLabel({
            text = string.formatnumberthousands(2384028014),
            size = 20,
            color = 0x514d3e,
        }):addTo(gem_bg,2)
            :align(display.CENTER,gem_bg:getContentSize().width/2,gem_bg:getContentSize().height/2)

        local info_bg = WidgetUIBackGround.new({
            width = 540,
            height = 480,
            top_img = "back_ground_568X14_top.png",
            bottom_img = "back_ground_568X14_top.png",
            mid_img = "back_ground_568X1_mid.png",
            u_height = 14,
            b_height = 14,
            m_height = 1,
            b_flip = true,
        }):align(display.TOP_CENTER,window.cx, window.top-360):addTo(layer)
        self.info_listview = UIListView.new{
            -- bgColor = UIKit:hex2c4b(0x7a000000),
            viewRect = cc.rect(9, 10, 522, 460),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
        }:addTo(info_bg)
        local info_message = {
            {string.formatnumberthousands(2384028014),_("击杀数"),string.formatnumberthousands(2384028014)},
            {string.formatnumberthousands(2384028014),_("战斗力"),string.formatnumberthousands(2384028014)},
            {"62分钟",_("占领月门时间"),"32分钟"},
            {"4",_("占领城市"),"2"},
            {"33",_("突袭次数"),"22"},
            {"44",_("进攻次数"),"55"},
            {"11",_("获胜次数"),"3"},
            {"11",_("失败进攻"),"3"},
            {"11",_("成功防御"),"3"},
            {"11",_("失败防御"),"3"},
        }
        self:CreateInfoItem(self.info_listview,info_message)
    end
end

function GameUIAllianceBattle:CreateInfoItem(listview,info_message)
    local meetFlag = true

    local item_width, item_height = 522,46
    for k,v in pairs(info_message) do
        local item = listview:newItem()
        item:setItemSize(item_width, item_height)
        local content
        if meetFlag then
            content = display.newSprite("upgrade_resources_background_3.png"):scale(item_width/520)
        else
            content = display.newSprite("upgrade_resources_background_2.png"):scale(item_width/520)
        end
        UIKit:ttfLabel({
            text = v[1],
            size = 20,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER, 10, item_height/2):addTo(content)
        UIKit:ttfLabel({
            text = v[2],
            size = 20,
            color = 0x5d563f,
        }):align(display.CENTER, item_width/2, item_height/2):addTo(content)
        UIKit:ttfLabel({
            text = v[3],
            size = 20,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER, 510, item_height/2):addTo(content)

        meetFlag =  not meetFlag
        item:addContent(content)
        listview:addItem(item)
    end
    listview:reload()
end

function GameUIAllianceBattle:OpenAllianceDetails()
    local layer = display.newColorLayer(cc.c4b(0,0,0,127)):addTo(self)
    local body = WidgetUIBackGround.new({height=726}):align(display.TOP_CENTER,display.cx,display.top-100)
        :addTo(layer)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = "Alliance Name",
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                layer:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width-20,rb_size.height+10):addTo(body)
    self.close_btn:addChild(display.newSprite("X_3.png"))

    -- 联盟旗帜
    local flag_bg = display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.CENTER,90,rb_size.height-90)
        :addTo(body)
    local a_helper = WidgetAllianceUIHelper.new()
    local flag_sprite = a_helper:CreateFlagWithRhombusTerrain(Alliance_Manager:GetMyAlliance():TerrainType()
        ,Alliance_Manager:GetMyAlliance():Flag())
    flag_sprite:scale(0.85)
    flag_sprite:align(display.CENTER, flag_bg:getContentSize().width/2, flag_bg:getContentSize().height/2-20)
        :addTo(flag_bg)

    local function addAttr(title,value,x,y)
        local attr_title = UIKit:ttfLabel({
            text = title,
            size = 20,
            color = 0x797154,
        }):align(display.LEFT_CENTER, x, y)
            :addTo(body)
        UIKit:ttfLabel({
            text = value,
            size = 20,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER,x + attr_title:getContentSize().width+20,y)
            :addTo(body)
    end
    addAttr(_("成员"),"30/50",180,rb_size.height-50)
    addAttr(_("语言"),"English",180,rb_size.height-90)
    addAttr(_("战斗力"),"9.446.842",350,rb_size.height-50)
    addAttr(_("击杀"),"9.446.842",350,rb_size.height-90)

    display.newSprite("dividing_line_594x2.png")
        :align(display.CENTER, rb_size.width/2, rb_size.height-160)
        :addTo(body)
    self.member_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a990000),
        viewRect = cc.rect(7, 14, 594, 550),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(body)
    local function addMemberItem(member)
        local item = self.member_listview:newItem()
        item:setItemSize(594, 50)
        local content = display.newNode()
        content:setContentSize(594, 50)

        local line = display.newSprite("dividing_line_594x2.png")
            :align(display.LEFT_CENTER,0,0)
            :addTo(content)
        UIKit:ttfLabel({
            text = "PlayerName",
            size = 22,
            color = 0x403c2f,
        }):align(display.LEFT_BOTTOM,20,10)
            :addTo(line)
        UIKit:ttfLabel({
            text = "LV 23",
            size = 22,
            color = 0x403c2f,
        }):align(display.CENTER_BOTTOM,320,10)
            :addTo(line)
        local t = UIKit:ttfLabel({
            text = "9.446.842",
            size = 22,
            color = 0x403c2f,
        }):align(display.RIGHT_BOTTOM,574,10)
            :addTo(line)
        display.newSprite("dragon_strength_27x31.png")
            :align(display.RIGHT_BOTTOM,564-t:getContentSize().width,10)
            :addTo(line)
        item:addContent(content)
        self.member_listview:addItem(item)
    end
    for i=1,20 do
        addMemberItem()
    end
    self.member_listview:reload()
end


function GameUIAllianceBattle:OpenWarDetails()
    local layer = display.newColorLayer(cc.c4b(0,0,0,127)):addTo(self)
    local body = WidgetUIBackGround.new({height=608}):align(display.TOP_CENTER,display.cx,display.top-100)
        :addTo(layer)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = _("联盟对战"),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                layer:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width-20,rb_size.height+10):addTo(body)
    self.close_btn:addChild(display.newSprite("X_3.png"))

    local war_introduce_table = {
        _("概述，准备期。战争期，保护期的描述。1"),
        _("概述，准备期。战争期，保护期的描述。2"),
        _("概述，准备期。战争期，保护期的描述。3"),
        _("概述，准备期。战争期，保护期的描述。4"),
    }

    local info_bg = WidgetUIBackGround.new({
        width = 574,
        height = 422,
        top_img = "back_ground_top_2.png",
        bottom_img = "back_ground_bottom_2.png",
        mid_img = "back_ground_mid_2.png",
        u_height = 10,
        b_height = 10,
        m_height = 1,
    }):align(display.TOP_CENTER,rb_size.width/2,rb_size.height-90):addTo(body)
    local war_introduce_label = UIKit:ttfLabel({
        text = "概述，准备期。战争期，保护期的描述。",
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(550,0)
    })
        :align(display.LEFT_TOP,12,416)
        :addTo(info_bg)

    WidgetPages.new({
        page =4, -- 页数
        titles =  {_("概述"),
            _("准备期"),
            _("战争期"),
            _("保护期")}, -- 标题 type -> table
        cb = function (page)
            war_introduce_label:setString(war_introduce_table[page])
        end -- 回调
    }):align(display.CENTER, rb_size.width/2,rb_size.height-50)
        :addTo(body)

    local know_button =  WidgetPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("明白"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                layer:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width/2, 50):addTo(body)
end

function GameUIAllianceBattle:InitHistoryRecord()
    local layer = self.history_layer
    self.history_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a990000),
        viewRect = cc.rect(17, window.top-890, 608, 786),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(layer)
    local function addHistoryItem(report)
        local item = self.history_listview:newItem()
        local w,h = 608,274
        item:setItemSize(w,h)
        local content = WidgetUIBackGround.new({height=274})

        local title_bg = display.newSprite("blue_bar_548x30.png"):align(display.CENTER, w/2, h-30)
            :addTo(content)
            :scale(1.06)
        UIKit:ttfLabel({
            text = _("2015.5.1 13:50"),
            size = 22,
            color = 0xffedae,
        }):align(display.CENTER,title_bg:getContentSize().width/2, title_bg:getContentSize().height/2)
            :addTo(title_bg)

        local fight_bg = display.newSprite("report_back_ground.png")
            :align(display.TOP_CENTER, w/2,h-50)
            :addTo(content)
            :scale(0.95)
        UIKit:ttfLabel({
            text = "胜利",
            size = 20,
            color = 0x007c23,
        }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width/2-90,65)
            :addTo(fight_bg)
        UIKit:ttfLabel({
            text = "玩家名字",
            size = 20,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width/2-90,40)
            :addTo(fight_bg)
        UIKit:ttfLabel({
            text = "[己方联盟名字]",
            size = 18,
            color = 0x403c2f,
        }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width/2-90,20)
            :addTo(fight_bg)
        UIKit:ttfLabel({
            text = "失败",
            size = 20,
            color = 0x7e0000,
        }):align(display.LEFT_CENTER,fight_bg:getContentSize().width/2+90,65)
            :addTo(fight_bg)
        UIKit:ttfLabel({
            text = "玩家名字",
            size = 20,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER,fight_bg:getContentSize().width/2+90,40)
            :addTo(fight_bg)
        UIKit:ttfLabel({
            text = "[敌方联盟名字]",
            size = 18,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER,fight_bg:getContentSize().width/2+90,20)
            :addTo(fight_bg)

        local VS = UIKit:ttfLabel({
            text = "VS",
            size = 20,
            color = 0x403c2f,
        }):align(display.CENTER,fight_bg:getContentSize().width/2,fight_bg:getContentSize().height/2)
            :addTo(fight_bg)

        -- 己方联盟旗帜
        local ui_helper = WidgetAllianceUIHelper.new()
        local self_flag = ui_helper:CreateFlagContentSprite(self.alliance:Flag()):scale(0.5)
        self_flag:align(display.CENTER, VS:getPositionX()-80, 10)
            :addTo(fight_bg)
        -- 敌方联盟旗帜
        local enemy_flag = ui_helper:CreateFlagContentSprite(self.alliance:Flag()):scale(0.5)
        enemy_flag:align(display.CENTER, VS:getPositionX()+20, 10)
            :addTo(fight_bg)

        -- 击杀数，战斗力
        local info_bg = WidgetUIBackGround.new({
            width = 540,
            height = 110,
            top_img = "back_ground_568X14_top.png",
            bottom_img = "back_ground_568X14_top.png",
            mid_img = "back_ground_568X1_mid.png",
            u_height = 14,
            b_height = 14,
            m_height = 1,
            b_flip = true,
        }):align(display.BOTTOM_CENTER,w/2,20):addTo(content)

        local info_message = {
            {string.formatnumberthousands(2384028014),_("击杀数"),string.formatnumberthousands(2384028014)},
            {string.formatnumberthousands(2384028014),_("战斗力"),string.formatnumberthousands(2384028014)},
        }
        local function createItem(info,meetFlag)
            local content
            if meetFlag then
                content = display.newSprite("upgrade_resources_background_3.png")
            else
                content = display.newSprite("upgrade_resources_background_2.png")
            end
            UIKit:ttfLabel({
                text = info[1],
                size = 20,
                color = 0x403c2f,
            }):align(display.LEFT_CENTER, 10, 23):addTo(content)
            UIKit:ttfLabel({
                text = info[2],
                size = 20,
                color = 0x5d563f,
            }):align(display.CENTER, 261, 23):addTo(content)
            UIKit:ttfLabel({
                text = info[3],
                size = 20,
                color = 0x403c2f,
            }):align(display.RIGHT_CENTER, 510, 23):addTo(content)
            return content
        end

        createItem(info_message[1],true):align(display.CENTER, 270, 33):addTo(info_bg)
        createItem(info_message[2],false):align(display.CENTER, 270, 79):addTo(info_bg)


        item:addContent(content)
        self.history_listview:addItem(item)
    end

    for i=1,10 do
        addHistoryItem()
    end

    self.history_listview:reload()
end


function GameUIAllianceBattle:InitOtherAlliance()
    local layer = self.other_alliance_layer
    local face_bg = display.newSprite("allianceHome/banner.png")
        :align(display.TOP_CENTER, window.cx, window.top-50)
        :addTo(layer)

    --搜索
    local searchIcon = display.newSprite("alliacne_search_29x33.png"):addTo(layer)
        :align(display.LEFT_CENTER,50,window.top-270)
    local function onEdit(event, editbox)
        if event == "return" then
            self:SearchAllianAction(self.editbox_tag_search:getText())
        end
    end

    local editbox_tag_search = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "alliance_editbox_575x48.png",
        size = cc.size(510,48),
        listener = onEdit,
    })

    editbox_tag_search:setPlaceHolder(_("搜索联盟标签"))
    editbox_tag_search:setMaxLength(600)
    editbox_tag_search:setFont(UIKit:getFontFilePath(),18)
    editbox_tag_search:setFontColor(cc.c3b(0,0,0))
    editbox_tag_search:setPlaceholderFontColor(UIKit:hex2c3b(0xccc49e))
    editbox_tag_search:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
    editbox_tag_search:align(display.CENTER,window.cx+20,window.top-270):addTo(layer)
    self.editbox_tag_search = editbox_tag_search

    -- 搜索结果
    self.alliance_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a990000),
        viewRect = cc.rect(17, window.top-890, 608, 586),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(layer)
    for i=1,10 do
        self:CreateAllianceItem()
    end
    self.alliance_listview:reload()
end

function GameUIAllianceBattle:CreateAllianceItem()
    local item = self.alliance_listview:newItem()
    local w,h = 608,160
    item:setItemSize(w, h)
    local content = WidgetUIBackGround.new({height=h})


    -- 联盟旗帜
    local flag_bg =  WidgetPushButton.new({normal = "alliance_item_flag_box_126X126.png",
        pressed = "alliance_item_flag_box_126X126.png"})
        :onButtonClicked(function()
            self:OpenOtherAllianceDetails()
        end)
        :align(display.CENTER,90,h/2)
        :addTo(content)
    local a_helper = WidgetAllianceUIHelper.new()
    local flag_sprite = a_helper:CreateFlagWithRhombusTerrain(Alliance_Manager:GetMyAlliance():TerrainType()
        ,Alliance_Manager:GetMyAlliance():Flag())
    flag_sprite:scale(0.85)
    flag_sprite:align(display.CENTER,0,-20)
        :addTo(flag_bg)


    local i_icon = display.newSprite("info_26x26.png")
        :align(display.CENTER,-flag_bg:getCascadeBoundingBox().size.width/2+15,-flag_bg:getCascadeBoundingBox().size.height/2+15)
        :addTo(flag_bg)


    local title_bg = display.newScale9Sprite("title_blue_588X30.png", w-10, h-30,cc.size(438,30))
        :align(display.RIGHT_CENTER)
        :addTo(content)
    -- 搜索出的条目index
    local index_box  = UIKit:ttfLabel({
        text = "1",
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 10, title_bg:getContentSize().height/2):addTo(title_bg,2)

    -- 代表此联盟与己方联盟的关系图标
    local s_icon = display.newSprite("allianceHome/down.png")
        :align(display.LEFT_CENTER, index_box:getPositionX()+index_box:getContentSize().width, title_bg:getContentSize().height/2)
        :addTo(title_bg,2)
    -- 联盟tag和名字
    local index_box  = UIKit:ttfLabel({
        text = "【KOD】iverson",
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, s_icon:getPositionX()+s_icon:getContentSize().width, title_bg:getContentSize().height/2)
        :addTo(title_bg,2)
    -- 联盟power
    display.newSprite("dragon_strength_27x31.png")
        :align(display.CENTER, 180,70)
        :addTo(content)
    local power_label  = UIKit:ttfLabel({
        text = string.formatnumberthousands(323568321),
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,200,70)
        :addTo(content)
    -- 联盟击杀
    display.newSprite("allianceHome/hit_icon.png")
        :align(display.CENTER, 180,30)
        :addTo(content)
    local hit_label  = UIKit:ttfLabel({
        text = string.formatnumberthousands(323568321),
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,200,30)
        :addTo(content)

    -- relationship
    local relationship_label = UIKit:ttfLabel({
        text = _("仇敌"),
        size = 20,
        color = 0x853506,--007c23 盟友color
    }):align(display.CENTER,w-93,75)
        :addTo(content)

    -- 进入按钮
    local enter_btn = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("进入"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.RIGHT_CENTER,w-20,35):addTo(content)

    item:addContent(content)
    self.alliance_listview:addItem(item)
end

-- tag ~= nil -->search
function GameUIAllianceBattle:GetJoinList(tag)
    if tag  then
        NetManager:getSearchAllianceByTagPromsie(tag):next(function(data)
            if #data.alliances > 0 then
            -- self:RefreshJoinListView(data.alliances)
            end
        end)
    else
        NetManager:getFetchCanDirectJoinAlliancesPromise():next(function(data)
            if #data.alliances > 0 then
            -- self:RefreshJoinListView(data.alliances)
            end
        end)
    end
end
function GameUIAllianceBattle:SearchAllianAction(tag)
    self:GetJoinList(tag)
end

function GameUIAllianceBattle:OpenOtherAllianceDetails()
    local body = WidgetPopDialog.new(706,_("联盟信息")):addTo(self)
    local rb_size = body:getContentSize()
    local w,h = rb_size.width,rb_size.height
    -- 联盟旗帜
    local flag_bg = display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.CENTER,100,rb_size.height-230)
        :addTo(body)
    local a_helper = WidgetAllianceUIHelper.new()
    local flag_sprite = a_helper:CreateFlagWithRhombusTerrain(Alliance_Manager:GetMyAlliance():TerrainType()
        ,Alliance_Manager:GetMyAlliance():Flag())
    flag_sprite:scale(0.85)
    flag_sprite:align(display.CENTER, flag_bg:getContentSize().width/2, flag_bg:getContentSize().height/2-20)
        :addTo(flag_bg)

    -- 联盟名字和tag
    local title_bg = display.newScale9Sprite("title_blue_588X30.png", w-30, h-180,cc.size(438,30))
        :align(display.RIGHT_CENTER)
        :addTo(body)

    -- 联盟tag和名字
    local index_box  = UIKit:ttfLabel({
        text = "【KOD】iverson",
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 20, title_bg:getContentSize().height/2)
        :addTo(title_bg,2)

    local function addAttr(title,value,x,y)
        local attr_title = UIKit:ttfLabel({
            text = title,
            size = 20,
            color = 0x797154,
        }):align(display.LEFT_CENTER, x, y)
            :addTo(body)
        UIKit:ttfLabel({
            text = value,
            size = 20,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER,x + attr_title:getContentSize().width+20,y)
            :addTo(body)
    end
    addAttr(_("成员"),"30/50",180,h-220)
    addAttr(_("语言"),"English",180,h-250)
    addAttr(_("战斗力"),"9.446.842",350,h-220)
    addAttr(_("击杀"),"9.446.842",350,h-250)
    -- 进入按钮
    local enter_btn = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("进入"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.RIGHT_CENTER,w-40,h-290):addTo(body)
    WidgetInfo.new({
        info={
            {_("名城占领时间"),"30/50"},
            {_("消灭的战斗力"),"30/50"},
            {_("占领过的城市"),"30/50"},
            {_("联盟战胜利"),"30/50"},
            {_("联盟战失败"),"30/50"},
            {_("胜率"),"30/50"},
        },
        h =260
    }):align(display.TOP_CENTER, w/2 , h-330)
        :addTo(body)
 --    -- 和平标记
 --    local peace_bg = display.newSprite("back_ground_green_570x84.png")
 --        :align(display.CENTER, w/2, h-650)
 --        :addTo(body)
 --    UIKit:ttfLabel({
 --            text = _("标记和平"),
 --            size = 24,
 --            color = 0xffedae,
 --        }):align(display.LEFT_CENTER,120,peace_bg:getContentSize().height/2)
 --            :addTo(peace_bg)
 --    -- 和平被标记
 --    display.newSprite("upgrade_mark.png"):addTo(peace_bg):pos(30,peace_bg:getContentSize().height/2)
 --    -- icon
 --    display.newSprite("icon_relation.png"):addTo(peace_bg):pos(80,peace_bg:getContentSize().height/2)

 --    local cancel_btn = WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"})
 --        :setButtonLabel(UIKit:ttfLabel({
 --            text = _("取消"),
 --            size = 24,
 --            color = 0xffedae,
 --            shadow= true
 --        }))
 --        :onButtonClicked(function(event)
 --            if event.name == "CLICKED_EVENT" then

 --            end
 --        end):align(display.RIGHT_CENTER,peace_bg:getContentSize().width-10,peace_bg:getContentSize().height/2):addTo(peace_bg)
 --    -- 仇敌标记
 --    local enemy_bg = display.newSprite("back_ground_red_570x84.png")
 --        :align(display.CENTER, w/2, h-750)
 --        :addTo(body)
 --    UIKit:ttfLabel({
 --            text = _("标记仇敌"),
 --            size = 24,
 --            color = 0xffedae,
 --        }):align(display.LEFT_CENTER,120,enemy_bg:getContentSize().height/2)
 --            :addTo(enemy_bg)
	-- -- honour icon
 --    display.newSprite("honour.png"):addTo(enemy_bg):pos(enemy_bg:getContentSize().width-240,enemy_bg:getContentSize().height/2)

 --    UIKit:ttfLabel({
 --            text = "100",
 --            size = 20,
 --            color = 0xffedae,
 --        }):align(display.CENTER,enemy_bg:getContentSize().width-200,enemy_bg:getContentSize().height/2)
 --            :addTo(enemy_bg)
 --    -- icon
 --    display.newSprite("icon_enemy.png"):addTo(enemy_bg):pos(80,enemy_bg:getContentSize().height/2)
 --    local mark_btn = WidgetPushButton.new({normal = "blue_btn_up_142x39.png",pressed = "blue_btn_down_142x39.png"})
 --        :setButtonLabel(UIKit:ttfLabel({
 --            text = _("标记"),
 --            size = 22,
 --            color = 0xffedae,
 --            shadow= true
 --        }))
 --        :onButtonClicked(function(event)
 --            if event.name == "CLICKED_EVENT" then

 --            end
 --        end):align(display.RIGHT_CENTER,enemy_bg:getContentSize().width-10,enemy_bg:getContentSize().height/2):addTo(enemy_bg)

end

return GameUIAllianceBattle