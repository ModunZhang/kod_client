--
-- Author: Kenny Dai
-- Date: 2015-10-19 11:31:18
--
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local UILib = import(".UILib")
local Alliance = import("..entity.Alliance")
local Localize = import("..utils.Localize")
local GameUIAllianceWatchTower = UIKit:createUIClass('GameUIAllianceWatchTower', "GameUIAllianceBuilding")

function GameUIAllianceWatchTower:ctor(city,default_tab,building)
    GameUIAllianceWatchTower.super.ctor(self, city, _("巨石阵"),default_tab,building)
    self.default_tab = default_tab
    self.building = building
    self.alliance = Alliance_Manager:GetMyAlliance()
end

function GameUIAllianceWatchTower:OnMoveInStage()
    GameUIAllianceWatchTower.super.OnMoveInStage(self)
    self:CreateTabButtons({
        {
            label = _("来袭"),
            tag = "beStriked",
            default = "beStriked" == self.default_tab,
        },
        {
            label = _("行军"),
            tag = "march",
            default = "march" == self.default_tab,
        },
    }, function(tag)
        
    end):pos(window.cx, window.bottom + 34)
    dump(self.alliance.marchEvents,"marchEvents")
end
function GameUIAllianceWatchTower:CreateBetweenBgAndTitle()
    GameUIAllianceWatchTower.super.CreateBetweenBgAndTitle(self)
    self.event_layer = display.newLayer():addTo(self:GetView())
end

function GameUIAllianceWatchTower:onExit()
    GameUIAllianceWatchTower.super.onExit(self)
end
-- 创建来袭事件列表页
function GameUIAllianceWatchTower:CreateBeStrikedList()
end
-- 创建行军事件列表页
function GameUIAllianceWatchTower:CreateMarchList()
end
-- 根据巨石阵等级过滤出能够显示出的事件信息
function GameUIAllianceWatchTower:FliterEffect()

end
return GameUIAllianceWatchTower