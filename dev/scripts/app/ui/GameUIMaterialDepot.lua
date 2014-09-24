local UIListView = import(".UIListView")
local WidgetMaterialBox = import("..widget.WidgetMaterialBox")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetMaterialDetails = import("..widget.WidgetMaterialDetails")
local DRAGON_MATERIAL_PIC_MAP = {
    ["ironIngot"] = "ironIngot_92x92.png",
    ["steelIngot"] = "steelIngot_92x92.png",
    ["mithrilIngot"] = "mithrilIngot_92x92.png",
    ["blackIronIngot"] = "blackIronIngot_92x92.png",
    ["arcaniteIngot"] = "arcaniteIngot_92x92.png",
    ["wispOfFire"] = "wispOfFire_92x92.png",
    ["wispOfCold"] = "wispOfCold_92x92.png",
    ["wispOfWind"] = "wispOfWind_92x92.png",
    ["lavaSoul"] = "lavaSoul_92x92.png",
    ["iceSoul"] = "iceSoul_92x92.png",
    ["forestSoul"] = "forestSoul_92x92.png",
    ["infernoSoul"] = "infernoSoul_92x92.png",
    ["blizzardSoul"] = "blizzardSoul_92x92.png",
    ["fairySoul"] = "fairySoul_92x92.png",
    ["moltenShard"] = "moltenShard_92x92.png",
    ["glacierShard"] = "glacierShard_92x92.png",
    ["chargedShard"] = "chargedShard_92x92.png",
    ["moltenShiver"] = "moltenShiver_92x92.png",
    ["glacierShiver"] = "glacierShiver_92x92.png",
    ["chargedShiver"] = "chargedShiver_92x92.png",
    ["moltenCore"] = "moltenCore_92x92.png",
    ["glacierCore"] = "glacierCore_92x92.png",
    ["chargedCore"] = "chargedCore_92x92.png",
    ["moltenMagnet"] = "moltenMagnet_92x92.png",
    ["glacierMagnet"] = "glacierMagnet_92x92.png",
    ["chargedMagnet"] = "chargedMagnet_92x92.png",
    ["challengeRune"] = "challengeRune_92x92.png",
    ["suppressRune"] = "suppressRune_92x92.png",
    ["rageRune"] = "rageRune_92x92.png",
    ["guardRune"] = "guardRune_92x92.png",
    ["poisonRune"] = "poisonRune_92x92.png",
    ["giantRune"] = "giantRune_92x92.png",
    ["dolanRune"] = "dolanRune_92x92.png",
    ["warsongRune"] = "warsongRune_92x92.png",
    ["infernoRune"] = "infernoRune_92x92.png",
    ["arcanaRune"] = "arcanaRune_92x92.png",
    ["eternityRune"] = "eternityRune_92x92.png"
}

local GameUIMaterialDepot = UIKit:createUIClass("GameUIMaterialDepot", "GameUIUpgradeBuilding")
function GameUIMaterialDepot:ctor(city,building)
    GameUIMaterialDepot.super.ctor(self, city, _("材料库房"),building)
    City:GetMaterialManager():AddObserver(self)
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
    end):pos(display.cx, display.bottom + 40)

    self:CreateMaterialInfo()
    self:SelectOneTypeMaterials("materials")
    self:CreateSelectButton()
end

function GameUIMaterialDepot:CreateMaterialInfo()

    local material_map = City:GetMaterialManager():GetMaterialMap()
    self.material_listview_table = {}
    for k,v in pairs(material_map) do
        self.material_listview_table[k] = UIListView.new{
            -- bgColor = cc.c4b(math.random(255) math.random(255), math.random(255), math.random(255)),
            bgScale9 = true,
            viewRect = cc.rect(display.cx-266, display.top-870, 547, 700),
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
    local gap_x = (547 - unit_width * 4) / 3
    local row_item = display.newNode()
    local row_count = 4
    for i,v in pairs(materials) do
        row_count = row_count -1
        
        local soldier = WidgetMaterialBox.new(material_type=="dragonMaterials" and DRAGON_MATERIAL_PIC_MAP[i] or "material_blueprints.png",function ()
            self:OpenMaterialDetails(material_type,i,v.."/"..self.building:GetMaxMaterial())
        end,true):addTo(row_item):SetNumber(v.."/"..self.building:GetMaxMaterial())
            :pos(origin_x + (unit_width + gap_x) * row_count , -unit_height/2)
        if row_count<1 then
            local item = list_view:newItem()
            item:addContent(row_item)
            item:setItemSize(547, unit_height)
            list_view:addItem(item)
            row_count=4
            row_item = display.newNode()
        end
    end
    list_view:reload()
end
function GameUIMaterialDepot:SelectOneTypeMaterials(m_type)
    for k,v in pairs(self.material_listview_table) do
        self.material_listview_table[k]:setVisible(m_type==k)
    end
end
function GameUIMaterialDepot:OpenMaterialDetails(material_type,material_name,num)
    self:addChild(WidgetMaterialDetails.new(material_type,material_name,num))
end
function GameUIMaterialDepot:CreateSelectButton()
    self.selected = 2
    local tt= {
        "materials",
        "dragonEquipments",
        "dragonMaterials",
        "soldierMaterials",
    }
    self.material_bg = WidgetPushButton.new({normal = "icon_background_wareHouseUI.png",
        pressed = "icon_background_wareHouseUI.png"}):align(display.LEFT_BOTTOM):addTo(self.info_layer)
        :onButtonClicked(function ()
            print("选中了！！！！！！====",tt[self.selected])
            self:SelectOneTypeMaterials(tt[self.selected])
            if self.selected<4 then
                self.selected = self.selected +1
            else
                self.selected=1
            end
        end):pos(display.cx, display.top-100)
end


function GameUIMaterialDepot:OnMaterialChanged(material_manager,changed_table)
    
end
return GameUIMaterialDepot







