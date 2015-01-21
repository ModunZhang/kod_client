--
-- Author: Kenny Dai
-- Date: 2015-01-17 10:33:17
--
local window = import("..utils.window")
local WidgetProgress = import(".WidgetProgress")
local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetPushButton = import(".WidgetPushButton")
local WidgetUpgradeMilitaryTech = import(".WidgetUpgradeMilitaryTech")
local SoldierManager = import("..entity.SoldierManager")
local Localize = import("..utils.Localize")

local function create_line_item(icon,text_1,text_2)
    local line = display.newScale9Sprite("divide_line_489x2.png", 0, 0,cc.size(384,2),cc.rect(10,1,364,1))
    local icon = display.newSprite(icon):addTo(line,2):align(display.LEFT_BOTTOM, 0, 0)
    local text1 = UIKit:ttfLabel({
        text = text_1,
        size = 20,
        color = 0x797154,
    }):align(display.LEFT_BOTTOM, 50 , 0)
        :addTo(line)
    local text2 = UIKit:ttfLabel({
        text = text_2,
        size = 22,
        color = 0x403c2f,
    }):align(display.RIGHT_BOTTOM, 384 , 0)
        :addTo(line)

    function line:SetText(text)
        text2:setString(text)
    end

    return line
end

local WidgetMilitaryTechnology = class("WidgetMilitaryTechnology", function ()
    local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0, 0,568, 560),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list_node.listview = list
    list_node:setNodeEventEnabled(true)
    return list_node
end)

function WidgetMilitaryTechnology:ctor(building)
    self.building = building

    local techs = City:GetSoldierManager():FindMilitaryTechsByBuildingType(self.building:GetType())
    self.items_list = {}
    for k,v in pairs(techs) do
        self.items_list[k] =  self:CreateItem(v)
    end
    self.listview:reload()
end

function WidgetMilitaryTechnology:CreateItem(tech)
    local list = self.listview
    local item = list:newItem()
    local item_width,item_height = 568,150
    item:setItemSize(item_width,item_height)
    list:addItem(item)

    local content = WidgetUIBackGround.new({width = item_width,height = item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)
    item:addContent(content)

    local title_bg = display.newScale9Sprite("title_blue_430x30.png",item_width/2,item_height-25,cc.size(550,30),cc.rect(15,10,400,10))
        :addTo(content)
    local temp = UIKit:ttfLabel({
        text = string.format(_("对%s的攻击"),Localize.soldier_category[string.split(tech:Name(), "_")[2]]) ,
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 20 , title_bg:getContentSize().height/2)
        :addTo(title_bg)
    local tech_level = UIKit:ttfLabel({
        text = string.format("Lv%d",tech:Level()) ,
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, temp:getPositionX()+temp:getContentSize().width+20 , title_bg:getContentSize().height/2)
        :addTo(title_bg)

    local upgrade_btn = WidgetPushButton.new({normal = "blue_btn_up_148x58.png",pressed = "blue_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({
            text = _("研发"),
            size = 22,
            color = 0xffedae,
            shadow = true
        })):onButtonClicked(function (event)
        WidgetUpgradeMilitaryTech.new(tech):addToCurrentScene()
        end)
        :align(display.CENTER, item_width-90, 44):addTo(content)


    local soldiers = string.split(tech:Name(), "_")
    local soldier_category = Localize.soldier_category
    local line1 = create_line_item("icon_hit.png",tech:GetTechLocalize(),"+"..tech:GetAtkEff().."%"):addTo(content):align(display.LEFT_CENTER, 10, 60)
    local line2 = create_line_item("icon_teac.png",tech:GetTechCategory(),"+"..tech:GetTechPoint()):addTo(content):align(display.LEFT_CENTER, 10, 20)

    function item:LevelUpRefresh(tech)
        tech_level:setString(string.format("Lv%d",tech:Level()))
        line1:SetText("+"..tech:GetAtkEff().."%")
        line2:SetText("+"..tech:GetTechPoint())
    end
    return item
end
function WidgetMilitaryTechnology:onEnter()
    City:GetSoldierManager():AddListenOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_DATA_CHANGED)
end
function WidgetMilitaryTechnology:onExit()
    City:GetSoldierManager():RemoveListenerOnType(self,SoldierManager.LISTEN_TYPE.MILITARY_TECHS_DATA_CHANGED)
end
function WidgetMilitaryTechnology:OnMilitaryTechsDataChanged(city,changed_map)
    for k,v in pairs(changed_map) do
        print("OnMilitaryTechsDataChanged",k,self.items_list[k])
        if self.items_list[k] then
            self.items_list[k]:LevelUpRefresh(v)
        end
    end
end
return WidgetMilitaryTechnology



