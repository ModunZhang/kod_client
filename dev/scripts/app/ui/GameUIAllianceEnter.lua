local WidgetPushButton = import("..widget.WidgetPushButton")
local UIListView = import(".UIListView")
local window = import("..utils.window")
local UILib = import(".UILib")
local Enum = import("..utils.Enum")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIWriteMail = import(".GameUIWriteMail")

local GameUIAllianceEnter = UIKit:createUIClass("GameUIAllianceEnter")
local GameUIAllianceSendTroops = import(".GameUIAllianceSendTroops")

GameUIAllianceEnter.MODE = Enum("Normal","Enemy","Watch")

function GameUIAllianceEnter:InitConfig()
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
        enter_buttons = 
        {
            Normal = 
            {
                {
                    img = "icon_info_1.png",
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
                    img = "icon_upgrade_1.png",
                    title = _("升级"),
                    func = function (building)
                        UIKit:newGameUI('GameUIAlliancePalace',City,"upgrade",building):addToCurrentScene(true)
                    end
                },
            },
            Enemy = 
            {
                
            },
            Watch = 
            {

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
        enter_buttons = 
        {
            Normal = 
            {
                {
                    img = "icon_info_1.png",
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
                    img = "icon_upgrade_1.png",
                    title = _("升级"),
                    func = function (building)
                        UIKit:newGameUI('GameUIAllianceShop',City,"upgrade",building):addToCurrentScene(true)
                    end
                },
            },
            Enemy = 
            {

            },
            Watch = 
            {

            }
        },
    },
    moonGate = {
        height = 311,
        title = _("月门"),
        building_image = "moonGate_200x217.png",
        building_desc = _("本地化缺失"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("驻防部队"),0x797154},
                {_("暂无"),0x403c2f},
            },
            {
                {_("占领方"),0x797154},
                {_("暂无"),0x403c2f},
            },
            {
                {_("状态"),0x797154},
                {_("暂无"),0x403c2f},
            },
        },
        enter_buttons = {
            Normal = 
            {
                {
                    img = "icon_info_1.png",
                    title = _("驻防部队"),
                    func = function (building)
                        UIKit:newGameUI('GameUIMoonGate',City,"garrison",building):addToCurrentScene(true)
                    end
                },
                {
                    img = "icon_alliance_crisis.png",
                    title = _("战场"),
                    func = function (building)
                        UIKit:newGameUI('GameUIMoonGate',City,"battlefield",building):addToCurrentScene(true)
                    end
                },
                {
                    img = "icon_upgrade_1.png",
                    title = _("升级"),
                    func = function (building)
                        UIKit:newGameUI('GameUIMoonGate',City,"upgrade",building):addToCurrentScene(true)
                    end
                },
            },
            Enemy = 
            {
                {
                    img = "icon_info_1.png",
                    title = _("驻防部队"),
                    func = function (building)
                        UIKit:newGameUI('GameUIMoonGate',City,"garrison",building):addToCurrentScene(true)
                    end
                },
                {
                    img = "icon_alliance_crisis.png",
                    title = _("战场"),
                    func = function (building)
                        UIKit:newGameUI('GameUIMoonGate',City,"battlefield",building):addToCurrentScene(true)
                    end
                },
            },
            Watch = 
            {
                {
                    img = "icon_alliance_crisis.png",
                    title = _("战场"),
                    func = function (building)
                        UIKit:newGameUI('GameUIMoonGate',City,"battlefield",building):addToCurrentScene(true)
                    end
                }
            }
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
            Normal = 
            {
                {
                    img = "icon_info_1.png",
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
                    img = "icon_upgrade_1.png",
                    title = _("升级"),
                    func = function (building)
                        UIKit:newGameUI('GameUIOrderHall',City,"upgrade",building):addToCurrentScene(true)
                    end
                },
            },
            Enemy = 
            {

            },
            Watch = 
            {

            }
        },
    },
    shrine = {
        height = 261,
        title = _("圣地"),
        building_image = "orderHall_277x417.png",
        building_desc = _("本地化缺失"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("正在进行的事件"),0x797154},
                {_("暂无"),0x403c2f},
            },
            {
                {_("参与部队"),0x797154},
                {_("暂无"),0x403c2f},
            },
        },
        enter_buttons = {
            Normal = 
            {
                {
                    img = "icon_info_1.png",
                    title = _("战争事件"),
                    func = function (building)
                        UIKit:newGameUI('GameUIAllianceShrine',City,"fight_event",building):addToCurrentScene(true)
                    end
                },
                {
                    img = "icon_alliance_crisis.png",
                    title = _("联盟危机"),
                    func = function (building)
                        UIKit:newGameUI('GameUIAllianceShrine',City,"stage",building):addToCurrentScene(true)
                    end
                },
                {
                    img = "icon_upgrade_1.png",
                    title = _("升级"),
                    func = function (building)
                        UIKit:newGameUI('GameUIAllianceShrine',City,"upgrade",building):addToCurrentScene(true)
                    end
                },
            },
            Enemy = 
            {

            },
            Watch = 
            {

            }
        },
    },
    decorate = {
        height = 242,
        title = _("树/湖泊/山脉"),
        building_image = "tree_1_120x120.png",
        building_desc = _("可拆除,需要职位在将军以上的玩家,并且花费一定的荣誉值"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("占地"),0x797154},
                {_("暂无"),0x403c2f},
            },
        },
        enter_buttons = {
            Normal = 
            {
                {
                    img = "icon_demolish.png",
                    title = _("拆除"),
                    func = function (building)
                        local alliacne =  Alliance_Manager:GetMyAlliance()
                        local isEqualOrGreater = alliacne:GetMemeberById(DataManager:getUserData()._id):IsTitleEqualOrGreaterThan("general")
                        if isEqualOrGreater then
                            NetManager:getDistroyAllianceDecoratePromise(building:Id())
                        end
                    end
                },
            },
            Enemy = 
            {

            },
            Watch = 
            {

            }
        },
    },
    --空地
    none = {
        height = 242,
        title = _("空地"),
        building_image = "tree_1_120x120.png",
        building_desc = _("联盟将军可将联盟建筑移动到空地,玩家可将自己的城市移动到空地处,空地定期刷新放逐者的村落,树木,山脉和湖泊"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
        },
        enter_buttons = {
            Normal = 
            {
                {
                    img = "icon_move_city.png",
                    title = _("迁移城市"),
                    func = function (building)
                    -- UIKit:newGameUI('GameUIOrderHall',City,"proficiency",building):addToCurrentScene(true)
                    end
                },
                {
                    img = "icon_move_alliance_building.png",
                    title = _("迁移联盟建筑"),
                    func = function (building)
                    -- UIKit:newGameUI('GameUIOrderHall',City,"proficiency",building):addToCurrentScene(true)
                    end
                },
            },
            Enemy = 
            {

            },
            Watch = 
            {

            }
        },
    },
    --玩家城市
    member = {
        height = 311,
        title = _("空地"),
        building_image = "keep_760x855.png",
        building_desc = _("联盟将军可将联盟建筑移动到空地,玩家可将自己的城市移动到空地处,空地定期刷新放逐者的村落,树木,山脉和湖泊"),
        building_info = {
            {
                {_("坐标"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("玩家"),0x797154},
                {_("11,11"),0x403c2f},
            },
            {
                {_("驻防玩家"),0x797154},
                {"10",0x403c2f},
            },
        },
        enter_buttons = {
            Normal = 
            {
                {
                    img = "help_defense_55x69.png",
                    title = _("协防"),
                    func = function (building)
                        UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
                            dump(soldiers,"协防派兵")
                        end):addToCurrentScene(true)
                    end
                },
                {
                    img = "playercity_66x83.png",
                    title = _("进入"),
                    func = function (building)
                    end
                },
                {
                    img = "mail_70x55.png",
                    title = _("邮件"),
                    func = function (building)
                        local mail = GameUIWriteMail.new()
                        mail:SetTitle(_("个人邮件"))
                        mail:SetAddressee(building.player:name())
                        mail:OnSendButtonClicked( GameUIWriteMail.SEND_TYPE.PERSONAL_MAIL)
                        mail:addToCurrentScene(true)
                    end
                },
                {
                    img = "icon_info_1.png",
                    title = _("信息"),
                    func = function (building)
                        UIKit:newGameUI("GameUIPlayerInfo",true,building.player:Id()):addToCurrentScene(true)
                    end
                },
            },
            Enemy = 
            {

            },
            Watch = 
            {
            
            }
        },
    },
}
    return ENTER_LIST
end

function GameUIAllianceEnter:GetMode()
    return self.mode_
end

function GameUIAllianceEnter:GetAlliance()
    return self.alliance
end

function GameUIAllianceEnter:GetBuilding()
    return self.building
end

function GameUIAllianceEnter:GetConfig()
    return self.config_
end

function GameUIAllianceEnter:GetBuildingConfig()
    assert(self:GetConfig()[self:GetBuildingKey()],"联盟建筑配置为空"..self:GetBuildingKey())
    return self:GetConfig()[self:GetBuildingKey()]
end
function GameUIAllianceEnter:GetBuildingKey()
    local building = self:GetBuilding()
    local building_identity = building.name or (building:GetType()=="none" and "none") or building:GetCategory()
    return building_identity
end

function GameUIAllianceEnter:ctor(alliance,building,mode)
    GameUIAllianceEnter.super.ctor(self)
    self.config_ = self:InitConfig()
    self.mode_ = mode or self.MODE.Normal
    self.alliance = alliance
    self.building = building
    display.newColorLayer(cc.c4b(0,0,0,127)):addTo(self)
    self:setNodeEventEnabled(true)
    self.params = self:GetBuildingConfig()
    self:SetBuildingInfo()
    self.body = self:CreateBackGroundWithTitle(self.params)
        :align(display.CENTER, window.cx, window.top - 400)
        :addTo(self)
    self:InitBuildingImage()
    self:InitBuildingDese()
    self:InitBuildingInfo(self.params.building_info)
    self:InitEnterButton(self.params.enter_buttons[self.MODE[self:GetMode()]])
end
--设置数据结构
function GameUIAllianceEnter:SetBuildingInfo()
    local building = self:GetBuilding()
    local building_config = self:GetBuildingConfig()
    local info = building_config.building_info
    if building.location then
        info[1][2][1] = building.location.x..","..building.location.y
    else
        local x,y = self.building:GetLogicPosition()
        info[1][2][1] = x..","..y
    end
    local name = self:GetBuildingKey()
    if name == "palace" then
        info[2][2][1] = self:GetAlliance():MemberCount()
        info[3][2][1] = _("暂无")
    elseif name == "shop" then
        info[2][2][1] = _("暂无")
    elseif name == "orderHall" then
    elseif name == "member" then
        local dataModel = self:GetConfig()[name]
        local memeber = self:GetPlayerByLocation(self.building:GetLogicPosition())
        dataModel.title = memeber.name
        dataModel.building_info[2][2][1] = memeber.name
        dataModel.building_info[3][2][1] = memeber.helpTroopsCount
        building.player = memeber
        if self:GetMode() == GameUIAllianceEnter.MODE.Normal then
            print(User:Id(),memeber:Id(),User:Id() == memeber:Id())
            if User:Id() == memeber:Id() then
                --自己的城市建筑
                table.remove(dataModel.enter_buttons.Normal,4)
                table.remove(dataModel.enter_buttons.Normal,3)
                table.remove(dataModel.enter_buttons.Normal,1)
                dump(dataModel.enter_buttons.Normal)
            end
        end
    elseif name == "decorate" then
        local w,h = self.building:GetSize()
        info[2][2][1] = w*h
        self:GetConfig()[name].building_image = UILib.decorator_image[self.building:GetType()]
        if string.find(self.building:GetType(), "tree", 9) then
            self:GetConfig()[name].title = _("树")
        elseif string.find(self.building:GetType(), "mountain", 9) then
            self:GetConfig()[name].title = _("山脉")
        elseif string.find(self.building:GetType(), "lake", 9) then
            self:GetConfig()[name].title = _("湖泊")
        end
    end
end

function GameUIAllianceEnter:GetPlayerByLocation( x,y )
    for _,member in pairs(self:GetAlliance():GetAllMembers()) do
        print(member.location.x,member.location.y)
        if member.location.x == x and y == member.location.y then
            return member
        end
    end
end

function GameUIAllianceEnter:InitBuildingDese()
    local building_key = self:GetBuildingKey()
    local p = self.params
    if building_key == 'member' then
        self.desc_label = display.newSprite("Progress_bar_1.png"):align(display.LEFT_TOP, 180, p.height-30)
                :addTo(self.body)
        self.progressTimer = UIKit:commonProgressTimer("progress_bar_366x34.png"):addTo(self.desc_label):align(display.LEFT_BOTTOM,0,0):scale(386/366)
        self.progressTimer:setPercentage(100)
        local bg = display.newSprite("back_ground_43x43.png"):addTo(self.desc_label):pos(10,18)
        display.newSprite("wall_36x41.png"):addTo(bg):pos(21,21)
        
    else
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
                self:leftButtonClicked()
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
    if not self.building.name and string.find(self.building:GetType(), "decorate", 1)  then
        display.newSprite("honour.png"):align(display.CENTER, 20, level_bg:getContentSize().height/2)
            :addTo(level_bg)
        local distroyNeedHonour = GameDatas.AllianceInitData.buildingType[self.building:GetType()].distroyNeedHonour
        UIKit:ttfLabel({
            text = distroyNeedHonour,
            size = 20,
            color = 0x514d3e,
        }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height/2)
            :addTo(level_bg)
    elseif not self.building.name and self.building:GetType()=="none" then
        level_bg:setVisible(false)
    else
        UIKit:ttfLabel({
            text = _("Level").." "..self.building.level,
            size = 20,
            color = 0x514d3e,
        }):align(display.CENTER, level_bg:getContentSize().width/2 , level_bg:getContentSize().height/2)
            :addTo(level_bg)
    end
end

function GameUIAllianceEnter:InitEnterButton(buttons)
    local width = 608
    local btn_width = 130
    local count = 0
    for _,v in ipairs(buttons) do
        local btn = WidgetPushButton.new({normal = "btn_130X104.png",pressed = "btn_pressed_130X104.png"})
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    v.func(self.building)
                    self:leftButtonClicked()
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




return GameUIAllianceEnter