local SpriteUINode = import(".SpriteUINode")
local BuildingUpgradeUINode = class("BuildingUpgradeUINode", SpriteUINode)

function BuildingUpgradeUINode:OnBuildingUpgradingBegin(building, time)
    self:OnBuildingUpgrading(building, time)
end
function BuildingUpgradeUINode:OnBuildingUpgradeFinished(building)
    self:setVisible(false)
end
function BuildingUpgradeUINode:OnBuildingUpgrading(building, time)
    if not self:isVisible() then
        self:setVisible(true)
    end
end
function BuildingUpgradeUINode:ctor()
    BuildingUpgradeUINode.super.ctor(self)
    self:zorder(1)
    self:setVisible(false)
end
function BuildingUpgradeUINode:setVisible(visible)
    getmetatable(self).setVisible(self, visible)
    if visible then
        self.armature:getAnimation():play("Animation1")
    else
        self.armature:getAnimation():stop()
    end
end
function BuildingUpgradeUINode:InitWidget()
    local armature = ccs.Armature:create("chuizidonghua")
    self:addChild(armature)
    armature:getAnimation():play("Animation1")
    self.armature = armature
end




return BuildingUpgradeUINode




