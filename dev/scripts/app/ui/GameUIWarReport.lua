local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSoldierBox = import("..widget.WidgetSoldierBox")
local WidgetClickPageView = import("..widget.WidgetClickPageView")
local window = import("..utils.window")
local UILib = import("..ui.UILib")



local GameUIWarReport = class("GameUIWarReport", function ()
    return display.newColorLayer(UIKit:hex2c4b(0x7a000000))
end)

function GameUIWarReport:ctor(report)
    self:setNodeEventEnabled(true)
    self.report = report
end

function GameUIWarReport:onEnter()
    local report_body = WidgetUIBackGround.new({height=800}):addTo(self):align(display.TOP_CENTER,display.cx,display.top-100)
    local rb_size = report_body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height)
        :addTo(report_body)
    local title_label = UIKit:ttfLabel(
        {
            text = _("Attack Successful"),
            size = 22,
            color = 0xffedae
        }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2)
        :addTo(title)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent()
        end):align(display.CENTER, title:getContentSize().width-10, title:getContentSize().height-10)
        :addTo(title):addChild(display.newSprite("X_3.png"))
    -- 战争结果图片
    local war_result_image = display.newSprite("report_failure.png")
        :align(display.CENTER_TOP, rb_size.width/2, rb_size.height-16)
        :addTo(report_body)
    -- 标记
    local mark_btn = WidgetPushButton.new({normal = "blue_btn_up_142x39.png",pressed = "blue_btn_down_142x39.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("标记"),
            size = 22,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.RIGHT_CENTER,war_result_image:getContentSize().width - 10,war_result_image:getContentSize().height/2)
        :addTo(war_result_image)

    -- 战斗评星
    local star = 3
    local origin_x = war_result_image:getContentSize().width - 100
    local gap_x = 30
    for i=1,star do
        display.newSprite("star_18x16.png"):align(display.CENTER,origin_x+(i-1)*gap_x,15)
            :addTo(war_result_image)
    end
    -- 战斗发生时间
    local war_result_label = UIKit:ttfLabel(
        {
            text = _("2015.5.13 13:30"),
            size = 18,
            color = 0xffedae
        }):align(display.LEFT_CENTER, 10, 15)
        :addTo(war_result_image)
    local war_result_label = UIKit:ttfLabel(
        {
            text = _("Battle at CitrName (182,450)"),
            size = 18,
            color = 0x797154
        }):align(display.LEFT_CENTER, 20, rb_size.height-170)
        :addTo(report_body)

    local war_result_label = UIKit:ttfLabel(
        {
            text = _("战斗地形：沙漠（派出红龙获得额外力量）"),
            size = 18,
            color = 0x797154
        }):align(display.LEFT_CENTER, 20, rb_size.height-195)
        :addTo(report_body)

    -- 战争战报详细内容展示
    self.details_view = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(0, 70, 588, 505),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(report_body):pos(10, 5)

    -- 战利品部分
    self:CreateBootyPart()

    -- 战斗统计部分
    self:CreateWarStatisticsPart()
    -- 击杀敌方
    self:KillEnemy()
    -- 我方损失
    self:OurLose()


    self.details_view:reload()

    -- 回放按钮
    local replay_label = UIKit:ttfLabel({
        text = _("回放"),
        size = 20,
        color = 0xfff3c7})

    replay_label:enableShadow()
    WidgetPushButton.new(
        {normal = "keep_unlocked_button_normal.png", pressed = "keep_unlocked_button_pressed.png"},
        {scale9 = false}
    ):setButtonLabel(replay_label)
        :addTo(report_body):align(display.CENTER, report_body:getContentSize().width-120, rb_size.height-186)
        :onButtonClicked(function(event)
            end)

    -- 删除按钮
    local delete_label = UIKit:ttfLabel({
        text = _("删除"),
        size = 20,
        color = 0xfff3c7})
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

        end):addTo(report_body):pos(rb_size.width-48, 37)
end

function GameUIWarReport:GetTextBooty()
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

function GameUIWarReport:CreateBootyPart()
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
        UIKit:ttfLabel({
            text = booty_parms.resource_type,
            size = 22,
            color = 0x403c2f
        }):align(display.LEFT_CENTER,80,23):addTo(booty_item_bg)
        UIKit:ttfLabel({
            text = booty_parms.value,
            size = 22,
            color = 0x288400
        }):align(display.RIGHT_CENTER,booty_list_bg_size.width-30,23):addTo(booty_item_bg)

        added_booty_item_count = added_booty_item_count + 1
        booty_item_bg_color_flag = not booty_item_bg_color_flag
    end

    local booty_title_bg = display.newSprite("upgrade_resources_title.png")
        :align(display.CENTER_BOTTOM, 0,booty_list_bg:getContentSize().height/2)

    booty_group:addWidget(booty_title_bg)

    UIKit:ttfLabel({
        text = _("战利品") ,
        size = 24,
        color = 0xffedae
    }):align(display.CENTER,booty_title_bg:getContentSize().width/2, 25):addTo(booty_title_bg)
    local item = self.details_view:newItem()
    -- print("战利品框大小",booty_list_bg:getContentSize().width,booty_list_bg:getContentSize().height+booty_title_bg:getContentSize().height)
    item:setItemSize(booty_list_bg:getContentSize().width,booty_list_bg:getContentSize().height+booty_title_bg:getContentSize().height+50)
    item:addContent(booty_group)
    self.details_view:addItem(item)
end

function GameUIWarReport:CreateWarStatisticsPart()
    local war_s_label_item = self.details_view:newItem()
    war_s_label_item:setItemSize(540,22)
    local g = cc.ui.UIGroup.new()
    g:addWidget(UIKit:ttfLabel({
        text = _("战斗统计") ,
        size = 22,
        color = 0x403c2f
    }):align(display.CENTER, 0, 20))
    war_s_label_item:addContent(g)
    self.details_view:addItem(war_s_label_item)
    -- 交战双方信息
    self:CreateBelligerents()
    -- 部队信息
    self:CreateArmyGroup()
end

-- 交战双方信息
function GameUIWarReport:CreateBelligerents()
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

function GameUIWarReport:CreateBelligerentsItem(height,title)
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
    -- -- 分割线
    -- local line = display.newScale9Sprite("divide_line_489x2.png", 0, height-110,cc.size(258,2))
    --     :align(display.LEFT_CENTER)
    --     :addTo(player_item)
    -- -- 人口名称
    -- UIKit:ttfLabel({
    --     text = _("population ") ,
    --     size = 18,
    --     color = 0x403c2f
    -- }):align(display.LEFT_CENTER,110, height-130)
    --     :addTo(player_item)

    -- local before_war_num = UIKit:ttfLabel({
    --     text = _("2000 /") ,
    --     size = 18,
    --     color = 0x403c2f
    -- }):align(display.LEFT_CENTER,110,  height-160)
    --     :addTo(player_item)
    -- UIKit:ttfLabel({
    --     text = _("-1000") ,
    --     size = 18,
    --     color = 0x980101
    -- }):align(display.LEFT_CENTER,110+before_war_num:getContentSize().width,  height-160)
    --     :addTo(player_item)


    return player_item
end

function GameUIWarReport:CreateArmyGroup()
    local group = cc.ui.UIGroup.new()

    local group_width,group_height = 540,268
    local self_army_item = self:CreateArmyItem(_("你的部队"))
        :align(display.CENTER, -group_width/2+129, 0)

    group:addWidget(self_army_item)

    local enemy_army_item = self:CreateArmyItem(_("敌方部队"))
        :align(display.CENTER, group_width/2-129, 0)
    group:addWidget(enemy_army_item)
    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end

function GameUIWarReport:CreateArmyItem(title)
    local w,h = 258,256
    local army_item = display.newSprite("back_ground_258x256.png")

    local t_bg = display.newSprite("report_title_252X30.png"):align(display.CENTER_TOP, w/2, h-3)
        :addTo(army_item)
    UIKit:ttfLabel({
        text = title ,
        size = 20,
        color = 0xffedae
    }):align(display.CENTER,t_bg:getContentSize().width/2, 15):addTo(t_bg)

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
            bg_image = "back_ground_254x28_1.png",
            title = "Troops",
            value = "2454",
        },
        {
            bg_image = "back_ground_254x28_2.png",
            title = "Survived",
            value = "2454",
        },
        {
            bg_image = "back_ground_254x28_1.png",
            title = "Wounded",
            value = "2454",
        },
        {
            bg_image = "back_ground_254x28_2.png",
            title = "Killed",
            value = "2454",
            color = 0x7e0000,
        },
        {
            bg_image = "back_ground_254x28_1.png",
            title = "Red Dragon",
        },
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

    -- -- 龙的头像
    -- local dragonBg = display.newSprite("chat_hero_background.png"):align(display.CENTER, 50, height-90):addTo(army_item)
    -- dragonBg:setScale(0.8)
    -- local dragon = display.newSprite("head_dragon.png"):align(display.CENTER, 50, height-90)
    --     :addTo(army_item)
    -- -- 等级
    -- UIKit:ttfLabel({
    --     text = _("等级".." "..20) ,
    --     size = 18,
    --     color = 0x403c2f
    -- }):align(display.LEFT_CENTER,110, height-60)
    --     :addTo(army_item)
    -- -- 经验
    -- display.newSprite("upgrade_experience_icon.png"):align(display.CENTER, 122 , height-90)
    --     :addTo(army_item):setScale(0.5)
    -- UIKit:ttfLabel({
    --     text = _("+"..667) ,
    --     size = 18,
    --     color = 0x403c2f
    -- }):align(display.LEFT_CENTER,140,  height-90)
    --     :addTo(army_item)

    -- -- 龙的活力
    -- display.newSprite("dragon_lv_icon.png"):align(display.CENTER, 122 , height-125)
    --     :addTo(army_item):setScale(0.9)
    -- -- 战争前的龙的活力值
    -- local a_label = UIKit:ttfLabel({
    --     text = "200/",
    --     size = 18,
    --     color = 0x403c2f
    -- }):align(display.LEFT_CENTER,140, height-125)
    --     :addTo(army_item)
    -- -- 本次战争龙消耗的活力值
    -- UIKit:ttfLabel({
    --     text = _("-"..50) ,
    --     size = 18,
    --     color = 0x980101
    -- }):align(display.LEFT_CENTER,a_label:getContentSize().width+142, height-125)
    --     :addTo(army_item)

    -- local soldier_item_height = 68
    -- local orgion_height = height-140
    -- local added_soldier_count = 0
    -- for k,soldier_parms in pairs(soldiers) do
    --     -- 分割线
    --     local line = display.newScale9Sprite("divide_line_489x2.png", 0, orgion_height-added_soldier_count*soldier_item_height,cc.size(258,2))
    --         :align(display.LEFT_CENTER)
    --         :addTo(army_item)

    --     -- 士兵头像
    --     local soldier_icon = display.newSprite("soldier_crossbowman_2.png"):align(display.TOP_LEFT, 10, -5):addTo(line,2)
    --     soldier_icon:setScale(58/soldier_icon:getContentSize().height)
    --     -- 士兵名字
    --     UIKit:ttfLabel({
    --         text = soldier_parms.soldier_name ,
    --         size = 18,
    --         color = 0x403c2f
    --     }):align(display.LEFT_CENTER,80, -20)
    --         :addTo(line,2)
    --     -- 战前士兵数量
    --     UIKit:ttfLabel({
    --         text = _(""..soldier_parms.soldier_original_num) ,
    --         size = 18,
    --         color = 0x403c2f
    --     }):align(display.LEFT_CENTER,80, -50)
    --         :addTo(line,2)
    --     -- 战后士兵数量
    --     UIKit:ttfLabel({
    --         text = _("/-"..soldier_parms.soldier_after_war_num) ,
    --         size = 18,
    --         color = 0x980101
    --     }):align(display.LEFT_CENTER,110, -50)
    --         :addTo(line,2)
    --     added_soldier_count = added_soldier_count + 1
    --     -- 最后一条信息并且是条目较少的士兵信息框后多添加一条分割线
    --     local self_soldier_count = #self:GetTestSelfSoldiers()
    --     local enemy_soldier_count = #self:GetTestEnemySoldiers()
    --     local max_soldiers_count = self_soldier_count>enemy_soldier_count and self_soldier_count or enemy_soldier_count
    --     if added_soldier_count==#soldiers and max_soldiers_count>added_soldier_count then
    --         display.newScale9Sprite("divide_line_489x2.png", 0, orgion_height-added_soldier_count*soldier_item_height,cc.size(258,2))
    --             :align(display.LEFT_CENTER)
    --             :addTo(army_item)
    --     end
    -- end
    return army_item
end

-- function GameUIWarReport:GetTestSelfSoldiers()
--     return {
--         {
--             soldier_type = _("ranger"),
--             soldier_name = _("ranger"),
--             soldier_original_num = 1,
--             soldier_after_war_num = 1,
--         },
--         {
--             soldier_type = _("ranger"),
--             soldier_name = _("ranger"),
--             soldier_original_num = 1,
--             soldier_after_war_num = 1,
--         },
--         {
--             soldier_type = _("ranger"),
--             soldier_name = _("ranger"),
--             soldier_original_num = 1,
--             soldier_after_war_num = 1,
--         },
--     }
-- end
function GameUIWarReport:GetTestEnemySoldiers()
    return {
        {
            soldier_type = _("ranger"),
            soldier_name = _("ranger"),
            soldier_original_num = 1,
            soldier_after_war_num = 1,
        },
        {
            soldier_type = _("ranger"),
            soldier_name = _("ranger"),
            soldier_original_num = 1,
            soldier_after_war_num = 1,
        },
    -- {
    --     soldier_type = _("ranger"),
    --     soldier_name = _("ranger"),
    --     soldier_original_num = 1,
    --     soldier_after_war_num = 1,
    -- },
    }
end

-- function GameUIWarReport:CreateTechnology()
--     local group = cc.ui.UIGroup.new()
--     local self_technology = self:GetTestSelfTechnology()
--     local enemy_technology = self:GetTestEnemyTechnology()
--     local self_technology_count = #self:GetTestSelfTechnology()
--     local enemy_technology_count = #self:GetTestEnemyTechnology()
--     local max_technology_count = self_technology_count>enemy_technology_count and self_technology_count or enemy_technology_count
--     local item_height = 60
--     local group_width,group_height = 540,33+max_technology_count*item_height
--     local self_technology_item = self:CreateTechnologyItem(33+max_technology_count*item_height,_("你的科技"),self_technology):align(display.CENTER, -group_width/2+129, 0)

--     group:addWidget(self_technology_item)

--     local enemy_technology_item = self:CreateTechnologyItem(33+#self:GetTestSelfTechnology()*item_height,_("敌方科技"),enemy_technology)
--         :align(display.CENTER, group_width/2-129, 0)
--     group:addWidget(enemy_technology_item)
--     local item = self.details_view:newItem()
--     item:setItemSize(group_width,group_height)
--     item:addContent(group)
--     self.details_view:addItem(item)
-- end

-- function GameUIWarReport:CreateTechnologyItem(height,title,technology)
--     local technology_item = self:CreateSmallBackGround(height,title)

--     local technology_item_height = 60
--     local orgion_height = height-33
--     local added_technology_count = 0
--     for k,tech_parms in pairs(technology) do
--         -- 分割线
--         local line = display.newScale9Sprite("divide_line_489x2.png", 0, orgion_height-added_technology_count*technology_item_height,cc.size(258,2))
--             :align(display.LEFT_CENTER)
--             :addTo(technology_item)


--         -- 科技名字
--         UIKit:ttfLabel({
--             text = tech_parms.tech_type ,
--             size = 18,
--             color = 0x403c2f
--         }):align(display.LEFT_CENTER,10, -20)
--             :addTo(line,2)
--         -- 科技水平值
--         UIKit:ttfLabel({
--             text = _(""..tech_parms.value) ,
--             size = 18,
--             color = 0x403c2f
--         }):align(display.LEFT_CENTER,10, -40)
--             :addTo(line,2)

--         added_technology_count = added_technology_count + 1
--         -- 最后一条信息并且是条目较少的科技信息框后多添加一条分割线
--         local self_tech_count = #self:GetTestSelfTechnology()
--         local enemy_tech_count = #self:GetTestEnemyTechnology()
--         local max_tech_count = self_tech_count>enemy_tech_count and self_tech_count or enemy_tech_count
--         if added_technology_count==#technology and max_tech_count>added_technology_count then
--             display.newScale9Sprite("divide_line_489x2.png", 0, orgion_height-added_technology_count*technology_item_height,cc.size(258,2))
--                 :align(display.LEFT_CENTER)
--                 :addTo(technology_item)
--         end
--     end
--     return technology_item
-- end
-- function GameUIWarReport:GetTestSelfTechnology()
--     return {
--         {
--             tech_type = _("步兵科技"),
--             value = "X "..100,
--         },
--         {
--             tech_type = _("弓箭手科技"),
--             value = "X "..100,
--         },
--         {
--             tech_type = _("骑兵科技"),
--             value = "X "..100,
--         },
--         {
--             tech_type = _("投石车科技"),
--             value = "X "..100,
--         },
--     }
-- end

-- function GameUIWarReport:GetTestEnemyTechnology()
--     return {
--         {
--             tech_type = _("步兵科技"),
--             value = "X "..100,
--         },
--         {
--             tech_type = _("弓箭手科技"),
--             value = "X "..100,
--         },
--         {
--             tech_type = _("骑兵科技"),
--             value = "X "..100,
--         },
--     -- {
--     --     tech_type = _("投石车科技"),
--     --     value = "X "..100,
--     -- },
--     }
-- end


-- 击杀敌方
function GameUIWarReport:KillEnemy()
    local war_s_label_item = self.details_view:newItem()
    war_s_label_item:setItemSize(540,40)
    local g = cc.ui.UIGroup.new()
    g:addWidget(UIKit:ttfLabel({
        text = _("击杀敌方") ,
        size = 22,
        color = 0x403c2f
    }):align(display.CENTER, 0, 0))
    war_s_label_item:addContent(g)
    self.details_view:addItem(war_s_label_item)

    self:CreateSoldierInfo()
end
-- 我方损失
function GameUIWarReport:OurLose()
    local war_s_label_item = self.details_view:newItem()
    war_s_label_item:setItemSize(540,40)
    local g = cc.ui.UIGroup.new()
    g:addWidget(UIKit:ttfLabel({
        text = _("我方损失") ,
        size = 22,
        color = 0x403c2f
    }):align(display.CENTER, 0, 0))
    war_s_label_item:addContent(g)
    self.details_view:addItem(war_s_label_item)

    self:CreateSoldierInfo()

end

function GameUIWarReport:CreateSoldierInfo()
    local item = self.details_view:newItem()
    item:setItemSize(540,210)
    -- 背景框
    local bg = WidgetUIBackGround.new({
        width = 550,
        height = 202,
        top_img = "back_ground_top_2.png",
        bottom_img = "back_ground_bottom_2.png",
        mid_img = "back_ground_mid_2.png",
        u_height = 10,
        b_height = 10,
        m_height = 1,
    })

    local content = WidgetClickPageView.new({bg=bg})

    for i=1,10 do

        local page_item = content:newItem()
        self:CreateSoldiersInfo():align(display.CENTER, -4,25):addTo(page_item)
        self:CreateSoldiersInfo():align(display.CENTER, 116,25):addTo(page_item)
        self:CreateSoldiersInfo():align(display.CENTER, 236,25):addTo(page_item)
        self:CreateSoldiersInfo():align(display.CENTER, 356,25):addTo(page_item)

        content:addItem(page_item)
    end
    content:pos(50,101)
    content:reload()
    item:addContent(content)
    self.details_view:addItem(item)

end

function GameUIWarReport:CreateSoldiersInfo()
    local soldier_level = 3
    local soldier_type ="catapult"
    local soldier_head_bg  = display.newSprite(UILib.soldier_bg[soldier_level])

    local soldier_ui_config = UILib.soldier_image[soldier_type][soldier_level]


    local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.LEFT_BOTTOM,0,10)
    soldier_head_icon:scale(130/soldier_head_icon:getContentSize().height)
    soldier_head_bg:addChild(soldier_head_icon)

    UIKit:ttfLabel({
        text = "20000" ,
        size = 18,
        color = 0x403c2f
    }):align(display.CENTER,soldier_head_bg:getContentSize().width/2, -10):addTo(soldier_head_bg)
    UIKit:ttfLabel({
        text = "-500" ,
        size = 18,
        color = 0x980101
    }):align(display.CENTER,soldier_head_bg:getContentSize().width/2, -30):addTo(soldier_head_bg)

    return soldier_head_bg
end

-- 创建 宽度为258的 UI框
function GameUIWarReport:CreateSmallBackGround(height,title)
    local r_bg = display.newNode()
    r_bg:setContentSize(cc.size(258,height))
    -- 上中下三段的图片高度
    local u_height,m_height,b_height = 12 , 1 , 12
    -- title bg
    if title then
        local t_bg = display.newSprite("report_title_252X30.png"):align(display.CENTER_TOP, 129, height-3):addTo(r_bg,2)
        UIKit:ttfLabel({
            text = title ,
            size = 20,
            color = 0xffedae
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

function GameUIWarReport:onExit()

end

return GameUIWarReport














