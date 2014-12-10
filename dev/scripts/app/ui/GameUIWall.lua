
local Localize = import("..utils.Localize")
local GameUIWall = UIKit:createUIClass('GameUIWall',"GameUIUpgradeBuilding")

function GameUIWall:ctor(city,building)
    local bn = Localize.building_name
    GameUIWall.super.ctor(self,city,bn[building:GetType()],building)
end

function GameUIWall:onEnter()
	GameUIWall.super.onEnter(self)
	self:CreateTabButtons({
        {
            label = _("驻防"),
            tag = "hold",
        }
    },
    function(tag)
        if tag == 'hold' then
        else
        end
    end)
end


return GameUIWall