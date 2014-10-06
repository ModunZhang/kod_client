local WidgetWithBlueTitle = import("..widget.WidgetWithBlueTitle")
local UIListView = import('.UIListView')
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetSoldierBox = import("..widget.WidgetSoldierBox")
local WidgetTimerProgress = import("..widget.WidgetTimerProgress")
local WidgetTreatSoldier = import("..widget.WidgetTreatSoldier")
local SoldierManager = import("..entity.SoldierManager")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local HospitalUpgradeBuilding = import("..entity.HospitalUpgradeBuilding")

local window = import("..utils.window")
local GameUIHospital = UIKit:createUIClass('GameUIHospital',"GameUIUpgradeBuilding")
GameUIHospital.SOLDIERS_NAME = {
    [1] = "swordsman",
    [2] = "archer",
    [3] = "lancer",
    [4] = "catapult",
    [5] = "sentinel",
    [6] = "crossbowman",
    [7] = "horseArcher",
    [8] = "ballista",
-- [9] = "skeletonWarrior",
-- [10] = "skeletonArcher",
-- [11] = "deathKnight",
-- [12] = "meatWagon",
-- [13] = "priest",
-- [14] = "demonHunter",
-- [15] = "paladin",
-- [16] = "steamTank",
}

GameUIHospital.HEAL_NEED_RESOURCE_TYPE ={
    IRON = 1,
    STONE = 2,
    WOOD = 3,
    FOOD = 4,
}

local IRON = GameUIHospital.HEAL_NEED_RESOURCE_TYPE.IRON
local STONE = GameUIHospital.HEAL_NEED_RESOURCE_TYPE.STONE
local WOOD = GameUIHospital.HEAL_NEED_RESOURCE_TYPE.WOOD
local FOOD = GameUIHospital.HEAL_NEED_RESOURCE_TYPE.FOOD

function GameUIHospital:ctor(city,building)
    GameUIHospital.super.ctor(self,city,_("医院"),building)
    self.heal_resource_item_table = {}
    self.treat_soldier_boxes_table = {}
end

function GameUIHospital:CreateBetweenBgAndTitle()
    GameUIHospital.super.CreateBetweenBgAndTitle(self)

    -- 加入治疗heal_layer
    self.heal_layer = display.newLayer()
    self:addChild(self.heal_layer)
end

function GameUIHospital:onEnter()
    GameUIHospital.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("治疗"),
            tag = "heal",
        },
    },function(tag)
        if tag == 'heal' then
            self.heal_layer:setVisible(true)
        else
            self.heal_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)

    -- 创建伤兵数量占最大伤兵数量比例条
    self:CreateCasualtyRateBar()
    -- 创建伤兵列表
    self:CresteCasualtySoldiersListView()
    -- 创建治疗所有伤病栏UI
    self:CreateHealAllSoldierItem()
    -- 创建加速治疗框
    self:CreateSpeedUpHeal()

    self.city:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.TREAT_SOLDIER_CHANGED)
    self.building:AddHospitalListener(self)
end

function GameUIHospital:onExit()
    self.building:RemoveHospitalListener(self)
    self.city:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.TREAT_SOLDIER_CHANGED)
    GameUIHospital.super.onExit(self)
end

function GameUIHospital:OnBeginTreat(hospital, event)
    self:OnTreating(hospital, event, app.timer:GetServerTime())
end

function GameUIHospital:OnTreating(hospital, event, current_time)
    local treat_count = 0
    local soldiers = event:GetTreatInfo()
    for k,v in pairs(soldiers) do
        treat_count = treat_count + v.count
    end
    self:SetTreatingSoldierNum(treat_count)
    self.timer:SetProgressInfo(GameUtils:formatTimeStyle1(event:LeftTime(current_time)),event:Percent(current_time))
    self.treate_all_soldiers_item:hide()
    self.timer:show()
end

function GameUIHospital:OnEndTreat(hospital, event, soldiers, current_time)
    self.treate_all_soldiers_item:show()
    self.timer:hide()
end

function GameUIHospital:CreateHealAllSoldierItem()
    self.treate_all_soldiers_item = WidgetWithBlueTitle.new(266, _("治疗所有伤兵")):addTo(self.heal_layer)
        :pos(window.cx,window.top-750)
    local bg_size = self.treate_all_soldiers_item:getContentSize()
    -- 治疗伤病需要使用的4种资源和数量（矿，石头，木材，食物）
    local function createResourceItem(resource_icon,num)
        local item = display.newSprite("back_ground_116x30.png"):align(display.LEFT_CENTER)
        local item_size = item:getContentSize()
        local icon = display.newSprite(resource_icon):addTo(item):align(display.LEFT_BOTTOM)
        icon:setScale(32/icon:getContentSize().width)
        item.need_value = cc.ui.UILabel.new(
            {
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = "X "..GameUtils:formatNumber(num),
                font = UIKit:getFontFilePath(),
                size = 20,
                color = UIKit:hex2c3b(0x403c2f)
            }):addTo(item):align(display.LEFT_CENTER, 40, item_size.height/2)
        return item
    end
    local item_width = 116
    local gap_x = (bg_size.width - 4*item_width)/5
    local soldiers = {}
    for k,v in pairs(self.city:GetSoldierManager():GetTreatSoldierMap()) do
        table.insert(soldiers,{name=k,count=v})
    end
    local total_iron,total_stone,total_wood,total_food = self.city:GetSoldierManager():GetTreatResource(soldiers)
    local resource_icons = {
        [IRON] = {total_iron,"iron_icon.png"},
        [STONE]  = {total_stone,"stone_icon.png"},
        [WOOD]  = {total_wood,"wood_icon.png"},
        [FOOD]  = {total_food,"food_icon.png"},
    }
    for k,v in pairs(resource_icons) do
        self.heal_resource_item_table[k] = createResourceItem(v[2],v[1]):addTo(self.treate_all_soldiers_item):pos(gap_x*k+item_width*(k-1), 180)
    end

    -- 立即治疗和治疗按钮
    self.treat_all_now_button = WidgetPushButton.new({normal = "upgrade_green_button_normal.png",pressed = "upgrade_green_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("立即治疗"), size = 24, color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:TreatNowListener()
            end
        end):align(display.CENTER, bg_size.width/2-150, 110):addTo(self.treate_all_soldiers_item)
    self.treat_all_button = WidgetPushButton.new({normal = "upgrade_yellow_button_normal.png",pressed = "upgrade_yellow_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("治疗"), size = 24, color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:TreatListener()
            end
        end):align(display.CENTER, bg_size.width/2+180, 110):addTo(self.treate_all_soldiers_item)
    -- 立即治疗所需宝石
    display.newSprite("Topaz-icon.png", bg_size.width/2 - 260, 50):addTo(self.treate_all_soldiers_item):setScale(0.5)
    self.heal_now_need_gems_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,bg_size.width/2 - 240,50):addTo(self.treate_all_soldiers_item)
    self:SetTreatAllSoldiersNowNeedGems()
    --治疗所需时间
    display.newSprite("upgrade_hourglass.png", bg_size.width/2+100, 50):addTo(self.treate_all_soldiers_item):setScale(0.6)
    self.heal_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,bg_size.width/2+125,60):addTo(self.treate_all_soldiers_item)
    self:SetTreatAllSoldiersTime()

    -- 科技减少治疗时间
    self.buff_reduce_time = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "(-00:20:00)",
        font = UIKit:getFontFilePath(),
        size = 18,
        color = UIKit:hex2c3b(0x068329)
    }):align(display.LEFT_CENTER,bg_size.width/2+120,40):addTo(self.treate_all_soldiers_item)
end

function GameUIHospital:TreatListener()
    local soldiers = {}
    local treat_soldier_map = self.city:GetSoldierManager():GetTreatSoldierMap()
    for k,v in pairs(treat_soldier_map) do
        if v>0 then
            table.insert(soldiers,{name=k,count=v})
        end
    end
    local treat_fun = function ()
        NetManager:treatSoldiers(soldiers, NOT_HANDLE)
    end
    local isAbleToTreat =self.building:IsAbleToTreat(soldiers)
    if #soldiers<1 then
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("没有伤兵需要治疗")):AddToCurrentScene()
    elseif City:GetResourceManager():GetGemResource():GetValue()< self.building:GetTreatGems(soldiers) then
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("没有足够的宝石补充资源")):AddToCurrentScene()
    elseif isAbleToTreat==HospitalUpgradeBuilding.CAN_NOT_TREAT.TREATING_AND_LACK_RESOURCE then
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("正在治疗，资源不足"))
            :CreateOKButton(treat_fun)
            :CreateNeeds("Topaz-icon.png",self.building:GetTreatGems(soldiers)):AddToCurrentScene()
    elseif isAbleToTreat==HospitalUpgradeBuilding.CAN_NOT_TREAT.LACK_RESOURCE then
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("资源不足，是否花费宝石补足"))
            :CreateOKButton(treat_fun)
            :CreateNeeds("Topaz-icon.png",self.building:GetTreatGems(soldiers)):AddToCurrentScene()
    elseif isAbleToTreat==HospitalUpgradeBuilding.CAN_NOT_TREAT.TREATING then
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("正在治疗，是否花费魔法石立即完成"))
            :CreateOKButton(treat_fun)
            :CreateNeeds("Topaz-icon.png",self.building:GetTreatGems(soldiers)):AddToCurrentScene()
    else
        treat_fun()
    end
end
function GameUIHospital:TreatNowListener()
    local soldiers = {}
    local treat_soldier_map = self.city:GetSoldierManager():GetTreatSoldierMap()
    for k,v in pairs(treat_soldier_map) do
        if v>0 then
            table.insert(soldiers,{name=k,count=v})
        end
    end
    local treat_fun = function ()
        NetManager:instantTreatSoldiers(soldiers, NOT_HANDLE)
    end
    if #soldiers<1 then
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("没有伤兵需要治疗")):AddToCurrentScene()
    elseif self.treat_all_now_need_gems>City:GetResourceManager():GetGemResource():GetValue() then
        local dialog = FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("宝石补足")):AddToCurrentScene()
    else
        treat_fun()
    end
end
function GameUIHospital:SetTreatAllSoldiersNeedResources(params)
    for k,v in pairs(GameUIHospital.HEAL_NEED_RESOURCE_TYPE) do
        -- 有对应资源需求
        if params[v] then
            -- 得到对应资源框
            self.heal_resource_item_table[v].need_value:setString("X "..params[v])
        end
    end
end

-- 设置立即治疗所有伤兵需要魔法石数量
function GameUIHospital:SetTreatAllSoldiersNowNeedGems()
    local total_treat_time = self.city:GetSoldierManager():GetTreatAllTime()
    local soldiers = {}
    for k,v in pairs(self.city:GetSoldierManager():GetTreatSoldierMap()) do
        table.insert(soldiers,{name=k,count=v})
    end
    local total_iron,total_stone,total_wood,total_food = self.city:GetSoldierManager():GetTreatResource(soldiers)
    local bur_resource_gems = DataUtils:buyResource({wood=total_wood,
        stone=total_stone,
        iron=total_iron,
        food=total_food},{})
    local buy_time = DataUtils:getGemByTimeInterval(total_treat_time)
    self.treat_all_now_need_gems = buy_time+bur_resource_gems
    self.heal_now_need_gems_label:setString(""..self.treat_all_now_need_gems)
end
-- 设置普通治疗需要时间
function GameUIHospital:SetTreatAllSoldiersTime()
    self.heal_time:setString(GameUtils:formatTimeStyle1(self.city:GetSoldierManager():GetTreatAllTime()))
end
-- 检查普通治疗需要资源
-- function GameUIHospital:IsAbleToTreat()
--     local total_iron,total_stone,total_wood,total_food = self.city:GetSoldierManager():GetTreatResource()
--     if self.city:GetResourceManager():GetWoodResource()<total_wood
--         or self.city:GetResourceManager():GetFoodResource()<total_food
--         or self.city:GetResourceManager():GetIronResource()<total_iron
--         or self.city:GetResourceManager():GetStoneResource()<total_stone
--     then
--         return false
--     end
--     return true
-- end

function GameUIHospital:CreateCasualtyRateBar()
    local bar = display.newSprite("progress_bg_535x35.png"):addTo(self.heal_layer):pos(window.cx+10, window.top-120)
    local progressFill = display.newSprite("progress_bar_532x33.png")
    self.heal_layer.ProgressTimer = cc.ProgressTimer:create(progressFill)
    local pro = self.heal_layer.ProgressTimer
    pro:setType(display.PROGRESS_TIMER_BAR)
    pro:setBarChangeRate(cc.p(1,0))
    pro:setMidpoint(cc.p(0,0))
    pro:align(display.LEFT_BOTTOM, 0, 0):addTo(bar)
    -- pro:setPercentage(0/self.building:GetMaxCasualty())
    self:SetProgressCasualtyRate()
    self.heal_layer.casualty_rate_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        -- text = "",
        font = UIKit:getFontFilePath(),
        size = 18,
        align = ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xfff3c7),
    }):addTo(bar)
    self.heal_layer.casualty_rate_label:setAnchorPoint(cc.p(0,0.5))
    self.heal_layer.casualty_rate_label:pos(self.heal_layer.casualty_rate_label:getContentSize().width/2+30, bar:getContentSize().height/2)
    self:SetProgressCasualtyRateLabel()

    -- 进度条头图标
    display.newSprite("progress_bg_head_43x43.png", 0, 0):addTo(bar):pos(0, 16)
    display.newSprite("progress_head_44x42.png", 0, 0):addTo(bar):pos(0, 16)
end

-- 设置伤兵比例条
function GameUIHospital:SetProgressCasualtyRate()
    self.heal_layer.ProgressTimer:setPercentage(self.city:GetSoldierManager():GetTotalTreatSoldierCount()/self.building:GetMaxCasualty())
end
-- 设置伤兵比例条文本框
function GameUIHospital:SetProgressCasualtyRateLabel()
    self.heal_layer.casualty_rate_label:setString(self.city:GetSoldierManager():GetTotalTreatSoldierCount().."/"..self.building:GetMaxCasualty())
end

function GameUIHospital:CresteCasualtySoldiersListView()
    self.soldiers_listview = UIListView.new{
        -- bgColor = cc.c4b(200, 200, 0, 170),
        bgScale9 = true,
        viewRect = cc.rect(window.cx-274, window.top-610, 547, 465),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self.heal_layer)
    self:CreateItemWithListView(self.soldiers_listview)
end

function GameUIHospital:CreateItemWithListView(list_view)
    local rect = list_view:getViewRect()
    local origin_x = - rect.width / 2
    local unit_width = 130
    local gap_x = (547 - unit_width * 4) / 3
    local row_item = display.newNode()
    local treat_soldier_map = City:GetSoldierManager():GetTreatSoldierMap()
    local row_count = -1
    for i,soldier_name in pairs(GameUIHospital.SOLDIERS_NAME) do
        local soldier_number = treat_soldier_map[soldier_name] or 0
        row_count = row_count + 1
        local soldier = WidgetSoldierBox.new("",function ()
            local widget = WidgetTreatSoldier.new(soldier_name,
                1,
                soldier_number)
                :addTo(self)
                :align(display.CENTER, window.cx, 500 / 2)
                :OnBlankClicked(function(widget)
                    City:GetResourceManager():RemoveObserver(widget)
                    widget:removeFromParentAndCleanup(true)
                end)
                :OnNormalButtonClicked(function(widget)
                    City:GetResourceManager():RemoveObserver(widget)
                    widget:removeFromParentAndCleanup(true)
                end)
                :OnInstantButtonClicked(function(widget)
                    City:GetResourceManager():RemoveObserver(widget)
                    widget:removeFromParentAndCleanup(true)
                end)
            City:GetResourceManager():AddObserver(widget)
            City:GetResourceManager():OnResourceChanged()
        end):addTo(row_item)
            :alignByPoint(cc.p(0.5,0.4), origin_x + (unit_width + gap_x) * row_count + unit_width / 2, 0)
            :SetNumber(soldier_number)
        soldier:SetSoldier(soldier_name,1)
        self.treat_soldier_boxes_table[soldier_name] = soldier
        if row_count>2 then
            local item = list_view:newItem()
            item:addContent(row_item)
            item:setItemSize(547, 170)
            list_view:addItem(item)
            row_count=-1
            row_item = display.newNode()
        end
    end
    list_view:reload()
end

function GameUIHospital:CreateSpeedUpHeal()
    self.timer = WidgetTimerProgress.new(549,108):addTo(self.heal_layer)
        :align(display.CENTER_BOTTOM, window.cx, window.bottom + 100)
        :hide()
        :OnButtonClicked(function(event)
            print("加速伤兵治疗速度")
        end)
end
--设置正在治疗的伤兵数量label
function GameUIHospital:SetTreatingSoldierNum( treat_soldier_num )
    self.timer:SetDescribe(string.format(_("正在治愈%d人口的伤兵"),treat_soldier_num))
end

function GameUIHospital:OnTreatSoliderCountChanged(soldier_manager, treat_soldier_changed)
    for k,soldier_type in pairs(treat_soldier_changed) do
        local changed_treat_soldier_num = soldier_manager:GetTreatCountBySoldierType(soldier_type)
        self.treat_soldier_boxes_table[soldier_type]:SetNumber(changed_treat_soldier_num)
        self.treat_soldier_boxes_table[soldier_type]:SetButtonListener(function ()
            local widget = WidgetTreatSoldier.new(soldier_type,
                1,
                changed_treat_soldier_num)
                :addTo(self)
                :align(display.CENTER, window.cx, 500 / 2)
                :OnBlankClicked(function(widget)
                    City:GetResourceManager():RemoveObserver(widget)
                    widget:removeFromParentAndCleanup(true)
                end)
                :OnNormalButtonClicked(function(widget)
                    City:GetResourceManager():RemoveObserver(widget)
                    widget:removeFromParentAndCleanup(true)
                end)
                :OnInstantButtonClicked(function(widget)
                    City:GetResourceManager():RemoveObserver(widget)
                    widget:removeFromParentAndCleanup(true)
                end)
            City:GetResourceManager():AddObserver(widget)
            City:GetResourceManager():OnResourceChanged()
        end)
        local soldiers = {}
        for k,v in pairs(self.city:GetSoldierManager():GetTreatSoldierMap()) do
            table.insert(soldiers,{name=k,count=v})
        end
        local total_iron,total_stone,total_wood,total_food = soldier_manager:GetTreatResource(soldiers)
        self:SetTreatAllSoldiersNeedResources({
            [IRON] = total_iron,
            [STONE]  = total_stone,
            [WOOD]  = total_wood,
            [FOOD]  = total_food,
        })
        self:SetTreatAllSoldiersNowNeedGems()
        self:SetTreatAllSoldiersTime()
    end
    self:SetProgressCasualtyRateLabel()
    self.treat_all_now_button:removeAllEventListeners()
    self.treat_all_button:removeAllEventListeners()
    self.treat_all_now_button:onButtonClicked(function (event)
        if event.name == "CLICKED_EVENT" then
            self:TreatNowListener()
        end
    end )
    self.treat_all_button:onButtonClicked(function (event)
        if event.name == "CLICKED_EVENT" then
            self:TreatListener()
        end
    end )
end

return GameUIHospital





























