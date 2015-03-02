local StarBar = import(".StarBar")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local UICheckBoxButton = import(".UICheckBoxButton")
local Localize = import("..utils.Localize")
local UILib = import(".UILib")

local GameUIStrikeReport = UIKit:createUIClass("GameUIStrikeReport", "UIAutoClose")

function GameUIStrikeReport:ctor(report)
    GameUIStrikeReport.super.ctor(self)
    self:setNodeEventEnabled(true)
    self.report = report
end

function GameUIStrikeReport:GetReportLevel()
    local report = self.report
    local level = report:GetStrikeLevel()
    local report_level = level==1 and _("没有得到任何情报") or _("得到一封%s级的情报")
    local level_map ={
        "",
        "D",
        "C",
        "B",
        "A",
        "S",
    }
    return (report:Type() == "cityBeStriked" and _("敌方") or "")..string.format(report_level,level_map[level])
end
function GameUIStrikeReport:GetBattleCityName()
    local battleAt = self.report:GetBattleAt()
    local location = self.report:GetBattleLocation()
    return string.format(_("Battle at %s (%d,%d)"),battleAt,location.x,location.y)
end
function GameUIStrikeReport:GetBooty()
    local booty = {}
    if self.report:GetMyRewards() then
        for k,v in pairs(self.report:GetMyRewards()) do
            table.insert(booty, {
                resource_type = Localize.fight_reward[v.name],
                icon= UILib.resource[v.name],
                value = v.count
            })
        end
    end
    return booty
end
function GameUIStrikeReport:onEnter()
    local report = self.report
    local report_content = report:GetData()

    local report_body = WidgetUIBackGround.new({height=800}):align(display.TOP_CENTER,display.cx,display.top-100)
    self:addTouchAbleChild(report_body)
    self.body = report_body

    local rb_size = report_body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+10)
        :addTo(report_body)


    local title_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = report:GetReportTitle(),
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
        end):align(display.CENTER, title:getContentSize().width-20, title:getContentSize().height-15)
        :addTo(title)
    -- 突袭结果图片
    local report_result_img
    if report:Type() == "strikeCity" or report:Type() == "strikeVillage" then
        report_result_img = report:GetStrikeLevel() >1 and "report_victory.png" or "report_failure.png"
    elseif report:Type() == "cityBeStriked" or report:Type() == "villageBeStriked" then
        report_result_img = report:GetStrikeLevel() >1 and "report_failure.png" or "report_victory.png"
    end
    local strike_result_image = display.newSprite(report_result_img)
        :align(display.CENTER_TOP, rb_size.width/2, rb_size.height-10)
        :addTo(report_body)
    local strike_result_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = self:GetReportLevel(),
            font = UIKit:getFontFilePath(),
            size = 18,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, strike_result_image:getContentSize().width/2, 15)
        :addTo(strike_result_image)
    local strike_result_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = self:GetBattleCityName(),
            font = UIKit:getFontFilePath(),
            size = 18,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 20, rb_size.height-170)
        :addTo(report_body)
    local strike_result_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = GameUtils:formatTimeStyle2(math.floor(report:CreateTime()/1000)),
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
    if (report:Type() == "strikeCity" or report:Type() == "strikeVillage") and report:GetStrikeLevel()>1 then
        -- 敌方情报部分
        self:CreateReportOfEnemy()
    end

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
            NetManager:getDeleteReportsPromise({report:Id()}):done(function ()
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
            NetManager:getSaveReportPromise(report:Id()):catch(function(err)
                target:setButtonSelected(false,true)
                dump(err:reason())
            end)
        else
            NetManager:getUnSaveReportPromise(report:Id()):catch(function(err)
                target:setButtonSelected(true,true)
                dump(err:reason())
            end)
        end
    end):addTo(report_body):pos(rb_size.width-47, 37)
        :setButtonSelected(report:IsSaved(),true)
end



function GameUIStrikeReport:CreateBootyPart()
    if not self:GetBooty() then
        return
    end
    local booty_count = #self:GetBooty()
    local booty_group = display.newNode()
    local booty_list_bg
    if booty_count>0 then
        local item_height = 46
        -- 战利品列表部分高度
        local booty_list_height = booty_count * item_height
        -- 战利品列表
        booty_list_bg = WidgetUIBackGround.new({
            width = 540,
            height = booty_list_height+16,
            top_img = "back_ground_568X14_top.png",
            bottom_img = "back_ground_568X14_top.png",
            mid_img = "back_ground_568X1_mid.png",
            u_height = 14,
            b_height = 14,
            m_height = 1,
            b_flip = true,
        }):align(display.CENTER,0,-25)
        :addTo(booty_group)
        
        local booty_list_bg_size = booty_list_bg:getContentSize()

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
            cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = booty_parms.resource_type,
                font = UIKit:getFontFilePath(),
                size = 22,
                color = UIKit:hex2c3b(0x403c2f)
            }):align(display.LEFT_CENTER,80,23):addTo(booty_item_bg)
            local color = (self.report:Type() == "strikeCity" or self.report:Type() == "strikeVillage") and 0x288400 or 0x770000
            cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = ((self.report:Type() == "strikeCity" or self.report:Type() == "strikeVillage") and "" or "-")..booty_parms.value,
                font = UIKit:getFontFilePath(),
                size = 22,
                color = UIKit:hex2c3b(color)
            }):align(display.RIGHT_CENTER,booty_list_bg_size.width-30,23):addTo(booty_item_bg)

            added_booty_item_count = added_booty_item_count + 1
            booty_item_bg_color_flag = not booty_item_bg_color_flag
        end
    end


    local booty_title_bg = display.newSprite("upgrade_resources_title.png")
        :align(display.CENTER_BOTTOM, 0,booty_list_bg and booty_list_bg:getContentSize().height/2-25 or -25)
        :addTo(booty_group)

    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = booty_count>0 and _("战利品") or _("无战利品"),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER,booty_title_bg:getContentSize().width/2, 25):addTo(booty_title_bg)
    local item = self.details_view:newItem()
    item:setItemSize(548,(booty_list_bg and booty_list_bg:getContentSize().height or 0 )+booty_title_bg:getContentSize().height)
    item:addContent(booty_group)
    self.details_view:addItem(item)
end

function GameUIStrikeReport:CreateWarStatisticsPart()
    local group = cc.ui.UIGroup.new()
    local group_width,group_height = 540,34
    group:addWidget(
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("战斗统计") ,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER,0, 0)
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


    -- 首先检查是否与协防方战斗  ，交战双方信息
    local report = self.report

    -- 左边为己方，右边为敌方
    local l_player = report:GetMyPlayerData()
    local r_player = report:GetEnemyPlayerData()
    self:CreateBelligerents(l_player,r_player)
    local l_dragon = l_player.dragon
    local r_dragon = r_player.dragon
    -- LuaUtils:outputTable("l_dragon", l_dragon)
    -- LuaUtils:outputTable("r_dragon", r_dragon)
    self:CreateArmyGroup(l_dragon,r_dragon)


    -- self:CreateBelligerents()
    -- 龙
    -- self:CreateArmyGroup()
end


-- 交战双方信息
function GameUIStrikeReport:CreateBelligerents(l_player,r_player)
    local group = cc.ui.UIGroup.new()
    local group_width,group_height = 540,100
    local self_item = self:CreateBelligerentsItem(group_height,l_player)
        :align(display.CENTER, -group_width/2+129, 0)

    group:addWidget(self_item)

    local enemy_item = self:CreateBelligerentsItem(group_height,r_player)
        :align(display.CENTER, group_width/2-129, 0)
    group:addWidget(enemy_item)
    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end

function GameUIStrikeReport:CreateBelligerentsItem(height,player)
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
        text = player.type and _("Level").." "..player.level or player.alliance.name ,
        size = 18,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,110,  height-70)
        :addTo(player_item)

    return player_item
end

function GameUIStrikeReport:CreateArmyGroup(l_dragon,r_dragon)
    if not l_dragon and not r_dragon then
        return
    end
    local group = cc.ui.UIGroup.new()

    local group_width,group_height = 540,150
    if l_dragon then
        local self_army_item = self:CreateArmyItem(l_dragon)
            :align(display.CENTER, -group_width/2+129, 0)

        group:addWidget(self_army_item)
    end
    if r_dragon then
        local enemy_army_item = self:CreateArmyItem(r_dragon)
            :align(display.CENTER, group_width/2-129, 0)
        group:addWidget(enemy_army_item)
    end

    local item = self.details_view:newItem()
    item:setItemSize(group_width,group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end

function GameUIStrikeReport:CreateArmyItem(dragon)
    local w,h = 258,96

    local army_item = self:CreateSmallBackGround(h,Localize.dragon[dragon.type])

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
            value = dragon.level,
        },

        {
            bg_image = "back_ground_254x28_1.png",
            title = "HP",
            value = dragon.hp.."/-"..dragon.hpDecreased,
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

    local report_level = self.report:GetStrikeLevel()
    -- 敌方资源产量
    self:CreateEnemyResource()
    -- 敌方军事水平
    -- 暂无
    -- self:CreateEnemyTechnology()
    -- if report_level>2 then
    -- 敌方龙的装备
    self:CreateDragonEquipments()
    -- 驻防部队
    self:CreateGarrison()
    -- end
    -- if report_level>4 then
    -- 敌方龙的技能
    self:CreateDragonSkills()
    -- end
end
function GameUIStrikeReport:CreateEnemyResource()
    local resources = self.report:GetStrikeIntelligence().resources
    if not resources then
        return
    end
    local r_tip_height = 36

    -- 敌方资源列表部分高度
    local unpack_resources = self:GetEnemyResource(resources)
    local r_count = #unpack_resources
    local r_list_height = r_count * r_tip_height

    -- 敌方资源列表
    local group = self:CreateBigBackGround(r_list_height+37,_("资源产量"))
    local group_width , group_height = 552,r_list_height+50

    -- 构建所有资源标签项
    local r_item_bg_color_flag = true
    local added_r_item_count = 0
    for k,r_parms in pairs(unpack_resources) do
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
        local r_value = self.report:GetStrikeLevel() < 4 and self:GetProbableNum(r_parms.value) or r_parms.value
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = r_value,
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
function GameUIStrikeReport:GetEnemyResource(resources)
    local unpack_resources = {}
    for k,v in pairs(resources) do
        table.insert(unpack_resources, {
            resource_type = Localize.fight_reward[k],
            icon= UILib.resource[k],
            value = v,
        }
        )
    end
    return unpack_resources
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
    local dragon = self.report:GetStrikeIntelligence().dragon
    if not dragon then
        return
    end
    local r_tip_height = 36

    local skills = dragon.skills
    -- 敌方龙技能列表部分高度
    local r_count = not skills and 0 or #skills
    local r_list_height = r_count * r_tip_height

    -- 敌方龙技能列表
    local title = (not skills or #skills ==0) and _("龙没有技能") or _("龙的技能")
    local group = self:CreateBigBackGround(r_list_height+37,title)
    local group_width , group_height = 552,r_list_height+50
    if skills then
        -- 构建所有龙技能标签项
        local r_item_bg_color_flag = true
        local added_r_item_count = 0
        for k,r_parms in pairs(skills) do
            local r_item_bg_image = r_item_bg_color_flag and "back_ground_546X36_1.png" or "back_ground_546X36_2.png"
            local r_item_bg = display.newSprite(r_item_bg_image)
                :align(display.TOP_CENTER, group_width/2, r_list_height-r_tip_height*added_r_item_count+4)
                :addTo(group)
            cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = Localize.dragon_skill[r_parms.name],
                font = UIKit:getFontFilePath(),
                size = 20,
                color = UIKit:hex2c3b(0x403c2f)
            }):align(display.LEFT_CENTER,10,18):addTo(r_item_bg)
            cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = _("Level")..r_parms.level,
                font = UIKit:getFontFilePath(),
                size = 20,
                color = UIKit:hex2c3b(0x403c2f)
            }):align(display.RIGHT_CENTER,group_width-30,18):addTo(r_item_bg)

            added_r_item_count = added_r_item_count + 1
            r_item_bg_color_flag = not r_item_bg_color_flag
        end
    end


    local item = self.details_view:newItem()
    item:setItemSize(group_width , group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end
function GameUIStrikeReport:CreateGarrison()
    -- local soldiers = self.report[self.report:Type()].enemyPlayerData.soldiers
    local soldiers = self.report:GetStrikeIntelligence().soldiers

    local r_tip_height = 36


    -- 敌方龙技能列表部分高度
    local r_count = not soldiers and 0 or #soldiers
    local r_list_height = r_count * r_tip_height

    -- 敌方龙技能列表
    local title = (not soldiers or #soldiers ==0) and _("没有驻防部队") or _("驻防部队")
    local group = self:CreateBigBackGround(r_list_height+37,title)
    local group_width , group_height = 552,r_list_height+50
    if soldiers then
        -- 构建所有龙技能标签项
        local r_item_bg_color_flag = true
        local added_r_item_count = 0
        for k,r_parms in pairs(soldiers) do
            local r_item_bg_image = r_item_bg_color_flag and "back_ground_546X36_1.png" or "back_ground_546X36_2.png"
            local r_item_bg = display.newSprite(r_item_bg_image)
                :align(display.TOP_CENTER, group_width/2, r_list_height-r_tip_height*added_r_item_count+4)
                :addTo(group)
            cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = Localize.soldier_name[r_parms.name],
                font = UIKit:getFontFilePath(),
                size = 20,
                color = UIKit:hex2c3b(0x403c2f)
            }):align(display.LEFT_CENTER,10,18):addTo(r_item_bg)
            local report_level = self.report:GetStrikeLevel()

            if report_level>3 then
                local soldier_num = report_level<5 and self:GetProbableNum(r_parms.count) or r_parms.count
                cc.ui.UILabel.new({
                    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = _("数量")..soldier_num,
                    font = UIKit:getFontFilePath(),
                    size = 20,
                    color = UIKit:hex2c3b(0x403c2f)
                }):align(display.RIGHT_CENTER,group_width-30,18):addTo(r_item_bg)
                StarBar.new({
                    max = 5,
                    bg = "Stars_bar_bg.png",
                    fill = "Stars_bar_highlight.png",
                    num = r_parms.star,
                    margin = 0,
                    direction = StarBar.DIRECTION_HORIZONTAL,
                    scale = 0.6,
                }):addTo(r_item_bg):align(display.RIGHT_CENTER,group_width/2, 18)
            end

            added_r_item_count = added_r_item_count + 1
            r_item_bg_color_flag = not r_item_bg_color_flag
        end
    end


    local item = self.details_view:newItem()
    item:setItemSize(group_width , group_height)
    item:addContent(group)
    self.details_view:addItem(item)
end
function GameUIStrikeReport:CreateDragonEquipments()
    local dragon = self.report:GetStrikeIntelligence().dragon

    -- local dragon = self.report:GetData().enemyPlayerData.dragon
    local equipments = dragon and dragon.equipments

    local r_tip_height = 36

    -- 敌方龙装备列表部分高度
    local r_count =not equipments and 0 or #equipments
    local r_list_height = r_count * r_tip_height
    -- 敌方龙装备列表
    local title = not dragon and _("敌方龙没有驻防") or (not equipments or #equipments == 0) and _("敌方龙没有装备") or _("龙的装备")
    local group = self:CreateBigBackGround(r_list_height+37,title)
    local group_width , group_height = 552,r_list_height+50
    if equipments then
        -- 构建所有龙装备标签项
        local r_item_bg_color_flag = true
        local added_r_item_count = 0
        for k,r_parms in pairs(equipments) do
            local r_item_bg_image = r_item_bg_color_flag and "back_ground_546X36_1.png" or "back_ground_546X36_2.png"
            local r_item_bg = display.newSprite(r_item_bg_image)
                :align(display.TOP_CENTER, group_width/2, r_list_height-r_tip_height*added_r_item_count+4)
                :addTo(group)
            cc.ui.UILabel.new({
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = Localize.body[r_parms.type],
                font = UIKit:getFontFilePath(),
                size = 20,
                color = UIKit:hex2c3b(0x403c2f)
            }):align(display.LEFT_CENTER,10,18):addTo(r_item_bg)

            StarBar.new({
                max = 5,
                bg = "Stars_bar_bg.png",
                fill = "Stars_bar_highlight.png",
                num = r_parms.star,
                margin = 0,
                direction = StarBar.DIRECTION_HORIZONTAL,
                scale = 0.6,
            }):addTo(r_item_bg):align(display.RIGHT_CENTER,group_width-50, 18)

            added_r_item_count = added_r_item_count + 1
            r_item_bg_color_flag = not r_item_bg_color_flag
        end
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

function GameUIStrikeReport:GetProbableNum(num)
    if num<=20 then
        return "0-20"
    elseif num<=50 then
        return "20-50"
    elseif num<=100 then
        return "50-100"
    elseif num<=200 then
        return "100-200"
    elseif num<=500 then
        return "200-500"
    elseif num<=1000 then
        return "500-1000"
    elseif num<=2000 then
        return "1k-2k"
    elseif num<=5000 then
        return "2k-5k"
    elseif num<=10000 then
        return "5k-10k"
    elseif num<=20000 then
        return "10k-20k"
    elseif num<=50000 then
        return "20k-50k"
    elseif num<=100000 then
        return "50k-100k"
    elseif num<=200000 then
        return "100k-200k"
    elseif num<=500000 then
        return "200k-500k"
    elseif num<=1000000 then
        return "500k-1M"
    elseif num<=2000000 then
        return "1M-2M"
    elseif num<=5000000 then
        return "2M-5M"
    elseif num<=10000000 then
        return "5M-10M"
    else
        return ">10M"
    end
end

return GameUIStrikeReport













































