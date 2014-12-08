--
-- Author: dannyhe
-- Date: 2014-08-01 08:46:35
--
-- 封装常用ui工具
import(".bit")
local promise = import(".promise")
UIKit =
    {
        Registry   = import('framework.cc.Registry'),
        GameUIBase = import('..ui.GameUIBase'),
    }
local CURRENT_MODULE_NAME = ...

UIKit.open_ui_callbacks = {}

function UIKit:PromiseOfOpen(ui_name)
    local callbacks = self.open_ui_callbacks
    assert(#callbacks == 0)
    local p = promise.new()
    table.insert(callbacks, function(ui)
        if ui_name == ui.__cname then
            p:resolve(ui)
            return true
        end
    end)
    return p
end
function UIKit:CheckOpenUI(ui)
    local callbacks = self.open_ui_callbacks
    if #callbacks > 0 and callbacks[1](ui) then
        table.remove(callbacks, 1)
    end
end
function UIKit:ClearPromise()
    self.open_ui_callbacks = {}
end

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
    return "Droid Sans Faliback.ttf"
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
--[[
    参数和quick原函数一样
新属性-->
    color:hex 颜色值
    shadow:bool 是否用阴影
    margin:number 单个字水平间距
    lineHeight: number 行高(多行)
    bold:bool 加粗
]]--
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
    if params.margin then
        label:setAdditionalKerning(params.margin)
    end
    -- if params.bold then
    --     params.boldSize = 1
    -- else
    --     params.boldSize = 0
    -- end
    -- printInfo("%s","字体加粗-->" .. params.boldSize)
    if params.lineHeight and params.dimensions then
        label:setLineHeight(params.lineHeight)
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
    local level_1,level_2 = 2 ,3
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
        return "hospital_1_392x472.png"
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
    elseif building_type=="moonGate" then
        return "moonGate_200x217.png"
    elseif building_type=="orderHall" then
        return "orderHall_277x417.png"
    elseif building_type=="palace" then
        return "palace_421x481.png"
    elseif building_type=="shop" then
        return "shop_268x274.png"
    elseif building_type=="shrine" then
        return "shrine_256x210.png"
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
--TODO:将这个函数替换成CreateBoxPanel9来实现
function UIKit:CreateBoxPanel(height)
    local node = display.newNode()
    local bottom = display.newSprite("alliance_box_bottom_552x12.png")
        :addTo(node)
        :align(display.LEFT_BOTTOM,0,0)
    local top =  display.newSprite("alliance_box_top_552x12.png")
    local middleHeight = height - bottom:getContentSize().height - top:getContentSize().height
    local next_y = bottom:getContentSize().height
    while middleHeight > 0 do
        local middle = display.newSprite("alliance_box_middle_552x1.png")
            :addTo(node)
            :align(display.LEFT_BOTTOM,0, next_y)
        middleHeight = middleHeight - middle:getContentSize().height
        next_y = next_y + middle:getContentSize().height
    end
    top:addTo(node)
        :align(display.LEFT_BOTTOM,0,next_y)
    return node
    
end

function UIKit:CreateBoxPanel9(params)
    local common_bg = display.newScale9Sprite("gray_box_574x102.png")
    common_bg:setCapInsets(cc.rect(8,8,556,78))
    common_bg:setAnchorPoint(cc.p(0,0))
    common_bg:size(params.width and params.width or 552,params.height)
    return common_bg
end

function UIKit:commonButtonLable(params)
    if not params then params = {} end
    params.color = params.color or 0xffedae
    params.size  = params.size or 24
    params.shadow = true
    return UIKit:ttfLabel(params)
end

function UIKit:commonTitleBox(height)
    local node = display.newNode()
    local bottom = display.newSprite("title_box_bottom_540x18.png")
        :addTo(node)
        :align(display.LEFT_BOTTOM,4,0)
    local top =  display.newSprite("title_box_top_548x58.png")
    local middleHeight = height - bottom:getContentSize().height - top:getContentSize().height
    local next_y = bottom:getContentSize().height
    while middleHeight > 0 do
        local middle = display.newSprite("title_box_middle_540x1.png")
            :addTo(node)
            :align(display.LEFT_BOTTOM,4, next_y)
        middleHeight = middleHeight - middle:getContentSize().height
        next_y = next_y + middle:getContentSize().height
    end
    top:addTo(node):align(display.LEFT_BOTTOM,0,next_y)
    return node
end

function UIKit:closeButton()
    local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
    return closeButton
end
