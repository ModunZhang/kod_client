local FullScreenPopDialogUI = class("FullScreenPopDialogUI", function ()
    return display.newColorLayer(cc.c4b(0,0,0,127))
end)

function FullScreenPopDialogUI:ctor()
    -- self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
    --     print("ccccccc",event.name)
    --     if event.name=="ended" then
    --         self:removeFromParent(true)
    --     end
    -- end, 1)
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
    -- 提示内容
    self.message_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        -- text = _("陛下，.................."),
        font = UIKit:getFontFilePath(),
        size = 24,
        dimensions = cc.size(360, 88),
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.LEFT_CENTER,display.cx-80,display.top-470):addTo(self)

    -- close button
    cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"})
        :onButtonClicked(function(event)
            self:removeFromParent(true)
        end):align(display.CENTER, display.cx + 290, display.top-320):addTo(self):addChild(display.newSprite("X_3.png"))

end

function FullScreenPopDialogUI:SetTitle(title)
    self.title:setString(title)
end

function FullScreenPopDialogUI:SetPopMessage(message)
    self.message_label:setString(message)
end

function FullScreenPopDialogUI:CreateOKButton(listener)
    local ok_button = cc.ui.UIPushButton.new({normal = "green_button_normal.png",pressed = "green_button_pressed.png"})
        :setButtonLabel(cc.ui.UILabel.new({UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,text = _("是的"), size = 26, color = display.COLOR_WHITE}))
        :onButtonClicked(function(event)
            -- print(" pop dialog click")
            listener()
            self:removeFromParent(true)
        end):align(display.CENTER, display.cx+50, display.top-610):addTo(self)
end

function FullScreenPopDialogUI:CreateNeeds(icon,value)
    local icon_image = display.newScale9Sprite(icon, display.cx+20, display.top-560):addTo(self)
    icon_image:setScale(30/icon_image:getContentSize().height)
    self.needs_label = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = value.."",
        font = UIKit:getFontFilePath(),
        size = 24,
        color = UIKit:hex2c3b(0xfdfac2)
    }):align(display.LEFT_CENTER,display.cx+60,display.top-560):addTo(self)
end
function FullScreenPopDialogUI:SetNeedsValue(value)
    if self.needs_label then
        self.needs_label:setString(value)
    end
end
function FullScreenPopDialogUI:AddToCurrentScene(anima)
    diplay.getRunningScene():addChild(self)
end
return FullScreenPopDialogUI







