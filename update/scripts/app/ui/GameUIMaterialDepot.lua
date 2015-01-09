local window = import("..utils.window")
local WidgetMaterials = import("..widget.WidgetMaterials")

local MaterialManager = import("..entity.MaterialManager")

local GameUIMaterialDepot = UIKit:createUIClass("GameUIMaterialDepot", "GameUIUpgradeBuilding")
function GameUIMaterialDepot:ctor(city,building)
    GameUIMaterialDepot.super.ctor(self, city, _("材料库房"),building)
end

function GameUIMaterialDepot:CreateBetweenBgAndTitle()
    GameUIMaterialDepot.super.CreateBetweenBgAndTitle(self)

    -- 加入军用帐篷info_layer
    self.info_layer = WidgetMaterials.new(self.city,self.building)
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
    end):pos(window.cx, window.bottom + 34)
end

return GameUIMaterialDepot