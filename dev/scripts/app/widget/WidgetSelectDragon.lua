local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetPushButton = import(".WidgetPushButton")

local WidgetSelectDragon = UIKit:createUIClass("WidgetSelectDragon", "UIAutoClose")

local img_dir = "allianceHome/"

function WidgetSelectDragon:ctor(callback)
    local dragon_manager = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager()

	local body = WidgetUIBackGround.new({height=516}):align(display.TOP_CENTER,display.cx,display.top-200)
    self:addTouchAbleChild(body)
	
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = _("选中出战的巨龙"),
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width-20,rb_size.height+10):addTo(body)
    local function createDragonFrame(dragon)
        local dragon_frame = display.newSprite("alliance_item_flag_box_126X126.png")


        local dragon_bg = display.newSprite("chat_hero_background.png")
            :align(display.LEFT_CENTER, 7,dragon_frame:getContentSize().height/2)
            :addTo(dragon_frame)
        local dragon_img = display.newSprite(img_dir..dragon:Type()..".png")
            :align(display.CENTER, dragon_bg:getContentSize().width/2, dragon_bg:getContentSize().height/2+5)
            :addTo(dragon_bg)
        local box_bg = display.newSprite(img_dir.."box_426X126.png")
            :align(display.LEFT_CENTER, dragon_frame:getContentSize().width, dragon_frame:getContentSize().height/2)
            :addTo(dragon_frame)
        -- 龙，等级
        local dragon_name = UIKit:ttfLabel({
            text = _(dragon:Type()).."（LV "..dragon:Level().."）",
            size = 22,
            color = 0x514d3e,
        }):align(display.LEFT_CENTER,20,100)
            :addTo(box_bg,2)
        -- 总力量
        local dragon_vitality = UIKit:ttfLabel({
            text = _("总力量")..dragon:Strength(),
            size = 20,
            color = 0x797154,
        }):align(display.LEFT_CENTER,20,60)
            :addTo(box_bg)
        -- 龙活力
        local dragon_vitality = UIKit:ttfLabel({
            text = _("生命值")..dragon:Hp().."/"..dragon:GetMaxHP(),
            size = 20,
            color = 0x797154,
        }):align(display.LEFT_CENTER,20,20)
            :addTo(box_bg)
        return dragon_frame
    end

    local dragons = dragon_manager:GetDragons()
    local origin_y = rb_size.height-90
    local gap_y = 130
    local add_count = 0
    local optional_dragon = {}
    for k,dragon in pairs(dragons) do
        if dragon:Level()>0 then
            createDragonFrame(dragon):align(display.LEFT_CENTER, 30,origin_y-add_count*gap_y)
                :addTo(body)
            add_count = add_count + 1
            table.insert(optional_dragon, dragon)
        end
    end

    local checkbox_image = {
        off = "checkbox_unselected.png",
        off_pressed = "checkbox_unselected.png",
        off_disabled = "checkbox_unselected.png",
        on = "checkbox_selectd.png",
        on_pressed = "checkbox_selectd.png",
        on_disabled = "checkbox_selectd.png",

    }
    local group = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :addTo(body)
    for i=1,add_count do
        group:addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
            :align(display.LEFT_CENTER))
    end
    group:setButtonsLayoutMargin(80, 0, 0, 0)
        :setLayoutSize(100, 500)
        :align(display.TOP_CENTER, 500 , 110)
    group:getButtonAtIndex(1):setButtonSelected(true)

    local ok_btn = WidgetPushButton.new({normal = "yellow_btn_up_185x65.png",pressed = "yellow_btn_down_185x65.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("确定"),
            size = 24,
            color = 0xffedae,
            shadow= true
        }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                for i=1,group:getButtonsCount() do
                    if group:getButtonAtIndex(i):isButtonSelected() then
                    	assert(tolua.type(callback)=="function","选择出战龙回调错误")
                        callback(optional_dragon[i])
                        break
                    end
                end
                self:removeFromParent(true)
            end
        end):align(display.CENTER,rb_size.width/2,50):addTo(body)
end

return WidgetSelectDragon