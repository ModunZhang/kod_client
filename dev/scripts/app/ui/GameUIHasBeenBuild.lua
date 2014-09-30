local window = import("..utils.window")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetPushButton = import("..widget.WidgetPushButton")
local GameUIHasBeenBuild = UIKit:createUIClass('GameUIHasBeenBuild', "GameUIWithCommonHeader")
function GameUIHasBeenBuild:ctor(city)
    GameUIHasBeenBuild.super.ctor(self, city, _("建筑列表"))
    self.build_city = city
end
function GameUIHasBeenBuild:onEnter()
    self.build_city:AddListenOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.onEnter(self)
    self:TabButtons()
end
function GameUIHasBeenBuild:onExit()
    self.build_city:RemoveListenerOnType(self, self.build_city.LISTEN_TYPE.UPGRADE_BUILDING)
    GameUIHasBeenBuild.super.onExit(self)
end
function GameUIHasBeenBuild:OnUpgradingBegin(building)

end
function GameUIHasBeenBuild:OnUpgrading()

end
function GameUIHasBeenBuild:OnUpgradingFinished(building)
end

function GameUIHasBeenBuild:TabButtons()
    self:CreateTabButtons({
        {
            label = _("功能建筑"),
            tag = "function",
            default = true
        },
        {
            label = _("资源建筑"),
            tag = "resource",
        },
    },
    function(tag)
        if tag == "function" then
            self:LoadFunctionListView()
        elseif tag == "resource" then
            self:UnloadFunctionListView()
        end
    end):pos(window.cx, window.bottom + 34)
end
function GameUIHasBeenBuild:LoadFunctionListView()
    if not self.function_list_view then
        self.function_list_view = self:CreateVerticalListView(window.left + 20, window.bottom + 70, window.right - 20, window.top - 180)

        local item = self:CreateItemWithListView(self.function_list_view)
        self.function_list_view:addItem(item)
        self.function_list_view:reload():resetPosition()
    end
    self.function_list_view:setVisible(true)
end
function GameUIHasBeenBuild:UnloadFunctionListView()
    self.function_list_view:removeFromParentAndCleanup(true)
    self.function_list_view = nil
end


function GameUIHasBeenBuild:CreateItemWithListView(list_view)
    local item = list_view:newItem()
    local back_ground = WidgetUIBackGround.new(170)
    item:addContent(back_ground)



    local w, h = back_ground:getContentSize().width, back_ground:getContentSize().height
    item:setItemSize(w, h + 10)

    local left_x, right_x = 15, 160
    local left = display.newSprite("building_frame_36x136.png")
        :addTo(back_ground):align(display.LEFT_CENTER, left_x, h/2):flipX(true)

    display.newSprite("building_frame_36x136.png")
        :addTo(back_ground):align(display.RIGHT_CENTER, right_x, h/2)

    WidgetPushButton.new(
        {normal = "info_26x26.png",pressed = "info_26x26.png"})
        :addTo(left)
        :align(display.CENTER, 6, 6)


    display.newSprite("keep_131x164.png")
        :addTo(back_ground):align(display.CENTER, (left_x + right_x) / 2, h/2 + 30)


    local title_blue = display.newSprite("title_blue_402x48.png")
        :addTo(back_ground):align(display.LEFT_CENTER, right_x + 15, h - 33)
    
    local size = title_blue:getContentSize()
    local title_label = cc.ui.UILabel.new({
        text = "城堡",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue, 2)
        :align(display.LEFT_CENTER, 30, size.height/2)



        local title_label = cc.ui.UILabel.new({
        text = "城堡",
        size = 22,
        font = UIKit:getFontFilePath(),
        align = cc.ui.TEXT_ALIGN_LEFT,
        color = UIKit:hex2c3b(0xffedae)
    }):addTo(title_blue, 2)
        :align(display.LEFT_CENTER, 30, size.height/2)

    -- display.newSprite("build_item/building_image.png")
    --     :addTo(content)
    --     :align(display.LEFT_BOTTOM, 10, 10)


    -- WidgetPushButton.new(
    --     {normal = "build_item/info.png",pressed = "build_item/info.png"})
    --     :addTo(content)
    --     :align(display.LEFT_BOTTOM, 10, 10)

    -- local condition_label = cc.ui.UILabel.new({
    --     text = _("已达到最大建筑数量"),
    --     size = 20,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_LEFT,
    --     color = UIKit:hex2c3b(0x797154)
    -- }):addTo(content)
    --     :align(display.LEFT_CENTER, 175, 80)

    -- local number_label = cc.ui.UILabel.new({
    --     text = _("建筑数量").."5 / 5",
    --     size = 20,
    --     font = UIKit:getFontFilePath(),
    --     align = cc.ui.TEXT_ALIGN_LEFT,
    --     color = UIKit:hex2c3b(0x403c2f)
    -- }):addTo(content)
    --     :align(display.LEFT_CENTER, 175, 40)

    -- local build_btn = WidgetPushButton.new(
    --     {normal = "build_item/build_btn_up.png",pressed = "build_item/build_btn_down.png"}
    --     ,{}
    --     ,{
    --         disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    --     })
    --     :setButtonLabel(cc.ui.UILabel.new({
    --         UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --         text = _("建造"),
    --         size = 24,
    --         font = UIKit:getFontFilePath(),
    --         color = display.COLOR_WHITE}))
    --     :addTo(content)
    --     :pos(520, 40)




    -- function item:SetType(item_info, on_build)
    --     title_label:setString(item_info.label)
    --     build_btn:onButtonClicked(function(event)
    --         on_build(self)
    --     end)
    -- end
    -- function item:SetNumber(number, max_number)
    --     number_label:setString(_("数量")..string.format(" %d/%d", number, max_number))
    --     if number == max_number then
    --         self:SetCondition(_("已达到最大建筑数量"))
    --         self:SetBuildEnable(false)
    --     else
    --         self:SetCondition(_("满足条件"))
    --         self:SetBuildEnable(true)
    --     end
    -- end
    -- function item:SetCondition(condition, color)
    --     condition_label:setString(_(condition))
    --     condition_label:setColor(color == nil and display.COLOR_GREEN or display.COLOR_RED)
    -- end
    -- function item:SetBuildEnable(is_enable)
    --     build_btn:setButtonEnabled(is_enable)
    -- end

    return item
end



return GameUIHasBeenBuild

















