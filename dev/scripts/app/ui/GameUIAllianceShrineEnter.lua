--
-- Author: Danny He
-- Date: 2014-12-29 11:32:56
--
local GameUIAllianceShrineEnter = UIKit:createUIClass("GameUIAllianceShrineEnter","GameUIAllianceEnterBase")

function GameUIAllianceShrineEnter:ctor(building,isMyAlliance,alliance)
	GameUIAllianceShrineEnter.super.ctor(self,building,isMyAlliance,alliance)
	self.building = building:GetAllianceBuildingInfo()
end

-- function GameUIAllianceShrineEnter:IsMyAlliance()
-- 	return self.isMyAlliance
-- end

function GameUIAllianceShrineEnter:GetLocation()
	local mapObject = self:GetMyAlliance():GetAllianceMap():FindMapObjectById(self:GetBuilding().id)
	return mapObject.location.x .. "," .. mapObject.location.y
end

function GameUIAllianceShrineEnter:GetUIHeight()
	return 261
end

function GameUIAllianceShrineEnter:GetUITitle()
	return _("圣地")
end

function GameUIAllianceShrineEnter:GetBuildingImage()
	return "shrine_256x210.png"
end

function GameUIAllianceShrineEnter:GetBuildingType()
	return 'shrine'
end

function GameUIAllianceShrineEnter:GetBuildingDesc()
	return "本地化缺失"
end

function GameUIAllianceShrineEnter:FixedUI()
	self:GetHonourIcon():hide()
	self:GetHonourLabel():hide()
	self.process_bar_bg:hide()
end

function GameUIAllianceShrineEnter:GetBuildingInfo()
	local events = _("未知")
    local running_event = _("未知")
    local people_count =   _("未知")
    if self:IsMyAlliance() then
	 	events = self:GetMyAlliance():GetAllianceShrine():GetShrineEvents()
		running_event = #events > 0 and events[1]:StageName() or _("暂无")
		people_count =   #events > 0 and  #events[1]:PlayerTroops() .. "/" .. events[1]:Stage():SuggestPlayer() or _("暂无")
	end
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
    local doing_event = {
        {_("正在进行的事件"),0x797154},
        {running_event,0x403c2f},
    } 
    local join_people = 
    {
	    {_("参与部队"),0x797154},
	    {people_count,0x403c2f},
    }
  	return {location,doing_event,join_people}
end

function GameUIAllianceShrineEnter:GetEnterButtons()
	if self:IsMyAlliance() then
		local fight_event_button = self:BuildOneButton("icon_info_1.png",_("战争事件")):onButtonClicked(function()
			UIKit:newGameUI('GameUIAllianceShrine',City,"fight_event",self:GetBuilding()):AddToCurrentScene(true)
			self:LeftButtonClicked()
		end)
		local alliance_shirine_event_button = self:BuildOneButton("icon_alliance_crisis.png",_("联盟危机")):onButtonClicked(function()
			 UIKit:newGameUI('GameUIAllianceShrine',City,"stage",self:GetBuilding()):AddToCurrentScene(true)
			self:LeftButtonClicked()
		end)
		local upgrade_button = self:BuildOneButton("icon_upgrade_1.png",_("升级")):onButtonClicked(function()
			UIKit:newGameUI('GameUIAllianceShrine',City,"upgrade",self:GetBuilding()):AddToCurrentScene(true)
			self:LeftButtonClicked()
		end)
	    return {fight_event_button,alliance_shirine_event_button,upgrade_button}
	else
		return {}
	end
end
return GameUIAllianceShrineEnter