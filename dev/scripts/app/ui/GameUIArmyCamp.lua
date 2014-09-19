
local TabButtons = import('.TabButtons')
local UIListView = import('.UIListView')
local WidgetSoldierDetails = import('..widget.WidgetSoldierDetails')
local WidgetSoldierBox = import('..widget.WidgetSoldierBox')
local GameUIArmyCamp = UIKit:createUIClass('GameUIArmyCamp',"GameUIUpgradeBuilding")

function GameUIArmyCamp:ctor(city,building)
    GameUIArmyCamp.super.ctor(self,city,_("军用帐篷"),building)
end

function GameUIArmyCamp:CreateBetweenBgAndTitle()
    GameUIArmyCamp.super.CreateBetweenBgAndTitle(self)

    -- 加入军用帐篷info_layer
    self.info_layer = display.newLayer()
    self:addChild(self.info_layer)
end

function GameUIArmyCamp:onEnter()
    GameUIArmyCamp.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "info",
        },
    },{
        ["info"] = self.info_layer
    }):pos(display.cx, display.bottom + 40)

    self:CreateTopPart()
    self:CresteSoldiersListView()
    -- self:OpenSoldierDetails()
end

function GameUIArmyCamp:CreateTopPart()
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("Total Troops Population"),
            font = UIKit:getFontFilePath(),
            size = 18,
            color = UIKit:hex2c3b(0x665f49)
        }):align(display.LEFT_CENTER, display.cx-260, display.top-130)
        :addTo(self.info_layer)
    -- Total Troops Population 当前数值
    self.total_troops =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("120000"),
            font = UIKit:getFontFilePath(),
            size = 22,
            color = UIKit:hex2c3b(0x29261c)
        }):align(display.LEFT_CENTER, display.cx-260, display.top-160)
        :addTo(self.info_layer)
    -- 维护费部分
    display.newSprite("food_icon.png", display.cx+160, display.top-145):addTo(self.info_layer):setScale(0.5)
    cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("维护费"),
            font = UIKit:getFontFilePath(),
            size = 18,
            color = UIKit:hex2c3b(0x7f775f)
        }):align(display.RIGHT_CENTER, display.cx+260, display.top-130)
        :addTo(self.info_layer)
    self.maintenance_cost = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = "-12099",
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x930000)
        }):align(display.RIGHT_CENTER, display.cx+260, display.top-160)
        :addTo(self.info_layer)

    -- 分割线显示部分
    -- 构造分割线显示信息方法
    local function createTipItem(prams)
        -- 分割线
        local line = display.newScale9Sprite("dividing_line.png",prams.x, prams.y, cc.size(520,2))

        -- title
        cc.ui.UILabel.new(
            {
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = prams.title,
                font = UIKit:getFontFilePath(),
                size = 20,
                color = prams.title_color
            }):align(display.LEFT_CENTER, 0, 12)
            :addTo(line)
        -- title value
        line.value = cc.ui.UILabel.new(
            {
                UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                text = prams.value,
                font = UIKit:getFontFilePath(),
                size = 20,
                color = prams.value_color
            }):align(display.RIGHT_CENTER, line:getCascadeBoundingBox().size.width, 12)
            :addTo(line)
        return line
    end

    -- 空闲部队人口
    self.free_troops = createTipItem({
        title = _("空闲部队人口"),
        title_color = UIKit:hex2c3b(0x797154),
        value = 1005 ,
        value_color = UIKit:hex2c3b(0x403c2f),
        x = display.cx,
        y = display.top - 220
    }):addTo(self.info_layer)
    -- 驻防部队人口
    self.garrison_troops = createTipItem({
        title = _("驻防部队人口"),
        title_color = UIKit:hex2c3b(0x797154),
        value = 475000 ,
        value_color = UIKit:hex2c3b(0x403c2f),
        x = display.cx,
        y = display.top - 260
    }):addTo(self.info_layer)
end

-- BEGIN set 各项数值方法
-- 部队总人口
function GameUIArmyCamp:SetTotalTroopsPop()
    self.total_troops:setString()
end
-- 维护费
function GameUIArmyCamp:SetMaintenanceCost()
    self.maintenance_cost:setString()
end
-- 空闲部队人口
function GameUIArmyCamp:SetFreeTroopsPop()
    self.free_troops:setString()
end
-- 驻防部队总人口
function GameUIArmyCamp:SetGarrisonTroopsPop()
    self.garrison_troops:setString()
end
--END set 各项数值方法

function GameUIArmyCamp:OpenSoldierDetails()
    self.soldier_details_layer = WidgetSoldierDetails.new()
    self:addChild(self.soldier_details_layer)
end

function GameUIArmyCamp:CresteSoldiersListView()
    self.soldiers_listview = UIListView.new{
        -- bgColor = cc.c4b(200, 200, 0, 170),
        bgScale9 = true,
        viewRect = cc.rect(display.cx-274, display.top-870, 547, 600),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self.info_layer)
    local item = self:CreateItemWithListView(self.soldiers_listview)
    self.soldiers_listview:addItem(item)
    local item = self:CreateItemWithListView(self.soldiers_listview)
    self.soldiers_listview:addItem(item)
    local item = self:CreateItemWithListView(self.soldiers_listview)
    self.soldiers_listview:addItem(item)
    local item = self:CreateItemWithListView(self.soldiers_listview)
    self.soldiers_listview:addItem(item)
    self.soldiers_listview:reload()
end

function GameUIArmyCamp:CreateItemWithListView(list_view)
    local rect = list_view:getViewRect()
    local origin_x = - rect.width / 2
    -- local widget_rect = self.widget:getBoundingBox()
    local unit_width = 130
    local gap_x = (547 - unit_width * 4) / 3
    local row_item = display.newNode()


    for i = 1, 4 do
        WidgetSoldierBox.new("soldier_130x183.png",function (  )
            self:OpenSoldierDetails()
        end):addTo(row_item)
        :alignByPoint(cc.p(0.5,0.4), origin_x + (unit_width + gap_x) * (i - 1) + unit_width / 2, 0)
        :SetNumber(999)
    end
    local item = list_view:newItem()
    item:addContent(row_item)
    item:setItemSize(547, 170)


    return item
end

return GameUIArmyCamp













