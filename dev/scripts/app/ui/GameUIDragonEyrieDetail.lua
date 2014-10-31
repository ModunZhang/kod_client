--
-- Author: Danny He
-- Date: 2014-10-31 15:08:59
--
local GameUIDragonEyrieDetail = UIKit:createUIClass("GameUIDragonEyrieDetail","GameUIWithCommonHeader")

-- building-->DragonEyrie
function GameUIDragonEyrieDetail:ctor(city,building,dragon_type)
	GameUIDragonEyrieDetail.super.ctor(self,city,_("龙巢"))
	self.dragon_manager = building:GetDragonManager()
	self.dragon = self.dragon_manager:GetDragon(dragon_type)
end


function GameUIDragonEyrieDetail:CreateBetweenBgAndTitle()

end

function GameUIDragonEyrieDetail:GetDragon()
	return self.dragon
end

return GameUIDragonEyrieDetail