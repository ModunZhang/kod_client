local UIListView = import(".UIListView")
local window = import("..utils.window")
local WidgetMaterialBox = import("..widget.WidgetMaterialBox")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetMaterialDetails = import("..widget.WidgetMaterialDetails")
local MaterialManager = import("..entity.MaterialManager")


local GameUIMaterialDepot = UIKit:createUIClass("GameUIMaterialDepot", "GameUIUpgradeBuilding")
function GameUIMaterialDepot:ctor(city,building)
    GameUIMaterialDepot.super.ctor(self, city, _("材料库房"),building)
    City:GetMaterialManager():AddObserver(self)
    self.material_box_table = {}
    self.material_listview_table = {}
end

function GameUIMaterialDepot:onExit()
    City:GetMaterialManager():RemoveObserver(self)
    GameUIMaterialDepot.super.onExit(self)
end


function GameUIMaterialDepot:CreateBetweenBgAndTitle()
    GameUIMaterialDepot.super.CreateBetweenBgAndTitle(self)

    -- 加入军用帐篷info_layer
    self.info_layer = display.newLayer()
    self:addChild(self.info_layer)
end

function GameUIMaterialDepot:onEnter()
    GameUIMaterialDepot.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("信息"),
            tag = "info",
        },
    },function(tag)
        if tag == 'info' then
            self.info_layer:setVisible(true)
        else
            self.info_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)

    -- self:CreateMaterialInfo()
    self:CreateSelectButton()
    self:SelectOneTypeMaterials(MaterialManager.MATERIAL_TYPE.BUILD)
end

function GameUIMaterialDepot:CreateMaterialInfo()

    local material_map = City:GetMaterialManager():GetMaterialMap()
    self.material_listview_table = {}
    for k,v in pairs(material_map) do
        self.material_listview_table[k] = UIListView.new{
            -- bgColor = cc.c4b(math.random(255), math.random(255), math.random(255), math.random(255)),
            bgScale9 = true,
            viewRect = cc.rect(display.cx-271, display.top-870, 548, 700),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}:addTo(self.info_layer)
        self.material_listview_table[k]:setVisible(false)
        self:CreateItemWithListView(self.material_listview_table[k],k,v)
        print(" 创建了 listview ",k)
    end
end

function GameUIMaterialDepot:CreateItemWithListView(list_view,material_type,materials)
    local rect = list_view:getViewRect()
    local origin_x = - rect.width / 2
    local unit_width ,unit_height = 118 , 140
    local gap_x = (548 - unit_width * 4) / 3
    local row_item = display.newNode()
    local row_count = 4
    for material_name,v in pairs(materials) do
        row_count = row_count -1

        local material_box = WidgetMaterialBox.new(material_type,material_name,function ()
            self:OpenMaterialDetails(material_type,material_name,v.."/"..self.building:GetMaxMaterial())
        end,true):addTo(row_item):SetNumber(v.."/"..self.building:GetMaxMaterial())
            :pos(origin_x + (unit_width + gap_x) * row_count , -unit_height/2)
        self.material_box_table[material_type]={}
        self.material_box_table[material_type][material_name] = material_box
        if row_count<1 then
            local item = list_view:newItem()
            item:addContent(row_item)
            item:setItemSize(548, unit_height)
            list_view:addItem(item)
            row_count=4
            row_item = display.newNode()
        end
    end
    list_view:reload()
end
function GameUIMaterialDepot:SelectOneTypeMaterials(m_type)
    local material_map = City:GetMaterialManager():GetMaterialMap()
    local  material_type = {
        [MaterialManager.MATERIAL_TYPE.BUILD] = _("建造材料"),
        [MaterialManager.MATERIAL_TYPE.DRAGON] = _("龙的材料"),
        [MaterialManager.MATERIAL_TYPE.SOLDIER] = _("士兵材料"),
        [MaterialManager.MATERIAL_TYPE.EQUIPMENT] = _("龙的装备"),
    }
    if not self.material_listview_table[m_type] then
        self.material_listview_table[m_type] = UIListView.new{
            -- bgColor = cc.c4b(math.random(255), math.random(255), math.random(255), math.random(255)),
            bgScale9 = true,
            viewRect = cc.rect(display.cx-271, display.top-870, 548, 700),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}:addTo(self.info_layer)
        self.material_listview_table[m_type]:setVisible(false)
        self:CreateItemWithListView(self.material_listview_table[m_type],m_type,material_map[m_type])
    end
    for k,v in pairs(self.material_listview_table) do

        self.material_listview_table[k]:setVisible(m_type==k)
        if m_type==k then
            self.material_button:setButtonLabel(cc.ui.UILabel.new(
                {
                    UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
                    text = material_type[k],
                    size = 24,
                    color = UIKit:hex2c3b(0xffedae)
                }))
        end
    end
end
function GameUIMaterialDepot:OpenMaterialDetails(material_type,material_name,num)
    self:addChild(WidgetMaterialDetails.new(material_type,material_name,num))
end
function GameUIMaterialDepot:CreateSelectButton()
    self.selected = 2
    self.material_button = WidgetPushButton.new({normal = "yellow_btn_up_185x65.png",
        pressed = "yellow_btn_down_185x65.png"}):align(display.LEFT_BOTTOM):addTo(self.info_layer)
        :onButtonClicked(function ()
            self:SelectOneTypeMaterials(self.selected)
            if self.selected<4 then
                self.selected = self.selected +1
            else
                self.selected=1
            end
        end):align(display.CENTER,display.cx, display.top-130)
end


function GameUIMaterialDepot:OnMaterialsChanged(material_manager,material_type,changed_table)
    for k,v in pairs(changed_table) do
        self.material_box_table[material_type][k]:SetNumber(v.new.."/"..self.building:GetMaxMaterial())
    end
end
return GameUIMaterialDepot













