local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetPVEGetRewards = class("WidgetPVEGetRewards", WidgetPopDialog)


function WidgetPVEGetRewards:ctor()
    WidgetPVEGetRewards.super.ctor(self, 250, _("完成奖励"), display.cy + 150)
end






return WidgetPVEGetRewards