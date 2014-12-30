--
-- Author: Danny He
-- Date: 2014-12-30 15:10:58
--
local Observer = import(".Observer")
local AllianceBelvedere = class("AllianceBelvedere")

function AllianceBelvedere:ctor()
	AllianceBelvedere.super.ctor(self)
end

-- read limt or somethiong
function AllianceBelvedere:OnAllianceDataChanged(alliance_data)

end

return AllianceBelvedere