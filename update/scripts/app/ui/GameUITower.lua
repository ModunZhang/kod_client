local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetInfoWithTitle = import("..widget.WidgetInfoWithTitle")


local GameUITower = UIKit:createUIClass('GameUITower',"GameUIUpgradeBuilding")
function GameUITower:ctor(city,building)
    local bn = Localize.building_name
    GameUITower.super.ctor(self,city,bn[building:GetType()],building)
end


function GameUITower:OnMoveInStage()
    GameUITower.super.OnMoveInStage(self)
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "info",
        }
    },
    function(tag)
        if tag == 'info' then
            self.info_layer:show()
        else
            self.info_layer:hide()
        end
    end):pos(window.cx, window.bottom + 34)

    self:InitInfo()
end

function GameUITower:CreateBetweenBgAndTitle()
    GameUITower.super.CreateBetweenBgAndTitle(self)

    -- 加入城堡info_layer
    self.info_layer = display.newLayer():addTo(self:GetView())
end

function GameUITower:InitInfo()
    local atkinfs,atkarcs,atkcavs,atkcats = self.building:GetAtk()
    local info = {
        {
            "对步兵攻击",
            atkinfs,
        },
        {
            "对骑兵攻击",
            atkarcs,
        },
        {
            "对弓箭手攻击",
            atkarcs,
        },
        {
            "对投石车攻击",
            atkcats,
        },
    }
    WidgetInfoWithTitle.new({
        info = info,
        title = _("总计"),
        h = 226
        }):addTo(self.info_layer)
    :align(display.TOP_CENTER, window.cx, window.top-100)
end

return GameUITower



