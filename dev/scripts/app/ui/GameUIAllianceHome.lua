local window = import("..utils.window")
local Alliance = import("..entity.Alliance")
local WidgetChat = import("..widget.WidgetChat")
local WidgetChangeMap = import("..widget.WidgetChangeMap")
local WidgetHomeBottom = import("..widget.WidgetHomeBottom")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetAllianceTop = import("..widget.WidgetAllianceTop")
local WidgetMarchEvents = import("app.widget.WidgetMarchEvents")
local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local GameUIAllianceHome = UIKit:createUIClass('GameUIAllianceHome')
local buildingName = GameDatas.AllianceInitData.buildingName
local Alliance_Manager = Alliance_Manager
local cc = cc



function GameUIAllianceHome:DisplayOn()
    self.visible_count = self.visible_count + 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIAllianceHome:DisplayOff()
    self.visible_count = self.visible_count - 1
    self:FadeToSelf(self.visible_count > 0)
end
function GameUIAllianceHome:FadeToSelf(isFullDisplay)
    self:stopAllActions()
    if isFullDisplay then
        self:show()
        transition.fadeIn(self, {
            time = 0.2,
        })
    else
        transition.fadeOut(self, {
            time = 0.2,
            onComplete = function()
                self:hide()
            end,
        })
    end
end
function GameUIAllianceHome:IsDisplayOn()
    return self.visible_count > 0
end


function GameUIAllianceHome:ctor(alliance)
    GameUIAllianceHome.super.ctor(self)
    self.alliance = alliance

    local sprite = display.newSprite("blue_tex.png"):addTo(self)
    :align(display.TOP_CENTER, display.cx, display.height)
    local size = sprite:getContentSize()
    sprite:setScaleX(display.width / size.width)
end
function GameUIAllianceHome:onEnter()
    GameUIAllianceHome.super.onEnter(self)
    -- 获取历史记录
    self.city = City
    self.visible_count = 1
    self.bottom = self:CreateBottom()

    local ratio = self.bottom:getScale()
    local rect1 = self.chat:getCascadeBoundingBox()
    local x, y = rect1.x, rect1.y + rect1.height - 2
    local march = WidgetMarchEvents.new(ratio):addTo(self):pos(x, y)
    self:AddMapChangeButton()
    scheduleAt(self, function()
        self:RefreshTop()
        self:UpdateCoordinate(display.getRunningScene():GetSceneLayer():GetMiddlePosition())
    end)
    self:InitArrow()
    -- 中间按钮
    UIKit:newWidgetUI("WidgetShortcutButtons",self.city):addTo(self)
    self.loading = display.newSprite("loading.png"):addTo(self):pos(rect1.x + 50, rect1.y + 80)
    self:HideLoading()
    self:AddOrRemoveListener(true)
    self:Schedule()
end
function GameUIAllianceHome:onExit()
    self:AddOrRemoveListener(false)
    GameUIAllianceHome.super.onExit(self)
end
function GameUIAllianceHome:AddOrRemoveListener(isAdd)
    local alliance = self.alliance
    if isAdd then
        alliance:AddListenOnType(self, "basicInfo")
    else
        alliance:RemoveListenerOnType(self, "basicInfo")
    end
end
function GameUIAllianceHome:ShowLoading()
    if self.loading:isVisible() and 
        self.loading:getNumberOfRunningActions() > 0 then 
        return 
    end
    self.loading:show():rotation(math.random(360)):stopAllActions()
    self.loading:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
end
function GameUIAllianceHome:HideLoading()
    self.loading:hide():stopAllActions()
end
function GameUIAllianceHome:AddMapChangeButton()
    WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE):addTo(self)
end
function GameUIAllianceHome:OnAllianceDataChanged_basicInfo(alliance,deltaData)
    local ok_honour, new_honour = deltaData("basicInfo.honour")
    local ok_status, new_status = deltaData("basicInfo.status")
    local ok_name, new_name = deltaData("basicInfo.name")
    local ok_tag, new_tag = deltaData("basicInfo.tag")
    local ok_flag, new_flag = deltaData("basicInfo.flag")
    if ok_honour then
        self.page_top:SetHonour(GameUtils:formatNumber(new_honour))
    elseif ok_status then
        if alliance.allianceFightReports then
            NetManager:getAllianceFightReportsPromise(self.alliance.id):done(function ( ... )
                if self.top then
                    self:RefreshTop()
                end
            end)
        else
            self:RefreshTop()
        end
        -- self.operation_button_order:RefreshOrder()
    elseif ok_name or ok_tag then
        self.self_name_label:setString("["..alliance.basicInfo.tag.."] ".. alliance.basicInfo.name)
    elseif ok_flag then
        self.self_flag:removeFromParent(true)
        -- 己方联盟旗帜
        local ui_helper = WidgetAllianceHelper.new()
        local self_flag = ui_helper:CreateFlagContentSprite(alliance.basicInfo.flag):scale(0.5)
        self_flag:align(display.CENTER, self.self_name_bg:getContentSize().width-100, -30):addTo(self.self_name_bg)
        self.self_flag = self_flag
    end

    if deltaData("basicInfo.status", "fight") then
        self.top:SetOurPowerOrKill(0)
        self.top:SetEnemyPowerOrKill(0)
    end
end
function GameUIAllianceHome:Schedule()
    local alliance = self.alliance
    -- display.newNode():addTo(self):schedule(function()
    --     if alliance:IsDefault() then return end
    --     local lx,ly,view = self.multialliancelayer:GetAllianceCoordWithPoint(display.cx, display.cy)
    --     self:UpdateCoordinate(lx, ly, view)
    -- end, 0.5)
    self:scheduleAt(function()
        if alliance:IsDefault() then return end
        self:UpdateMyCityArrows(alliance)
    end, 0.01)
    -- display.newNode():addTo(self):schedule(function()
    --     if alliance:IsDefault() then return end
    --     local lx,ly,view = self.multialliancelayer:GetAllianceCoordWithPoint(display.cx, display.cy)
    --     local layer = view:GetLayer()
    --     -- local x,y = alliance:FindMapObjectById(myself:MapId()):GetMidLogicPosition()
    --     -- self:UpdateMyAllianceBuildingArrows(screen_rect, alliance, layer)
    --     if not Alliance_Manager:GetMyAlliance():IsDefault() then
    --         self:UpdateFriendArrows(screen_rect, Alliance_Manager:GetMyAlliance(), layer, lx, ly, myself)
    --     end
    --     if Alliance_Manager:HaveEnemyAlliance() then
    --         self:UpdateEnemyArrows(screen_rect, Alliance_Manager:GetEnemyAlliance(), layer, lx, ly)
    --     end
    -- end, 0.05)
end

function GameUIAllianceHome:InitArrow()
    local rect1 = self.bottom:getCascadeBoundingBox()
    local rect2 = self.top_bg:getCascadeBoundingBox()
    self.screen_rect = cc.rect(0, rect1.height, display.width, rect2.y - rect1.height)

    -- my alliance building
    -- self.alliance_building_arrows = {}
    -- for i = 1, 5 do
    --     self.alliance_building_arrows[i] = display.newSprite("arrow_blue-hd.png")
    --         :addTo(self, -2):align(display.TOP_CENTER):hide()
    -- end
    -- self.allince_arrow_index = 1
    -- -- friends
    -- self.friends_arrows = {}
    -- self.friends_arrow_index = 1
    -- -- enemys
    -- self.enemy_arrows = {}
    -- self.enemy_arrow_index = 1

    -- my city
    self.arrow = cc.ui.UIPushButton.new({normal = "location_arrow_up.png",
        pressed = "location_arrow_down.png"})
        :addTo(self, -1):align(display.TOP_CENTER):hide()
        :onButtonClicked(function()
            self:ReturnMyCity()
        end)
    self.arrow_label = cc.ui.UILabel.new({
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xf5e8c4)
    }):addTo(self.arrow):rotation(90):align(display.LEFT_CENTER, 0, -40)
end
function GameUIAllianceHome:ReturnMyCity()
    local alliance = self.alliance
    local mapObject = alliance:FindMapObjectById(alliance:GetSelf().mapId)
    local location = mapObject.location
    local x,y = DataUtils:GetAbsolutePosition(alliance.mapIndex, location.x, location.y)
    display.getRunningScene():GotoPosition(x,y)
end

function GameUIAllianceHome:TopBg()
    local top_bg = display.newSprite("alliance_home_top_bg_768x116.png")
        :align(display.TOP_CENTER, window.cx, window.top)
        :addTo(self)
    if display.width >640 then
        top_bg:scale(display.width/768)
    end
    top_bg:setTouchEnabled(true)
    self.top_bg = top_bg

    top_bg:setTouchSwallowEnabled(true)
    local t_size = top_bg:getContentSize()

    -- 顶部背景,为按钮
    local top_self_bg = WidgetPushButton.new({normal = "button_blue_normal_314X88.png",
        pressed = "button_blue_pressed_314X88.png"})
        :onButtonClicked(handler(self, self.OnTopLeftButtonClicked))
        :align(display.TOP_CENTER, t_size.width/2-160, t_size.height-4)
        :addTo(top_bg)
    local top_enemy_bg = WidgetPushButton.new({normal = "button_red_normal_314X88.png",
        pressed = "button_red_pressed_314X88.png"})
        :onButtonClicked(handler(self, self.OnTopRightButtonClicked))
        :align(display.TOP_CENTER, t_size.width/2+160, t_size.height-4)
        :addTo(top_bg)

    return top_self_bg,top_enemy_bg,top_bg
end

function GameUIAllianceHome:TopTabButtons()
    self.page_top = WidgetAllianceTop.new(self.alliance):align(display.TOP_CENTER,self.top_bg:getContentSize().width/2,26)
        :addTo(self.top_bg)
end

function GameUIAllianceHome:RefreshTop(force_refresh)
    if self.alliance:IsDefault() then return end 
    local alliance = self.alliance
    -- 获取当前所在联盟
    local current_allinace_index = self.current_allinace_index
    local pre_status = self.pre_status
    local need_refresh = false
    local current_map_index = display.getRunningScene():GetSceneLayer():GetMiddleAllianceIndex()
    local need_refresh = current_allinace_index ~= current_map_index or pre_status ~= alliance.basicInfo.status
    if not need_refresh and not force_refresh then
        return
    end
    local top_bg = self.top_bg
    if top_bg then
        top_bg:removeFromParent()
    end
    local Top = {}
    local top_self_bg,top_enemy_bg,top_bg = self:TopBg()
    -- 己方联盟名字
    local self_name_bg = display.newSprite("title_green_292X32.png")
        :align(display.LEFT_CENTER, -147,-26)
        :addTo(top_self_bg):flipX(true)
    self.self_name_bg = self_name_bg
    self.self_name_label = UIKit:ttfLabel(
        {
            text = "["..alliance.basicInfo.tag.."] "..alliance.basicInfo.name,
            size = 18,
            color = 0xffedae,
            dimensions = cc.size(160,18),
            ellipsis = true
        }):align(display.LEFT_CENTER, 30, 20)
        :addTo(self_name_bg)
    -- 己方联盟旗帜
    local ui_helper = WidgetAllianceHelper.new()
    local self_flag = ui_helper:CreateFlagContentSprite(alliance.basicInfo.flag):scale(0.5)
    self_flag:align(display.CENTER, self_name_bg:getContentSize().width-100, -30):addTo(self_name_bg)
    self.self_flag = self_flag

    -- 和平期,战争期,准备期背景
    local period_bg = WidgetPushButton.new({normal = "box_104x104.png"})
        :onButtonClicked(function (event)
            if event.name == "CLICKED_EVENT" then
                UIKit:newWidgetUI("WidgetWarIntroduce"):AddToCurrentScene(true)
            end
        end)
        :align(display.TOP_CENTER, top_bg:getContentSize().width/2,top_bg:getContentSize().height)
        :addTo(top_bg)
    period_bg:setTouchSwallowEnabled(true)
    -- local period_bg = display.newSprite("box_104x104.png")
    --     :align(display.TOP_CENTER, top_bg:getContentSize().width/2,top_bg:getContentSize().height)
    --     :addTo(top_bg)

    local period_text = self:GetAlliancePeriod()
    local period_label = UIKit:ttfLabel(
        {
            text = period_text,
            size = 16,
            color = 0xbdb582
        }):align(display.TOP_CENTER, period_bg:getContentSize().width/2, period_bg:getContentSize().height-14)
        :addTo(period_bg)
    local time_label = UIKit:ttfLabel(
        {
            text = "",
            size = 18,
            color = 0xffedae
        }):align(display.BOTTOM_CENTER, period_bg:getContentSize().width/2, period_bg:getContentSize().height/2-62)
        :addTo(period_bg)
    scheduleAt(period_bg, function()
        local basicInfo = alliance.basicInfo
        if basicInfo.status then
            if basicInfo.status ~= "peace" then
                local statusFinishTime = basicInfo.statusFinishTime
                if math.floor(statusFinishTime/1000)>app.timer:GetServerTime() then
                    time_label:setString(GameUtils:formatTimeStyle1(math.floor(statusFinishTime/1000)-app.timer:GetServerTime()))
                end
            else
                local statusStartTime = basicInfo.statusStartTime
                if app.timer:GetServerTime()>= math.floor(statusStartTime/1000) then
                    time_label:setString(GameUtils:formatTimeStyle1(app.timer:GetServerTime()-math.floor(statusStartTime/1000)))
                end
            end
        end
    end)

    -- 敌方联盟名字 或者 占领联盟背景条
    local enemy_name_bg =  display.newSprite("title_red_292X32.png")
        :align(display.RIGHT_CENTER, 147,-26)
        :addTo(top_enemy_bg)
    local enemy_name_label = UIKit:ttfLabel(
        {
            text = "",
            size = 18,
            color = 0xffedae,
            dimensions = cc.size(160,18),
            ellipsis = true
        }):align(display.LEFT_CENTER, 100, 20)
        :addTo(enemy_name_bg)

    local status = alliance.basicInfo.status
    -- local status = "peace"
    if status == "peace" or status == "protect" then
        -- 己方战力
        local self_power_bg = display.newSprite("power_background_146x26.png")
            :align(display.LEFT_CENTER, -107, -65):addTo(top_self_bg)
        local our_num_icon = cc.ui.UIImage.new("dragon_strength_27x31.png"):align(display.CENTER, -107, -65):addTo(top_self_bg)
        local self_power_label = UIKit:ttfLabel(
            {
                text = string.formatnumberthousands(alliance.basicInfo.power),
                size = 20,
                color = 0xbdb582
            }):align(display.LEFT_CENTER, 20, self_power_bg:getContentSize().height/2)
            :addTo(self_power_bg)
        local other_alliance = Alliance_Manager:GetAllianceByCache(current_map_index)
        if current_map_index ~= alliance:MapIndex() and other_alliance then
            local enemy_flag = ui_helper:CreateFlagContentSprite(other_alliance.basicInfo.flag):scale(0.5)
            enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
                :addTo(enemy_name_bg)
            enemy_name_label:setString("["..other_alliance.basicInfo.tag.."] "..other_alliance.basicInfo.name)

            -- 敌方战力
            local enemy_power_bg = display.newSprite("power_background_146x26.png")
                :align(display.LEFT_CENTER, -20, -65):addTo(top_enemy_bg)
            local enemy_num_icon = cc.ui.UIImage.new("dragon_strength_27x31.png")
                :align(display.CENTER, 0, enemy_power_bg:getContentSize().height/2)
                :addTo(enemy_power_bg)
            local enemy_power_label = UIKit:ttfLabel(
                {
                    text = string.formatnumberthousands(other_alliance.basicInfo.power),
                    size = 20,
                    color = 0xbdb582
                }):align(display.LEFT_CENTER, 20, enemy_power_bg:getContentSize().height/2)
                :addTo(enemy_power_bg)
        else
            local fight_icon_66x66 = display.newSprite("icon_capture_80x72.png"):addTo(top_enemy_bg):align(display.LEFT_CENTER, -108,-37)
            enemy_name_label:align(display.CENTER, 220, 20)
            enemy_name_label:setString(_("占领联盟"))
            local capture_bg = display.newSprite("power_background_146x26_2.png")
                :align(display.LEFT_CENTER, -20, -65):addTo(top_enemy_bg)
            local capture_label = UIKit:ttfLabel(
                {
                    text = "0",
                    size = 20,
                    color = 0xbdb582
                }):align(display.CENTER, capture_bg:getContentSize().width/2, capture_bg:getContentSize().height/2)
                :addTo(capture_bg)
        end
    else
        local our_kill = alliance.allianceFight.attacker.alliance.id == alliance._id and alliance.allianceFight.attacker.allianceCountData.kill or alliance.allianceFight.defencer.alliance
        local enemy_kill = alliance.allianceFight.attacker.alliance.id == alliance._id and alliance.allianceFight.defencer.allianceCountData.kill or alliance.allianceFight.attacker.alliance

        -- 己方击杀
        local self_power_bg = display.newSprite("power_background_146x26.png")
            :align(display.LEFT_CENTER, -107, -65):addTo(top_self_bg)
        local our_num_icon = cc.ui.UIImage.new("battle_33x33.png"):align(display.CENTER, -107, -65):addTo(top_self_bg)
        local self_power_label = UIKit:ttfLabel(
            {
                text = string.formatnumberthousands(our_kill),
                size = 20,
                color = 0xbdb582
            }):align(display.LEFT_CENTER, 20, self_power_bg:getContentSize().height/2)
            :addTo(self_power_bg)

        local enemy_alliance = alliance._id == alliance.allianceFight.attacker.alliance.id and alliance.allianceFight.defencer or alliance.allianceFight.attacker
        enemy_name_label:setString("["..enemy_alliance.alliance.tag.."] "..enemy_alliance.alliance.name)
        local enemy_flag = ui_helper:CreateFlagContentSprite(enemy_alliance.alliance.flag):scale(0.5)
        enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
            :addTo(enemy_name_bg)

        -- 敌方击杀
        local enemy_power_bg = display.newSprite("power_background_146x26.png")
            :align(display.LEFT_CENTER, -20, -65):addTo(top_enemy_bg)
        local enemy_num_icon = cc.ui.UIImage.new("battle_33x33.png")
            :align(display.CENTER, 0, enemy_power_bg:getContentSize().height/2)
            :addTo(enemy_power_bg)
        local enemy_power_label = UIKit:ttfLabel(
            {
                text = string.formatnumberthousands(enemy_kill),
                size = 20,
                color = 0xbdb582
            }):align(display.LEFT_CENTER, 20, enemy_power_bg:getContentSize().height/2)
            :addTo(enemy_power_bg)
    end

    self.current_allinace_index = current_map_index
    self.pre_status = alliance.basicInfo.status
    self:TopTabButtons()

    local home = self
    function Top:Refresh()
        local alliance = home.alliance
        local status = alliance.basicInfo.status
        period_label:setString(home:GetAlliancePeriod())
        enemy_name_label:setVisible(status~="peace")
        -- 和平期
        if status=="peace" then
            enemy_peace_label:setVisible(true)
            fight_icon_66x66:setVisible(true)
            if enemy_name_bg:getChildByTag(201) then
                enemy_name_bg:removeChildByTag(201, true)
            end
        else
            fight_icon_66x66:setVisible(false)
            enemy_peace_label:setVisible(false)

            -- 敌方联盟旗帜
            if enemy_name_bg:getChildByTag(201) then
                enemy_name_bg:removeChildByTag(201, true)
            end
            if status=="fight" or status=="prepare" then
                local enemy_flag = ui_helper:CreateFlagContentSprite(enemyAlliance.basicInfo.flag):scale(0.5)
                enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
                    :addTo(enemy_name_bg)
                enemy_flag:setTag(201)
                enemy_name_label:setString("["..enemyAlliance.basicInfo.tag.."] "..enemyAlliance.basicInfo.name)
            elseif status=="protect" then
                local enemy_reprot_data = alliance:GetEnemyLastAllianceFightReportsData()
                local enemy_flag = ui_helper:CreateFlagContentSprite(enemy_reprot_data.flag):scale(0.5)
                enemy_flag:align(display.CENTER,100-enemy_flag:getCascadeBoundingBox().size.width, -30)
                    :addTo(enemy_name_bg)
                enemy_flag:setTag(201)
                enemy_name_label:setString("["..enemy_reprot_data.tag.."] "..enemy_reprot_data.name)
            end
        end
        if status=="fight"  then
            our_num_icon:setTexture("battle_33x33.png")
            enemy_num_icon:setTexture("battle_33x33.png")
            enemy_num_icon:scale(1.0)

            self:SetOurPowerOrKill(0)
            self:SetEnemyPowerOrKill(0)
        elseif status=="protect" then
            our_num_icon:setTexture("battle_33x33.png")
            enemy_num_icon:setTexture("battle_33x33.png")
            enemy_num_icon:scale(1.0)
            local our_reprot_data_kill = alliance:GetOurLastAllianceFightReportsData().kill
            local enemy_reprot_data_kill = alliance:GetEnemyLastAllianceFightReportsData().kill
            self:SetOurPowerOrKill(our_reprot_data_kill)
            self:SetEnemyPowerOrKill(enemy_reprot_data_kill)
        else
            if status~="peace" then
                enemy_num_icon:setTexture("dragon_strength_27x31.png")
                self:SetEnemyPowerOrKill(enemyAlliance.basicInfo.power)
                enemy_num_icon:scale(1.0)
            else
                enemy_num_icon:setTexture("res_citizen_88x82.png")
                enemy_num_icon:scale(0.4)
                self:SetEnemyPowerOrKill(0)
            end
            our_num_icon:setTexture("dragon_strength_27x31.png")
            self:SetOurPowerOrKill(alliance.basicInfo.power)
        end
    end
    function Top:SetOurPowerOrKill(num)
        self_power_label:setString(string.formatnumberthousands(num))
    end
    function Top:SetEnemyPowerOrKill(num)
        enemy_power_label:setString(string.formatnumberthousands(num))
    end
    return Top
end
function GameUIAllianceHome:CreateBottom()
    local bottom_bg = WidgetHomeBottom.new(self.city):addTo(self)
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)
    self.chat = WidgetChat.new():addTo(bottom_bg)
        :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height-11)
    return bottom_bg
end
function GameUIAllianceHome:ChangeChatChannel(channel_index)
    self.chat:ChangeChannel(channel_index)
end
function GameUIAllianceHome:OnTopLeftButtonClicked(event)
    if event.name == "CLICKED_EVENT" then
        UIKit:newGameUI("GameUIAllianceBattle", self.city , "history"):AddToCurrentScene(true)
    end
end
function GameUIAllianceHome:OnTopRightButtonClicked(event)
    if event.name == "CLICKED_EVENT" then
        local status = self.alliance.basicInfo.status
        local other_alliance = Alliance_Manager:GetAllianceByCache(self.current_allinace_index)
        local tag
        if other_alliance and self.current_allinace_index ~= self.alliance:MapIndex() or status == "prepare" or status == "fight" then
            tag = "fight"
        else
            tag = "capture"
        end
        UIKit:newGameUI("GameUIAllianceBattle", self.city , tag ,other_alliance):AddToCurrentScene(true)
    end
end
local deg = math.deg
local ceil = math.ceil
local point = cc.p
local pSub = cc.pSub
local pGetAngle = cc.pGetAngle
local pGetLength = cc.pGetLength
local rectContainsPoint = cc.rectContainsPoint
local RIGHT_CENTER = display.RIGHT_CENTER
local LEFT_CENTER = display.LEFT_CENTER
local MID_POINT = point(display.cx, display.cy)
local function pGetIntersectPoint(pt1,pt2,pt3,pt4)
    local s,t, ret = 0,0,false
    ret,s,t = cc.pIsLineIntersect(pt1,pt2,pt3,pt4,s,t)
    if ret then
        return point(pt1.x + s * (pt2.x - pt1.x), pt1.y + s * (pt2.y - pt1.y)), s
    else
        return point(0,0), s
    end
end
function GameUIAllianceHome:UpdateCoordinate(logic_x, logic_y, alliance_view)
    local coordinate_str = string.format("%d, %d", logic_x, logic_y)
    local is_mine
    if alliance_view then
        is_mine = alliance_view:GetAlliance().id == self.alliance.id and _("我方") or _("敌方")
    else
        is_mine = _("坐标")
    end
    self.page_top:SetCoordinateTitle(is_mine)
    self.page_top:SetCoordinate(coordinate_str)
end
function GameUIAllianceHome:UpdateMyCityArrows(alliance)
    local screen_rect = self.screen_rect
    local member = alliance:GetSelf()
    local mapObj = alliance:FindMapObjectById(member.mapId)
    local x,y = DataUtils:GetAbsolutePosition(alliance.mapIndex, mapObj.location.x, mapObj.location.y)
    local sceneLayer = display.getRunningScene():GetSceneLayer()
    local map_point = sceneLayer:ConvertLogicPositionToMapPosition(x,y)
    local world_point = sceneLayer:convertToWorldSpace(map_point)
    if not rectContainsPoint(screen_rect, world_point) then
        local p,degree = self:GetIntersectPoint(screen_rect, MID_POINT, world_point)
        if p and degree then
            degree = degree + 180
            self.arrow:show():pos(p.x, p.y):rotation(degree)

            local isflip = (degree > 0 and degree < 180)
            local distance = ceil(pGetLength(pSub(world_point, p)) / 80)
            self.arrow_label:align(isflip and RIGHT_CENTER or LEFT_CENTER)
                :scale(isflip and -1 or 1):setString(string.format("%dM", distance))
        end
    else
        self.arrow:hide()
    end
end
-- function GameUIAllianceHome:UpdateMyAllianceBuildingArrows(screen_rect, alliance, layer)
--     local id = alliance.id
--     local count = 1
--     alliance:IteratorAllianceBuildings(function(_, v)
--         if count == self.allince_arrow_index then
--             local arrow = self:GetMyAllianceArrow(count)
--             local x,y = v:GetMidLogicPosition()
--             local map_point = layer:ConvertLogicPositionToMapPosition(x, y, id)
--             local world_point = layer:convertToWorldSpace(map_point)
--             if not rectContainsPoint(screen_rect, world_point) then
--                 local p,degree = self:GetIntersectPoint(screen_rect, MID_POINT, world_point)
--                 if p and degree then
--                     arrow:show():pos(p.x, p.y):rotation(degree + 180)
--                 end
--             else
--                 arrow:hide()
--             end
--             return true
--         end
--         count = count + 1
--     end)
--     self.allince_arrow_index = self.allince_arrow_index + 1
--     if self.allince_arrow_index > 5 then
--         self.allince_arrow_index = 1
--     end
-- end
-- function GameUIAllianceHome:GetMyAllianceArrow(count)
--     return self.alliance_building_arrows[count]
-- end
local min = math.min
local MAX_ARROW_COUNT = 5
function GameUIAllianceHome:UpdateFriendArrows(screen_rect, alliance, layer, logic_x, logic_y, myself)
    local count = self:UpdateAllianceArrow(screen_rect, alliance, layer, logic_x, logic_y, self.friends_arrow_index, function(index)
        if not self.friends_arrows[index] then
            self.friends_arrows[index] = display.newSprite("arrow_blue-hd.png")
                :addTo(self, -2):align(display.TOP_CENTER):hide()
        end
        return self.friends_arrows[index]
    end, myself:MapId())
    local friends_arrows = self.friends_arrows
    for i = count, #friends_arrows do
        friends_arrows[i]:hide()
    end
    self.friends_arrow_index = self.friends_arrow_index + 1
    if self.friends_arrow_index > min(count, MAX_ARROW_COUNT) then
        self.friends_arrow_index = 1
    end
end
function GameUIAllianceHome:UpdateEnemyArrows(screen_rect, alliance, layer, logic_x, logic_y)
    local count = self:UpdateAllianceArrow(screen_rect, alliance, layer, logic_x, logic_y, self.enemy_arrow_index, function(index)
        if not self.enemy_arrows[index] then
            self.enemy_arrows[index] = display.newSprite("arrow_red-hd.png")
                :addTo(self, -2):align(display.TOP_CENTER):hide()
        end
        return self.enemy_arrows[index]
    end)
    local enemy_arrows = self.enemy_arrows
    for i = count, #enemy_arrows do
        enemy_arrows[i]:hide()
    end
    self.enemy_arrow_index = self.enemy_arrow_index + 1
    if self.enemy_arrow_index > min(count, MAX_ARROW_COUNT) then
        self.enemy_arrow_index = 1
    end
end
--
function GameUIAllianceHome:UpdateAllianceArrow(screen_rect, alliance, layer, logic_x, logic_y, cur_index, func, except_map_id)
    local id = alliance.id
    local count = 1
    alliance:IteratorCities(function(_, v)
        if count > MAX_ARROW_COUNT then return true end
        if count == cur_index and except_map_id ~= v.id then
            local x,y = v:GetMidLogicPosition()
            local dx, dy = (logic_x - x), (logic_y - y)
            if dx^2 + dy^2 > 1 then
                local arrow = func(count)
                local map_point = layer:ConvertLogicPositionToMapPosition(x, y, id)
                local world_point = layer:convertToWorldSpace(map_point)
                if not rectContainsPoint(screen_rect, world_point) then
                    local p,degree = self:GetIntersectPoint(screen_rect, MID_POINT, world_point)
                    if p and degree then
                        arrow:show():pos(p.x, p.y):rotation(degree + 180)
                    end
                else
                    arrow:hide()
                end
            end
        end
        count = count + 1
    end)
    return count
end
--
function GameUIAllianceHome:GetIntersectPoint(screen_rect, point1, point2, normal)
    local points = self:GetPointsWithScreenRect(screen_rect)
    for i = 1, #points do
        local p1, p2
        if i ~= #points then
            p1 = points[i]
            p2 = points[i + 1]
        else
            p1 = points[i]
            p2 = points[1]
        end
        local p,s = pGetIntersectPoint(point1, point2, p1, p2)
        if s > 0 and rectContainsPoint(screen_rect, p) then
            return p, deg(pGetAngle(pSub(point1, point2), normal or point(0, 1)))
        end
    end
end
function GameUIAllianceHome:GetPointsWithScreenRect(screen_rect)
    local x,y,w,h = screen_rect.x, screen_rect.y, screen_rect.width, screen_rect.height
    return {
        point(x + w, y),
        point(x + w, y + h),
        point(x, y + h),
        point(x, y),
    }
end

function GameUIAllianceHome:GetAlliancePeriod()
    local period = ""
    local status = self.alliance.basicInfo.status
    if status == "peace" then
        period = _("和平期")
    elseif status == "prepare" then
        period = _("准备期")
    elseif status == "fight" then
        period = _("战争期")
    elseif status == "protect" then
        period = _("保护期")
    end
    return period
end

return GameUIAllianceHome
































