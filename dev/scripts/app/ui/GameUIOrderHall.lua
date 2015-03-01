local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetStockGoods = import("..widget.WidgetStockGoods")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetDropList = import("..widget.WidgetDropList")
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
local collect_type  = {_("木材"),
    _("石料"),
    _("铁矿"),
    _("粮食")}
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

    UIKit:createLineItem(
        {
            width = 396,
            text_1 = _("资源总量"),
            text_2 = string.formatnumberthousands(400000),
        }
    ):align(display.RIGHT_CENTER,item_width - 10 , 120)
        :addTo(content)
    UIKit:createLineItem(
        {
            width = 396,
            text_1 = _("采集速度"),
            text_2 = string.formatnumberthousands(400000).._("每分钟"),
        }
    ):align(display.RIGHT_CENTER,item_width - 10, 80)
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
    local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0, 0,608, 500),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list_node:addTo(layer):align(display.BOTTOM_CENTER, window.cx, window.bottom_top+20)
    self.proficiency_listview = list
    local my_ranking_bg = display.newScale9Sprite("back_ground_516x60.png", window.cx, window.top_bottom - 210,cc.size(548,52),cc.rect(15,10,486,40))
        :addTo(layer)
    self.my_ranking_label = UIKit:ttfLabel({
        text = _("我的木材熟练度排名:")..33,
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, my_ranking_bg:getContentSize().width/2 , my_ranking_bg:getContentSize().height/2)
        :addTo(my_ranking_bg)
    self.proficiency_drop_list =  WidgetDropList.new(
        {
            {tag = "1",label = _("木材熟练度排名"),default = true},
            {tag = "2",label = _("石料熟练度排名")},
            {tag = "3",label = _("铁矿熟练度排名")},
            {tag = "4",label = _("粮食熟练度排名")},
        },
        function(tag)
            self:ChangeProficiencyOption(tonumber(tag))
        end
    )
    self.proficiency_drop_list:align(display.TOP_CENTER,window.cx,window.top-80):addTo(layer,2)



    local desc_bg = display.newScale9Sprite("back_ground_398x97.png", window.cx, window.top_bottom - 110,cc.size(556,110),cc.rect(15,10,368,77))
        :addTo(layer)

    UIKit:ttfLabel({
        text = _("显示联盟成员的村落采集资源熟练度,每采集一定的村落资源,就会增加一定的熟练度,熟练度越高,采集相应村落资源的速度就会越快"),
        size = 20,
        color = 0x797154,
        dimensions = cc.size(500,0)
    }):align(display.CENTER, desc_bg:getContentSize().width/2 , desc_bg:getContentSize().height/2)
        :addTo(desc_bg)



end
function GameUIOrderHall:ChangeProficiencyOption(option)
    self.proficiency_listview:removeAllItems()
    local sortByProficiencyMember = {}
    self.current_loading_num = 1
    self.alliance:IteratorAllMembers(function ( id,member )
        table.insert(sortByProficiencyMember, member)
    end)
    table.sort( sortByProficiencyMember, function ( a,b )
        return a:GetCollectLevelByType(option)>b:GetCollectLevelByType(option)
    end)
    self.sortByProficiencyMember = sortByProficiencyMember
    self:LoadMember(option)
    print("current_loading_num",self.current_loading_num,"sortByProficiencyMember",#sortByProficiencyMember)
    if self.current_loading_num<=#sortByProficiencyMember then
        self:CreateLoadingMoreItem()
    end
    self.proficiency_listview:reload()
    self.option = option

    -- 更新我的对应排名
    for i,v in ipairs(sortByProficiencyMember) do
        if v:Id() == User:Id() then
            self.my_ranking_label:setString(string.format(_("我的%s熟练度排名:"),collect_type[option]) ..i)
        end
    end
end
function GameUIOrderHall:LoadMember(option)
    local sortByProficiencyMember = self.sortByProficiencyMember
    local current_index = self.current_loading_num
    local load_to_index = current_index+LOADING_NUM-1<#sortByProficiencyMember and current_index+LOADING_NUM-1 or #sortByProficiencyMember
    for i = current_index,load_to_index do
        self:CreateProficiencyItem(sortByProficiencyMember[i],i,option)
    end
    self.current_loading_num = load_to_index + 1
    if (self.current_loading_num-1) == #sortByProficiencyMember then
        local listview =self.proficiency_listview
        if self.loading_more_item then
            listview:removeItem(self.loading_more_item)
        end
        local _,pre_y = listview.container:getPosition()
        local item_height = 100
        listview.container:setPositionY(pre_y+item_height)
    end
end
function GameUIOrderHall:CreateProficiencyItem(member,index,option)
    if not member then
        return
    end
    local item = self.proficiency_listview:newItem()
    local item_width,item_height = 568 , 100
    item:setItemSize(item_width, item_height)
    local content = WidgetUIBackGround.new({
        width = item_width,
        height = item_height,
    },WidgetUIBackGround.STYLE_TYPE.STYLE_2)

    UIKit:ttfLabel({
        text = index..".",
        size = 22,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 10 , item_height/2)
        :addTo(content)
    -- 成员职位，名字
    local title_bg = display.newScale9Sprite("back_ground_166x84.png",114,item_height/2,cc.size(162,78),cc.rect(15,10,136,64))
        :addTo(content)
    -- 职位对应icon
    display.newSprite(UILib.alliance_title_icon[member:Title()])
        :align(display.CENTER, title_bg:getContentSize().width/2, title_bg:getContentSize().height-20)
        :addTo(title_bg)
    -- 名字
    UIKit:ttfLabel({
        text = member:Name(),
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER, title_bg:getContentSize().width/2 , 20)
        :addTo(title_bg)

    -- 等级经验
    local level_bg = display.newScale9Sprite("back_ground_166x84.png",290,item_height/2,cc.size(162,78),cc.rect(15,10,136,64))
        :addTo(content)
    -- 等级
    UIKit:ttfLabel({
        text = _("等级")..member:GetCollectLevelByType(option),
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height-20)
        :addTo(level_bg)
    -- 经验
    local exp , expTo = member:GetCollectExpsByType(option)
    UIKit:ttfLabel({
        text = exp.."/"..expTo,
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER, level_bg:getContentSize().width/2 , 20)
        :addTo(level_bg)

    -- 采集速度
    local speed_bg = display.newScale9Sprite("back_ground_166x84.png",466,item_height/2,cc.size(162,78),cc.rect(15,10,136,64))
        :addTo(content)
    -- 等级
    UIKit:ttfLabel({
        text = _("采集速度"),
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER, speed_bg:getContentSize().width/2 , speed_bg:getContentSize().height-20)
        :addTo(speed_bg)
    UIKit:ttfLabel({
        text = "+"..(member:GetCollectEffectByType(option)*100).."%",
        size = 20,
        color = 0x403c2f,
    }):align(display.CENTER, speed_bg:getContentSize().width/2 , 20)
        :addTo(speed_bg)

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
                self:LoadMember(self.option)
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
































