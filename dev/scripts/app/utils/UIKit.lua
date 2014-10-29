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
    UIListView = import('..ui.UIListView'),
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
    return "Noto Sans S Chinese.otf"
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

function UIKit:ttfLabel( params )
    if not checktable(params) then
         printError("%s","params must a table")
    end
    params.font = UIKit:getFontFilePath()
    params.UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF
    if params.color then
        params.color = self:hex2c3b(params.color)
    end
    local label = cc.ui.UILabel.new(params)
    if params.shadow then
        label:enableShadow()
    end
    return label
end

function UIKit:convertColorToGL_( color )
    local r,g,b = self:hex2rgba(color)
    r = r/255
    g = g/255
    b = b/255
    return {r,g,b}
end


function UIKit:getImageByBuildingType( building_type ,level)
    print("建筑等级=",level)
    local level_1,level_2 = 6 ,16
    if building_type=="keep" then
        return "keep_760x855.png"
    elseif building_type=="dragonEyrie" then
        return "dragonEyrie_566x464.png"
    elseif building_type=="watchTower" then
        return "watchTower_445x638.png"
    elseif building_type=="warehouse" then
        return "warehouse_498x468.png"
    elseif building_type=="toolShop" then
        return "toolShop_1_521x539.png"
    elseif building_type=="materialDepot" then
        return "materialDepot_1_438x531.png"
    elseif building_type=="armyCamp" then
        return "armyCamp_485x444.png"
    elseif building_type=="barracks" then
        return "barracks_553x536.png"
    elseif building_type=="blackSmith" then
        return "blackSmith_1_442x519.png"
    elseif building_type=="foundry" then
        return "foundry_1_487x479.png"
    elseif building_type=="lumbermill" then
        return "lumbermill_1_495x423.png"
    elseif building_type=="mill" then
        return "mill_1_470x405.png"
    elseif building_type=="stoneMason" then
        return "stoneMason_1_423x486.png"
    elseif building_type=="hospital" then
        return "hospital_1_461x458.png"
    elseif building_type=="townHall" then
        return "townHall_1_524x553.png"
    elseif building_type=="tradeGuild" then
        return "tradeGuild_1_558x403.png"
    elseif building_type=="tower" then
        return "tower_head_78x124.png"
    elseif building_type=="wall" then
        return "gate_292x302.png"
    elseif building_type=="dwelling" then
        if level<level_1 then
            return "dwelling_1_297x365.png"
        elseif level<level_2 then
            return "dwelling_2_357x401.png"
        else
            return "dwelling_3_369x419.png"
        end
    elseif building_type=="woodcutter" then
        if level<level_1 then
            return "woodcutter_1_342x250.png"
        elseif level<level_2 then
            return "woodcutter_2_364x334.png"
        else
            return "woodcutter_3_351x358.png"
        end
    elseif building_type=="farmer" then
        if level<level_1 then
            return "farmer_1_315x281.png"
        elseif level<level_2 then
            return "farmer_2_312x305.png"
        else
            return "farmer_3_332x345.png"
        end
    elseif building_type=="quarrier" then
        if level<level_1 then
            return "quarrier_1_303x296.png"
        elseif level<level_2 then
            return "quarrier_2_347x324.png"
        else
            return "quarrier_3_363x386.png"
        end
    elseif building_type=="miner" then
        if level<level_1 then
            return "miner_1_315x309.png"
        elseif level<level_2 then
            return "miner_2_340x308.png"
        else
            return "miner_3_326x307.png"
        end
    end
end

function UIKit:shadowLayer()
    return display.newColorLayer(UIKit:hex2c4b(0x7a000000))
end
-- TODO: 玩家头像
function UIKit:GetPlayerCommonIcon()
    local heroBg = display.newSprite("chat_hero_background.png")
    local hero = display.newSprite("Hero_1.png"):align(display.CENTER, math.floor(heroBg:getContentSize().width/2), math.floor(heroBg:getContentSize().height/2)+5)
    hero:addTo(heroBg)
    return heroBg
end

function UIKit:GetTextListView(rect,label)
     local listView = self.UIListView.new {
        viewRect =  rect,
        direction = 0
    }

    local textItem = listView:newItem()
    textItem:addContent(label)
    textItem:setItemSize(rect.width,label:getContentSize().height)
    listView:addItem(textItem)
    listView:reload()
    return listView
end