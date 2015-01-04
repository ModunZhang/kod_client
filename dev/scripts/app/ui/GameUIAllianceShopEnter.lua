--
-- Author: Danny He
-- Date: 2014-12-29 16:10:25
--
local GameUIAllianceShopEnter = UIKit:createUIClass("GameUIAllianceShopEnter","GameUIAllianceShrineEnter")


function GameUIAllianceShopEnter:GetUIHeight()
	return 261
end

function GameUIAllianceShopEnter:GetUITitle()
	return _("商店")
end

function GameUIAllianceShopEnter:GetBuildingImage()
	return "shop_268x274.png"
end

function GameUIAllianceShopEnter:GetBuildingCategory()
	return 'shop'
end

function GameUIAllianceShopEnter:GetBuildingDesc()
	return "本地化缺失"
end


function GameUIAllianceShopEnter:GetBuildingInfo()
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
    local label_2 = {
        {_("高级道具数量"),0x797154},
        {"50",0x403c2f},
    } 
    local label_3 = 
    {
	    {_("有新的货物补充"),0x007c23}
    }
  	return {location,label_2,label_3}
end

function GameUIAllianceShopEnter:GetEnterButtons()
	local info_button = self:BuildOneButton("icon_info_1.png",_("商店记录")):onButtonClicked(function()
		UIKit:newGameUI('GameUIAllianceShop',City,"record",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)

	local stock_button = self:BuildOneButton("icon_stock.png",_("进货")):onButtonClicked(function()
		UIKit:newGameUI('GameUIAllianceShop',City,"stock",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
	local tax_button = self:BuildOneButton("icon_tax.png",_("购买商品")):onButtonClicked(function()
		UIKit:newGameUI('GameUIAllianceShop',City,"goods",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
	local upgrade_button = self:BuildOneButton("icon_upgrade_1.png",_("升级")):onButtonClicked(function()
		UIKit:newGameUI('GameUIAllianceShop',City,"upgrade",self:GetBuilding()):addToCurrentScene(true)
		self:leftButtonClicked()
	end)
    return {info_button,stock_button,tax_button,upgrade_button}
end

return GameUIAllianceShopEnter