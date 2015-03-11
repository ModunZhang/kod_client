local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIScrollView = import(".UIScrollView")
local Localize = import("..utils.Localize")
local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetSlider = import("..widget.WidgetSlider")
local WidgetSelectDragon = import("..widget.WidgetSelectDragon")
local WidgetInput = import("..widget.WidgetInput")
local SoldierManager = import("..entity.SoldierManager")

local Corps = import(".Corps")
local UILib = import(".UILib")
local window = import("..utils.window")
local normal = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special

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

function GameUIAllianceSendTroops:GetMyAlliance()
    return Alliance_Manager:GetMyAlliance()
end

function GameUIAllianceSendTroops:GetEnemyAlliance()
    return self:GetMyAlliance():GetEnemyAlliance()
end

function GameUIAllianceSendTroops:GetMarchTime(soldier_show_table)
    local fromLocation = self:GetMyAlliance():GetSelf().location
    local target_alliance = self.targetIsMyAlliance and self:GetMyAlliance() or self:GetEnemyAlliance()
    local time = DataUtils:getPlayerSoldiersMarchTime(soldier_show_table,self:GetMyAlliance(),fromLocation,target_alliance,self.toLocation)
    local buffTime = DataUtils:getPlayerMarchTimeBuffTime(time)
    return time,buffTime
end

function GameUIAllianceSendTroops:RefreshMarchTimeAndBuff(soldier_show_table)
    local time,buffTime = self:GetMarchTime(soldier_show_table)
    self.march_time:setString(GameUtils:formatTimeStyle1(time))
    self.buff_reduce_time:setString(string.format("-(%s)",GameUtils:formatTimeStyle1(buffTime)))
end

function GameUIAllianceSendTroops:ctor(march_callback,params)
    checktable(params)
    self.isPVE = type(params.isPVE) == 'boolean' and params.isPVE or false
    self.toLocation = params.toLocation or cc.p(0,0)
    self.targetIsMyAlliance = type(params.targetIsMyAlliance) == 'boolean' and params.targetIsMyAlliance or true
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
                if self.dragon:LeadCitizen()<max_soldiers_citizen then
                    -- 拥有士兵数量大于派兵数量上限时，首先选取power最高的兵种，依次到达最大派兵上限为止
                    local s_table = self.soldiers_table
                    table.sort(s_table, function(a, b)
                        local soldier_type,level = a:GetSoldierInfo()
                        local a_power = __getSoldierConfig(soldier_type,level).power
                        local soldier_type,level = b:GetSoldierInfo()
                        local b_power = __getSoldierConfig(soldier_type,level).power
                        return a_power > b_power
                    end)
                    local max_troop_num = self.dragon:LeadCitizen()
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
    if not self.isPVE then 
        --行军所需时间
        display.newSprite("hourglass_39x46.png", window.cx, window.top-920)
            :addTo(self):scale(0.6)
        self.march_time = UIKit:ttfLabel({
            text = "00:00:00",
            size = 18,
            color = 0x403c2f
        }):align(display.LEFT_CENTER,window.cx+20,window.top-910):addTo(self)

        -- 科技减少行军时间
        self.buff_reduce_time = UIKit:ttfLabel({
            text = "-(00:00:00)",
            size = 18,
            color = 0x068329
        }):align(display.LEFT_CENTER,window.cx+20,window.top-930):addTo(self)
    end
    City:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)
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
    local list ,listnode=  UIKit:commonListView({
        viewRect = cc.rect(0, 0, 568, 366),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(self):pos(window.cx, window.top-685)
    listnode:align(display.CENTER)

    self.soldier_listview = list
    local function addListItem(name,star,max_soldier)
        if max_soldier<1 then
            return
        end
        local item = list:newItem()
        local w,h = 568,128
        item:setItemSize(w, h)
        local content = display.newSprite("back_ground_568X128.png")
        item.max_soldier = max_soldier
        -- progress
        local slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
            progress = "slider_progress_445x14.png",
            button = "slider_btn_66x66.png"}, {max = item.max_soldier}):addTo(content)
            :align(display.RIGHT_CENTER, w-5, 35)
            :scale(0.95)
        -- soldier name
        local soldier_name_label = UIKit:ttfLabel({
            text = Localize.soldier_name[name],
            size = 24,
            color = 0x403c2f
        }):align(display.LEFT_CENTER,140,90):addTo(content)

        local function getMax()
            local usable_citizen=self.dragon:LeadCitizen()

            for k,item in pairs(self.soldiers_table) do
                local soldier_t,soldier_l,soldier_n =item:GetSoldierInfo()
                local soldier_config = normal[soldier_t.."_"..soldier_l] or SPECIAL[soldier_t]
                if name~=soldier_t then
                    usable_citizen =usable_citizen-soldier_config.citizen*soldier_n
                end
            end
            local soldier_config = normal[name.."_"..star] or SPECIAL[name]
            return math.floor(usable_citizen/soldier_config.citizen)
        end

        local text_btn = WidgetPushButton.new({normal = "back_ground_83x32.png",pressed = "back_ground_83x32.png"})
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    local p = {
                        current = math.floor(slider:getSliderValue()),
                        max= math.min(getMax(),max_soldier),
                        min=0,
                        callback = function ( edit_value )
                            if edit_value ~= slider_value then
                                slider:setSliderValue(edit_value)
                                self:RefreashSoldierShow()
                            end
                        end
                    }
                    WidgetInput.new(p):addToCurrentScene()
                end
            end):align(display.CENTER,  340,90):addTo(content)
        local btn_text = UIKit:ttfLabel({
            text = 0,
            size = 22,
            color = 0x403c2f,
        }):addTo(text_btn):align(display.CENTER)

        slider:onSliderValueChanged(function(event)
            btn_text:setString(math.floor(event.value))
        end)
        slider:addSliderReleaseEventListener(function(event)
            self:RefreashSoldierShow()
        end)
        slider:setDynamicMaxCallBakc(function (value)
            local usable_citizen=self.dragon:LeadCitizen()
            for k,item in pairs(self.soldiers_table) do
                local soldier_t,soldier_l,soldier_n =item:GetSoldierInfo()
                local soldier_config = normal[soldier_t.."_"..soldier_l] or SPECIAL[soldier_t]
                if name~=soldier_t then
                    usable_citizen =usable_citizen-soldier_config.citizen*soldier_n
                end
            end
            local soldier_config = normal[name.."_"..star] or SPECIAL[name]
            if soldier_config.citizen*math.floor(value)< usable_citizen+1 then
                return math.floor(value)
            else
                return math.floor(usable_citizen/soldier_config.citizen)
            end
        end)


        local soldier_total_count = UIKit:ttfLabel({
            text = string.format("/ %d", item.max_soldier),
            size = 20,
            color = 0x403c2f
        }):addTo(content)
            :align(display.LEFT_CENTER, 400,90)

        -- 士兵头像
        local soldier_ui_config = UILib.soldier_image[name][star]
        local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.CENTER,60,64):addTo(content):scale(104/128)
        local soldier_head_bg  = display.newSprite("box_soldier_128x128.png"):addTo(soldier_head_icon):pos(soldier_head_icon:getContentSize().width/2,soldier_head_icon:getContentSize().height/2)

        item:addContent(content)
        list:addItem(item)
        function item:SetMaxSoldier(max_soldier)
            self.max_soldier = max_soldier
            slider:SetMax(max_soldier)
            soldier_total_count:setString(string.format("/ %d", self.max_soldier))
        end

        function item:GetSoldierInfo()
            return name,star,math.floor(slider:getSliderValue()), self.max_soldier
        end
        function item:SetSoldierCount(count)
            btn_text:setString(count)
            slider:setSliderValue(count)
        end
        return item
    end
    local sm = self.soldier_manager
    local soldiers = {}
    for name,soldier_num in pairs(sm:GetSoldierMap()) do
        if soldier_num>0 then
            table.insert(soldiers, {name = name,level = sm:GetStarBySoldierType(name), max_num = soldier_num})
        end
    end
    for k,v in pairs(soldiers) do
        table.insert(self.soldiers_table, addListItem(v.name,v.level,v.max_num))
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
        local soldier_config = normal[soldier_type.."_"..soldier_level] or SPECIAL[soldier_type]
        if soldier_number>0 then
            table.insert(soldier_show_table, {
                soldier_type = soldier_type,
                power = soldier_config.power*soldier_number,
                soldier_num = soldier_number,
                soldier_weight = soldier_config.load*soldier_number,
                soldier_citizen = soldier_config.citizen*soldier_number,
                soldier_march = soldier_config.march
            })
        end
    end
    self.show:ShowOrRefreasTroops(soldier_show_table)
    if not self.isPVE then
        self:RefreshMarchTimeAndBuff(soldier_show_table)
    end
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
        local citizen_item = createInfoItem(_("部队容量"),citizen.."/"..parent.dragon:LeadCitizen())
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
function GameUIAllianceSendTroops:OnSoliderCountChanged( soldier_manager,changed_map )
    for i,soldier_type in ipairs(changed_map) do
        for _,item in pairs(self.soldiers_table) do
            local item_type = item:GetSoldierInfo()
            if soldier_type == item_type then
                item:SetMaxSoldier(City:GetSoldierManager():GetCountBySoldierType(item_type))
            end
        end
    end
end
function GameUIAllianceSendTroops:onExit()
    City:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)

    GameUIAllianceSendTroops.super.onExit(self)
end

return GameUIAllianceSendTroops
























