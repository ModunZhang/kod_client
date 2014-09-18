local GameUIWithCommonHeader = import('.GameUIWithCommonHeader')
local CommonUpgradeUI = import('.CommonUpgradeUI')
local GameUIUpgradeBuilding = class('GameUIUpgradeBuilding', GameUIWithCommonHeader)

function GameUIUpgradeBuilding:ctor(city, title , building)
    GameUIUpgradeBuilding.super.ctor(self,city, title)
    self.building = building
end

function GameUIUpgradeBuilding:CreateBetweenBgAndTitle()
    GameUIUpgradeBuilding.super.CreateBetweenBgAndTitle(self)
    -- 加入升级layer
    self.upgrade_layer = CommonUpgradeUI.new(self.city,self.building)
    self:addChild(self.upgrade_layer)
end

function GameUIUpgradeBuilding:CreateTabButtons(param, layers)
    table.insert(param,1, {
        label = _("升级"),
        tag = "upgrade",
        default = true,
    })
    return GameUIUpgradeBuilding.super.CreateTabButtons(self,param,function(tag)
        if tag == "upgrade" then
            self.upgrade_layer:setVisible(true)
            for k,v in pairs(layers) do
                v:setVisible(false)
            end
        else
            self.upgrade_layer:setVisible(false)
            for layer_tag,layer in pairs(layers) do
                if tag == layer_tag then
                    layer:setVisible(true)
                else
                    layer:setVisible(false)
                end
            end
        end
    end)
end


return GameUIUpgradeBuilding


