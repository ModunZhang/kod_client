local window = import("..utils.window")
local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetPushButton = import(".WidgetPushButton")
local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetPVESelectStage = class("WidgetPVESelectStage", WidgetPopDialog)




function WidgetPVESelectStage:ctor(user)
    self.user = user
    self.pve_database = user:GetPVEDatabase()
    WidgetPVESelectStage.super.ctor(self, 600, _("选择关卡"), display.cy + 250)
    local list_view, listnode=  UIKit:commonListView({
        bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 0, 568, 500),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    })
    listnode:addTo(self):align(display.BOTTOM_CENTER, window.cx,window.bottom_top + 100)

    for i = 1, self.pve_database:MapLen() do
    	list_view:addItem(self:CreateItemWithListView(list_view, i))
    end
    list_view:reload()
end


function WidgetPVESelectStage:CreateItemWithListView(list_view, level)
    local item = list_view:newItem()
    local w = 568
    local h = 142
    local back_ground = WidgetUIBackGround.new({
        width = w,
        height = h,
        top_img = "back_ground_568x16_top.png",
        bottom_img = "back_ground_568x80_bottom.png",
        mid_img = "back_ground_568x28_mid.png",
        u_height = 16,
        b_height = 80,
        m_height = 28,
    })
    item:addContent(back_ground)
    item:setItemSize(w, h)



    local cur_map = self.pve_database:GetMapByIndex(level)

    local name = cc.ui.UILabel.new({
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f),
        text = "1 关卡名"
    }):addTo(back_ground, 2):align(display.LEFT_CENTER, 30, h - 50)


    local status = cc.ui.UILabel.new({
        size = 18,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f),
        text = string.format("探索度 %.2f%%", cur_map:ExploreDegree() * 100)
    }):addTo(back_ground, 2):align(display.LEFT_CENTER, 30, 50)

    local btn = WidgetPushButton.new(
        {normal = "yellow_btn_up_148x58.png",pressed = "yellow_btn_down_148x58.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(back_ground)
        :align(display.CENTER, w - 90, 40)
        :setButtonLabel(cc.ui.UILabel.new({
            text = _("传送"),
            size = 24,
            font = UIKit:getFontFilePath(),
            color = UIKit:hex2c3b(0xffedae)}))
        :onButtonClicked(function(event)
            if self.user:GetCurrentPVEMap():GetIndex() == level then
                print("你已经在当前关卡")
            else
                print("level ", level)
            end
        end)

        btn:setButtonEnabled(cur_map:IsAvailable())
    


    return item
end



return WidgetPVESelectStage




















