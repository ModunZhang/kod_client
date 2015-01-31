local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetStockGoods = import("..widget.WidgetStockGoods")
local WidgetPushButton = import("..widget.WidgetPushButton")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local SpriteConfig = import("..sprites.SpriteConfig")
local Flag = import("..entity.Flag")
local UIListView = import(".UIListView")
local UILib = import(".UILib")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Alliance = import("..entity.Alliance")
local Localize = import("..utils.Localize")

-- 联盟成员采集熟练度列表一次加载条数
local LOADING_NUM = 3

local GameUIOrderHall = UIKit:createUIClass('GameUIOrderHall', "GameUIAllianceBuilding")

function GameUIOrderHall:ctor(city,default_tab,building)
    GameUIOrderHall.super.ctor(self, city, _("秩序大厅"),default_tab,building)
    self.default_tab = default_tab
    self.building = building
    self.alliance = Alliance_Manager:GetMyAlliance()
end

function GameUIOrderHall:onEnter()
    GameUIOrderHall.super.onEnter(self)
    self:CreateTabButtons({
        {
            label = _("村落管理"),
            tag = "village",
            default = "village" == self.default_tab,
        },
        {
            label = _("熟练度"),
            tag = "proficiency",
            default = "proficiency" == self.default_tab,
        },
    }, function(tag)
        if tag == 'village' then
            self.village_layer:setVisible(true)
        else
            self.village_layer:setVisible(false)
        end
        if tag == 'proficiency' then
            self.proficiency_layer:setVisible(true)
        else
            self.proficiency_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)
    self:InitVillagePart()
    self:InitProficiencyPart()


    self.alliance:AddListenOnType(self, Alliance.LISTEN_TYPE.VILLAGE_LEVELS_CHANGED)

end
function GameUIOrderHall:CreateBetweenBgAndTitle()
    GameUIOrderHall.super.CreateBetweenBgAndTitle(self)

    -- village_layer
    self.village_layer = display.newLayer()
    self:addChild(self.village_layer)
    -- proficiency_layer
    self.proficiency_layer = display.newLayer()
    self:addChild(self.proficiency_layer)
end

function GameUIOrderHall:InitVillagePart()
    local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0, 0,608, 786),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    },false)
    list_node:addTo(self.village_layer):align(display.BOTTOM_CENTER, window.cx, window.bottom_top+20)
    self.village_listview = list
    self:ResetVillageList()
end
-- 重置村落list
function GameUIOrderHall:ResetVillageList()
    self.village_listview:removeAllItems()
    self.village_items = {}
    for k,v in pairs(self.alliance:GetVillageLevels()) do
        self.village_items[k] = self:CreateVillageItem(k,v)
    end
    self.village_listview:reload()
end

function GameUIOrderHall:CreateVillageItem(village_type,village_level)
    local alliance = self.alliance
    local item = self.village_listview:newItem()
    local item_width,item_height = 568 , 200
    item:setItemSize(item_width, item_height)
    local content = WidgetUIBackGround.new({width=item_width,height=item_height},WidgetUIBackGround.STYLE_TYPE.STYLE_2)

    -- 建筑图片 放置区域左右边框
    cc.ui.UIImage.new("building_image_box.png"):align(display.LEFT_CENTER, 10, 120)
        :addTo(content):flipX(true)
    cc.ui.UIImage.new("building_image_box.png"):align(display.RIGHT_CENTER, 143, 120)
        :addTo(content)

    local build_png = SpriteConfig[village_type]:GetConfigByLevel(village_level).png

    local building_image = display.newSprite(build_png)
        :addTo(content):pos(75, 120)
    building_image:setAnchorPoint(cc.p(0.5,0.5))
    building_image:setScale(113/math.max(building_image:getContentSize().width,building_image:getContentSize().height))
    local level_bg = display.newSprite("back_ground_138x34.png")
        :addTo(content):pos(76, 34)
    local villageLevel = UIKit:ttfLabel({
        text = _("等级")..village_level,
        size = 20,
        color = 0x514d3e,
    }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height/2)
        :addTo(level_bg)
    -- 村落名字
    local title_bg = display.newSprite("title_blue_412x30.png")
        :align(display.LEFT_CENTER, 150, 175)
        :addTo(content)
    UIKit:ttfLabel({
        text = Localize.village_name[village_type],
        size = 22,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 20 , title_bg:getContentSize().height/2)
        :addTo(title_bg)
    -- 村落介绍
    UIKit:ttfLabel({
        text =  string.format(_("提升%s的产量,同时也增加了放逐者的战斗力"),Localize.village_name[village_type]) ,
        size = 20,
        color = 0x797154,
        dimensions = cc.size(380,0)
    }):align(display.LEFT_TOP, 170 , 150)
        :addTo(content)


    if alliance:GetSelf():CanUpgradeAllianceBuilding() then
        -- 荣耀值
        display.newSprite("honour.png"):align(display.CENTER, 250, 40):addTo(content)
        local honour_bg = display.newSprite("back_ground_114x36.png"):align(display.CENTER, 330, 40):addTo(content)
        local need_honour = GameDatas.AllianceVillage[village_type][village_level+1].needHonour
        item.honour_label = UIKit:ttfLabel({
            text = need_honour,
            size = 20,
            color = 0x403c2f,
        }):addTo(honour_bg):align(display.CENTER,honour_bg:getContentSize().width/2,honour_bg:getContentSize().height/2)
        -- 升级按钮
        WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
            :setButtonLabel(UIKit:ttfLabel({
                text = _("升级"),
                size = 22,
                color = 0xffedae,
                shadow= true
            }))
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    if alliance:Honour()<need_honour then
                        FullScreenPopDialogUI.new()
                            :SetTitle(_("提示"))
                            :SetPopMessage(_("荣耀点不足"))
                            :AddToCurrentScene()
                    else
                        NetManager:getUpgradeAllianceVillagePromise(village_type)
                    end
                end
            end):align(display.CENTER, 480, 40):addTo(content)
    end
    item:addContent(content)
    self.village_listview:addItem(item)

    function item:LevelUpRefresh(village_type,village_level)
        villageLevel:setString(_("等级")..village_level)
        local build_png = SpriteConfig[village_type]:GetConfigByLevel(village_level).png
        building_image:setTexture(build_png)
        if self.honour_label then
            local need_honour = GameDatas.AllianceVillage[village_type][village_level+1].needHonour
            self.honour_label:setString(need_honour)
        end
    end

    return item
end

function GameUIOrderHall:InitProficiencyPart()
    local layer = self.proficiency_layer
    local desc_bg = display.newScale9Sprite("back_ground_398x97.png", window.cx, window.top_bottom - 50,cc.size(556,110),cc.rect(15,10,368,77))
        :addTo(layer)

    UIKit:ttfLabel({
        text = "显示联盟成员的村落采集资源熟练度,每采集一定的村落资源,就会增加一定的熟练度,熟练度越高,采集相应村落资源的速度就会越快",
        size = 20,
        color = 0x797154,
        dimensions = cc.size(500,0)
    }):align(display.CENTER, desc_bg:getContentSize().width/2 , desc_bg:getContentSize().height/2)
        :addTo(desc_bg)

    local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0, 0,608, 640),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list_node:addTo(layer):align(display.BOTTOM_CENTER, window.cx, window.bottom_top+20)
    self.proficiency_listview = list

    local sortByPostionMember = {}
    self.current_loading_num = 1
    self.alliance:IteratorAllMembers(function ( id,member )
        table.insert(sortByPostionMember, member)
    end)
    table.sort( sortByPostionMember, function ( a,b )
        return a:GetTitleLevel()>b:GetTitleLevel()
    end)
    self.sortByPostionMember = sortByPostionMember
    self:LoadMember()
    if self.current_loading_num<#sortByPostionMember then
        self:CreateLoadingMoreItem()
    end
    self.proficiency_listview:reload()
end
function GameUIOrderHall:LoadMember()
    local sortByPostionMember = self.sortByPostionMember
    local current_index = self.current_loading_num
    local load_to_index = current_index+LOADING_NUM-1<#sortByPostionMember and current_index+LOADING_NUM-1 or #sortByPostionMember
    for i = current_index,load_to_index do
        self:CreateProficiencyItem(sortByPostionMember[i],i)
    end
    self.current_loading_num = load_to_index + 1
    if (self.current_loading_num-1) == #sortByPostionMember then
        local listview =self.proficiency_listview
        if self.loading_more_item then
            listview:removeItem(self.loading_more_item)
        end
        local _,pre_y = listview.container:getPosition()
        local item_height = 210
        listview.container:setPositionY(pre_y+item_height)
    end
end
function GameUIOrderHall:CreateProficiencyItem(member,index)
    if not member then
        return
    end
    local item = self.proficiency_listview:newItem()
    local item_width,item_height = 568 , 210
    item:setItemSize(item_width, item_height)
    local content = WidgetUIBackGround.new({
        width = item_width,
        height = item_height,
    },WidgetUIBackGround.STYLE_TYPE.STYLE_2)


    local title_bg = display.newScale9Sprite("title_blue_430x30.png",item_width/2,item_height-30,cc.size(550,30),cc.rect(15,10,400,10))
        :addTo(content)
    local level_bg = display.newSprite("back_ground_44X44.png")
        :align(display.CENTER, 30, title_bg:getContentSize().height/2)
        :addTo(title_bg)
    -- 职位对应icon
    display.newSprite(UILib.alliance_title_icon[member:Title()])
        :align(display.CENTER, level_bg:getContentSize().width/2, level_bg:getContentSize().height/2)
        :addTo(level_bg)
    UIKit:ttfLabel({
        text = member:Name().."  ".._("等级").. " "..member:Level(),
        size = 20,
        color = 0xffedae,
    }):align(display.LEFT_CENTER, 60 , title_bg:getContentSize().height/2)
        :addTo(title_bg)
    -- 各项采集熟料度
    local function createItem(params)
        local item = display.newSprite("back_ground_162x62.png")
        local size = item:getContentSize()
        -- 采集资源对应图片
        local image = display.newSprite(params.image)
            :align(display.CENTER, 30, size.height/2)
            :addTo(item)
            :scale(0.5)
        UIKit:ttfLabel({
            text = params.level,
            size = 18,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER, 60 , 45)
            :addTo(item)
        UIKit:ttfLabel({
            text = params.proficiency,
            size = 18,
            color = 0x403c2f,
        }):align(display.LEFT_CENTER, 60 , 20)
            :addTo(item)
        return item
    end

    local allianceExp = member:GetAllianceExp()
    local r_table = {
        {
            image = "wood_icon.png",
            level = _("等级")..member:GetWoodCollectLevel(),
            proficiency = allianceExp.woodExp.."/"..member:GetWoodCollectLevelUpExp(),
        },
        {
            image = "stone_icon.png",
            level = _("等级")..member:GetStoneCollectLevel(),
            proficiency = allianceExp.stoneExp.."/"..member:GetStoneCollectLevelUpExp(),
        },
        {
            image = "food_icon.png",
            level = _("等级")..member:GetFoodCollectLevel(),
            proficiency = allianceExp.foodExp.."/"..member:GetFoodCollectLevelUpExp(),
        },
        {
            image = "iron_icon.png",
            level = _("等级")..member:GetIronCollectLevel(),
            proficiency = allianceExp.ironExp.."/"..member:GetIronCollectLevelUpExp(),
        },
        {
            image = "coin_icon.png",
            level = _("等级")..member:GetCoinCollectLevel(),
            proficiency = allianceExp.coinExp.."/"..member:GetCoinCollectLevelUpExp(),
        },
    }

    local margin_x = (item_width - 3 * 162)/2 - 20
    local original_x = 100
    local count = 0
    for k,v in pairs(r_table) do
        count = count + 1
        createItem(v)
            :align(display.CENTER, original_x +  math.mod(count-1,3)*162 + math.mod(count-1,3)*margin_x, math.floor((count-1)/3)==0 and 120 or 50)
            :addTo(content)
    end
    item:addContent(content)
    self.proficiency_listview:insertItemAndRefresh(item,index)
end
function GameUIOrderHall:CreateLoadingMoreItem()
    local listview = self.proficiency_listview
    local item = listview:newItem()
    local item_width, item_height = 568 , 210
    item:setItemSize(item_width, item_height)
    -- 加载更多按钮
    local loading_more_button = WidgetPushButton.new():setButtonLabel(UIKit:ttfLabel({
        text = _("载入更多..."),
        size = 24,
        color = 0xfff3c7}))
        :align(display.CENTER, item_width/2, item_height/2)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:LoadMember()
            end
        end)
    item:addContent(loading_more_button)
    listview:addItem(item)
    listview:reload()
    self.loading_more_item = item
end
function GameUIOrderHall:OnVillageLevelsChanged(alliance,changed_map)
    for k,v in pairs(changed_map) do
        if self.village_items[k] then
            self.village_items[k]:LevelUpRefresh(k,v)
        end
    end
end

function GameUIOrderHall:onExit()
    self.alliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.VILLAGE_LEVELS_CHANGED)
    GameUIOrderHall.super.onExit(self)
end

return GameUIOrderHall




























