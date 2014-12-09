--
-- Author: Danny He
-- Date: 2014-12-02 09:26:02
--
local Observer = import(".Observer")
local MarchEventBase = class("MarchEventBase",Observer)
local Enum = import("..utils.Enum")

MarchEventBase.MARCH_EVENT_WITH_PLAYER = Enum("SENDER","RECEIVER","NOTHING")

--判断该玩家是这个事件的发送者/接受者/无关
function MarchEventBase:GetMarchPlayerInfo(palyer_id)
	assert(false,"必须在子类实现GetMarchPlayerInfo方法，并返回MarchEventBase.MARCH_EVENT_WITH_PLAYER中的枚举类型")
end

function MarchEventBase:Reset()
	self:RemoveAllObserver()
end

function MarchEventBase:OnTimer(current_time)
	assert(false,"必须在子类实现OnTimer方法，用于计算行军还需要的时间")
end

function MarchEventBase:GetTime()
	assert(false,"必须在子类实现GetTime方法，用于返回行军还需的时间")
end

return MarchEventBase