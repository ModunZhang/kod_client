local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIScrollView = import(".UIScrollView")
local Localize = import("..utils.Localize")
local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetSlider = import("..widget.WidgetSlider")
local WidgetSelectDragon = import("..widget.WidgetSelectDragon")
local Corps = import(".Corps")
local UILib = import(".UILib")
local window = import("..utils.window")
local normal = GameDatas.UnitsConfig.normal
local SPECIAL = GameDatas.UnitsConfig.special

local GameUIAllianceSendTroops = UIKit:createUIClass("GameUIAllianceSendTroops","GameUIWithCommonHeader")
local soldier_arrange = {
    swordsman = {row = 4, col = 2},
    ranger = {row = 4, col = 2},
    lancer = {row = 3, col = 1},
    catapult = {row = 2, col = 1},

    horseArcher = {row = 4, col = 2},
    ballista = {row = 4, col = 2},
    skeletonWarrior = {row = 3, col = 1},
    skeletonArcher = {row = 2, col = 1},

    deathKnight = {row = 4, col = 2},
    meatWagon = {row = 4, col = 2},
    priest = {row = 3, col = 1},
    demonHunter = {row = 2, col = 1},

    paladin = {row = 4, col = 2},
    steamTank = {row = 4, col = 2},
    sentinel = {row = 4, col = 2},
    crossbowman = {row = 4, col = 2},
}
local STAR_BG = {
    "star1_118x132.png",
    "star2_118x132.png",
    "star3_118x132.png",
    "star4_118x132.png",
    "star5_118x132.png",
}
local img_dir = "allianceHome/"

function GameUIAllianceSendTroops:ctor(march_callback)
    GameUIAllianceSendTroops.super.ctor(self,City,_("准备进攻"))
    local manager = ccs.ArmatureDataManager:getInstance()
    for _, anis in pairs(UILib.soldier_animation_files) do
        for _, v in pairs(anis) do
            manager:addArmatureFileInfo(v)
        end
    end
    self.soldier_manager = City:GetSoldierManager()
    self.dragon_manager = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager()
    self.soldiers_table = {}
    self.march_callback = march_callback

    -- 默认选中最强的并且可以出战的龙,如果都不能出战，则默认最强龙
    self.dragon = self.dragon_manager:GetDragon(self.dragon_manager:GetCanFightPowerfulDragonType()) or self.dragon_manager:GetDragon(self.dragon_manager:GetPowerfulDragonType())
end

function GameUIAllianceSendTroops:onEnter()
    GameUIAllianceSendTroops.super.onEnter(self)

    self:SelectDragonPart()
    self:SelectSoldiers()

    local function __getSoldierConfig(soldier_type,level)
        local level = level or 1
        return normal[soldier_type.."_"..level] or SPECIAL[soldier_type]
    end

    local max_btn = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("最大"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                local max_soldiers_citizen = 0
                for k,item in pairs(self.soldiers_table) do
                    local soldier_type,level,_,max_num = item:GetSoldierInfo()
                    max_soldiers_citizen=max_soldiers_citizen+max_num*__getSoldierConfig(soldier_type,level).citizen
                end
                if self.soldier_manager:GetTroopPopulation()<max_soldiers_citizen then
                    -- 拥有士兵数量大于派兵数量上限时，首先选取power最高的兵种，依次到达最大派兵上限为止
                    local s_table = self.soldiers_table
                    table.sort(s_table, function(a, b)
                        local soldier_type,level = a:GetSoldierInfo()
                        local a_power = __getSoldierConfig(soldier_type,level).power
                        local soldier_type,level = b:GetSoldierInfo()
                        local b_power = __getSoldierConfig(soldier_type,level).power
                        return a_power > b_power
                    end)
                    local max_troop_num = self.soldier_manager:GetTroopPopulation()
                    for k,item in ipairs(s_table) do
                        local soldier_type,level,_,max_num = item:GetSoldierInfo()
                        local max_citizen = __getSoldierConfig(soldier_type,level).citizen*max_num
                        if max_citizen<=max_troop_num then
                            max_troop_num = max_troop_num - max_citizen
                            item:SetSoldierCount(max_num)
                        else
                            local num = math.floor(max_troop_num/__getSoldierConfig(soldier_type,level).citizen)
                            item:SetSoldierCount(num)
                            break
                        end
                    end
                    self:RefreashSoldierShow()
                else
                    for k,item in pairs(self.soldiers_table) do
                        local _,_,_,max_num = item:GetSoldierInfo()
                        item:SetSoldierCount(max_num)
                    end
                    self:RefreashSoldierShow()
                end
            end
        end):align(display.LEFT_CENTER,window.left+50,window.top-920):addTo(self)
    local march_btn = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("行军"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                assert(tolua.type(self.march_callback)=="function")
                if not self.dragon then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("您还没有龙,快去孵化一只巨龙吧"))
                        :AddToCurrentScene()
                    return
                end
                local dragonType = self.dragon:Type()
                local soldiers = self:GetSelectSoldier()
                if self.dragon:Status() ~= "free" then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("龙未处于空闲状态"))
                        :AddToCurrentScene()
                    return
                elseif self.dragon:Hp()<1 then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("选择的龙已经死亡"))
                        :AddToCurrentScene()
                    return
                elseif #soldiers == 0 then
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("请选择要派遣的部队"))
                        :AddToCurrentScene()
                    return
                end
                if self.dragon:IsHpLow() then
                    FullScreenPopDialogUI.new():SetTitle(_("行军"))
                        :SetPopMessage(_("您的龙的HP低于20%,有很大几率阵亡,确定要派出吗?"))
                        :CreateOKButton(
                            {
                                listener =  function ()
                                    self.march_callback(dragonType,soldiers)
                                    -- 确认派兵后关闭界面
                                    self:leftButtonClicked()
                                end
                            }
                        )
                        :AddToCurrentScene()
                else
                    self.march_callback(dragonType,soldiers)
                    -- 确认派兵后关闭界面
                    self:leftButtonClicked()
                end
            end

        end):align(display.RIGHT_CENTER,window.right-50,window.top-920):addTo(self)
    --行军所需时间
    display.newSprite("upgrade_hourglass.png", window.cx, window.top-920)
        :addTo(self):scale(0.6)
    self.march_time = UIKit:ttfLabel({
        text = "20:00:00",
        size = 18,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,window.cx+20,window.top-910):addTo(self)

    -- 科技减少行军时间
    self.buff_reduce_time = UIKit:ttfLabel({
        text = "(-00:20:00)",
        size = 18,
        color = 0x068329
    }):align(display.LEFT_CENTER,window.cx+20,window.top-930):addTo(self)
end
function GameUIAllianceSendTroops:SelectDragonPart()
    if not self.dragon then return end
    local dragon = self.dragon

    local dragon_frame = display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.LEFT_CENTER, window.left+47,window.top-425)
        :addTo(self)

    local dragon_bg = display.newSprite("chat_hero_background.png")
        :align(display.LEFT_CENTER, 7,dragon_frame:getContentSize().height/2)
        :addTo(dragon_frame)
    self.dragon_img = cc.ui.UIImage.new(img_dir..dragon:Type()..".png")
        :align(display.CENTER, dragon_bg:getContentSize().width/2, dragon_bg:getContentSize().height/2+5)
        :addTo(dragon_bg)
    local box_bg = display.newSprite(img_dir.."box_426X126.png")
        :align(display.LEFT_CENTER, dragon_frame:getContentSize().width, dragon_frame:getContentSize().height/2)
        :addTo(dragon_frame)
    -- 龙，等级
    self.dragon_name = UIKit:ttfLabel({
        text = _(dragon:Type()).."（LV ".. dragon:Level()..")",
        size = 22,
        color = 0x514d3e,
    }):align(display.LEFT_CENTER,20,80)
        :addTo(box_bg)
    -- 龙活力
    self.dragon_vitality = UIKit:ttfLabel({
        text = _("生命值")..dragon:Hp().."/"..dragon:GetMaxHP(),
        size = 20,
        color = 0x797154,
    }):align(display.LEFT_CENTER,20,30)
        :addTo(box_bg)

    local send_troops_btn = WidgetPushButton.new({normal = "blue_btn_up_142x39.png",pressed = "blue_btn_down_142x39.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("选择"),
            size = 22,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:SelectDragon()
            end
        end):align(display.CENTER,330,30):addTo(box_bg)

end
function GameUIAllianceSendTroops:RefreashDragon(dragon)
    self.dragon_img:setTexture(img_dir..dragon:Type()..".png")
    self.dragon_name:setString(_(dragon:Type()).."（LV "..dragon:Level().."）")
    self.dragon_vitality:setString(_("生命值")..dragon:Hp().."/"..dragon:GetMaxHP())
    self.dragon = dragon
end

function GameUIAllianceSendTroops:SelectDragon()
    WidgetSelectDragon.new(
        {
            title = _("选中出战的巨龙"),
            btns = {
                {
                    btn_label = _("确定"),
                    btn_callback = function (selectDragon)
                        self:RefreashDragon(selectDragon)
                    end,
                },
            },

        }
    ):addTo(self)
end
function GameUIAllianceSendTroops:SelectSoldiers()
    local body = display.newSprite(img_dir.."back_ground_538x396.png")
        :align(display.CENTER, window.cx, window.top-695)
        :addTo(self)
    self.soldier_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a004400),
        viewRect = cc.rect(9, 10, 520, 376),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(body)
    local list = self.soldier_listview
    local function addListItem(soldier_type,soldier_level,max_soldier)
        if max_soldier<1 then
            return
        end
        local item = list:newItem()
        local w,h = 516,118
        item:setItemSize(w, h)
        local content = display.newSprite(img_dir.."back_ground_516x116.png")

        -- progress
        local slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
            progress = "slider_progress_445x14.png",
            button = "slider_btn_66x66.png"}, {max = max_soldier}):addTo(content)
            :align(display.RIGHT_CENTER, w-5, 35)
            :scale(0.82)
        -- :setSliderValue(4000)
        -- soldier name
        local soldier_name_label = UIKit:ttfLabel({
            text = Localize.soldier_name[soldier_type],
            size = 24,
            color = 0x403c2f
        }):align(display.LEFT_CENTER,140,90):addTo(content)
        local function edit(event, editbox)
            local text = tonumber(editbox:getText()) or 0
            if event == "began" then
                if 0==text then
                    editbox:setText("")
                end
            elseif event == "changed" then
                if text and text > max_soldier then
                    editbox:setText(max_soldier)
                end
            elseif event == "ended" then
                if text=="" or 0==text then
                    editbox:setText(0)
                end
                local edit_value = tonumber(editbox:getText())

                local usable_citizen=self.soldier_manager:GetTroopPopulation()
                for k,item in pairs(self.soldiers_table) do
                    local soldier_t,soldier_l,soldier_n =item:GetSoldierInfo()
                    local soldier_config = normal[soldier_t.."_"..soldier_l] or SPECIAL[soldier_t]
                    if soldier_type~=soldier_t then
                        usable_citizen =usable_citizen-soldier_config.citizen*soldier_n
                    end
                end
                local soldier_config = normal[soldier_type.."_"..soldier_level] or SPECIAL[soldier_type]
                if soldier_config.citizen*edit_value > usable_citizen then
                    edit_value = math.floor(usable_citizen/soldier_config.citizen)
                end

                editbox:setText(edit_value)

                local slider_value = slider:getSliderValue()
                if edit_value ~= slider_value then
                    slider:setSliderValue(edit_value)
                    self:RefreashSoldierShow()
                end
            end
        end
        -- soldier current
        local editbox = cc.ui.UIInput.new({
            UIInputType = 1,
            image = "back_ground_83x32.png",
            size = cc.size(100,32),
            font = UIKit:getFontFilePath(),
            listener = edit
        })
        editbox:setMaxLength(10)
        editbox:setText(0)
        editbox:setFont(UIKit:getFontFilePath(),20)
        editbox:setFontColor(cc.c3b(0,0,0))
        editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
        editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
        editbox:align(display.CENTER, 340,90):addTo(content)


        slider:onSliderValueChanged(function(event)
            editbox:setText(math.floor(event.value))
        end)
        slider:addSliderReleaseEventListener(function(event)
            -- print(slider:getSliderValue())
            self:RefreashSoldierShow()
        end)
        slider:setDynamicMaxCallBakc(function (value)
            local usable_citizen=self.soldier_manager:GetTroopPopulation()
            for k,item in pairs(self.soldiers_table) do
                local soldier_t,soldier_l,soldier_n =item:GetSoldierInfo()
                local soldier_config = normal[soldier_t.."_"..soldier_l] or SPECIAL[soldier_t]
                if soldier_type~=soldier_t then
                    usable_citizen =usable_citizen-soldier_config.citizen*soldier_n
                end
            end
            local soldier_config = normal[soldier_type.."_"..soldier_level] or SPECIAL[soldier_type]
            if soldier_config.citizen*math.floor(value)< usable_citizen+1 then
                return math.floor(value)
            else
                return math.floor(usable_citizen/soldier_config.citizen)
            end
        end)


        local soldier_total_count = UIKit:ttfLabel({
            text = string.format("/ %d", max_soldier),
            size = 20,
            color = 0x403c2f
        }):addTo(content)
            :align(display.LEFT_CENTER, 400,90)

        -- 士兵头像
        local stars_bg = display.newSprite("soldier_head_stars_bg.png", 100,58):scale(0.8)
            :addTo(content)
        local soldier_head_bg  = display.newSprite(STAR_BG[soldier_level], 50,58):addTo(content):scale(0.8)

        local soldier_type_with_star = soldier_type..(soldier_level == nil and "" or string.format("_%d", soldier_level))
        local soldier_ui_config = UILib.soldier_image[soldier_type][soldier_level]


        local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.LEFT_BOTTOM,0,10)
        soldier_head_icon:scale(130/soldier_head_icon:getContentSize().height)
        -- soldier_head_icon:setScale(0.7)
        soldier_head_bg:addChild(soldier_head_icon)

        -- 士兵星级，特殊兵种无星级
        local soldier_stars = soldier_level
        if soldier_stars then
            local gap_y = 25
            for i=1,5 do
                stars_bg:addChild(display.newSprite("soldier_stars_bg.png", 38, 15+gap_y*(i-1)))
                if soldier_stars>0 then
                    stars_bg:addChild(display.newSprite("soldier_stars.png", 38, 15+gap_y*(i-1)))
                    soldier_stars = soldier_stars-1
                end
            end
        end
        item:addContent(content)
        list:addItem(item)

        function item:GetSoldierInfo()
            return soldier_type,soldier_level,math.floor(slider:getSliderValue()),max_soldier
        end
        function item:SetSoldierCount(count)
            editbox:setText(count)
            slider:setSliderValue(count)
        end
        return item
    end
    local sm = self.soldier_manager
    local soldiers = {}
    for soldier_type,soldier_num in pairs(sm:GetSoldierMap()) do
        if soldier_num>0 then
            table.insert(soldiers, {soldier_type = soldier_type,level = sm:GetStarBySoldierType(soldier_type), max_num = soldier_num})
        end
    end
    for k,v in pairs(soldiers) do
        table.insert(self.soldiers_table, addListItem(v.soldier_type,v.level,v.max_num))
    end
    list:reload()

end
function GameUIAllianceSendTroops:CreateBetweenBgAndTitle()
    GameUIAllianceSendTroops.super.CreateBetweenBgAndTitle(self)
    self.show = self:CreateTroopsShow()
end
function GameUIAllianceSendTroops:RefreashSoldierShow()
    local soldier_show_table = {}
    for k,item in pairs(self.soldiers_table) do
        local soldier_type,soldier_level,soldier_number =item:GetSoldierInfo()
        -- print("--soldier_type,soldier_level,soldier_number----",soldier_type,soldier_level,soldier_number)
        local soldier_config = normal[soldier_type.."_"..soldier_level] or SPECIAL[soldier_type]
        if soldier_number>0 then
            table.insert(soldier_show_table, {
                soldier_type = soldier_type,
                power = soldier_config.power*soldier_number,
                soldier_num = soldier_number,
                soldier_weight = soldier_config.load*soldier_number,
                soldier_citizen = soldier_config.citizen*soldier_number,
            })
        end
    end
    self.show:ShowOrRefreasTroops(soldier_show_table)
end

function GameUIAllianceSendTroops:GetSelectSoldier()
    local soldiers = {}
    for k,item in pairs(self.soldiers_table) do
        local soldier_type,soldier_level,soldier_number =item:GetSoldierInfo()
        if soldier_number>0 then
            table.insert(soldiers, {
                name = soldier_type,
                count = soldier_number,
            })
        end
    end
    return soldiers
end
function GameUIAllianceSendTroops:CreateTroopsShow()
    local parent = self
    local TroopShow = display.newSprite("battle_bg_grass_772x388.png")
        :align(display.BOTTOM_RIGHT, window.right-16, window.top-355)

    local scrollView = UIScrollView.new({
        viewRect = cc.rect(window.cx-304, window.top-355, 608, 388),
        bgColor = UIKit:hex2c4b(0x7a000000),
    }):addScrollNode(TroopShow)
        :setBounceable(false)
        :setDirection(UIScrollView.DIRECTION_HORIZONTAL)
        :addTo(self)
    -- 战斗力，人口，负重信息展示背景框
    local info_bg = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
        :pos(window.left+14, window.top-355)
        :addTo(self)
    info_bg:setTouchEnabled(false)
    info_bg:setContentSize(620, 45)
    local function createInfoItem(title,value)
        local info = display.newLayer()
        local value_label = UIKit:ttfLabel({
            text = value,
            size = 18,
            color = 0xffedae,
        })
        value_label:align(display.BOTTOM_CENTER,value_label:getContentSize().width/2,0)
            :addTo(info)
        UIKit:ttfLabel({
            text = title,
            size = 16,
            color = 0xbbae80,
        }):align(display.BOTTOM_CENTER,value_label:getContentSize().width/2,20)
            :addTo(info)
        info:setContentSize(value_label:getContentSize().width, 45)
        function info:SetValue(value)
            value_label:setString(value)
        end
        return info
    end




    -- line
    local line = display.newSprite(img_dir.."line_624x4.png")
        :align(display.CENTER, window.cx+2, window.top-355)
        :addTo(self)

    function TroopShow:SetPower(power)
        local power_item = createInfoItem(_("战斗力"),string.formatnumberthousands(power))
            :align(display.CENTER,20,0)
            :addTo(info_bg)
        return self
    end
    function TroopShow:SetCitizen(citizen)
        local citizen_item = createInfoItem(_("部队容量"),citizen.."/"..parent.soldier_manager:GetTroopPopulation())
        citizen_item:align(display.CENTER,310-citizen_item:getContentSize().width/2,0)
            :addTo(info_bg)
        return self
    end
    function TroopShow:SetWeight(weight)
        local weight_item = createInfoItem(_("负重"),string.formatnumberthousands(weight))
        weight_item:align(display.CENTER,620-weight_item:getContentSize().width-30,0)
            :addTo(info_bg)
        return self
    end
    function TroopShow:NewCorps(soldier,soldier_number)
        local arrange = soldier_arrange[soldier]
        local corps = Corps.new(soldier, arrange.row, arrange.col)
        local label = display.newSprite(img_dir.."back_ground_122x24.png")
            :align(display.CENTER, 0, -40)
            :addTo(corps)
        if soldier=="lancer" or soldier=="catapult" then
            label:setPositionX(20)
        end
        display.newSprite("dragon_strength_27x31.png"):pos(10,label:getContentSize().height/2)
            :addTo(label)
        UIKit:ttfLabel({
            text = soldier_number,
            size = 18,
            color = 0xffedae,
        }):align(display.CENTER,label:getContentSize().width/2,label:getContentSize().height/2)
            :addTo(label)
        return corps
    end
    function TroopShow:SetSoldiers(soldiers)
        self.soldiers = soldiers
    end
    function TroopShow:GetSoldiers()
        return self.soldiers
    end
    function TroopShow:ShowOrRefreasTroops(soldiers)
        -- 按兵种战力排序
        table.sort(soldiers, function(a, b)
            return a.power > b.power
        end)
        local isRefresh = false
        if self:GetSoldiers() then
            if #self:GetSoldiers() ~= #soldiers then
                isRefresh = true
            else
                for i,soldier in ipairs(self:GetSoldiers()) do
                    if soldier.soldier_type ~= soldiers[i].soldier_type
                        or soldier.power ~= soldiers[i].power then
                        isRefresh = true
                        break
                    end
                end
            end
        else
            isRefresh = true
        end
        -- 更新
        self:SetSoldiers(soldiers)
        if isRefresh then
            self:removeAllChildren()
            local y  = 100
            local x = 752
            local count = 0
            local pre_width -- 前一个添加的节点的宽
            local total_power , total_weight, total_citizen =0,0,0
            for index,v in pairs(soldiers) do
                local corp = self:NewCorps(v.soldier_type,v.power):addTo(self)
                corp:PlayAnimation("idle_2")
                x = x - (count ~= 0 and pre_width or corp:getCascadeBoundingBox().size.width/2) -10
                pre_width = corp:getCascadeBoundingBox().size.width
                if v.soldier_type =="lancer" then
                    pre_width = pre_width-60
                end
                corp:pos(x,y)
                count = count + 1
                total_power = total_power + v.power
                total_weight = total_weight + v.soldier_weight
                total_citizen = total_citizen + v.soldier_citizen

                -- print("soldier==",v.soldier_type,corp:getCascadeBoundingBox().size.width)
            end
            info_bg:removeAllChildren()
            self:SetPower(total_power)
            self:SetWeight(total_weight)
            self:SetCitizen(total_citizen)

        end
    end

    return TroopShow
end

function GameUIAllianceSendTroops:onExit()
    GameUIAllianceSendTroops.super.onExit(self)
end

return GameUIAllianceSendTroops
























