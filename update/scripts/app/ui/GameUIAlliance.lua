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
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetAllianceCreateOrEdit = import("..widget.WidgetAllianceCreateOrEdit")
local GameUIAllianceNoticeOrDescEdit = import(".GameUIAllianceNoticeOrDescEdit")
local Localize = import("..utils.Localize")
local NetService = import('..service.NetService')
local Alliance_Manager = Alliance_Manager
local Alliance = import("..entity.Alliance")
local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local Flag = import("..entity.Flag")
local GameUIWriteMail = import('.GameUIWriteMail')
local UILib = import(".UILib")
local UICheckBoxButton = import(".UICheckBoxButton")
local UICanCanelCheckBoxButtonGroup = import('.UICanCanelCheckBoxButtonGroup')
GameUIAlliance.COMMON_LIST_ITEM_TYPE = Enum("JOIN","INVATE","APPLY")

--
--------------------------------------------------------------------------------
function GameUIAlliance:ctor()
    GameUIAlliance.super.ctor(self,City,_("联盟"))
    self.alliance_ui_helper = WidgetAllianceHelper.new()
end

function GameUIAlliance:OnBasicChanged(alliance, changed_map)
    if Alliance_Manager:GetMyAlliance():IsDefault() then return end
    if self.tab_buttons:GetSelectedButtonTag() == 'overview' then
        if changed_map.flag then
            self:RefreshFlag()
        else
            self:RefreshOverViewUI()
        end
    end
    if self.tab_buttons:GetSelectedButtonTag() == 'members' then
        self:RefreshMemberList()
    end
    if self.tab_buttons:GetSelectedButtonTag() == 'infomation' then
        self:RefreshInfomationView()
    end
end

function GameUIAlliance:OnJoinEventsChanged(alliance)

end

function GameUIAlliance:OnEventsChanged(alliance)
    if self.tab_buttons:GetSelectedButtonTag() == 'overview' then
        self:RefreshEventListView()
    end
end

function GameUIAlliance:OnMemberChanged(alliance)
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
    self.member_list_bg = nil
end

function GameUIAlliance:OnMoveInStage()
    GameUIAlliance.super.OnMoveInStage(self)
    self:RefreshMainUI()
    self:AddListenerOfMyAlliance()
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
    self.main_content = display.newNode():addTo(self:GetView()):pos(window.left,window.bottom_top)
    self.main_content:setContentSize(cc.size(window.width,window.betweenHeaderAndTab))
end

-- function GameUIAlliance:OnMoveInStage()
--     GameUIAlliance.super.OnMoveInStage(self)
--     self:AddListenerOfMyAlliance()
-- end

function GameUIAlliance:OnMoveOutStage()
    local myAlliance = Alliance_Manager:GetMyAlliance()
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.BASIC)
    -- join or quit
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.OPERATION)
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.EVENTS)
    myAlliance:RemoveListenerOnType(self, Alliance.LISTEN_TYPE.JOIN_EVENTS)
    GameUIAlliance.super.OnMoveOutStage(self)
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
        :addTo(self:GetView())
    local backgroundImage = WidgetUIBackGround.new({height=542}):addTo(shadowLayer):pos(window.left+20,window.top - 700)
    local titleBar = display.newSprite("title_blue_600x52.png")
        :pos(backgroundImage:getContentSize().width/2, backgroundImage:getContentSize().height+8)
        :addTo(backgroundImage)
    local mainTitleLabel = UIKit:ttfLabel({
        text = _("创建联盟"),
        size = 24,
        color= 0xffedae
    })
        :addTo(titleBar)
        :align(display.CENTER,titleBar:getContentSize().width/2,titleBar:getContentSize().height/2)
    UIKit:closeButton()
        :align(display.BOTTOM_RIGHT,titleBar:getContentSize().width,0)
        :addTo(titleBar)
        :onButtonClicked(function(event)
            shadowLayer:removeFromParent()
        end)
    local title_bg = display.newSprite("green_title_639x39.png")
        :addTo(backgroundImage)
        :align(display.LEFT_TOP, -15, titleBar:getPositionY()-titleBar:getContentSize().height/2-5)
    UIKit:ttfLabel({
        text = _("联盟的强大功能！"),
        size = 24,
        color= 0xffeca5,
        shadow=true,
    }):addTo(title_bg):align(display.CENTER,title_bg:getContentSize().width/2,title_bg:getContentSize().height/2+5)

    local list_bg = display.newScale9Sprite("box_bg_546x214.png")
        :size(572,354)
        :addTo(backgroundImage)
        :align(display.TOP_CENTER, backgroundImage:getContentSize().width/2, title_bg:getPositionY() - title_bg:getContentSize().height - 5)
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
        viewRect = cc.rect(13,10, 546, 334),
        direction = UIScrollView.DIRECTION_VERTICAL,
        alignment = UIListView.ALIGNMENT_LEFT,
    }:addTo(list_bg)

    local tips = {_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护"),_("将城市迁入联盟领地，受到联盟保护")}
    for i,v in ipairs(tips) do
        local item = scrollView:newItem()
        local content = display.newNode()
        local png = string.format("resource_item_bg%d.png",i % 2)
        display.newScale9Sprite(png):size(546,48):align(display.LEFT_BOTTOM,0,0):addTo(content)
        local star = display.newSprite("alliance_star_23x23.png"):addTo(content):align(display.LEFT_BOTTOM, 10, 10)
        UIKit:ttfLabel({
            text = v,
            size = 20,
            color = 0x403c2f,
            align = cc.TEXT_ALIGNMENT_LEFT
        }):addTo(content):align(display.LEFT_BOTTOM, star:getPositionX()+star:getContentSize().width+10, star:getPositionY()-2)
        item:addContent(content)
        item:setItemSize(546,48)
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
    local basic_setting = WidgetAllianceCreateOrEdit.new()

    local scrollView = UIScrollView.new({
        viewRect = cc.rect(0,10,window.width,window.betweenHeaderAndTab),
    })
        :addScrollNode(basic_setting:pos(55,0))
        :setDirection(UIScrollView.DIRECTION_VERTICAL)
        :addTo(self.main_content)
    scrollView:fixResetPostion(3)
    self.createScrollView = scrollView
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
    editbox_tag_search:setPlaceholderFontColor(UIKit:hex2c3b(0xccc49e))
    editbox_tag_search:setMaxLength(600)
    editbox_tag_search:setFont(UIKit:getEditBoxFont(),18)
    editbox_tag_search:setFontColor(cc.c3b(0,0,0))
    editbox_tag_search:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
    editbox_tag_search:align(display.LEFT_TOP,searchIcon:getPositionX()+searchIcon:getContentSize().width+10,self.main_content:getCascadeBoundingBox().height - 10):addTo(joinNode)
    self.editbox_tag_search = editbox_tag_search
    local list,list_node = UIKit:commonListView({
        direction = UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(20, 0,608,680),
    })
    list_node:addTo(joinNode):pos(15,30)
    self.joinListView = list
    self:GetJoinList()
    return joinNode
end

-- tag ~= nil -->search
function GameUIAlliance:GetJoinList(tag)
    if tag then
        NetManager:getSearchAllianceByTagPromsie(tag):done(function(response)
            if not response.msg or not response.msg.allianceDatas then return end
            if #response.msg.allianceDatas > 0 then
                self:RefreshJoinListView(response.msg.allianceDatas)
            end
        end)
    else
        NetManager:getFetchCanDirectJoinAlliancesPromise():done(function(response)
            if not response.msg or not response.msg.allianceDatas then return end
            if #response.msg.allianceDatas > 0 then
                self:RefreshJoinListView(response.msg.allianceDatas)
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
    local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0, 0,608,710),
        direction = UIScrollView.DIRECTION_VERTICAL,
    })
    list_node:addTo(invateNode):pos(15,30)
    UIKit:ttfLabel({
        text = _("下列联盟邀请你加入"),
        size = 22,
        color= 0x797154,
        align = cc.TEXT_ALIGNMENT_CENTER
    }):align(display.BOTTOM_CENTER,window.cx,760):addTo(invateNode)
    self.invateListView = list
    self:RefreshInvateListView()
    return invateNode
end

function GameUIAlliance:RefreshInvateListView()
    local list = User:InviteToAllianceEvents()
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
    local list,list_node = UIKit:commonListView({
        viewRect = cc.rect(0, 0,608,710),
        direction = UIScrollView.DIRECTION_VERTICAL,
    })
    list_node:addTo(applyNode):pos(15,30)
    self.applyListView = list
    UIKit:ttfLabel({
        text = _("下列等待联盟审批"),
        size = 22,
        color= 0x797154,
        align = cc.TEXT_ALIGNMENT_CENTER
    }):align(display.BOTTOM_CENTER,window.cx,760):addTo(applyNode)
    self:RefreshApplyListView()
    return applyNode
end

function GameUIAlliance:RefreshApplyListView()
    local list = User:RequestToAllianceEvents()
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
    dump(alliance,"alliance----->")
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
    end

    local item = targetListView:newItem()
    local bg = WidgetUIBackGround.new({width = 568,height = 206},WidgetUIBackGround.STYLE_TYPE.STYLE_2)

    local flag_box = display.newScale9Sprite("alliance_item_flag_box_126X126.png")
        :size(100,100)
        :addTo(bg)
        :align(display.LEFT_TOP, 6, bg:getContentSize().height - 10)

    local flag_sprite = self.alliance_ui_helper:CreateFlagWithRhombusTerrain(terrain,Flag.new():DecodeFromJson(flag_info))
    flag_sprite:addTo(flag_box):scale(0.6)
    flag_sprite:pos(50,40)

    local titleBg = display.newScale9Sprite("alliance_event_type_cyan_222x30.png",0,0, cc.size(438,30), cc.rect(7,7,190,16))
        :addTo(bg)
        :align(display.RIGHT_TOP,bg:getContentSize().width-10, bg:getContentSize().height - 10)
    local nameLabel = UIKit:ttfLabel({
        text = alliance.name, -- alliance name
        size = 22,
        color = 0xffedae
    }):addTo(titleBg):align(display.LEFT_CENTER,10, 15)
    local info_bg = UIKit:CreateBoxPanelWithBorder({height = 82})
        :align(display.LEFT_BOTTOM, flag_box:getPositionX(),10)
        :addTo(bg)
    local memberTitleLabel = UIKit:ttfLabel({
        text = _("成员"),
        size = 20,
        color = 0x797154
    }):addTo(info_bg):align(display.LEFT_TOP,10,info_bg:getContentSize().height - 10)

    local memberValLabel = UIKit:ttfLabel({
        text = "14/50", --count of members
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_TOP,70, memberTitleLabel:getPositionY())


    local fightingTitleLabel = UIKit:ttfLabel({
        text = _("战斗力"),
        size = 20,
        color = 0x797154
    }):addTo(info_bg):align(display.LEFT_TOP, 340, memberTitleLabel:getPositionY())

    local fightingValLabel = UIKit:ttfLabel({
        text = alliance.power,
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_TOP, 430, fightingTitleLabel:getPositionY())


    local languageTitleLabel = UIKit:ttfLabel({
        text = _("语言"),
        size = 20,
        color = 0x797154
    }):addTo(info_bg):align(display.LEFT_BOTTOM,memberTitleLabel:getPositionX(),10)

    local languageValLabel = UIKit:ttfLabel({
        text = alliance.language, -- language
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_BOTTOM,memberValLabel:getPositionX(),10)


    local killTitleLabel = UIKit:ttfLabel({
        text = _("击杀"),
        size = 20,
        color = 0x797154,
        align = ui.TEXT_ALIGN_RIGHT,
    }):addTo(info_bg):align(display.LEFT_BOTTOM, fightingTitleLabel:getPositionX(),10)

    local killValLabel = UIKit:ttfLabel({
        text = alliance.kill,
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_BOTTOM, fightingValLabel:getPositionX(), 10)


    if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
        local leaderIcon = display.newSprite("alliance_item_leader_39x39.png")
            :addTo(bg)
            :align(display.LEFT_TOP,titleBg:getPositionX() - titleBg:getContentSize().width, titleBg:getPositionY() - titleBg:getContentSize().height -12)
        local leaderLabel = UIKit:ttfLabel({
            text = alliance.archon,
            size = 22,
            color = 0x403c2f
        }):addTo(bg):align(display.LEFT_TOP,leaderIcon:getPositionX()+leaderIcon:getContentSize().width+15, leaderIcon:getPositionY()-4)
        local buttonNormalPng,buttonHighlightPng,buttonText
        if alliance.joinType == 'all' then
            buttonNormalPng = "yellow_btn_up_148x58.png"
            buttonHighlightPng = "yellow_btn_down_148x58.png"
            buttonText = _("加入")

        else
            buttonNormalPng = "blue_btn_up_148x58.png"
            buttonHighlightPng = "blue_btn_down_148x58.png"
            buttonText = _("申请")
        end

        WidgetPushButton.new({normal = buttonNormalPng,pressed = buttonHighlightPng})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = buttonText,
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :align(display.RIGHT_TOP,titleBg:getPositionX(),titleBg:getPositionY() - titleBg:getContentSize().height -10)
            :onButtonClicked(function(event)
                self:commonListItemAction(listType,item,alliance)
            end)
            :addTo(bg)
        nameLabel:setString(alliance.name)
        memberValLabel:setString(alliance.members .. "/50") --TODO:联盟人数限制
        fightingValLabel:setString(alliance.power)
        languageValLabel:setString(alliance.language)
        killValLabel:setString(alliance.kill)

    elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then

        local argreeButton = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = _("同意"),
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :align(display.RIGHT_TOP,titleBg:getPositionX(),titleBg:getPositionY() - titleBg:getContentSize().height -10)
            :onButtonClicked(function(event)
                self:commonListItemAction(listType,item,alliance,2)
            end)
            :addTo(bg)
        local rejectButton = WidgetPushButton.new({normal = "red_btn_up_148x58.png",pressed = "red_btn_down_148x58.png"})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = _("拒绝"),
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :align(display.RIGHT_TOP,argreeButton:getPositionX() - 148 - 20, argreeButton:getPositionY())
            :onButtonClicked(function(event)
                self:commonListItemAction(listType,item,alliance,1)
            end)
            :addTo(bg)
    elseif listType == self.COMMON_LIST_ITEM_TYPE.APPLY then
        local cancel_button = WidgetPushButton.new({normal = "red_btn_up_148x58.png",pressed = "red_btn_down_148x58.png"})
            :setButtonLabel(
                UIKit:ttfLabel({
                    text = _("撤销"),
                    size = 20,
                    shadow = true,
                    color = 0xfff3c7
                })
            )
            :align(display.RIGHT_TOP,titleBg:getPositionX(), titleBg:getPositionY() - titleBg:getContentSize().height -10)
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
end


function GameUIAlliance:commonListItemAction( listType,item,alliance,tag)
    if listType == self.COMMON_LIST_ITEM_TYPE.JOIN then
        if  alliance.joinType == 'all' then --如果是直接加入
            NetManager:getJoinAllianceDirectlyPromise(alliance.id):fail(function()
                self:SearchAllianAction(self.editbox_tag_search:getText())
            end)
        else
            NetManager:getRequestToJoinAlliancePromise(alliance.id):done(function()
                UIKit:showMessageDialog(_("申请成功"),
                    string.format(_("您的申请已发送至%s,如果被接受将加入该联盟,如果被拒绝,将收到一封通知邮件."),alliance.name),
                    function()end)
            end):fail(function()
                self:SearchAllianAction(self.editbox_tag_search:getText())
            end)
        end
    elseif  listType == self.COMMON_LIST_ITEM_TYPE.APPLY then
        NetManager:getCancelJoinAlliancePromise(alliance.id):done(function()
            self:RefreshApplyListView()
        end)
    elseif listType == self.COMMON_LIST_ITEM_TYPE.INVATE then
        -- tag == 1 -> 拒绝
        NetManager:getHandleJoinAllianceInvitePromise(alliance.id,tag~=1):done(function()
            if tag == 1 then
                self:RefreshInvateListView()
            end
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
    if self.overviewNode then 
        self:RefreshEventListView()
        return self.overviewNode end
    self.ui_overview = {}
    local overviewNode = display.newNode():addTo(self.main_content)

    local events_bg = display.newSprite("alliance_events_bg_540x356.png")
        :addTo(overviewNode):align(display.CENTER_BOTTOM, window.width/2,10)

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

    local headerBg  = WidgetUIBackGround.new({height=376,isFrame="yes"}):addTo(overviewNode,-1)
        :pos(18,events_title:getPositionY()+events_title:getContentSize().height+10)
    local titileBar = display.newScale9Sprite("alliance_event_type_cyan_222x30.png",0,0, cc.size(438,30), cc.rect(7,7,190,16))
        :addTo(headerBg):align(display.TOP_RIGHT, headerBg:getContentSize().width - 10, headerBg:getContentSize().height - 20)
    local flag_box = display.newScale9Sprite("alliance_item_flag_box_126X126.png"):size(134,134)
        :align(display.TOP_LEFT,20, headerBg:getContentSize().height - 20):addTo(headerBg)
    self.flag_box = flag_box
    self.ui_overview.nameLabel = UIKit:ttfLabel({
        text = Alliance_Manager:GetMyAlliance():Name(),
        size = 24,
        color = 0xffedae,
    }):align(display.LEFT_CENTER,10,15):addTo(titileBar)

    self.ui_overview.my_alliance_flag = self.alliance_ui_helper:CreateFlagWithRhombusTerrain(Alliance_Manager:GetMyAlliance():Terrain(),Alliance_Manager:GetMyAlliance():Flag())
        :addTo(flag_box)
        :pos(70,50):scale(0.8)
    display.newSprite("info_26x26.png"):align(display.LEFT_BOTTOM, 0, 0):addTo(flag_box)
    WidgetPushTransparentButton.new(cc.rect(0,0,134,134))
        :align(display.LEFT_BOTTOM,0,0)
        :addTo(flag_box)
        :onButtonClicked(handler(self, self.OnAllianceSettingButtonClicked))


    local notice_bg = display.newSprite("alliance_notice_box_580x184.png")
        :addTo(headerBg):align(display.CENTER_BOTTOM,headerBg:getContentSize().width/2, 20)

    local noticeView = UIListView.new {
        viewRect =  cc.rect(21,14,537,123),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(notice_bg)
    self.ui_overview.noticeView = noticeView

    self:RefreshNoticeView()

    local notice_button = WidgetPushButton.new({normal = "alliance_notice_button_normal_310x36.png",pressed = "alliance_notice_button_highlight_310x36.png"})
        :setButtonLabel('normal',UIKit:ttfLabel({
            text = _("联盟公告"),
            size = 22,
            color = 0xffedae,
        })
        )
        :onButtonClicked(function(event)
            if not Alliance_Manager:GetMyAlliance():GetSelf():CanEditAllianceNotice() then
                UIKit:showMessageDialog(_("提示"), _("您没有此操作权限"), function()end)
                return
            end
            UIKit:newGameUI('GameUIAllianceNoticeOrDescEdit',GameUIAllianceNoticeOrDescEdit.EDIT_TYPE.ALLIANCE_NOTICE)
                :AddToCurrentScene(true)
        end)
        :addTo(notice_bg)
        :align(display.TOP_CENTER,292,181)
    display.newSprite("alliance_notice_icon_26x26.png"):addTo(notice_button):pos(70,-18)


    local line_2 = display.newSprite("dividing_line.png")
        :addTo(headerBg)
        :align(display.LEFT_BOTTOM,titileBar:getPositionX() - titileBar:getContentSize().width + 10,flag_box:getPositionY() - flag_box:getContentSize().height+5)
    local languageLabel = UIKit:ttfLabel({
        text = _("语言"),
        size = 22,
        color = 0x797154,
    }):addTo(headerBg):align(display.LEFT_BOTTOM,line_2:getPositionX()+5,line_2:getPositionY() + 5)

    local languageLabelVal =  UIKit:ttfLabel({
        text = Alliance_Manager:GetMyAlliance():DefaultLanguage(),
        size = 22,
        color= 0x403c2f,
        align= cc.TEXT_ALIGNMENT_RIGHT
    }):addTo(headerBg):align(display.RIGHT_BOTTOM,line_2:getPositionX()+line_2:getContentSize().width - 5,languageLabel:getPositionY())
    self.ui_overview.languageLabel = languageLabelVal


    local line_1 = display.newSprite("dividing_line.png")
        :addTo(headerBg)
        :align(display.LEFT_TOP,titileBar:getPositionX() - titileBar:getContentSize().width + 10,titileBar:getPositionY() - titileBar:getContentSize().height - 50)

    local tagLabel = UIKit:ttfLabel({
        text = _("标签"),
        size = 22,
        color = 0x797154,
    }):addTo(headerBg)
        :align(display.LEFT_BOTTOM,languageLabel:getPositionX(),line_1:getPositionY() + 5)

    local tagLabelVal = UIKit:ttfLabel({
        text = Alliance_Manager:GetMyAlliance():AliasName(),
        size = 22,
        color = 0x403c2f,
    })
        :addTo(headerBg)
        :align(display.RIGHT_BOTTOM,languageLabelVal:getPositionX(),tagLabel:getPositionY())

    self.ui_overview.tagLabel = tagLabelVal
    self.overviewNode = overviewNode
    return self.overviewNode
end

function GameUIAlliance:RefreshNoticeView()
    local textLabel = UIKit:ttfLabel({
        dimensions = cc.size(537, 0),
        text = string.len(Alliance_Manager:GetMyAlliance():Notice())>0 and Alliance_Manager:GetMyAlliance():Notice() or _("未设置联盟公告"),
        size = 20,
        color = 0x403c2f,
        align=cc.TEXT_ALIGNMENT_CENTER
    })
    local content = display.newNode()
    content:size(537,textLabel:getContentSize().height)
    textLabel:addTo(content):align(display.CENTER, 269, textLabel:getContentSize().height/2)
    self.ui_overview.noticeView:removeAllItems()
    local textItem = self.ui_overview.noticeView:newItem()
    textItem:addContent(content)
    textItem:setItemSize(537,content:getContentSize().height)
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
    local params_,params = event.params,{}
    for _,v in ipairs(params_) do
        if Localize.alliance_title[v] then
            v = Localize.alliance_title[v]
        end
        table.insert(params, v)
    end
    return string.format(Localize.alliance_events[event_type],unpack(params))
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

function GameUIAlliance:RefreshFlag()
    if not self.flag_box then return end
    if self.ui_overview and self.tab_buttons:GetSelectedButtonTag() == 'overview'  then
        local alliance_data = Alliance_Manager:GetMyAlliance()
        if self.ui_overview.my_alliance_flag then
            local x,y = self.ui_overview.my_alliance_flag:getPosition()
            self.ui_overview.my_alliance_flag:removeFromParent()
            self.ui_overview.my_alliance_flag = self.alliance_ui_helper:CreateFlagWithRhombusTerrain(Alliance_Manager:GetMyAlliance():Terrain(),Alliance_Manager:GetMyAlliance():Flag())
                :addTo(self.flag_box)
                :pos(x,y)
        end
    end
end

function GameUIAlliance:RefreshOverViewUI()
    if self.ui_overview and self.tab_buttons:GetSelectedButtonTag() == 'overview'  then
        local alliance_data = Alliance_Manager:GetMyAlliance()
        self.ui_overview.nameLabel:setString(alliance_data:Name())
        self.ui_overview.tagLabel:setString(alliance_data:AliasName())
        self.ui_overview.languageLabel:setString(alliance_data:DefaultLanguage())
        self:RefreshNoticeView()
    end
end

function GameUIAlliance:RefreshEventListView()
    local events = Alliance_Manager:GetMyAlliance():Events()
    self.eventListView:removeAllItems()
    for i = #events, 1, -1 do
        self.eventListView:addItem(self:GetEventItemByIndexAndEvent(i,events[i]))
    end
    self.eventListView:reload()
end

function GameUIAlliance:OnAllianceSettingButtonClicked(event)
    if not Alliance_Manager:GetMyAlliance():GetSelf():CanEditAlliance() then
        UIKit:showMessageDialog(_("提示"), _("您没有此操作权限"), function()end)
        return
    end
    UIKit:newGameUI('GameUIAllianceBasicSetting',true):AddToCurrentScene(true)
end

--成员

function GameUIAlliance:HaveAlliaceUI_membersIf()
    if self.member_list_bg then self:RefreshMemberList() return self.member_list_bg end
    local member_list_bg = display.newSprite("alliance_member_bg_568x784.png")
        :align(display.CENTER_TOP, window.width/2, window.betweenHeaderAndTab)
        :addTo(self.main_content)
    local listView = UIListView.new {
        viewRect = cc.rect(10, 10, 548,764),
        direction = UIScrollView.DIRECTION_VERTICAL,
    -- bgColor = UIKit:hex2c4b(0x7a000000),
    }:addTo(member_list_bg)
    self.memberListView = listView
    self.member_list_bg = member_list_bg
    self:RefreshMemberList()
    return self.member_list_bg
end

function GameUIAlliance:RefreshMemberList()
    if not self.memberListView then return end
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
    local alliance = Alliance_Manager:GetMyAlliance()
    return alliance:GetTitles()[title],UILib.alliance_title_icon[title]
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
        local bg = display.newScale9Sprite("alliance_member_item_bg0_548x68.png"):size(548,150):align(display.LEFT_BOTTOM, 0, 0)
        local title_bar = display.newSprite("alliance_member_title_548x38.png"):align(display.LEFT_TOP, 0, 150):addTo(bg)
        local button = WidgetPushButton.new({normal = "alliance_member_i_n_34x34.png",pressed = "alliance_member_i_h_34x34.png"})
            :align(display.RIGHT_CENTER,540,19)
            :addTo(title_bar)
            :onButtonClicked(function(event)
                self:OnAllianceTitleClicked(title)
            end)
        WidgetPushTransparentButton.new(cc.rect(0,0,548,38),button):addTo(title_bar):align(display.LEFT_BOTTOM,0,0)
        local display_title,imageName = self:GetAllianceTitleAndLevelPng(title)
        local titleLabel = UIKit:ttfLabel({
            text = display_title,
            size = 22,
            color = 0xffedae,
        }):align(display.CENTER, 274,19):addTo(title_bar)

        local icon = display.newSprite(imageName)
            :align(display.RIGHT_CENTER,titleLabel:getPositionX() - titleLabel:getContentSize().width/2 - 10,19)
            :addTo(title_bar)
        --content
        local box = display.newSprite("alliance_icon_box_108x108.png"):align(display.LEFT_BOTTOM, 4, 4):addTo(bg)
        UIKit:GetPlayerCommonIcon():addTo(box):pos(54,54):scale(0.8)
        local nameLabel = UIKit:ttfLabel({
            text = data[1].name,
            size = 22,
            color = 0x403c2f,
        }):addTo(bg):align(display.LEFT_TOP,box:getPositionX()+box:getContentSize().width + 5, box:getPositionY()+box:getContentSize().height - 2)
        local lvLabel =  UIKit:ttfLabel({
            text = "LV " .. data[1].level,
            size = 22,
            color = 0x403c2f,
        }):addTo(bg):align(display.LEFT_TOP,nameLabel:getPositionX()+200, nameLabel:getPositionY())
        local line_2 = display.newScale9Sprite("dividing_line_594x2.png"):addTo(bg)
            :align(display.LEFT_BOTTOM,box:getPositionX()+box:getContentSize().width+2,box:getPositionY()+2)
            :size(title_bar:getContentSize().width - box:getContentSize().width - 20,2)
        local loginLabel = UIKit:ttfLabel({
            text = _("最后登陆时间:") .. NetService:formatTimeAsTimeAgoStyleByServerTime(data[1].lastLoginTime),
            size = 20,
            color = 0x403c2f,
        }):addTo(bg):align(display.LEFT_BOTTOM, line_2:getPositionX(),line_2:getPositionY() + 5)
        local line_1 = display.newScale9Sprite("dividing_line_594x2.png"):addTo(bg)
            :align(display.LEFT_BOTTOM,box:getPositionX()+box:getContentSize().width+2,box:getPositionY()+35)
            :size(title_bar:getContentSize().width - box:getContentSize().width - 20,2)
        local powerIcon = display.newSprite("dragon_strength_27x31.png")
            :align(display.LEFT_BOTTOM,line_1:getPositionX(),line_1:getPositionY()+5)
            :addTo(bg)
        local powerLabel = UIKit:ttfLabel({
            text = string.formatnumberthousands(data[1].power),
            size = 22,
            color = 0x403c2f,
            align = cc.TEXT_ALIGNMENT_LEFT,
        }):addTo(bg):align(display.LEFT_BOTTOM,powerIcon:getPositionX()+powerIcon:getContentSize().width+10,powerIcon:getPositionY())
        if DataManager:getUserData()._id ~= data[1].id then
            WidgetPushButton.new({normal = "alliacne_search_29x33.png"})
                :align(display.RIGHT_BOTTOM,line_1:getPositionX()+line_1:getContentSize().width - 2,line_1:getPositionY()+2)
                :addTo(bg)
                :onButtonClicked(function()
                    self:OnPlayerDetailButtonClicked(data[1].id)
                end)
        end
        --end
        item:addContent(bg)
        item:setItemSize(548,150)
        return item
    else
        header_title,number_image = self:GetAllianceTitleAndLevelPng(title)
    end
    local height = 38 + 68 * (#data)
    local node = display.newNode():size(548,height)
    local title_bar = display.newSprite("alliance_member_title_548x38.png"):align(display.LEFT_TOP, 0, height):addTo(node)
    local button = WidgetPushButton.new({normal = "alliance_member_i_n_34x34.png",pressed = "alliance_member_i_h_34x34.png"})
        :align(display.RIGHT_CENTER,540,19)
        :addTo(title_bar)
        :onButtonClicked(function(event)
            self:OnAllianceTitleClicked(title)
        end)
    WidgetPushTransparentButton.new(cc.rect(0,0,548,38),button):addTo(title_bar):align(display.LEFT_BOTTOM,0,0)
    local title_label= UIKit:ttfLabel({
        text = header_title,
        size = 22,
        color = 0xffedae,
    }):addTo(title_bar):align(display.CENTER,274, 19)
    local num = display.newSprite(number_image):addTo(title_bar)
        :align(display.RIGHT_CENTER,title_label:getPositionX() - title_label:getContentSize().width/2 - 10,19)
    local y = height - 38
    for i,v in ipairs(data) do
        self:GetNormalSubItem(i,v.name,v.level,v.power,v.id):addTo(node):align(display.LEFT_TOP, 0, y)
        y = y - 68
    end
    item:addContent(node)
    item:setItemSize(548,height)
    return item
end

function GameUIAlliance:GetNormalSubItem(index,playerName,level,power,memberId)
    local item = display.newSprite(string.format("alliance_member_item_bg%d_548x68.png",index % 2))
    local icon = UIKit:GetPlayerCommonIcon():scale(0.5):align(display.LEFT_CENTER,15, 34):addTo(item)
    local nameLabel = UIKit:ttfLabel({
        text = playerName,
        size = 22,
        color = 0x403c2f,
    }):addTo(item):align(display.LEFT_CENTER,icon:getPositionX()+icon:getContentSize().width*0.5 + 3,34)
    local lvLabel =  UIKit:ttfLabel({
        text = "LV " .. level,
        size = 22,
        color = 0x797154,
    }):addTo(item):align(display.LEFT_CENTER,icon:getPositionX()+icon:getContentSize().width*0.5+170, 34)
    local powerIcon = display.newSprite("dragon_strength_27x31.png"):align(display.LEFT_CENTER,icon:getPositionX()+icon:getContentSize().width*0.5+266,34)
        :addTo(item)
    local powerLabel = UIKit:ttfLabel({
        text = string.formatnumberthousands(power),
        size = 22,
        color = 0x403c2f,
        align = cc.TEXT_ALIGNMENT_LEFT,
    }):addTo(item):align(display.LEFT_CENTER,icon:getPositionX()+icon:getContentSize().width*0.5+300,34)
    if DataManager:getUserData()._id ~= memberId then
        WidgetPushButton.new({normal = "alliacne_search_29x33.png"})
            :align(display.RIGHT_CENTER,524,34)
            :addTo(item)
            :onButtonClicked(function()
                self:OnPlayerDetailButtonClicked(memberId)
            end)
    end
    return item
end

function GameUIAlliance:OnAllianceTitleClicked( title )
    UIKit:newGameUI('GameUIAllianceTitle',title):AddToCurrentScene(true)
end

function GameUIAlliance:OnPlayerDetailButtonClicked(memberId)
    UIKit:newGameUI('GameUIAllianceMemberInfo',true,memberId):AddToCurrentScene(true)
end
-- 信息
function GameUIAlliance:HaveAlliaceUI_infomationIf()
    if self.informationNode then return self.informationNode end
    local informationNode = WidgetUIBackGround.new({height=384,isFrame = "yes"}):addTo(self.main_content):pos(20,window.betweenHeaderAndTab-384 - 10)
    self.informationNode = informationNode

    local notice_bg = display.newSprite("alliance_notice_box_580x184.png")
        :align(display.CENTER_TOP,informationNode:getContentSize().width/2,395)
        :addTo(informationNode)



    local descView = UIListView.new {
        viewRect =  cc.rect(21,14,537,123),
        direction = UIScrollView.DIRECTION_VERTICAL,
    }:addTo(notice_bg)
    self.descListView = descView

    local notice_button = WidgetPushButton.new({normal = "alliance_notice_button_normal_310x36.png",pressed = "alliance_notice_button_highlight_310x36.png"})
        :setButtonLabel('normal',UIKit:ttfLabel({
            text = _("联盟描述"),
            size = 22,
            color = 0xffedae,
        })
        )
        :onButtonClicked(function(event)
            if not Alliance_Manager:GetMyAlliance():GetSelf():CanEditAllianceDesc() then
                UIKit:showMessageDialog(_("提示"), _("您没有此操作权限"), function()end)
                return
            end
            UIKit:newGameUI('GameUIAllianceNoticeOrDescEdit',GameUIAllianceNoticeOrDescEdit.EDIT_TYPE.ALLIANCE_DESC)
                :AddToCurrentScene(true)
        end)
        :addTo(notice_bg)
        :align(display.TOP_CENTER,292,181)
    display.newSprite("alliance_notice_icon_26x26.png"):addTo(notice_button):pos(70,-18)
    local checkbox_image = {
        off = "checkbox_unselected.png",
        off_pressed = "checkbox_unselected.png",
        off_disabled = "checkbox_unselected.png",
        on = "checkbox_selectd.png",
        on_pressed = "checkbox_selectd.png",
        on_disabled = "checkbox_selectd.png",

    }
    self.joinTypeButton = UICanCanelCheckBoxButtonGroup.new(display.TOP_TO_BOTTOM)
        :addButton(UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("允许玩家立即加入联盟"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_CENTER)
            :setButtonSelected(Alliance_Manager:GetMyAlliance():JoinType() == "all"))
        :addButton(UICheckBoxButton.new(checkbox_image)
            :setButtonLabel(UIKit:ttfLabel({text = _("玩家仅能通过申请或者邀请的方式加入"),size = 20,color = 0x797154}))
            :setButtonLabelOffset(40, 0)
            :align(display.LEFT_CENTER)
            :setButtonSelected(Alliance_Manager:GetMyAlliance():JoinType() ~= "all"))
        :onButtonSelectChanged(handler(self, self.OnAllianceJoinTypeButtonClicked))
        :addTo(informationNode)
        :setButtonsLayoutMargin(26,0,0,0)
        :setLayoutSize(557, 54)
        :pos(notice_bg:getPositionX() - notice_bg:getContentSize().width/2,notice_bg:getPositionY() - notice_bg:getContentSize().height/2 - 118)
        :setCheckButtonStateChangeFunction(function(group,currentSelectedIndex,oldIndex)
             if  not Alliance_Manager:GetMyAlliance():GetSelf():CanEditAllianceJoinType() then
                UIKit:showMessageDialog(_("提示"), _("您没有此操作权限"), function()end)
                return false
            end
            if currentSelectedIndex ~= oldIndex then
                local title = _("允许玩家立即加入联盟")
                if currentSelectedIndex ~= 1 then
                    title = _("玩家仅能通过申请或者邀请的方式加入")
                end
                UIKit:showMessageDialog(_("提示"), 
                    _("你将设置联盟加入方式为") .. title,
                    function()
                        self.joinTypeButton:sureSelectedButtonIndex(currentSelectedIndex)
                    end,
                    function()end)
            end
            return false
        end)

    local x,y = 37,-125
    local button_imags = {"alliance_sign_out_60x54.png","alliance_invitation_60x54.png","alliance_apply_60x54.png","alliance_group_mail_60x54.png"}
    local button_texts = {_("退出联盟"),_("邀请加入"),_("审批申请"),_("群邮件")}
    for i=1,4 do
        local button = cc.ui.UIPushButton.new({normal = 'alliance_button_n_132x98.png',pressed = "alliance_button_h_132x98.png"}):align(display.LEFT_BOTTOM,132*(i-1) + x, y)
            :addTo(informationNode)
            :onButtonClicked(function(event)
                self:OnInfoButtonClicked(i)
            end)
            :setButtonLabel("normal",UIKit:ttfLabel({text = button_texts[i],size = 18,color = 0xffedae}))
            :setButtonLabelOffset(0, -30)
        display.newSprite(button_imags[i]):addTo(button):pos(66,59)
    end
    self:RefreshDescView()
    return self.informationNode
end

function GameUIAlliance:IsOperateButtonEnable(index)
    local member = Alliance_Manager:GetMyAlliance():GetSelf()
    local enable = true
    if index == 2 then
        enable = member:CanInvatePlayer()
    elseif index == 3 then
        enable = member:CanHandleAllianceApply()
    elseif index == 4 then
        enable = member:CanSendAllianceMail()
    end
    return enable
end

function GameUIAlliance:SelectJoinType()
    if Alliance_Manager:GetMyAlliance():JoinType() == "all" then
        self.joinTypeButton:sureSelectedButtonIndex(1,true)
    else
        self.joinTypeButton:sureSelectedButtonIndex(2,true)
    end
end

function GameUIAlliance:RefreshDescView()
    local textLabel = UIKit:ttfLabel({
        dimensions = cc.size(537, 0),
        text = string.len(Alliance_Manager:GetMyAlliance():Describe())>0 and Alliance_Manager:GetMyAlliance():Describe() or _("未设置联盟描述"),
        size = 20,
        color = 0x403c2f,
        align=cc.TEXT_ALIGNMENT_CENTER
    })
    local content = display.newNode()
    content:size(537,textLabel:getContentSize().height)
    textLabel:addTo(content):align(display.CENTER, 269, textLabel:getContentSize().height/2)
    self.descListView:removeAllItems()
    local textItem = self.descListView:newItem()
    textItem:addContent(content)
    textItem:setItemSize(537,content:getContentSize().height)
    self.descListView:addItem(textItem)
    self.descListView:reload()
end

function GameUIAlliance:OnAllianceJoinTypeButtonClicked(event)  
    local join_type = "all"
    if event.selected ~= 1 then
        join_type = "audit"
    end 
    NetManager:getEditAllianceJoinTypePromise(join_type)
end


function GameUIAlliance:RefreshInfomationView()
    self:RefreshDescView()
    self:SelectJoinType()
end

function GameUIAlliance:OnInfoButtonClicked(tag)
    if not self:IsOperateButtonEnable(tag) then
       UIKit:showMessageDialog(_("提示"), _("您没有此操作权限"), function()end)
        return
    end
    if tag == 1 then
        if Alliance_Manager:GetMyAlliance():GetSelf():IsArchon() and Alliance_Manager:GetMyAlliance():GetMembersCount() > 1 then 
            UIKit:showMessageDialog(_("提示"),_("仅当联盟成员为空时,盟主才能退出联盟"), function()end)
            return
        end
        UIKit:showMessageDialog(_("退出联盟"),
            _("您必须在没有部队在外行军的情况下，才可以退出联盟。退出联盟会损失当前未打开的联盟礼物。"),
            function() 
                NetManager:getQuitAlliancePromise():done()
            end)
    elseif tag == 2 then
        self:CreateInvateUI()
    elseif tag == 3 then
        UIKit:newGameUI("GameAllianceApproval"):AddToCurrentScene(true)
    elseif tag == 4 then -- 邮件
        local mail = GameUIWriteMail.new(GameUIWriteMail.SEND_TYPE.ALLIANCE_MAIL)
        mail:SetTitle(_("联盟邮件"))
        mail:SetAddressee(_("发送联盟所有成员"))
        mail:addTo(self)
    end
end

function GameUIAlliance:CreateInvateUI()
    local layer = UIKit:shadowLayer()
    local bg = WidgetUIBackGround.new({height=150}):addTo(layer):pos(window.left+20,window.cy-20)
    local title_bar = display.newSprite("title_blue_600x52.png")
        :addTo(bg)
        :align(display.LEFT_BOTTOM, 0,150-15)

    local closeButton = UIKit:closeButton()
        :addTo(title_bar)
        :align(display.BOTTOM_RIGHT,title_bar:getContentSize().width, 0)
        :onButtonClicked(function ()
            layer:removeFromParent(true)
        end)
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
    editbox:setFont(UIKit:getEditBoxFont(),18)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.RIGHT_TOP,588,120):addTo(bg)
    WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
        :setButtonLabel(
            UIKit:commonButtonLable({
                text = _("发送"),
                color = 0xffedae
            })
        )
        :onButtonClicked(function(event)
            local playerID = string.trim(editbox:getText())
            if string.len(playerID) == 0 then
                UIKit:showMessageDialog(_("提示"), _("请输入邀请的玩家ID"), function()end)
                return
            end
            NetManager:getInviteToJoinAlliancePromise(playerID):done(function(result)
                    layer:removeFromParent(true)
                    UIKit:showMessageDialog(_("提示"), _("邀请发送成功"), function()end)
                end):fail(function(err)
                    UIKit:showMessageDialog(_("提示"), err:reason(), function()end)
                end)
        end)
        :addTo(bg):align(display.RIGHT_BOTTOM,editbox:getPositionX(), 20)

    layer:addTo(self)
end


return GameUIAlliance
