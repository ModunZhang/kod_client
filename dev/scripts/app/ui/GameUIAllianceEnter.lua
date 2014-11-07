local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")

local GameUIAllianceEnter = class("GameUIAllianceEnter", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

local ENTER_LIST = {
    palace = {
        height = 261,
        title = _("联盟宫殿"),
        building_image = "palace_421x481.png",
        building_desc = _("联盟的核心建筑，升级可提升联盟人数上限，向占领城市征税，更改联盟地形。"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("成员"),0x797154},
                {_("25/30"),0x403c2f},
            },
            {
                {_("占领城市"),0x797154},
                {_("44"),0x403c2f},
            },
        },
        enter_buttons = {
            {
                img = "icon_info.png",
                title = _("信息"),
                func = function (building)
                    UIKit:newGameUI('GameUIAlliancePalace',City,"info",building):addToCurrentScene(true)
                end
            },
            {
                img = "icon_tax.png",
                title = _("收税"),
                func = function (building)
                    UIKit:newGameUI('GameUIAlliancePalace',City,"impose",building):addToCurrentScene(true)
                end
            },
            {
                img = "icon_upgrade.png",
                title = _("升级"),
                func = function (building)
                    UIKit:newGameUI('GameUIAlliancePalace',City,"upgarde",building):addToCurrentScene(true)
                end
            },
        },
    },
    shop = {
        height = 261,
        title = _("商店"),
        building_image = "shop_268x274.png",
        building_desc = _("本地化缺失"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("高级道具数量"),0x797154},
                {_("25/30"),0x403c2f},
            },
            {
                {_("有新的货物补充"),0x007c23},
            },
        },
        enter_buttons = {
            {
                img = "icon_info.png",
                title = _("商店记录"),
                func = function (building)
                    UIKit:newGameUI('GameUIAllianceShop',City,"record",building):addToCurrentScene(true)
                end
            },
            {
                img = "icon_stock.png",
                title = _("进货"),
                func = function (building)
                    UIKit:newGameUI('GameUIAllianceShop',City,"stock",building):addToCurrentScene(true)
                end
            },
            {
                img = "icon_tax.png",
                title = _("购买商品"),
                func = function (building)
                    UIKit:newGameUI('GameUIAllianceShop',City,"goods",building):addToCurrentScene(true)
                end
            },
            {
                img = "icon_upgrade.png",
                title = _("升级"),
                func = function (building)
                    UIKit:newGameUI('GameUIAllianceShop',City,"upgarde",building):addToCurrentScene(true)
                end
            },
        },
    },
    orderHall = {
        height = 261,
        title = _("秩序大厅"),
        building_image = "orderHall_277x417.png",
        building_desc = _("本地化缺失"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("当前村落数量"),0x797154},
                {_("暂无"),0x403c2f},
            },
            {
                {_("当前采集村落"),0x797154},
                {_("暂无"),0x403c2f},
            },
        },
        enter_buttons = {
            {
                img = "icon_info.png",
                title = _("熟练度"),
                func = function (building)
                    UIKit:newGameUI('GameUIOrderHall',City,"proficiency",building):addToCurrentScene(true)
                end
            },
            {
                img = "icon_village.png",
                title = _("村落管理"),
                func = function (building)
                    UIKit:newGameUI('GameUIOrderHall',City,"village",building):addToCurrentScene(true)
                end
            },
            {
                img = "icon_upgrade.png",
                title = _("升级"),
                func = function (building)
                    UIKit:newGameUI('GameUIOrderHall',City,"upgarde",building):addToCurrentScene(true)
                end
            },
        },
    },
}

function GameUIAllianceEnter:ctor(building)
    self:setNodeEventEnabled(true)
    self.building = building
    self.params = ENTER_LIST[building.name]
    assert(ENTER_LIST[building.name],"联盟建筑配置为空")
    self.alliance = Alliance_Manager:GetMyAlliance()
    self:SetBuildingInfo()
    self.body = self:CreateBackGroundWithTitle(self.params)
        :align(display.CENTER, window.cx, window.top -400)
        :addTo(self)
    self:InitBuildingImage()
    self:InitBuildingDese()
    self:InitBuildingInfo(self.params.building_info)
    self:InitEnterButton(self.params.enter_buttons)
end

function GameUIAllianceEnter:SetBuildingInfo()
    local building = self.building
    local name = self.building.name
    local info = ENTER_LIST[name].building_info
    info[1][2][1] = building.location.x..","..building.location.y
    if name == "palace" then
        info[2][2][1] = self.alliance:MemberCount()
        info[3][2][1] = _("暂无")
    elseif name == "shop" then
        info[2][2][1] = _("暂无")
    elseif name == "orderHall" then
    end
end

function GameUIAllianceEnter:InitBuildingDese()
    local p = self.params
    if p.building_desc then
        -- building desc
        self.desc_label = UIKit:ttfLabel({
            text = p.building_desc,
            size = 18,
            color = 0x797154,
            dimensions = cc.size(400,0)
        }):align(display.LEFT_TOP, 180, p.height-20)
            :addTo(self.body)
    end
end

function GameUIAllianceEnter:InitBuildingInfo(info)
    local original_y = self.desc_label:getPositionY()-self.desc_label:getContentSize().height-40
    local gap_y = 40
    local info_count = 0
    for k,v in pairs(info) do
        self:CreateItemWithLine(v)
            :align(display.CENTER, 380, original_y - gap_y*info_count)
            :addTo(self.body)
        info_count = info_count + 1
    end
end

function GameUIAllianceEnter:CreateItemWithLine(params)
    local line = display.newSprite("dividing_line.png")
    local size = line:getContentSize()
    UIKit:ttfLabel({
        text = params[1][1],
        size = 20,
        color = params[1][2],
    }):align(display.LEFT_BOTTOM, 0, 6)
        :addTo(line)
    if params[2] then
        UIKit:ttfLabel({
            text = params[2][1],
            size = 20,
            color = params[2][2],
        }):align(display.RIGHT_BOTTOM, size.width, 6)
            :addTo(line)
    end
    return line
end

function GameUIAllianceEnter:CreateBackGroundWithTitle( params )
    local body = WidgetUIBackGround.new({height=params.height}):align(display.TOP_CENTER,display.cx,display.top-200)
    local rb_size = body:getContentSize()
    local title = display.newSprite("report_title.png"):align(display.CENTER, rb_size.width/2, rb_size.height+5)
        :addTo(body)
    local title_label = UIKit:ttfLabel({
        text = params.title,
        size = 22,
        color = 0xffedae,
    }):align(display.CENTER, title:getContentSize().width/2, title:getContentSize().height/2+2)
        :addTo(title)
    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent(true)
            end
        end):align(display.CENTER, rb_size.width-20,rb_size.height+10):addTo(body)
    self.close_btn:addChild(display.newSprite("X_3.png"))
    return body
end

function GameUIAllianceEnter:InitBuildingImage()
    local p = self.params
    local body = self.body
    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.LEFT_CENTER, 30, p.height-90)
        :addTo(body):flipX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.RIGHT_CENTER, 163, p.height-90)
        :addTo(body)

    local building_image = display.newSprite(p.building_image)
        :addTo(body):pos(105, p.height-60)
    building_image:setAnchorPoint(cc.p(0.5,0.5))
    building_image:setScale(125/building_image:getContentSize().width)
    local level_bg = display.newSprite("back_ground_138x34.png")
        :addTo(body):pos(96, p.height-180)
    UIKit:ttfLabel({
        text = _("Level").." "..self.building.level,
        size = 20,
        color = 0x514d3e,
    }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height/2)
        :addTo(level_bg)
end

function GameUIAllianceEnter:InitEnterButton(buttons)
    local width = 608
    local btn_width = 130
    local count = 0
    for k,v in pairs(buttons) do
        local btn = WidgetPushButton.new({normal = "btn_130X104.png",pressed = "btn_pressed_130X104.png"})
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    v.func(self.building)
                    self:removeFromParent(true)
                end
            end):align(display.RIGHT_TOP,width-count*btn_width, 5):addTo(self.body)
        local s = btn:getCascadeBoundingBox().size
        display.newSprite(v.img):align(display.CENTER, -s.width/2, -s.height/2+22):addTo(btn)
        UIKit:ttfLabel({
            text = v.title,
            size = 18,
            color = 0xffedae,
        }):align(display.CENTER, -s.width/2 , -s.height+25)
            :addTo(btn)
        count = count + 1
    end
end

function GameUIAllianceEnter:addToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end
function GameUIAllianceEnter:onExit()
    UIKit:getRegistry().removeObject(self.__cname)
end

return GameUIAllianceEnter















