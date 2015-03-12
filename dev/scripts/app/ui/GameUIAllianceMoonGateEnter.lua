--
-- Author: Kenny Dai
-- Date: 2015-01-14 20:37:32
--
local  GameUIAllianceMoonGateEnter = UIKit:createUIClass("GameUIAllianceMoonGateEnter","GameUIAllianceShrineEnter")


function GameUIAllianceMoonGateEnter:GetUIHeight()
	return 282
end

function GameUIAllianceMoonGateEnter:GetUITitle()
	return _("月门")
end

function GameUIAllianceMoonGateEnter:GetBuildingImage()
	return "moonGate_200x217.png"
end

function GameUIAllianceMoonGateEnter:GetBuildingCategory()
	return 'orderHall'
end

function GameUIAllianceMoonGateEnter:GetBuildingDesc()
	return "本地化缺失"
end


function GameUIAllianceMoonGateEnter:GetBuildingInfo()
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
    local label_2 = {
        {_("开战的王城"),0x797154},
        {_("未知"),0x403c2f},
    } 
    local label_3 = {
        {_("占领者"),0x797154},
        {_("未知"),0x403c2f},
    } 
    local label_4 = 
    {
	    {_("状态"),0x797154},
        {_("未开启"),0x403c2f},
    }
  	return {location,label_2,label_3,label_4}
end

function GameUIAllianceMoonGateEnter:GetEnterButtons()
	if self:IsMyAlliance() then
		local village_button = self:BuildOneButton("hit_icon_29x32.png",_("王城")):onButtonClicked(function()
			 UIKit:newGameUI('GameUIMoonGate',City,"",self:GetBuilding()):addToCurrentScene(true)
			self:leftButtonClicked()
		end)
    	return {village_button}
    else
    	return {}
    end
end


return GameUIAllianceMoonGateEnter