--
-- Author: Kenny Dai
-- Date: 2015-10-22 16:49:31
--

local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local window = import("..utils.window")
local Localize = import("..utils.Localize")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local intInit = GameDatas.AllianceInitData.intInit
local WidgetWorldAllianceInfo = class("WidgetWorldAllianceInfo", WidgetPopDialog)

function WidgetWorldAllianceInfo:ctor(object)
	self.object = object
	local isNumber = tolua.type(object) == "number"
    WidgetWorldAllianceInfo.super.ctor(self,isNumber and 328 or 430,isNumber and _("无主领土") or object.alliance.name,window.top-120)
    self:setNodeEventEnabled(true)

    if isNumber then
    	self:LoadMoveAlliance()
    else
	    NetManager:getAllianceBasicInfoPromise(object.alliance.id,User.serverId):done(function(response)
	        if response.success and response.msg.allianceData then
	            self:SetAllianceData(response.msg.allianceData)
	            self:LoadInfo(response.msg.allianceData)
	        end
	    end)
    end
end
function WidgetWorldAllianceInfo:SetAllianceData(allianceData)
    self.allianceData = allianceData
end
function WidgetWorldAllianceInfo:GetAllianceData()
    return self.allianceData
end
function WidgetWorldAllianceInfo:onEnter()

end

function WidgetWorldAllianceInfo:onExit()

end
function WidgetWorldAllianceInfo:LoadInfo(alliance_data)
    local layer = self.body
    local l_size = layer:getContentSize()
    local flag_box = display.newScale9Sprite("alliance_item_flag_box_126X126.png")
        :size(100,100)
        :addTo(layer)
        :align(display.LEFT_TOP, 30, l_size.height - 30)
    local flag_sprite = WidgetAllianceHelper.new():CreateFlagWithRhombusTerrain(alliance_data.terrain,alliance_data.flag)
    flag_sprite:addTo(flag_box)
    flag_sprite:pos(50,40)

    local titleBg = UIKit:createLineItem(
        {
            width = 418,
            text_1 = _("和平期"),
            text_2 = "00:11:11",
        }
    ):align(display.RIGHT_TOP,l_size.width-30, l_size.height - 56):addTo(layer)

    scheduleAt(self, function()
        titleBg:SetValue(GameUtils:formatTimeStyle1(app.timer:GetServerTime() - alliance_data.statusStartTime/1000.0),Localize.period_type[alliance_data.status])
    end)

    local info_bg = WidgetUIBackGround.new({height=82,width=556},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :align(display.LEFT_TOP, flag_box:getPositionX(),l_size.height - 146)
        :addTo(layer)
    local memberTitleLabel = UIKit:ttfLabel({
        text = _("成员"),
        size = 20,
        color = 0x615b44
    }):addTo(info_bg):align(display.LEFT_TOP,10,info_bg:getContentSize().height - 10)

    local memberValLabel = UIKit:ttfLabel({
        text = string.format("%d/%d",alliance_data.members,alliance_data.membersMax), --count of members
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_TOP,memberTitleLabel:getPositionX() + memberTitleLabel:getContentSize().width + 10, memberTitleLabel:getPositionY())


    local fightingTitleLabel = UIKit:ttfLabel({
        text = _("战斗力"),
        size = 20,
        color = 0x615b44
    }):addTo(info_bg):align(display.LEFT_TOP, 320, memberTitleLabel:getPositionY())

    local fightingValLabel = UIKit:ttfLabel({
        text = string.formatnumberthousands(alliance_data.power),
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_TOP, fightingTitleLabel:getPositionX() + fightingTitleLabel:getContentSize().width + 10, fightingTitleLabel:getPositionY())


    local languageTitleLabel = UIKit:ttfLabel({
        text = _("语言"),
        size = 20,
        color = 0x615b44
    }):addTo(info_bg):align(display.LEFT_BOTTOM,memberTitleLabel:getPositionX(),10)

    local languageValLabel = UIKit:ttfLabel({
        text = Localize.alliance_language[alliance_data.language], -- language
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_BOTTOM,languageTitleLabel:getPositionX() + languageTitleLabel:getContentSize().width + 10,10)


    local killTitleLabel = UIKit:ttfLabel({
        text = _("击杀"),
        size = 20,
        color = 0x615b44,
        align = ui.TEXT_ALIGN_RIGHT,
    }):addTo(info_bg):align(display.LEFT_BOTTOM, fightingTitleLabel:getPositionX(),10)

    local killValLabel = UIKit:ttfLabel({
        text = string.formatnumberthousands(alliance_data.kill),
        size = 20,
        color = 0x403c2f
    }):addTo(info_bg):align(display.LEFT_BOTTOM, killTitleLabel:getPositionX() + killTitleLabel:getContentSize().width + 10, 10)

    local leaderIcon = display.newSprite("alliance_item_leader_39x39.png")
        :addTo(layer)
        :align(display.LEFT_TOP,titleBg:getPositionX() - titleBg:getContentSize().width, titleBg:getPositionY() - titleBg:getContentSize().height -18)
    local leaderLabel = UIKit:ttfLabel({
        text = self:GetAllianceArchonName() or  "",
        size = 22,
        color = 0x403c2f
    }):addTo(layer):align(display.LEFT_TOP,leaderIcon:getPositionX()+leaderIcon:getContentSize().width+15, leaderIcon:getPositionY()-4)

    local button = WidgetPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
        :setButtonLabel(
            UIKit:ttfLabel({
                text = _("定位"),
                size = 20,
                shadow = true,
                color = 0xfff3c7
            })
        )
        :align(display.RIGHT_TOP,titleBg:getPositionX(),titleBg:getPositionY() - titleBg:getContentSize().height -10)
        :addTo(layer)
    button:onButtonClicked(function(event)
        end)

    local desc_bg = WidgetUIBackGround.new({height=158,width=550},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :align(display.CENTER_TOP, l_size.width/2,l_size.height - 240)
        :addTo(layer)

    local desc = alliance_data.desc
    if not desc or desc == json.null then
        desc = _("联盟未设置联盟描述")
    end
    local killTitleLabel = UIKit:ttfLabel({
        text =  desc,
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(530,0),
        align = cc.TEXT_ALIGNMENT_CENTER,
    }):addTo(desc_bg):align(display.CENTER, desc_bg:getContentSize().width/2,desc_bg:getContentSize().height/2)

    self:BuildOneButton("icon_goto_38x56.png",_("定位")):onButtonClicked(function()
        self:LeftButtonClicked()
    end):addTo(layer):align(display.RIGHT_TOP, l_size.width,10)
    return layer
end

function WidgetWorldAllianceInfo:GetAllianceArchonName()
    return self:GetAllianceData().archon.name
end
function WidgetWorldAllianceInfo:BuildOneButton(image,title,music_info)
    local btn = WidgetPushButton.new({normal = "btn_138x110.png",pressed = "btn_pressed_138x110.png"},{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        }
        ,music_info)
    local s = btn:getCascadeBoundingBox().size
    display.newSprite(image):align(display.CENTER, -s.width/2, -s.height/2+12):addTo(btn)
    UIKit:ttfLabel({
        text =  title,
        size = 18,
        color = 0xffedae,
    }):align(display.CENTER, -s.width/2 , -s.height+25):addTo(btn)
    return btn
end


function WidgetWorldAllianceInfo:LoadMoveAlliance()
	local body = self.body
	local b_size = body:getContentSize()
	UIKit:ttfLabel({
        text =  _("迁移冷却时间"),
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, b_size.width/2 , b_size.height - 40):addTo(body)

    local move_time = UIKit:ttfLabel({
        size = 22,
        color = 0x007c23,
    }):align(display.CENTER, b_size.width/2 , b_size.height - 70):addTo(body)

    scheduleAt(self,function ()
    	local time = intInit.allianceMoveColdMinutes.value * 60 + Alliance_Manager:GetMyAlliance().basicInfo.allianceMoveTime/1000.0 - app.timer:GetServerTime()
    	local canMove = Alliance_Manager:GetMyAlliance().basicInfo.allianceMoveTime == 0 or time <= 0
    	move_time:setString(GameUtils:formatTimeStyle1(canMove and 0 or time))
    end)

	local desc_bg = WidgetUIBackGround.new({height=186,width=556},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :align(display.CENTER_TOP, b_size.width/2,b_size.height - 100)
        :addTo(body)
     UIKit:ttfLabel({
        text =  _("当迁移时间就绪时，联盟可进行一次免费的迁移。迁移联盟时，针对联盟外目标的行军事件会被强制召回。迁移联盟需要将军以上的权限的玩家操作。"),
        size = 20,
        color = 0x403c2f,
        dimensions = cc.size(520,0),
    }):align(display.CENTER, desc_bg:getContentSize().width/2 , desc_bg:getContentSize().height/2):addTo(desc_bg)

     self:BuildOneButton("icon_move_alliance_building.png",_("迁移")):onButtonClicked(function()
		local time = intInit.allianceMoveColdMinutes.value * 60 + Alliance_Manager:GetMyAlliance().basicInfo.allianceMoveTime/1000.0 - app.timer:GetServerTime()
    	local canMove = Alliance_Manager:GetMyAlliance().basicInfo.allianceMoveTime == 0 or time <= 0
    	if canMove then
	     	NetManager:getMoveAlliancePromise(self.object)
	    else
	    	UIKit:showMessageDialog(_("提示"), _("当前还不能移动联盟"))
    	end
        self:LeftButtonClicked()
    end):addTo(body):align(display.RIGHT_TOP, b_size.width,10)
end
return WidgetWorldAllianceInfo















