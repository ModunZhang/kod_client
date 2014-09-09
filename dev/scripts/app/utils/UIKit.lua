--
-- Author: dannyhe
-- Date: 2014-08-01 08:46:35
--
-- 封装常用ui工具

UIKit = 
{
	GameUIBase = import('..ui.GameUIBase'),
}

function UIKit:createUIClass(className)
	return class(className, self.GameUIBase)
end

function UIKit:newGameUI(gameUIName,... )
	local viewPackageName = app.packageRoot .. ".ui." .. gameUIName
    local viewClass = require(viewPackageName)
    return viewClass.new(...)
end

function UIKit:getFontFilePath()
    return "res/fonts/Noto Sans S Chinese.otf"
end

function UIKit:getBuildingLocalizedKeyByBuildingType(type)
    local building_config = GameDatas.Buildings.buildings
    for _,v in ipairs(building_config) do
        if v.type == type then
            return v.desc
        end
    end
    return "buidling localized string not found"
end

function UIKit:getHouseLocalizedKeyByBuildingType(type)
    local house_config = GameDatas.Houses.houses
    for _,v in pairs(house_config) do
        if v.type == type then
            return v.desc
        end
    end
    return "house localized string not found"
end

function UIKit:getLocaliedKeyByType(type)
    local house_config = GameDatas.Houses.houses
    if house_config[type] then
        return self:getHouseLocalizedKeyByBuildingType(type)
    else
        return self:getBuildingLocalizedKeyByBuildingType(type)
    end
end