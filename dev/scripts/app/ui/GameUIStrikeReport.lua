local StarBar = import(".StarBar")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")


local GameUIStrikeReport = class("GameUIStrikeReport", function ()
    return display.newColorLayer(UIKit:hex2c4b(0x7a000000))
end)

function GameUIStrikeReport:ctor(report)
    self:setNodeEventEnabled(true)
    self.report = report
end

function GameUIStrikeReport:onEnter()
    local report_body = WidgetUIBackGround.new({height=800}):addTo(self):align(display.TOP_CENTER,display.cx,display.top-100)
    local rb_size = report_body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height)
        :addTo(report_body)
    local title_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("Attack Successful"),
            font = UIKit:getFontFilePath(),
            size = 22,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2)
        :addTo(title)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent()
        end):align(display.CENTER, title:getContentSize().width-10, title:getContentSize().height-10)
        :addTo(title):addChild(display.newSprite("X_3.png"))
    -- 突袭结果图片
    local strike_result_image = display.newSprite("report_victory.png")
        :align(display.CENTER_TOP, rb_size.width/2, rb_size.height-16)
        :addTo(report_body)
    local strike_result_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("得到一份s级情报"),
            font = UIKit:getFontFilePath(),
            size = 18,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, strike_result_image:getContentSize().width/2, 15)
        :addTo(strike_result_image)
    local strike_result_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("Battle at CitrName (182,450)"),
            font = UIKit:getFontFilePath(),
            size = 18,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 20, rb_size.height-170)
        :addTo(report_body)
    local strike_result_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("2015.5.13 13:30"),
            font = UIKit:getFontFilePath(),
            size = 18,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 20, rb_size.height-200)
        :addTo(report_body)
    -- 突袭战报详细内容展示
    self.details_view = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(0, 70, 588, 505),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(report_body):pos(10, 5)

    -- 战利品部分
    self:CreateBootyPart()
    -- 战斗统计部分
    self:CreateWarStatisticsPart()
    -- 敌方情报部分
    self:CreateReportOfEnemy()

    self.details_view:reload()

    -- 删除按钮
    local delete_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("删除"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    delete_label:enableShadow()

    WidgetPushButton.new(
        {normal = "resource_butter_red.png", pressed = "resource_butter_red_highlight.png"},
        {scale9 = false}
    ):setButtonLabel(delete_label)
        :addTo(report_body):align(display.CENTER, 140, 40)
        :onButtonClicked(function(event)

            end)
    -- 收藏按钮
    local saved_button = cc.ui.UICheckBoxButton.new({
        off = "mail_saved_button_normal.png",
        off_pressed = "mail_saved_button_normal.png",
        off_disabled = "mail_saved_button_normal.png",
        on = "mail_saved_button_pressed.png",
        on_pressed = "mail_saved_button_pressed.png",
        on_disabled = "mail_saved_button_pressed.png",
    }):onButtonStateChanged(function(event)

        end):addTo(report_body):pos(rb_size.width-47, 37)
end

function GameUIStrikeReport:GetTextBooty()
    return {
        {
            resource_type = _("英雄之血"),
            icon="dragonskill_blood_51x63.png",
            value = "X "..100,
        },
        {
            resource_type = _("粮食"),
            icon="food_icon.png",
            value = "X "..100,
        },
        {
            resource_type = _("木材"),
            icon="wood_icon.png",
            value = "X "..100,
        },
        {
            resource_type = _("石料"),
            icon="stone_icon.png",
            value = "X "..100,
        },
        {
            resource_type = _("铁矿"),
            icon="iron_icon.png",
            value = "X "..100,
        },
        {
            resource_type = _("硬币"),
            icon="coin_icon.png",
            value = "X "..100,
        },
    }
end

function GameUIStrikeReport:CreateBootyPart()
    local booty_group = cc.ui.UIGroup.new()
    local item_height = 46
    -- 战利品列表部分高度
    local booty_count = #self:GetTextBooty()
    local booty_list_height = booty_count * item_height

    -- 战利品列表
    local booty_list_bg = display.newScale9Sprite("upgrade_requirement_background.png", 0,0,cc.size(540, booty_list_height+16))
        :align(display.CENTER)
    local booty_list_bg_size = booty_list_bg:getContentSize()
    booty_group:addWidget(booty_list_bg)

    -- 构建所有战利品标签项
    local booty_item_bg_color_flag = true
    local added_booty_item_count = 0
    for k,booty_parms in pairs(self:GetTextBooty()) do
        local booty_item_bg_image = booty_item_bg_color_flag and "upgrade_resources_background_3.png" or "upgrade_resources_background_2.png"
        local booty_item_bg = display.newSprite(booty_item_bg_image)
            :align(display.TOP_CENTER, booty_list_bg_size.width/2, booty_list_bg_size.height-item_height*added_booty_item_count-6)
            :addTo(booty_list_bg,2)
        local booty_icon = display.newSprite(booty_parms.icon, 30, 23):addTo(booty_item_bg)
        booty_icon:setScale(40/booty_icon:getContentSize().width)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = booty_parms.resource_type,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,80,23):addTo(booty_item_bg)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = booty_parms.value,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x288400)
        }):align(display.RIGHT_CENTER,booty_list_bg_size.width-30,23):addTo(booty_item_bg)

        added_booty_item_count = added_booty_item_count + 1
        booty_item_bg_color_flag = not booty_item_bg_color_flag
    end

    local booty_title_bg = display.newSprite("upgrade_resources_title.png")
        :align(display.CENTER_BOTTOM, 0,booty_list_bg:getContentSize().height/2)

    booty_group:addWidget(booty_title_bg)

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("战利品") ,
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER,booty_title_bg:getContentSize().width/2, 25):addTo(booty_title_bg)
    local item = self.details_view:newItem()
    -- print("战利品框大小",booty_list_bg:getContentSize().width,booty_list_bg:getContentSize().height+booty_title_bg:getContentSize().height)
    item:setItemSize(booty_list_bg:getContentSize().width,booty_list_bg:getContentSize().height+booty_title_bg:getContentSize().height+50)
    item:addContent(booty_group)
    self.details_view:addItem(item)
end

function GameUIStrikeReport:CreateWarStatisticsPart()
    local group = cc.ui.UIGroup.new()
    local group_width,group_height = 540,28
    group:addWidget(
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("战斗统计") ,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER,0, group_height/2+15)
    )
    -- local self_dragon_item = self:CreateDragonItem(_("你的龙")):align(display.CENTER, -group_width/2+129, 0)

    -- group:addWidget(self_dragon_item)

    -- local enemy_dragon_item = self:CreateDragonItem(_("敌方的龙"))
    --     :align(display.CENTER, group_width/2-129, 0)
    -- group:addWidget(enemy_dragon_item)
    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)


    -- 交战双方信息
    self:CreateBelligerents()
    -- 龙
    self:CreateArmyGroup()
end


-- 交战双方信息
function GameUIStrikeReport:CreateBelligerents()
    local group = cc.ui.UIGroup.new()
    local group_width,group_height = 540,100
    local self_item = self:CreateBelligerentsItem(group_height):align(display.CENTER, -group_width/2+129, 0)

    group:addWidget(self_item)

    local enemy_item = self:CreateBelligerentsItem(group_height)
        :align(display.CENTER, group_width/2-129, 0)
    group:addWidget(enemy_item)
    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end

function GameUIStrikeReport:CreateBelligerentsItem(height,title)
    local player_item = self:CreateSmallBackGround(height,title)

    -- 玩家头像
    local heroBg = display.newSprite("chat_hero_background.png"):align(display.CENTER, 50, height/2):addTo(player_item)
    heroBg:setScale(0.6)
    local hero = display.newSprite("Hero_1.png"):align(display.CENTER, 50, height/2)
        :addTo(player_item):setScale(0.5)
    -- 玩家名称
    UIKit:ttfLabel({
        text = _("Player Name") ,
        size = 18,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,110, height-40)
        :addTo(player_item)

    UIKit:ttfLabel({
        text = _("Aliance") ,
        size = 18,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,110,  height-70)
        :addTo(player_item)

    return player_item
end

function GameUIStrikeReport:CreateArmyGroup()
    local group = cc.ui.UIGroup.new()

    local group_width,group_height = 540,150
    local self_army_item = self:CreateArmyItem(_("Red Dragon"))
        :align(display.CENTER, -group_width/2+129, 0)

    group:addWidget(self_army_item)

    local enemy_army_item = self:CreateArmyItem(_("Red Dragon"))
        :align(display.CENTER, group_width/2-129, 0)
    group:addWidget(enemy_army_item)
    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end

function GameUIStrikeReport:CreateArmyItem(title)
    local w,h = 258,114
    local army_item = self:CreateSmallBackGround(h,title)

    local function createInfoItem(params)
        local item  = display.newSprite(params.bg_image)
        local title = UIKit:ttfLabel({
            text = params.title ,
            size = 18,
            color = params.color or 0x615b44
        }):addTo(item)
        if params.value then
            UIKit:ttfLabel({
                text = params.value ,
                size = 20,
                color = 0x403c2f
            }):align(display.RIGHT_CENTER,item:getContentSize().width, item:getContentSize().height/2):addTo(item)
            title:align(display.LEFT_CENTER,0, item:getContentSize().height/2)

        else
            title:align(display.CENTER,item:getContentSize().width/2, item:getContentSize().height/2)
        end

        return item
    end

    local army_info = {
        {
            bg_image = "back_ground_254x28_2.png",
            title = "Level",
            value = "11",
        },
        {
            bg_image = "back_ground_254x28_1.png",
            title = "XP",
            value = "+665",
        },
        {
            bg_image = "back_ground_254x28_2.png",
            title = "HP",
            value = "20000/-500",
        },
    }

    local gap_y = 28
    local y_postion = h -30
    for k,v in pairs(army_info) do
        createInfoItem(v):addTo(army_item)
            :align(display.TOP_CENTER, w/2, y_postion)
        y_postion = y_postion - gap_y
    end
    return army_item
end
function GameUIStrikeReport:CreateDragonItem(title)
    local dragon_item = self:CreateSmallBackGround(140,title)

    -- 龙的头像
    local dragonBg = display.newSprite("chat_hero_background.png"):align(display.CENTER, 50, 55):addTo(dragon_item)
    dragonBg:setScale(0.8)
    local dragon = display.newSprite("head_dragon.png"):align(display.CENTER, 50, 55)
        :addTo(dragon_item)
    -- 等级
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("等级".." "..20) ,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,110, 85)
        :addTo(dragon_item)
    -- 经验
    display.newSprite("upgrade_experience_icon.png"):align(display.CENTER, 122 , 55)
        :addTo(dragon_item):setScale(0.5)
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("+"..667) ,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,140, 55)
        :addTo(dragon_item)

    -- 龙的活力
    display.newSprite("dragon_lv_icon.png"):align(display.CENTER, 122 , 20)
        :addTo(dragon_item):setScale(0.9)
    -- 突袭前的龙的活力值
    local a_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "200/",
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,140, 20)
        :addTo(dragon_item)
    -- 本次突袭龙消耗的活力值
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("-"..50) ,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x980101)
    }):align(display.LEFT_CENTER,a_label:getContentSize().width+142, 20)
        :addTo(dragon_item)

    return dragon_item
end
function GameUIStrikeReport:CreateReportOfEnemy()
    local item = self.details_view:newItem()
    item:setItemSize(540,34)
    item:addContent(
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("敌方情报") ,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER,0, 17)
    )
    self.details_view:addItem(item)
    -- 敌方资源产量
    self:CreateEnemyResource()
    -- 敌方军事水平
    self:CreateEnemyTechnology()
    -- 敌方龙的装备
    self:CreateDragonEquipments()
    -- 敌方龙的技能
    self:CreateDragonSkills()
end
function GameUIStrikeReport:CreateEnemyResource()
    local r_tip_height = 36

    -- 敌方资源列表部分高度
    local r_count = #self:GetTextEnemyResource()
    local r_list_height = r_count * r_tip_height

    -- 敌方资源列表
    local group = self:CreateBigBackGround(r_list_height+37,_("资源产量"))
    local group_width , group_height = 552,r_list_height+50

    -- 构建所有资源标签项
    local r_item_bg_color_flag = true
    local added_r_item_count = 0
    for k,r_parms in pairs(self:GetTextEnemyResource()) do
        local r_item_bg_image = r_item_bg_color_flag and "back_ground_546X36_1.png" or "back_ground_546X36_2.png"
        local r_item_bg = display.newSprite(r_item_bg_image)
            :align(display.TOP_CENTER, group_width/2, r_list_height-r_tip_height*added_r_item_count+4)
            :addTo(group)
        local r_icon = display.newSprite(r_parms.icon, 30, 18):addTo(r_item_bg)
        r_icon:setScale(40/r_icon:getContentSize().width)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_parms.resource_type,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,80,18):addTo(r_item_bg)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_parms.value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.RIGHT_CENTER,group_width-30,18):addTo(r_item_bg)

        added_r_item_count = added_r_item_count + 1
        r_item_bg_color_flag = not r_item_bg_color_flag
    end


    local item = self.details_view:newItem()
    item:setItemSize(group_width , group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end
function GameUIStrikeReport:GetTextEnemyResource()
    return {
        {
            resource_type = _("粮食"),
            icon="food_icon.png",
            value = "X "..100,
        },
        {
            resource_type = _("木材"),
            icon="wood_icon.png",
            value = "X "..100,
        },
        {
            resource_type = _("石料"),
            icon="stone_icon.png",
            value = "X "..100,
        },
        {
            resource_type = _("铁矿"),
            icon="iron_icon.png",
            value = "X "..100,
        },
    }
end

function GameUIStrikeReport:CreateEnemyTechnology()
    local r_tip_height = 36

    -- 敌方科技列表部分高度
    local r_count = #self:GetTextEnemyTechnology()
    local r_list_height = r_count * r_tip_height

    -- 敌方科技列表
    local group = self:CreateBigBackGround(r_list_height+37,_("军事科技水平"))
    local group_width , group_height = 552,r_list_height+50

    -- 构建所有科技标签项
    local r_item_bg_color_flag = true
    local added_r_item_count = 0
    for k,r_parms in pairs(self:GetTextEnemyTechnology()) do
        local r_item_bg_image = r_item_bg_color_flag and "back_ground_546X36_1.png" or "back_ground_546X36_2.png"
        local r_item_bg = display.newSprite(r_item_bg_image)
            :align(display.TOP_CENTER, group_width/2, r_list_height-r_tip_height*added_r_item_count+4)
            :addTo(group)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_parms.tech_type,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,10,18):addTo(r_item_bg)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_parms.value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.RIGHT_CENTER,group_width-30,18):addTo(r_item_bg)

        added_r_item_count = added_r_item_count + 1
        r_item_bg_color_flag = not r_item_bg_color_flag
    end


    local item = self.details_view:newItem()
    item:setItemSize(group_width , group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end
function GameUIStrikeReport:GetTextEnemyTechnology()
    return {
        {
            tech_type = _("步兵科技"),
            value = "X "..100,
        },
        {
            tech_type = _("弓箭手科技"),
            value = "X "..100,
        },
        {
            tech_type = _("骑兵科技"),
            value = "X "..100,
        },
        {
            tech_type = _("投石车科技"),
            value = "X "..100,
        },
    }
end
function GameUIStrikeReport:CreateDragonSkills()
    local r_tip_height = 36

    -- 敌方龙技能列表部分高度
    local r_count = #self:GetDragonSkills()
    local r_list_height = r_count * r_tip_height

    -- 敌方龙技能列表
    local group = self:CreateBigBackGround(r_list_height+37,_("龙的技能"))
    local group_width , group_height = 552,r_list_height+50

    -- 构建所有龙技能标签项
    local r_item_bg_color_flag = true
    local added_r_item_count = 0
    for k,r_parms in pairs(self:GetDragonSkills()) do
        local r_item_bg_image = r_item_bg_color_flag and "back_ground_546X36_1.png" or "back_ground_546X36_2.png"
        local r_item_bg = display.newSprite(r_item_bg_image)
            :align(display.TOP_CENTER, group_width/2, r_list_height-r_tip_height*added_r_item_count+4)
            :addTo(group)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_parms.skill_name,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,10,18):addTo(r_item_bg)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_parms.skill_level,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.RIGHT_CENTER,group_width-30,18):addTo(r_item_bg)

        added_r_item_count = added_r_item_count + 1
        r_item_bg_color_flag = not r_item_bg_color_flag
    end


    local item = self.details_view:newItem()
    item:setItemSize(group_width , group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end
function GameUIStrikeReport:GetDragonSkills()
    return {
        {
            skill_name = _("技能名"),
            skill_level = "Level "..100,
        },
        {
            skill_name = _("技能名"),
            skill_level = "Level "..100,
        },
        {
            skill_name = _("技能名"),
            skill_level = "Level "..100,
        },
        {
            skill_name = _("技能名"),
            skill_level = "Level "..100,
        },
    }
end
function GameUIStrikeReport:CreateDragonEquipments()
    local r_tip_height = 36

    -- 敌方龙装备列表部分高度
    local r_count = #self:GetDragonEquipments()
    local r_list_height = r_count * r_tip_height

    -- 敌方龙装备列表
    local group = self:CreateBigBackGround(r_list_height+37,_("龙的装备"))
    local group_width , group_height = 552,r_list_height+50

    -- 构建所有龙装备标签项
    local r_item_bg_color_flag = true
    local added_r_item_count = 0
    for k,r_parms in pairs(self:GetDragonEquipments()) do
        local r_item_bg_image = r_item_bg_color_flag and "back_ground_546X36_1.png" or "back_ground_546X36_2.png"
        local r_item_bg = display.newSprite(r_item_bg_image)
            :align(display.TOP_CENTER, group_width/2, r_list_height-r_tip_height*added_r_item_count+4)
            :addTo(group)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_parms.equipments_name,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,10,18):addTo(r_item_bg)

        StarBar.new({
            max = 5,
            bg = "Stars_bar_bg.png",
            fill = "Stars_bar_highlight.png",
            num = r_parms.equipments_level,
            margin = 0,
            direction = StarBar.DIRECTION_HORIZONTAL,
            scale = 0.6,
        }):addTo(r_item_bg):align(display.RIGHT_CENTER,group_width-50, 18)

        added_r_item_count = added_r_item_count + 1
        r_item_bg_color_flag = not r_item_bg_color_flag
    end


    local item = self.details_view:newItem()
    item:setItemSize(group_width , group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end
function GameUIStrikeReport:GetDragonEquipments()
    return {
        {
            equipments_name = _("头部装备名"),
            equipments_level = 1,
        },
        {
            equipments_name = _("胸部装备名"),
            equipments_level = 2,
        },
        {
            equipments_name = _("尾部装备名"),
            equipments_level = 3,
        },
        {
            equipments_name = _("手部装备名"),
            equipments_level = 4,
        },
        {
            equipments_name = _("法球装备名"),
            equipments_level = 5,
        },

    }
end
-- 创建 宽度为258的 UI框
function GameUIStrikeReport:CreateSmallBackGround(height,title)
    local r_bg = display.newNode()
    r_bg:setContentSize(cc.size(258,height))
    -- 上中下三段的图片高度
    local u_height,m_height,b_height = 12 , 1 , 12
    if title then
        -- title bg
        local t_bg = display.newSprite("report_title_252X30.png"):align(display.CENTER_TOP, 129, height-3):addTo(r_bg,2)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = title ,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER,t_bg:getContentSize().width/2, 15):addTo(t_bg)
    end
    --top
    display.newSprite("back_ground_258X12_top.png"):align(display.LEFT_TOP, 0, height):addTo(r_bg)
    --bottom
    display.newSprite("back_ground_258X12_bottom.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(r_bg)

    --center
    local need_filled_height = height-(u_height+b_height) --中间部分需要填充的高度
    local center_y = b_height -- 中间部分起始 y 坐标
    local  next_y = b_height
    -- 需要填充的剩余高度大于中间部分图片原始高度时，直接复制即可
    while need_filled_height>=m_height do
        display.newSprite("back_ground_258X1_mid.png"):align(display.LEFT_BOTTOM, 0, next_y):addTo(r_bg)
        need_filled_height = need_filled_height - m_height
        -- copy_count = copy_count + 1
        next_y = next_y+m_height
    end
    return r_bg
end
-- 创建 宽度为552的 UI框
function GameUIStrikeReport:CreateBigBackGround(height,title)
    local r_bg = display.newNode()
    r_bg:setContentSize(cc.size(552,height))
    -- 上中下三段的图片高度
    local u_height,m_height,b_height = 12 , 1 , 10
    -- title bg
    local t_bg = display.newSprite("report_title_546X30.png"):align(display.CENTER_TOP, 276, height-3):addTo(r_bg,2)
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = title ,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER,t_bg:getContentSize().width/2, 15):addTo(t_bg)
    --top
    display.newSprite("back_ground_552X12_top.png"):align(display.LEFT_TOP, 0, height):addTo(r_bg)
    --bottom
    display.newSprite("back_ground_552X10_bottom.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(r_bg)

    --center
    local need_filled_height = height-(u_height+b_height) --中间部分需要填充的高度
    local center_y = b_height -- 中间部分起始 y 坐标
    local  next_y = b_height
    -- 需要填充的剩余高度大于中间部分图片原始高度时，直接复制即可
    while need_filled_height>=m_height do
        display.newSprite("back_ground_552X1_mid.png"):align(display.LEFT_BOTTOM, 0, next_y):addTo(r_bg)
        need_filled_height = need_filled_height - m_height
        -- copy_count = copy_count + 1
        next_y = next_y+m_height
    end
    return r_bg
end

function GameUIStrikeReport:onExit()

end

return GameUIStrikeReport





















