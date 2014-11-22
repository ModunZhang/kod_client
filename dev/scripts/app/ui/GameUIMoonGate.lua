local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIMoonGate = UIKit:createUIClass('GameUIMoonGate', "GameUIAllianceBuilding")
local Flag = import("..entity.Flag")
local GameUIAllianceSendTroops = import(".GameUIAllianceSendTroops")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Localize = import("..utils.Localize")
local AllianceMoonGate = import("..entity.AllianceMoonGate")
local NORMAL = GameDatas.UnitsConfig.normal
local SPECIAL = GameDatas.UnitsConfig.special
local img_dir = "allianceHome/"

function GameUIMoonGate:ctor(city,default_tab,building)
    GameUIMoonGate.super.ctor(self, city, _("月门"),default_tab,building)
    self.default_tab = default_tab
    self.building = building
    self.alliance = Alliance_Manager:GetMyAlliance()
    self.alliance_moonGate = Alliance_Manager:GetMyAlliance():GetAllianceMoonGate()
end

function GameUIMoonGate:onEnter()
    GameUIMoonGate.super.onEnter(self)
    local moon_gate = self.alliance_moonGate
    moon_gate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateOwnerChanged)
    moon_gate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnOurTroopsChanged)
    moon_gate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnEnemyTroopsChanged)
    moon_gate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnCurrentFightTroopsChanged)
    moon_gate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnFightReportsChanged)
    moon_gate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateDataReset)


    self:CreateTabButtons({
        {
            label = _("战场"),
            tag = "battlefield",
            default = "battlefield" == self.default_tab,
        },
        {
            label = _("驻防部队"),
            tag = "garrison",
            default = "garrison" == self.default_tab,
        },
    }, function(tag)
        if tag == 'garrison' then
            self.garrison_layer:setVisible(true)
        else
            self.garrison_layer:setVisible(false)
        end
        if tag == 'battlefield' then
            self.battlefield_layer:setVisible(true)
        else
            self.battlefield_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
    self:InitBattlefieldPart()
    self:InitGarrisonPart()
end
function GameUIMoonGate:CreateBetweenBgAndTitle()
    GameUIMoonGate.super.CreateBetweenBgAndTitle(self)

    -- garrison_layer
    self.garrison_layer = display.newLayer()
    self:addChild(self.garrison_layer)
    -- battlefield_layer
    self.battlefield_layer = display.newLayer()
    self:addChild(self.battlefield_layer)
end

function GameUIMoonGate:InitBattlefieldPart()
    local alliance = self.alliance
    local moon_gate = self.alliance_moonGate

    local layer = self.battlefield_layer

    -- 正在作战的部队
    self.camp_blue = self:CreateFightPlayer("blue"):align(display.RIGHT_TOP, window.cx-6, window.top-160)
        :addTo(layer)
    self.camp_red = self:CreateFightPlayer("red"):align(display.LEFT_TOP, window.cx+10, window.top-160)
        :addTo(layer)

    self:RefreshCurrentFightTroops(moon_gate:GetCurrentFightTroops())


    local moon_bg = display.newSprite(img_dir.."ring_1.png")
        :align(display.CENTER, window.cx, window.top-144)
        :addTo(layer)
    self.moon_owner_red = display.newSprite(img_dir.."ring_red.png")
        :align(display.CENTER, moon_bg:getContentSize().width/2,moon_bg:getContentSize().height/2)
        :addTo(moon_bg)
    self.moon_owner_red:setVisible(false)
    self.moon_owner_blue = display.newSprite(img_dir.."ring_blue.png")
        :align(display.CENTER, moon_bg:getContentSize().width/2,moon_bg:getContentSize().height/2)
        :addTo(moon_bg)
    self.moon_owner_blue:setVisible(false)
    display.newSprite(img_dir.."moongate_icon.png")
        :align(display.CENTER, moon_bg:getContentSize().width/2,moon_bg:getContentSize().height/2)
        :addTo(moon_bg)
    display.newSprite(img_dir.."ring_3.png")
        :align(display.CENTER, moon_bg:getContentSize().width/2,moon_bg:getContentSize().height/2)
        :addTo(moon_bg)
    local time_bg = display.newSprite(img_dir.."time_background.png")
        :align(display.CENTER, window.cx, window.top-310)
        :addTo(layer)
    local time_label = UIKit:ttfLabel({
        text = "30S",
        size = 18,
        color = 0xffedae,
    }):align(display.CENTER,time_bg:getContentSize().width/2,time_bg:getContentSize().height/2)
        :addTo(time_bg)
    self.moongate_belong_label = UIKit:ttfLabel({
        text = "月门归属：ALLIANCE A",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,window.cx,window.top-420)
        :addTo(layer)
    UIKit:ttfLabel({
        text = "在月门战场中，连胜3场可以占领月门",
        size = 18,
        color = 0x797154,
    }):align(display.CENTER,window.cx,window.top-450)
        :addTo(layer)
    UIKit:ttfLabel({
        text = "占领月门后可以进攻和突袭敌方领地上的城市和村落",
        size = 18,
        color = 0x797154,
    }):align(display.CENTER,window.cx,window.top-480)
        :addTo(layer)
    self:SetMoonGateBelong(moon_gate:MoonGateOwner())

    -- 战斗记录 listview
    self.war_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a004400),
        viewRect = cc.rect(window.cx-304, window.bottom+40, 608, 424),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(layer)
    -- self:CreateWarRecordItem(true)
    -- self:CreateWarRecordItem()
    -- self:CreateWarRecordItem()
    -- self:CreateWarRecordItem()
    -- self.war_listview:reload()
end

function GameUIMoonGate:RefreshCurrentFightTroops(currentFightTroops)
    local our = currentFightTroops.our
    local enemy = currentFightTroops.enemy
    local blue = self.camp_blue -- 蓝方为己方
    local red = self.camp_red -- 红方为敌方
    if our then
        blue:SetPlayerName(our.name)
        blue:SetDragon(our.dragon.type)
        blue:SetFlag(self.alliance:Flag())
        blue:SetWin(our.winCount)
        -- 设置power
        blue:SetPower(self:CountPower(our.soldiers))
    else
        blue:ResetFightPlayer()
    end
    if enemy then
        -- 玩家名字
        red:SetPlayerName(enemy.name)
        -- 设置龙
        red:SetDragon(enemy.dragon.type)
        -- 设置联盟旗帜
        red:SetFlag(Flag.new():DecodeFromJson(self.alliance_moonGate:GetEnemyAlliance().flag))
        -- 设置连胜
        red:SetWin(enemy.winCount)
        -- 设置power
        red:SetPower(self:CountPower(enemy.soldiers))
    else
        red:ResetFightPlayer()
    end
end

function GameUIMoonGate:CountPower(soldiers)
    local power = 0
    for _,soldier in pairs(soldiers) do
        power = power + NORMAL[soldier.name.."_"..soldier.star].power*soldier.count
    end
    return power
end

function GameUIMoonGate:SetMoonGateBelong(moonGateOwner)
    if moonGateOwner == "our" then
        self.moongate_belong_label:setString(_("月门归属:")..self.alliance:Name())
        self.moon_owner_blue:setVisible(true)
        self.moon_owner_red:setVisible(false)
    elseif moonGateOwner == "enemy" then
        self.moongate_belong_label:setString(_("月门归属:")..self.alliance_moonGate:GetEnemyAlliance().name)
        self.moon_owner_blue:setVisible(false)
        self.moon_owner_red:setVisible(true)
    else
        self.moongate_belong_label:setString(_("月门归属:未占领"))
        self.moon_owner_blue:setVisible(false)
        self.moon_owner_red:setVisible(false)
    end
end

function GameUIMoonGate:CreateWarRecordItem(isSelected)
    local list = self.war_listview
    local item = list:newItem()
    local item_width,item_height = 608,98
    item:setItemSize(item_width,item_height)
    local content = WidgetPushButton.new({normal = img_dir.."back_ground_608x106.png",pressed = img_dir.."back_ground_608x106.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                item:OnClicked(true)
                for k,v in pairs(list:getItems()) do
                    if v~=item then
                        v:OnClicked(false)
                    end
                end
            end
        end)
    local size = content:getCascadeBoundingBox().size
    local selected_title_bg = display.newSprite(img_dir.."title_blue_588X32.png")
        :align(display.CENTER,0, 26)
        :addTo(content)
    selected_title_bg:setVisible(isSelected)
    local unselected_title_bg = display.newSprite(img_dir.."title_grey_588X32.png")
        :align(display.CENTER,0, 26)
        :addTo(content)
    unselected_title_bg:setVisible(not isSelected)
    local self_name = UIKit:ttfLabel({
        text = "己方姓名",
        size = 18,
        color = 0xffedae,
    }):align(display.LEFT_CENTER,-size.width/2+20,26)
        :addTo(content)
    local enemy_name = UIKit:ttfLabel({
        text = "敌方姓名",
        size = 18,
        color = 0xffedae,
    }):align(display.RIGHT_CENTER,size.width/2-20,26)
        :addTo(content)
    UIKit:ttfLabel({
        text = "VS",
        size = 18,
        color = 0xffedae,
    }):align(display.RIGHT_CENTER,0,26)
        :addTo(content)
    local result_own = UIKit:ttfLabel({
        text = "WIN X2",
        size = 18,
        color = 0x007c23,
    }):align(display.LEFT_CENTER,-size.width/2+20,-15)
        :addTo(content)
    local result_enemy = UIKit:ttfLabel({
        text = "LOSE",
        size = 18,
        color = 0x7e0000,
    }):align(display.RIGHT_CENTER,size.width/2-20,-15)
        :addTo(content)
    local war_time_label = UIKit:ttfLabel({
        text = "4 min ago",
        size = 18,
        color = 0x797154,
    }):align(display.CENTER,0,-20)
        :addTo(content)
    war_time_label:setVisible(not isSelected)

    -- 全部收取按钮
    local replay_btn = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("战斗回放"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER,0,-20):addTo(content)
    replay_btn:setVisible(isSelected)
    item:addContent(content)
    list:addItem(item)

    function item:OnClicked(isSelected)
        selected_title_bg:setVisible(isSelected)
        unselected_title_bg:setVisible(not isSelected)
        replay_btn:setVisible(isSelected)
        war_time_label:setVisible(not isSelected)
    end
end

function GameUIMoonGate:CreateFightPlayer(camp)
    local attr ={
        blue = {
            flag = img_dir.."flag_blue.png",
            bar = img_dir.."bar_blue_1.png",
            pFill = img_dir.."bar_blue_2.png",
            frame = img_dir.."bar_blue_3.png",
            nameBg = img_dir.."back_ground_blue_278x46.png",
        },
        red = {
            flag = img_dir.."flag_red.png",
            bar = img_dir.."bar_red_1.png",
            pFill = img_dir.."bar_red_2.png",
            frame = img_dir.."bar_red_3.png",
            nameBg = img_dir.."back_ground_red_278x46.png",
        },
    }
    local acc_attr = attr[camp]


    local player = display.newSprite(acc_attr.flag)
    -- 设置阵营
    player.camp = camp

    local size = player:getContentSize()
    --进度条
    local x = camp == "blue" and -14 or size.width+10
    local bar_align = camp == "blue" and display.LEFT_BOTTOM or display.RIGHT_BOTTOM
    local bar = display.newSprite(acc_attr.bar):addTo(player)
        :align(bar_align, x, size.height)
    local progressFill = display.newSprite(acc_attr.pFill)
    local pro = cc.ProgressTimer:create(progressFill)
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    local ccp = camp == "blue" and cc.p(0,0) or cc.p(1,0)
    pro:setMidpoint(ccp)
    pro:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    display.newSprite(acc_attr.frame):align(display.LEFT_BOTTOM):addTo(bar)
    -- name
    local x = camp == "blue" and 0 or size.width
    local y = camp == "blue" and size.height+2 or size.height+3
    local align = camp == "blue" and display.LEFT_TOP or display.RIGHT_TOP
    local name_bg = display.newSprite(acc_attr.nameBg)
        :align(align,x,y):addTo(player)
    local name = UIKit:ttfLabel({
        text = "",
        size = 18,
        color = 0xffedae,
    }):align(display.CENTER,name_bg:getContentSize().width/2,name_bg:getContentSize().height/2+4)
        :addTo(name_bg)

    -- power
    local power_bg = display.newSprite(img_dir.."back_ground_252x30.png")
        :align(display.LEFT_TOP, 5, name_bg:getPositionY()-46)
        :addTo(player)
    UIKit:ttfLabel({
        text = _("POWER"),
        size = 18,
        color = 0xbbae80,
    }):align(display.LEFT_CENTER,4,power_bg:getContentSize().height/2)
        :addTo(power_bg)
    local power = UIKit:ttfLabel({
        text = "",
        size = 18,
        color = 0xbbae80,
    }):align(display.LEFT_CENTER,80,power_bg:getContentSize().height/2)
        :addTo(power_bg)

    local x = camp == "blue" and 4 or size.width-4
    local align = camp == "blue" and display.LEFT_BOTTOM or display.RIGHT_BOTTOM
    local win_num = UIKit:ttfLabel({
        text = "",
        size = 18,
        color = 0x797154,
    }):addTo(player)
        :align(align,x,bar:getPositionY()+bar:getContentSize().height)



    function player:SetWin(win)
        local ss = win == 0 and "" or (_("连胜").." X"..win)
        win_num:setString(ss)
        if win == 1 then
            pro:setPercentage(33)
        elseif win == 2 then
            pro:setPercentage(64)
        elseif win >= 3 then
            pro:setPercentage(100)
        else
            pro:setPercentage(0)
        end
        return self
    end
    function player:SetPower(power_1)
        power:setString(string.formatnumberthousands(power_1))
        return self
    end
    function player:SetPlayerName(playerName)
        name:setString(playerName)
        return self
    end
    function player:SetFlag(flag_1)
        -- 联盟旗帜
        local x = self.camp == "blue" and 40 or 160
        local ui_helper = WidgetAllianceUIHelper.new()
        self.flag = ui_helper:CreateFlagContentSprite(flag_1):scale(0.5)
        self.flag:align(display.CENTER, x, 40)
            :addTo(self)
        self.flag:setTag(100)
        return self
    end
    function player:SetDragon(dragonType)
        -- dragon icon
        if self.dragon_bg then
            self.dragon_bg:removeAllChildren()
        else
            local x = camp == "blue" and size.width-100 or 100
            self.dragon_bg = display.newSprite("chat_hero_background.png")
                :align(display.CENTER, x,90)
                :addTo(self)
            self.dragon_bg:setTag(200)
        end

        local dragon_img = display.newSprite(img_dir..dragonType..".png")
            :align(display.CENTER, self.dragon_bg:getContentSize().width/2, self.dragon_bg:getContentSize().height/2+5)
            :addTo(self.dragon_bg)
        if self.camp == "red" then
            dragon_img:flipX(true)
        end
        return self
    end

    function player:ResetFightPlayer()
        win_num:setString("")
        power:setString("")
        name:setString("")
        if self.dragon_bg then
            self:removeChildByTag(200, true)
        end
        if self.flag then
            self:removeChildByTag(100, true)
        end
    end

    return player
end

function GameUIMoonGate:InitGarrisonPart()
    local layer = self.garrison_layer
    local fight_bg = display.newSprite("report_back_ground.png")
        :align(display.TOP_CENTER, window.cx, window.top-110)
        :addTo(layer)
        :scale(0.95)
    local our_alliance_name = UIKit:ttfLabel({
        text = "己方联盟",
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,80,60)
        :addTo(fight_bg)
    local enemy_alliance_name = UIKit:ttfLabel({
        text = "敌方联盟",
        size = 20,
        color = 0x403c2f,
    }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width-80,60)
        :addTo(fight_bg)
    -- 己方派出的部队数量
    local self_citizen_bg = display.newSprite("back_ground_138x34.png")
        :align(display.LEFT_CENTER,80,25)
        :addTo(fight_bg)
        :scale(0.9)
    display.newSprite("citizen_44x50.png")
        :align(display.CENTER,20,20)
        :addTo(self_citizen_bg)
    local self_citizen_label = UIKit:ttfLabel({
        text = "",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,80,self_citizen_bg:getContentSize().height/2)
        :addTo(self_citizen_bg)
    local VS = UIKit:ttfLabel({
        text = "VS",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,fight_bg:getContentSize().width/2,fight_bg:getContentSize().height/2)
        :addTo(fight_bg)
    -- 敌方派出的部队数量
    local enemy_citizen_bg = display.newSprite("back_ground_138x34.png")
        :align(display.RIGHT_CENTER,fight_bg:getContentSize().width-80,25)
        :addTo(fight_bg)
        :scale(0.9)
    display.newSprite("citizen_44x50.png")
        :align(display.CENTER,20,20)
        :addTo(enemy_citizen_bg)
    local enemy_citizen_label = UIKit:ttfLabel({
        text = "",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,80,enemy_citizen_bg:getContentSize().height/2)
        :addTo(enemy_citizen_bg)



    local army_list_bg = WidgetUIBackGround.new({
        width = 554,
        height = 596,
        top_img = "back_ground_258X12_top.png",
        bottom_img = "back_ground_258X12_bottom.png",
        mid_img = "back_ground_258X1_mid.png",
        u_height = 12,
        b_height = 12,
        m_height = 1,
    }):align(display.TOP_CENTER,window.cx, window.top-200):addTo(layer)
    self.garrison_listview_self = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a110000),
        viewRect = cc.rect(4, 5, 274, 586),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(army_list_bg)
    self.garrison_listview_enemy = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a112200),
        viewRect = cc.rect(278, 5, 274, 586),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(army_list_bg)


    local send_troops_btn = WidgetPushButton.new({normal = "blue_btn_up_142x39.png",pressed = "blue_btn_down_142x39.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("派兵"),
            size = 22,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
                    NetManager:getMarchToMoonGatePromose(dragonType,soldiers):catch(function(err)
                        dump(err:reason())
                    end)
                end):addToCurrentScene(true)
                self:leftButtonClicked()
            end
        end):align(display.LEFT_CENTER,window.left+50,window.top-830):addTo(layer)
    local retreat_btn = WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("撤退"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.CENTER,window.cx,window.top-830):addTo(layer)
    local single_combat_btn = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("单挑"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then

            end
        end):align(display.RIGHT_CENTER,window.right-50,window.top-830):addTo(layer)
    UIKit:ttfLabel({
        text = _("一个玩家同一时间只能在月门驻防一支部队"),
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,window.cx,window.top-870)
        :addTo(layer)



    -- 驻防部队页中的数据管理器
    self.Garrison = {}
    local Garrison = self.Garrison
    local moonGateUI = self
    Garrison.ourTroop = {}
    Garrison.enemyTroop = {}
    function Garrison:SetOurAllianceName(alliance_name)
        our_alliance_name:setString(alliance_name)
        return self
    end
    function Garrison:SetEnemyAllianceName(alliance_name)
        enemy_alliance_name:setString(alliance_name)
        return self
    end
    function Garrison:SetOurAllianceFlag(flag)
        fight_bg:removeChildByTag(100, true)
        -- 己方联盟旗帜
        local ui_helper = WidgetAllianceUIHelper.new()
        local self_flag = ui_helper:CreateFlagContentSprite(flag):scale(0.5)
        self_flag:align(display.CENTER, VS:getPositionX()-80, 10)
            :addTo(fight_bg)
        self_flag:setTag(100)
        return self
    end
    function Garrison:SetEnemyAllianceFlag(flag)
        fight_bg:removeChildByTag(101, true)
        -- 敌方联盟旗帜
        local ui_helper = WidgetAllianceUIHelper.new()
        local enemy_flag = ui_helper:CreateFlagContentSprite(flag):scale(0.5)
        enemy_flag:align(display.CENTER, VS:getPositionX()+20, 10)
            :addTo(fight_bg)
        enemy_flag:setTag(101)

        return self
    end

    function Garrison:SetOurTroopsNum(troops_num)
        self_citizen_label:setString(troops_num)
        return self
    end
    function Garrison:SetEnemyTroopsNum(troops_num)
        enemy_citizen_label:setString(troops_num)
        return self
    end
    function Garrison:AddOurTroop(troop)
        local item = moonGateUI:CreateItemForListView(
            {
                list = moonGateUI.garrison_listview_self,
                isSelf = true,
                is_self_army = troop.id == DataManager:getUserData()._id,
                player_name = troop.name,
                level = troop.level,
                city_name = troop.cityName,
                dragon = img_dir..troop.dragon.type..".png",
            }
        )
        moonGateUI.garrison_listview_self:reload()
        self.ourTroop[troop.id] = item
        return self
    end
    function Garrison:AddEnemyTroop(troop)
        local item = moonGateUI:CreateItemForListView(
            {
                list = moonGateUI.garrison_listview_enemy,
                isSelf = false,
                is_self_army = false,
                player_name = troop.name,
                level = troop.level,
                city_name = troop.cityName,
                dragon = img_dir..troop.dragon.type..".png",
            }
        )
        moonGateUI.garrison_listview_enemy:reload()
        self.enemyTroop[troop.id] = item

        return self
    end

    function Garrison:RemoveFromOurTroop(troop)
        moonGateUI.garrison_listview_self:removeItem(self.ourTroop[troop.id])
        self.ourTroop[troop.id] = nil
    end
    function Garrison:RemoveFromEnemyTroop(troop)
        moonGateUI.garrison_listview_enemy:removeItem(self.enemyTroop[troop.id])
        self.enemyTroop[troop.id] = nil
    end

    function Garrison:ResetGarrison()
        moonGateUI.garrison_listview_self:removeAllItems()
        moonGateUI.garrison_listview_enemy:removeAllItems()
        self_citizen_label:setString("")
        enemy_citizen_label:setString("")
        self_flag:removeChildByTag(100, true)
        enemy_flag:removeChildByTag(101, true)
        our_alliance_name:setString("")
        enemy_alliance_name:setString("")
    end

    -- 初始化
    local alliacne = self.alliance
    local moonGate = self.alliance_moonGate
    for k,v in pairs(moonGate:GetEnemyAlliance()) do
        Garrison:SetOurAllianceName(alliacne:Name())
        Garrison:SetEnemyAllianceName(moonGate:GetEnemyAlliance().name)
        Garrison:SetOurAllianceFlag(alliacne:Flag())
        Garrison:SetEnemyAllianceFlag(Flag.new():DecodeFromJson(moonGate:GetEnemyAlliance().flag))
        Garrison:SetOurTroopsNum(moonGate:GetOurTroopsNum())
        Garrison:SetEnemyTroopsNum(moonGate:GetEnemyTroopsNum())
        LuaUtils:outputTable("moonGate:GetOurTroops()", moonGate:GetOurTroops())
        for k,v in pairs(moonGate:GetOurTroops()) do
            Garrison:AddOurTroop(v)
        end
        for k,v in pairs(moonGate:GetEnemyTroops()) do
            Garrison:AddEnemyTroop(v)
        end
        break
    end
    
end

function GameUIMoonGate:CreateItemForListView(params)
    local list = params.list
    local isSelf = params.isSelf
    local is_self_army = params.is_self_army
    local player_name = params.player_name
    local level = params.level
    local city_name = params.city_name
    local dragon = params.dragon
    local item = list:newItem()
    local w,h = 266,120
    item:setItemSize(w, h)
    local content = display.newSprite(img_dir.."back_ground_266X116.png")
    local dragon_bg = display.newSprite("chat_hero_background.png")
        :addTo(content)
        :scale(0.8)
    local dragon_img = display.newSprite(dragon)
        :align(display.CENTER, dragon_bg:getContentSize().width/2, dragon_bg:getContentSize().height/2+5)
        :addTo(dragon_bg)
    display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.CENTER, dragon_bg:getContentSize().width/2, dragon_bg:getContentSize().height/2)
        :addTo(dragon_bg)

    -- :scale(0.9)
    local name_bg
    if is_self_army then
        if isSelf then
            name_bg = display.newSprite(img_dir.."title_green_156X30.png"):addTo(content)
        else
            name_bg = display.newSprite(img_dir.."title_blue_156X30.png"):addTo(content)
        end
    else
        name_bg = display.newSprite(img_dir.."title_red_156X30.png"):addTo(content)
    end
    UIKit:ttfLabel({
        text = player_name,
        size = 20,
        color = 0xffedae,
    }):align(display.CENTER,name_bg:getContentSize().width/2,name_bg:getContentSize().height/2)
        :addTo(name_bg)
    local info_bg = display.newSprite(img_dir.."back_ground_160X70.png"):addTo(content)
    UIKit:ttfLabel({
        text = "LV "..level,
        size = 18,
        color = 0x797154,
    }):align(display.LEFT_CENTER,10,50)
        :addTo(info_bg)
    UIKit:ttfLabel({
        text = city_name,
        size = 18,
        color = 0x797154,
    }):align(display.LEFT_CENTER,10,20)
        :addTo(info_bg)
    if is_self_army then
        dragon_bg:pos(215,h/2)
        name_bg:pos(80,h-20)
        info_bg:pos(82,40)
    else
        dragon_bg:pos(50,h/2)
        dragon_img:flipX(true)
        name_bg:pos(184,h-20)
        info_bg:pos(184,40)
    end
    item:addContent(content)
    list:addItem(item)
    return item
end
-- 月门占领方改变
function GameUIMoonGate:OnMoonGateOwnerChanged(moonGateOwner)
    print("月门占领方改变->",moonGateOwner)
    self:SetMoonGateBelong(moonGateOwner)
end
-- 己方联盟部队改变
function GameUIMoonGate:OnOurTroopsChanged(changed_map)
    LuaUtils:outputTable("己方联盟部队改变->", changed_map)
end
-- 敌方联盟部队改变
function GameUIMoonGate:OnEnemyTroopsChanged(changed_map)
    LuaUtils:outputTable("敌方联盟部队改变->", changed_map)

end
-- 正在交战的部队改变
function GameUIMoonGate:OnCurrentFightTroopsChanged(currentFightTroops)
    LuaUtils:outputTable("正在交战的部队改变->", currentFightTroops)
    self:RefreshCurrentFightTroops(currentFightTroops)
end
-- 战报改变
function GameUIMoonGate:OnFightReportsChanged(changed_map)
    LuaUtils:outputTable("战报改变->", changed_map)

end
-- 联盟战结束
function GameUIMoonGate:OnMoonGateDataReset()
    print("联盟战结束")
end

function GameUIMoonGate:onExit()
    local moon_gate = self.alliance_moonGate
    moon_gate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateOwnerChanged)
    moon_gate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnOurTroopsChanged)
    moon_gate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnEnemyTroopsChanged)
    moon_gate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnCurrentFightTroopsChanged)
    moon_gate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnFightReportsChanged)
    moon_gate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateDataReset)
    GameUIMoonGate.super.onExit(self)
end

return GameUIMoonGate











