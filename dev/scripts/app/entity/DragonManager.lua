--
-- Author: Danny He
-- Date: 2014-10-27 21:33:54
--
local Enum = import("app.utils.Enum")
local property = import("app.utils.property")
local MultiObserver = import("app.entity.MultiObserver")
local DragonManager = class("DragonManager", MultiObserver)

function DragonManager:ctor()
	self.dragons_ = {}
end

-- function DragonManager:( ... )
-- 	-- body
-- end

return DragonManager