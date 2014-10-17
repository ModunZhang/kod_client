--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local WidgetPushButton = import("..widget.WidgetPushButton")
local window = import("..utils.window")
local GameUIShop = UIKit:createUIClass("GameUIShop", "GameUIWithCommonHeader")
function GameUIShop:ctor(city)
    GameUIShop.super.ctor(self, city, _("商城"))
    self.shop_city = city
end
function GameUIShop:onEnter()
    GameUIShop.super.onEnter(self)

    local add_gem = 100000
    local button = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"}
        ,{scale9 = false}
    -- ,{
    --     disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
    -- }
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "gem add "..add_gem,
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.cx, window.cy)
        :onButtonClicked(function()
            local current = self.shop_city:GetResourceManager():GetGemResource():GetValue() + add_gem
            NetManager:sendMsg("gem "..current, NOT_HANDLE)
        end)
    -- :setButtonEnabled(false)
    -- :SetFilter({
    --     disabled = nil
    -- })

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "reset",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.cx, window.cy - 200)
        :onButtonClicked(function()
            NetManager:sendMsg("reset", NOT_HANDLE)
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "草地",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 140, window.top - 200)
        :onButtonClicked(function()
            if display.getRunningScene().__cname == "CityScene" then
                display.getRunningScene():ChangeTerrain("grass")
            end
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "雪地",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 320, window.top - 200)
        :onButtonClicked(function()
            if display.getRunningScene().__cname == "CityScene" then
                display.getRunningScene():ChangeTerrain("icefield")
            end
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "沙地",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 500, window.top - 200)
        :onButtonClicked(function()
            if display.getRunningScene().__cname == "CityScene" then
                display.getRunningScene():ChangeTerrain("desert")
            end
        end)


    -- local node = display.newFilteredSprite("green_btn_up.png", "GRAY", {0.2, 0.3, 0.5, 0.1})
    --     :align(display.CENTER, window.cx, window.cy)
    --     :addTo(self)
    --     node:clearFilter()
    --     node:setFilter(filter.newFilter("GRAY", {0.2, 0.3, 0.5, 0.1}))
end
function GameUIShop:onExit()
    GameUIShop.super.onExit(self)
end


return GameUIShop













































