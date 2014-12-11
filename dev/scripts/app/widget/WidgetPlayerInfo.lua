local WidgetPushButton = import(".WidgetPushButton")
local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetPopDialog = import(".WidgetPopDialog")
local window = import("..utils.window")
local UIListView = import("..ui.UIListView")

local WidgetPlayerInfo = class("WidgetPlayerInfo", function ()
    return display.newLayer()
end)
function WidgetPlayerInfo:ctor()
    self.basicInfo = DataManager:getUserData().basicInfo
    -- self.basicInfo = {
    --     ["level"] = 1,
    --     ["levelExp"] = 0,
    --     ["resourceRefreshTime"] = 1418281750597,
    --     ["power"] = 620,
    --     ["vipFinishTime"] = 0,
    --     ["kill"] = 0,
    --     ["buildQueue"] = 5,
    --     ["icon"] = "playerIcon_default.png",
    --     ["vipExp"] = 0,
    --     ["cityName"] = "city_89fe2ddc",
    --     ["name"] = "player_89fe2ddc",
    --     ["language"] = "cn",
    -- }
    self:setNodeEventEnabled(true)
    return true
end
function WidgetPlayerInfo:onEnter()
    self:AddPlayerHead()
    self:AddNameBar()
    self:AddExpProgress()
    self:AddPowerAndID()
    self:AddPlayerInfo()
    self:AddMedal()
    self:AddDamnation()
end
function WidgetPlayerInfo:onExit()

end
-- 玩家头像，点击弹出选择新头像弹出框
function WidgetPlayerInfo:AddPlayerHead()
    local head_btn = WidgetPushButton.new(
        {normal = "home/player_bg.png", pressed = "home/player_bg.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:OpenSelectHeadIcon()
        end
    end)
        :addTo(self):align(display.LEFT_TOP, window.left+36, window.top-100)

    local vip_level_bg = display.newSprite("playerIcon_default.png"):addTo(head_btn)
        :align(display.CENTER,64,-50)
        :scale(0.8)
    -- vip level
    local vip_level_bg = display.newSprite("home/vip_level_bg.png"):addTo(head_btn)
        :align(display.TOP_CENTER,64,-102)

    UIKit:ttfLabel({
        text = _("VIP ")..88,
        size = 18,
        color = 0xe19319,
        shadow = true
    }):align(display.CENTER,vip_level_bg:getContentSize().width/2,38)
        :addTo(vip_level_bg)
end
-- 选择新头像弹出框
function WidgetPlayerInfo:OpenSelectHeadIcon()
    local pd = WidgetPopDialog.new(644,_("选择头像")):addToCurrentScene()
    local body = pd:GetBody()
end
-- 玩家姓名，提供更改玩家姓名接口
function WidgetPlayerInfo:AddNameBar()
    local name_bg = display.newSprite("title_blue_430x30.png")
        :align(display.LEFT_CENTER, window.left+170, window.top-120)
        :addTo(self)
    local name_label = UIKit:ttfLabel({
        text = self.basicInfo.name,
        size = 20,
        color = 0xffedae
    }):align(display.LEFT_CENTER,10,name_bg:getContentSize().height/2)
        :addTo(name_bg)
    -- 修改名字按钮
    WidgetPushButton.new(
        {normal = "alliance_notice_icon_26x26.png", pressed = "alliance_notice_icon_26x26.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:ChangeNameDialog()
        end
    end)
        :addTo(name_bg):align(display.RIGHT_CENTER, name_bg:getContentSize().width-30, name_bg:getContentSize().height/2)
end
-- 更改玩家姓名弹出框
function WidgetPlayerInfo:ChangeNameDialog()

end
-- 经验等级进度条
function WidgetPlayerInfo:AddExpProgress()
    local basicInfo = self.basicInfo
    --进度条
    local bar = display.newSprite("progress_bar_410x40_1.png"):addTo(self)
        :pos(window.cx+74, window.top-170)
    local progressFill = display.newSprite("progress_bar_410x40_2.png")
    local pro = cc.ProgressTimer:create(progressFill)
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    pro:setMidpoint(cc.p(0,0))
    pro:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)

    display.newSprite("dragonskill_xp_51x63.png"):addTo(bar):pos(0,bar:getContentSize().height/2)
    local level_label = UIKit:ttfLabel({
        text = "LV "..basicInfo.level,
        size = 20,
        color = 0xfff3c7
    }):align(display.LEFT_CENTER,40,bar:getContentSize().height/2)
        :addTo(bar)
    local exp_config = GameDatas.PlayerInitData.playerLevel[basicInfo.level]
    local levelUpExp = exp_config.expTo - exp_config.expFrom
    pro:setPercentage(basicInfo.levelExp/levelUpExp)
    local exp_label = UIKit:ttfLabel({
        text = basicInfo.levelExp.."/"..levelUpExp,
        size = 20,
        color = 0xfff3c7
    }):align(display.RIGHT_CENTER,bar:getContentSize().width-10,bar:getContentSize().height/2)
        :addTo(bar)
end
-- power ID
function WidgetPlayerInfo:AddPowerAndID()
    -- power icon
    local power_icon = display.newSprite("allianceHome/power.png")
        :pos(window.cx-130, window.top-220):addTo(self)
        :scale(1.2)
    local power_label = UIKit:ttfLabel({
        text = _("Power")..": "..self.basicInfo.power,
        size = 22,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,window.cx-110, window.top-220)
        :addTo(self)
    local ID_label = UIKit:ttfLabel({
        text = _("ID")..": ssssf32",
        size = 22,
        color = 0x403c2f
    }):align(display.RIGHT_CENTER,window.right-40, window.top-220)
        :addTo(self)
end
-- 玩家信息
function WidgetPlayerInfo:AddPlayerInfo()
    local info_bg = WidgetUIBackGround.new({
        width = 546,
        height = 260,
        top_img = "back_ground_568X14_top.png",
        bottom_img = "back_ground_568X14_top.png",
        mid_img = "back_ground_568X1_mid.png",
        u_height = 14,
        b_height = 14,
        m_height = 1,
        b_flip = true,
    }):align(display.CENTER,0,0)
        :pos(window.cx, window.top-390)
        :addTo(self)

    -- WidgetUIBackGround.new({
    --     width = 548,
    --     height = 260,
    --     top_img = "back_ground_548x62_top.png",
    --     bottom_img = "back_ground_548x18_bottom.png",
    --     mid_img = "back_ground_548x1_mid.png",
    --     u_height = 62,
    --     b_height = 18,
    --     m_height = 1,
    --     -- b_flip = true,
    -- }):align(display.CENTER,0,0)
    --     :pos(window.cx, window.top-690)
    --     :addTo(self,2)

    self.info_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(9, 10, 526, 240),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(info_bg)
    local list = self.info_listview
    local infos = self:GetInfos()
    local flag = true
    for _,v in pairs(infos) do
        local item = list:newItem()
        local w,h = 528,48
        item:setItemSize(w, h)
        local content = display.newNode()
        content:setContentSize(cc.size(w, h))
        display.newScale9Sprite(flag and "upgrade_resources_background_2.png" or "upgrade_resources_background_3.png",264,24,cc.size(w,h))
            :addTo(content)
        UIKit:ttfLabel({
            text = v[1],
            size = 20,
            color = 0x615b44
        }):align(display.LEFT_CENTER,6, h/2)
            :addTo(content)
        UIKit:ttfLabel({
            text = v[2],
            size = 20,
            color = 0x403c2f
        }):align(display.RIGHT_CENTER,w-6, h/2)
            :addTo(content)
        item:addContent(content)
        list:addItem(item)
        flag = not flag
    end
    list:reload()
end
function WidgetPlayerInfo:GetInfos()
	local infos = {}
	local basicInfo = self.basicInfo
	local alliance = Alliance_Manager:GetMyAlliance()
	if alliance then
		local member = alliance:GetMemeberById(DataManager:getUserData()._id)
		table.insert(infos,{_("职位"),member:Title()})
		table.insert(infos,{_("联盟"),alliance:Name()})
		table.insert(infos,{_("忠诚值"),member:Loyalty()})
		table.insert(infos,{_("击杀"),member:Kill()})
		table.insert(infos,{_("胜率"),"假的"})
		table.insert(infos,{_("进攻胜利"),"假的"})
		table.insert(infos,{_("防御胜利"),"假的"})
		table.insert(infos,{_("采集木材熟练度"),"假的"})
		table.insert(infos,{_("采集石料熟练度"),"假的"})
		table.insert(infos,{_("采集铁矿熟练度"),"假的"})
		table.insert(infos,{_("采集粮食熟练度"),"假的"})
	end
	return infos
end
-- 勋章
function WidgetPlayerInfo:AddMedal()
    -- title
    local title_icon = display.newSprite("title_green_618x52.png")
        :pos(window.cx, window.top-580):addTo(self)
    UIKit:ttfLabel({
        text = _("勋章"),
        size = 24,
        color = 0xffeca5
    }):align(display.CENTER,title_icon:getContentSize().width/2, title_icon:getContentSize().height/2)
        :addTo(title_icon)

    WidgetPushButton.new(
        {normal = "i_8x17.png", pressed = "i_8x17.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
        end
    end):addTo(title_icon)
        :pos(title_icon:getContentSize().width-30, title_icon:getContentSize().height/2)
        :scale(1.2)

    -- 勋章列表
    local list_width,list_height = 574, 88
    self.medal_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(window.cx-list_width/2, window.top-705,list_width,list_height  ),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL
    }:addTo(self)
    local list = self.medal_listview
    for i=1,4 do
        local item = list:newItem()
        local w,h = 144,88
        item:setItemSize(w, h)
        local content = display.newSprite("icon_medal.png")
        item:addContent(content)
        list:addItem(item)
    end
    list:reload()
end
-- 诅咒
function WidgetPlayerInfo:AddDamnation()
    -- title
    local title_icon = display.newSprite("title_red_618x52.png")
        :pos(window.cx, window.top-740):addTo(self)
    UIKit:ttfLabel({
        text = _("诅咒"),
        size = 24,
        color = 0xffeca5
    }):align(display.CENTER,title_icon:getContentSize().width/2, title_icon:getContentSize().height/2)
        :addTo(title_icon)

    WidgetPushButton.new(
        {normal = "i_8x17.png", pressed = "i_8x17.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
        end
    end):addTo(title_icon)
        :pos(title_icon:getContentSize().width-30, title_icon:getContentSize().height/2)
        :scale(1.2)

    -- 勋章列表
    local list_width,list_height = 574, 88
    self.damnation_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100100),
        viewRect = cc.rect(window.cx-list_width/2, window.top-865,list_width,list_height  ),
        direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL
    }:addTo(self)
    local list = self.damnation_listview
    for i=1,4 do
        local item = list:newItem()
        local w,h = 144,88
        item:setItemSize(w, h)
        local content = display.newSprite("icon_damnation.png")
        item:addContent(content)
        list:addItem(item)
    end
    list:reload()
end
return WidgetPlayerInfo








