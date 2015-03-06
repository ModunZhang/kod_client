--
-- Author: Danny He
-- Date: 2015-03-06 17:27:51
--

local GameUIDailyMissionInfo = UIKit:createUIClass("GameUIDailyMissionInfo")
local KEYS_OF_DAILY = {"empireRise","conqueror","brotherClub","growUp"}
local window = import("..utils.window")
local Localize = import("..utils.Localize")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local UIKit = UIKit

function GameUIDailyMissionInfo:ctor(key_of_daily)
	GameUIDailyMissionInfo.super.ctor(self)
	self.key_of_daily = key_of_daily
end

return GameUIDailyMissionInfo