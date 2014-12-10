
local Localize = import("..utils.Localize")
local GameUIWall = UIKit:createUIClass('GameUIWall',"GameUIUpgradeBuilding")
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")

function GameUIWall:ctor(city,building)
    local bn = Localize.building_name
    GameUIWall.super.ctor(self,city,bn[building:GetType()],building)
end

function GameUIWall:onEnter()
	GameUIWall.super.onEnter(self)
	self:CreateMilitaryUIIf():addTo(self):hide()
	self:CreateTabButtons({
        {
            label = _("驻防"),
            tag = "military",
        }
    },
    function(tag)
        if tag == 'military' then
        	self.military_node:show()
        else
        	self.military_node:hide()
        end
    end):pos(window.cx, window.bottom + 34)
end


function GameUIWall:CreateMilitaryUIIf()
	if self.military_node then return self.military_node end
	local military_node = display.newNode()
	local top_bg = WidgetUIBackGround.new({height = 332})
		:addTo(military_node)
		:pos(15,window.betweenHeaderAndTab - 220)
	local list_bg = display.newScale9Sprite("box_bg_546x214.png")
		:addTo(top_bg)
		:align(display.LEFT_BOTTOM,25,30)
		:size(568, 100)
	self.military_node = military_node
	return self.military_node
end

return GameUIWall