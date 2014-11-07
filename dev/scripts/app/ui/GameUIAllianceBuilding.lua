local WidgetAllianceBuildingUpgrade = import("..widget.WidgetAllianceBuildingUpgrade")
local GameUIAllianceBuilding = UIKit:createUIClass('GameUIAllianceBuilding', "GameUIWithCommonHeader")



function GameUIAllianceBuilding:ctor(city,title,default_tab,building)
    GameUIAllianceBuilding.super.ctor(self, city, title)
    self.default_tab = default_tab
    self.building = building
end

function GameUIAllianceBuilding:CreateTabButtons(param, cb)
    table.insert(param,1, {
        label = _("升级"),
        tag = "upgrade",
        default = true,
    })
    return GameUIAllianceBuilding.super.CreateTabButtons(self,param,function(tag)
        if tag == "upgrade" then
            self.upgrade_layer:setVisible(true)
        else
            self.upgrade_layer:setVisible(false)
        end
        cb(tag)
    end)
end
function GameUIAllianceBuilding:CreateBetweenBgAndTitle()
    GameUIAllianceBuilding.super.CreateBetweenBgAndTitle(self)

    -- upgrade_layer
    self.upgrade_layer = WidgetAllianceBuildingUpgrade.new(self.building)
    self:addChild(self.upgrade_layer)
end



return GameUIAllianceBuilding




