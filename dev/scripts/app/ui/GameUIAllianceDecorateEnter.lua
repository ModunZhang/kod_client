--
-- Author: Danny He
-- Date: 2014-12-29 17:09:39
--
local GameUIAllianceDecorateEnter = UIKit:createUIClass("GameUIAllianceDecorateEnter","GameUIAllianceEnterBase")
local buildingType_config = GameDatas.AllianceInitData.buildingType

function GameUIAllianceDecorateEnter:GetUIHeight()
	return 242
end

function GameUIAllianceDecorateEnter:GetHonourLabelText()
	return buildingType_config[self:GetBuilding():GetType()].distroyNeedHonour 
end

function GameUIAllianceDecorateEnter:FixedUI()
	self:GetLevelBg():show()
	self:GetLevelLabel():hide()
	self.process_bar_bg:hide()
end



function GameUIAllianceDecorateEnter:GetUITitle()
	return _("树/湖泊/山脉")
end

function GameUIAllianceDecorateEnter:GetBuildingImage()
	return "tree_1_120x120.png"
end

function GameUIAllianceDecorateEnter:GetBuildingCategory()
	return 'decorate'
end

function GameUIAllianceDecorateEnter:GetBuildingDesc()
	return _("可拆除,需要职位在将军以上的玩家,并且花费一定的荣誉值")
end


function GameUIAllianceDecorateEnter:GetBuildingInfo()
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
    local w,h = self:GetBuilding():GetSize()
    local occupy = {
        {_("占地"),0x797154},
        {w*h,0x403c2f},
    }
  	return {location,occupy}
end

function GameUIAllianceDecorateEnter:GetEnterButtons()
	local chai_button = self:BuildOneButton("icon_demolish.png",_("拆除")):onButtonClicked(function()
		local alliacne =  self:GetMyAlliance()
        local isEqualOrGreater = alliacne:GetMemeberById(DataManager:getUserData()._id):IsTitleEqualOrGreaterThan("general")
        if isEqualOrGreater then
            NetManager:getDistroyAllianceDecoratePromise(building:Id())
        end
		self:leftButtonClicked()
	end)
 	return {chai_button}
end

return GameUIAllianceDecorateEnter