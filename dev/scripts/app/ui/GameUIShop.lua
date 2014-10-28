--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local Alliance = import("..entity.Alliance")
local Flag = import("..entity.Flag")
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
        text = "宝石增加十万",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 320, window.top - 500)
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
        text = "重置玩家数据和联盟",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 500, window.top - 500)
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
        text = string.format("联盟类型到%s", Alliance_Manager:GetMyAlliance():JoinType() == "all" and "审核" or "直接"),
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 140, window.top - 300)
        :onButtonClicked(function(event)
            if event.target:getButtonLabel():getString() == "联盟类型到直接" then
                event.target:getButtonLabel():setString("联盟类型到审核")
                NetManager:editAllianceJoinType("all", NOT_HANDLE)
            else
                event.target:getButtonLabel():setString("联盟类型到直接")
                NetManager:editAllianceJoinType("audit", NOT_HANDLE)
            end
        end)

    local member_id
    for _, v in pairs(Alliance_Manager:GetMyAlliance():GetJoinEventsMap()) do
        if v.id ~=  DataManager:getUserData()._id then
            member_id = v.id
        end
    end
    local join_btn = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "拒绝一个申请",
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
        text = "接受一个申请",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 500, window.top - 300)
        :onButtonClicked(function(event)
            NetManager:agreeJoinAllianceRequest(member_id, NOT_HANDLE)
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "创建联盟1",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 140, window.top - 400)
        :onButtonClicked(function(event)
            PushService:createAlliance({
                name="1",
                tag="111",
                language="all",
                terrain="grassLand",
                flag=Flag:RandomFlag():EncodeToJson()
            }, NOT_HANDLE)
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "立即加入联盟1",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 320, window.top - 400)
        :onButtonClicked(function(event)
            NetManager:searchAllianceByTag("1", function(success, data)
                if success and #data.alliances > 0 then
                    PushService:joinAllianceDirectly(Alliance:DecodeFromJsonData(data.alliances[1]):Id(), NOT_HANDLE)
                end
            end)
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "请求加入联盟1",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 500, window.top - 400)
        :onButtonClicked(function(event)
            NetManager:searchAllianceByTag("1", function(success, data)
                if success and #data.alliances > 0 then
                    PushService:requestToJoinAlliance(Alliance:DecodeFromJsonData(data.alliances[1]):Id(), NOT_HANDLE)
                end
            end)
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "退出联盟 1",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 140, window.top - 500)
        :onButtonClicked(function(event)
            PushService:quitAlliance(NOT_HANDLE)
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "创建联盟2",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 140, window.top - 600)
        :onButtonClicked(function(event)
            PushService:createAlliance({
                name="2",
                tag="222",
                language="all",
                terrain="grassLand",
                flag=Flag:RandomFlag():EncodeToJson()
            }, NOT_HANDLE)
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "立即加入联盟2",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 320, window.top - 600)
        :onButtonClicked(function(event)
            NetManager:searchAllianceByTag("2", function(success, data)
                if success and #data.alliances > 0 then
                    PushService:joinAllianceDirectly(Alliance:DecodeFromJsonData(data.alliances[1]):Id(), NOT_HANDLE)
                end
            end)
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "请求加入联盟2",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 500, window.top - 600)
        :onButtonClicked(function(event)
            NetManager:searchAllianceByTag("2", function(success, data)
                if success and #data.alliances > 0 then
                    PushService:requestToJoinAlliance(Alliance:DecodeFromJsonData(data.alliances[1]):Id(), NOT_HANDLE)
                end
            end)
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "邀请2进入联盟",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 140, window.top - 700)
        :onButtonClicked(function(event)
            NetManager:inviteToJoinAlliance("W1t87MVYS", function(success, data)
                if success and data then
                    dump(data)
                end
            end)
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "获取2号玩家信息",
        size = 24,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(self)
        :align(display.CENTER, window.left + 320, window.top - 700)
        :onButtonClicked(function(event)
            NetManager:getPlayerInfo("W1t87MVYS"):next(function(data)
                dump(data)
            end):catch(function(err)
                dump(err:reason())
            end)
        end)


    --     WidgetPushButton.new(
    --     {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
    --     {scale9 = false}
    -- ):setButtonLabel(cc.ui.UILabel.new({
    --     UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
    --     text = "退出联盟",
    --     size = 24,
    --     font = UIKit:getFontFilePath(),
    --     color = UIKit:hex2c3b(0xfff3c7)}))
    --     :addTo(self)
    --     :align(display.CENTER, window.left + 320, window.top - 400)
    --     :onButtonClicked(function(event)
    --         PushService:quitAlliance(NOT_HANDLE)
    --     end)


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

























































