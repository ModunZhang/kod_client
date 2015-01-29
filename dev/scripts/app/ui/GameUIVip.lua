local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetBackGroundLucid = import("..widget.WidgetBackGroundLucid")
local WidgetPlayerNode = import("..widget.WidgetPlayerNode")
local UIAutoClose = import(".UIAutoClose")
local UIListView = import(".UIListView")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetPages = import("..widget.WidgetPages")
local WidgetInfoNotListView = import("..widget.WidgetInfoNotListView")
local WidgetInfo = import("..widget.WidgetInfo")
local window = import("..utils.window")

local GameUIVip = UIKit:createUIClass('GameUIVip',"GameUIWithCommonHeader")

local BUY_AND_USE = 1
local USE = 2
local VIP_MAX_LEVEL = 10

local function __getPlayerIcons()
    return {
        "head_dragon.png",
        "Hero_1.png",
        "playerIcon_default.png",
    }
end
-- vip 经验对应 等级
local vip_level_table = {
    [1]= -1,
    [2]= 99,
    [3]=199,
    [4]=599,
    [5]=1199,
    [6]=3599,
    [7]=7999,
    [8]=19999,
    [9]=49999,
    [10]=99998,
}

-- VIP 效果总览
local VIP_EFFECIVE_ALL = {
    _("立即完成建筑时间"),
    _("协助加速(城建和科技)"),
    _("在聊天和档案中点亮VIP徽章"),
    _("木材产量增加"),
    _("石料产量增加"),
    _("铁矿产量增加"),
    _("粮食产量增加"),
    _("银币产量增加"),
    _("城民增长速度"),
    _("每日免费Gacha"),
    _("暗仓保护上限提升"),
    _("巨龙获得经验值加成"),
    _("巨龙体力恢复速度"),
    _("城墙修复速度提升"),
    _("提升带兵上限"),
    _("提升玩家部队所有类型攻击力"),
    _("提升玩家部队所有类型防御力"),
    _("提升行军速度"),
    _("到达VIP10赠送唯一特殊装饰物"),
}
-- VIP  效果数值
local VIP_EFFECIVE_VALUE = {
    [1] = {"6min","1min+0.6%",""},
    [2] = {"7min","1min+0.7%","","5%","5%","5%","5%"},
    [3] = {"8min","1min+0.8%","","6%","6%","6%","6%","5%"},
    [4] = {"9min","1min+0.9%","","7%","7%","7%","7%","6%","5%"},
    [5] = {"10min","1min+1%","","8%","8%","8%","8%","7%","7%","+1"},
    [6] = {"12min","1min+1.1%","","9%","9%","9%","9%","8%","8%","+1","5%"},
    [7] = {"15min","1min+1.2%","","10%","10%","10%","10%","10%","10%","+1","8%","5%"},
    [8] = {"18min","1min+1.3%","","12%","12%","12%","12%","12%","12%","+2","10%","8%","5%"},
    [9] = {"24min","1min+1.4%","","15%","15%","15%","15%","15%","15%","+2","12%","12%","10%","5%","5%","5%","5%","5%"},
    [10] = {"30min","1min+1.5%","","20%","20%","20%","20%","20%","20%","+2","15%","15%","15%","10%","10%","10%","10%","10%",""},
}

function GameUIVip:ctor(city,default_tag)
    GameUIVip.super.ctor(self,city,_("PLAYER INFO"))
    self.default_tag = default_tag
end

function GameUIVip:CreateBetweenBgAndTitle()
    GameUIVip.super.CreateBetweenBgAndTitle(self)
    self.player_node = WidgetPlayerNode.new(cc.size(564,760),self)
        :addTo(self):pos(window.cx-564/2,window.bottom_top+30)
    self.vip_layer = display.newLayer():addTo(self)
    self:RefreshListView()
end

function GameUIVip:RefreshListView()
    self.player_node:RefreshUI()
end

function GameUIVip:AdapterPlayerList()
    local infos = {}
    local alliance = Alliance_Manager:GetMyAlliance()
    if not alliance:IsDefault() then
        local member = alliance:GetMemeberById(DataManager:getUserData()._id)
    end
    table.insert(infos,{_("职位"),member and member:Title() or ""})
    table.insert(infos,{_("联盟"),alliance and alliance:Name() or ""})
    table.insert(infos,{_("忠诚值"),member and member:Loyalty() or ""})
    table.insert(infos,{_("击杀"),member and member:Kill() or ""})
    table.insert(infos,{_("胜率"),"假的"})
    table.insert(infos,{_("进攻胜利"),"假的"})
    table.insert(infos,{_("防御胜利"),"假的"})
    table.insert(infos,{_("采集木材熟练度"),"假的"})
    table.insert(infos,{_("采集石料熟练度"),"假的"})
    table.insert(infos,{_("采集铁矿熟练度"),"假的"})
    table.insert(infos,{_("采集粮食熟练度"),"假的"})
    return infos
end
-- 选择新头像弹出框
function GameUIVip:OpenSelectHeadIcon()
    local pd = WidgetPopDialog.new(644,_("选择头像")):addToCurrentScene()
    local body = pd:GetBody()
    self.head_icon_list = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(4, 10, 600, 600),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(body)
    for _,icon in pairs(__getPlayerIcons()) do
        self:AddIconOption(icon)
    end
    self.head_icon_list:reload()

end

function GameUIVip:AddIconOption(icon)
    local list =  self.head_icon_list
    local item =list:newItem()

    item:setItemSize(600, 138)

    local content = display.newNode()
    content:setContentSize(cc.size(600, 126))

    local bg_1 = display.newSprite("alliance_item_flag_box_126X126.png")
        :addTo(content):pos(75,63)
    local size = bg_1:getContentSize()
    local head_bg = display.newSprite("player_head_bg.png"):addTo(bg_1)
        :pos(size.width/2,size.height/2)
    display.newSprite(icon):addTo(head_bg):pos(head_bg:getContentSize().width/2,head_bg:getContentSize().height/2)
    local bg_2 = display.newSprite("alliance_approval_box_450x126.png"):addTo(bg_1)
        :align(display.LEFT_CENTER,size.width,size.height/2)
    UIKit:ttfLabel({
        text = _("头像")..icon,
        size = 24,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,10,80)
        :addTo(bg_2)
    UIKit:ttfLabel({
        text = _("解锁条件").."XXXXXX",
        size = 24,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,10,40)
        :addTo(bg_2)

    if User:Icon() ~= icon then
        WidgetPushButton.new(
            {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"},
            {scale9 = false},
            {
                disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
            }
        ):setButtonLabel(UIKit:ttfLabel({
            text = _("选择"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                end
            end):addTo(bg_2):align(display.RIGHT_CENTER, bg_2:getContentSize().width-10,40)
            :setButtonEnabled(false)
    else
        UIKit:ttfLabel({
            text = _("已装备"),
            size = 24,
            color = 0xffedae,
        }):addTo(bg_2):align(display.RIGHT_CENTER, bg_2:getContentSize().width-10,40)
    end


    item:addContent(content)
    list:addItem(item)
end
--WidgetPlayerNode的回调方法
--点击勋章
function GameUIVip:WidgetPlayerNode_OnMedalButtonClicked(index)
    print("OnMedalButtonClicked-->",index)
end
-- 点击头衔
function GameUIVip:WidgetPlayerNode_OnTitleButtonClicked()
    print("OnTitleButtonClicked-->")
end
--修改头像
function GameUIVip:WidgetPlayerNode_OnPlayerIconCliked()
    print("WidgetPlayerNode_OnPlayerIconCliked-->")
    self:OpenSelectHeadIcon()
end
--修改玩家名
function GameUIVip:WidgetPlayerNode_OnPlayerNameCliked()
    print("WidgetPlayerNode_OnPlayerNameCliked-->")
end
--决定按钮是否可以点击
function GameUIVip:WidgetPlayerNode_PlayerCanClickedButton(name,args)
    print("WidgetPlayerNode_PlayerCanClickedButton-->",name)
    if name == 'Medal' then --点击勋章
        return false
    elseif name == 'PlayerIcon' then --修改头像
        return true
    elseif name == 'PlayerTitle' then -- 点击头衔
        return false
    elseif name == 'PlayerName' then --修改玩家名
        return true
    end

end
--数据回调
function GameUIVip:WidgetPlayerNode_DataSource(name)
    if name == 'BasicInfoData' then
        local exp_config = GameDatas.PlayerInitData.playerLevel[User:Level()]
        local levelUpExp = exp_config.expTo - exp_config.expFrom
        return {
            name = User:Name(),
            lv = User:Level(),
            currentExp = User:LevelExp(),
            maxExp = levelUpExp,
            power = User:Power(),
            playerId = User:Id(),
            playerIcon = User:Icon(),
            vip = "88"
        }
    elseif name == "MedalData"  then
        return {} -- {"xx.png","xx.png"}
    elseif name == "TitleData"  then
        return {} -- {image = "xxx.png",desc = "我是头衔"}
    elseif name == "DataInfoData"  then
        return self:AdapterPlayerList() -- {{"职位","将军"},{"职位","将军"},{"职位","将军"}}
    end
end
function GameUIVip:onEnter()
    GameUIVip.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "info",
            default = self.default_tag == "info"
        },
        {
            label = _("VIP"),
            tag = "VIP",
            default = self.default_tag == "VIP"
        },
    }, function(tag)
        if tag == 'info' then
            self.player_node:setVisible(true)
        else
            self.player_node:setVisible(false)
        end
        if tag == 'VIP' then
            self.vip_layer:setVisible(true)
        else
            self.vip_layer:setVisible(false)
        end

    end):pos(window.cx, window.bottom + 34)
    self:InitVip()
end

function GameUIVip:InitVip()
    self:CreateAD():addTo(self.vip_layer):align(display.CENTER_TOP, display.cx - 2, display.top-46)
    local exp_bar = self:CreateVipExpBar():addTo(self.vip_layer):pos(display.cx-287, display.top-300)
    exp_bar:LightLevelBar(self:GetVipLevelByExp(95000))
    self:CreateVIPStatus()
end

-- 创建广告框
function GameUIVip:CreateAD()
    local ad = display.newSprite("allianceHome/banner.png")

    display.newSprite("line_663x58.png"):addTo(ad):pos(ad:getContentSize().width/2,6)
    return ad
end

-- 创建vip等级经验条
function GameUIVip:CreateVipExpBar()
    local  head_width = 35 -- 两头经验圈宽度
    local  mid_width = 34 -- 中间各个经验圈宽度
    local  level_width = 26 -- 各个等级间的进度条的宽度

    local ExpBar = display.newNode()
    function ExpBar:AddLevelBar(level,bar)
        self.level_bar = self.level_bar or {}
        self.level_bar["level_bar_"..level] = bar
    end

    function ExpBar:AddLevelExpBar(level,exp_bar)
        self.exp_bar = self.exp_bar or {}
        self.exp_bar["exp_bar_"..level] = exp_bar
    end
    function ExpBar:AddLevelImage(level,image)
        self.level_images = self.level_images or {}
        self.level_images["level_image_"..level] = image
    end
    function ExpBar:CreateTip(image,level)
        local tip = display.newSprite(image)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("VIP"..level),
            size = 18,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}):addTo(tip):align(display.CENTER, tip:getContentSize().width/2, 50)
        cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = vip_level_table[level]+1,
            size = 16,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}):addTo(tip):align(display.CENTER, tip:getContentSize().width/2, 25)
        return tip
    end
    --[[
        设置经验条等级
        @param level 达到等级
        @param per 下一级升级当前百分比
    ]]
    function ExpBar:LightLevelBar(level,per,exp)
        for i=1,level do
            self.level_images["level_image_"..i]:setVisible(true)
            self.level_bar["level_bar_"..i]:setVisible(true)
            if self.exp_bar["exp_bar_"..i-1] then
                self.exp_bar["exp_bar_"..i-1]:setPercentage(100)
            end
        end
        if per then
            self.exp_bar["exp_bar_"..level]:setPercentage(per)
        end
        if not self.tip_1 then
            self.tip_1 = self:CreateTip("vip_level_tip_bg_1.png",level):addTo(self):scale(0.9)

            if level<VIP_MAX_LEVEL then
                self.tip_2 = self:CreateTip("vip_level_tip_bg_2.png",level+1):addTo(self):scale(0.9)
            end
        end
        local x = self.level_bar["level_bar_"..level]:getParent():getPosition()
        -- 由于两头的圈使用的图片宽度为单数，所以锚点都设置在了左边中心而不是中间圈那样的锚点在中心，此时需要tip框中心找到其中心位置
        x = x + ((level == 1 or level == VIP_MAX_LEVEL) and 17 or 0)
        self.tip_1:align(display.BOTTOM_CENTER, x, 20)
        if level<VIP_MAX_LEVEL then
            local x = self.level_bar["level_bar_"..level+1]:getParent():getPosition()
            x = x + ((level+1) == VIP_MAX_LEVEL and 17 or 0)
            self.tip_2:align(display.BOTTOM_CENTER, x, 20)
        else
            self:removeChild(self.tip_2)
        end
        -- 添加vip经验 指针
        if level<VIP_MAX_LEVEL then
            x = x + (per and math.floor(level_width*per/100+head_width/2) or 0)
            if not self.vip_exp_point then
                self.vip_exp_point = display.newSprite("vip_point.png"):addTo(self)
                cc.ui.UILabel.new({
                    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = exp,
                    size = 14,
                    font = UIKit:getFontFilePath(),
                    color = UIKit:hex2c3b(0x403c2f)}):addTo(self.vip_exp_point):align(display.LEFT_CENTER, 24, 10)
            end
            self.vip_exp_point:align(display.TOP_CENTER, x, -20)
        else
            if self.vip_exp_point then
                self:removeChild(self.vip_exp_point)
            end
        end

    end

    local function createProgressTimer()
        local progressFill = display.newSprite("vip_lv_bar_6.png")
        local ProgressTimer = cc.ProgressTimer:create(progressFill)
        ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
        ProgressTimer:setBarChangeRate(cc.p(1,0))
        ProgressTimer:setMidpoint(cc.p(0,0))
        return ProgressTimer
    end
    local current_x = 0
    for i=1,VIP_MAX_LEVEL do
        local lv_bg
        if i==1 then
            lv_bg = display.newSprite("vip_lv_bar_1.png"):addTo(ExpBar):align(display.LEFT_CENTER, 0, 0)
            ExpBar:AddLevelBar(i,display.newSprite("vip_lv_bar_3.png"):addTo(lv_bg)
                :align(display.CENTER, lv_bg:getContentSize().width/2+3, lv_bg:getContentSize().height/2))
            current_x = current_x + head_width
            local exp = display.newSprite("vip_lv_bar_5.png"):addTo(ExpBar):align(display.CENTER, current_x+level_width/2, 0)
            local ProgressTimer = createProgressTimer():align(display.LEFT_CENTER, 0, exp:getContentSize().height/2):addTo(exp)
            -- ProgressTimer:setPercentage(100)
            ExpBar:AddLevelExpBar(i,ProgressTimer)
            current_x = current_x + level_width
        elseif i>1 and i<VIP_MAX_LEVEL then
            lv_bg = display.newSprite("vip_lv_bar_2.png"):addTo(ExpBar):align(display.CENTER, current_x+mid_width/2, 0)
            local light = display.newSprite("vip_lv_bar_4.png"):addTo(lv_bg)
                :align(display.CENTER, lv_bg:getContentSize().width/2, lv_bg:getContentSize().height/2)
            light:setVisible(false)
            ExpBar:AddLevelBar(i,light)
            current_x = current_x + mid_width
            local exp = display.newSprite("vip_lv_bar_5.png"):addTo(ExpBar):align(display.CENTER, current_x+level_width/2, 0)
            local ProgressTimer = createProgressTimer():align(display.LEFT_CENTER, 0, exp:getContentSize().height/2):addTo(exp)
            -- ProgressTimer:setPercentage(100)
            ExpBar:AddLevelExpBar(i,ProgressTimer)

            current_x = current_x + level_width
        elseif i==VIP_MAX_LEVEL then
            lv_bg = display.newSprite("vip_lv_bar_1.png"):addTo(ExpBar):align(display.LEFT_CENTER, current_x, 0)
            lv_bg:setFlippedX(true)
            local light = display.newSprite("vip_lv_bar_3.png"):addTo(lv_bg,1,i)
                :align(display.CENTER, lv_bg:getContentSize().width/2-3, lv_bg:getContentSize().height/2)
            light:setVisible(false)
            ExpBar:AddLevelBar(i,light)
            light:setFlippedX(true)
        end
        local level_image = display.newSprite(i..".png"):addTo(lv_bg,1,i*100)
            :align(display.CENTER, lv_bg:getContentSize().width/2, lv_bg:getContentSize().height/2)
            :scale(0.5)
        level_image:setVisible(false)
        ExpBar:AddLevelImage(i,level_image)
    end

    return ExpBar
end

function GameUIVip:CreateVIPStatus()
    local status_bg = WidgetUIBackGround.new({height=532,isFrame="yes"}):addTo(self.vip_layer)
        :align(display.BOTTOM_CENTER, display.cx, display.top-880)
    local bg_size = status_bg:getContentSize()
    -- 透明边框
    WidgetBackGroundLucid.new(300):addTo(status_bg)
        :align(display.TOP_CENTER, bg_size.width/2, bg_size.height-60)

    local title_bg = display.newSprite("title_purple_586x34.png"):addTo(status_bg)
        :align(display.CENTER, bg_size.width/2, bg_size.height-35)
    local title =  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("未激活VIP"),
        size = 22,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xffedae)}):addTo(title_bg)
        :align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height/2)
    -- 增加VIP点数按钮
    local increase_vip_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("增加VIP点数"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    increase_vip_label:enableShadow()
    WidgetPushButton.new(
        {normal = "yellow_button_highlight_190x46.png", pressed = "yellow_button_190x46.png"},
        {scale9 = false}
    ):setButtonLabel(increase_vip_label)
        :addTo(status_bg):align(display.CENTER, 120, bg_size.height-100)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:OpenIncreaseVIPPoint()
            end
        end)
    -- 激活VIP按钮
    local active_vip_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("激活VIP"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    active_vip_label:enableShadow()
    WidgetPushButton.new(
        {normal = "yellow_button_highlight_190x46.png", pressed = "yellow_button_190x46.png"},
        {scale9 = false}
    ):setButtonLabel(active_vip_label)
        :addTo(status_bg):align(display.CENTER, bg_size.width-120, bg_size.height-100)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:OpenActiveVIP()
            end
        end)

    local widget_info = WidgetInfoNotListView.new(
        {
            info={
                {_("当前VIP等级"),_("LV 3")},
                {_("下一次登录"),_("+150 VIP 点数")},
                {_("连续登录"),_("5天")},
            }
        }
    ):align(display.CENTER, bg_size.width/2, 90)
        :addTo(status_bg)
    
    local vip_button_group = self:CreateVIPButtons(1):addTo(status_bg)
    vip_button_group:pos(bg_size.width/2 - vip_button_group:getContentSize().width/2, 200)
end

function GameUIVip:CreateVIPButtons(level)
    local button_group = display.newLayer()
    button_group:setContentSize(cc.size(560,210))

    local gap_x = 112
    for i=1,VIP_MAX_LEVEL do
        local button
        if i<=level then
            button = WidgetPushButton.new(
                {normal = "vip_unlock.png", pressed = "vip_unlock.png"},
                {scale9 = false}
            ):addTo(button_group):align(display.LEFT_BOTTOM, (math.mod(i-1,5))*gap_x, 90-math.floor((i-1)/5)*110)
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        self:OpenVIPDetails(i)
                    end
                end)
        else
            button = WidgetPushButton.new(
                {normal = "vip_lock.png", pressed = "vip_lock.png"},
                {scale9 = false}
            ):addTo(button_group):align(display.LEFT_BOTTOM, (math.mod(i-1,5))*gap_x, 90-math.floor((i-1)/5)*110)
                :onButtonClicked(function(event)
                    if event.name == "CLICKED_EVENT" then
                        self:OpenVIPDetails(i)
                    end
                end)

        end
        display.newSprite("vip"..i..".png"):addTo(button)
            :align(display.CENTER, 52,45)
    end
    return button_group
end

-- 构造分割线显示信息方法
function GameUIVip:CreateDividing(prams)
    -- 分割线
    local line = display.newScale9Sprite("dividing_line.png",prams.x, prams.y, cc.size(prams.width,2))

    -- title
    local title = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = prams.title,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = prams.title_color
        }):align(display.LEFT_CENTER, 10, 12)
        :addTo(line)
    -- title value
    local value = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = prams.value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = prams.value_color
        }):align(display.RIGHT_CENTER, line:getCascadeBoundingBox().size.width-10, 12)
        :addTo(line)

    function line:SetValue( string )
        value:setString(string)
        return self
    end
    return line
end

function GameUIVip:OpenIncreaseVIPPoint()
    local body,layer = self:CreateBackGroundWithTitle(_("增加VIP点数"))
    layer:addTo(self)

    local rb_size = body:getContentSize()

    self:CreateVIPItem({
        value = "9999",
        gem = true,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = BUY_AND_USE,
        listener = function (  )
            print("BUY_AND_USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-160)
    self:CreateVIPItem({
        value = "OWN 2",
        gem = false,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = USE,
        listener = function (  )
            print("USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-300)
    self:CreateVIPItem({
        value = "OWN 2",
        gem = false,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = USE,
        listener = function (  )
            print("USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-440)
end

function GameUIVip:OpenActiveVIP()
    local body,layer = self:CreateBackGroundWithTitle(_("激活VIP"))
    layer:addTo(self)

    local rb_size = body:getContentSize()
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("如果当前VIP已被激活，使用激活VIP道具提供的时间将会自动叠加"),
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(500,100),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER_TOP, body:getContentSize().width/2, body:getContentSize().height-40)
        :addTo(body)
    self:CreateVIPItem({
        value = "9999",
        gem = true,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = BUY_AND_USE,
        listener = function (  )
            print("BUY_AND_USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-260)
    self:CreateVIPItem({
        value = "OWN 2",
        gem = false,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = USE,
        listener = function (  )
            print("USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-390)
    self:CreateVIPItem({
        value = "OWN 2",
        gem = false,
        first_label = _("100点VIP 点数"),
        second_label = _("使用后增长100 点VIP点数"),
        btn_type = USE,
        listener = function (  )
            print("USE")
        end,
    }):addTo(body):pos(rb_size.width/2-290, rb_size.height-520)
end

function GameUIVip:CreateBackGroundWithTitle(title_string)
    local layer = UIAutoClose.new()
    local body = WidgetUIBackGround.new({height=643}):align(display.TOP_CENTER,display.cx,display.top-200)
    layer:addTouchAbleChild(body)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+10)
        :addTo(body)
    local title_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = title_string,
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2)
        :addTo(title)
    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            layer:removeFromParent()
        end):align(display.CENTER, title:getContentSize().width-20, title:getContentSize().height-20)
        :addTo(title)
    return body,layer
end

function GameUIVip:CreateVIPItem(params)
    local body = display.newColorLayer(cc.c4b(0,0,0,0))
    body:setContentSize(cc.size(580,138))
    local prop_bg = display.newSprite("box_136x138.png"):align(display.LEFT_BOTTOM, 0,0):addTo(body)
    local prop_icon = display.newSprite("vip_tool_icon.png")
        :align(display.CENTER, prop_bg:getContentSize().width/2,prop_bg:getContentSize().height/2)
        :addTo(prop_bg)
    local num_bg = display.newSprite("vip_bg_2.png")
        :align(display.BOTTOM_CENTER, prop_bg:getContentSize().width/2,6)
        :addTo(prop_bg)
    local num_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = params.value,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0xffedae)
        })
        :addTo(num_bg)
    if params.gem then
        local gem_icon = display.newSprite("home/gem_1.png"):align(display.RIGHT_CENTER, 42,num_bg:getContentSize().height/2):addTo(num_bg):scale(0.5)
        num_label:align(display.LEFT_CENTER, 45, num_bg:getContentSize().height/2)
    else
        num_label:align(display.CENTER, num_bg:getContentSize().width/2, num_bg:getContentSize().height/2)
    end

    local des_bg = display.newSprite("vip_bg_3.png"):align(display.LEFT_BOTTOM, 126,6):addTo(body)

    local eff_label_1 = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = params.first_label,
            font = UIKit:getFontFilePath(),
            size = 24,
            color = UIKit:hex2c3b(0x514d3e)
        }):align(display.LEFT_CENTER,140, 100)
        :addTo(body)
    local eff_label_2 = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = params.second_label,
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER,140, 60)
        :addTo(body)
    local button_label_str,normal_img,pressed_img
    if params.btn_type == BUY_AND_USE then
        button_label_str,normal_img,pressed_img = _("购买使用"),"green_btn_up_142x39.png","green_btn_down_142x39.png"
    else
        button_label_str,normal_img,pressed_img = _("使用"),"yellow_btn_up_149x47.png","yellow_btn_down_149x47.png"
    end
    local button_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = button_label_str,
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    button_label:enableShadow()
    local button = WidgetPushButton.new(
        {normal = normal_img, pressed = pressed_img},
        {scale9 = false}
    ):setButtonLabel(button_label)
        :addTo(body):align(display.CENTER, 500,30)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                params.listener()
            end
        end)

    return body
end
function GameUIVip:GetVIPInfoByLevel(level)
    local info ={}
    for k,v in pairs(VIP_EFFECIVE_VALUE[level]) do
        local tmp_tip = VIP_EFFECIVE_ALL[k]..v
        table.insert(info, {tmp_tip})
    end
    return info
end
function GameUIVip:SetVIPInfo(level)
    local info = self:GetVIPInfoByLevel(level)
    self.widget_info:SetInfo(info)
end
function GameUIVip:OpenVIPDetails(show_vip_level)
    local layer = WidgetPopDialog.new(737,_("VIP"),display.top-140,"title_purple_600x52.png")
        :addToCurrentScene()
    local body = layer:GetBody()
    local size = body:getContentSize()
    self.widget_info = WidgetInfo.new({info={},h=500}):align(display.TOP_CENTER, size.width/2, size.height-90)
        :addTo(body)
    local widget_page = WidgetPages.new({
        page = 10, -- 页数
        titles =  {"VIP 1","VIP 2","VIP 3","VIP 4","VIP 5","VIP 6","VIP 7","VIP 8","VIP 9","VIP 10",}, -- 标题 type -> table
        cb = function (page)
            self:SetVIPInfo(page)
        end,
        current_page = show_vip_level,
        icon = "vip_king_icon.png"
    }):align(display.CENTER, size.width/2, size.height-50)
        :addTo(body)

    self.reach_bg = display.newSprite("vip_bg_4.png")
    local reach_bg = self.reach_bg

    reach_bg:hide()

    reach_bg:align(display.CENTER, size.width/2, 40)
        :addTo(body)
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("已达成"),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER, reach_bg:getContentSize().width/2, reach_bg:getContentSize().height/2)
        :addTo(reach_bg)
    self.not_reach_bg  = display.newSprite("vip_bg_5.png")
    local not_reach_bg = self.not_reach_bg
    not_reach_bg:align(display.CENTER, size.width/2, 80)
        :addTo(body)
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("到达等级赠送"),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0xefdea3)
        }):align(display.LEFT_CENTER, 120, 70)
        :addTo(not_reach_bg)
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("7 DAY"),
            font = UIKit:getFontFilePath(),
            size = 18,
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER, 70, 12)
        :addTo(not_reach_bg)

end

-- 根据当前vip exp 获取对应VIP等级
function GameUIVip:GetVipLevelByExp(exp)
    for i=VIP_MAX_LEVEL,1,-1 do
        if exp > vip_level_table[i] then
            local percent = math.floor((exp - vip_level_table[i])/vip_level_table[i+1]*100)
            return i,percent,exp
        end
    end

end

return GameUIVip















