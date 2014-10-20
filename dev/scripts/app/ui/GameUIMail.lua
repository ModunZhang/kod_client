local GameUIBase = import('.GameUIBase')
local UIListView = import(".UIListView")
local UICheckBoxButton = import(".UICheckBoxButton")
local GameUIStrikeReport = import(".GameUIStrikeReport")
local GameUIWarReport = import(".GameUIWarReport")
local window = import("..utils.window")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetUIBackGround2 = import("..widget.WidgetUIBackGround2")
local WidgetBackGroudWhite = import("..widget.WidgetBackGroudWhite")
local WidgetBackGroundLucid = import("..widget.WidgetBackGroundLucid")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")

local GameUIMail = class('GameUIMail', GameUIBase)

GameUIMail.ONE_TIME_LOADING_MAILS = 10

function GameUIMail:ctor(title,city)
    GameUIMail.super.ctor(self)
    self.title = title
    self.city = city
    self.inbox_mails = {}
    self.saved_mails = {}
    self.send_mails = {}
    -- print("测试",tolua.type(nil)=="nil",nil==false,tolua.type(true))
end

function GameUIMail:onEnter()
    GameUIMail.super.onEnter(self)
    self:CreateBackGround()
    self:CreateBetweenBgAndTitle()
    self:CreateTitle(self.title)
    self.home_btn = self:CreateHomeButton()
    self:CreateWriteMailButton()
    self:CreateTabButtons({
        {
            label = _("收件箱"),
            tag = "inbox",
            default = true,
        },
        {
            label = _("战报"),
            tag = "report",
        },
        {
            label = _("收藏夹"),
            tag = "saved",
        },
        {
            label = _("已发送"),
            tag = "sent",
        },
    }, function(tag)
        if tag == 'inbox' then
            self.inbox_layer:setVisible(true)
        else
            self.inbox_layer:setVisible(false)
        end

        if tag == 'report' then
            self.report_layer:setVisible(true)
        else
            self.report_layer:setVisible(false)
        end

        if tag == 'saved' then
            self.saved_layer:setVisible(true)
        else
            self.saved_layer:setVisible(false)
        end

        if tag == 'sent' then
            self.sent_layer:setVisible(true)
        else
            self.sent_layer:setVisible(false)
        end
    end):pos(window.cx, window.bottom + 34)

    DataManager:GetManager("MailManager"):AddObserver(self)
    local mails = DataManager:GetManager("MailManager"):GetMails(function (...)
        local saved_mails = DataManager:GetManager("MailManager"):GetSavedMails(function (...)
            local send_mails = DataManager:GetManager("MailManager"):GetSendMails(function (...)end)
            self:InitSendMails(send_mails)
        end)
        self:InitSaveMails(saved_mails)
    end)
    self:InitInbox(mails)
end
function GameUIMail:onExit()
    DataManager:GetManager("MailManager"):RemoveObserver(self)
    GameUIMail.super.onExit(self)
end

function GameUIMail:OnSavedMailsChanged(mail_manager,saved_mails)
end
function GameUIMail:OnSendMailsChanged(mail_manager,send_mails)
end

function GameUIMail:CreateWriteMailButton()
    local write_mail_button = WidgetPushButton.new(
        {normal = "gem_btn_up.png", pressed = "gem_btn_down.png"}
    ):onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:CreateWriteMail()
        end
    end):addTo(self)
    write_mail_button:align(display.RIGHT_TOP, window.right, window.top)
    cc.ui.UIImage.new("write_mail_58X46.png")
        :addTo(write_mail_button)
        :pos(-75, -75)
end
function GameUIMail:CreateBetweenBgAndTitle()
    self.inbox_layer = display.newLayer()
    self:addChild(self.inbox_layer)

    self.report_layer = display.newLayer()
    self:addChild(self.report_layer)

    self.saved_layer = display.newLayer()
    self:addChild(self.saved_layer)

    self.sent_layer = display.newLayer()
    self:addChild(self.sent_layer)
end

function GameUIMail:InitInbox(mails)
    self.inbox_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-304, display.top-890, 612, 790),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.inbox_layer)
    if mails then
        local added_count = 0
        for k,inbox_mail in pairs(mails) do
            added_count = added_count + 1
            if added_count>GameUIMail.ONE_TIME_LOADING_MAILS then
                break
            end
            local item = self:CreateMailItem(self.inbox_listview,inbox_mail)
            self:AddMailToListView(self.inbox_listview,item,inbox_mail)
        end
        -- 从服务器第一次获取到的邮件数量等于10时才有可能有更多的邮件
        if added_count == GameUIMail.ONE_TIME_LOADING_MAILS then
            self:CreateLoadingMoreItem(self.inbox_listview)
        end
    end
end

function GameUIMail:InitSaveMails(mails)
    self.save_mails_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-304, display.top-890, 612, 790),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.saved_layer)
    local added_count = 0
    if mails then
        for k,saved_mail in pairs(mails) do
            added_count = added_count + 1
            if added_count>GameUIMail.ONE_TIME_LOADING_MAILS then
                break
            end
            local item = self:CreateMailItem(self.save_mails_listview,saved_mail)
            self:AddMailToListView(self.save_mails_listview,item,saved_mail)
        end
        -- 从服务器第一次获取到的邮件数量等于10时才有可能有更多的邮件
        if added_count == GameUIMail.ONE_TIME_LOADING_MAILS then
            self:CreateLoadingMoreItem(self.save_mails_listview)
        end
    end
end

function GameUIMail:InitSendMails(mails)
    self.send_mail_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-304, display.top-890, 612, 790),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.sent_layer)
    if mails then
        local added_count = 0
        for k,send_mail in pairs(mails) do
            added_count = added_count + 1
            if added_count>GameUIMail.ONE_TIME_LOADING_MAILS then
                break
            end
            local item = self:CreateMailItem(self.send_mail_listview,send_mail)
            self:AddMailToListView(self.send_mail_listview,item,send_mail)
        end
        -- 从服务器第一次获取到的邮件数量等于10时才有可能有更多的邮件
        if added_count == GameUIMail.ONE_TIME_LOADING_MAILS then
            self:CreateLoadingMoreItem(self.send_mail_listview)
        end
    end
end

function GameUIMail:GetIsReadImage(isRead)
    local image_file = isRead and "mail_state_read.png" or "mail_state_user_not_read.png"
    local image = display.newSprite(image_file, 22, 22)
    image:setScale(34/image:getContentSize().width)
    return image
end

function GameUIMail:CreateMailItem(listview,mail)
    local item = listview:newItem()
    local item_width, item_height = 612,192
    item.mail = mail
    item:setItemSize(item_width, item_height)
    local content = WidgetPushButton.new({normal = "mail_inbox_item_bg_612X188.png",pressed = "mail_inbox_item_bg_612X188.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if tolua.type(mail.isRead)=="boolean" and not mail.isRead then
                    self:ReadMail(mail.id,function (flag)
                        if flag then
                            DataManager:GetManager("MailManager"):RemoveObserver(self)
                            DataManager:GetManager("MailManager"):DecreaseUnReadMailsAndReports(1)
                            self.inbox_mails[mail.id].mail.isRead = true
                            self.inbox_mails[mail.id].mail_state:setTexture("mail_state_read.png")
                            self.inbox_mails[mail.id].mail_state:setScale(34/self.inbox_mails[mail.id].mail_state:getContentSize().width)
                            -- --如果收藏夹中有此邮件也要更改已读状态
                            -- if self.saved_mails[mail.id] then
                            --     self.saved_mails[mail.id].mail.isRead = true
                            --     self.saved_mails[mail.id].mail_state:setTexture("mail_state_read.png")
                            --     self.saved_mails[mail.id].mail_state:setScale(34/self.inbox_mails[mail.id].mail_state:getContentSize().width)
                            -- end
                        end
                    end)
                end
                --如果是发送邮件
                if mail.toId then
                    self:ShowSendMailDetails(item.mail)
                else
                    self:ShowMailDetails(item.mail)
                end
            end
        end)
    local c_size = content:getContentSize()
    local title_bg = display.newSprite("title_blue_588X30.png", 0, 60):addTo(content)
    local mail_state_bg = display.newSprite("back_ground_44X44.png", 35, 16):addTo(title_bg)
    item.mail_state= self:GetIsReadImage(mail.isRead):addTo(mail_state_bg)
    local from_name_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.fromName,
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.LEFT_CENTER, 60, 17)
        :addTo(title_bg)
    local date_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = GameUtils:formatTimeStyle2(mail.sendTime/1000),
            font = UIKit:getFontFilePath(),
            size = 16,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.RIGHT_CENTER, 540, 17)
        :addTo(title_bg)
    local mail_content_bg = display.newSprite("box_584X114.png", 0, -23):addTo(content)
    local mail_content_title_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.title,
            font = UIKit:getFontFilePath(),
            size = 20,
            dimensions = cc.size(580,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER, 20, 90)
        :addTo(mail_content_bg)
    local mail_content_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.content,
            font = UIKit:getFontFilePath(),
            size = 18,
            dimensions = cc.size(550,20),
            color = UIKit:hex2c3b(0x68624c)
        }):align(display.LEFT_TOP, 20, 60)
        :addTo(mail_content_bg)
    -- 发件箱无收藏功能
    if listview ~= self.send_mail_listview then
        item.saved_button = UICheckBoxButton.new({
            off = "mail_saved_button_normal.png",
            off_pressed = "mail_saved_button_normal.png",
            off_disabled = "mail_saved_button_normal.png",
            on = "mail_saved_button_pressed.png",
            on_pressed = "mail_saved_button_pressed.png",
            on_disabled = "mail_saved_button_pressed.png",
        }):setButtonSelected(tolua.type(mail.isSaved)=="nil" or mail.isSaved,true):onButtonStateChanged(function(event)
            self:SaveOrUnsaveMail(mail,event.target)
        end):addTo(content):pos(264, -54)
    end
    item:addContent(content)
    return item
end

function GameUIMail:SaveOrUnsaveMail(mail,target)
    if target:isButtonSelected() then
        NetManager:saveMail(mail.id,function(flag)
            if flag then
                if self.inbox_mails[mail.id] then
                    self.inbox_mails[mail.id].mail.isSaved=true
                    self.inbox_mails[mail.id].saved_button:setButtonSelected(true,true)
                end
                -- 收藏夹中的邮件没有这两个属性
                mail.isRead = nil
                mail.isSaved = nil
                DataManager:GetManager("MailManager"):AddSavedMail(mail)
                -- 收藏成功，收藏夹添加此封邮件
                local item =  self:CreateMailItem(self.save_mails_listview, mail)
                self:AddMails(self.save_mails_listview, item, mail ,1)
                -- LuaUtils:outputTable("当前saved_mails", self.saved_mails)
            else
                target:setButtonSelected(false,true)
            end
        end)
    else
        NetManager:unSaveMail(mail.id,function(flag)
            if flag then
                if self.inbox_mails[mail.id] then
                    self.inbox_mails[mail.id].mail.isSaved=false
                    self.inbox_mails[mail.id].saved_button:setButtonSelected(false,true)
                end
                -- 取消收藏成功，从收藏夹删除这封邮件
                self.save_mails_listview:removeItem(self.saved_mails[mail.id])
                self.saved_mails[mail.id] = nil
                DataManager:GetManager("MailManager"):DeleteSavedMail(mail)
            else
                target:setButtonSelected(true,true)
            end
        end)
    end
end

function GameUIMail:ReadMail(mailId,cb)
    NetManager:readMail(mailId,cb)
end

function GameUIMail:AddMails( listview,item,mail,index )
    local item_count = self:GetMailsCount(listview)
    if item_count==0 then
        self:AddMailToListView(listview, item, mail)
    else
        self:InsertMailToListView(listview, item, mail, index)
    end
end

function GameUIMail:AddMailToListView(listview,item,mail)
    local mails_table = self:GetMailsTableWithMailListView(listview)
    local id = mail.id or mail.toId
    mails_table[id] = item
    listview:addItem(item,self:GetMailsCount(listview))
    listview:reload()
end

function GameUIMail:GetMailsTableWithMailListView( listview )
    if listview == self.inbox_listview then
        return self.inbox_mails
    elseif listview == self.save_mails_listview then
        return self.saved_mails
    elseif listview == self.send_mail_listview then
        return self.send_mails
    end
end

function GameUIMail:InsertMailToListView(listview,item,mail,index)
    local mails_table = self:GetMailsTableWithMailListView(listview)
    local id = mail.id or mail.toId
    mails_table[id] = item
    local add_index = index or self:GetMailsCount(listview)
    listview:insertItemAndRefresh(item,add_index)
end

function GameUIMail:CreateLoadingMoreItem(listview)
    local item = listview:newItem()
    local item_width, item_height = 612,192
    item:setItemSize(item_width, item_height)
    -- 加载更多按钮
    local loading_more_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("载入更多..."),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})
    loading_more_label:enableShadow()

    local loading_more_button = WidgetPushButton.new(
        {normal = "resource_butter_red.png", pressed = "resource_butter_red_highlight.png"},
        {scale9 = false}
    ):setButtonLabel(loading_more_label)
        :align(display.CENTER, item_width/2, item_height/2)
    loading_more_button:onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            local mails = self:GetMails(listview)
            if mails then
                self:AddLoadingMoreMails(listview,mails)
            end
        end
    end)
    item:addContent(loading_more_button)
    listview.loading_more_button_height = 192
    listview.loading_more_button = item
    listview:addItem(item)
    listview:reload()
end
function GameUIMail:GetMails(listview)
    if listview == self.inbox_listview then
        return DataManager:GetManager("MailManager"):GetMails(NOT_HANDLE, self:GetMailsCount(listview))
    elseif listview == self.save_mails_listview then
        return DataManager:GetManager("MailManager"):GetSavedMails(NOT_HANDLE,self:GetMailsCount(listview))
    elseif listview == self.send_mail_listview then
        return DataManager:GetManager("MailManager"):GetSendMails(NOT_HANDLE,self:GetMailsCount(listview))
    end
end
function GameUIMail:OnServerDataEvent(event)
    if event.eventType == "onGetMailsSuccess" then
        self:AddLoadingMoreMails(self.inbox_listview,event.data.mails)
    elseif event.eventType == "onNewMailReceived" then
        local item = self:CreateMailItem(self.inbox_listview,event.data.mail)
        self:AddMails(self.inbox_listview,item,event.data.mail,1)
    elseif event.eventType == "onGetSavedMailsSuccess" then
        self:AddLoadingMoreMails(self.save_mails_listview,event.data.mails)
    elseif event.eventType == "onGetSendMailsSuccess" then
        self:AddLoadingMoreMails(self.send_mail_listview,event.data.mails)
    elseif event.eventType == "onSendMailSuccess" then
        local item = self:CreateMailItem(self.send_mail_listview,event.data.mail)
        self:AddMails(self.send_mail_listview,item,event.data.mail,1)
    end
end

function GameUIMail:AddLoadingMoreMails(listview,mails)
    local loaded_num = 0
    local now_showed_count = self:GetMailsCount(listview)
    if mails then
        for k,v in pairs(mails) do
            loaded_num = loaded_num + 1
            if loaded_num>GameUIMail.ONE_TIME_LOADING_MAILS then
                break
            end

            local item_1 = self:CreateMailItem(listview,v)
            self:InsertMailToListView(listview,item_1,v)
        end
    end
    -- 如果载入的数量小于10，则代表没有更多的邮件了
    if loaded_num < GameUIMail.ONE_TIME_LOADING_MAILS then
        if listview.loading_more_button then
            listview:removeItem(listview.loading_more_button)
            local _,pre_y = listview.container:getPosition()
            local item_height = listview.loading_more_button_height
            listview.container:setPositionY(pre_y+item_height)
        end
    end
end
function GameUIMail:GetMailsCount(listview)
    local mails_table = self:GetMailsTableWithMailListView(listview)
    local count = 0
    for _,_ in pairs(mails_table) do
        count = count +1
    end
    return count
end
--已发送邮件详情弹出框
function GameUIMail:ShowSendMailDetails(mail)
    -- 蒙层背景
    local layer_bg = display.newColorLayer(UIKit:hex2c4b(0x7a000000)):addTo(self)
    -- bg
    local bg = WidgetUIBackGround.new(768):addTo(layer_bg)
    bg:pos((display.width-bg:getContentSize().width)/2,display.top - bg:getContentSize().height - 120)
    -- mail content bg
    local content_bg = WidgetUIBackGround2.new(544):addTo(bg)
    content_bg:pos((bg:getContentSize().width-content_bg:getContentSize().width)/2,30)
    -- title bg
    local title_bg = display.newSprite("title_blue_596x49.png"):align(display.TOP_LEFT, 6, bg:getContentSize().height-6):addTo(bg)
    -- title
    local title_string = mail.fromAllianceTag~="" and "["..mail.fromAllianceTag.."] "..mail.fromName or mail.fromName
    local title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = title_string,
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.LEFT_CENTER, 150, 25)
        :addTo(title_bg)
    -- player head icon
    local heroBg = display.newSprite("chat_hero_background.png"):align(display.CENTER, 76, bg:getContentSize().height - 70):addTo(bg)
    local hero = display.newSprite("Hero_1.png"):align(display.CENTER, math.floor(heroBg:getContentSize().width/2), math.floor(heroBg:getContentSize().height/2)+5)
    hero:addTo(heroBg)
    --close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeChild(layer_bg, true)
            end
        end):align(display.CENTER, title_bg:getContentSize().width-10, title_bg:getContentSize().height-6):addTo(title_bg):addChild(display.newSprite("X_3.png"))
    -- 收件人
    local subject_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("收件人: "),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 155, bg:getContentSize().height-80)
        :addTo(bg)
    local subject_content_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.toName,
            font = UIKit:getFontFilePath(),
            size = 20,
            dimensions = cc.size(0,24),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,155 + subject_label:getContentSize().width+20, bg:getContentSize().height-80)
        :addTo(bg)
    -- 主题
    local subject_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("主题: "),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 155, bg:getContentSize().height-120)
        :addTo(bg)
    local subject_content_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.title,
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,155 + subject_label:getContentSize().width+20, bg:getContentSize().height-120)
        :addTo(bg)
    -- 日期
    local date_title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("日期: "),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 155, bg:getContentSize().height-160)
        :addTo(bg)
    local date_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = GameUtils:formatTimeStyle2(mail.sendTime/1000),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER, 155 + date_title_label:getContentSize().width+20, bg:getContentSize().height-160)
        :addTo(bg)
    -- 内容
    local content_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(0, 10, 550, 520),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(content_bg):pos(10, 0)
    local content_item = content_listview:newItem()
    local content_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.content,
            font = UIKit:getFontFilePath(),
            size = 20,
            dimensions = cc.size(550,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_TOP)
    content_item:setItemSize(570,content_label:getContentSize().height)
    content_item:addContent(content_label)
    content_listview:addItem(content_item)
    content_listview:reload()
end
--邮件详情弹出框
function GameUIMail:ShowMailDetails(mail)
    -- 蒙层背景
    local layer_bg = display.newColorLayer(UIKit:hex2c4b(0x7a000000)):addTo(self)
    -- bg
    local bg = WidgetUIBackGround.new(768):addTo(layer_bg)
    bg:pos((display.width-bg:getContentSize().width)/2,display.top - bg:getContentSize().height - 120)
    -- mail content bg
    local content_bg = WidgetUIBackGround2.new(544):addTo(bg)
    content_bg:pos((bg:getContentSize().width-content_bg:getContentSize().width)/2,80)
    -- title bg
    local title_bg = display.newSprite("title_blue_596x49.png"):align(display.TOP_LEFT, 6, bg:getContentSize().height-6):addTo(bg)
    -- title
    local title_string = mail.fromAllianceTag~="" and "["..mail.fromAllianceTag.."] "..mail.fromName or mail.fromName
    local title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = title_string,
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.LEFT_CENTER, 150, 25)
        :addTo(title_bg)
    -- player head icon
    local heroBg = display.newSprite("chat_hero_background.png"):align(display.CENTER, 76, bg:getContentSize().height - 70):addTo(bg)
    local hero = display.newSprite("Hero_1.png"):align(display.CENTER, math.floor(heroBg:getContentSize().width/2), math.floor(heroBg:getContentSize().height/2)+5)
    hero:addTo(heroBg)
    --close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeChild(layer_bg, true)
            end
        end):align(display.CENTER, title_bg:getContentSize().width-10, title_bg:getContentSize().height-6):addTo(title_bg):addChild(display.newSprite("X_3.png"))
    -- 主题
    local subject_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("主题: "),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 155, bg:getContentSize().height-80)
        :addTo(bg)
    local subject_content_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.title,
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER,155 + subject_label:getContentSize().width+20, bg:getContentSize().height-80)
        :addTo(bg)
    -- 日期
    local date_title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("日期: "),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 155, bg:getContentSize().height-120)
        :addTo(bg)
    local date_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = GameUtils:formatTimeStyle2(mail.sendTime/1000),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER, 155 + date_title_label:getContentSize().width+20, bg:getContentSize().height-120)
        :addTo(bg)
    -- 内容
    local content_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(0, 10, 550, 520),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(content_bg):pos(10, 0)
    local content_item = content_listview:newItem()
    local content_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.content,
            font = UIKit:getFontFilePath(),
            size = 20,
            dimensions = cc.size(550,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_TOP)
    content_item:setItemSize(570,content_label:getContentSize().height)
    content_item:addContent(content_label)
    content_listview:addItem(content_item)
    content_listview:reload()
    if mail.isSaved then
        -- 删除按钮
        local delete_label = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("删除"),
            size = 20,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)})
        delete_label:enableShadow()

        WidgetPushButton.new(
            {normal = "resource_butter_red.png", pressed = "resource_butter_red_highlight.png"},
            {scale9 = false}
        ):setButtonLabel(delete_label)
            :addTo(bg):align(display.CENTER, 140, 50)
            :onButtonClicked(function(event)
                if event.name == "CLICKED_EVENT" then
                    NetManager:deleteMail(mail.id,function (flag)
                        if flag then
                            layer_bg:removeFromParent()
                            self.inbox_listview:removeItem(self.inbox_mails[mail.id])
                            self.inbox_mails[mail.id]=nil
                            DataManager:GetManager("MailManager"):DeleteMail(mail)
                        end
                    end)
                end
            end)
        -- 回复按钮
        local replay_label = cc.ui.UILabel.new({
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("回复"),
            size = 20,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xfff3c7)})

        replay_label:enableShadow()
        WidgetPushButton.new(
            {normal = "keep_unlocked_button_normal.png", pressed = "keep_unlocked_button_pressed.png"},
            {scale9 = false}
        ):setButtonLabel(replay_label)
            :addTo(bg):align(display.CENTER, bg:getContentSize().width-140, 50)
            :onButtonClicked(function(event)
                self:CreateReplyMail(mail):addTo(layer_bg)
            end)
    end
    -- 收藏按钮
    local saved_button = UICheckBoxButton.new({
        off = "mail_saved_button_normal.png",
        off_pressed = "mail_saved_button_normal.png",
        off_disabled = "mail_saved_button_normal.png",
        on = "mail_saved_button_pressed.png",
        on_pressed = "mail_saved_button_pressed.png",
        on_disabled = "mail_saved_button_pressed.png",
    }):setButtonSelected(tolua.type(mail.isSaved)=="nil" or mail.isSaved,true):onButtonStateChanged(function(event)
        self:SaveOrUnsaveMail(mail,event.target)
    end):addTo(bg):pos(bg:getContentSize().width-40, 37)
end

-- report layer
function GameUIMail:InitReport()
    local flag = true
    self.report_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-304, display.top-890, 612, 790),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.report_layer)

    self:CreateReportItem()
    self:CreateReportItem()
    self:CreateReportItem()
    self:CreateReportItem()

    self:CreateReportItem(true)
end

function GameUIMail:CreateReportItem(flag)
    local item = self.report_listview:newItem()
    local item_width, item_height = 612,200
    item:setItemSize(item_width, item_height)
    local content = WidgetPushButton.new({normal = "back_ground_608x196.png",pressed = "back_ground_608x196.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if flag then
                    GameUIWarReport.new():addTo(self)
                else
                    GameUIStrikeReport.new():addTo(self)
                end
            end
        end)
    local c_size = content:getContentSize()
    local title_bg = display.newSprite("title_red_588X30.png", 0, 66):addTo(content)
    local report_state_bg = display.newSprite("back_ground_44X44.png", 35, 16):addTo(title_bg)
    local report_state= display.newSprite("dragon_red.png", 22, 22):addTo(report_state_bg)
    local from_name_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("[KOD] Viciouss"),
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.LEFT_CENTER, 60, 17)
        :addTo(title_bg)
    local date_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("2015.5.1 13:50"),
            font = UIKit:getFontFilePath(),
            size = 16,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.RIGHT_CENTER, 540, 17)
        :addTo(title_bg)
    local report_content_bg = display.newSprite("report_back_ground.png", 0, -4):addTo(content)
    -- 战报发出方信息
    -- 旗帜
    display.newSprite("report_from_icon.png", 120, 47):addTo(report_content_bg)
    -- from title label
    local from_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("From"),
            font = UIKit:getFontFilePath(),
            size = 16,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 160, 70)
        :addTo(report_content_bg)
    -- 发出方名字
    local from_player_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("Viciouss"),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER, 160, 50)
        :addTo(report_content_bg)
    -- 发出方所属联盟
    local from_alliance_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("[KOD]"),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER, 160, 30)
        :addTo(report_content_bg)


    -- 战报发向方信息
    -- 旗帜
    display.newSprite("report_to_icon.png", 360, 47):addTo(report_content_bg)
    -- to title label
    local to_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("To"),
            font = UIKit:getFontFilePath(),
            size = 16,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER, 400, 70)
        :addTo(report_content_bg)
    -- 发向方名字
    local to_player_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("Viciouss"),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER, 400, 50)
        :addTo(report_content_bg)
    -- 发向方所属联盟
    local to_alliance_label =  cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("[KOD]"),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_CENTER, 400, 30)
        :addTo(report_content_bg)

    local report_result_bg = WidgetUIBackGround2.new(34):addTo(content):pos(-290, -87)
    local report_result_label = cc.ui.UILabel.new(
        {
            UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("敌方获得一封C级情报"),
            font = UIKit:getFontFilePath(),
            size = 18,
            -- dimensions = cc.size(200,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.CENTER, report_result_bg:getContentSize().width/2, report_result_bg:getContentSize().height/2)
        :addTo(report_result_bg)
    local saved_button = UICheckBoxButton.new({
        off = "mail_saved_button_normal.png",
        off_pressed = "mail_saved_button_normal.png",
        off_disabled = "mail_saved_button_normal.png",
        on = "mail_saved_button_pressed.png",
        on_pressed = "mail_saved_button_pressed.png",
        on_disabled = "mail_saved_button_pressed.png",
    }):onButtonStateChanged(function(event)

        end):addTo(content):pos(265, -60)
    item:addContent(content)
    self.report_listview:addItem(item)
    self.report_listview:reload()
end

function GameUIMail:InitSaved()
    self.saved_listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(display.cx-304, display.top-890, 612, 790),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.saved_layer)
end

function GameUIMail:CreateReplyMail(mail)
    -- bg
    local reply_mail = WidgetUIBackGround.new(768)
    reply_mail:pos((display.width-reply_mail:getContentSize().width)/2,display.top - reply_mail:getContentSize().height - 120)
    local r_size = reply_mail:getContentSize()
    -- title reply_mail
    local title_reply_mail = display.newSprite("title_blue_596x49.png"):align(display.TOP_LEFT, 6, reply_mail:getContentSize().height-6):addTo(reply_mail)
    -- title
    local title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("回复邮件"),
            font = UIKit:getFontFilePath(),
            size = 22,
            dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0xffedae)
        }):align(display.LEFT_CENTER,30, 25)
        :addTo(title_reply_mail)

    --close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                reply_mail:removeFromParent()
            end
        end):align(display.CENTER, title_reply_mail:getContentSize().width-10, title_reply_mail:getContentSize().height-6):addTo(title_reply_mail):addChild(display.newSprite("X_3.png"))

    -- 收件人
    local addressee_title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("收件人："),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.RIGHT_CENTER,120, r_size.height-90)
        :addTo(reply_mail)
    local addressee_input_box_image = display.newSprite("input_box.png",350, r_size.height-90):addTo(reply_mail)
    local addressee_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.fromAllianceTag~="" and _("RE:").."["..mail.fromAllianceTag.."]"..mail.fromName
            or _("RE:")..mail.fromName,
            font = UIKit:getFontFilePath(),
            size = 18,
            dimensions = cc.size(410,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER,10,18)
        :addTo(addressee_input_box_image)
    -- 主题
    local subject_title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("主题："),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.RIGHT_CENTER,120, r_size.height-140)
        :addTo(reply_mail)
    local subject_input_box_image = display.newSprite("input_box.png",350, r_size.height-140):addTo(reply_mail)
    local subject_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("RE:")..mail.title,
            font = UIKit:getFontFilePath(),
            size = 18,
            dimensions = cc.size(410,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER,10,18)
        :addTo(subject_input_box_image)
    -- 分割线
    display.newScale9Sprite("dividing_line_584x1.png", r_size.width/2, r_size.height-180,cc.size(594,1)):addTo(reply_mail)
    -- 内容
    cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("内容："),
            font = UIKit:getFontFilePath(),
            size = 18,
            dimensions = cc.size(410,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.LEFT_CENTER,30,r_size.height-200)
        :addTo(reply_mail)
    -- 回复的邮件内容
    local lucid_bg = WidgetBackGroundLucid.new(472):addTo(reply_mail)
    lucid_bg:pos((r_size.width-lucid_bg:getContentSize().width)/2, 82)
    display.newScale9Sprite("dividing_line_584x1.png", lucid_bg:getContentSize().width/2, lucid_bg:getContentSize().height-288,cc.size(580,1)):addTo(lucid_bg)



    local textView = cc.DTextView:create(cc.size(578,278),display.newScale9Sprite("background_578X278.png"))
    textView:align(display.LEFT_TOP,1,lucid_bg:getContentSize().height-5):addTo(lucid_bg)
    textView:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    textView:setFont(UIKit:getFontFilePath(), 24)

    textView:setFontColor(cc.c3b(0,0,0))

    -- 被回复的邮件内容
    local content_listview = UIListView.new{
        bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(0, 10, 560, 170),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(lucid_bg):pos(10, 0)
    local content_item = content_listview:newItem()
    local content_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = mail.content,
            font = UIKit:getFontFilePath(),
            size = 20,
            dimensions = cc.size(560,0),
            color = UIKit:hex2c3b(0x403c2f)
        }):align(display.LEFT_TOP)
    content_item:setItemSize(560,content_label:getContentSize().height)
    content_item:addContent(content_label)
    content_listview:addItem(content_item)
    content_listview:reload()

    -- 回复按钮
    local send_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("发送"),
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)})

    send_label:enableShadow()
    WidgetPushButton.new(
        {normal = "keep_unlocked_button_normal.png", pressed = "keep_unlocked_button_pressed.png"},
        {scale9 = false}
    ):setButtonLabel(send_label)
        :addTo(reply_mail):align(display.CENTER, reply_mail:getContentSize().width-120, 40)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:SendMail(mail.fromName, _("RE:")..mail.title, textView:getText())
                reply_mail:removeFromParent()
            end
        end)
    return reply_mail
end


function GameUIMail:CreateWriteMail()
    local layer_bg = display.newColorLayer(UIKit:hex2c4b(0x7a000000)):addTo(self)
    -- bg
    local write_mail = WidgetUIBackGround.new(768):addTo(layer_bg)
    write_mail:pos((display.width-write_mail:getContentSize().width)/2,display.top - write_mail:getContentSize().height - 120)
    local r_size = write_mail:getContentSize()
    -- title write_mail
    local title_write_mail = display.newSprite("title_blue_596x49.png"):align(display.TOP_LEFT, 6, write_mail:getContentSize().height-6):addTo(write_mail)
    -- title
    local title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("写邮件"),
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
                layer_bg:removeFromParent()
            end
        end):align(display.CENTER, title_write_mail:getContentSize().width-10, title_write_mail:getContentSize().height-6):addTo(title_write_mail):addChild(display.newSprite("X_3.png"))

    -- 收件人
    local addressee_title_label = cc.ui.UILabel.new(
        {cc.ui.UILabel.LABEL_TYPE_TTF,
            text = _("收件人："),
            font = UIKit:getFontFilePath(),
            size = 20,
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.RIGHT_CENTER,120, r_size.height-90)
        :addTo(write_mail)
    local editbox_addressee = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(422,40),
        listener = onEdit,
        font = UIKit:getFontFilePath(),
    })
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
            -- dimensions = cc.size(200,24),
            color = UIKit:hex2c3b(0x797154)
        }):align(display.RIGHT_CENTER,120, r_size.height-140)
        :addTo(write_mail)
    local editbox_subject = cc.ui.UIInput.new({
        UIInputType = 1,
        image = "input_box.png",
        size = cc.size(422,40),
        listener = onEdit,
        font = UIKit:getFontFilePath(),
    })
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
    local textView = cc.DTextView:create(cc.size(580,472),display.newScale9Sprite("background_580X472.png"))
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
    WidgetPushButton.new(
        {normal = "keep_unlocked_button_normal.png", pressed = "keep_unlocked_button_pressed.png"},
        {scale9 = false}
    ):setButtonLabel(send_label)
        :addTo(write_mail):align(display.CENTER, write_mail:getContentSize().width-120, 40)
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:SendMail(editbox_addressee:getText(), editbox_subject:getText(), textView:getText())
                layer_bg:removeFromParent()
            end
        end)
    return layer_bg
end

--[[
    发送邮件
    @param addressee 收件人
    @param title 邮件主题
    @param content 邮件内容 
]]
function GameUIMail:SendMail(addressee,title,content)
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
    NetManager:sendPersonalMail(addressee, title, content,NOT_HANDLE)
end

return GameUIMail