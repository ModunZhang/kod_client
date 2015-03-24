--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local window = import("..utils.window")
-- local ResourceManager = import("..entity.ResourceManager")
local GameUIResource = import(".GameUIResource")
local WidgetCitizen = import("..widget.WidgetCitizen")
local GameUIDwelling = class("GameUIDwelling", GameUIResource)

function GameUIDwelling:ctor(building, city)
    GameUIDwelling.super.ctor(self, building)
    self.dwelling_city = city
    return true
end

function GameUIDwelling:CreateUI()
    self:CreateInfomation()
    self.citizen_panel = self:CreateCitizenPanel()
    self:createTabButtons()
end
function GameUIDwelling:OnMoveOutStage()
    GameUIDwelling.super.OnMoveOutStage(self)
end
function GameUIDwelling:CreateCitizenPanel()
    return WidgetCitizen.new(self.city):addTo(self)
end

function GameUIDwelling:createTabButtons()
    self:CreateTabButtons({
        {
            label = _("城民"),
            tag = "citizen",
        },
        {
            label = _("信息"),
            tag = "infomation",
        }
    },
    function(tag)
        if tag == 'infomation' then
            self.citizen_panel:setVisible(false)
            self.infomationLayer:setVisible(true)
            self:RefreshListView()
        elseif tag == "citizen" then
            self.citizen_panel:UpdateData()
            self.citizen_panel:setVisible(true)
            self.infomationLayer:setVisible(false)
        else
            self.citizen_panel:setVisible(false)
            self.infomationLayer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
end

return GameUIDwelling











