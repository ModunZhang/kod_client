--
-- Author: Kenny Dai
-- Date: 2015-02-02 16:19:41
--

local WidgetMoveHouse = class("WidgetMoveHouse",function ( )
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)

WidgetMoveHouse.ADD_TAG =989

function WidgetMoveHouse:ctor(house)
    local running_scene = display.getRunningScene()
    if running_scene.__cname == "MyCityScene" then
        running_scene:EnterEditMode()
        self.house = house
        running_scene:GetSceneUILayer():addChild(self, 1, WidgetMoveHouse.ADD_TAG)
        self.ok_btn = cc.ui.UIPushButton.new(
            {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"},
            {scale9 = false}
        ):setButtonLabel(UIKit:commonButtonLable({text = _("确定")}))
            :addTo(self):pos(100,0)
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                	local from_house_tile = City:GetTileWhichBuildingBelongs(house)
                	local _fromBuildingLocation = from_house_tile.location_id
                	local _fromHouseLocation = from_house_tile:GetBuildingLocation(house)
                	local to_house_tile = City:GetTileWhichBuildingBelongs(self.move_to_ruins:GetEntity())
                	local _toBuildingLocation = to_house_tile.location_id
                	local _toHouseLocation = to_house_tile:GetBuildingLocation(self.move_to_ruins:GetEntity())
                    NetManager:getUseItemPromise("movingConstruction",{
                        movingConstruction = {
                            fromBuildingLocation = _fromBuildingLocation,
                            fromHouseLocation = _fromHouseLocation,
                            toBuildingLocation = _toBuildingLocation,
                            toHouseLocation = _toHouseLocation,
                        }
                    }):next(function ()
                        running_scene:LeaveEditMode()
                    end)
                end
            end)
        self.ok_btn:setVisible(false)
        self.cancel_btn = cc.ui.UIPushButton.new(
            {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"},
            {scale9 = false}
        ):setButtonLabel(UIKit:commonButtonLable({text = _("取消")}))
            :addTo(self):pos(-100,0)
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    running_scene:LeaveEditMode()
                end
            end)
        self.cancel_btn:setVisible(false)

    end

end
function WidgetMoveHouse:SetMoveToRuins( ruins )
    if ruins:GetEntity() == self.house then
        return
    end
    self.move_to_ruins=ruins
    self.ok_btn:setVisible(true)

    self.cancel_btn:setVisible(true)

    local world_pos = ruins:GetWorldPosition()
    self:setPosition(world_pos.x, world_pos.y)
end
function WidgetMoveHouse:GetRuins( )
    return self.move_to_ruins
end

return WidgetMoveHouse




