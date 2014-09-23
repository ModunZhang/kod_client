--
-- Author: dannyhe
-- Date: 2014-08-01 08:46:35
--
-- 封装常用ui工具
import(".bit")
UIKit = 
{
    GameUIBase = import('..ui.GameUIBase'),
}
local CURRENT_MODULE_NAME = ...


function UIKit:createUIClass(className, baseName)
	return class(className, baseName == nil and self["GameUIBase"] or import('..ui.' .. baseName,CURRENT_MODULE_NAME))
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
--通过type获取建筑或者小屋的本地化名称
function UIKit:getLocaliedKeyByType(type)
    local house_config = GameDatas.Houses.houses
    if house_config[type] then
        return self:getHouseLocalizedKeyByBuildingType(type)
    else
        return self:getBuildingLocalizedKeyByBuildingType(type)
    end
end

function UIKit:hex2rgba(hexNum)
    local a = bit:_rshift(hexNum,24)
    if a < 0 then
        a = a + 0x100
    end
    local r = bit:_and(bit:_rshift(hexNum,16),0xff)
    local g = bit:_and(bit:_rshift(hexNum,8),0xff)
    local b = bit:_and(hexNum,0xff)
    print(string.format("hex2rgba:%x --> %d %d %d %d",hexNum,r,g,b,a))
    return r,g,b,a
end

function UIKit:hex2c3b(hexNum)
    local r,g,b = self:hex2rgba(hexNum)
    return cc.c3b(r,g,b)
end

function UIKit:hex2c4b(hexNum)
    local r,g,b,a = self:hex2rgba(hexNum)
    return cc.c4b(r,g,b,a)
end


function UIKit:debugNode(node,name)
    name = name or " "
    printf("\n:::%s---------------------\n",name)
    printf("AnchorPoint---->%d,%d\n",node:getAnchorPoint().x,node:getAnchorPoint().y)
    printf("Position---->%d,%d\n",node:getPositionX(),node:getPositionY())
    printf("Size---->%d,%d\n",node:getContentSize().width,node:getContentSize().height)
end
