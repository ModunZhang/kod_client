local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIMoonGate = UIKit:createUIClass('GameUIMoonGate', "GameUIAllianceBuilding")
local Flag = import("..entity.Flag")
local GameUIAllianceSendTroops = import(".GameUIAllianceSendTroops")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Localize = import("..utils.Localize")

local img_dir = "allianceHome/"

function GameUIMoonGate:ctor(city,default_tab,building)
    GameUIMoonGate.super.ctor(self, city, _("月门"),default_tab,building)
    self.default_tab = default_tab
    self.building = building
    self.alliance = Alliance_Manager:GetMyAlliance()
end

function GameUIMoonGate:onEnter()
    GameUIMoonGate.super.onEnter(self)
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
    local layer = self.battlefield_layer
    self:CreateFightPlayer(
        {
            progress_type = "blue",
            name = "PlayerName",
            power = 98877711,
        }
    ):align(display.RIGHT_TOP, window.cx-6, window.top-160)
        :addTo(layer)
    self:CreateFightPlayer(
        {
            progress_type = "red",
            name = "PlayerName",
            power = 1111111,
        }
    ):align(display.LEFT_TOP, window.cx+10, window.top-160)
        :addTo(layer)
    local moon_bg = display.newSprite(img_dir.."ring_1.png")
        :align(display.CENTER, window.cx, window.top-144)
        :addTo(layer)
    display.newSprite(img_dir.."ring_red.png")
        :align(display.CENTER, moon_bg:getContentSize().width/2,moon_bg:getContentSize().height/2)
        :addTo(moon_bg)
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
    -- 战斗记录 listview
    self.war_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a004400),
        viewRect = cc.rect(window.cx-304, window.bottom+40, 608, 424),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(layer)
    self:CreateWarRecordItem(true)
    self:CreateWarRecordItem()
    self:CreateWarRecordItem()
    self:CreateWarRecordItem()
    self.war_listview:reload()
end

function GameUIMoonGate:SetMoonGateBelong(alliance_name)
    self.moongate_belong_label:setString(_("月门归属：")..alliance_name)
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

function GameUIMoonGate:CreateFightPlayer(params)
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
    local acc_attr = attr[params.progress_type]


    local player = display.newSprite(acc_attr.flag)
    local size = player:getContentSize()
    --进度条
    local x = params.progress_type == "blue" and -14 or size.width+10
    local bar_align = params.progress_type == "blue" and display.LEFT_BOTTOM or display.RIGHT_BOTTOM
    local bar = display.newSprite(acc_attr.bar):addTo(player)
        :align(bar_align, x, size.height)
    local progressFill = display.newSprite(acc_attr.pFill)
    local pro = cc.ProgressTimer:create(progressFill)
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    local ccp = params.progress_type == "blue" and cc.p(0,0) or cc.p(1,0)
    pro:setMidpoint(ccp)
    pro:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    display.newSprite(acc_attr.frame):align(display.LEFT_BOTTOM):addTo(bar)
    -- name
    local x = params.progress_type == "blue" and 0 or size.width
    local y = params.progress_type == "blue" and size.height+2 or size.height+3
    local align = params.progress_type == "blue" and display.LEFT_TOP or display.RIGHT_TOP
    local name_bg = display.newSprite(acc_attr.nameBg)
        :align(align,x,y):addTo(player)
    local name = UIKit:ttfLabel({
        text = params.name,
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
        text = string.formatnumberthousands(params.power),
        size = 18,
        color = 0xbbae80,
    }):align(display.LEFT_CENTER,80,power_bg:getContentSize().height/2)
        :addTo(power_bg)

    local x = params.progress_type == "blue" and 4 or size.width-4
    local align = params.progress_type == "blue" and display.LEFT_BOTTOM or display.RIGHT_BOTTOM
    local win_num = UIKit:ttfLabel({
        text = _("连胜").." X3",
        size = 18,
        color = 0x797154,
    }):addTo(player)
        :align(align,x,bar:getPositionY()+bar:getContentSize().height)
    -- dragon icon
    local x = params.progress_type == "blue" and size.width-100 or 100
    local dragon_bg = display.newSprite("chat_hero_background.png")
        :align(display.CENTER, x,90)
        :addTo(player)
    -- :scale(0.8)
    local dragon_img = display.newSprite(img_dir.."dragon_red.png")
        :align(display.CENTER, dragon_bg:getContentSize().width/2, dragon_bg:getContentSize().height/2+5)
        :addTo(dragon_bg)
    if params.progress_type == "red" then
        dragon_img:flipX(true)
    end
    -- display.newSprite(img_dir.."dragon_red_icon.png"):pos(x,90):addTo(player)


    -- 联盟旗帜
    local x = params.progress_type == "blue" and 40 or 160
    local ui_helper = WidgetAllianceUIHelper.new()
    local self_flag = ui_helper:CreateFlagContentSprite(self.alliance:Flag()):scale(0.5)
    self_flag:align(display.CENTER, x, 40)
        :addTo(player)

    function player:SetWin(win)
        local ss = win == 0 and "" or _("连胜").." X"..win
        win_num:setString(ss)
        if win == 1 then
            pro:setPercentage(33)
        elseif win == 2 then
            pro:setPercentage(64)
        elseif win == 3 then
            pro:setPercentage(100)
        else
            pro:setPercentage(0)
        end
        return self
    end
    function player:SetPower(power)
        win_num:setString(string.formatnumberthousands(power))
        return self
    end

    return player
end

function GameUIMoonGate:InitGarrisonPart()

    local layer = self.garrison_layer
    local fight_bg = display.newSprite("report_back_ground.png")
        :align(display.TOP_CENTER, window.cx, window.top-110)
        :addTo(layer)
        :scale(0.95)
    UIKit:ttfLabel({
        text = "己方联盟名字",
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,80,60)
        :addTo(fight_bg)
    UIKit:ttfLabel({
        text = "敌方联盟名字",
        size = 20,
        color = 0x403c2f,
    }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width-80,60)
        :addTo(fight_bg)
    -- 己方人口
    local self_citizen_bg = display.newSprite("back_ground_138x34.png")
        :align(display.LEFT_CENTER,80,25)
        :addTo(fight_bg)
        :scale(0.9)
    display.newSprite("citizen_44x50.png")
        :align(display.CENTER,20,20)
        :addTo(self_citizen_bg)
    local self_citizen_label = UIKit:ttfLabel({
        text = GameUtils:formatNumber(2020921),
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
    -- 敌方人口
    local enemy_citizen_bg = display.newSprite("back_ground_138x34.png")
        :align(display.RIGHT_CENTER,fight_bg:getContentSize().width-80,25)
        :addTo(fight_bg)
        :scale(0.9)
    display.newSprite("citizen_44x50.png")
        :align(display.CENTER,20,20)
        :addTo(enemy_citizen_bg)
    local enemy_citizen_label = UIKit:ttfLabel({
        text = GameUtils:formatNumber(1111),
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,80,enemy_citizen_bg:getContentSize().height/2)
        :addTo(enemy_citizen_bg)
    -- 己方联盟旗帜
    local ui_helper = WidgetAllianceUIHelper.new()
    local self_flag = ui_helper:CreateFlagContentSprite(self.alliance:Flag()):scale(0.5)
    self_flag:align(display.CENTER, VS:getPositionX()-80, 10)
        :addTo(fight_bg)
    -- 敌方联盟旗帜
    local enemy_flag = ui_helper:CreateFlagContentSprite(self.alliance:Flag()):scale(0.5)
    enemy_flag:align(display.CENTER, VS:getPositionX()+20, 10)
        :addTo(fight_bg)



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
    self:CreateItemForListView(
        {
            list = self.garrison_listview_self,
            isSelf = true,
            is_self_army = true,
            player_name = "aa",
            level = 11,
            city_name = "rrr",
            dragon = img_dir.."dragon_green.png",
        }
    )
    self:CreateItemForListView(
        {
            list = self.garrison_listview_self,
            isSelf = true,
            is_self_army = true,
            player_name = "aa",
            level = 11,
            city_name = "rrr",
            dragon = img_dir.."dragon_green.png",
        }
    )
    self:CreateItemForListView(
        {
            list = self.garrison_listview_enemy,
            player_name = "aa",
            level = 11,
            city_name = "rrr",
            dragon = img_dir.."dragon_red.png",
        }
    )
    self.garrison_listview_enemy:reload()
    self.garrison_listview_self:reload()

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
end

function GameUIMoonGate:onExit()
    GameUIMoonGate.super.onExit(self)
end

return GameUIMoonGate

