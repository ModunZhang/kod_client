local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetPages = import("..widget.WidgetPages")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetInfo = import("..widget.WidgetInfo")
local Alliance = import("..entity.Alliance")
local AllianceMoonGate = import("..entity.AllianceMoonGate")
local UIListView = import(".UIListView")
local Flag = import("..entity.Flag")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local GameUIAllianceEnter = import(".GameUIAllianceEnter")

local GameUIAllianceBattle = UIKit:createUIClass('GameUIAllianceBattle', "GameUIWithCommonHeader")
local img_dir = "allianceHome/"

function GameUIAllianceBattle:ctor(city)
    GameUIAllianceBattle.super.ctor(self, city, _("联盟会战"))
    self.alliance = Alliance_Manager:GetMyAlliance()

    self.alliance_fight_reports_table = {}
    self.history_items = {}
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
            if not self.alliance_listview then
                self:InitOtherAlliance()
                NetManager:getNearedAllianceInfosPromise():next(function(data)
                    LuaUtils:outputTable("getNearedAllianceInfosPromise", data)
                    if #data > 0 then
                        self:RefreshAllianceListview(data)
                    end
                end)

            end
        else
            self.other_alliance_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)

    self:InitBattleStatistics()
    self:InitHistoryRecord()


    app.timer:AddListener(self)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.FIGHT_REQUESTS)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.FIGHT_REPORTS)
    self.alliance:GetAllianceMoonGate():AddListenOnType(self, AllianceMoonGate.LISTEN_TYPE.OnCountDataChanged)

end

function GameUIAllianceBattle:onExit()
    app.timer:RemoveListener(self)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.FIGHT_REQUESTS)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.FIGHT_REPORTS)
    self.alliance:GetAllianceMoonGate():RemoveListenerOnType(self, AllianceMoonGate.LISTEN_TYPE.OnCountDataChanged)
    GameUIAllianceBattle.super.onExit(self)
end

function GameUIAllianceBattle:OnTimer(current_time)
    if self.statistics_layer:isVisible() then
        local status = self.alliance:Status()
        if status ~= "peace" then
            local statusFinishTime = self.alliance:StatusFinishTime()
            if math.floor(statusFinishTime/1000)>current_time then
                self.time_label:setString(GameUtils:formatTimeStyle1(math.floor(statusFinishTime/1000)-current_time))
            end
        else
            local statusStartTime = self.alliance:StatusStartTime()
            if current_time>= math.floor(statusStartTime/1000) then
                self.time_label:setString(GameUtils:formatTimeStyle1(current_time-math.floor(statusStartTime/1000)))
            end
        end
    end
    if self.history_layer:isVisible() then
        for k,v in pairs(self.alliance_fight_reports_table) do
            v:RefreshRevengeTime(current_time)
        end
    end
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
    layer:removeAllChildren()
    self.info_listview = nil

    local period_label = UIKit:ttfLabel({
        text = self:GetAlliancePeriod(),
        size = 22,
        color = 0x403c2f,
    }):addTo(layer):align(display.LEFT_CENTER,window.cx-50,window.top-100)

    self.time_label = UIKit:ttfLabel({
        text = "",
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
    if self.alliance:Status() == "peace" then
        -- 请求开战玩家数量
        local request_fight_bg = WidgetUIBackGround2.new(106)
            :align(display.TOP_CENTER, window.cx, window.top - 140)
            :addTo(layer)
            :scale(0.9)
        UIKit:ttfLabel({
            text = _("请求开战玩家"),
            size = 22,
            color = 0x403c2f,
        }):addTo(request_fight_bg)
            :align(display.LEFT_CENTER,30,request_fight_bg:getContentSize().height/2)
        local request_num_bg = display.newSprite("allianceHome/power_background.png")
            :align(display.RIGHT_CENTER,request_fight_bg:getContentSize().width-30,request_fight_bg:getContentSize().height/2)
            :addTo(request_fight_bg)
        cc.ui.UIImage.new("citizen_44x50.png")
            :align(display.CENTER,0, request_num_bg:getContentSize().height/2)
            :addTo(request_num_bg)
            :scale(0.7)

        self.request_num_label = UIKit:ttfLabel(
            {
                text = self.alliance:GetFightRequestPlayerNum(),
                size = 18,
                color = 0xffedae
            }):align(display.CENTER, request_num_bg:getContentSize().width/2, request_num_bg:getContentSize().height/2)
            :addTo(request_num_bg)

        -- 介绍
        -- 只有权限大于将军的玩家可以请求开启联盟会战匹配
        local isEqualOrGreater = self.alliance:GetMemeberById(DataManager:getUserData()._id)
            :IsTitleEqualOrGreaterThan("general")

        if not isEqualOrGreater then
            UIKit:ttfLabel({
                text = _("向盟主和将军请求联盟会战"),
                size = 22,
                color = 0x403c2f,
            }):addTo(layer)
                :align(display.LEFT_CENTER,window.left+50,window.top-280)
            WidgetPushButton.new({normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png",disable="yellow_disable_185x65.png"})
                :setButtonLabel(UIKit:ttfLabel({
                    text = _("请求开战!"),
                    size = 24,
                    color = 0xffedae,
                    shadow= true
                }))
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        NetManager:getRequestAllianceToFightPromose()
                    end
                end):align(display.RIGHT_CENTER,window.right-50,window.top-280):addTo(layer)
        end



        local intro_1_text = isEqualOrGreater and _("参加联盟会战,赢得荣誉,金龙币和丰厚战利品,联盟处在和平期可以主动匹配或被其他联盟匹配进行联盟会战")
            or _("联盟处在和平期可以主动匹配或被其他联盟匹配进行联盟会战")
        local intro_1 = UIKit:ttfLabel({
            text = intro_1_text,
            size = 22,
            color = 0x797154,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.CENTER,window.cx,window.top-370)

        -- 介绍
        local intro_2 = UIKit:ttfLabel({
            text = _("联盟会战会根据联盟战斗力匹配,你可以通过以下方式提升联盟战斗力"),
            size = 22,
            color = 0x797154,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.CENTER,window.cx,intro_1:getPositionY()-intro_1:getContentSize().height-40)

        local tip_1 = UIKit:ttfLabel({
            text = _("1，招募更多的玩家加入联盟"),
            size = 22,
            color = 0x403c2f,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.LEFT_CENTER,window.left+60,window.top-560)

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

        local tip_4 = UIKit:ttfLabel({
            text = _("4，提升龙的等级,技能和装备"),
            size = 22,
            color = 0x403c2f,
            dimensions = cc.size(530,0),
        }):addTo(layer)
            :align(display.LEFT_CENTER,window.left+60,tip_3:getPositionY()-50)



        if isEqualOrGreater then
            UIKit:ttfLabel({
                text = _("准备好了,那就开战吧"),
                size = 22,
                color = 0x403c2f,
            }):addTo(layer)
                :align(display.LEFT_CENTER,window.left+50,window.top-830)
            WidgetPushButton.new({normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png",disable="yellow_disable_185x65.png"})
                :setButtonLabel(UIKit:ttfLabel({
                    text = _("开始战斗!"),
                    size = 24,
                    color = 0xffedae,
                    shadow= true
                }))
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        NetManager:getFindAllianceToFightPromose()
                    end
                end):align(display.RIGHT_CENTER,window.right-50,window.top-830):addTo(layer)
        end
    else
        local our_alliance = self.alliance
        local enemy_alliance = self.alliance:GetAllianceMoonGate():GetEnemyAlliance()
        local self_alliance_bg = WidgetPushButton.new({normal = "allianceHome/button_blue_normal_320X94.png",
            pressed = "allianceHome/button_blue_pressed_320X94.png"})
            :onButtonClicked(function()
                self:OpenAllianceDetails(true)
            end)
            :align(display.RIGHT_CENTER,window.cx,window.top-180)
            :addTo(layer)
            :scale(0.85)
        local enemy_alliance_bg = WidgetPushButton.new({normal = "allianceHome/button_red_normal_320X94.png",
            pressed = "allianceHome/button_red_pressed_320X94.png"})
            :onButtonClicked(function()
                self:OpenAllianceDetails(false)
            end)
            :align(display.LEFT_CENTER,window.cx,window.top-180)
            :addTo(layer)
            :scale(0.85)
        -- 己方联盟名字
        UIKit:ttfLabel({
            text = our_alliance:Name(),
            size = 22,
            color = 0xffedae,
        }):addTo(self_alliance_bg)
            :align(display.CENTER,-180,0)
        -- 敌方联盟名字
        UIKit:ttfLabel({
            text = enemy_alliance.name,
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


        -- 保护期显示战斗结果
        local info_bg_y
        if our_alliance:Status() == "protect" then
            local fight_result =  our_alliance:GetLastAllianceFightReports().fightResult == "ourWin"
            local text_1 = fight_result and "WIN" or "LOSE"
            local color_1 = fight_result and 0x007c23 or 0x7e0000
            local result_own = UIKit:ttfLabel({
                text = text_1,
                size = 20,
                color = color_1,
            }):align(display.LEFT_CENTER,window.left+50,window.top-240)
                :addTo(layer)
            local text_1 = not fight_result and "WIN" or "LOSE"
            local color_1 = not fight_result and 0x007c23 or 0x7e0000
            local result_enemy = UIKit:ttfLabel({
                text = text_1,
                size = 20,
                color = color_1,
            }):align(display.RIGHT_CENTER,window.right-50,window.top-240)
                :addTo(layer)

            local isEqualOrGreater = self.alliance:GetMemeberById(DataManager:getUserData()._id)
                :IsTitleEqualOrGreaterThan("general")
            if isEqualOrGreater then
                UIKit:ttfLabel({
                    text = _("不需要保护,立即开战!"),
                    size = 22,
                    color = 0x403c2f,
                }):addTo(layer)
                    :align(display.LEFT_CENTER,window.left+50,window.top-830)
                WidgetPushButton.new({normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png",disable="yellow_disable_185x65.png"})
                    :setButtonLabel(UIKit:ttfLabel({
                        text = _("开始战斗!"),
                        size = 24,
                        color = 0xffedae,
                        shadow= true
                    }))
                    :onButtonClicked(function(event)
                        if event.name == "CLICKED_EVENT" then
                            NetManager:getFindAllianceToFightPromose()
                        end
                    end):align(display.RIGHT_CENTER,window.right-50,window.top-830):addTo(layer)
            end

            info_bg_y = window.top-260

        else
            UIKit:ttfLabel({
                text = _("本次联盟会战结束后奖励,总击杀越高奖励越高.获胜方获得70%的总奖励,失败方获得剩下的,获胜联盟击杀前5名的玩家还将平分奖励的宝石"),
                size = 20,
                color = 0x797154,
                -- align = cc.ui.TEXT_ALIGN_CENTER,
                dimensions = cc.size(500,0),
            }):addTo(layer)
                :align(display.TOP_CENTER,window.cx,window.top-240)
            -- 荣耀值奖励
            local honour_bg = display.newScale9Sprite("back_ground_138x34.png",window.left+70,window.top-350,cc.size(188,34))
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
            local gem_bg = display.newScale9Sprite("back_ground_138x34.png",window.right-60,window.top-350,cc.size(188,34))
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
            info_bg_y = window.top-380
        end


        local info_bg = WidgetUIBackGround.new({
            width = 540,
            height = 434,
            top_img = "back_ground_568X14_top.png",
            bottom_img = "back_ground_568X14_top.png",
            mid_img = "back_ground_568X1_mid.png",
            u_height = 14,
            b_height = 14,
            m_height = 1,
            b_flip = true,
        }):align(display.TOP_CENTER,window.cx, info_bg_y):addTo(layer)
        self.info_listview = UIListView.new{
            -- bgColor = UIKit:hex2c4b(0x7a000000),
            viewRect = cc.rect(9, 10, 522, 414),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
        }:addTo(info_bg)
        self:RefreshFightInfoList()
    end
end

function GameUIAllianceBattle:RefreshFightInfoList()
    if self.info_listview then
        self.info_listview:removeAllItems()
        local our = self.alliance:GetAllianceMoonGate():GetCountData().our
        local enemy = self.alliance:GetAllianceMoonGate():GetCountData().enemy
        local info_message = {
            {string.formatnumberthousands(our.kill),_("击杀数"),string.formatnumberthousands(enemy.kill)},
            {string.formatnumberthousands(self.alliance:Power()),_("战斗力"),string.formatnumberthousands(self.alliance:GetAllianceMoonGate():GetEnemyAlliance().power)},
            {GameUtils:formatTimeStyle1(our.moonGateOwnCount*30),_("占领月门时间"),GameUtils:formatTimeStyle1(enemy.moonGateOwnCount*30)},
            {our.routCount,_("击溃城市"),enemy.routCount},
            {our.strikeCount,_("突袭次数"),enemy.strikeCount},
            {our.attackSuccessCount,_("获胜进攻"),enemy.attackSuccessCount},
            {our.attackFailCount,_("失败进攻"),enemy.attackFailCount},
            {our.defenceSuccessCount,_("成功防御"),enemy.defenceSuccessCount},
            {our.defenceFailCount,_("失败防御"),enemy.defenceFailCount},
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

function GameUIAllianceBattle:OpenAllianceDetails(isOur)
    local alliance = self.alliance
    local enemy_alliance = alliance:GetAllianceMoonGate():GetEnemyAlliance()
    local count_data = alliance:GetAllianceMoonGate():GetCountData()

    local alliance_name = isOur and alliance:Name() or enemy_alliance.name
    -- 玩家联盟成员
    local palace_level = alliance:GetAllianceMap():FindAllianceBuildingInfoByName("palace").level
    local memberCount = GameDatas.AllianceBuilding.palace[palace_level].memberCount
    local enemy_memberCount = GameDatas.AllianceBuilding.palace[enemy_alliance.palaceLevel].memberCount
    local alliance_members = isOur and alliance:GetMembersCount().."/"..memberCount or enemy_alliance.memberCount.."/"..enemy_memberCount
    -- 联盟语言
    local  language = isOur and alliance:DefaultLanguage() or enemy_alliance.language
    -- 联盟战斗力
    local  alliance_power = isOur and alliance:Power() or enemy_alliance.power
    -- 联盟击杀
    local  alliance_kill = isOur and count_data.our.kill or count_data.enemy.kill
    -- 玩家击杀列表
    local  player_kill = isOur and count_data.our.playerKills or count_data.enemy.playerKills
    -- 联盟旗帜
    local alliance_flag = isOur and alliance:Flag() or Flag.new():DecodeFromJson(enemy_alliance.flag)
    -- 联盟地形
    local alliance_terrain = isOur and alliance:TerrainType() or enemy_alliance.terrain


    local layer = display.newColorLayer(cc.c4b(0,0,0,127)):addTo(self)
    local body = WidgetUIBackGround.new({height=726}):align(display.TOP_CENTER,display.cx,display.top-100)
        :addTo(layer)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = alliance_name,
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

    -- 联盟旗帜
    local flag_bg = display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.CENTER,90,rb_size.height-90)
        :addTo(body)
    local a_helper = WidgetAllianceUIHelper.new()
    local flag_sprite = a_helper:CreateFlagWithRhombusTerrain(alliance_terrain,alliance_flag)
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
    addAttr(_("成员"),alliance_members,180,rb_size.height-50)
    addAttr(_("语言"),language,180,rb_size.height-90)
    addAttr(_("战斗力"),string.formatnumberthousands(alliance_power),350,rb_size.height-50)
    addAttr(_("击杀"),string.formatnumberthousands(alliance_kill),350,rb_size.height-90)

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
            text = member.name,
            size = 22,
            color = 0x403c2f,
        }):align(display.LEFT_BOTTOM,20,10)
            :addTo(line)

        local t = UIKit:ttfLabel({
            text = string.formatnumberthousands(member.kill),
            size = 22,
            color = 0x403c2f,
        }):align(display.RIGHT_BOTTOM,574,10)
            :addTo(line)
        display.newSprite("battle_39x38.png")
            :align(display.RIGHT_BOTTOM,564-t:getContentSize().width,10)
            :addTo(line)
        item:addContent(content)
        self.member_listview:addItem(item)
    end
    for k,v in pairs(player_kill) do
        addMemberItem(v)
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

    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams = {text = _("明白")},
            listener = function ()
                layer:removeFromParent(true)
            end,
        }
    ):pos(rb_size.width/2, 50)
        :addTo(body)

end

function GameUIAllianceBattle:InitHistoryRecord()
    local layer = self.history_layer
    self.history_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a990000),
        viewRect = cc.rect(window.left+17, window.top-890, 608, 786),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(layer)

    local fight_reports = self.alliance:GetAllianceFightReports()
    for k,v in pairs(fight_reports) do
        self:AddHistoryItem(v)
    end

    self.history_listview:reload()
end

function GameUIAllianceBattle:AddHistoryItem(report,index)
    -- 各项数据
    local win = report.fightResult == "ourWin"
    local fightTime = report.fightTime
    local ourAlliance = report.ourAlliance
    local enemyAlliance = report.enemyAlliance


    local item = self.history_listview:newItem()
    local w,h = 608,314
    item:setItemSize(w,h)
    local content = WidgetUIBackGround.new({height=314})

    local title_bg = display.newSprite("blue_bar_548x30.png"):align(display.CENTER, w/2, h-30)
        :addTo(content)
        :scale(1.06)
    UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle2(math.floor(fightTime/1000)),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER,title_bg:getContentSize().width/2, title_bg:getContentSize().height/2)
        :addTo(title_bg)

    local fight_bg = display.newSprite("report_back_ground.png")
        :align(display.TOP_CENTER, w/2,h-50)
        :addTo(content)
        :scale(0.95)
    local win_text = win and _("胜利") or _("失败")
    local win_color = win and 0x007c23 or 0x7e0000

    UIKit:ttfLabel({
        text = win_text,
        size = 20,
        color = win_color,
    }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width/2-90,65)
        :addTo(fight_bg)
    UIKit:ttfLabel({
        text = ourAlliance.name,
        size = 20,
        color = 0x403c2f,
    }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width/2-90,40)
        :addTo(fight_bg)
    UIKit:ttfLabel({
        text = "["..ourAlliance.tag.."]",
        size = 18,
        color = 0x403c2f,
    }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width/2-90,20)
        :addTo(fight_bg)


    local win_text = not win and _("胜利") or _("失败")
    local win_color = not win and 0x007c23 or 0x7e0000
    UIKit:ttfLabel({
        text = win_text,
        size = 20,
        color = win_color,
    }):align(display.LEFT_CENTER,fight_bg:getContentSize().width/2+90,65)
        :addTo(fight_bg)
    UIKit:ttfLabel({
        text = enemyAlliance.name,
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,fight_bg:getContentSize().width/2+90,40)
        :addTo(fight_bg)
    UIKit:ttfLabel({
        text = "["..enemyAlliance.tag.."]",
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
    local self_flag = ui_helper:CreateFlagContentSprite(Flag.new():DecodeFromJson(ourAlliance.flag)):scale(0.5)
    self_flag:align(display.CENTER, VS:getPositionX()-80, 10)
        :addTo(fight_bg)
    -- 敌方联盟旗帜
    local enemy_flag = ui_helper:CreateFlagContentSprite(Flag.new():DecodeFromJson(enemyAlliance.flag)):scale(0.5)
    enemy_flag:align(display.CENTER, VS:getPositionX()+20, 10)
        :addTo(fight_bg)

    -- 击杀数，击溃城市
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
    }):align(display.BOTTOM_CENTER,w/2,60):addTo(content)

    local info_message = {
        {string.formatnumberthousands(ourAlliance.kill),_("总击杀"),string.formatnumberthousands(enemyAlliance.kill)},
        {string.formatnumberthousands(ourAlliance.routCount),_("击溃城市"),string.formatnumberthousands(enemyAlliance.routCount)},
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

    -- 只有权限大于将军的玩家可以请求复仇
    local isEqualOrGreater = self.alliance:GetMemeberById(DataManager:getUserData()._id)
        :IsTitleEqualOrGreaterThan("general")
    if not win and isEqualOrGreater then
        -- 复仇按钮
        local revenge_button = WidgetPushButton.new(
            {normal = "resource_butter_red.png",pressed = "resource_butter_red_highlight.png"},
            {scale9 = false},
            {disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}}
        ):addTo(content):align(display.RIGHT_CENTER,560,35)
            :setButtonLabel(UIKit:ttfLabel({
                text = _("复仇"),
                size = 24,
                color = 0xffedae,
                shadow= true
            }))
        revenge_button:onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if self.alliance:Status()~="peace" then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("已经处于联盟战期间"))
                        :AddToCurrentScene()
                    return
                end
                NetManager:getRevengeAlliancePromise(report.id):done(function ()
                    revenge_button:setButtonEnabled(false)
                end)
            end
        end)
        local revenge_time_limit = GameDatas.AllianceInitData.intInit.allianceRevengeMaxTime.value + math.floor(fightTime/1000)
        local revenge_time_label
        if app.timer:GetServerTime()>revenge_time_limit then
            revenge_time_label = UIKit:ttfLabel({
                text = _("已过期"),
                size = 24,
                color = 0x7e0000,
            }):align(display.LEFT_CENTER, 50, 30)
                :addTo(content)
            revenge_button:setButtonEnabled(false)
        else
            revenge_time_label = UIKit:ttfLabel({
                text = _("剩余复仇时间:")..GameUtils:formatTimeStyle1(revenge_time_limit-app.timer:GetServerTime()),
                size = 24,
                color = 0x007c23,
            }):align(display.LEFT_CENTER, 50, 30)
                :addTo(content)
            revenge_button:setButtonEnabled(true)
            table.insert(self.alliance_fight_reports_table, item)
        end
        local parent = self
        function item:RefreshRevengeTime(current_time)
            if current_time>revenge_time_limit then
                revenge_time_label:setString(_("已过期"))
                revenge_time_label:setColor(UIKit:hex2c3b(0x7e0000))
                revenge_button:setButtonEnabled(false)
                for k,v in pairs(parent.alliance_fight_reports_table) do
                    if self == v then
                        parent.alliance_fight_reports_table[k] = nil
                    end
                end
            else
                revenge_time_label:setString(_("剩余复仇时间:")..GameUtils:formatTimeStyle1(revenge_time_limit-current_time))
            end
        end
    end

    item:addContent(content)
    self.history_items[report.id] = item
    self.history_listview:addItem(item,index)
end

function GameUIAllianceBattle:InitOtherAlliance()
    local layer = self.other_alliance_layer
    local face_bg = display.newSprite("allianceHome/banner.png")
        :align(display.TOP_CENTER, window.cx, window.top-50)
        :addTo(layer)

    --搜索
    local searchIcon = display.newSprite("alliacne_search_29x33.png"):addTo(layer)
        :align(display.LEFT_CENTER,window.left+50,window.top-270)
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
        viewRect = cc.rect(window.left+17, window.top-890, 608, 586),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(layer)
    -- for i=1,10 do
    --     self:CreateAllianceItem()
    -- end
    -- self.alliance_listview:reload()
end

function GameUIAllianceBattle:CreateAllianceItem(alliance)
    LuaUtils:outputTable("search alliance result", alliance)
    local basic = alliance.basicInfo
    local countInfo = alliance.countInfo

    local item = self.alliance_listview:newItem()
    local w,h = 608,160
    item:setItemSize(w, h)
    local content = WidgetUIBackGround.new({height=h})


    -- 联盟旗帜
    local flag_bg =  WidgetPushButton.new({normal = "alliance_item_flag_box_126X126.png",
        pressed = "alliance_item_flag_box_126X126.png"})
        :onButtonClicked(function()
            self:OpenOtherAllianceDetails(alliance)
        end)
        :align(display.CENTER,90,h/2)
        :addTo(content)
    local a_helper = WidgetAllianceUIHelper.new()
    local flag_sprite = a_helper:CreateFlagWithRhombusTerrain(basic.terrain
        ,Flag.new():DecodeFromJson(basic.flag))
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
    -- local s_icon = display.newSprite("allianceHome/down.png")
    --     :align(display.LEFT_CENTER, index_box:getPositionX()+index_box:getContentSize().width, title_bg:getContentSize().height/2)
    --     :addTo(title_bg,2)
    -- 联盟tag和名字
    local index_box  = UIKit:ttfLabel({
        text = "["..basic.tag.."]"..basic.name,
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, index_box:getPositionX()+index_box:getContentSize().width+20, title_bg:getContentSize().height/2)
        :addTo(title_bg,2)
    -- 联盟power
    display.newSprite("dragon_strength_27x31.png")
        :align(display.CENTER, 180,70)
        :addTo(content)
    local power_label  = UIKit:ttfLabel({
        text = string.formatnumberthousands(basic.power),
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,200,70)
        :addTo(content)
    -- 联盟击杀
    display.newSprite("allianceHome/hit_icon.png")
        :align(display.CENTER, 180,30)
        :addTo(content)
    local hit_label  = UIKit:ttfLabel({
        text = string.formatnumberthousands(basic.kill),
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,200,30)
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
            -- if event.name == "CLICKED_EVENT" then
            --     NetManager:getFtechAllianceViewDataPromose(alliance.id):next(function(msg)
            --         local enemyAlliance = Alliance_Manager:DecodeAllianceFromJson(msg)
            --         app:lockInput(false)
            --         app:enterScene("EnemyAllianceScene", {enemyAlliance,GameUIAllianceEnter.Enemy}, "custom", -1, function(scene, status)
            --             local manager = ccs.ArmatureDataManager:getInstance()
            --             if status == "onEnter" then
            --                 manager:addArmatureFileInfo("animations/Cloud_Animation.ExportJson")
            --                 local armature = ccs.Armature:create("Cloud_Animation"):addTo(scene):pos(display.cx, display.cy)
            --                 display.newColorLayer(UIKit:hex2c4b(0x00ffffff)):addTo(scene):runAction(
            --                     transition.sequence{
            --                         cc.CallFunc:create(function() armature:getAnimation():play("Animation1", -1, 0) end),
            --                         cc.FadeIn:create(0.75),
            --                         cc.CallFunc:create(function() scene:hideOutShowIn() end),
            --                         cc.DelayTime:create(0.5),
            --                         cc.CallFunc:create(function() armature:getAnimation():play("Animation4", -1, 0) end),
            --                         cc.FadeOut:create(0.75),
            --                         cc.CallFunc:create(function() scene:finish() end),
            --                     }
            --                 )
            --             elseif status == "onExit" then
            --                 manager:removeArmatureFileInfo("animations/Cloud_Animation.ExportJson")
            --             end
            --         end)
            --     end)
            -- end
        end):align(display.RIGHT_CENTER,w-20,35):addTo(content)

    item:addContent(content)
    self.alliance_listview:addItem(item)
end

function GameUIAllianceBattle:RefreshAllianceListview(alliances)
    self.alliance_listview:removeAllItems()
    for k,v in pairs(alliances) do
        self:CreateAllianceItem(v)
    end
    self.alliance_listview:reload()
end

-- tag ~= nil -->search
function GameUIAllianceBattle:GetJoinList(tag)
    if tag then
        NetManager:getSearchAllianceInfoByTagPromise(tag):next(function(data)
            if #data > 0 then
                self:RefreshAllianceListview(data)
            end
        end)
    end
end
function GameUIAllianceBattle:SearchAllianAction(tag)
    self:GetJoinList(tag)
end

function GameUIAllianceBattle:OpenOtherAllianceDetails(alliance)
    local basic = alliance.basicInfo
    local countInfo = alliance.countInfo

    local body = WidgetPopDialog.new(506,_("联盟信息")):addTo(self)
    local rb_size = body:getContentSize()
    local w,h = rb_size.width,rb_size.height
    -- 联盟旗帜
    local flag_bg = display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.CENTER,100,rb_size.height-230)
        :addTo(body)
    local a_helper = WidgetAllianceUIHelper.new()
    local flag_sprite = a_helper:CreateFlagWithRhombusTerrain(basic.terrain
        ,Flag.new():DecodeFromJson(basic.flag))
    flag_sprite:scale(0.85)
    flag_sprite:align(display.CENTER, flag_bg:getContentSize().width/2, flag_bg:getContentSize().height/2-20)
        :addTo(flag_bg)

    -- 联盟名字和tag
    local title_bg = display.newScale9Sprite("title_blue_588X30.png", w-30, h-180,cc.size(438,30))
        :align(display.RIGHT_CENTER)
        :addTo(body)

    -- 联盟tag和名字
    local index_box  = UIKit:ttfLabel({
        text = "["..basic.tag.."]"..basic.name,
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
    addAttr(_("语言"),basic.language,180,h-250)
    addAttr(_("战斗力"),basic.power,350,h-220)
    addAttr(_("击杀"),basic.kill,350,h-250)
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
            {_("名城占领时间"),"2d 23h 4m"},
            {_("击杀部队人口"),string.formatnumberthousands(countInfo.kill)},
            {_("阵亡部队人口"),string.formatnumberthousands(countInfo.beKilled)},
            {_("击溃城市"),string.formatnumberthousands(countInfo.routCount)},
            {_("联盟战胜利"),string.formatnumberthousands(countInfo.winCount)},
            {_("联盟战失败"),string.formatnumberthousands(countInfo.failedCount)},
            {_("胜率"),(math.floor(countInfo.winCount/(countInfo.winCount+countInfo.failedCount)*1000)/10).."%"},
        },
        h =300
    }):align(display.TOP_CENTER, w/2 , h-330)
        :addTo(body)
end

function GameUIAllianceBattle:OnBasicChanged(alliance,changed_map)
    if changed_map.status then
        self:InitBattleStatistics()
    end
end
function GameUIAllianceBattle:OnCountDataChanged(changed_map)
    self:RefreshFightInfoList()
end

function GameUIAllianceBattle:GetAlliancePeriod()
    local period = ""
    local status = self.alliance:Status()
    if status == "peace" then
        period = _("和平期")
    elseif status == "prepare" then
        period = _("准备期")
    elseif status == "fight" then
        period = _("战争期")
    elseif status == "protect" then
        period = _("保护期")
    end
    return period
end

function GameUIAllianceBattle:OnAllianceFightRequestsChanged(request_num)
    if self.request_num_label then
        self.request_num_label:setString(request_num)
    end
end
function GameUIAllianceBattle:OnAllianceFightReportsChanged(changed_map)
    LuaUtils:outputTable("OnAllianceFightReportsChanged changed_map", changed_map)
    if changed_map.add then
        for k,v in pairs(changed_map.add) do
            self:AddHistoryItem(v, 1)
        end
    end
    if changed_map.remove then
        for _,report in pairs(changed_map.remove) do
            if self.history_items[report.id] then
                self.history_listview:removeItem(self.history_items[report.id])
            end
        end
    end
    self.history_listview:reload()
end

return GameUIAllianceBattle















