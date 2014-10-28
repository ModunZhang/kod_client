local WidgetUIBackGround = import(".WidgetUIBackGround")
local WidgetWithBlueTitle = class("WidgetWithBlueTitle", function(height, title)
    local back_ground = WidgetUIBackGround.new({height=height}):align(display.CENTER)
    local size = back_ground:getContentSize()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png")
        :addTo(back_ground, 2)
        :align(display.CENTER, size.width / 2, height - 49/2)

    back_ground.title_label = cc.ui.UILabel.new({
        text = title,
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_RIGHT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue, 2):align(display.LEFT_CENTER, 20, title_blue:getContentSize().height/2)
    return back_ground
end)
function WidgetWithBlueTitle:SetTitle(title)
	if self.title_label:getString() ~= title then
		self.title_label:setString(title)
	end
end


return WidgetWithBlueTitle

