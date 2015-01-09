--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
local WidgetProgress = import("..widget.WidgetProgress")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetInfoWithTitle = import("..widget.WidgetInfoWithTitle")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local StarBar = import("..ui.StarBar")
local UILib = import(".UILib")
local WidgetInfo = import("..widget.WidgetInfo")
local GameUITownHall = UIKit:createUIClass("GameUITownHall", "GameUIUpgradeBuilding")
function GameUITownHall:ctor(city, townHall)
    GameUITownHall.super.ctor(self, city, _("市政厅"), townHall)
    self.town_hall_city = city
    self.town_hall = townHall
end
function GameUITownHall:onEnter()
    GameUITownHall.super.onEnter(self)
    self:CreateDwelling()
    self:TabButtons()
    self:UpdateDwellingCondition()
end
function GameUITownHall:onExit()
    app.timer:RemoveListener(self)
    GameUITownHall.super.onExit(self)
end

-- function GameUITownHall:OnBuildingUpgradingBegin()
-- end
-- function GameUITownHall:OnBuildingUpgradeFinished()
-- end
-- function GameUITownHall:OnBuildingUpgrading()
--     if self.impose then
--         self.impose:RefreshImpose()
--     end
-- end
-- function GameUITownHall:OnBeginImposeWithEvent(building, event)
--     -- 前置条件
--     assert(self.impose)
--     assert(self.timer == nil)
--     local admin_layer = self.admin_layer
--     self.timer = self:CreateTimerItemWithListView(admin_layer):RefreshByEvent(event, app.timer:GetServerTime())
--     admin_layer:replaceItem(self.timer, self.impose)
--     self.impose = nil
--     -- 重置列表
--     admin_layer:reload()
-- end
-- function GameUITownHall:OnImposingWithEvent(building, event, current_time)
--     assert(self.impose == nil)
--     assert(self.timer)
--     self.timer:RefreshByEvent(event, current_time)
-- end
-- function GameUITownHall:OnEndImposeWithEvent(building, event, current_time)
--     assert(self.impose == nil)
--     assert(self.timer)

--     local admin_layer = self.admin_layer
--     self.impose = self:CreateImposeItemWithListView(admin_layer):RefreshImpose()
--     admin_layer:replaceItem(self.impose, self.timer)
--     self.timer = nil

--     -- 重置列表
--     admin_layer:reload()
-- end
function GameUITownHall:UpdateDwellingCondition()
    local cur = #self.town_hall_city:GetHousesAroundFunctionBuildingByType(self.town_hall, "dwelling", 2)
    self.dwelling:GetLineByIndex(1):SetCondition(cur, 3)
    self.dwelling:GetLineByIndex(2):SetCondition(cur, 6)
end
---
function GameUITownHall:TabButtons()
    self:CreateTabButtons({
        {
            label = _("市政"),
            tag = "administration",
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.admin_layer:setVisible(false)
        elseif tag == "administration" then
            self.admin_layer:setVisible(true)
            if not self.quest_list_view then
                self:CreateAdministration()
            end
        end
    end):pos(window.cx, window.bottom + 34)
end
function GameUITownHall:CreateDwelling()
    local admin_layer = display.newLayer():addTo(self):pos(window.left+20,window.bottom_top+10)
    admin_layer:setContentSize(cc.size(layer_width,layer_height))
    local layer_width,layer_height = 600,window.betweenHeaderAndTab
    self.dwelling = self:CreateDwellingItemWithListView():addTo(admin_layer):align(display.TOP_CENTER,layer_width/2,layer_height-20)
    self.admin_layer = admin_layer
end
function GameUITownHall:CreateAdministration()
    local admin_layer = self.admin_layer

    local layer_width,layer_height = 600,window.betweenHeaderAndTab
    -- self.dwelling
    -- admin_layer:addItem(self.dwelling)

    -- admin_layer:reload()

    -- 每日任务
    UIKit:ttfLabel({
        text = _("每日任务"),
        size = 22,
        color = 0x403c2f,
    }):align(display.RIGHT_CENTER, layer_width/2+30, 600):addTo(admin_layer)
    display.newSprite("info_26x26.png"):align(display.CENTER, layer_width/2+50, 600)
        :addTo(admin_layer)


    -- 刷新倒计时
    UIKit:ttfLabel({
        text = _("刷新时间"),
        size = 22,
        color = 0x00900e,
    }):align(display.RIGHT_CENTER, layer_width/2-10, 570):addTo(admin_layer)

    -- 把上次刷新时间缓存到UI
    local dailyQuestsRefreshTime = User:DailyQuestsRefreshTime()
    self.dailyQuestsRefreshTime = dailyQuestsRefreshTime
    local refresh_time = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x00900e,
    }):align(display.LEFT_CENTER, layer_width/2+10, 570):addTo(admin_layer)
    self.refresh_time = refresh_time
    local list_view ,listnode=  UIKit:commonListView({
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0,0, layer_width, layer_height-280),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:align(display.BOTTOM_CENTER, layer_width/2, 20):addTo(admin_layer)
    self.quest_list_view = list_view

    -- 获取任务
    local daily_quest = User:GetDailyQuests()
    for _,quest in pairs(daily_quest) do
        self:CreateQuestItem(quest)
    end
    list_view:reload()

    -- 添加到全局计时器中
    app.timer:AddListener(self)
end

function GameUITownHall:CreateQuestItem(quest)
    LuaUtils:outputTable("CreateQuestItem  quest", quest)
    local quest_config = GameDatas.DailyQuests.dailyQuests[quest.index]
    local list = self.quest_list_view
    local item = list:newItem()
    local item_width,item_height = 568,218
    item:setItemSize(item_width,item_height)

    local body = WidgetUIBackGround.new({width=item_width,height=item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    local b_size = body:getContentSize()
    local title_bg = display.newSprite("title_blue_558x34.png"):addTo(body):align(display.CENTER,b_size.width/2 , b_size.height-24)
    local quest_name = UIKit:ttfLabel({
        text = quest_config.name,
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 15, title_bg:getContentSize().height/2):addTo(title_bg)
    local star_bar = StarBar.new({
        max = 5,
        bg = "Stars_bar_bg.png",
        fill = "Stars_bar_highlight.png",
        num = quest.star,
        margin = 0,
        direction = StarBar.DIRECTION_HORIZONTAL,
    }):addTo(title_bg):align(display.RIGHT_CENTER,title_bg:getContentSize().width-10, title_bg:getContentSize().height/2)

    -- 任务icon
    local icon_bg = display.newSprite("box_100x100.png"):addTo(body):pos(55,120)

    local status_label = UIKit:ttfLabel({
        text = "111",
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,icon_bg:getPositionX()+ icon_bg:getContentSize().width -20, icon_bg:getPositionY()+20):addTo(body)
    local add_star_btn = WidgetPushButton.new(
        {normal = "add_btn_up_50x50.png", pressed = "add_btn_down_50x50.png"},
        {scale9 = false}
    )
        :addTo(title_bg):align(display.RIGHT_CENTER, title_bg:getContentSize().width-10, title_bg:getContentSize().height/2)
        :onButtonClicked(function(event)

            end):scale(0.6)
    star_bar:setPositionX(title_bg:getContentSize().width-50)

    local glass_icon = display.newSprite("hourglass_39x46.png")
        :align(display.RIGHT_CENTER,icon_bg:getPositionX()+ icon_bg:getContentSize().width, icon_bg:getPositionY()-20)
        :addTo(body)
        :scale(0.8)

    local need_time_label = UIKit:ttfLabel({
        text = "222",
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,icon_bg:getPositionX()+ icon_bg:getContentSize().width-20, icon_bg:getPositionY()-20):addTo(body)

    local progress = WidgetProgress.new(UIKit:hex2c3b(0xffedae), "progress_bar_272x40_1.png", "progress_bar_272x40_2.png", {
        icon_bg = "progress_bg_head_43x43.png",
        icon = "hourglass_39x46.png",
        bar_pos = {x = 0,y = 0}
    }):addTo(body):align(display.LEFT_CENTER, icon_bg:getPositionX()+ icon_bg:getContentSize().width-25, icon_bg:getPositionY()-20)

    local control_btn = WidgetPushButton.new({normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"})
        :align(display.RIGHT_CENTER,item_width-10,108)
        :addTo(body)

    local reward_bg = display.newSprite("back_ground_548x52.png"):pos(item_width/2,34):addTo(body)


    function body:SetStar(star)
        star_bar:setNum(star)
        return self
    end
    function body:SetStatus(quest)
        local status = ""
        if User:IsQuestStarted(quest) then
            if User:IsQuestFinished(quest) then
                progress:setVisible(false)
                status = _("任务完成")
            else
                progress:setVisible(true)
                status = _("正在处理政务")
            end
            need_time_label:setVisible(false)
        else
            status = _("需要")
            need_time_label:setString(GameUtils:formatTimeStyle1(GameDatas.DailyQuests.dailyQuestStar[quest.star].needMinutes*60))
            progress:setVisible(false)
        end
        status_label:setString(status)
        return self
    end
    function body:SetStatus(status)
        status_label:setString(status)
        return self
    end
    function body:SetProgress(time_label, percent)
        progress:SetProgressInfo(time_label, percent)
        return self
    end
    function body:SetReward(quest)
        reward_bg:removeAllChildren()

        local re_label = UIKit:ttfLabel({
            text = _("奖励"),
            size = 20,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER,10,reward_bg:getContentSize().height/2):addTo(reward_bg)
        local rewards = GameDatas.DailyQuests.dailyQuests[quest.index].rewards
        local origin_x = re_label:getPositionX()+re_label:getContentSize().width + 30
        for k,v in pairs(string.split(rewards,",")) do
            local re = string.split(v,":")
            for k,v in pairs(re) do
                print("-----rewards=",k,v)
            end
            local reward_icon = display.newSprite(UILib.resource[re[2]]):addTo(reward_bg):pos(origin_x+(k-1)*180,reward_bg:getContentSize().height/2)
            local max = math.max(reward_icon:getContentSize().width,reward_icon:getContentSize().height)
            reward_icon:scale(40/max)

            UIKit:ttfLabel({
                text = re[3],
                size = 20,
                color = 0x403c2f,
            }):align(display.LEFT_CENTER,reward_icon:getPositionX()+20,reward_bg:getContentSize().height/2):addTo(reward_bg)
        end
        return self
    end
    body:SetReward(quest)
    item:addContent(body)
    list:addItem(item)
end

function GameUITownHall:CreateDwellingItemWithListView()
    local widget = WidgetInfoWithTitle.new({
        title = _("周围2格范围的住宅数量"),
        h = 146,
    }):align(display.CENTER)
    local size = widget:getContentSize()
    local lineItems = {}
    for i, v in ipairs({1,2}) do
        table.insert(lineItems, self:CreateDwellingLineItem(520,i==1):addTo(widget.info_bg, 2)
            :pos(size.width/2, 32+(i-1)*40))
    end
    -- local item = admin_layer:newItem()
    -- item:addContent(widget)
    -- item:setItemSize(size.width,156)


    function widget:GetLineByIndex(index)
        return lineItems[index]
    end
    return widget
end


function GameUITownHall:CreateDwellingLineItem(width,flag)
    local left, right = 0, width
    local node =   display.newScale9Sprite(flag and "back_ground_548x40_1.png" or "back_ground_548x40_2.png")
    node:size(524,40)
    local condition = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x615b44)
    }):addTo(node, 2):align(display.LEFT_CENTER, left + 10, 20)

    cc.ui.UILabel.new({
        text = string.format("%s%%5%s", _("增加"), _("城民增长")),
        size = 20,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0x615b44)
    }):addTo(node, 2):align(display.RIGHT_CENTER, right - 70, 20)

    local check = cc.ui.UICheckBoxButton.new({on = "yes_40x40.png", off = "no_40x40.png" })
        :addTo(node)
        :align(display.CENTER, right - 20, 20)
        :setButtonSelected(true)
    check:setTouchEnabled(false)

    function node:align()
        assert("you should not use this function for any purpose!")
    end
    function node:SetCondition(current, max)
        local str = string.format("%s %d/%d", _("达到"), current > max and max or current, max)
        if condition:getString() ~= str then
            condition:setString(str)
        end
        check:setButtonSelected(max <= current)
        return self
    end
    return node
end
-- function GameUITownHall:CreateTaxLineItem(width, param,flag)
--     local left, right = 0, width
--     local node = display.newScale9Sprite(flag and "back_ground_548x40_1.png" or "back_ground_548x40_2.png")
--     node:size(348,40)
--     cc.ui.UIImage.new(param.icon):addTo(node, 2)
--         :align(display.CENTER, left + 40, 20):scale(param.scale)
--     cc.ui.UILabel.new({
--         text = param.title,
--         size = 20,
--         font = UIKit:getFontFilePath(),
--         align = cc.ui.TEXT_ALIGN_RIGHT,
--         color = UIKit:hex2c3b(0x615b44)
--     }):addTo(node, 2):align(display.LEFT_CENTER, left + 70, 20)

--     local label = cc.ui.UILabel.new({
--         text = "增加 5% 城民增长",
--         size = 20,
--         font = UIKit:getFontFilePath(),
--         align = cc.ui.TEXT_ALIGN_RIGHT,
--         color = UIKit:hex2c3b(0x615b44)
--     }):addTo(node, 2):align(display.RIGHT_CENTER, right - 30, 20)

--     function node:align()
--         assert("you should not use this function for any purpose!")
--     end
--     function node:SetLabel(str)
--         if label:getString() ~= str then
--             label:setString(str)
--         end
--         return self
--     end
--     return node
-- end
function GameUITownHall:OnTimer(current_time)
    if self.refresh_time then
        self.refresh_time:setString(GameUtils:formatTimeStyle1(current_time-User:GetNextDailyQuestsRefreshTime()/1000))
    end
end

return GameUITownHall

















































