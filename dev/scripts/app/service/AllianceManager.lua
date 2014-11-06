--
-- Author: Danny He
-- Date: 2014-10-10 12:07:04
--
local AllianceManager = class("AllianceManager")
local Enum = import("..utils.Enum")

local ALLIANCETITLE_LEVEL = {
    "member",
    "elite",
    "supervisor",
    "quartermaster",
    "general",
    "archon"
}

--event
AllianceManager.ALLIANCE_EVENT_TYPE_NAME = "ALLIANCE_EVENT_TYPE_NAME"
AllianceManager.ALLIANCE_SERVER_EVENT_NAME = "ALLIANCE_SERVER_EVENT_NAME"

AllianceManager.ALLIANCE_EVENT_TYPE = Enum(
    "NORMAL",
    "CREATE_OR_JOIN",
    "QUIT",
    "CHANGE",
    "NONE"
)

--flag ui
------------------------------------------------------------------------------------------------

AllianceManager.FLAG_BODY_TAG = 1
AllianceManager.FLAG_BODY_ZORDER = 1
AllianceManager.FLAG_GRAPHIC_TAG = 2
AllianceManager.FLAG_GRAPHIC_ZORDER = 2
AllianceManager.FLAG_BOX_TAG  = 3
AllianceManager.FLAG_BOX_ZORDER = 3


AllianceManager.flagData_ = {
    color = {}, -- 颜色
    graphic = {}, -- 图案
    body = {}, -- 背景
    bodyButton = {}, -- 背景类型按钮
    graphicButton = {}, -- 图案类型按钮
    lawn = {},
}

--flag data
local color_from_excel =
    {
        red = 0x8b0000,
        yellow = 0xd8bc00,
        green = 0x0d8b00,
        babyBlue = 0x008b89,
        darkBlue = 0x000d8b,
        purple = 0x8b0080,
        orange = 0xd58200,
        white = 0xffffff,
        black = 0x000000,
        charmRed = 0xc10084,
        blue = 0x005ea7,
        orangeRed = 0xa74b00,
    }

table.foreach(color_from_excel,function(k,v)
    table.insert(AllianceManager.flagData_.color,{name = k,color=UIKit:convertColorToGL_(v)})
end)

local FLAG_LOCATION_TYPES = {
    "ONE",
    "TWO_LEFT_RIGHT",
    "TWO_TOP_BOTTOM",
    "TWO_X"
}

AllianceManager.LANDFORM_TYPE = {grassLand = 1,desert = 2,iceField = 3}

AllianceManager.FLAG_LOCATION_TYPE = {
    ONE = 1,
    TWO_LEFT_RIGHT = 2,
    TWO_TOP_BOTTOM = 3,
    TWO_X = 4
}

-- graphicButton & bodyButton
for i=1,4 do
    local graphicButtonImageName = string.format("alliance_flag_graphic_%d",i)
    AllianceManager.flagData_.graphicButton[i] = {name = i,image = graphicButtonImageName .. ".png"}
    local bodyButtonImageName = string.format("alliance_flag_type_45x45_%d",i)
    AllianceManager.flagData_.bodyButton[i] = {name = i,image = bodyButtonImageName .. ".png"}
end


--body image
AllianceManager.flagData_.body["1"] = "alliance_flag_body_1.png"
AllianceManager.flagData_.body["2_1"] = "alliance_flag_body_2_1.png"
AllianceManager.flagData_.body["2_2"] = "alliance_flag_body_2_2.png"
AllianceManager.flagData_.body["3_1"] = "alliance_flag_body_3_1.png"
AllianceManager.flagData_.body["3_2"] = "alliance_flag_body_3_2.png"
AllianceManager.flagData_.body["4_1"] = "alliance_flag_body_4.png"
AllianceManager.flagData_.body["4_2"] = "alliance_flag_body_4.png"

--graphic

for i=1,17 do
    local imageName = string.format("alliance_graphic_%d",i)
    table.insert(AllianceManager.flagData_.graphic,{name = i,image = imageName .. ".png"})
end

for i=1,3 do
    AllianceManager.flagData_.lawn[i] = "greensward_540x378.png"
end

--end flag ui
------------------------------------------------------------------------------------------------

function AllianceManager:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    self.alliance_ = nil
    self.isInit_ = true
end

function AllianceManager:OnUserDataChanged(userData,timer)
	local eventType = self.ALLIANCE_EVENT_TYPE.NORMAL
	if not userData.alliance then return end
	if not self.isInit_ then
		if not userData.alliance then return end
		if (self.alliance_.id == nil and  userData.alliance.id ~= nil) then
			-- server auto push meessage
			-- self:FetchMyAllianceData()
			eventType = self.ALLIANCE_EVENT_TYPE.NONE
		end
		if (self.alliance_.id ~= nil and  userData.alliance.id == nil) then
			self.localAllianceData_ = nil -- clean local alliance data
			eventType = self.ALLIANCE_EVENT_TYPE.QUIT
		end
		if userData.requestToAllianceEvents then
			self.requestToAllianceEvents_ = userData.requestToAllianceEvents
		end
		if userData.inviteToAllianceEvents then
			self.inviteToAllianceEvents_  = userData.inviteToAllianceEvents
		end
		if userData.alliance  then
			self.alliance_ = userData.alliance 
			if eventType ~= self.ALLIANCE_EVENT_TYPE.NONE then
				self:dispathAllianceEvent(eventType)
			end
		end
	else
		self.alliance_ = userData.alliance 
		self.requestToAllianceEvents_ = userData.requestToAllianceEvents
		self.inviteToAllianceEvents_  = userData.inviteToAllianceEvents
	end

    self.isInit_  = false
end

-- 1 apply 2 invate
function AllianceManager:GetAllianceEvents(eventType)
    if eventType == 2 then
        return self.inviteToAllianceEvents_ or {}
    elseif eventType == 3 then
        return self.requestToAllianceEvents_ or {}
    end
end

--logic methods

function AllianceManager:getAlliance()
    return self.alliance_
end

function AllianceManager:haveAlliance()
    return self:getAlliance() and self:getAlliance().id ~= nil
end


-- flag ui

function AllianceManager:GetFlagSprite(flagInfo)
    -- flagInfo = self:GetFlagInfomation()
    if type(flagInfo) == 'string' then flagInfo = json.decode(flagInfo)  end
    local box_bounding = display.newSprite("alliance_flag_box_119x139.png")
    local box = display.newNode()
    --body
    local body_node = self:GetFlagBody(flagInfo,box_bounding)
    body_node:addTo(box,self.FLAG_BODY_ZORDER,self.FLAG_BODY_TAG)
    --graphic
    local graphic_node = self:GetGraphic(flagInfo,box_bounding)
    graphic_node:addTo(box,self.FLAG_GRAPHIC_ZORDER,self.FLAG_GRAPHIC_TAG)
    box_bounding:addTo(box,self.FLAG_BOX_ZORDER,self.FLAG_BOX_TAG):align(display.LEFT_BOTTOM, 0, 0)
    return box
end

function AllianceManager:GetGraphic(flagInfo,box_bounding)
    local graphic_node = display.newNode()
    if flagInfo.graphic == self.FLAG_LOCATION_TYPE.ONE then

        local color_1 = flagInfo.graphicColor[1]
        local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
        local graphic_1 =  self:getColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :pos(box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)

    elseif flagInfo.graphic == self.FLAG_LOCATION_TYPE.TWO_LEFT_RIGHT then

        local color_1 = flagInfo.graphicColor[1]
        local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
        local graphic_1 =  self:getColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :pos(box_bounding:getContentSize().width/3*1 - 4,box_bounding:getContentSize().height/2)
            :scale(0.5)
        local color_2 = flagInfo.graphicColor[2]
        local imageName_2 = self.flagData_.graphic[flagInfo.graphicContent[2]].image
        local graphic_2 =  self:getColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :pos(box_bounding:getContentSize().width/3*2 + 4,box_bounding:getContentSize().height/2)
            :scale(0.5)

    elseif flagInfo.graphic == self.FLAG_LOCATION_TYPE.TWO_TOP_BOTTOM then

        local color_1 = flagInfo.graphicColor[1]
        local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
        local graphic_1 =  self:getColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :align(display.TOP_CENTER,box_bounding:getContentSize().width/2, box_bounding:getContentSize().height - 20)
            :scale(0.5)
        local color_2 = flagInfo.graphicColor[2]
        local imageName_2 = self.flagData_.graphic[flagInfo.graphicContent[2]].image
        local graphic_2 =  self:getColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :align(display.CENTER_BOTTOM, box_bounding:getContentSize().width/2, 20)
            :scale(0.5)

    elseif flagInfo.graphic == self.FLAG_LOCATION_TYPE.TWO_X then
        local color_1 = flagInfo.graphicColor[1]
        local imageName_1 = self.flagData_.graphic[flagInfo.graphicContent[1]].image
        local graphic_1 =  self:getColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :align(display.LEFT_TOP,box_bounding:getContentSize().width/8*1, box_bounding:getContentSize().height/8*7)
            :scale(0.5)
        graphic_1 = self:getColorSprite(imageName_1,color_1)
            :addTo(graphic_node)
            :align(display.RIGHT_BOTTOM,box_bounding:getContentSize().width/8*7, box_bounding:getContentSize().height/8*1+10)
            :scale(0.5)
        local color_2 = flagInfo.graphicColor[2]
        local imageName_2 = self.flagData_.graphic[flagInfo.graphicContent[2]].image
        local graphic_2 =  self:getColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :align(display.LEFT_BOTTOM,box_bounding:getContentSize().width/8*1, box_bounding:getContentSize().height/8*1 + 10)
            :scale(0.5)
        graphic_2 = self:getColorSprite(imageName_2,color_2)
            :addTo(graphic_node)
            :align(display.RIGHT_TOP,box_bounding:getContentSize().width/8*7, box_bounding:getContentSize().height/8*7)
            :scale(0.5)
    end
    return graphic_node
end


function AllianceManager:GetFlagBody(flagInfo,box_bounding)
    --body
    local body_node = display.newNode() -- :addTo(box,self.FLAG_BODY_ZORDER,self.FLAG_BODY_TAG)
    if flagInfo.flag == self.FLAG_LOCATION_TYPE.ONE then
        local imageName = self.flagData_.body["1"]
        local color  = flagInfo.flagColor[1]
        self:getColorSprite(imageName,color)
            :addTo(body_node)
            :pos(box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    elseif flagInfo.flag == self.FLAG_LOCATION_TYPE.TWO_LEFT_RIGHT then
        local imageName_1 = self.flagData_.body["2_1"]
        local color_1  = flagInfo.flagColor[1]
        self:getColorSprite(imageName_1,color_1)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER_RIGHT,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
        local imageName_2 = self.flagData_.body["2_2"]
        local color_2  = flagInfo.flagColor[2]
        self:getColorSprite(imageName_2,color_2)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER_LEFT,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    elseif flagInfo.flag == self.FLAG_LOCATION_TYPE.TWO_TOP_BOTTOM then
        local imageName_1 = self.flagData_.body["3_1"]
        local color_1  = flagInfo.flagColor[1]
        self:getColorSprite(imageName_1,color_1)
            :scale(0.95)
            :addTo(body_node)
            :align(display.BOTTOM_CENTER,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
        local imageName_2 = self.flagData_.body["3_2"]
        local color_2  = flagInfo.flagColor[2]
        self:getColorSprite(imageName_2,color_2)
            :scale(0.95)
            :addTo(body_node)
            :align(display.TOP_CENTER,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
    elseif flagInfo.flag == self.FLAG_LOCATION_TYPE.TWO_X then
        local imageName_1 = self.flagData_.body["4_1"]
        local color_1  = flagInfo.flagColor[1]
        self:getColorSprite(imageName_1,color_1)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER,box_bounding:getContentSize().width/2,box_bounding:getContentSize().height/2)
        local imageName_2 = self.flagData_.body["4_2"]
        local color_2  = flagInfo.flagColor[2]
        self:getColorSprite(imageName_2,color_2)
            :scale(0.95)
            :addTo(body_node)
            :align(display.CENTER,box_bounding:getContentSize().width/2-1,box_bounding:getContentSize().height/2)
            :setFlippedX(true)
    end
    return body_node
end

function AllianceManager:getColorSprite(image,color)
    print(image,color)
    local customParams = {
        frag = "shaders/customer_color.fsh",
        shaderName = color,
        color = UIKit:convertColorToGL_(color_from_excel[color])
    }
    return display.newFilteredSprite(image, "CUSTOM", json.encode(customParams))
end

function AllianceManager:CreateFlagWithTerrain(terrain_info,flagInfo)
    if type(flagInfo) == 'string' then flagInfo = json.decode(flagInfo)  end
    if type(terrain_info) == 'string' then terrain_info = self.LANDFORM_TYPE[terrain_info] end
    local node = display.newNode()
    local lawn = self.flagData_.lawn[terrain_info]
    local upgrade_surface = display.newSprite(lawn)
        :addTo(node)
        :scale(0.258)
    local shadow = display.newSprite("alliance_flag_shadow_113x79.png")
        :addTo(node)
        :align(display.RIGHT_BOTTOM, upgrade_surface:getPositionX()+27, upgrade_surface:getPositionY()-23)
        :scale(0.7)
    local base = display.newSprite("alliance_flag_base_84x89.png")
        :addTo(node)
        :align(display.RIGHT_BOTTOM, upgrade_surface:getPositionX()+27, upgrade_surface:getPositionY()-23)
        :scale(0.7)
    local flag_sprite = self:GetFlagSprite(flagInfo):addTo(node)
        :align(display.RIGHT_BOTTOM, upgrade_surface:getPositionX() - 42, upgrade_surface:getPositionY()+5)
        :scale(0.7)

    return node,upgrade_surface,flag_sprite
end

-- alliance event


-- basic event
function AllianceManager:dispathAllianceEvent(eventType)
    self:dispatchEvent({name = AllianceManager.ALLIANCE_EVENT_TYPE_NAME,eventType = eventType})
end

-- event dispatch from server

function AllianceManager:dispatchAlliceServerData(eventName,msg)
	print("dispatchAlliceServerData------>",eventName)
	--simple response data
	if eventName == 'onSearchAlliancesSuccess' 
		or  eventName == 'onGetCanDirectJoinAlliancesSuccess'
		then
		self:dispatchEvent({name = AllianceManager.ALLIANCE_SERVER_EVENT_NAME,
	        eventName = eventName,
	        data = msg
	    })
	--basic ui event
	elseif eventName == 'onGetAllianceDataSuccess' 
		or eventName == 'onAllianceDataChanged' 
		or eventName == 'onAllianceNewEventReceived' 
		then
        -- Alliance_Manager:OnAllianceDataChanged(msg)
		self:setMyAllianceData_(eventName,msg)
	elseif eventName == 'onAllianceMemberDataChanged'  --update one member
		then
		local members = self:GetMyAllianceData().members
		local isFound = false
		for i,member in ipairs(members) do
			if member.id == msg.memberDoc.id then
				members[i] = msg.memberDoc
				isFound = true
			end
		end
		if not isFound then
			table.insert(members,msg.memberDoc)
		end
		-- onAllianceMemberDataChanged
		self:dispatchEvent({name = AllianceManager.ALLIANCE_SERVER_EVENT_NAME,
	        eventName = eventName,
	        data = msg.memberDoc
	    })
	elseif eventName == 'onAllianceBasicInfoAndMemberDataChanged' then
        Alliance_Manager:OnAllianceBasicInfoAndMemberDataChanged(msg)
		-- 拆分onAllianceBasicInfoAndMemberDataChanged 分成两个事件
		self:dispatchAlliceServerData("onAllianceDataChanged",{basicInfo=msg.basicInfo})
		self:dispatchAlliceServerData("onAllianceMemberDataChanged",{memberDoc=msg.memberDoc})
	end
end

function AllianceManager:OnAllianceEvent(tag,callback)
    self:addEventListener(self.ALLIANCE_EVENT_TYPE_NAME,callback,tag)
end

function AllianceManager:OnAllianceDataEvent(tag,callback)
    self:addEventListener(self.ALLIANCE_SERVER_EVENT_NAME,callback,tag)
end

function AllianceManager:RemoveEventByTag(tag)
    self:removeEventListenersByTag(tag)
end

function AllianceManager:FetchMyAllianceData()
    if self:haveAlliance() then
        PushService:getMyAllianceData()
    end
end

function AllianceManager:refreshMyAllianceHelpEventsData_(eventName,data)
    for k,v in pairs(self.localAllianceData_.helpEvents) do
        if data.event.eventId == v.eventId  then
            self.localAllianceData_.helpEvents[k] = data.event

            --update ui
            self:dispatchEvent({name = AllianceManager.ALLIANCE_SERVER_EVENT_NAME,
                eventName = eventName,
                data = data
            })
        end
    end
end

function AllianceManager:setMyAllianceData_(eventName,data)
	if self.localAllianceData_ ~= nil then
		if eventName == 'onAllianceNewEventReceived' then
			table.insert(self.localAllianceData_.events,data.event)
		else
			for k,v in pairs(data) do
				self.localAllianceData_[k] = v
			end
		end
		--update ui
		self:dispatchEvent({name = AllianceManager.ALLIANCE_SERVER_EVENT_NAME,
	        eventName = eventName,
	        data = data
	    })
	else
		self.localAllianceData_ = data
		self:dispathAllianceEvent(AllianceManager.ALLIANCE_EVENT_TYPE.CREATE_OR_JOIN)
	end
end

function AllianceManager:GetMyAllianceData()
    return self.localAllianceData_ or {}
end

function AllianceManager:GetMyAllianceFlag()
    return self:CreateFlagWithTerrain(self:GetMyAllianceData().basicInfo.terrain,self:GetMyAllianceData().basicInfo.flag)
end

function AllianceManager:GetMyAllianceEventData()
    return self:GetMyAllianceData()
end

function AllianceManager:KickAllianceMemberById(memberId)
	local members = self:GetMyAllianceData().members
	local member = nil
	for i,v in ipairs(members) do
		print("find one member----->id",v.id)
		if v.id == memberId then
			member = v
			print("find one member----->",member)
			table.remove(members,i)
		end
	end
	if member then
		self:dispatchEvent({name = AllianceManager.ALLIANCE_SERVER_EVENT_NAME,
	        eventName = "onAllianceMemberDataChanged"
	    })
	end
end

-- getType 1 up 2 down
function AllianceManager:GetMemberTitle(currentTitle,getType)
	local currentIndex = -1
	for i,v in ipairs(ALLIANCETITLE_LEVEL) do
		if v == currentTitle then
			currentIndex = i
		end
	end
	print("currentIndex------>",currentIndex,currentTitle,getType)
	local nextIndex = -1
	if getType == 1 then
		nextIndex = currentIndex + 1 > #ALLIANCETITLE_LEVEL and -1 or currentIndex + 1
	elseif getType == 2 then
		nextIndex = currentIndex - 1 < 0 and -1 or currentIndex - 1
	end
	if nextIndex > 0 then
		return ALLIANCETITLE_LEVEL[nextIndex]
	else
		return nil
	end
end

--TODO: 添加权限判定函数
function AllianceManager:AlliancePermission_can_modifyAllianceMemberTitle()

end

function AllianceManager:CanBuyArchon()
    if not self:haveAlliance() then return false end
    local archon = nil
    for i,v in ipairs(self:GetMyAllianceData().members) do
        if v.title == 'archon' then
            archon = v
            break
        end
    end
    print("(app.timer:GetServerTime() - archon.lastLoginTime/1000)/60*60*24---->",(app.timer:GetServerTime() - archon.lastLoginTime/1000)/60*60*24)
    return  (app.timer:GetServerTime() - archon.lastLoginTime/1000)/60*60*24 >= 7
end

return AllianceManager

