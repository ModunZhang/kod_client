local UIListView = import(".UIListView")
local UIAutoClose = import(".UIAutoClose")

local FullScreenPopDialogUI = class("FullScreenPopDialogUI", UIAutoClose)

function FullScreenPopDialogUI:ctor()
    self:Init()
end

function FullScreenPopDialogUI:Init()
    -- bg
    local bg = display.newSprite("back_ground_608x350.png", display.cx, display.top - 480)
    self:addTouchAbleChild(bg)
    local size = bg:getContentSize()
    -- title bg
    local title_bg =display.newSprite("report_title.png", size.width/2, size.height+10):addTo(bg)
    -- title label
    self.title = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "title",
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xffedae)
    }):align(display.CENTER,title_bg:getContentSize().width/2,title_bg:getContentSize().height/2):addTo(title_bg)
    -- npc image
    display.newSprite("Npc.png"):align(display.LEFT_BOTTOM, -50, -14):addTo(bg)
    -- 对话框 bg
    local tip_bg = display.newSprite("back_ground_342x228.png", 406,210):addTo(bg)
    self.tip_bg= tip_bg
    -- 称谓label
    cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("主人").."!",
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_TOP,14,210):addTo(tip_bg)

    -- close button
    self.close_btn = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent()
            end
        end):align(display.CENTER, size.width-30, size.height+16):addTo(bg)
end

function FullScreenPopDialogUI:SetTitle(title)
    self.title:setString(title)
    return self
end

function FullScreenPopDialogUI:SetPopMessage(message)
    local message_label = UIKit:ttfLabel({
        text = message,
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_CENTER,
        dimensions = cc.size(310, 0),
    })
    local w,h =  message_label:getContentSize().width,message_label:getContentSize().height
    -- 提示内容
    local  listview = UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(14,10, w, 170),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(self.tip_bg)
    local item = listview:newItem()
    item:setItemSize(w,h)
    item:addContent(message_label)
    listview:addItem(item)
    listview:reload()
    return self
end

function FullScreenPopDialogUI:CreateOKButton(params)
    local params = params or {}
    local listener,btn_name = params.listener,params.btn_name
    local name = btn_name or _("确定")
    local ok_button = cc.ui.UIPushButton.new({normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({text =name, size = 24, color = 0xffedae,shadow=true}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent()
                if listener then
                    listener()
                end
            end
        end):align(display.CENTER, display.cx+200, display.top-610):addTo(self)
    return self
end

function FullScreenPopDialogUI:CreateCancelButton(params)
    local params = params or {}
    local listener,btn_name = params.listener,params.btn_name
    local name = btn_name or _("取消")
    local ok_button = cc.ui.UIPushButton.new({normal = "red_btn_up_148x58.png",pressed = "red_btn_down_148x58.png"})
        :setButtonLabel(UIKit:ttfLabel({text =name, size = 24, color = 0xffedae,shadow=true}))
        :onButtonClicked(function(event)
            if event.name == "CLICKED_EVENT" then
                self:removeFromParent()
                if listener then
                    listener()
                end
            end
        end):align(display.CENTER, display.cx+6, display.top-610):addTo(self)

    self.close_btn:onButtonClicked(function(event)
        if event.name == "CLICKED_EVENT" then
            self:removeFromParent()
            if listener then
                listener()
            end
        end
    end)
    return self
end

function FullScreenPopDialogUI:CreateNeeds(icon,value,color)
    local icon_image = display.newScale9Sprite(icon, display.cx-30, display.top-610):addTo(self)
    icon_image:setScale(30/icon_image:getContentSize().height)
    self.needs_label = UIKit:ttfLabel({
        text = value.."",
        size = 24,
        color = color or 0x403c2f
    }):align(display.LEFT_CENTER,display.cx+10,display.top-610):addTo(self)
    return self
end
function FullScreenPopDialogUI:SetNeedsValue(value)
    if self.needs_label then
        self.needs_label:setString(value)
    end
    return self
end
function FullScreenPopDialogUI:VisibleXButton(visible)
    self.close_btn:setVisible(visible)
    return self
end
function FullScreenPopDialogUI:AddToCurrentScene(anima)
    display.getRunningScene():addChild(self,3000)
    return self
end
return FullScreenPopDialogUI














