--
-- Author: Danny He
-- Date: 2014-12-29 11:32:56
--
local GameUIAllianceShrineEnter = UIKit:createUIClass("GameUIAllianceShrineEnter","GameUIAllianceEnterBase")

function GameUIAllianceShrineEnter:ctor(building,alliance)
	GameUIAllianceShrineEnter.super.ctor(self,building,alliance)
	self.building = building:GetAllianceBuildingInfo()
end

function GameUIAllianceShrineEnter:GetLocation()
	return self:GetBuilding().location.x .. "," .. self:GetBuilding().location.y
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

function GameUIAllianceShrineEnter:GetBuildingCategory()
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
	 local events = self:GetMyAlliance():GetAllianceShrine():GetShrineEvents()
        local running_event = #events > 0 and events[1]:StageName() or _("暂无")
        local people_count =   #events > 0 and  #events[1]:PlayerTroops() .. "/" .. events[1]:Stage():SuggestPlayer() or _("暂无")
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
	local fight_event_button = self:BuildOneButton("icon_info_1.png",_("战争事件")):onButtonClicked(function()
		UIKit:newGameUI('GameUIAllianceShrine',City,"fight_event",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
	local alliance_shirine_event_button = self:BuildOneButton("icon_alliance_crisis.png",_("联盟危机")):onButtonClicked(function()
		 UIKit:newGameUI('GameUIAllianceShrine',City,"stage",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
	local upgrade_button = self:BuildOneButton("icon_upgrade_1.png",_("升级")):onButtonClicked(function()
		UIKit:newGameUI('GameUIAllianceShrine',City,"upgrade",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
    return {fight_event_button,alliance_shirine_event_button,upgrade_button}
end
return GameUIAllianceShrineEnter