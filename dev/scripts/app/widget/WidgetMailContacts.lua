--
-- Author: Kenny Dai
-- Date: 2015-04-22 21:33:43
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIWriteMail = import("..ui.GameUIWriteMail")
local WidgetMailContacts = class("WidgetMailContacts", WidgetPopDialog)

function WidgetMailContacts:ctor()
    WidgetMailContacts.super.ctor(self,674,_("最近联系人"))
    local contacts = app:GetGameDefautlt():getRecentContacts()
    dump(self.contacts)
    local body = self:GetBody()
    local size = body:getContentSize()
    UIKit:ttfLabel({
        text = _("向其他玩家发送邮件,会自动添加到最近联系人列表"),
        size = 24,
        color = 0x403c2f
    }):align(display.CENTER,size.width/2,size.height-40)
        :addTo(body)
    local list,list_node = UIKit:commonListView_1({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0, 0,570,570),
    })
    list_node:addTo(body):align(display.BOTTOM_CENTER, size.width/2,20)
    self.head_icon_list = list
    for _,con in ipairs(contacts) do
        self:AddContacts(con)
    end

    list:reload()
end

function WidgetMailContacts:AddContacts(contacts)
    local list =  self.head_icon_list
    local item =list:newItem()
    local item_width,item_height = 548, 124
    item:setItemSize(item_width,item_height)
    local body_image = list.which_bg and "upgrade_resources_background_2.png" or "upgrade_resources_background_3.png"
    local content = display.newScale9Sprite(body_image,0,0,cc.size(item_width,item_height),cc.rect(10,10,500,26))
    list.which_bg = not list.which_bg

    UIKit:GetPlayerCommonIcon():align(display.CENTER, 70, item_height/2):addTo(content):scale(0.8)

    UIKit:ttfLabel({
        text = contacts.allianceTag or "",
        size = 24,
        color = 0x403c2f
    }):align(display.LEFT_CENTER,140,80)
        :addTo(content)
    UIKit:ttfLabel({
        text = contacts.name,
        size = 20,
        color = 0x5c553f
    }):align(display.LEFT_CENTER,140,40)
        :addTo(content)

    WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"},
        {scale9 = false},
        {
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        }
    ):setButtonLabel(UIKit:ttfLabel({
        text = _("邮件"),
        size = 24,
        color = 0xffedae,
        shadow= true
    }))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
            	local mail = UIKit:newGameUI("GameUIWriteMail", GameUIWriteMail.SEND_TYPE.PERSONAL_MAIL,contacts)
                mail:SetTitle(_("个人邮件"))
                mail:AddToCurrentScene(true)
                mail:setLocalZOrder(3000)
                self:LeftButtonClicked()
            end
        end):addTo(content):align(display.RIGHT_CENTER, item_width-10,40)


    item:addContent(content)
    list:addItem(item)
end
return WidgetMailContacts




