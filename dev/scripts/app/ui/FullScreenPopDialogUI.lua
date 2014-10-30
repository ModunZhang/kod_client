local UIListView = import(".UIListView")

local FullScreenPopDialogUI = class("FullScreenPopDialogUI", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function FullScreenPopDialogUI:ctor()
    self:Init()
end

function FullScreenPopDialogUI:Init()
    -- bg
    display.newSprite("full_screen_dialog_bg.png", display.cx, display.top - 480):addTo(self)
    -- title bg
    display.newSprite("Title_blue.png", display.cx, display.top-340):addTo(self)
    -- title label
    self.title = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "title",
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER,display.cx,display.top-340):addTo(self)
    -- npc image
    display.newSprite("Npc.png", display.cx - 205, display.top-470):addTo(self)
    -- 对话框 bg
    display.newSprite("pop_tip_bg.png", display.cx+80, display.top-460):addTo(self)

    -- 称谓label
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("陛下，"),
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx-80,display.top-410):addTo(self)

    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent(true)
            end
        end):align(display.CENTER, display.cx + 290, display.top-320):addTo(self)
    self.close_btn:addChild(display.newSprite("X_3.png"))
end

function FullScreenPopDialogUI:SetTitle(title)
    self.title:setString(title)
    return self
end

function FullScreenPopDialogUI:SetPopMessage(message)
    -- 提示内容
    local  listview = UIListView.new{
        viewRect = cc.rect(display.cx-80,display.top-525, 340, 95),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self)
    local message_label = UIKit:ttfLabel({
        text = message,
        size = 24,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        dimensions = cc.size(340, 0),
    })
    local item = listview:newItem()
    local w,h =  message_label:getContentSize().width,message_label:getContentSize().height
    item:setItemSize(w,h)
    item:addContent(message_label)
    listview:addItem(item)
    listview:reload()
    return self
end

function FullScreenPopDialogUI:CreateOKButton(listener,btn_name)
    local name = btn_name or _("确定")
    local ok_button = cc.ui.UIPushButton.new({normal = "yellow_button_146x42.png",pressed = "yellow_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({text =name, size = 26, color = 0xffedae,shadow=true}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if listener then
                    listener()
                end
                self:removeFromParent(true)
            end
        end):align(display.CENTER, display.cx, display.top-610):addTo(self)
    return self
end

function FullScreenPopDialogUI:CreateCancelButton(params)
    local params = params or {}
    local listener,btn_name = params.listener,params.btn_name
    local name = btn_name or _("取消")
    local ok_button = cc.ui.UIPushButton.new({normal = "red_button_146x42.png",pressed = "red_button_highlight_146x42.png"})
        :setButtonLabel(UIKit:ttfLabel({text =name, size = 26, color = 0xffedae,shadow=true}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                if listener then
                    listener()
                end
                self:removeFromParent(true)
            end
        end):align(display.CENTER, display.cx+200, display.top-610):addTo(self)

    self.close_btn:onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            if listener then
                listener()
            end
            self:removeFromParent(true)
        end
    end)
    return self
end

function FullScreenPopDialogUI:CreateNeeds(icon,value)
    local icon_image = display.newScale9Sprite(icon, display.cx-30, display.top-560):addTo(self)
    icon_image:setScale(30/icon_image:getContentSize().height)
    self.needs_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = value.."",
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xfdfac2)
    }):align(display.LEFT_CENTER,display.cx+10,display.top-560):addTo(self)
    return self
end
function FullScreenPopDialogUI:SetNeedsValue(value)
    if self.needs_label then
        self.needs_label:setString(value)
    end
    return self
end
function FullScreenPopDialogUI:AddToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end
return FullScreenPopDialogUI














