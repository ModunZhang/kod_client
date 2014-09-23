local UIListView = import(".UIListView")
local WidgetMaterialBox = import("..widget.WidgetMaterialBox")
local WidgetMaterialDetails = import("..widget.WidgetMaterialDetails")


local GameUIMaterialDepot = UIKit:createUIClass("GameUIMaterialDepot", "GameUIUpgradeBuilding")
function GameUIMaterialDepot:ctor(city,building)
    GameUIMaterialDepot.super.ctor(self, city, _("材料库房"),building)
end
function GameUIMaterialDepot:onEnter()
    GameUIMaterialDepot.super.onEnter(self)
end


function GameUIMaterialDepot:CreateBetweenBgAndTitle()
    GameUIMaterialDepot.super.CreateBetweenBgAndTitle(self)

    -- 加入军用帐篷info_layer
    self.info_layer = display.newLayer()
    self:addChild(self.info_layer)
end

function GameUIMaterialDepot:onEnter()
    GameUIMaterialDepot.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "info",
        },
    },function(tag)
        if tag == 'info' then
            self.info_layer:setVisible(true)
        else
            self.info_layer:setVisible(false)
        end
    end):pos(display.cx, display.bottom + 40)

    self:CreateMaterialInfo()

end

function GameUIMaterialDepot:CreateMaterialInfo()
    -- create page view
    self.pv = cc.ui.UIPageView.new {
        -- bgColor = cc.c4b(200, 200, 0, 200),
        -- bg = "sunset.png",
        viewRect = cc.rect(display.cx-266, display.top-870, 547, 780),
        column = 4, row = 5,
        padding = {left = 20, right = 20, top = 20, bottom = 20},
        columnSpace = 20, rowSapce = 20}
        :onTouch(function ( ... )
            print("hello")
        end)
        :addTo(self.info_layer)

    -- add items
    for i=1,23 do
        local item = self.pv:newItem()
        local materialBox = WidgetMaterialBox.new("material_blueprints.png",function ()
            self:OpenMaterialDetails()
        end,true)
        materialBox:SetNumber("1/99")
        item:addChild(materialBox)
        self.pv:addItem(item)
    end
    self.pv:reload()
end

function GameUIMaterialDepot:OpenMaterialDetails()
	self:addChild(WidgetMaterialDetails.new())
end

return GameUIMaterialDepot



