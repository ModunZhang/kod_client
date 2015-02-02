--
-- Author: Kenny Dai
-- Date: 2015-01-31 10:08:11
--

local WidgetPushButton = import(".WidgetPushButton")
local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetPopDialog = import(".WidgetPopDialog")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local Enum = import("..utils.Enum")
local window = import("..utils.window")
local Localize = import("..utils.Localize")
local Item = import("..entity.Item")

local WidgetUseItems = class("WidgetUseItems")
WidgetUseItems.USE_TYPE = Enum("CHANGE_PLAYER_NAME",
    "CHANGE_CITY_NAME",
    "HERO_BLOOD",
    "STAMINA",
    "DRAGON_EXP",
    "DRAGON_HP",
    "CHEST",
    "VIP_ACTIVE",
    "BUFF",
    "RESOURCE"
)
local ITEMS_TYPE = {
    "changePlayerName",
    "changeCityName",
    "heroBlood",
    "stamina",
    "dragonExp",
    "dragonHp",
    "chest",
    "vipActive",
    "buff",
    "resource",

}

function WidgetUseItems:ctor(params)
    local item_type = ITEMS_TYPE[params.item_type] or string.split(params.item:Name(), "_")[1]
    local item = params.item or self:GetItemByType(item_type,params)
    if item_type == "changePlayerName"
        or item_type == "changeCityName"
    then
        self:OpenChangePlayerOrCityName(item)
    elseif item_type == "heroBlood" then
        self:OpenHeroBloodDialog(item)
    elseif item_type == "stamina" then
        self:OpenStrengthDialog(item)
    elseif item_type == "dragonExp"
        or item_type == "dragonHp"
    then
        if params.dragon then
            self:OpenOneDragonItemDialog(item,dragon)
        else
            self:OpenIncreaseDragonExpOrHp(item)
        end
    elseif item_type == "chest" then
        self:OpenChestDialog(item)
    elseif item_type == "vipActive" then
        self:OpenVipActive(item)
    elseif item_type == "buff" or item:Category() == Item.CATEGORY.BUFF then
        self:OpenBuffDialog(item)
    elseif item_type == "resource" or item:Category() == Item.CATEGORY.RESOURCE then
        self:OpenResourceDialog(item)
    else
        self:OpenNormalDialog(params.item)
    end
end
function WidgetUseItems:GetItemByType(item_type,params)
    local im = ItemManager
    local item
    if item_type == "changePlayerName"
        or item_type == "changeCityName"
    then
        item = im:GetItemByName(item_type)
    elseif item_type == "heroBlood" then
        item = im:GetItemByName(item_type.."_1")
    elseif item_type == "stamina" then
        item = im:GetItemByName(item_type.."_1")
    elseif item_type == "dragonExp"
        or item_type == "dragonHp"
    then
        item = im:GetItemByName(item_type.."_1")
    elseif item_type == "chest" then
        item = im:GetItemByName(item_type.."_1")
    elseif item_type == "vipActive" then
        item = im:GetItemByName(item_type.."_1")
    elseif item_type == "buff" then
        item = im:GetItemByName(params.item_name)
    elseif item_type == "resource" then
        item = im:GetItemByName(params.item_name)
    end
    return item
end
function WidgetUseItems:OpenChangePlayerOrCityName(item)
    local title , eidtbox_holder, request_key
    if item:Name()== "changePlayerName" then
        title=_("更改玩家名称")
        eidtbox_holder=_("输入新的玩家名称")
        request_key= "playerName"
    else
        title=_("更改城市名称")
        eidtbox_holder=_("输入新的城市名称")
        request_key= "cityName"
    end
    local dialog = WidgetPopDialog.new(264,title,window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()
    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(576,48),
        font = UIKit:getFontFilePath(),
    })
    editbox:setPlaceHolder(eidtbox_holder)
    editbox:setMaxLength(14)
    editbox:setFont(UIKit:getFontFilePath(),22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.LEFT_TOP,16, size.height-30)
    editbox:addTo(body)

    self:CreateItemBox(item,function ()
        local newName = string.trim(editbox:getText())
        if string.len(newName) == 0 then
            FullScreenPopDialogUI.new():SetTitle(_("提示"))
                :SetPopMessage(_("请输入新的名称"))
                :CreateOKButton(
                    {
                        listener = function()end
                    })
                :AddToCurrentScene()
        else
            return true
        end
    end,
    function ()
        local item_name = item:Name()
        NetManager:getUseItemPromise(item_name,{[item_name] = {
            [request_key] = string.trim(editbox:getText())
        }}):next(function ()
            dialog:leftButtonClicked()
        end)
    end
    ):addTo(body):align(display.CENTER,size.width/2,90)
end
function WidgetUseItems:OpenBuffDialog( item )
    local same_items = ItemManager:GetSameTypeItems(item)
    local dialog = WidgetPopDialog.new(#same_items * 138 + 100,_("激活增益道具"),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()

    -- 是否激活buff
    local item_event = ItemManager:GetItemEventByType( string.split(item:Name(),"_")[1] )
    local buff_status_label = UIKit:ttfLabel({
        size = 22,
        color = item_event and 0x007c23 or 0x403c2f,
    }):addTo(body):align(display.CENTER,size.width/2, size.height-50)
    if item_event then
        buff_status_label:setString(_("已激活,剩余时间:")..GameUtils:formatTimeStyle1(item_event:GetTime()))
    else
        buff_status_label:setString(_("未激活"))
    end

    for i,v in ipairs(same_items) do
        self:CreateItemBox(
            v,
            function ()
                return true
            end,
            function ()
                local item_name = v:Name()
                NetManager:getUseItemPromise(item_name,{}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        ):addTo(body):align(display.CENTER,size.width/2,size.height- 150 - (i-1)*138)
    end
    function dialog:OnItemEventTimer( item_event_new )
        local item_event = ItemManager:GetItemEventByType( string.split(item:Name(),"_")[1] )
        if item_event then
            local time = item_event_new:GetTime()
            if time >0 then
                buff_status_label:setString(_("已激活,剩余时间:")..GameUtils:formatTimeStyle1(time))
                buff_status_label:setColor(UIKit:hex2c4b(0x007c23))
            else
                buff_status_label:setString(_("未激活"))
                buff_status_label:setColor(UIKit:hex2c4b(0x403c2f))
            end
        else
            if buff_status_label:getString() ~= _("未激活") then
                buff_status_label:setString(_("未激活"))
                buff_status_label:setColor(UIKit:hex2c4b(0x403c2f))
            end
        end
    end
    ItemManager:AddListenOnType(dialog,ItemManager.LISTEN_TYPE.OnItemEventTimer)
    dialog:addCloseCleanFunc(function ()
        ItemManager:RemoveListenerOnType(dialog,ItemManager.LISTEN_TYPE.OnItemEventTimer)
    end)
end
function WidgetUseItems:OpenResourceDialog( item )
    local same_items = ItemManager:GetSameTypeItems(item)
    local dialog = WidgetPopDialog.new(4 * 138 +40,_("增益道具"),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()

    local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0, 0,570,4 * 138),
    },false)
    list_node:addTo(body):align(display.BOTTOM_CENTER, size.width/2,20)

    for i,v in ipairs(same_items) do
        local list_item = list:newItem()
        list_item:setItemSize(570,136)
        list_item:addContent(self:CreateItemBox(
            v,
            function ()
                return true
            end,
            function ()
                local item_name = v:Name()
                NetManager:getUseItemPromise(item_name,{}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        )
        )
        list:addItem(list_item)
    end
    list:reload()
end
function WidgetUseItems:OpenHeroBloodDialog( item )
    local same_items = ItemManager:GetSameTypeItems(item)
    local dialog = WidgetPopDialog.new(#same_items * 138 +110,_("英雄之血"),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()
    local blood_bg = display.newScale9Sprite("back_ground_398x97.png",size.width/2,size.height-50,cc.size(556,58),cc.rect(10,10,378,77))
        :addTo(body)
    -- local blood_icon = display.newSprite("buff_tool.png"):addTo(blood_bg):align(display.CENTER, 40, blood_bg:getContentSize().height/2):scale(0.2)
    UIKit:ttfLabel({
        text = _("英雄之血"),
        size = 22,
        color = 0x797154,
    }):align(display.LEFT_CENTER,80,blood_bg:getContentSize().height/2)
        :addTo(blood_bg)
    UIKit:ttfLabel({
        text = City:GetResourceManager():GetBloodResource():GetValue(),
        size = 22,
        color = 0x28251d,
    }):align(display.RIGHT_CENTER,blood_bg:getContentSize().width-40,blood_bg:getContentSize().height/2)
        :addTo(blood_bg)
    for i,v in ipairs(same_items) do
        self:CreateItemBox(
            v,
            function ()
                return true
            end,
            function ()
                local item_name = v:Name()
                NetManager:getUseItemPromise(item_name,{}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        ):addTo(body):align(display.CENTER,size.width/2,size.height - 160 - (i-1)*138)
    end
end
function WidgetUseItems:OpenOneDragonItemDialog( item ,dragon)
    local same_items = ItemManager:GetSameTypeItems(item)
    local increase_type = string.split(item:Name(),"_")[1]
    local dialog = WidgetPopDialog.new(192 + dragon_num*136,increase_type == "dragonHp" and _("增加龙的生命值") or _("增加龙的经验"),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()
    local blood_bg = display.newScale9Sprite("back_ground_398x97.png",size.width/2,size.height-50,cc.size(556,58),cc.rect(10,10,378,77))
        :addTo(body)
    -- local blood_icon = display.newSprite("buff_tool.png"):addTo(blood_bg):align(display.CENTER, 40, blood_bg:getContentSize().height/2):scale(0.2)
    UIKit:ttfLabel({
        text = increase_type == "dragonHp" and _("生命值") or _("经验"),
        size = 22,
        color = 0x797154,
    }):align(display.LEFT_CENTER,80,blood_bg:getContentSize().height/2)
        :addTo(blood_bg)
    UIKit:ttfLabel({
        text = increase_type == "dragonHp" and dragon:Hp() or dragon:Exp(),
        size = 22,
        color = 0x28251d,
    }):align(display.RIGHT_CENTER,blood_bg:getContentSize().width-40,blood_bg:getContentSize().height/2)
        :addTo(blood_bg)
    for i,v in ipairs(same_items) do
        self:CreateItemBox(
            v,
            function ()
                return true
            end,
            function ()
                local item_name = item:Name()
                NetManager:getUseItemPromise(item_name,{[item_name] = {
                    dragonType = dragon:Type()
                }}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        ):addTo(body):align(display.CENTER,size.width/2,size.height - 160 - (i-1)*138)
    end
end
function WidgetUseItems:OpenStrengthDialog( item )
    local same_items = ItemManager:GetSameTypeItems(item)
    local dialog = WidgetPopDialog.new(#same_items * 138 +110,_("探索体力值"),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()
    local blood_bg = display.newScale9Sprite("back_ground_398x97.png",size.width/2,size.height-50,cc.size(556,58),cc.rect(10,10,378,77))
        :addTo(body)
    local blood_icon = display.newSprite("buff_tool.png"):addTo(blood_bg):align(display.CENTER, 40, blood_bg:getContentSize().height/2):scale(0.2)
    UIKit:ttfLabel({
        text = _("探索体力值"),
        size = 22,
        color = 0x797154,
    }):align(display.LEFT_CENTER,80,blood_bg:getContentSize().height/2)
        :addTo(blood_bg)
    UIKit:ttfLabel({
        text = User:GetStrengthResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()),
        size = 22,
        color = 0x28251d,
    }):align(display.RIGHT_CENTER,blood_bg:getContentSize().width-40,blood_bg:getContentSize().height/2)
        :addTo(blood_bg)
    for i,v in ipairs(same_items) do
        self:CreateItemBox(
            v,
            function ()
                return true
            end,
            function ()
                local item_name = v:Name()
                NetManager:getUseItemPromise(item_name,{}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        ):addTo(body):align(display.CENTER,size.width/2,size.height - 160 - (i-1)*138)
    end
end
function WidgetUseItems:OpenIncreaseDragonExpOrHp( item )
    local increase_type = string.split(item:Name(),"_")[1]

    local dragon_manager = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager()
    local dragons = dragon_manager:GetDragonsSortWithPowerful()
    local dragon_num = LuaUtils:table_size(dragons)
    if dragon_num==0 then
        return
    end
    local checkbox_image = {
        off = "checkbox_unselected.png",
        off_pressed = "checkbox_unselected.png",
        off_disabled = "checkbox_unselected.png",
        on = "checkbox_selectd.png",
        on_pressed = "checkbox_selectd.png",
        on_disabled = "checkbox_selectd.png",

    }
    local function createDragonFrame(dragon)
        local dragon_frame = display.newSprite("alliance_item_flag_box_126X126.png")


        local dragon_bg = display.newSprite("chat_hero_background.png")
            :align(display.LEFT_CENTER, 7,dragon_frame:getContentSize().height/2)
            :addTo(dragon_frame)
        local dragon_img = display.newSprite("allianceHome/"..dragon:Type()..".png")
            :align(display.CENTER, dragon_bg:getContentSize().width/2, dragon_bg:getContentSize().height/2+5)
            :addTo(dragon_bg)
        local box_bg = display.newSprite("allianceHome/".."box_426X126.png")
            :align(display.LEFT_CENTER, dragon_frame:getContentSize().width, dragon_frame:getContentSize().height/2)
            :addTo(dragon_frame)
        -- 龙，等级
        local dragon_name = UIKit:ttfLabel({
            text = Localize.dragon[dragon:Type()] .."（LV "..dragon:Level().."）",
            size = 22,
            color = 0x514d3e,
        }):align(display.LEFT_CENTER,20,100)
            :addTo(box_bg,2)

        -- 经验 or hp
        local text_1 = increase_type == "dragonHp" and _("生命值")..dragon:Hp().."/"..dragon:GetMaxHP() or _("经验值")..dragon:Exp().."/"..dragon:GetMaxExp()
        local dragon_vitality = UIKit:ttfLabel({
            text = text_1,
            size = 20,
            color = 0x797154,
        }):align(display.LEFT_CENTER,20,60)
            :addTo(box_bg)

        -- 龙状态
        local d_status = dragon:GetLocalizedStatus()
        local s_color = dragon:IsFree() and 0x007c23 or 0x7e0000
        if dragon:IsDead() then
            s_color = 0x7e0000
        end
        local dragon_status = UIKit:ttfLabel({
            text = d_status,
            size = 20,
            color = s_color,
        }):align(display.LEFT_CENTER,20,30)
            :addTo(box_bg)

        -- check_box
        local check_box = cc.ui.UICheckBoxButton.new(checkbox_image)
            :align(display.CENTER,380,63)
            :addTo(box_bg)

        function dragon_frame:GetDragonType()
            return dragon:Type()
        end
        function dragon_frame:setCheckBoxButtonSelected( isSelected )
            check_box:setButtonSelected(isSelected)
        end
        function dragon_frame:IsSelected()
            return check_box:isButtonSelected()
        end
        function dragon_frame:GetCheckBox()
            return check_box
        end

        function dragon_frame:OnStateChanged(listener)
            check_box:onButtonStateChanged(function(event)
                listener(event)
            end)
            return self
        end
        return dragon_frame
    end

    local dialog = WidgetPopDialog.new(192 + dragon_num*136,increase_type == "dragonHp" and _("增加龙的生命值") or _("增加龙的经验"),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()

    local origin_y = size.height-240
    local gap_y = 130
    local add_count = 0
    local optional_dragon = {}
    function optional_dragon:OnStateChanged( event )
        if event.target:isButtonSelected() == false then
            return
        end
        for i,v in ipairs(self) do
            if v:GetCheckBox() == event.target then
                if not v:IsSelected() then
                    v:setCheckBoxButtonSelected(true)
                end
            else
                if v:IsSelected() then
                    v:setCheckBoxButtonSelected(false)
                end
            end
        end
    end
    -- 默认选中最强的并且可以出战的龙,如果都不能出战,则默认最强龙
    local default_dragon_type = dragon_manager:GetCanFightPowerfulDragonType() ~= "" and dragon_manager:GetCanFightPowerfulDragonType() or dragon_manager:GetPowerfulDragonType()
    local default_select_dragon_index
    for k,dragon in ipairs(dragons) do
        if dragon:Level()>0 then
            local dragon_box = createDragonFrame(dragon):align(display.LEFT_CENTER, 30,origin_y-add_count*gap_y)
                :addTo(body)
                :OnStateChanged(function (event)
                    optional_dragon:OnStateChanged(event)
                end)

            add_count = add_count + 1
            table.insert(optional_dragon, dragon_box)
            if dragon:Type() == default_dragon_type then
                dragon_box:setCheckBoxButtonSelected(true)
            end
        end
    end

    self:CreateItemBox(
        item,
        function ()
            return true
        end,
        function ()
            local item_name = item:Name()
            local select_dragonType = ""
            for i,v in ipairs(optional_dragon) do
                if v:IsSelected() then
                    select_dragonType = v:GetDragonType()
                    break
                end
            end
            NetManager:getUseItemPromise(item_name,{[item_name] = {
                dragonType = select_dragonType
            }}):next(function ()
                dialog:leftButtonClicked()
            end)
        end
    ):addTo(body):align(display.CENTER,size.width/2,size.height - 100)
end
function WidgetUseItems:OpenChestDialog( item )
    local same_items = ItemManager:GetSameTypeItems(item)
    local dialog = WidgetPopDialog.new(#same_items * 138 +100,item:GetLocalizeName(),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()

    for i,v in ipairs(same_items) do
        self:CreateItemBox(
            v,
            function (use_item)
                if ItemManager:CanOpenChest(use_item)  then
                    return true
                else
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("没有钥匙"))
                        :CreateOKButton(
                            {
                                listener = function()end
                            })
                        :AddToCurrentScene()
                end
            end,
            function ()
                local item_name = v:Name()
                NetManager:getUseItemPromise(item_name,{}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        ):addTo(body):align(display.CENTER,size.width/2,size.height - 120 - (i-1)*138)
    end
end

function WidgetUseItems:OpenNormalDialog( item )
    local same_items = ItemManager:GetSameTypeItems(item)
    local dialog = WidgetPopDialog.new(#same_items * 138 +100,item:GetLocalizeName(),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()

    for i,v in ipairs(same_items) do
        self:CreateItemBox(
            v,
            function ()
                return true
            end,
            function ()
                local item_name = v:Name()
                NetManager:getUseItemPromise(item_name,{}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        ):addTo(body):align(display.CENTER,size.width/2,size.height - 120 - (i-1)*138)
    end
end
function WidgetUseItems:OpenVipActive( item )
    local same_items = ItemManager:GetSameTypeItems(item)
    local dialog = WidgetPopDialog.new(4 * 138 +40,_("激活VIP"),window.top-230):addToCurrentScene()
    local body = dialog:GetBody()
    local size = body:getContentSize()
    -- 是否激活 vip
    local vip_event = User:GetVipEvent()
    local vip_status_label = UIKit:ttfLabel({
        size = 22,
        color = vip_event:IsActived() and 0x007c23 or 0x403c2f,
    }):addTo(body):align(display.CENTER,size.width/2, size.height-50)
    if vip_event:IsActived() then
        vip_status_label:setString(_("已激活,剩余时间:")..GameUtils:formatTimeStyle1(vip_event:GetTime()))
    else
        vip_status_label:setString(_("未激活"))
    end


    function dialog:OnVipEventTimer( vip_event_new )
        local time = vip_event_new:GetTime()
        if time >0 then
            vip_status_label:setString(_("已激活,剩余时间:")..GameUtils:formatTimeStyle1(time))
            vip_status_label:setColor(UIKit:hex2c4b(0x007c23))
        else
            vip_status_label:setString(_("未激活"))
            vip_status_label:setColor(UIKit:hex2c4b(0x403c2f))
        end
    end
    dialog:addCloseCleanFunc(function ()
        User:RemoveListenerOnType(dialog, User.LISTEN_TYPE.VIP_EVENT)
    end)

    User:AddListenOnType(dialog, User.LISTEN_TYPE.VIP_EVENT)

    local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0, 0,570,4 * 138 - 60),
    },false)
    list_node:addTo(body):align(display.BOTTOM_CENTER, size.width/2,20)

    for i,v in ipairs(same_items) do
        local list_item = list:newItem()
        list_item:setItemSize(570,136)
        list_item:addContent(self:CreateItemBox(
            v,
            function ()
                return true
            end,
            function ()
                local item_name = v:Name()
                NetManager:getUseItemPromise(item_name,{}):next(function ()
                    dialog:leftButtonClicked()
                end)
            end
        )
        )
        list:addItem(list_item)
    end
    list:reload()
end
function WidgetUseItems:CreateItemBox(item,checkUseFunc,useItemFunc)
    local body = display.newNode()
    body:setContentSize(cc.size(570,128))

    -- icon bg
    local icon_bg = display.newSprite("box_120x128.png"):addTo(body):pos(60,64)
    local item_bg = display.newSprite("box_118x118.png"):addTo(icon_bg):align(display.CENTER, icon_bg:getContentSize().width/2, icon_bg:getContentSize().height/2)
    local item_icon_color_bg = display.newSprite("box_item_100x100.png"):addTo(item_bg):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2)
    local item_icon = display.newSprite("tool_1.png"):addTo(item_bg):align(display.CENTER, item_bg:getContentSize().width/2, item_bg:getContentSize().height/2):scale(0.6)

    local desc_bg = display.newSprite("box_450x128.png"):addTo(body):pos(345,64)

    -- 道具名称
    UIKit:ttfLabel({
        text = item:GetLocalizeName(),
        size = 24,
        color = 0x514d3e,
    }):addTo(desc_bg):align(display.LEFT_CENTER,20, desc_bg:getContentSize().height-20)
    -- 道具介绍
    UIKit:ttfLabel({
        text = item:GetLocalizeDesc(),
        size = 20,
        color = 0x797154,
        dimensions = cc.size(260,0)
    }):addTo(desc_bg):align(display.LEFT_TOP,20, desc_bg:getContentSize().height/2+20)

    local btn_pics , btn_label, btn_call_back
    if item:Count()<1 then
        btn_pics = {normal = "green_btn_up_148x58.png", pressed = "green_btn_down_148x58.png"}
        btn_label = _("购买&使用")
        local item_name = item:Name()
        btn_call_back = function ()
            if item:Price() > User:GetGemResource():GetValue() then
                FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("宝石不足"))
                    :AddToCurrentScene()
            else
                NetManager:getBuyItemPromise(item_name,1):next(function ()
                    useItemFunc()
                end)
            end
        end
        if item:IsSell() then
            local price_bg = display.newSprite("back_ground_118x36.png"):addTo(body):align(display.CENTER,490,84)
            -- gem icon
            local gem_icon = display.newSprite("home/gem_1.png"):addTo(price_bg):align(display.CENTER, 20, price_bg:getContentSize().height/2):scale(0.6)
            UIKit:ttfLabel({
                text = string.formatnumberthousands(item:Price()),
                size = 20,
                color = 0x403c2f,
            }):align(display.LEFT_CENTER, 50 , price_bg:getContentSize().height/2)
                :addTo(price_bg)
        end
    else
        local num_bg = display.newSprite("back_ground_102x30.png"):addTo(item_bg):pos(icon_bg:getContentSize().width/2,20)

        local own_label = UIKit:ttfLabel({
            text = _("拥有")..item:Count(),
            size = 20,
            color = 0xffedae,
        }):addTo(num_bg):align(display.CENTER,num_bg:getContentSize().width/2, num_bg:getContentSize().height/2)

        btn_pics = {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"}
        btn_label = _("使用")
        local item_name = item:Name()
        btn_call_back = useItemFunc
    end
    -- 使用按钮
    local use_btn = WidgetPushButton.new(
        btn_pics,
        {scale9 = false}
    ):setButtonLabel(UIKit:commonButtonLable({text = btn_label}))
        :addTo(body):align(display.CENTER, 490, 34)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if checkUseFunc(item) then
                    btn_call_back(item)
                end
            end
        end)
    -- 没有道具，并且不能购买
    if item:Count()<1 and not item:IsSell() then
        use_btn:setVisible(false)
    end
    return body
end

return WidgetUseItems







