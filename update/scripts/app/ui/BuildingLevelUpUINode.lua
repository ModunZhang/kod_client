local SpriteUINode = import(".SpriteUINode")
local BuildingLevelUpUINode = class("BuildingLevelUpUINode", SpriteUINode)

function BuildingLevelUpUINode:OnCheckUpgradingCondition(sprite)
    self:OnBuildingUpgradeFinished(sprite:GetEntity(), nil)
end
function BuildingLevelUpUINode:OnBuildingUpgradingBegin(building, time)
    self:OnBuildingUpgradeFinished(building, time)
end
function BuildingLevelUpUINode:OnBuildingUpgradeFinished(building, time)
    self:setVisible(building:GetLevel() > 0)
    self.arrow:setVisible(building:BelongCity():GetKeep():CanUpgradeThis(building))
    self:SetLevel(building:GetLevel())
end
function BuildingLevelUpUINode:OnPositionChanged(x, y, bottom_x, bottom_y)
    self:setPosition(self:GetPositionFromWorld(bottom_x, bottom_y))
end
function BuildingLevelUpUINode:SetLevel(level)
    self.text_field:setString(level)
end
function BuildingLevelUpUINode:ctor()
    BuildingLevelUpUINode.super.ctor(self)
    self:zorder(0)
    self:setCascadeOpacityEnabled(true)
end
function BuildingLevelUpUINode:InitWidget()
    cc.ui.UIImage.new("levelup/level_bg.png"):addTo(self)
    self.text_field = cc.ui.UILabel.new({
        text = "0",
        size = 15,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xfff1cc)
    }):addTo(self):align(display.CENTER, 10, 15)
    local level_arrow_bg = cc.ui.UIImage.new("levelup/level_arrow_bg.png"):addTo(self):pos(15, 15)
    cc.ui.UIImage.new("levelup/level_arrow.png"):addTo(level_arrow_bg):pos(2, 2)
    self.arrow = level_arrow_bg
end



return BuildingLevelUpUINode



