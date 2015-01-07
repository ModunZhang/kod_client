local UIListView = import("..ui.UIListView")
local window = import("..utils.window")
local WidgetMaterialBox = import("..widget.WidgetMaterialBox")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetMaterialDetails = import("..widget.WidgetMaterialDetails")
local MaterialManager = import("..entity.MaterialManager")
local WidgetDropList = import("..widget.WidgetDropList")

local WidgetMaterials = class("WidgetMaterials", function ()
	return display.newLayer()
end)

function WidgetMaterials:ctor(city,building)
    self:setNodeEventEnabled(true)
    self.city = City
    self.building = building
    City:GetMaterialManager():AddObserver(self)
    self.material_box_table = {}
    self.material_listview_table = {}
end

function WidgetMaterials:onExit()
    City:GetMaterialManager():RemoveObserver(self)
end

function WidgetMaterials:onEnter()
    self:CreateSelectButton()
    self:SelectOneTypeMaterials(MaterialManager.MATERIAL_TYPE.BUILD)
end

function WidgetMaterials:CreateMaterialInfo()
    local material_map = City:GetMaterialManager():GetMaterialMap()
    self.material_listview_table = {}
    for k,v in pairs(material_map) do
        self.material_listview_table[k] = UIListView.new{
            bgScale9 = true,
            viewRect = cc.rect(display.cx-271, display.top-870, 548, 700),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}:addTo(self)
        self.material_listview_table[k]:setVisible(false)
        self:CreateItemWithListView(self.material_listview_table[k],k,v)
    end
end

function WidgetMaterials:CreateItemWithListView(list_view,material_type,materials)
    local rect = list_view:getViewRect()
    local origin_x = - rect.width / 2
    local unit_width ,unit_height = 118 , 170
    local gap_x = (548 - unit_width * 4) / 3
    local row_item = display.newNode()
    local row_count = 4
    for material_name,v in pairs(materials) do
        row_count = row_count -1

        local material_box = WidgetMaterialBox.new(material_type,material_name,function ()
            self:OpenMaterialDetails(material_type,material_name,v.."/"..self.building:GetMaxMaterial())
        end,true):addTo(row_item):SetNumber(v.."/"..self.building:GetMaxMaterial())
            :pos(origin_x + (unit_width + gap_x) * row_count , -unit_height/2+30)
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
function WidgetMaterials:SelectOneTypeMaterials(m_type)
    local material_map = City:GetMaterialManager():GetMaterialMap()
    if not self.material_listview_table[m_type] then
        self.material_listview_table[m_type] = UIListView.new{
            bgScale9 = true,
            viewRect = cc.rect(display.cx-271, display.top-870, 548, 700),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}:addTo(self)
        self.material_listview_table[m_type]:setVisible(false)
        self:CreateItemWithListView(self.material_listview_table[m_type],m_type,material_map[m_type])
    
    end
    for k,v in pairs(self.material_listview_table) do
    	print("SelectOneTypeMaterials---",m_type,k)
    	self.material_listview_table[k]:setVisible(k==m_type)
    end
end
function WidgetMaterials:OpenMaterialDetails(material_type,material_name,num)
    WidgetMaterialDetails.new(material_type,material_name,num):addToCurrentScene()
end
function WidgetMaterials:CreateSelectButton()
	 self.dropList = WidgetDropList.new(
        {
            {tag = "1",label = "工具材料",default = true},
            {tag = "2",label = "龙的装备"},
            {tag = "3",label = "打造装备材料"},
            {tag = "4",label = "招募特殊兵种的材料"},
        },
        function(tag)
            if tag == '1' then
            	self:SelectOneTypeMaterials(MaterialManager.MATERIAL_TYPE.BUILD)
            end
            if tag == '2' then
            	self:SelectOneTypeMaterials(MaterialManager.MATERIAL_TYPE.DRAGON)
            end
            if tag == '3' then
            	self:SelectOneTypeMaterials(MaterialManager.MATERIAL_TYPE.SOLDIER)
            end
            if tag == '4' then
            	self:SelectOneTypeMaterials(MaterialManager.MATERIAL_TYPE.EQUIPMENT)
            end
        end
    )
    self.dropList:align(display.TOP_CENTER,window.cx,window.top-96):addTo(self,2)

end


function WidgetMaterials:OnMaterialsChanged(material_manager,material_type,changed_table)
    for k,v in pairs(changed_table) do
        self.material_box_table[material_type][k]:SetNumber(v.new.."/"..self.building:GetMaxMaterial())
    end
end

return WidgetMaterials