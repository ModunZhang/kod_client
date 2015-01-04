--
-- Author: Danny He
-- Date: 2014-12-29 16:18:19
--
local  GameUIAllianceOrderHallEnter = UIKit:createUIClass("GameUIAllianceOrderHallEnter","GameUIAllianceShrineEnter")


function GameUIAllianceOrderHallEnter:GetUIHeight()
	return 261
end

function GameUIAllianceOrderHallEnter:GetUITitle()
	return _("秩序大厅")
end

function GameUIAllianceOrderHallEnter:GetBuildingImage()
	return "orderHall_277x417.png"
end

function GameUIAllianceOrderHallEnter:GetBuildingCategory()
	return 'orderHall'
end

function GameUIAllianceOrderHallEnter:GetBuildingDesc()
	return "本地化缺失"
end


function GameUIAllianceOrderHallEnter:GetBuildingInfo()
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
    local label_2 = {
        {_("当前村落数量"),0x797154},
        {"50",0x403c2f},
    } 
    local label_3 = 
    {
	    {_("当前采集村落"),0x797154},
        {_("暂无"),0x403c2f},
    }
  	return {location,label_2,label_3}
end

function GameUIAllianceOrderHallEnter:GetEnterButtons()
	local info_button = self:BuildOneButton("icon_info_1.png",_("熟练度")):onButtonClicked(function()
		UIKit:newGameUI('GameUIOrderHall',City,"proficiency",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)

	local village_button = self:BuildOneButton("icon_village.png",_("村落管理")):onButtonClicked(function()
		 UIKit:newGameUI('GameUIOrderHall',City,"village",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
	local upgrade_button = self:BuildOneButton("icon_upgrade_1.png",_("升级")):onButtonClicked(function()
		 UIKit:newGameUI('GameUIOrderHall',City,"upgrade",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
    return {info_button,village_button,upgrade_button}
end


return GameUIAllianceOrderHallEnter