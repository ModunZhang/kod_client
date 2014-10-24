local Enum = import("..utils.Enum")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")


local GameUIWriteMail = class("GameUIWriteMail", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)
GameUIWriteMail.SEND_TYPE = Enum("PERSONAL_MAIL","ALLIANCE_MAIL")

local PERSONAL_MAIL = GameUIWriteMail.SEND_TYPE.PERSONAL_MAIL
local ALLIANCE_MAIL = GameUIWriteMail.SEND_TYPE.ALLIANCE_MAIL

function GameUIWriteMail:ctor()
    -- bg
    local write_mail = WidgetUIBackGround.new(768):addTo(self)
    write_mail:pos((display.width-write_mail:getContentSize().width)/2,display.top - write_mail:getContentSize().height - 120)
    local r_size = write_mail:getContentSize()
    -- title write_mail
    local title_write_mail = display.newSprite("title_blue_596x49.png"):align(display.TOP_LEFT, 6, write_mail:getContentSize().height-6):addTo(write_mail)
    -- title
    self.title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.LEFT_CENTER,30, 25)
        :addTo(title_write_mail)

    --close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent()
            end
        end):align(display.CENTER, title_write_mail:getContentSize().width-10, title_write_mail:getContentSize().height-6):addTo(title_write_mail):addChild(display.newSprite("X_3.png"))

    -- 收件人
    local addressee_title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("收件人："),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x797154)
        }):align(display.RIGHT_CENTER,120, r_size.height-90)
        :addTo(write_mail)
    self.editbox_addressee = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(422,40),
        listener = onEdit,
        font = UIKit:getFontFilePath(),
    })
    local editbox_addressee = self.editbox_addressee
    editbox_addressee:setPlaceHolder(_("最多可输入140字符"))
    editbox_addressee:setMaxLength(140)
    editbox_addressee:setFont(UIKit:getFontFilePath(),22)
    editbox_addressee:setFontColor(cc.c3b(0,0,0))
    editbox_addressee:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox_addressee:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox_addressee:align(display.LEFT_TOP,150, r_size.height-70):addTo(write_mail)
    -- 主题
    local subject_title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("主题："),
            font = UIKit:getFontFilePath(),
            size = 20,
            color = UIKit:hex2c3b(0x797154)
        }):align(display.RIGHT_CENTER,120, r_size.height-140)
        :addTo(write_mail)
    self.editbox_subject = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(422,40),
        listener = onEdit,
        font = UIKit:getFontFilePath(),
    })
    local editbox_subject = self.editbox_subject
    editbox_subject:setPlaceHolder(_("最多可输入140字符"))
    editbox_subject:setMaxLength(140)
    editbox_subject:setFont(UIKit:getFontFilePath(),22)
    editbox_subject:setFontColor(cc.c3b(0,0,0))
    editbox_subject:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox_subject:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    editbox_subject:align(display.LEFT_TOP,150, r_size.height-120):addTo(write_mail)

    -- 分割线
    display.newScale9Sprite("dividing_line_584x1.png", r_size.width/2, r_size.height-180,cc.size(594,1)):addTo(write_mail)
    -- 内容
    cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("内容："),
            font = UIKit:getFontFilePath(),
            size = 18,
            dimensions = cc.size(410,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER,30,r_size.height-200)
        :addTo(write_mail)
    -- 回复的邮件内容
    self.textView = cc.DTextView:create(cc.size(580,472),display.newScale9Sprite("background_580X472.png"))
    local textView = self.textView
    textView:addTo(write_mail):align(display.CENTER_BOTTOM,r_size.width/2,76)
    textView:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    textView:setFont(UIKit:getFontFilePath(), 24)

    textView:setFontColor(cc.c3b(0,0,0))

    -- 发送按钮
    local send_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("发送"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})

    send_label:enableShadow()
    self.send_button = WidgetPushButton.new(
        {normal = "keep_unlocked_button_normal.png", pressed = "keep_unlocked_button_pressed.png"},
        {scale9 = false}
    ):setButtonLabel(send_label)
        :addTo(write_mail):align(display.CENTER, write_mail:getContentSize().width-120, 40)
        
end
function GameUIWriteMail:SendMail(send_type,addressee,title,content)
    if not addressee or string.trim(addressee)=="" then
        FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("请填写正确的收件人ID"))
            :AddToCurrentScene()
        return
    elseif not title or string.trim(title)=="" then
        FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("请填写邮件主题"))
            :AddToCurrentScene()
        return
    elseif not content or string.trim(content)=="" then
        FullScreenPopDialogUI.new():SetTitle(_("提示"))
            :SetPopMessage(_("请填写邮件内容"))
            :AddToCurrentScene()
        return
    end
    if send_type == PERSONAL_MAIL then
        NetManager:sendPersonalMail(addressee, title, content,NOT_HANDLE)
    elseif send_type == ALLIANCE_MAIL then
        NetManager:sendAllianceMail(title, content,NOT_HANDLE)
    end
end

-- 发送的邮件类型title ， 默认为 ‘发邮件’
function GameUIWriteMail:SetTitle( title )
    self.title_label:setString(title)
    return self
end
-- 收件人
function GameUIWriteMail:SetAddressee( addressee )
    self.editbox_addressee:setText(addressee)
    return self
end
-- 邮件主题
function GameUIWriteMail:SetSubject( subject )
    self.editbox_subject:setText(subject)
    return self
end
-- 邮件内容
function GameUIWriteMail:SetContent( content )
    self.textView:setText(content)
    return self
end
-- 发送邮件
function GameUIWriteMail:OnSendButtonClicked( send_type )
    self.send_button:onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:SendMail(send_type,self.editbox_addressee:getText(), self.editbox_subject:getText(), self.textView:getText())
            self:removeFromParent()
        end
    end)
    return self
end

return GameUIWriteMail








   
