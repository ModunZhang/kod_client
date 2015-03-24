--
-- Author: Danny He
-- Date: 2015-03-24 16:04:35
--
local GameUIStore = UIKit:createUIClass("GameUIStore", "GameUIWithCommonHeader")
local UIListView = import(".UIListView")
local window = import("..utils.window")


function GameUIStore:ctor()
	GameUIStore.super.ctor(self,City,_("获得金龙币"))

end

function GameUIStore:OnMoveInStage()
	GameUIStore.super.OnMoveInStage(self)
	self:CreateUI()
end

function GameUIStore:CreateUI()
	self.listView = UIListView.new({
		bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect((window.width - 610)/2, window.bottom + 10, 610,window.betweenHeaderAndTab),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
	}):addTo(self:GetView())
end

function GameUIStore:RightButtonClicked()
end

return GameUIStore