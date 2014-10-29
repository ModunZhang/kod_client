--
-- Author: Danny He
-- Date: 2014-10-28 16:14:06
--
local GameUIDragonEyrieMain = UIKit:createUIClass("GameUIDragonEyrieMain","GameUIWithCommonHeader")

function GameUIDragonEyrieMain:ctor(city,building)
	GameUIDragonEyrieMain.super.ctor(self,City,_("龙巢"),building)
	self.dragon_manager = building:GetDragonManager()
end

function GameUIDragonEyrieMain:onMoveInStage()
	GameUIDragonEyrieMain.super.onMoveInStage(self)

end

return GameUIDragonEyrieMain