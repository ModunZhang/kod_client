--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local GameUIBlackSmith = UIKit:createUIClass("GameUIBlackSmith", "GameUIWithCommonHeader")
function GameUIBlackSmith:ctor(city)
    GameUIBlackSmith.super.ctor(self, city, _("铁匠铺"))
end
function GameUIBlackSmith:onEnter()
    GameUIBlackSmith.super.onEnter(self)



    self.tips = self:CreateTips()

    self.list_view = self:CreateVerticalListView(20, display.bottom + 70, display.right - 20, display.top - 230)

    local item = self.list_view:newItem()


    local back_ground = cc.ui.UIImage.new("back_ground_608x227.png"):align(display.CENTER)
    local pos = back_ground:getAnchorPointInPoints()
    local title_blue = cc.ui.UIImage.new("title_blue_596x49.png"):addTo(back_ground)
    title_blue:align(display.CENTER, pos.x, back_ground:getContentSize().height - title_blue:getContentSize().height/2)

    local title_label = cc.ui.UILabel.new({
        text = _("灰色套装"),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue)
        :align(display.LEFT_CENTER, 15, title_blue:getContentSize().height/2)


    local equipment_btn = cc.ui.UIPushButton.new(
        {normal = "star1_105x104.png",pressed = "star1_105x104.png"})
        :addTo(back_ground):align(display.CENTER, 100, 100)
        :onButtonPressed(function(event)
            event.target.pre_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
        end)
        :onButtonRelease(function(event)
            local cur_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
            if event.touchInTarget and cc.pGetDistance(cur_pos, event.target.pre_pos) < 10 then
                event.target:my_onButtonClicked(event)
            end
        end)
    equipment_btn:setTouchSwallowEnabled(false)
    equipment_btn.set_clicked_function = function(sender, func)
        sender.my_onButtonClicked = func
        return sender
    end
    equipment_btn:set_clicked_function(function()
    	print("hello")
    end)




    item:addContent(back_ground)
    item:setItemSize(608, 227)
    self.list_view:addItem(item)


    self.list_view:reload():resetPosition()


    self:TabButtons()

    -- self.home_btn:onButtonClicked(function(event)
    --     NetManager:makeDragonEquipment("moltenCrown", NOT_HANDLE)
    -- end)
end
function GameUIBlackSmith:TabButtons()
    self:CreateTabButtons({
        {
            label = _("升级"),
            tag = "upgrade",
        },
        {
            label = _("制作"),
            tag = "manufacture",
            default = true,
        }
    },
    function(tag)
        if tag == 'upgrade' then
            self.list_view:setVisible(false)
        elseif tag == "manufacture" then
            self.list_view:setVisible(true)
        end
    end):pos(display.cx, display.bottom + 40)
end
function GameUIBlackSmith:CreateTips()
    local back_ground = cc.ui.UIImage.new("back_ground_549x108.png",
        {scale9 = true}):addTo(self)
        :align(display.CENTER, display.cx, display.top - 160)

    local align_x = 30
    cc.ui.UILabel.new({
        text = _("生成队列空闲"),
        size = 24,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2):align(display.LEFT_BOTTOM, align_x, 60)

    cc.ui.UILabel.new({
        text = _("请选择一个装备制造"),
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0x403c2f)
    }):addTo(back_ground, 2):align(display.LEFT_BOTTOM, align_x, 20)

    return back_ground
end



return GameUIBlackSmith












