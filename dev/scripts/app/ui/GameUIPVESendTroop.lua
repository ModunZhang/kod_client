--
-- Author: Kenny Dai
-- Date: 2015-02-03 16:58:16
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIScrollView = import(".UIScrollView")
local Localize = import("..utils.Localize")
local UIListView = import(".UIListView")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetSlider = import("..widget.WidgetSlider")
local WidgetSelectDragon = import("..widget.WidgetSelectDragon")
local SoldierManager = import("..entity.SoldierManager")

local UILib = import(".UILib")
local window = import("..utils.window")
local normal = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special

local GameUIPVESendTroop = UIKit:createUIClass("GameUIPVESendTroop","GameUIWithCommonHeader")


local img_dir = "allianceHome/"

function GameUIPVESendTroop:ctor()
    GameUIPVESendTroop.super.ctor(self,City,_("准备进攻"))
    
    self.soldier_manager = City:GetSoldierManager()
    self.dragon_manager = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager()
    self.soldiers_table = {}

    -- 默认选中最强的并且可以出战的龙,如果都不能出战，则默认最强龙
    self.dragon = self.dragon_manager:GetDragon(self.dragon_manager:GetCanFightPowerfulDragonType()) or self.dragon_manager:GetDragon(self.dragon_manager:GetPowerfulDragonType())
end

function GameUIPVESendTroop:onEnter()
    GameUIPVESendTroop.super.onEnter(self)

    self:SelectDragonPart()
    self:SelectSoldiers()

    local function __getSoldierConfig(soldier_type,level)
        local level = level or 1
        return normal[soldier_type.."_"..level] or SPECIAL[soldier_type]
    end

    local max_btn = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
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
        end):align(display.LEFT_CENTER,window.left+50,window.top-910):addTo(self)
    local march_btn = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
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

        end):align(display.RIGHT_CENTER,window.right-50,window.top-910):addTo(self)
    --行军所需时间
    display.newSprite("upgrade_hourglass.png", window.cx, window.top-910)
        :addTo(self):scale(0.6)
    self.march_time = UIKit:ttfLabel({
        text = "20:00:00",
        size = 18,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,window.cx+20,window.top-900):addTo(self)

    -- 科技减少行军时间
    self.buff_reduce_time = UIKit:ttfLabel({
        text = "(-00:20:00)",
        size = 18,
        color = 0x068329
    }):align(display.LEFT_CENTER,window.cx+20,window.top-920):addTo(self)

    City:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)
end
function GameUIPVESendTroop:SelectDragonPart()
    if not self.dragon then return end
    local dragon = self.dragon

    local dragon_frame = display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.LEFT_CENTER, window.left+47,window.top-405)
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

    local send_troops_btn = WidgetPushButton.new({normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png"})
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
        end):align(display.CENTER,330,35):addTo(box_bg)

end
function GameUIPVESendTroop:RefreashDragon(dragon)
    self.dragon_img:setTexture(img_dir..dragon:Type()..".png")
    self.dragon_name:setString(_(dragon:Type()).."（LV "..dragon:Level().."）")
    self.dragon_vitality:setString(_("生命值")..dragon:Hp().."/"..dragon:GetMaxHP())
    self.dragon = dragon
end

function GameUIPVESendTroop:SelectDragon()
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
function GameUIPVESendTroop:SelectSoldiers()
    local list ,listnode=  UIKit:commonListView({
        viewRect = cc.rect(0, 0, 520, 376),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(self):pos(window.cx, window.top-675)
    listnode:align(display.CENTER)

    self.soldier_listview = list
    local function addListItem(soldier_type,soldier_level,max_soldier)
        if max_soldier<1 then
            return
        end
        local item = list:newItem()
        local w,h = 516,118
        item:setItemSize(w, h)
        local content = display.newSprite(img_dir.."back_ground_516x116.png")
        item.max_soldier = max_soldier
        -- progress
        local slider = WidgetSlider.new(display.LEFT_TO_RIGHT,  {bar = "slider_bg_461x24.png",
            progress = "slider_progress_445x14.png",
            button = "slider_btn_66x66.png"}, {max = item.max_soldier}):addTo(content)
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
                if text and text > item.max_soldier then
                    editbox:setText(item.max_soldier)
                end
            elseif event == "ended" then
                if text=="" or 0==text then
                    editbox:setText(0)
                end
                local edit_value = tonumber(editbox:getText())

                local usable_citizen=self.dragon:LeadCitizen()
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
            local usable_citizen=self.dragon:LeadCitizen()
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
            text = string.format("/ %d", item.max_soldier),
            size = 20,
            color = 0x403c2f
        }):addTo(content)
            :align(display.LEFT_CENTER, 400,90)

        -- 士兵头像
        -- local stars_bg = display.newSprite("soldier_head_stars_bg.png", 100,58):scale(0.8)
        --     :addTo(content)
        local soldier_type_with_star = soldier_type..(soldier_level == nil and "" or string.format("_%d", soldier_level))
        local soldier_ui_config = UILib.soldier_image[soldier_type][soldier_level]
        local soldier_head_icon = display.newSprite(soldier_ui_config):align(display.CENTER,60,58):addTo(content):scale(0.8)
        local soldier_head_bg  = display.newSprite("box_soldier_128x128.png"):addTo(soldier_head_icon):pos(soldier_head_icon:getContentSize().width/2,soldier_head_icon:getContentSize().height/2)




        -- 士兵星级，特殊兵种无星级
        -- local soldier_stars = soldier_level
        -- if soldier_stars then
        --     local gap_y = 25
        --     for i=1,5 do
        --         stars_bg:addChild(display.newSprite("soldier_stars_bg.png", 38, 15+gap_y*(i-1)))
        --         if soldier_stars>0 then
        --             stars_bg:addChild(display.newSprite("soldier_stars.png", 38, 15+gap_y*(i-1)))
        --             soldier_stars = soldier_stars-1
        --         end
        --     end
        -- end
        item:addContent(content)
        list:addItem(item)
        function item:SetMaxSoldier(max_soldier)
            self.max_soldier = max_soldier
            slider:SetMax(max_soldier)
            soldier_total_count:setString(string.format("/ %d", self.max_soldier))
        end

        function item:GetSoldierInfo()
            return soldier_type,soldier_level,math.floor(slider:getSliderValue()), self.max_soldier
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
function GameUIPVESendTroop:CreateBetweenBgAndTitle()
    GameUIPVESendTroop.super.CreateBetweenBgAndTitle(self)
    self.show = self:CreateTroopsShow()
end
function GameUIPVESendTroop:RefreashSoldierShow()
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
end

function GameUIPVESendTroop:GetSelectSoldier()
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
function GameUIPVESendTroop:CreateTroopsShow()
   
end
function GameUIPVESendTroop:OnSoliderCountChanged( soldier_manager,changed_map )
    for i,soldier_type in ipairs(changed_map) do
        for _,item in pairs(self.soldiers_table) do
            local item_type = item:GetSoldierInfo()
            if soldier_type == item_type then
                item:SetMaxSoldier(City:GetSoldierManager():GetCountBySoldierType(item_type))
            end
        end
    end
end
function GameUIPVESendTroop:onExit()
    City:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)

    GameUIPVESendTroop.super.onExit(self)
end

return GameUIPVESendTroop