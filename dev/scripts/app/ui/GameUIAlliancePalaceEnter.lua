--
-- Author: Danny He
-- Date: 2014-12-29 15:56:44
--
local GameUIAlliancePalaceEnter = UIKit:createUIClass("GameUIAlliancePalaceEnter","GameUIAllianceShrineEnter")

function GameUIAlliancePalaceEnter:GetUIHeight()
	return 261
end

function GameUIAlliancePalaceEnter:GetUITitle()
	return _("联盟宫殿")
end

function GameUIAlliancePalaceEnter:GetBuildingImage()
	return "palace_421x481.png"
end

function GameUIAlliancePalaceEnter:GetBuildingCategory()
	return 'palace'
end

function GameUIAlliancePalaceEnter:GetBuildingDesc()
	return _("联盟的核心建筑，升级可提升联盟人数上限，向占领城市征税，更改联盟地形。")
end


function GameUIAlliancePalaceEnter:GetBuildingInfo()
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
    local member_count,cities = _("未知"),_("未知")
    if self:IsMyAlliance() then
    	member_count = self:GetMyAlliance():GetMembersCount()
    	cities = 10 
    end
    local label_2 = {
        {_("成员"),0x797154},
        {member_count,0x403c2f},
    } 
    local label_3 = 
    {
	    {_("占领城市"),0x797154},
	    {cities,0x403c2f},
    }
  	return {location,label_2}
end

function GameUIAlliancePalaceEnter:GetEnterButtons()
	if self:IsMyAlliance() then
		local info_button = self:BuildOneButton("icon_info_1.png",_("信息")):onButtonClicked(function()
			UIKit:newGameUI('GameUIAlliancePalace',City,"info",self:GetBuilding()):AddToCurrentScene(true)
			self:LeftButtonClicked()
		end)
		local tax_button = self:BuildOneButton("icon_tax.png",_("奖励")):onButtonClicked(function()
			 UIKit:newGameUI('GameUIAlliancePalace',City,"impose",self:GetBuilding()):AddToCurrentScene(true)
			self:LeftButtonClicked()
		end)
		local upgrade_button = self:BuildOneButton("icon_upgrade_1.png",_("升级")):onButtonClicked(function()
			UIKit:newGameUI('GameUIAlliancePalace',City,"upgrade",self:GetBuilding()):AddToCurrentScene(true)
			self:LeftButtonClicked()
		end)
	    return {info_button,tax_button,upgrade_button}
	else
		return {}
	end
end

return GameUIAlliancePalaceEnter