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
            NetManager:sendMsg("reset", function()
                PushService:quitAlliance(function()
                    end)
            end)
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


    -- print(Alliance_Manager:GetMyAlliance():JoinType())
    local join_btn = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = string.format("修改联盟加入类型到%s", Alliance_Manager:GetMyAlliance():JoinType() == "all" and "audit" or "all"),
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 140, window.top - 300)
        :onButtonClicked(function(event)
            if event.target:getButtonLabel():getString() == "修改联盟加入类型到all" then
                event.target:getButtonLabel():setString("修改联盟加入类型到audit")
                NetManager:editAllianceJoinType("all", NOT_HANDLE)
            else
                event.target:getButtonLabel():setString("修改联盟加入类型到all")
                NetManager:editAllianceJoinType("audit", NOT_HANDLE)
            end
        end)

    local member_id
    for _, v in pairs(Alliance_Manager:GetMyAlliance():GetJoinEventsMap()) do
        member_id = v.id
    end

    local join_btn = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "拒绝一个玩家的申请",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 320, window.top - 300)
        :onButtonClicked(function(event)
            NetManager:refuseJoinAllianceRequest(member_id, function()
                Alliance_Manager:GetMyAlliance():RemoveJoinEventWithNotifyById(member_id)
            end)
        end)
    local join_btn = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "接受一个玩家的申请",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 500, window.top - 300)
        :onButtonClicked(function(event)
            NetManager:agreeJoinAllianceRequest(member_id, NOT_HANDLE)
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















































