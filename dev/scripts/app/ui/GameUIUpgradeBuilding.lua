local GameUIWithCommonHeader = import('.GameUIWithCommonHeader')
local CommonUpgradeUI = import('.CommonUpgradeUI')
local GameUIUpgradeBuilding = class('GameUIUpgradeBuilding', GameUIWithCommonHeader)

function GameUIUpgradeBuilding:ctor(city, title , building)
    GameUIUpgradeBuilding.super.ctor(self,city, title)
    self.upgrade_city = city
    self.building = building
end

function GameUIUpgradeBuilding:CreateBetweenBgAndTitle()
    GameUIUpgradeBuilding.super.CreateBetweenBgAndTitle(self)
    -- 加入升级layer
    self.upgrade_layer = CommonUpgradeUI.new(self.upgrade_city, self.building)
    self:addChild(self.upgrade_layer)
end

function GameUIUpgradeBuilding:CreateTabButtons(param, cb)
    table.insert(param,1, {
        label = _("升级"),
        tag = "upgrade",
        default = true,
    })
    return GameUIUpgradeBuilding.super.CreateTabButtons(self,param,function(tag)
        if tag == "upgrade" then
            self.upgrade_layer:setVisible(true)
        else
            self.upgrade_layer:setVisible(false)
        end
        cb(tag)
    end)
end

function GameUIUpgradeBuilding:GetBuilding()
    return self.building
end

return GameUIUpgradeBuilding


