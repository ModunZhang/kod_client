
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")


local GameUICollectReport = class("GameUICollectReport",WidgetPopDialog)


function GameUICollectReport:ctor()
    GameUICollectReport.super.ctor(self,768,_("发邮件"))
    -- bg
    local write_mail = self.body
    local r_size = write_mail:getContentSize()
  
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


return GameUICollectReport








   



