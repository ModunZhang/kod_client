--
-- Author: dannyhe
-- Date: 2014-08-01 08:46:35
--
-- 封装常用ui工具
import(".bit")
UIKit =
    {
        Registry   = import('framework.cc.Registry'),
        GameUIBase = import('..ui.GameUIBase'),
    }
local CURRENT_MODULE_NAME = ...


function UIKit:createUIClass(className, baseName)
    return class(className, baseName == nil and self["GameUIBase"] or import('..ui.' .. baseName,CURRENT_MODULE_NAME))
end

function UIKit:newGameUI(gameUIName,... )
    if self.Registry.isObjectExists(gameUIName) then
        print("已经创建过一个Object-->",gameUIName)
        return {addToCurrentScene=function(...)end,addToScene=function(...)end} -- 适配后面的调用不报错
    end
    local viewPackageName = app.packageRoot .. ".ui." .. gameUIName
    local viewClass = require(viewPackageName)
    local instance = viewClass.new(...)
    self.Registry.setObject(instance,gameUIName)
    return instance
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
    -- print(string.format("hex2rgba:%x --> %d %d %d %d",hexNum,r,g,b,a))
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

function UIKit:commonProgressTimer(png)
    local progressFill = display.newSprite(png)
    local ProgressTimer = cc.ProgressTimer:create(progressFill)
    ProgressTimer:setType(display.PROGRESS_TIMER_BAR)
    ProgressTimer:setBarChangeRate(cc.p(1,0))
    ProgressTimer:setMidpoint(cc.p(0,0))
    ProgressTimer:setPercentage(0)
    return ProgressTimer
end

function UIKit:getRegistry()
    return self.Registry
end

function UIKit:getImageByBuildingType( building_type ,level)
    print("建筑等级=",level)
    local level_1,level_2 = 6 ,16
    if building_type=="keep" then
        return "keep_616x855.png"
    elseif building_type=="dragonEyrie" then
        return "dragonEyrie_564x558.png"
    elseif building_type=="watchTower" then
        return "watchTower_263x638.png"
    elseif building_type=="warehouse" then
        return "warehouse_454x468.png"
    elseif building_type=="toolShop" then
        return "toolShop_1_465x539.png"
    elseif building_type=="materialDepot" then
        return "materialDepot_1_436x531.png"
    elseif building_type=="armyCamp" then
        return "armyCamp_485x444.png"
    elseif building_type=="barracks" then
        return "barracks_472x536.png"
    elseif building_type=="blackSmith" then
        return "blackSmith_1_424x519.png"
    elseif building_type=="foundry" then
        return "foundry_1_475x479.png"
    elseif building_type=="lumbermill" then
        return "lumbermill_1_454x423.png"
    elseif building_type=="mill" then
        return "mill_1_432x405.png"
    elseif building_type=="stoneMason" then
        return "stoneMason_1_461x486.png"
    elseif building_type=="hospital" then
        return "hospital_1_367x458.png"
    elseif building_type=="townHall" then
        return "townHall_1_464x553.png"
    elseif building_type=="tradeGuild" then
        return "tradeGuild_1_558x403.png"
    elseif building_type=="tower" then
        return "tower_head_78x124.png"
    elseif building_type=="wall" then
        return "gate_292x302.png"
    elseif building_type=="dwelling" then
        if level<level_1 then
            return "dwelling_1_290x365.png"
        elseif level<level_2 then
            return "dwelling_2_318x401.png"
        else
            return "dwelling_3_320x419.png"
        end
    elseif building_type=="woodcutter" then
        if level<level_1 then
            return "woodcutter_1_312x250.png"
        elseif level<level_2 then
            return "woodcutter_2_299x334.png"
        else
            return "woodcutter_3_302x358.png"
        end
    elseif building_type=="farmer" then
        if level<level_1 then
            return "farmer_1_306x280.png"
        elseif level<level_2 then
            return "farmer_2_303x305.png"
        else
            return "farmer_3_314x345.png"
        end
    elseif building_type=="quarrier" then
        if level<level_1 then
            return "quarrier_1_267x295.png"
        elseif level<level_2 then
            return "quarrier_2_307x324.png"
        else
            return "quarrier_3_294x386.png"
        end
    elseif building_type=="miner" then
        if level<level_1 then
            return "miner_1_258x309.png"
        elseif level<level_2 then
            return "miner_2_285x308.png"
        else
            return "miner_3_284x307.png"
        end
    end
end





