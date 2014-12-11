--
-- Author: Danny He
-- Date: 2014-10-06 18:18:26
--
local Enum = import("..utils.Enum")
local window = import('..utils.window')
local UIScrollView = import(".UIScrollView")
local UIListView = import(".UIListView")
local WidgetBackGroundTabButtons = import("..widget.WidgetBackGroundTabButtons")
local GameUIAlliance = UIKit:createUIClass("GameUIAlliance","GameUIWithCommonHeader")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPushTransparentButton = import("..widget.WidgetPushTransparentButton")
local contentWidth = window.width - 80
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIAllianceBasicSetting = import(".GameUIAllianceBasicSetting")
local GameUIAllianceNoticeOrDescEdit = import(".GameUIAllianceNoticeOrDescEdit")
local Localize = import("..utils.Localize")
local NetService = import('..service.NetService')
local Alliance_Manager = Alliance_Manager
local Alliance = import("..entity.Alliance")
local WidgetAllianceUIHelper = import("..widget.WidgetAllianceUIHelper")
local Flag = import("..entity.Flag")
local GameUIWriteMail = import('.GameUIWriteMail')
GameUIAlliance.COMMON_LIST_ITEM_TYPE = Enum("JOIN","INVATE","APPLY")

--
--------------------------------------------------------------------------------
function GameUIAlliance:ctor()
    GameUIAlliance.super.ctor(self,City,_("联盟"))
    self.alliance_ui_helper = WidgetAllianceUIHelper.new()
end

function GameUIAlliance:OnBasicChanged(alliance, changed_map)
    if Alliance_Manager:GetMyAlliance():IsDefault() then return end
    if self.tab_buttons:GetSelectedButtonTag() == 'overview' then
        self:RefreshOverViewUI()
    end
    if self.tab_buttons:GetSelectedButtonTag() == 'members' then
        self:RefreshMemberList()
    end
    if self.tab_buttons:GetSelectedButtonTag() == 'infomation' then
        self:RefreshInfomationView()
    end
end

function GameUIAlliance:OnJoinEventsChanged(alliance,changed_map)

end

function GameUIAlliance:OnEventsChanged(alliance,changed_map)
    if self.tab_buttons:GetSelectedButtonTag() == 'overview' then
        self:RefreshEventListView()
    end
end

function GameUIAlliance:OnMemberChanged(alliance,changed_map)
    if self.tab_buttons:GetSelectedButtonTag() == 'members' then
        self:RefreshMemberList()
    end
end

function GameUIAlliance:OnOperation(alliance,operation_type)
    self:RefreshMainUI()
end

function GameUIAlliance:AddListenerOfMyAlliance()
    local myAlliance = Alliance_Manager:GetMyAlliance()
    myAlliance:AddListenOnType(self, Alliance.LISTEN_TYPE.BASIC)
    -- join or quit
    myAlliance:AddListenOnType(self, Alliance.LISTEN_TYPE.OPERATION)
    myAlliance:AddListenOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    myAlliance:AddListenOnType(self, Alliance.LISTEN_TYPE.EVENTS)
    myAlliance:AddListenOnType(self, Alliance.LISTEN_TYPE.JOIN_EVENTS)
end

function GameUIAlliance:Reset()
    self.createScrollView = nil
    self.joinNode = nil
    self.invateNode = nil
    self.applyNode = nil
    self.overviewNode = nil
    self.memberListView = nil
    self.informationNode = nil
    self.currentContent = nil
end

function GameUIAlliance:onEnter()
    GameUIAlliance.super.onEnter(self)
    self:RefreshMainUI()
end

function GameUIAlliance:RefreshMainUI()
    self:Reset()
    self.main_content:removeAllChildren()
    if Alliance_Manager:GetMyAlliance():IsDefault() then
        self:CreateNoAllianceUI()
        if not Alliance_Manager.open_alliance then
            self:CreateAllianceTips()
        end
    else
        self:CreateHaveAlliaceUI()
    end
end

function GameUIAlliance:CreateBetweenBgAndTitle()
    self.main_content = display.newNode():addTo(self):pos(window.left,window.bottom_top)
    self.main_content:setContentSize(cc.size(window.width,window.betweenHeaderAndTab))
end

function GameUIAlliance:onMoveInStage()
    GameUIAlliance.super.onMoveInStage(self)
    self:AddListenerOfMyAlliance()
end

function GameUIAlliance:onMoveOutStage()
    local myAlliance = Alliance_Manager:GetMyAlliance()
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    -- join or quit
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.OPERATION)
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.EVENTS)
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.JOIN_EVENTS)
    GameUIAlliance.super.onMoveOutStage(self)
end

------------------------------------------------------------------------------------------------
---- I did not have a alliance
------------------------------------------------------------------------------------------------

function GameUIAlliance:CreateNoAllianceUI()
    self.tab_buttons = self:CreateTabButtons(
        {
            {
                label = _("创建"),
                tag = "create",
                default = true,
            },
            {
                label = _("加入"),
                tag = "join",
            },
            {
                label = _("邀请"),
                tag = "invite",
            },
            {
                label = _("申请"),
                tag = "apply",
            },
        },
        function(tag)
            --call common tabButtons event
            if self["NoAllianceTabEvent_" .. tag .. "If"] then
                if self.currentContent then
                    self.currentContent:hide()
                end
                self.currentContent = self["NoAllianceTabEvent_" .. tag .. "If"](self)
                assert(self.currentContent)
                self.currentContent:show()
            end
        end
    ):pos(window.cx, window.bottom + 34)
end

function GameUIAlliance:CreateAllianceTips()
    Alliance_Manager.open_alliance = true
    local shadowLayer = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
        :addTo(self)
    local backgroundImage = WidgetUIBackGround.new({height=500}):addTo(shadowLayer):pos(window.left+20,window.top - 600)
    local titleBar = display.newSprite("title_blue_596x49.png")
        :align(display.TOP_LEFT, 6,backgroundImage:getContentSize().height - 6)
        :addTo(backgroundImage)
    local mainTitleLabel =  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("创建联盟"),
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    })
        :addTo(titleBar)
        :align(display.LEFT_BOTTOM, 10, 10)

    local closeButton = cc.ui.UIPushButton.new({normal = "X_2.png",pressed = "X_1.png"}, {scale9 = false})
        :addTo(titleBar)
        :align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+25, 10)
        :onButtonClicked(function ()
            shadowLayer:removeFromParent(true)
        end)
    -- display.newSprite("X_3.png")
    --     :addTo(closeButton)
    --     :pos(-32,30)

    local title_bg = display.newSprite("alliance_green_title_639x69.png")
        :addTo(backgroundImage)
        :align(display.LEFT_TOP, -15, titleBar:getPositionY()-titleBar:getContentSize().height-5)
    UIKit:ttfLabel({
        text = _("联盟的强大功能！"),
        size = 24,
        color = 0xffeca5
    }):addTo(title_bg):align(display.CENTER,title_bg:getContentSize().width/2,title_bg:getContentSize().height/2+5)

    local list_bg = GameUIAllianceBasicSetting.CreateBoxPanel(260)
    list_bg:pos(25,100):addTo(backgroundImage)

    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams ={
                text = _("确定"),
                size = 20,
                color = 0xfff3c7,
            },
            listener = function ()
                shadowLayer:removeFromParent(true)
            end,
        }
    ):pos(backgroundImage:getContentSize().width/2,50)
        :addTo(backgroundImage)
    closeButton = btn_bg.button
  
    local scrollView = UIListView.new {
        viewRect = cc.rect(0, 5, 552,250),
        direction = UIScrollView.DIRECTION_VERTICAL,
        alignment = UIListView.ALIGNMENT_LEFT
    }:addTo(list_bg)

    local tips = {_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),}
    for i,v in ipairs(tips) do
        local item = scrollView:newItem()
        local content = display.newNode()
        local star = display.newSprite("alliance_star_23x23.png"):addTo(content):align(display.LEFT_BOTTOM, 10, 10)
        UIKit:ttfLabel({
            text = v,
            size = 20,
            color = 0x403c2f,
            align = cc.TEXT_ALIGNMENT_LEFT
        }):addTo(content):align(display.LEFT_BOTTOM, star:getPositionX()+star:getContentSize().width+10, star:getPositionY()-2)
        item:addContent(content)
        item:setItemSize(552,content:getCascadeBoundingBox().height+20)
        scrollView:addItem(item)
    end
    scrollView:reload()
end

-- TabButtons event

--1 main
function GameUIAlliance:NoAllianceTabEvent_createIf()
    if self.createScrollView then
        return self.createScrollView
    end
    local basic_setting = GameUIAllianceBasicSetting.new()

    local scrollView = UIScrollView.new({
        viewRect = cc.rect(0,0,window.width,window.betweenHeaderAndTab),
    -- bgColor = UIKit:hex2c4b(0x7a000000),
    })
        :addScrollNode(basic_setting:GetContentNode():pos(55,0))
        :setDirection(UIScrollView.DIRECTION_VERTICAL)
        :addTo(self.main_content)
    scrollView:fixResetPostion(-50)
    self.createScrollView = scrollView
    basic_setting = nil
    return self.createScrollView
end

--2.join
function GameUIAlliance:NoAllianceTabEvent_joinIf()
    if self.joinNode then
        self:GetJoinList()
        return self.joinNode
    end
    local joinNode = display.newNode():addTo(self.main_content)
    self.joinNode = joinNode
    local searchIcon = display.newSprite("alliacne_search_29x33.png"):addTo(joinNode)
        :align(display.LEFT_TOP,40,self.main_content:getCascadeBoundingBox().height - 30)
    local function onEdit(event, editbox)
        if event == "return" then
            self:SearchAllianAction(self.editbox_tag_search:getText())
        end
    end

    local editbox_tag_search = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "alliance_editbox_575x48.png",
        size = cc.size(510,48),
        listener = onEdit,
    })

    editbox_tag_search:setPlaceHolder(_("搜索联盟标签"))
    editbox_tag_search:setMaxLength(600)
    editbox_tag_search:setFont(UIKit:getFontFilePath(),18)
    editbox_tag_search:setFontColor(cc.c3b(0,0,0))
    editbox_tag_search:setPlaceholderFontColor(UIKit:hex2c3b(0xccc49e))
    editbox_tag_search:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
    editbox_tag_search:align(display.LEFT_TOP,searchIcon:getPositionX()+searchIcon:getContentSize().width+10,self.main_content:getCascadeBoundingBox().height - 10):addTo(joinNode)
    self.editbox_tag_search = editbox_tag_search

    self.joinListView = UIListView.new {
        viewRect = cc.rect(20, 0,608,710),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(joinNode)
    self:GetJoinList()
    return joinNode
end

-- tag ~= nil -->search
function GameUIAlliance:GetJoinList(tag)
    if tag  then
        NetManager:getSearchAllianceByTagPromsie(tag):next(function(data)
            if #data.alliances > 0 then
                self:RefreshJoinListView(data.alliances)
            end
        end)
    else
        NetManager:getFetchCanDirectJoinAlliancesPromise():next(function(data)
            if #data.alliances > 0 then
                self:RefreshJoinListView(data.alliances)
            end
        end)
    end
end

function GameUIAlliance:RefreshJoinListView(data)
    assert(data)
    self.joinListView:removeAllItems()
    for i,v in ipairs(data) do
        local newItem = self:getCommonListItem_(self.COMMON_LIST_ITEM_TYPE.JOIN,v)
        self.joinListView:addItem(newItem)
    end
    self.joinListView:reload()
end

function GameUIAlliance:SearchAllianAction(tag)
    self:GetJoinList(tag)
end

--3.invite
function GameUIAlliance:NoAllianceTabEvent_inviteIf()
    if self.invateNode then
        self:RefreshInvateListView()
        return self.invateNode
    end
    local invateNode = display.newNode():addTo(self.main_content)
    self.invateNode = invateNode
    self.invateListView = UIListView.new {
        viewRect = cc.rect(20, 0,608,790),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(invateNode)
    self:RefreshInvateListView()
    return invateNode
end

function GameUIAlliance:RefreshInvateListView()
    local list = User:GetInviteEvents()
    self.invateListView:removeAllItems()
    for i,v in ipairs(list) do
        local item = self:getCommonListItem_(self.COMMON_LIST_ITEM_TYPE.INVATE,v)
        self.invateListView:addItem(item)
    end
    self.invateListView:reload()
end

function GameUIAlliance:NoAllianceTabEvent_applyIf()
    if self.applyNode then
        self:RefreshApplyListView()
        return self.applyNode
    end
    local applyNode = display.newNode():addTo(self.main_content)
    self.applyNode = applyNode
    self.applyListView = UIListView.new {
        viewRect = cc.rect(20, 0,608,790),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(applyNode)
    self:RefreshApplyListView()
    return applyNode
end

function GameUIAlliance:RefreshApplyListView()
    local list = User:GetRequestEvents()
    self.applyListView:removeAllItems()
    for i,v in ipairs(list) do
        local item = self:getCommonListItem_(self.COMMON_LIST_ITEM_TYPE.APPLY,v)
        self.applyListView:addItem(item)
    end
    self.applyListView:reload()
end

function GameUIAlliance:getAllianceArchonName( alliance )
    for _,v in ipairs(alliance.members) do
        if v.title == 'archon' then
            return v.name
        end
    end
end


--  listType:join appy invate
function GameUIAlliance:getCommonListItem_(listType,alliance)
    local targetListView = nil
    local item = nil
    local terrain,flag_info = nil,nil
    terrain = alliance.terrain
    flag_info = alliance.flag
    if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
        targetListView = self.joinListView
    elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then
        targetListView = self.invateListView
    else
        targetListView = self.applyListView
        -- terrain = alliance.terrain
        -- flag_info = alliance.flag
    end

    local item = targetListView:newItem()
    local bg = display.newSprite("alliance_search_item_bg_608x164.png"):align(display.LEFT_BOTTOM,0,0)
    local titleBg = display.newScale9Sprite("alliance_item_title_bg_588x30.png")
        :size(448,30)
        :addTo(bg)
        :align(display.RIGHT_TOP,590, 150)
    local nameLabel = UIKit:ttfLabel({
        text = alliance.name, -- alliance name
        size = 22,
        color = 0xffedae
    }):addTo(titleBg,2):align(display.LEFT_BOTTOM, 10, 5)

    local flag_box = display.newSprite("alliance_item_flag_box_126X126.png"):addTo(bg):align(display.LEFT_BOTTOM, 10, 22)
    local flag_sprite = self.alliance_ui_helper:CreateFlagWithRhombusTerrain(terrain,Flag.new():DecodeFromJson(flag_info))
    flag_sprite:addTo(flag_box):scale(0.8)
    flag_sprite:pos(60,40)
    local memberTitleLabel = UIKit:ttfLabel({
        text = _("成员"),
        size = 18,
        color = 0x797154
    }):addTo(bg):align(display.LEFT_TOP,flag_box:getPositionX()+flag_box:getContentSize().width+10,titleBg:getPositionY()-titleBg:getContentSize().height - 10)

    local memberValLabel = UIKit:ttfLabel({
        text = "14/50", --count of members
        size = 18,
        color = 0x403c2f
    }):addTo(bg):align(display.LEFT_TOP, memberTitleLabel:getContentSize().width+memberTitleLabel:getPositionX()+15, memberTitleLabel:getPositionY())


    local fightingTitleLabel = UIKit:ttfLabel({
        text = _("战斗力"),
        size = 18,
        color = 0x797154
    }):addTo(bg):align(display.LEFT_TOP, memberValLabel:getContentSize().width+memberValLabel:getPositionX()+200, memberValLabel:getPositionY())

    local fightingValLabel = UIKit:ttfLabel({
        text = alliance.power,
        size = 18,
        color = 0x403c2f
    }):addTo(bg):align(display.LEFT_TOP, fightingTitleLabel:getContentSize().width+fightingTitleLabel:getPositionX()+15, fightingTitleLabel:getPositionY())


    local languageTitleLabel = UIKit:ttfLabel({
        text = _("语言"),
        size = 18,
        color = 0x797154
    }):addTo(bg):align(display.LEFT_TOP,memberTitleLabel:getPositionX(), memberTitleLabel:getPositionY() - memberTitleLabel:getContentSize().height-5)

    local languageValLabel = UIKit:ttfLabel({
        text = alliance.language, -- language
        size = 18,
        color = 0x403c2f
    }):addTo(bg):align(display.LEFT_BOTTOM,languageTitleLabel:getPositionX()+languageTitleLabel:getContentSize().width+15,languageTitleLabel:getPositionY()-languageTitleLabel:getContentSize().height)


    local killTitleLabel = UIKit:ttfLabel({
        text = _("击杀"),
        size = 18,
        color = 0x797154,
        align = ui.TEXT_ALIGN_RIGHT,
    }):addTo(bg):align(display.RIGHT_BOTTOM, fightingTitleLabel:getPositionX()+fightingTitleLabel:getContentSize().width, languageValLabel:getPositionY())

    local killValLabel = UIKit:ttfLabel({
        text = alliance.kill,
        size = 18,
        color = 0x403c2f
    }):addTo(bg):align(display.LEFT_BOTTOM, killTitleLabel:getPositionX()+15, killTitleLabel:getPositionY())


    if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
        local leaderIcon = display.newSprite("alliance_item_leader_39x39.png")
            :addTo(bg)
            :align(display.LEFT_TOP,languageTitleLabel:getPositionX(), languageTitleLabel:getPositionY()-20)
        local leaderLabel = UIKit:ttfLabel({
            text = alliance.archon,
            size = 22,
            color = 0x403c2f
        }):addTo(bg):align(display.LEFT_TOP,leaderIcon:getPositionX()+leaderIcon:getContentSize().width+15, languageTitleLabel:getPositionY()-30)
        local buttonNormalPng,buttonHighlightPng,buttonText
        if alliance.joinType == 'all' then
            buttonNormalPng = "yellow_button_146x42.png"
            buttonHighlightPng = "yellow_button_highlight_146x42.png"
            buttonText = _("加入")

        else
            buttonNormalPng = "blue_btn_up_142x39.png"
            buttonHighlightPng = "blue_btn_down_142x39.png"
            buttonText = _("申请")
        end

        WidgetPushButton.new({normal = buttonNormalPng,pressed = buttonHighlightPng},{scale9 = true})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = buttonText,
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :setButtonSize(147,45)
            :align(display.RIGHT_TOP,titleBg:getPositionX(),languageTitleLabel:getPositionY()-25)
            :onButtonClicked(function(event)
                self:commonListItemAction(listType,item,alliance)
            end)
            :addTo(bg)
        nameLabel:setString(alliance.name)
        memberValLabel:setString(alliance.members .. "/50")
        fightingValLabel:setString(alliance.power)
        languageValLabel:setString(alliance.language)
        killValLabel:setString(alliance.kill)

    elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then
        local rejectButton = WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"},{scale9 = true})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = _("拒绝"),
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :setButtonSize(146,42)
            :align(display.LEFT_TOP,languageTitleLabel:getPositionX(), languageTitleLabel:getPositionY()-25)
            :onButtonClicked(function(event)
                self:commonListItemAction(listType,item,alliance,1)
            end)
            :addTo(bg)

        local argreeButton = WidgetPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"},{scale9 = true})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = _("同意"),
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :setButtonSize(146,42)
            :align(display.RIGHT_TOP,titleBg:getPositionX(), languageTitleLabel:getPositionY()-25)
            :onButtonClicked(function(event)
                self:commonListItemAction(listType,item,alliance,2)
            end)
            :addTo(bg)
    elseif listType == self.COMMON_LIST_ITEM_TYPE.APPLY then
        local info_bg = display.newScale9Sprite("alliance_info_587x34.png")
            :size(220,34)
            :addTo(bg)
            :align(display.LEFT_TOP,languageTitleLabel:getPositionX(), languageTitleLabel:getPositionY()-30)

        UIKit:ttfLabel({
            text = _("等待对方审核"),
            size = 18,
            color = 0x797154,
        }):addTo(info_bg,2):align(display.CENTER, 110, 17)
        WidgetPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"},{scale9 = true})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = _("撤销"),
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :setButtonSize(146,42)
            :align(display.RIGHT_TOP,titleBg:getPositionX(), languageTitleLabel:getPositionY()-25)
            :onButtonClicked(function(event)
                self:commonListItemAction(listType,item,alliance)
            end)
            :addTo(bg)
        nameLabel:setString(alliance.name)
        memberValLabel:setString(alliance.members .. "/50")
        fightingValLabel:setString(alliance.power)
        languageValLabel:setString(alliance.language)
        killValLabel:setString(alliance.kill)
    end
    item:addContent(bg)
    item:setItemSize(bg:getContentSize().width,bg:getContentSize().height)
    return item
        -- end
end


function GameUIAlliance:commonListItemAction( listType,item,alliance,tag)
    if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
        if  alliance.joinType == 'all' then --如果是直接加入
            NetManager:getJoinAllianceDirectlyPromise(alliance.id):done()
        else
            NetManager:getRequestToJoinAlliancePromise(alliance.id):next(function()
                local dialog = FullScreenPopDialogUI.new()
                dialog:SetTitle(_("申请成功"))
                dialog:SetPopMessage(string.format(_("您的申请已发送至%s,如果被接受将加入该联盟,如果被拒绝,将收到一封通知邮件."),alliance.name))
                dialog:AddToCurrentScene()
            end)
        end
    elseif  listType == self.COMMON_LIST_ITEM_TYPE.APPLY then
        NetManager:getCancelJoinAlliancePromise(alliance.id):done(function()
            self:RefreshApplyListView()
        end)
    elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then
        -- tag == 1 -> 拒绝
        NetManager:getHandleJoinAllianceInvitePromise(alliance.id,tag~=1):done(function()
            self:RefreshInvateListView()
        end)
    end
end

------------------------------------------------------------------------------------------------
---- I have join in a alliance
------------------------------------------------------------------------------------------------
function GameUIAlliance:CreateHaveAlliaceUI()
    self.tab_buttons = self:CreateTabButtons(
        {
            {
                label = _("总览"),
                tag = "overview",
                default = true,
            },
            {
                label = _("成员"),
                tag = "members",
            },
            {
                label = _("信息"),
                tag = "infomation",
            }
        },
        function(tag)
            if self['HaveAlliaceUI_' .. tag .. 'If'] then
                if self.currentContent then
                    self.currentContent:hide()
                end
                self.currentContent = self["HaveAlliaceUI_" .. tag .. "If"](self)
                self.currentContent:show()
            end
        end
    ):pos(window.cx, window.bottom + 34)
end

--总览
function GameUIAlliance:HaveAlliaceUI_overviewIf()
    if self.overviewNode then return self.overviewNode end
    self.ui_overview = {}
    local overviewNode = display.newNode():addTo(self.main_content)

    local events_bg = display.newSprite("alliance_events_bg_540x356.png")
        :addTo(overviewNode):align(display.CENTER_BOTTOM, window.width/2,0)

    local eventListView = UIListView.new {
        viewRect = cc.rect(0, 12, 540,340),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(events_bg)
    self.eventListView = eventListView
    self:RefreshEventListView()

    local events_title = display.newSprite("alliance_evnets_title_548x50.png")
        :addTo(overviewNode):align(display.CENTER_BOTTOM,window.width/2,events_bg:getPositionY()+events_bg:getContentSize().height)
    UIKit:ttfLabel({
        text = _("事件记录"),
        size = 22,
        color = 0xffedae,
    }):addTo(events_title):align(display.CENTER,events_title:getContentSize().width/2,events_title:getContentSize().height/2)

    local headerBg  = WidgetUIBackGround.new({height=330}):addTo(overviewNode,-1):pos(18,events_title:getPositionY()+events_title:getContentSize().height+20)

    local titileBar = display.newSprite("alliance_blue_title_600x42.png"):addTo(overviewNode):align(display.CENTER_BOTTOM,window.width/2,headerBg:getPositionY()+headerBg:getCascadeBoundingBox().height-15)

    WidgetPushButton.new({normal = "chat_setting.png"})
        :align(display.RIGHT_BOTTOM,545,10)
        :addTo(titileBar)
        :scale(0.4)
        :onButtonClicked(handler(self, self.OnAllianceSettingButtonClicked))
    self.ui_overview.nameLabel = UIKit:ttfLabel({
        text = Alliance_Manager:GetMyAlliance():Name(),
        size = 24,
        color = 0xffedae,
    }):align(display.LEFT_BOTTOM,170,10):addTo(titileBar)

    local notice_bg = display.newSprite("alliance_notice_bg_576x174.png")
        :align(display.LEFT_BOTTOM,15,15)
        :addTo(headerBg)

    local noticeView = UIListView.new {
        viewRect =  cc.rect(10,2,556,170),
        direction = UIScrollView.DIRECTION_VERTICAL,
        alignment = UIListView.ALIGNMENT_LEFT
    }:addTo(notice_bg)
    self.ui_overview.noticeView = noticeView

    self:RefreshNoticeView()
    display.newSprite("alliance_notice_box_584x180.png"):align(display.LEFT_BOTTOM,13,15)
        :addTo(headerBg)

    local notice_button = WidgetPushButton.new({normal = "alliance_notice_button_normal_372x44.png",pressed = "alliance_notice_button_highlight_372x44.png"})
        :setButtonLabel('normal',UIKit:ttfLabel({
            text = _("联盟公告"),
            size = 22,
            color = 0xffedae,
        })
        )
        :onButtonClicked(function(event)
            UIKit:newGameUI('GameUIAllianceNoticeOrDescEdit',GameUIAllianceNoticeOrDescEdit.EDIT_TYPE.ALLIANCE_NOTICE)
                :addToCurrentScene(true)
        end)
        :addTo(headerBg)
        :align(display.LEFT_BOTTOM, 120,notice_bg:getPositionY()+notice_bg:getContentSize().height-5)
    display.newSprite("alliance_notice_icon_26x26.png"):addTo(notice_button):pos(250,22)


    self.ui_overview.my_alliance_flag = self.alliance_ui_helper:CreateFlagWithRhombusTerrain(Alliance_Manager:GetMyAlliance():TerrainType(),Alliance_Manager:GetMyAlliance():Flag())
        :addTo(overviewNode)
        :pos(100,titileBar:getPositionY() - 65)
    local tagLabel = UIKit:ttfLabel({
        text = _("标签"),
        size = 22,
        color = 0x797154,
    }):addTo(headerBg):align(display.LEFT_BOTTOM,170,270)

    local tagLabelVal = UIKit:ttfLabel({
        text = Alliance_Manager:GetMyAlliance():AliasName(),
        size = 22,
        color = 0x403c2f,
    })
        :addTo(headerBg)
        :align(display.LEFT_BOTTOM,tagLabel:getPositionX()+tagLabel:getContentSize().width+20,tagLabel:getPositionY())

    self.ui_overview.tagLabel = tagLabelVal
    local languageLabel = UIKit:ttfLabel({
        text = _("语言"),
        size = 22,
        color = 0x797154,
    }):addTo(headerBg):align(display.LEFT_BOTTOM,tagLabelVal:getPositionX()+tagLabelVal:getContentSize().width+100,tagLabel:getPositionY())


    local languageLabelVal =  UIKit:ttfLabel({
        text = Alliance_Manager:GetMyAlliance():DefaultLanguage(),
        size = 22,
        color = 0x403c2f,
    }):addTo(headerBg):align(display.LEFT_BOTTOM,languageLabel:getPositionX()+languageLabel:getContentSize().width+20,tagLabel:getPositionY())
    self.ui_overview.languageLabel = languageLabelVal
    local line = display.newSprite("dividing_line.png"):addTo(headerBg):align(display.LEFT_TOP,tagLabel:getPositionX() - 15,tagLabel:getPositionY()- 20)



    self.overviewNode = overviewNode
    return self.overviewNode
end

function GameUIAlliance:RefreshNoticeView()
    local textLabel = UIKit:ttfLabel({
        dimensions = cc.size(576, 0),
        text = string.len(Alliance_Manager:GetMyAlliance():Notice())>0 and Alliance_Manager:GetMyAlliance():Notice() or _("未设置联盟公告"),
        size = 20,
        color = 0x403c2f,
    })
    self.ui_overview.noticeView:removeAllItems()
    local textItem = self.ui_overview.noticeView:newItem()
    textItem:addContent(textLabel)
    textItem:setItemSize(576,textLabel:getContentSize().height)
    self.ui_overview.noticeView:addItem(textItem)
    self.ui_overview.noticeView:reload()
end

function GameUIAlliance:GetEventItemByIndexAndEvent(index,event)
    local item = self.eventListView:newItem()
    local bg = display.newSprite(string.format("alliance_events_bg_520x84_%d.png",index%2))
    local title_bg_image = self:GetEventTitleImageByEvent(event)
    local title_bg = display.newSprite(title_bg_image):addTo(bg):align(display.LEFT_TOP, 0,70)
    UIKit:ttfLabel({
        text = event.key or "",
        size = 20,
        color = 0xffedae
    }):addTo(title_bg):align(display.LEFT_BOTTOM,10,5)

    UIKit:ttfLabel({
        text = GameUtils:formatTimeStyle2(event.time/1000),
        size = 18,
        color = 0x797154
    }):addTo(bg):align(display.LEFT_BOTTOM,10, 5)
    local contentLabel = UIKit:ttfLabel({
        text = self:GetEventContent(event),
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(300, 60)
    }):align(display.LEFT_CENTER,0,0)
    contentLabel:pos(title_bg:getPositionX()+title_bg:getContentSize().width + 10,42)
    contentLabel:addTo(bg)
    --end
    item:addContent(bg)
    item:setItemSize(520,84)
    return item
end

function GameUIAlliance:GetEventContent(event)
    local event_type = event.type
    return string.format(Localize.alliance_events[event_type],unpack(event.params))
end


function GameUIAlliance:GetEventTitleImageByEvent(event)
    local category = event.category
    if category == 'normal' then
        return "alliance_event_type_cyan_222x30.png"
    elseif category == 'important' then
        return "alliance_event_type_green_222x30.png"
    elseif category == 'war' then
        return "alliance_event_type_red_222x30.png"
    end
end

function GameUIAlliance:RefreshOverViewUI()
    self:RefreshEventListView()
    if self.ui_overview and self.tab_buttons:GetSelectedButtonTag() == 'overview' then
        local alliance_data = Alliance_Manager:GetMyAlliance()
        self.ui_overview.nameLabel:setString(alliance_data:Name())
        self.ui_overview.tagLabel:setString(alliance_data:AliasName())
        self.ui_overview.languageLabel:setString(alliance_data:DefaultLanguage())
        if self.ui_overview.my_alliance_flag then
            local x,y = self.ui_overview.my_alliance_flag:getPosition()
            self.ui_overview.my_alliance_flag:removeFromParent()
            self.ui_overview.my_alliance_flag = self.alliance_ui_helper:CreateFlagWithRhombusTerrain(Alliance_Manager:GetMyAlliance():TerrainType(),Alliance_Manager:GetMyAlliance():Flag())
                :addTo(self.overviewNode)
                :pos(x,y)
        end
        self:RefreshNoticeView()
    end
end

function GameUIAlliance:RefreshEventListView()
    local events = Alliance_Manager:GetMyAlliance():GetEvents()
    self.eventListView:removeAllItems()
    for i,v in ipairs(events) do
        local item = self:GetEventItemByIndexAndEvent(i,v)
        self.eventListView:addItem(item)
    end
    self.eventListView:reload()
end

function GameUIAlliance:OnAllianceSettingButtonClicked(event)
    UIKit:newGameUI('GameUIAllianceBasicSetting',true):addToCurrentScene(true)
end

--成员

function GameUIAlliance:HaveAlliaceUI_membersIf()
    if self.memberListView then self:RefreshMemberList() return self.memberListView end
    local listView = UIListView.new {
        viewRect = cc.rect(0, 0, 608,window.betweenHeaderAndTab),
        direction = UIScrollView.DIRECTION_VERTICAL,
        alignment = UIListView.ALIGNMENT_LEFT
    }:addTo(self.main_content):pos(20,0)
    self.memberListView = listView
    self:RefreshMemberList()
    return self.memberListView
end

function GameUIAlliance:RefreshMemberList()
    assert(self.memberListView)
    self.memberListView:removeAllItems()

    local item = self:GetMemberItem("archon")
    self.memberListView:addItem(item)
    item = self:GetMemberItem("general")
    self.memberListView:addItem(item)
    item = self:GetMemberItem("quartermaster")
    self.memberListView:addItem(item)

    item = self:GetMemberItem("supervisor")
    self.memberListView:addItem(item)
    item = self:GetMemberItem("elite")
    self.memberListView:addItem(item)
    item = self:GetMemberItem("member")
    self.memberListView:addItem(item)



    self.memberListView:reload()
end

function GameUIAlliance:GetAllianceTitleAndLevelPng(title)
    local levelImages = {
        general = "5_23x24.png",
        quartermaster = "4_32x24.png",
        supervisor = "3_35x24.png",
        elite = "2_23x24.png",
        member = "1_11x24.png",
        archon = "alliance_item_leader_39x39.png"
    }
    local alliance = Alliance_Manager:GetMyAlliance()
    return alliance:GetTitles()[title],levelImages[title]
end

--title is alliance title
function GameUIAlliance:GetMemberItem(title)
    local item = self.memberListView:newItem()
    local filter_data = LuaUtils:table_filter(Alliance_Manager:GetMyAlliance():GetAllMembers(),function(k,v)
        return v:Title() == title
    end)
    local data = {}
    table.foreach(filter_data,function(k,v)
        table.insert(data,v)
    end)
    local header_title,number_image = "",""

    if title == 'archon' then
        local node = WidgetUIBackGround.new({height = 118})
        local title_bar = display.newSprite("alliance_archon_frame_604x148.png")
            :addTo(node)
            :align(display.LEFT_BOTTOM,0,0)
        local display_title,imageName = self:GetAllianceTitleAndLevelPng(title)
        local icon = display.newSprite(imageName)
            :align(display.TOP_LEFT,200, title_bar:getContentSize().height)
            :addTo(title_bar)

        local titleLabel = UIKit:ttfLabel({
            text = display_title,
            size = 22,
            color = 0xffedae,
        }):align(display.LEFT_BOTTOM, icon:getPositionX()+icon:getContentSize().width+10,icon:getPositionY() - icon:getContentSize().height+5)
            :addTo(title_bar)

        display.newSprite("i_8x17.png"):align(display.RIGHT_BOTTOM, 420, icon:getPositionY()-icon:getContentSize().height + 10)
            :addTo(title_bar)

        WidgetPushTransparentButton.new(cc.rect(0,0,372,44)):align(display.LEFT_TOP, 100,148)
            :addTo(title_bar):onButtonClicked(function ()
            self:OnAllianceTitleClicked(title)
            end)

        local box = display.newSprite("alliance_item_flag_box_126X126.png")
            :scale(0.7)
            :addTo(title_bar)
            :align(display.LEFT_BOTTOM,12,12)
        self:GetAllianceMemberIcon():addTo(box):pos(63,63)
        local line = display.newScale9Sprite("dividing_line_594x2.png"):addTo(title_bar)
            :align(display.LEFT_BOTTOM,box:getPositionX()+box:getContentSize().width*0.7,60)
            :size(498,2)
        local nameLabel = UIKit:ttfLabel({
            text = data[1].name,
            size = 22,
            color = 0x403c2f,
        }):addTo(title_bar):align(display.LEFT_BOTTOM,line:getPositionX()+20, line:getPositionY() + 10)

        local lvLabel =  UIKit:ttfLabel({
            text = "LV " .. data[1].level,
            size = 22,
            color = 0x797154,
        }):addTo(title_bar):align(display.LEFT_BOTTOM,nameLabel:getPositionX()+200, line:getPositionY() + 10)
        local powerIcon = display.newSprite("upgrade_power_icon.png")
            :align(display.LEFT_BOTTOM,lvLabel:getPositionX()+lvLabel:getContentSize().width+50,lvLabel:getPositionY())
            :addTo(title_bar):scale(0.5)
        local powerLabel = UIKit:ttfLabel({
            -- text = string.formatnumberthousands(21321312321),
            text = string.formatnumberthousands(data[1].power),
            size = 22,
            color = 0x403c2f,
            align = cc.TEXT_ALIGNMENT_LEFT,
        }):addTo(title_bar):align(display.LEFT_BOTTOM,powerIcon:getPositionX()+powerIcon:getContentSize().width*0.5+10,powerIcon:getPositionY())
        local loginLabel = UIKit:ttfLabel({
            text = _("最后登陆时间:") .. NetService:formatTimeAsTimeAgoStyleByServerTime(data[1].lastLoginTime),
            size = 22,
            color = 0x403c2f,
        }):addTo(title_bar):align(display.LEFT_BOTTOM, nameLabel:getPositionX(),line:getPositionY() - 40)
        --
        item:addContent(node)
        item:setItemSize(608,node:getCascadeBoundingBox().height)
        if DataManager:getUserData()._id ~= data[1].id then
            WidgetPushButton.new({normal = "alliacne_search_29x33.png"})
                :align(display.RIGHT_BOTTOM,588,loginLabel:getPositionY())
                :addTo(node)
                :onButtonClicked(function()
                    self:OnPlayerDetailButtonClicked(data[1].id)
                end)
        end
        return item
    else
        header_title,number_image = self:GetAllianceTitleAndLevelPng(title)
    end
    local height = 70
    local x,y = 7,20
    local contentNode = display.newNode()
    local oneLine = nil
    for i,v in ipairs(data) do
        oneLine = self:GetNormalSubItem(v.name,v.level,v.power,v.id)
        oneLine:pos(x,y+(i-1)*height)
        oneLine:addTo(contentNode)
    end

    local bg = nil
    if #data > 0 then
        assert(oneLine)
        bg = WidgetUIBackGround.new({height=oneLine:getPositionY()+height+20})
    else
        contentNode = UIKit:ttfLabel({
            text = _("该职位还未任命给任何成员"),
            size = 22,
            color = 0x403c2f,
        }):align(display.CENTER_BOTTOM,304,20)
        bg = WidgetUIBackGround.new({height=80})
    end
    contentNode:addTo(bg)
    local bar = display.newSprite("alliance_blue_title_600x42.png"):addTo(bg):align(display.LEFT_BOTTOM, 3, bg:getCascadeBoundingBox().height-35)
    local num = display.newSprite(number_image):addTo(bar):align(display.LEFT_BOTTOM,bar:getContentSize().width/2 - 10,10)
    UIKit:ttfLabel({
        text = header_title,
        size = 22,
        color = 0xffedae,
    }):addTo(bar):align(display.LEFT_BOTTOM, num:getPositionX()+num:getContentSize().width + 2, num:getPositionY())
    display.newSprite("i_8x17.png"):align(display.RIGHT_BOTTOM, 550, num:getPositionY()+2)
        :addTo(bar)
    WidgetPushTransparentButton.new(cc.rect(0,0,600,42)):align(display.LEFT_BOTTOM, 0,0)
        :addTo(bar):onButtonClicked(function ()
        self:OnAllianceTitleClicked(title)
        end)
    item:addContent(bg)
    item:setItemSize(608,bg:getCascadeBoundingBox().height)
    return item
end

function GameUIAlliance:GetNormalSubItem(playerName,level,power,memberId)
    local itemNode =  display.newNode()
    local line = display.newScale9Sprite("dividing_line_594x2.png"):addTo(itemNode)
        :align(display.LEFT_BOTTOM,0,0)
        :size(594,2)
    local icon = self:GetAllianceMemberIcon():scale(0.5):align(display.LEFT_BOTTOM,10,line:getPositionY()+10):addTo(itemNode)
    local nameLabel = UIKit:ttfLabel({
        text = playerName,
        size = 22,
        color = 0x403c2f,
    }):addTo(itemNode)
        :align(display.LEFT_CENTER,icon:getPositionX()+icon:getContentSize().width*0.5 + 20,line:getPositionY()+line:getContentSize().height+ 10 + icon:getContentSize().height*0.5/2)

    local lvLabel =  UIKit:ttfLabel({
        text = "LV " .. level,
        size = 22,
        color = 0x797154,
    }):addTo(itemNode):align(display.LEFT_CENTER,nameLabel:getPositionX()+200, nameLabel:getPositionY())

    local powerIcon = display.newSprite("upgrade_power_icon.png")
        :align(display.LEFT_CENTER,lvLabel:getPositionX()+lvLabel:getContentSize().width+50,lvLabel:getPositionY())
        :addTo(itemNode):scale(0.5)
    local powerLabel = UIKit:ttfLabel({
        text = string.formatnumberthousands(power),
        size = 22,
        color = 0x403c2f,
        align = cc.TEXT_ALIGNMENT_LEFT,
    }):addTo(itemNode):align(display.LEFT_CENTER,powerIcon:getPositionX()+powerIcon:getContentSize().width*0.5+10,powerIcon:getPositionY())
    if DataManager:getUserData()._id ~= memberId then
        WidgetPushButton.new({normal = "alliacne_search_29x33.png"})
            :align(display.RIGHT_CENTER,588,powerLabel:getPositionY())
            :addTo(itemNode)
            :onButtonClicked(function()
                self:OnPlayerDetailButtonClicked(memberId)
            end)
    end
    return itemNode
end

function GameUIAlliance:GetAllianceMemberIcon()
    local heroBg = display.newSprite("chat_hero_background.png")
    local hero = display.newSprite("Hero_1.png"):align(display.CENTER, math.floor(heroBg:getContentSize().width/2), math.floor(heroBg:getContentSize().height/2)+5)
    hero:addTo(heroBg)
    return heroBg
end

function GameUIAlliance:OnAllianceTitleClicked( title )
    UIKit:newGameUI('GameUIAllianceTitle',title):addToCurrentScene(true)
end

function GameUIAlliance:OnPlayerDetailButtonClicked(memberId)
    UIKit:newGameUI('GameUIPlayerInfo',false,memberId):addToCurrentScene(true)
end
-- 信息
function GameUIAlliance:HaveAlliaceUI_infomationIf()
    if self.informationNode then return self.informationNode end
    local informationNode = WidgetUIBackGround.new({height=556}):addTo(self.main_content):pos(20,window.betweenHeaderAndTab-556)
    self.informationNode = informationNode

    local notice_bg = display.newSprite("alliance_notice_bg_576x174.png")
        :align(display.LEFT_TOP,15,556 - 45)
        :addTo(informationNode)



    local descView = UIListView.new {
        viewRect =  cc.rect(10,2,556,170),
        direction = UIScrollView.DIRECTION_VERTICAL,
        alignment = UIListView.ALIGNMENT_LEFT
    }:addTo(notice_bg)
    self.descListView = descView


    display.newSprite("alliance_notice_box_584x180.png"):align(display.LEFT_TOP,13,notice_bg:getPositionY())
        :addTo(informationNode)

    local notice_button = WidgetPushButton.new({normal = "alliance_notice_button_normal_372x44.png",pressed = "alliance_notice_button_highlight_372x44.png"})
        :setButtonLabel('normal',UIKit:ttfLabel({
            text = _("联盟描述"),
            size = 22,
            color = 0xffedae,
        })
        )
        :onButtonClicked(function(event)
            UIKit:newGameUI('GameUIAllianceNoticeOrDescEdit',GameUIAllianceNoticeOrDescEdit.EDIT_TYPE.ALLIANCE_DESC)
                :addToCurrentScene(true)
        end)
        :addTo(informationNode)
        :align(display.LEFT_BOTTOM, 120,notice_bg:getPositionY()-10)
    display.newSprite("alliance_notice_icon_26x26.png"):addTo(notice_button):pos(250,22)
    local checkbox_image = {
        off = "checkbox_unselected.png",
        off_pressed = "checkbox_unselected.png",
        off_disabled = "checkbox_unselected.png",
        on = "checkbox_selectd.png",
        on_pressed = "checkbox_selectd.png",
        on_disabled = "checkbox_selectd.png",

    }
    self.joinTypeButton = cc.ui.UICheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("允许玩家立即加入联盟"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_CENTER)
            :setButtonSelected(Alliance_Manager:GetMyAlliance():JoinType() == "all"))
        :addButton(cc.ui.UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("玩家仅能通过申请或者邀请的方式加入"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_CENTER)
            :setButtonSelected(Alliance_Manager:GetMyAlliance():JoinType() ~= "all"))
        :onButtonSelectChanged(handler(self, self.OnAllianceJoinTypeButtonClicked))
        :addTo(informationNode)
        :pos(notice_bg:getPositionX(),notice_bg:getPositionY() - notice_bg:getContentSize().height - 100)
    local line = display.newSprite("dividing_line_594x2.png")
        :addTo(informationNode)
        :align(display.LEFT_TOP,7,self.joinTypeButton:getPositionY() - 50)

    local button_bg = display.newSprite("alliance_info_btn_bg_513x100.png"):align(display.TOP_CENTER,304,line:getPositionY() - 30):addTo(informationNode)
    local x = 0
    local button_imags = {"alliance_sign_out_56x50.png","alliance_invitation_39x59.png","alliance_apply_55x54.png","alliance_group_mail_62x48.png"}
    local button_texts = {_("退出联盟"),_("邀请加入"),_("审批申请"),_("群邮件")}
    for i=1,4 do
        local button = cc.ui.UIPushButton.new({normal = 'chat_tab_button.png',pressed = "chat_tab_button_highlight.png"}):align(display.LEFT_BOTTOM,128*(i-1), 0)
            :addTo(button_bg)
            :onButtonClicked(function(event)
                self:OnInfoButtonClicked(i)
            end)
            :setButtonLabel("normal",UIKit:ttfLabel({text = button_texts[i],size = 18,color = 0x403c2f}))
            :setButtonLabelOffset(0, -35)
        display.newSprite(button_imags[i]):addTo(button):pos(64,59)
    end
    -- self:SelectJoinType()
    self:RefreshDescView()
    return self.informationNode
end

function GameUIAlliance:SelectJoinType()
    if Alliance_Manager:GetMyAlliance():JoinType() == "all" then
        self.joinTypeButton:getButtonAtIndex(1):setButtonSelected(true)
    else
        self.joinTypeButton:getButtonAtIndex(2):setButtonSelected(true)
    end
end

function GameUIAlliance:RefreshDescView()
    local textLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = string.len(Alliance_Manager:GetMyAlliance():Describe())>0 and Alliance_Manager:GetMyAlliance():Describe() or _("未设置联盟描述"),
        size = 20,
        color = UIKit:hex2c3b(0x403c2f),
        dimensions = cc.size(576, 0),
        font = UIKit:getFontFilePath(),
    })
    self.descListView:removeAllItems()
    local textItem = self.descListView:newItem()
    textItem:addContent(textLabel)
    textItem:setItemSize(576,textLabel:getContentSize().height)
    self.descListView:addItem(textItem)
    self.descListView:reload()
end

function GameUIAlliance:OnAllianceJoinTypeButtonClicked(event)
    if self.fromCancel then
        self.fromCancel = nil
        return
    end
    local title,join_type = _("允许玩家立即加入联盟"),"all"

    if event.selected ~= 1 then
        title = _("玩家仅能通过申请或者邀请的方式加入")
        join_type = "audit"
    end
    FullScreenPopDialogUI.new():SetTitle(_("提示"))
        :SetPopMessage(_("你将设置联盟加入方式为") .. title)
        :CreateOKButton(function ()
            NetManager:getEditAllianceJoinTypePromise(join_type):catch(function(err)
                dump(err:reason())
            end):done(function(result)
                self:RefreshInfomationView()
            end)
        end,_("确定"))
        :CreateCancelButton({listener = function ()
            self.fromCancel = true
            self:SelectJoinType()
        end,btn_name = _("取消")})
        :AddToCurrentScene()
end


function GameUIAlliance:RefreshInfomationView()
    self:RefreshDescView()
    self:SelectJoinType()
end

function GameUIAlliance:OnInfoButtonClicked(tag)
    if tag == 1 then
        FullScreenPopDialogUI.new():SetTitle(_("退出联盟"))
            :SetPopMessage(_("您必须在没有部队在外行军的情况下，才可以退出联盟。退出联盟会损失当前未打开的联盟礼物。"))
            :CreateOKButton(function()
                NetManager:getQuitAlliancePromise():done()
            end)
            :AddToCurrentScene()
    elseif tag == 2 then
        self:CreateInvateUI()
    elseif tag == 3 then
        UIKit:newGameUI("GameAllianceApproval"):addToCurrentScene(true)
    elseif tag == 4 then -- 邮件
        local mail = GameUIWriteMail.new()
        mail:SetTitle(_("联盟邮件"))
        mail:SetAddressee(_("发送联盟所有成员"))
        mail:OnSendButtonClicked( GameUIWriteMail.SEND_TYPE.ALLIANCE_MAIL)
        mail:addTo(self)
    end
end

function GameUIAlliance:CreateInvateUI()
    local layer = UIKit:shadowLayer()
    local bg = WidgetUIBackGround.new({height=150}):addTo(layer):pos(window.left+20,window.cy-20)
    local title_bar = display.newSprite("alliance_blue_title_600x42.png")
        :addTo(bg)
        :align(display.LEFT_BOTTOM, 0,150-15)

    local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
        :addTo(title_bar)
        :align(display.BOTTOM_RIGHT,title_bar:getContentSize().width+10, 0)
        :onButtonClicked(function ()
            layer:removeFromParent(true)
        end)
    -- display.newSprite("X_3.png")
    --     :addTo(closeButton)
    --     :pos(-32,30)
    UIKit:ttfLabel({
        text = _("邀请加入联盟"),
        size = 22,
        color = 0xffedae
    }):addTo(title_bar):align(display.LEFT_BOTTOM, 100, 10)

    UIKit:ttfLabel({
        text = _("邀请玩家加入"),
        size = 20,
        color = 0x797154
    }):addTo(bg):align(display.LEFT_TOP, 20,150-40)

    local editbox = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(422,40),
    })
    editbox:setFont(UIKit:getFontFilePath(),18)
    editbox:setFontColor(UIKit:hex2c3b(0xccc49e))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.RIGHT_TOP,608-20,150-30):addTo(bg)

    cc.ui.UIPushButton.new({normal= "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :addTo(bg):align(display.RIGHT_BOTTOM,editbox:getPositionX(), 20)
        :onButtonClicked(function()
            local playerName = string.trim(editbox:getText())
            if string.len(playerName) == 0 then
                FullScreenPopDialogUI.new():SetTitle(_("提示"))
                    :SetPopMessage(_("请输入邀请的玩家名称"))
                    :CreateOKButton(function()end)
                    :AddToCurrentScene()
                return
            end
            NetManager:getInviteToJoinAlliancePromise(playerName)
                :next(function(result)
                    layer:removeFromParent(true)
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(_("邀请发送成功"))
                        :CreateOKButton(function()end)
                        :AddToCurrentScene()
                end)
                :catch(function(err)
                    FullScreenPopDialogUI.new():SetTitle(_("提示"))
                        :SetPopMessage(err:reason())
                        :CreateOKButton(function()end)
                        :AddToCurrentScene()
                end)
        end)
        :setButtonLabel("normal",UIKit:ttfLabel({
            text = _("发送"),
            size = 22,
            color = 0xffedae,
            shadow = true
        }))

    layer:addTo(self)
end


return GameUIAlliance

