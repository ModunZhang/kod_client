--
-- Author: Kenny Dai
-- Date: 2015-01-14 20:59:24
--
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetInfo = import("..widget.WidgetInfo")
local UIListView = import(".UIListView")
local img_dir = "allianceHome/"

local GameUIMoonGate = UIKit:createUIClass('GameUIMoonGate', "GameUIWithCommonHeader")

function GameUIMoonGate:ctor(city,default_tab,building)
    GameUIMoonGate.super.ctor(self, city, _("月门"))
    self.default_tab = default_tab
    self.building = building
end

function GameUIMoonGate:onEnter()
    GameUIMoonGate.super.onEnter(self)

    self:CreateTabButtons({
        {
            label = _("王城"),
            tag = "king_city",
            default = "king_city" == self.default_tab,
        },
        {
            label = _("驻防部队"),
            tag = "garrison",
            default = "garrison" == self.default_tab,
        },
    }, function(tag)
        if tag == 'garrison' then
            self.garrison_layer:setVisible(true)
        else
            self.garrison_layer:setVisible(false)
        end
        if tag == 'king_city' then
            self.king_city_layer:setVisible(true)
        else
            self.king_city_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
    self:InitKingCity()
    self:InitGarrison()
end
function GameUIMoonGate:CreateBetweenBgAndTitle()
    GameUIMoonGate.super.CreateBetweenBgAndTitle(self)

    -- garrison_layer
    self.garrison_layer = display.newLayer()
    self:addChild(self.garrison_layer)
    -- king_city_layer
    self.king_city_layer = display.newLayer()
    self:addChild(self.king_city_layer)
end

function GameUIMoonGate:InitKingCity()
    local layer = self.king_city_layer

    -- 王城大图
    local king_city_image = display.newSprite("king_city.png"):align(display.CENTER, window.cx, window.top - 350):addTo(layer)
    local shadow_layer = UIKit:shadowLayer():addTo(king_city_image)
    shadow_layer:setContentSize(cc.size(556,78))
    local box_bg = display.newSprite("box_558x514.png"):align(display.CENTER, king_city_image:getContentSize().width/2,king_city_image:getContentSize().height/2)
        :addTo(king_city_image)
    WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(shadow_layer)
        :align(display.CENTER, 278, 39)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("进入主城"),
            size = 24,
            color = 0xfff3c7
        }))
        :setButtonEnabled(false)
    WidgetInfo.new({
        info={
        	{_("统治者"),_("黑龙军团")},
        	{_("开启时间"),_("未知")},
        	{_("状态"),_("保护期")},
        },
        w = 546
    }):align(display.BOTTOM_CENTER, window.cx, window.top - 770)
        :addTo(layer)
    WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(layer)
        :align(display.CENTER, window.cx, window.top - 820)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("宣战"),
            size = 24,
            color = 0xfff3c7
        }))
        :setButtonEnabled(false)
end

function GameUIMoonGate:InitGarrison()
	local layer = self.garrison_layer
    local fight_bg = display.newSprite("report_back_ground.png")
        :align(display.TOP_CENTER, window.cx, window.top-110)
        :addTo(layer)
        :scale(0.95)
    local our_alliance_name = UIKit:ttfLabel({
        text = "己方联盟",
        size = 20,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER,80,60)
        :addTo(fight_bg)
    local enemy_alliance_name = UIKit:ttfLabel({
        text = "敌方联盟",
        size = 20,
        color = 0x403c2f,
    }):align(display.RIGHT_CENTER,fight_bg:getContentSize().width-80,60)
        :addTo(fight_bg)
    -- 己方派出的部队数量
    local self_citizen_bg = display.newSprite("back_ground_138x34.png")
        :align(display.LEFT_CENTER,80,25)
        :addTo(fight_bg)
        :scale(0.9)
    display.newSprite("citizen_44x50.png")
        :align(display.CENTER,20,20)
        :addTo(self_citizen_bg)
    local self_citizen_label = UIKit:ttfLabel({
        text = "？",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,80,self_citizen_bg:getContentSize().height/2)
        :addTo(self_citizen_bg)
    local VS = UIKit:ttfLabel({
        text = "VS",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,fight_bg:getContentSize().width/2,fight_bg:getContentSize().height/2)
        :addTo(fight_bg)
    -- 联盟旗帜
    display.newSprite("flag_background.png"):addTo(fight_bg):align(display.CENTER,fight_bg:getContentSize().width/2-45,fight_bg:getContentSize().height/2)
    display.newSprite("flag_background.png"):addTo(fight_bg):align(display.CENTER,fight_bg:getContentSize().width/2+45,fight_bg:getContentSize().height/2)

    -- 敌方派出的部队数量
    local enemy_citizen_bg = display.newSprite("back_ground_138x34.png")
        :align(display.RIGHT_CENTER,fight_bg:getContentSize().width-80,25)
        :addTo(fight_bg)
        :scale(0.9)
    display.newSprite("citizen_44x50.png")
        :align(display.CENTER,20,20)
        :addTo(enemy_citizen_bg)
    local enemy_citizen_label = UIKit:ttfLabel({
        text = "？",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,80,enemy_citizen_bg:getContentSize().height/2)
        :addTo(enemy_citizen_bg)

     local list,list_node = UIKit:commonListView({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(20, 0,608,540),
    })
    list_node:addTo(layer):pos(15,window.bottom_top+110)
	
	UIKit:ttfLabel({
        text = _("当前没有开战"),
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER,window.cx,window.top-480)
    :addTo(layer)
    WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(layer)
        :align(display.CENTER, window.cx, window.top - 830)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("派兵"),
            size = 24,
            color = 0xfff3c7
        }))
        :setButtonEnabled(false)
end

function GameUIMoonGate:onExit()
    GameUIMoonGate.super.onExit(self)
end

return GameUIMoonGate