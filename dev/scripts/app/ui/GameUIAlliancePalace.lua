local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetAllianceBuildingUpgrade = import("..widget.WidgetAllianceBuildingUpgrade")
local GameUIAlliancePalace = UIKit:createUIClass('GameUIAlliancePalace', "GameUIAllianceBuilding")
local Flag = import("..entity.Flag")
local NetService = import('..service.NetService')
local Alliance = import("..entity.Alliance")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local WidgetInfoWithTitle = import("..widget.WidgetInfoWithTitle")
local WidgetInfoNotListView = import("..widget.WidgetInfoNotListView")
local Localize = import("..utils.Localize")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetInfo = import("..widget.WidgetInfo")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetSliderWithInput = import("..widget.WidgetSliderWithInput")

function GameUIAlliancePalace:ctor(city,default_tab,building)
    GameUIAlliancePalace.super.ctor(self, city, _("联盟宫殿"),default_tab,building)
    self.default_tab = default_tab
    self.building = building
    self.alliance = Alliance_Manager:GetMyAlliance()
end

function GameUIAlliancePalace:OnMoveInStage()
    GameUIAlliancePalace.super.OnMoveInStage(self)
    self:CreateTabButtons({
        {
            label = _("奖励"),
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

    local alliance = self.alliance
    alliance:AddListenOnType(self,Alliance.LISTEN_TYPE.BASIC)
    alliance:AddListenOnType(self,Alliance.LISTEN_TYPE.MEMBER)
end
function GameUIAlliancePalace:CreateBetweenBgAndTitle()
    GameUIAlliancePalace.super.CreateBetweenBgAndTitle(self)

    -- impose_layer
    self.impose_layer = display.newLayer():addTo(self:GetView())
    -- info_layer
    self.info_layer = display.newLayer():addTo(self:GetView())
end
function GameUIAlliancePalace:onExit()
    local alliance = self.alliance
    alliance:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.BASIC)
    alliance:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.MEMBER)
    GameUIAlliancePalace.super.onExit(self)
end

-- 初始化奖励部分
function GameUIAlliancePalace:InitImposePart()
    local layer = self.impose_layer
    UIKit:ttfLabel({
        text = _("联盟荣耀"),
        size = 24,
        color = 0x514d3e,
    }):align(display.LEFT_CENTER, window.left+60,window.top_bottom-20):addTo(layer)

    -- 荣耀值
    self.current_honour = self:GetHonourNode():addTo(layer):align(display.CENTER,window.right-100, window.top_bottom-5)

    -- 可发放奖励成员列表
    local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0, 0,568,window.betweenHeaderAndTab-80),
    })
    list_node:addTo(layer):align(display.BOTTOM_CENTER, window.cx, window.bottom_top+20)
    self.award_menmber_listview = list

    self:SetAwardMemberList()

end
function GameUIAlliancePalace:SetAwardMemberList()
    self.award_menmber_listview:removeAllItems()
    local alliance = self.alliance
    local members = alliance:GetAllMembers()
    local sort_member = {}
    for k,v in pairs(members) do
        table.insert(sort_member, v)
    end
    table.sort(sort_member,function (a,b)
        return self:GetLastThreeDaysKill(a:LastThreeDaysKillData()) > self:GetLastThreeDaysKill(b:LastThreeDaysKillData())
    end)
    self.items = {}
    for i,v in ipairs(sort_member) do
        self:CreateAwardMemberItem(v,i)
    end
    self.award_menmber_listview:reload()
end
function GameUIAlliancePalace:CreateAwardMemberItem(member,index)
    local list = self.award_menmber_listview
    local item = list:newItem()
    local item_width,item_height = 568,168
    item:setItemSize(item_width,item_height)
    local content = WidgetUIBackGround.new({width=item_width,height=item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    local title_bg = display.newScale9Sprite("title_blue_430x30.png",item_width/2,item_height-30,cc.size(550,30),cc.rect(15,10,400,10))
        :addTo(content)
    -- 玩家头像
    local head_bg = display.newSprite("head_bg_46x46.png"):addTo(title_bg):pos(30,title_bg:getContentSize().height/2)
    local head_icon = display.newSprite("head_38x44.png"):addTo(head_bg):pos(head_bg:getContentSize().width/2,head_bg:getContentSize().height/2)
    -- 玩家名字
    UIKit:ttfLabel({
        text = index.."."..member:Name(),
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 60, title_bg:getContentSize().height/2):addTo(title_bg)


    -- 上次发放奖励时间
    local last_reward_time = UIKit:ttfLabel({
        size = 20,
        color = 0xc0b694,
    }):align(display.RIGHT_CENTER, title_bg:getContentSize().width-30, title_bg:getContentSize().height/2):addTo(title_bg)

    local widget_info = WidgetInfoNotListView.new({
        info={_("最近三日击杀"),""},
        {_("最近奖励"),""},
        w =398
    }):align(display.BOTTOM_LEFT, 10 , 10)
        :addTo(content)

    -- 奖励按钮
    WidgetPushButton.new({normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("奖赏"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:OpenAwardDialog(member)
            end
        end):align(display.BOTTOM_RIGHT, item_width-10,10):addTo(content)

    local palace_ui = self
    function item:RefreshItem(member)
        local lastRewardData = member:LastRewardData()
        local lastRewardTime = tolua.type(lastRewardData) == "table" and NetService:formatTimeAsTimeAgoStyleByServerTime( lastRewardData.time ) or _("无")
        local lastRewardCount = tolua.type(lastRewardData) == "table" and string.formatnumberthousands(lastRewardData.count) or _("无")
        local lastThreeDaysKill = string.formatnumberthousands(palace_ui:GetLastThreeDaysKill(member:LastThreeDaysKillData()))
        local info={
            {_("最近三日击杀"),lastThreeDaysKill},
            {_("最近奖励"),lastRewardCount},
        }
        widget_info:SetInfo(info)
        last_reward_time:setString(lastRewardTime)
    end
    item:RefreshItem(member)
    item:addContent(content)
    list:addItem(item)
    self.items[member:Id()] = item
end
function GameUIAlliancePalace:OpenAwardDialog(member)
    local dialog = WidgetPopDialog.new(282,_("奖励"),window.top-160):AddToCurrentScene()
    local body = dialog:GetBody()
    local body_size = body:getContentSize()
    self:GetHonourNode():addTo(body):align(display.BOTTOM_LEFT,50,60)

    -- 滑动条部分
    local slider_bg = display.newSprite("back_ground_580x136.png"):addTo(body)
        :align(display.CENTER_TOP,body_size.width/2,body_size.height-30)
    -- title
    UIKit:ttfLabel(
        {
            text = _("增加忠诚值"),
            size = 22,
            color = 0x403c2f,
        }):align(display.LEFT_TOP, 20 ,slider_bg:getContentSize().height-15)
        :addTo(slider_bg)
    -- slider
    local slider = WidgetSliderWithInput.new({max = self.alliance:Honour()})
        :addTo(slider_bg)
        :align(display.CENTER, slider_bg:getContentSize().width/2, self.alliance:Honour()==0 and 45 or 65)
        :OnSliderValueChanged(function(event)
            -- parms.onSliderValueChanged(math.floor(event.value))
            end)
        :LayoutValueLabel(WidgetSliderWithInput.STYLE_LAYOUT.TOP,75)

    -- icon
    local x,y = slider:GetEditBoxPostion()
    local icon = display.newSprite("loyalty_128x128.png")
        :align(display.CENTER, x-80, y)
        :addTo(slider)
    local max = math.max(icon:getContentSize().width,icon:getContentSize().height)
    icon:scale(40/max)
    --奖赏按钮
    WidgetPushButton.new({normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("奖赏"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if self.alliance:GetSelf():IsArchon() then
                    NetManager:getGiveLoyaltyToAllianceMemberPromise(member:Id(),slider:GetValue())
                    dialog:LeftButtonClicked()
                else
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("只有盟主拥有权限"))
                        :AddToCurrentScene()
                end
            end
        end):align(display.BOTTOM_RIGHT, body_size.width-20,30):addTo(body)
end
function GameUIAlliancePalace:GetLastThreeDaysKill(lastThreeDaysKillData)
    if not lastThreeDaysKillData then return 0 end
    local today = os.date("%Y",app.timer:GetServerTime()).."-"..tonumber(os.date("%m",app.timer:GetServerTime())).."-"..tonumber(os.date("%d",app.timer:GetServerTime()))
    local yesterday = os.date("%Y",app.timer:GetServerTime()-24 * 60 * 60).."-"..tonumber(os.date("%m",app.timer:GetServerTime()-24 * 60 * 60)).."-"..tonumber(os.date("%d",app.timer:GetServerTime()-24 * 60 * 60))
    local theDayBeforeYesterday = os.date("%Y",app.timer:GetServerTime()-24 * 60 * 60 * 2).."-"..tonumber(os.date("%m",app.timer:GetServerTime()-24 * 60 * 60 * 2)).."-"..tonumber(os.date("%d",app.timer:GetServerTime()-24 * 60 * 60 * 2))
    local kill = 0
    for k,v in pairs(lastThreeDaysKillData) do
        print("v.date",v.date)
        if v.date == today
            or v.date == yesterday
            or v.date == theDayBeforeYesterday
        then
            kill = kill + v.kill
        end
    end
    return kill
end
function GameUIAlliancePalace:GetHonourNode(honour)
    local node = display.newNode()
    node:setContentSize(cc.size(160,36))
    -- 荣耀值
    display.newSprite("honour_128x128.png"):align(display.CENTER, 0, 0):addTo(node):scale(20/128)
    local honour_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER,80, 0):addTo(node)
    local honour_label = UIKit:ttfLabel({
        text = honour or self.alliance:Honour(),
        size = 20,
        color = 0x403c2f,
    }):addTo(honour_bg):align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)
    function node:RefreshHonour(honour)
        honour_label:setString(honour)
    end
    return node
end
function GameUIAlliancePalace:MapTerrianToIndex(terrian)
    local terrian_type = {
        grassLand=1,
        iceField=2,
        desert=3,
    }
    return terrian_type[terrian]
end
function GameUIAlliancePalace:MapIndexToTerrian(index)
    local terrian_type = {
        "grassLand",
        "iceField",
        "desert",
    }
    return terrian_type[index]
end
function GameUIAlliancePalace:InitInfoPart()
    local layer = self.info_layer

    local bg1 = WidgetUIBackGround.new({
        width = 548,
        height = 322,
    },WidgetUIBackGround.STYLE_TYPE.STYLE_3):align(display.TOP_CENTER,window.cx, window.top-100):addTo(layer)
    local bg_size = bg1:getContentSize()
    -- title
    local title_bg = display.newSprite("title_blue_544x32.png"):addTo(bg1):pos(bg_size.width/2,bg_size.height-20)
    UIKit:ttfLabel({
        text = _("地形定义"),
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 20, title_bg:getContentSize().height/2):addTo(title_bg)
    UIKit:ttfLabel({
        text = _("需要职位是联盟盟主"),
        size = 20,
        color = 0xb7af8e,
    }):align(display.RIGHT_CENTER, title_bg:getContentSize().width-20, title_bg:getContentSize().height/2):addTo(title_bg)
    -- 草地
    display.newSprite("grass_ground1_800x560.png")
        :align(display.CENTER, 87, 220):addTo(bg1):scale(0.2)
    -- 雪地
    display.newSprite("icefield1_800x560.png")
        :align(display.CENTER, 272, 220):addTo(bg1):scale(0.2)
    -- 沙漠
    display.newSprite("desert1_800x560.png")
        :align(display.CENTER, 462, 220):addTo(bg1):scale(0.2)

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
            self.select_terrian_index = event.selected
        end)
        :align(display.CENTER, 57 , 90)
        :addTo(bg1)
    self.select_terrian_index = self:MapTerrianToIndex(self.alliance:Terrain())
    group:getButtonAtIndex(self.select_terrian_index):setButtonSelected(true)

    -- 介绍
    UIKit:ttfLabel({
        text = _("草地地形能产出绿龙装备材料，每当在自己的领土上完成任务，或者击杀一点战斗力的敌方单位，就由一定几率获得装备材料。"),
        size = 20,
        color = 0x514d3e,
        dimensions = cc.size(520, 0),
    }):align(display.BOTTOM_CENTER, bg1:getContentSize().width/2, 10):addTo(bg1)
    -- 消耗荣耀值更换地形
    local need_honour = GameDatas.AllianceInitData.intInit.editAllianceTerrianHonour.value
    self:GetHonourNode(need_honour):addTo(layer):align(display.CENTER,window.cx+30, window.top-454)

    -- 购买使用按钮
    WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("购买使用"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if need_honour>self.alliance:Honour() then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("联盟荣耀值不足"))
                        :AddToCurrentScene()
                else
                    if self.alliance:GetSelf():CanEditAlliance() then
                        NetManager:getEditAllianceTerrianPromise(self:MapIndexToTerrian(self.select_terrian_index))
                    else
                        FullScreenPopDialogUI.new():SetTitle(_("提示"))
                            :SetPopMessage(_("权限不足"))
                            :AddToCurrentScene()
                    end
                end

            end
        end):align(display.CENTER, window.right -120, window.top-470):addTo(layer)

    local countInfo = self.alliance:GetCountInfo()
    local info_message = {
        {_("击杀部队人口"),string.formatnumberthousands(countInfo.kill)},
        {_("阵亡部队人口"),string.formatnumberthousands(countInfo.beKilled)},
        {_("击溃城市"),string.formatnumberthousands(countInfo.routCount)},
        {_("联盟战胜利"),string.formatnumberthousands(countInfo.winCount)},
        {_("联盟战失败"),string.formatnumberthousands(countInfo.failedCount)},
        {_("胜率"),(math.floor(countInfo.winCount/(countInfo.winCount+countInfo.failedCount)*1000)/10).."%"},
    }
    WidgetInfoWithTitle.new({
        info = info_message,
        title = _("信息"),
        h = 306
    }):addTo(layer)
        :align(display.BOTTOM_CENTER, window.cx, window.bottom_top+20)
end
function GameUIAlliancePalace:OnBasicChanged(alliance,changed_map)
    if changed_map.honour then
        local new = changed_map.honour.new
        self.current_honour:RefreshHonour(new)
    end
end
function GameUIAlliancePalace:OnMemberChanged(alliance,changed_map)
    if not changed_map then return end
    if changed_map.added then
        for k,v in pairs(changed_map.added) do
            self:CreateAwardMemberItem(v,LuaUtils:table_size(self.award_menmber_listview:getItems()) + 1)
        end
        self.award_menmber_listview:reload()
    end
    if changed_map.removed then
        self:SetAwardMemberList()
    end
    if changed_map.changed then
        for k,v in pairs(changed_map.changed) do
            if self.items[v:Id()] then
                self.items[v:Id()]:RefreshItem(v)
            end
        end
    end
end
return GameUIAlliancePalace














