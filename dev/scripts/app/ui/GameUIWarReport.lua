local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetSoldierBox = import("..widget.WidgetSoldierBox")
local WidgetClickPageView = import("..widget.WidgetClickPageView")
local UICheckBoxButton = import(".UICheckBoxButton")
local window = import("..utils.window")
local UILib = import("..ui.UILib")
local Localize = import("..utils.Localize")


local GameUIWarReport = UIKit:createUIClass("GameUIWarReport", "UIAutoClose")


function GameUIWarReport:ctor(report)
    GameUIWarReport.super.ctor(self)
    self.body = WidgetUIBackGround.new({height=800}):align(display.TOP_CENTER,display.cx,display.top-100)
    self:addTouchAbleChild(self.body)
    self:setNodeEventEnabled(true)
    self.report = report
end

function GameUIWarReport:onEnter()
    GameUIWarReport.super.onEnter(self)
    local report = self.report
    local report_body = self.body
    local rb_size = report_body:getContentSize()
    local title = display.newSprite("title_blue_600x52.png"):align(display.CENTER, rb_size.width/2, rb_size.height+10)
        :addTo(report_body)
    local title_label = UIKit:ttfLabel(
        {
            text =self:GetReportTitle(),
            size = 22,
            color = 0xffedae
        }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2)
        :addTo(title)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent()
        end):align(display.CENTER, title:getContentSize().width-20, title:getContentSize().height-20)
        :addTo(title)
    -- 战争结果图片
    local result_img = self.report:GetReportResult() and "report_victory.png" or "report_failure.png"
    local war_result_image = display.newSprite(result_img)
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


    -- 战斗发生时间
    local war_result_label = UIKit:ttfLabel(
        {
            text = GameUtils:formatTimeStyle2(math.floor(report.createTime/1000)),
            size = 18,
            color = 0xffedae
        }):align(display.LEFT_CENTER, 10, 15)
        :addTo(war_result_image)
    local war_result_label = UIKit:ttfLabel(
        {
            text = self:GetFightTarget(),
            size = 18,
            color = 0x797154
        }):align(display.LEFT_CENTER, 20, rb_size.height-170)
        :addTo(report_body)



    local terrain = report:GetAttackTarget().terrain
    local war_result_label = UIKit:ttfLabel(
        {
            text = string.format(_("战斗地形:%s(派出%s获得额外力量)"),Localize.terrain[terrain],terrain=="grassLand" and _("绿龙") or terrain=="desert" and _("红龙") or terrain=="iceField" and _("蓝龙")),
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

    -- 城墙
    self:CreateWallPart()

    self.details_view:reload()

    -- 回放按钮
    local replay_label = UIKit:ttfLabel({
        text = _("回放"),
        size = 20,
        color = 0xfff3c7})

    replay_label:enableShadow()
    WidgetPushButton.new(
        {normal = "yellow_btn_up_149x47.png", pressed = "yellow_btn_down_149x47.png"},
        {scale9 = false}
    ):setButtonLabel(replay_label)
        :addTo(report_body):align(display.CENTER, report_body:getContentSize().width-120, rb_size.height-186)
        :onButtonClicked(function(event)
            UIKit:newGameUI("GameUIReplay",clone(report)):AddToCurrentScene(true)
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
            NetManager:getDeleteReportsPromise({report.id}):done(function ()
                self:removeFromParent()
            end)
        end)
    -- 收藏按钮
    local saved_button = UICheckBoxButton.new({
        off = "mail_saved_button_normal.png",
        off_pressed = "mail_saved_button_normal.png",
        off_disabled = "mail_saved_button_normal.png",
        on = "mail_saved_button_pressed.png",
        on_pressed = "mail_saved_button_pressed.png",
        on_disabled = "mail_saved_button_pressed.png",
    }):onButtonStateChanged(function(event)
        local target = event.target
        if target:isButtonSelected() then
            NetManager:getSaveReportPromise(report.id):catch(function(err)
                target:setButtonSelected(false,true)
                dump(err:reason())
            end)
        else
            NetManager:getUnSaveReportPromise(report.id):catch(function(err)
                target:setButtonSelected(true,true)
                dump(err:reason())
            end)
        end
    end):addTo(report_body):pos(rb_size.width-48, 37)
        :setButtonSelected(report:IsSaved(),true)

end

function GameUIWarReport:GetBooty()
    local booty = {}
    for k,v in pairs(self:GetRewards()) do
        table.insert(booty, {
            resource_type = Localize.fight_reward[v.name],
            icon= UILib.resource[v.name],
            value = v.count
        })
    end
    return booty
end

function GameUIWarReport:CreateBootyPart()
    local item_width = 540
    -- 战利品列表部分高度
    local booty_count = #self:GetBooty()
    local booty_group = display.newNode()
    -- cc.ui.UIGroup.new()
    local booty_list_bg
    if booty_count>0 then
        local item_height = 46
        local booty_list_height = booty_count * item_height

        -- 战利品列表
        booty_list_bg = WidgetUIBackGround.new({
            width = item_width,
            height = booty_list_height+16,
            top_img = "back_ground_568X14_top.png",
            bottom_img = "back_ground_568X14_top.png",
            mid_img = "back_ground_568X1_mid.png",
            u_height = 14,
            b_height = 14,
            m_height = 1,
            b_flip = true,
        }):align(display.CENTER,0,-25)
        local booty_list_bg_size = booty_list_bg:getContentSize()
        booty_group:addChild(booty_list_bg)

        -- 构建所有战利品标签项
        local booty_item_bg_color_flag = true
        local added_booty_item_count = 0
        for k,booty_parms in pairs(self:GetBooty()) do
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
                color = booty_parms.value>0 and 0x288400 or 0x7e0000
            }):align(display.RIGHT_CENTER,booty_list_bg_size.width-30,23):addTo(booty_item_bg)

            added_booty_item_count = added_booty_item_count + 1
            booty_item_bg_color_flag = not booty_item_bg_color_flag
        end
    end
    local booty_title_bg = display.newSprite("alliance_evnets_title_548x50.png")
        :align(display.CENTER_BOTTOM, 0,booty_list_bg and booty_list_bg:getContentSize().height/2-25 or -25)

    booty_group:addChild(booty_title_bg)


    UIKit:ttfLabel({
        text = booty_count > 0 and _("战利品") or _("无战利品") ,
        size = 24,
        color = 0xffedae
    }):align(display.CENTER,booty_title_bg:getContentSize().width/2, 25):addTo(booty_title_bg)
    local item = self.details_view:newItem()
    item:setItemSize(item_width, (booty_list_bg and booty_list_bg:getContentSize().height or 0) +booty_title_bg:getContentSize().height)
    item:addContent(booty_group)
    self.details_view:addItem(item)
end

function GameUIWarReport:CreateWarStatisticsPart()
    self:FightWithHelpDefencePlayerReports()
    self:FightWithDefencePlayerReports()
end

function GameUIWarReport:FightWithHelpDefencePlayerReports()
    local report = self.report
    if report:IsHasHelpDefencePlayer() then
        local war_s_label_item = self.details_view:newItem()
        war_s_label_item:setItemSize(540,40)
        local g = cc.ui.UIGroup.new()
        g:addWidget(UIKit:ttfLabel({
            text = _("与协防方战斗统计") ,
            size = 22,
            color = 0x403c2f
        }):align(display.CENTER, 0, 0))
        war_s_label_item:addContent(g)
        self.details_view:addItem(war_s_label_item)
        -- 交战双方信息
        local left_player = report:GetMyPlayerData()
        local right_player = report:GetEnemyPlayerData()
        self:CreateBelligerents(left_player,right_player)
        -- 部队信息
        local left_player_troop = report:GetMyHelpFightTroop()

        local right_player_troop = report:GetEnemyHelpFightTroop()
        local left_player_dragon = report:GetMyHelpFightDragon()

        local right_player_dragon = report:GetEnemyHelpFightDragon()

        self:CreateArmyGroup(left_player_troop,right_player_troop,left_player_dragon,right_player_dragon)
        -- 击杀敌方
        if right_player_troop then
            self:KillEnemy(right_player_troop)
        end
        -- 我方损失
        if left_player_troop then
            self:OurLose(left_player_troop)
        end
    end
end
function GameUIWarReport:FightWithDefencePlayerReports()
    local report = self.report
    local war_s_label_item = self.details_view:newItem()
    war_s_label_item:setItemSize(540,40)
    local g = cc.ui.UIGroup.new()
    g:addWidget(UIKit:ttfLabel({
        text = _("防守方战斗统计") ,
        size = 22,
        color = 0x403c2f
    }):align(display.CENTER, 0, 0))
    war_s_label_item:addContent(g)
    self.details_view:addItem(war_s_label_item)
    -- 交战双方信息
    local left_player = report:GetMyPlayerData()
    local right_player = report:GetEnemyPlayerData()
    self:CreateBelligerents(left_player,right_player)
    -- 部队信息
    local left_player_troop = report:GetMyDefenceFightTroop()

    local right_player_troop = report:GetEnemyDefenceFightTroop()
    -- 龙信息
    local left_player_dragon = report:GetMyDefenceFightDragon()

    local right_player_dragon = report:GetEnemyDefenceFightDragon()
    -- RoundDatas
    local left_round = report:GetMyRoundDatas()

    local right_round = report:GetEnemyRoundDatas()
    if left_player_troop then
        self:CreateArmyGroup(left_player_troop,right_player_troop,left_player_dragon,right_player_dragon,left_round,right_round)
    end
    -- 击杀敌方
    if right_player_troop then
        self:KillEnemy(right_player_troop)
    end
    -- 我方损失
    if left_player_troop then
        self:OurLose(left_player_troop)
    end
end
function GameUIWarReport:CreateArmyGroup(l_troop,r_troop,l_dragon,r_dragon,left_round,right_round)
    local group = cc.ui.UIGroup.new()

    local group_width,group_height = 540,268

    local self_army_item = self:CreateArmyItem(_("你的部队"),l_troop,l_dragon,r_troop,left_round,right_round)
        :align(display.CENTER, -group_width/2+129, 0)

    group:addWidget(self_army_item)

    local enemy_army_item = self:CreateArmyItem(_("敌方部队"),r_troop,r_dragon,l_troop,right_round,left_round)
        :align(display.CENTER, group_width/2-129, 0)
    group:addWidget(enemy_army_item)
    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end

function GameUIWarReport:CreateArmyItem(title,troop,dragon,enemy_troop,round_datas,enemy_round_datas)
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
    local army_info
    if troop then
        local troopTotal,totalDamaged,killed,totalWounded = 0,0,0,0

        for k,v in pairs(troop) do
            troopTotal=troopTotal+v.count
        end
        for k,v in pairs(enemy_round_datas) do
            for _,data in pairs(v) do
                killed = killed+data.soldierDamagedCount
            end
        end
        for k,v in pairs(round_datas) do
            for _,data in pairs(v) do
                totalDamaged = totalDamaged+data.soldierDamagedCount
                totalWounded = totalWounded+data.soldierWoundedCount
            end
        end

        army_info = {
            {
                bg_image = "back_ground_254x28_1.png",
                title = _("Troops"),
                value = troopTotal,
            },
            {
                bg_image = "back_ground_254x28_2.png",
                title = _("Survived"),
                value = troopTotal-totalDamaged-totalWounded,
            },
            {
                bg_image = "back_ground_254x28_1.png",
                title = _("Wounded"),
                value = totalWounded,
            },
            {
                bg_image = "back_ground_254x28_2.png",
                title = _("Killed"),
                value = killed,
                color = 0x7e0000,
            },
            {
                bg_image = "back_ground_254x28_1.png",
                title = Localize.dragon[dragon.type],
            },
            {
                bg_image = "back_ground_254x28_2.png",
                title = _("Level"),
                value = dragon.level,
            },
            {
                bg_image = "back_ground_254x28_1.png",
                title = _("XP"),
                value = "+"..dragon.expAdd,
            },
            {
                bg_image = "back_ground_254x28_2.png",
                title = _("HP"),
                value = dragon.hp.."/-"..dragon.hpDecreased,
            },
        }
    else
        army_info = {
            {
                bg_image = "back_ground_254x28_1.png",
                title = _("无部队"),
            }
        }
    end


    local gap_y = 28
    local y_postion = h -30
    for k,v in pairs(army_info) do
        createInfoItem(v):addTo(army_item)
            :align(display.TOP_CENTER, w/2, y_postion)
        y_postion = y_postion - gap_y
    end
    return army_item
end
-- 交战双方信息
function GameUIWarReport:CreateBelligerents(left_player,right_player)
    local group = cc.ui.UIGroup.new()
    local group_width,group_height = 540,100
    local self_item = self:CreateBelligerentsItem(left_player)
        :align(display.CENTER, -group_width/2+129, 0)

    group:addWidget(self_item)

    local enemy_item = self:CreateBelligerentsItem(right_player)
        :align(display.CENTER, group_width/2-129, 0)
    group:addWidget(enemy_item)
    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end

function GameUIWarReport:CreateBelligerentsItem(player)
    local height = 100
    local player_item = self:CreateSmallBackGround(height)

    -- 玩家头像
    local heroBg = display.newSprite("chat_hero_background.png"):align(display.CENTER, 50, height/2):addTo(player_item)
    heroBg:setScale(0.6)
    local hero = display.newSprite(player.icon or UILib.village[player.type]):align(display.CENTER, 50, height/2)
        :addTo(player_item)
    hero:setScale(60/math.max(hero:getContentSize().width,hero:getContentSize().height))

    -- 玩家名称
    UIKit:ttfLabel({
        text = player.name or Localize.village_name[player.type] ,
        size = 18,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,110, height-40)
        :addTo(player_item)

    UIKit:ttfLabel({
        text =  player.type and _("Level").." "..player.level or player.alliance.name,
        size = 18,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,110,  height-70)
        :addTo(player_item)

    return player_item
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


-- 击杀敌方
function GameUIWarReport:KillEnemy(troop)
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

    self:CreateSoldierInfo(troop)
end
-- 我方损失
function GameUIWarReport:OurLose(troop)
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

    self:CreateSoldierInfo(troop)

end

function GameUIWarReport:CreateSoldierInfo(soldiers)
    local item = self.details_view:newItem()
    item:setItemSize(540,220)
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

    for i=1,#soldiers,4 do

        local page_item = content:newItem()
        local gap_x = 120
        local origin_x = -4
        local count = 0
        for j=i,i+3 do
            if soldiers[j] then
                self:CreateSoldiersInfo(soldiers[j]):align(display.CENTER, origin_x+count*gap_x,25):addTo(page_item)
                count = count + 1
            end
        end

        content:addItem(page_item)
    end
    content:pos(50,101)
    content:reload()
    item:addContent(content)
    self.details_view:addItem(item)

end

function GameUIWarReport:CreateSoldiersInfo(soldier)
    local soldier_level = soldier.star
    local soldier_type = soldier.name
    local soldier_ui_config = UILib.soldier_image[soldier_type][soldier_level]

    local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.LEFT_BOTTOM,0,10)
    soldier_head_icon:scale(104/soldier_head_icon:getContentSize().height)
    local soldier_head_bg  = display.newSprite("box_soldier_128x128.png")
        :align(display.CENTER, soldier_head_icon:getContentSize().width/2, soldier_head_icon:getContentSize().height-64)
        :addTo(soldier_head_icon)

    UIKit:ttfLabel({
        text = soldier.count,
        size = 18,
        color = 0x403c2f
    }):align(display.CENTER,soldier_head_bg:getContentSize().width/2, -14):addTo(soldier_head_bg)
        :scale(soldier_head_icon:getContentSize().height/104)
    UIKit:ttfLabel({
        text = "-"..soldier.countDecreased ,
        size = 18,
        color = 0x980101
    }):align(display.CENTER,soldier_head_bg:getContentSize().width/2, -38):addTo(soldier_head_bg)
        :scale(soldier_head_icon:getContentSize().height/104)

    return soldier_head_icon
end

function GameUIWarReport:CreateWallPart()
    local wall_data = self.report:GetWallData()
    if not wall_data then
        return
    end
    local war_s_label_item = self.details_view:newItem()
    war_s_label_item:setItemSize(540,40)
    local g = cc.ui.UIGroup.new()
    g:addWidget(UIKit:ttfLabel({
        text = _("城墙") ,
        size = 22,
        color = 0x403c2f
    }):align(display.CENTER, 0, 0))
    war_s_label_item:addContent(g)
    self.details_view:addItem(war_s_label_item)

    local item = self.details_view:newItem()
    item:setItemSize(540,110)
    -- 背景框
    local bg = WidgetUIBackGround.new({
        width = 550,
        height = 100,
        top_img = "back_ground_top_2.png",
        bottom_img = "back_ground_bottom_2.png",
        mid_img = "back_ground_mid_2.png",
        u_height = 10,
        b_height = 10,
        m_height = 1,
    })

    display.newSprite("gate_1.png"):addTo(bg):align(display.LEFT_CENTER,20,50):scale(0.3)

    UIKit:ttfLabel({
        text = _("城墙生命值") ,
        size = 22,
        color = 0x403c2f
    }):align(display.LEFT_CENTER, 140, 70)
        :addTo(bg)
    UIKit:ttfLabel({
        text = _("城墙受损") ,
        size = 22,
        color = 0x403c2f
    }):align(display.LEFT_CENTER, 140, 30)
        :addTo(bg)
    UIKit:ttfLabel({
        text = wall_data.wall.hp ,
        size = 22,
        color = 0x403c2f
    }):align(display.RIGHT_CENTER, 500, 70)
        :addTo(bg)
    UIKit:ttfLabel({
        text = "-"..wall_data.wall.hpDecreased ,
        size = 22,
        color = 0x7e0000
    }):align(display.RIGHT_CENTER, 500, 30)
        :addTo(bg)

    item:addContent(bg)
    self.details_view:addItem(item)
    if self.report:IsAttackCamp() then
        self:OurLose(wall_data.soldiers)
    else
        self:KillEnemy(wall_data.soldiers)
    end
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

-- 获取自己是防御方还是进攻方
-- return 进攻方->true 防御方->false
function GameUIWarReport:IsAttackCamp()
    local report = self.report
    if report.attackCity.attackPlayerData.id == DataManager:getUserData()._id then
        return true
    elseif report.attackCity.defencePlayerData.id == DataManager:getUserData()._id
        or (report.attackCity.helpDefencePlayerData and report.attackCity.helpDefencePlayerData.id == DataManager:getUserData()._id)
    then
        return false
    end
end

function GameUIWarReport:GetReportTitle()
    return self.report:GetReportTitle()

end
-- function GameUIWarReport.report:GetReportResult()
--     return self.report:GetReportStar()

-- end
function GameUIWarReport:GetFightTarget()
    local battleAt = self.report:GetBattleAt()
    local location = self.report:GetBattleLocation()
    return string.format(_("Battle at %s (%d,%d)"),battleAt,location.x,location.y)
end
function GameUIWarReport:GetRewards()
    return  self.report:GetMyRewards()
end
return GameUIWarReport





































