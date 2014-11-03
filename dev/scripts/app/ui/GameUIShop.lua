--
-- Author: gaozhou
-- Date: 2014-08-18 14:33:28
--
local cocos_promise = import("..utils.cocos_promise")
local Alliance = import("..entity.Alliance")
local Flag = import("..entity.Flag")
local WidgetPushButton = import("..widget.WidgetPushButton")
local promise = import("..utils.promise")
local window = import("..utils.window")
local GameUIShop = UIKit:createUIClass("GameUIShop", "GameUIWithCommonHeader")
function GameUIShop:ctor(city)
    GameUIShop.super.ctor(self, city, _("商城"))
    self.shop_city = city
end
function GameUIShop:onEnter()
    GameUIShop.super.onEnter(self)

    local list_view = self:CreateVerticalListView(window.left + 20, window.bottom + 70, window.right - 20, window.top - 100)
    local item = list_view:newItem()
    local content = display.newNode()
    content:setContentSize(cc.size(640, 0))
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
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 500)
        :onButtonClicked(function()
            local current = self.shop_city:GetResourceManager():GetGemResource():GetValue() + add_gem
            -- NetManager:sendMsg("gem "..current, NOT_HANDLE)
            cocos_promise.promiseWithCatchError(NetManager:getSendGlobalMsgPromise("gem "..current))
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
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 500)
        :onButtonClicked(function()
            cocos_promise.promiseWithCatchError(NetManager:getSendGlobalMsgPromise("reset"):next(function()
                return NetManager:getQuitAlliancePromise()
            end))
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "草地",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
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
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
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
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
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
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 300)
        :onButtonClicked(function(event)
            if event.target:getButtonLabel():getString() == "联盟类型到直接" then
                event.target:getButtonLabel():setString("联盟类型到审核")
                -- NetManager:editAllianceJoinType("all", NOT_HANDLE)
                cocos_promise.promiseWithCatchError(NetManager:getEditAllianceJoinTypePromise("all")):done(function(result)
                    dump(result)
                end)
            else
                event.target:getButtonLabel():setString("联盟类型到直接")
                -- NetManager:editAllianceJoinType("audit", NOT_HANDLE)
                cocos_promise.promiseWithCatchError(NetManager:getEditAllianceJoinTypePromise("audit")
                    ):done(function(result)
                    dump(result)
                end)
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
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 300)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getRefuseJoinAllianceRequestPromise(member_id)):done(function(result)
                dump(result)
            end)
        end)
    local join_btn = WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "接受一个申请",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 300)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getAgreeJoinAllianceRequestPromise(member_id)):done(function(result)
                dump(result)
            end)
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "创建联盟1",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 400)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getCreateAlliancePromise("1", "111", "all", "grassLand", Flag:RandomFlag():EncodeToJson())
                :done(function(result)
                    dump(result)
                end))
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "立即加入联盟1",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 400)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getFetchCanDirectJoinAlliancesPromise("1"):next(function(result)
                dump(result)
                -- return NetManager:getJoinAllianceDirectlyPromise(Alliance:DecodeFromJsonData(result.alliances[1]):Id())
            end))
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "请求加入联盟1",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 400)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getSearchAllianceByTagPromsie("1"):next(function(result)
                return NetManager:getRequestToJoinAlliancePromise(Alliance:DecodeFromJsonData(result.alliances[1]):Id())
            end))
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "退出联盟 1",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 500)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getQuitAlliancePromise())
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "创建联盟2",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 600)
        :onButtonClicked(function(event)
            -- PushService:createAlliance({
            --     name="2",
            --     tag="222",
            --     language="all",
            --     terrain="grassLand",
            --     flag=Flag:RandomFlag():EncodeToJson()
            -- }, NOT_HANDLE)
            cocos_promise.promiseWithCatchError(NetManager:getCreateAlliancePromise("2", "222", "all", "grassLand", Flag:RandomFlag():EncodeToJson()))
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "立即加入联盟2",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 600)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getSearchAllianceByTagPromsie("2"):next(function(result)
                return NetManager:getRequestToJoinAlliancePromise(Alliance:DecodeFromJsonData(result.alliances[1]):Id())
            end))
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "请求加入联盟2",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 600)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getSearchAllianceByTagPromsie("2"):next(function(result)
                return NetManager:getRequestToJoinAlliancePromise(Alliance:DecodeFromJsonData(result.alliances[1]):Id())
            end))
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "邀请2进入联盟",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 700)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getInviteToJoinAlliancePromise("Zk9ErNdsH"):next(function(result)
                dump(result)
            end))
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "获取2号玩家信息",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 700)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getPlayerInfoPromise("Zk9ErNdsH")
                :next(function(data)
                    dump(data)
                end))
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "随机踢出一个成员",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 700)
        :onButtonClicked(function(event)
            local memberid
            Alliance_Manager:GetMyAlliance():IteratorAllMembers(function(_, v)
                if v:Id() ~= User:Id() then
                    memberid = v:Id()
                    return true
                end
            end)
            cocos_promise.promiseWithCatchError(NetManager:getKickAllianceMemberOffPromise(memberid)
                :next(function(data)
                    dump(data)
                end))
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "随机提升一个成员",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 800)
        :onButtonClicked(function(event)
            local member
            Alliance_Manager:GetMyAlliance():IteratorAllMembers(function(_, v)
                if v:Id() ~= User:Id() then
                    member = v
                    return true
                end
            end)
            if not member:IsTitleHighest() then
                cocos_promise.promiseWithCatchError(NetManager:getEditAllianceMemberTitlePromise(member:Id(), member:TitleUpgrade())
                    :next(function(data)
                        dump(data)
                    end))
            end
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "随机降级一个成员",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 800)
        :onButtonClicked(function(event)
            local member
            Alliance_Manager:GetMyAlliance():IteratorAllMembers(function(_, v)
                if v:Id() ~= User:Id() then
                    member = v
                    return true
                end
            end)
            if not member:IsTitleLowest() then
                cocos_promise.promiseWithCatchError(NetManager:getEditAllianceMemberTitlePromise(member:Id(), member:TitleDegrade())
                    :next(function(data)
                        dump(data)
                    end))
            end
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "移交萌主到随机成员",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 800)
        :onButtonClicked(function(event)
            local member
            Alliance_Manager:GetMyAlliance():IteratorAllMembers(function(_, v)
                if v:Id() ~= User:Id() then
                    member = v
                    return true
                end
            end)
            if Alliance_Manager:GetMyAlliance():GetMemeberById(User:Id()):IsArchon() then
                cocos_promise.promiseWithCatchError(NetManager:getHandOverArchonPromise(member:Id())
                    :next(function(data)
                        dump(data)
                    end))
            end
        end)



    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "发布一个随机公告",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 900)
        :onButtonClicked(function(event)
            math.randomseed(os.time())
            cocos_promise.promiseWithCatchError(NetManager:getEditAllianceNoticePromise("随机数公告: "..math.random(123456789)))
                
        end)

    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "发布一个随机描述",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 900)
        :onButtonClicked(function(event)
            math.randomseed(os.time())
            cocos_promise.promiseWithCatchError(NetManager:getEditAllianceDescriptionPromise("随机描述: "..math.random(123456789)))
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "随机修改萌主名字",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 900)
        :onButtonClicked(function(event)
            math.randomseed(os.time())
            cocos_promise.promiseWithCatchError(NetManager:getEditTitleNamePromise("archon", "萌主"..math.random(10)))
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "同意加入联盟",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 140, window.top - 1000)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getAgreeJoinAllianceInvitePromise(User:GetInviteEvents()[1].id):next(function(ee)
                dump(ee)
            end))
        end)


    WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "撤销加入联盟",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 320, window.top - 1000)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getCancelJoinAlliancePromise(
                User:GetRequestEvents()[1].id
            ):next(function(ee)
                dump(ee)
            end))
        end)

        WidgetPushButton.new(
        {normal = "green_btn_up.png", pressed = "green_btn_down.png"},
        {scale9 = false}
    ):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = "拒绝一个邀请",
        size = 20,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xfff3c7)}))
        :addTo(content)
        :align(display.CENTER, window.left + 500, window.top - 1000)
        :onButtonClicked(function(event)
            cocos_promise.promiseWithCatchError(NetManager:getDisagreeJoinAllianceInvitePromise(
                User:GetInviteEvents()[1].id
            ))
        end)




    item:addContent(content)
    item:setItemSize(640, 1000)
    list_view:addItem(item)
    list_view:reload():resetPosition()
end
function GameUIShop:onExit()
    GameUIShop.super.onExit(self)
end


return GameUIShop



