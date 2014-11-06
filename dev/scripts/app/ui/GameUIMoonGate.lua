local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetBuyGoods = import("..widget.WidgetBuyGoods")
local WidgetStockGoods = import("..widget.WidgetStockGoods")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIMoonGate = UIKit:createUIClass('GameUIMoonGate', "GameUIWithCommonHeader")
local Flag = import("..entity.Flag")
local UIListView = import(".UIListView")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Localize = import("..utils.Localize")


function GameUIMoonGate:ctor(city,default_tab)
    GameUIMoonGate.super.ctor(self, city, _("月门"))
    self.default_tab = default_tab
end

function GameUIMoonGate:onEnter()
    GameUIMoonGate.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("升级"),
            tag = "upgarde",
            default = "upgarde" == self.default_tab,
        },
        {
            label = _("驻防部队"),
            tag = "garrison",
            default = "garrison" == self.default_tab,
        },
        {
            label = _("其他联盟"),
            tag = "stock",
            default = "stock" == self.default_tab,
        },
        {
            label = _("外交关系"),
            tag = "record",
            default = "record" == self.default_tab,
        },
    }, function(tag)
        if tag == 'upgarde' then
            self.upgrade_layer:setVisible(true)
        else
            self.upgrade_layer:setVisible(false)
        end
        if tag == 'garrison' then
            self.garrison_layer:setVisible(true)
        else
            self.garrison_layer:setVisible(false)
        end
        if tag == 'otherAlliance' then
            self.otherAlliance_layer:setVisible(true)
        else
            self.otherAlliance_layer:setVisible(false)
        end
        if tag == 'foreignRelations' then
            self.foreign_relations_layer:setVisible(true)
        else
            self.foreign_relations_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
    self:InitGarrisonPart()
end
function GameUIMoonGate:CreateBetweenBgAndTitle()
    GameUIMoonGate.super.CreateBetweenBgAndTitle(self)

    -- upgrade_layer
    self.upgrade_layer = display.newLayer()
    self:addChild(self.upgrade_layer)
    -- garrison_layer
    self.garrison_layer = display.newLayer()
    self:addChild(self.garrison_layer)
    -- otherAlliance_layer
    self.otherAlliance_layer = display.newLayer()
    self:addChild(self.otherAlliance_layer)
    -- foreign_relations_layer
    self.foreign_relations_layer = display.newLayer()
    self:addChild(self.foreign_relations_layer)
end

function GameUIMoonGate:InitGarrisonPart()
    self.garrison_listview = UIListView.new{
        bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-300, display.top-730, 600, 630),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.garrison_layer)
end

function GameUIMoonGate:onExit()
    GameUIMoonGate.super.onExit(self)
end

return GameUIMoonGate




