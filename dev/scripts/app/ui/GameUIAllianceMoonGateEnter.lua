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
        {_("王城状态"),0x797154},
        {_("保护期"),0x403c2f},
    } 
    local label_3 = {
        {_("统治者"),0x797154},
        {_("黑龙军团"),0x403c2f},
    } 
    local label_4 = 
    {
	    {_("开启时间"),0x797154},
        {_("未知"),0x403c2f},
    }
  	return {location,label_2,label_3,label_4}
end

function GameUIAllianceMoonGateEnter:GetEnterButtons()
	if self:IsMyAlliance() then
		local info_button = self:BuildOneButton("icon_info_1.png",_("驻防部队")):onButtonClicked(function()
			UIKit:newGameUI('GameUIMoonGate',City,"garrison",self:GetBuilding()):addToCurrentScene(true)
			self:leftButtonClicked()
		end)

		local village_button = self:BuildOneButton("hit_icon.png",_("王城")):onButtonClicked(function()
			 UIKit:newGameUI('GameUIMoonGate',City,"king_city",self:GetBuilding()):addToCurrentScene(true)
			self:leftButtonClicked()
		end)
    	return {info_button,village_button}
    else
    	return {}
    end
end


return GameUIAllianceMoonGateEnter