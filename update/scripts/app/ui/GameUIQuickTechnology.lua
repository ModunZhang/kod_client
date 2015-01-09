--
-- Author: Danny He
-- Date: 2014-12-18 08:35:48
--
local GameUIQuickTechnology = UIKit:createUIClass("GameUIQuickTechnology","GameUIWithCommonHeader")
local GameUIAcademy = import(".GameUIAcademy")
local window = import("..utils.window")

function GameUIQuickTechnology:ctor()
	GameUIAcademy.super.ctor(self,City,_("科技研发"))
end

function GameUIQuickTechnology:onEnter()
	GameUIQuickTechnology.super.onEnter(self)
	local academy = GameUIAcademy.new()
	academy:BuildTechnologyUI(window.height - 100):addTo(self):pos(window.left,window.bottom+15)
	academy = nil
end

return GameUIQuickTechnology