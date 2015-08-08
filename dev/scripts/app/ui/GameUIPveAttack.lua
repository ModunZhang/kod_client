local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetUseItems = import("..widget.WidgetUseItems")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIPveAttack = class("GameUIPveAttack", WidgetPopDialog)
local sections = GameDatas.PvE.sections
local titles = {
    _("战斗胜利"),
    _("龙在战斗中胜利"),
    _("一个兵种击败敌军"),
}


function GameUIPveAttack:ctor(user, pve_name)
    self.user = user
    self.pve_name = pve_name
    if self.user:IsPveBoss(self.pve_name) then
        GameUIPveAttack.super.ctor(self,480,_("关卡")..pve_name,window.top - 160,nil,{color = UIKit:hex2c4b(0x00000000)})
    else
        GameUIPveAttack.super.ctor(self,680,_("关卡")..pve_name,window.top - 160,nil,{color = UIKit:hex2c4b(0x00000000)})
    end
    self.__type  = UIKit.UITYPE.BACKGROUND
    display.newNode():addTo(self):schedule(function()
        self:RefreshUI()
    end, 1)
end
function GameUIPveAttack:OnMoveInStage()
    if self.user:IsPveBoss(self.pve_name) then
        self:BuildBossUI()
    else
        self:BuildNormalUI()
    end
    self:RefreshUI()
    GameUIPveAttack.super.OnMoveInStage(self)
end
function GameUIPveAttack:BuildNormalUI()
    local size = self:GetBody():getContentSize()
    self.items = {}
    local sbg = display.newSprite("tmp_pve_bg.png"):addTo(self:GetBody()):pos(size.width/2, size.height - 55)
    display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2 - 60, 35):scale(0.8)
    self.items[1] = display.newSprite("tmp_pve_star.png"):addTo(sbg):pos(size.width/2 - 60, 35):scale(0.8)

    display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2, 35)
    self.items[2] = display.newSprite("tmp_pve_star.png"):addTo(sbg):pos(size.width/2, 35)

    display.newSprite("tmp_pve_star_bg.png"):addTo(sbg):pos(size.width/2 + 60, 35):scale(0.8)
    self.items[3] = display.newSprite("tmp_pve_star.png"):addTo(sbg):pos(size.width/2 + 60, 35):scale(0.8)


    local star = self.user:GetPveSectionStarByName(self.pve_name)
    local list,list_node = UIKit:commonListView_1({
        viewRect = cc.rect(0, 0, 550, 120),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list.touchNode_:setTouchEnabled(false)
    list_node:addTo(self:GetBody()):pos(20, size.height - 245)
    for i = 1, 3 do
        local item = list:newItem()
        local content = self:GetListItem(i,titles[i])
        item:addContent(content)
        item:setItemSize(600,40)
        list:addItem(item)
    end
    list:reload()
    self.list = list


    display.newSprite("tmp_label_line.png"):addTo(self:GetBody()):align(display.RIGHT_CENTER, size.width/2 - 85, size.height - 270):flipX(true)
    display.newSprite("tmp_label_line.png"):addTo(self:GetBody()):align(display.LEFT_CENTER, size.width/2 + 85, size.height - 270)
    UIKit:ttfLabel({
        text = _("几率掉落"),
        size = 20,
        color = 0x403c2f,
    }):addTo(self:GetBody()):align(display.CENTER, size.width/2, size.height - 270)

    WidgetUIBackGround.new({width = 568,height = 140},
        WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :addTo(self:GetBody()):pos((size.width - 568) / 2, size.height - 430)

    local rewards = LuaUtils:table_map(string.split(sections[self.pve_name].rewards, ","), function(k,v)
        local type,name = unpack(string.split(v, ":"))
        return k, {type = type, name = name}
    end)
    local skipw = 1.5
    local count = 10
    local w = (count - skipw * 2) / (#rewards - 1)
    for i,v in ipairs(rewards) do
        local png
        if v.type == "items" then
            png = UILib.item[v.name]
        elseif v.type == "soldierMaterials" then
            png = UILib.soldier_metarial[v.name]
        end
        display.newSprite(png)
            :addTo(
                display.newSprite("box_118x118.png"):addTo(self:GetBody())
                    :pos(size.width*(skipw + (i-1) * w) / count, size.height - 360)
            ):pos(118/2, 118/2):scale(100/128)
    end


    self.label = UIKit:ttfLabel({
        text = string.format(_("今日可挑战次数: %d/%d"), self.user:GetFightCountByName(self.pve_name), sections[self.pve_name].maxFightCount),
        size = 22,
        color = 0x615b44,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,25,size.height - 450)


    display.newSprite("dragon_lv_icon.png"):addTo(self:GetBody()):align(display.CENTER,40,size.height - 485):scale(0.8)

    self.str_label = UIKit:ttfLabel({
        text = string.format(_("体力 : %d/%d"), self.user:GetStrengthResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()), self.user:GetStrengthResource():GetValueLimit()),
        size = 22,
        color = 0x615b44,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,70,size.height - 485)
    local w = self.str_label:getContentSize().width

    UIKit:ttfLabel({
        text = string.format("-%d", sections[self.pve_name].staminaUsed),
        size = 20,
        color = 0x7e0000,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,70 + w + 20,size.height - 485)


    display.newSprite("sweep_128x128.png"):addTo(self:GetBody()):align(display.CENTER,40,size.height - 520):scale(0.25)
    local label = UIKit:ttfLabel({
        text = _("扫荡劵 : "),
        size = 22,
        color = 0x615b44,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,70,size.height - 520)

    self.sweep_label = UIKit:ttfLabel({
        text = ItemManager:GetItemByName("sweepScroll"):Count(),
        size = 22,
        color = ItemManager:GetItemByName("sweepScroll"):Count() > 0 and 0x615b44 or 0x7e00000,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,70 + label:getContentSize().width,size.height - 520)


    self.sweep_all = self:CreateSweepButton():setButtonLabelString(_("扫荡全部"))
        :align(display.CENTER, 100, size.height - 580):addTo(self:GetBody())
        :onButtonClicked(function()
            if self.user:GetPveLeftCountByName(self.pve_name) <= 0 then
                UIKit:showMessageDialog(_("提示"),_("已达今日最大挑战次数!"))
                return
            end
            if not self.user:HasAnyStength(sections[self.pve_name].staminaUsed * self.user:GetPveLeftCountByName(self.pve_name)) then
                WidgetUseItems.new():Create({
                    item_type = WidgetUseItems.USE_TYPE.STAMINA
                }):AddToCurrentScene()
                return
            end
            local use_str = self.user:GetPveLeftCountByName(self.pve_name) * sections[self.pve_name].staminaUsed
            if ItemManager:GetItemByName("sweepScroll"):Count() >= self.user:GetPveLeftCountByName(self.pve_name) then
                self:UseStrength(function()end,use_str):addTo(self.sweep_all)
                self:UseSweepScroll(self.user:GetPveLeftCountByName(self.pve_name))
            else
                self:UseStrength(function()end,use_str):addTo(self.sweep_all)
                self:BuyAndUseSweepScroll(self.user:GetPveLeftCountByName(self.pve_name))
            end
        end)

    self.sweep_once = self:CreateSweepButton():setButtonLabelString(_("扫荡一次"))
        :align(display.CENTER, size.width/2, size.height - 580):addTo(self:GetBody())
        :onButtonClicked(function(event)
            if self.user:GetPveLeftCountByName(self.pve_name) <= 0 then
                UIKit:showMessageDialog(_("提示"),_("已达今日最大挑战次数!"))
                return
            end
            if not self.user:HasAnyStength(sections[self.pve_name].staminaUsed) then
                WidgetUseItems.new():Create({
                    item_type = WidgetUseItems.USE_TYPE.STAMINA
                }):AddToCurrentScene()
                return
            end
            if ItemManager:GetItemByName("sweepScroll"):Count() >= 1 then
                self:UseStrength(function()end,sections[self.pve_name].staminaUsed):addTo(self.sweep_once)
                self:UseSweepScroll(1)
            else
                self:UseStrength(function()end,sections[self.pve_name].staminaUsed):addTo(self.sweep_once)
                self:BuyAndUseSweepScroll(1)
            end
        end)
    self.attack = self:CreateAttackButton():align(display.CENTER, size.width - 100,size.height - 580)
    UIKit:ttfLabel({
        text = _("关卡三星通关后，可使用扫荡"),
        size = 18,
        color = 0x615b44,
    }):addTo(self:GetBody()):align(display.CENTER,size.width/2,size.height - 640)
end
function GameUIPveAttack:BuildBossUI()
    local size = self:GetBody():getContentSize()
    local w,h = size.width, size.height
    display.newSprite("alliance_item_flag_box_126X126.png")
        :align(display.CENTER, 95, h - 110)
        :scale(136/126):addTo(self:GetBody())

    display.newSprite("alliance_moonGate.png")
        :addTo(self:GetBody()):pos(95, h - 110):scale(0.8)

    UIKit:ttfLabel({
        text = _("你能感觉到一个一场强大的生物驻守在这里, 阻挡着你继续前进, 但想要前往下一关卡必须击败它。"),
        size = 18,
        color = 0x615b44,
        dimensions = cc.size(350,0)
    }):align(display.LEFT_TOP, 180, h - 40):addTo(self:GetBody())


    display.newSprite("tmp_label_line.png"):addTo(self:GetBody()):align(display.RIGHT_CENTER, size.width/2 - 85, size.height - 200):flipX(true)
    display.newSprite("tmp_label_line.png"):addTo(self:GetBody()):align(display.LEFT_CENTER, size.width/2 + 85, size.height - 200)
    UIKit:ttfLabel({
        text = _("几率掉落"),
        size = 20,
        color = 0x403c2f,
    }):addTo(self:GetBody()):align(display.CENTER, size.width/2, size.height - 200)


    WidgetUIBackGround.new({width = 568,height = 140},
        WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :addTo(self:GetBody()):pos((size.width - 568) / 2, size.height - 370)

    local rewards = LuaUtils:table_map(string.split(sections[self.pve_name].rewards, ","), function(k,v)
        local type,name = unpack(string.split(v, ":"))
        return k, {type = type, name = name}
    end)
    local skipw = 1.5
    local count = 10
    local w = (count - skipw * 2) / (#rewards - 1)
    for i,v in ipairs(rewards) do
        local png
        if v.type == "items" then
            png = UILib.item[v.name]
        elseif v.type == "soldierMaterials" then
            png = UILib.soldier_metarial[v.name]
        end
        display.newSprite(png)
            :addTo(
                display.newSprite("box_118x118.png"):addTo(self:GetBody())
                    :pos(size.width*(skipw + (i-1) * w) / count, size.height - 300)
            ):pos(118/2, 118/2):scale(100/128)
    end



    self.tp = cc.ui.UIPushButton.new(
        {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"},
        {scale9 = false}
    ):addTo(self:GetBody())
        :align(display.CENTER, size.width/2,size.height - 420)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("传送") ,
            size = 22,
            color = 0xffedae,
            shadow = true
        })):onButtonClicked(function(event)
        app:EnterPVEScene(self.user:GetNextStageByPveName(self.pve_name))
        end)



    self.txt1 = UIKit:ttfLabel({
        text = _("每次消耗体力:"),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 420)


    self.txt2 = UIKit:ttfLabel({
        text = string.format("-%d", sections[self.pve_name].staminaUsed),
        size = 20,
        color = 0x7e0000,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20 + self.txt1:getContentSize().width + 20,size.height - 420)

    self.button = self:CreateAttackButton():align(display.CENTER, size.width - 100,size.height - 420)
end
local hide = function(obj)
    if obj then obj:hide() end
end
local show = function(obj)
    if obj then obj:show() end
end
function GameUIPveAttack:RefreshUI()
    if self.user:IsPveBoss(self.pve_name) then
        if self.user:IsPveBossPassed(self.pve_name) and
            self.user:HasNextStageByPveName(self.pve_name) then
            show(self.tp)
            hide(self.txt1)
            hide(self.txt2)
            hide(self.button)
        else
            hide(self.tp)
            show(self.txt1)
            show(self.txt2)
            show(self.button)
        end
    else
        local star = self.user:GetPveSectionStarByName(self.pve_name)
        for i,v in ipairs(self.items) do
            v:setVisible(i <= star)
        end
        self.str_label:setString(string.format(_("体力 : %d/%d"), self.user:GetStrengthResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()), self.user:GetStrengthResource():GetValueLimit()))
        self.sweep_label:setColor(UIKit:hex2c4b(ItemManager:GetItemByName("sweepScroll"):Count() > 0 and 0x615b44 or 0x7e00000))
        self.sweep_label:setString(ItemManager:GetItemByName("sweepScroll"):Count())
        self.label:setString(string.format(_("今日可挑战次数: %d/%d"), self.user:GetFightCountByName(self.pve_name), sections[self.pve_name].maxFightCount))
        self.sweep_all:setButtonEnabled(star >= 3)
        self.sweep_all.label:setColor(UIKit:hex2c4b(ItemManager:GetItemByName("sweepScroll"):Count() >= self.user:GetPveLeftCountByName(self.pve_name) and 0xffedae or 0x7e00000))
        self.sweep_all.label:setString(string.format("-%d", self.user:GetPveLeftCountByName(self.pve_name)))
        self.sweep_once.label:setColor(UIKit:hex2c4b(ItemManager:GetItemByName("sweepScroll"):Count() >= 1 and 0xffedae or 0x7e00000))
        self.sweep_once:setButtonEnabled(star >= 3)
    end
end
function GameUIPveAttack:CreateSweepButton()
    local s = cc.ui.UIPushButton.new(
        {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png", disabled = "gray_btn_148x58.png"},
        {scale9 = false}
    ):setButtonLabel(UIKit:ttfLabel({
        size = 20,
        color = 0xffedae,
        shadow = true
    })):setButtonLabelOffset(0, 15)
    local num_bg = display.newSprite("alliance_title_gem_bg_154x20.png"):addTo(s):align(display.CENTER, 0, -10):scale(0.8)
    local size = num_bg:getContentSize()
    display.newSprite("sweep_128x128.png"):addTo(num_bg):align(display.CENTER, 20, size.height/2):scale(0.4)
    s.label = UIKit:ttfLabel({
        text = "-1",
        size = 20,
        color = 0xff0000,
    }):align(display.CENTER, size.width/2, size.height/2):addTo(num_bg)
    return s
end
function GameUIPveAttack:CreateAttackButton()
    local size = self:GetBody():getContentSize()
    return cc.ui.UIPushButton.new(
        {
            normal = "red_btn_up_148x58.png",
            pressed = "red_btn_down_148x58.png",
            disabled = 'gray_btn_148x58.png'
        },
        {scale9 = false}
    ):addTo(self:GetBody())
        :align(display.RIGHT_CENTER, size.width - 20,size.height - 510)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("进攻") ,
            size = 22,
            color = 0xffedae,
            shadow = true
        })):onButtonClicked(function(event)
        if self.user:GetPveLeftCountByName(self.pve_name) <= 0 then
            UIKit:showMessageDialog(_("提示"),_("已达今日最大挑战次数!"))
            return
        end
        if not self.user:HasAnyStength(sections[self.pve_name].staminaUsed) then
            WidgetUseItems.new():Create({
                item_type = WidgetUseItems.USE_TYPE.STAMINA
            }):AddToCurrentScene()
            return
        end
        event.target:setTouchEnabled(false)
        self:UseStrength(function()
            self:Attack()
            event.target:setTouchEnabled(true)
        end, sections[self.pve_name].staminaUsed):addTo(event.target)
        end)
end
function GameUIPveAttack:Attack()
    local soldiers = string.split(sections[self.pve_name].troops, ",")
    table.remove(soldiers, 1)
    UIKit:newGameUI('GameUIPVESendTroop',
        LuaUtils:table_map(soldiers, function(k,v)
            local name,star = unpack(string.split(v, "_"))
            return k, {name = name, star = tonumber(star)}
        end),
        function(dragonType, soldiers)
            local dragon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
            local param = {
                dragonType = dragon:Type(),
                old_exp = dragon:Exp(),
                new_exp = dragon:Exp(),
                old_level = dragon:Level(),
                new_level = dragon:Level(),
                reward = {},
            }
            NetManager:getAttackPveSectionPromise(self.pve_name, dragonType, soldiers):done(function()
                display.getRunningScene():GetSceneLayer():RefreshPve()
            end):done(function(response)
                local star = 0
                if response.msg.fightReport.playerSoldierRoundDatas[#response.msg.fightReport.playerSoldierRoundDatas].isWin then
                    star = 2
                    if response.msg.fightReport.playerDragonFightData.isWin then
                        star = star + 1
                    end
                    local soldiername
                    for i,v in ipairs(response.msg.fightReport.playerSoldierRoundDatas) do
                        if not soldiername then
                            soldiername = v.soldierName
                        elseif soldiername ~= v.soldierName then
                            star = star - 1
                            break
                        end
                    end
                end
                

                local dragon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
                param.new_exp = dragon:Exp()
                param.new_level = dragon:Level()
                param.star = star
                if response.get_func then
                    param.reward = response.get_func()
                end
                local is_show = false
                UIKit:newGameUI("GameUIReplayNew", self:DecodeReport(response.msg.fightReport, dragon, soldiers), function(replayui)
                    if not is_show then
                        is_show = true
                        UIKit:newGameUI("GameUIPveSummary", param):AddToCurrentScene(true)
                        self:performWithDelay(function()
                            self:LeftButtonClicked()
                            display.getRunningScene():GetSceneLayer():MoveAirship(true)
                        end, 0)
                    end
                end, function(replayui)
                    replayui:LeftButtonClicked()
                    if not is_show then
                        is_show = true
                        UIKit:newGameUI("GameUIPveSummary", param):AddToCurrentScene(true)
                        self:performWithDelay(function()
                            self:LeftButtonClicked()
                            display.getRunningScene():GetSceneLayer():MoveAirship(true)
                        end, 0)
                    end
                end):AddToCurrentScene(true)
            end)
        end):AddToCurrentScene(true)
end
function GameUIPveAttack:BuyAndUseSweepScroll(count)
    local need_buy = count - ItemManager:GetItemByName("sweepScroll"):Count()
    assert(need_buy > 0)
    local required_gems = ItemManager:GetItemByName("sweepScroll"):Price() * need_buy
    local dialog = UIKit:showMessageDialog()
    dialog:SetTitle(_("补充道具"))
    dialog:SetPopMessage(_("您当前没有足够的扫荡劵,是否花费金龙币购买补充并使用"))
    dialog:CreateOKButtonWithPrice(
        {
            listener = function()
                if self.user:GetGemResource():GetValue() < required_gems then
                    UIKit:showMessageDialog(_("提示"),_("金龙币不足")):CreateOKButton(
                        {
                            listener = function ()
                                UIKit:newGameUI("GameUIStore"):AddToCurrentScene(true)
                            end,
                            btn_name= _("前往商店")
                        })
                else
                    NetManager:getBuyItemPromise("sweepScroll", need_buy, false):done(function()
                        self:UseSweepScroll(count)
                    end)
                end
            end,
            btn_images = {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"},
            price = required_gems
        }
    ):CreateCancelButton()
end
function GameUIPveAttack:UseSweepScroll(count)
    NetManager:getUseItemPromise("sweepScroll", {sweepScroll = {sectionName = self.pve_name, count = count}}):done(function(response)
        for i,v in ipairs(response.msg.playerData) do
            if v[1] == "__rewards" then
                UIKit:newGameUI("GameUIPveSweep", v[2]):AddToCurrentScene(true)
                return
            end
        end
    end):always(function()
        self:RefreshUI()
    end)
end
function GameUIPveAttack:UseStrength(func, num)
    local icon = display.newSprite("dragon_lv_icon.png")
    icon:runAction(transition.sequence{
        cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0, 100)), cc.FadeOut:create(1)),
        cc.CallFunc:create(func),
        cc.RemoveSelf:create(),
    })
    UIKit:ttfLabel({
        text = string.format("-%d", num),
        size = 22,
        color = 0x7e0000,
    }):addTo(icon):align(display.LEFT_CENTER,40,30)
    return icon
end


function GameUIPveAttack:GetListItem(index,title)
    local bg = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(600,40)
    UIKit:ttfLabel({
        text = title,
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(bg):align(display.LEFT_CENTER,90,20)

    bg.star = display.newSprite("tmp_pve_star.png"):addTo(bg):pos(55, 20):scale(0.5)
    return bg
end
function GameUIPveAttack:DecodeReport(report, dragon, attack_soldiers)
    local user = self.user
    local pve_name = self.pve_name
    local troops = string.split(sections[pve_name].troops, ",")
    local _,_,level = unpack(string.split(troops[1], "_"))
    table.remove(troops, 1)
    local defence_soldiers = LuaUtils:table_map(troops, function(k,v)
        local name,star,count = unpack(string.split(v, "_"))
        return k, {name = name, star = tonumber(star), count = count}
    end)
    function report:GetFightAttackName()
        return user:Name()
    end
    function report:GetFightDefenceName()
        return pve_name
    end
    function report:IsDragonFight()
        return true
    end
    function report:GetFightAttackDragonRoundData()
        return self.playerDragonFightData
    end
    function report:GetFightDefenceDragonRoundData()
        return self.sectionDragonFightData
    end
    function report:GetFightAttackSoldierRoundData()
        return self.playerSoldierRoundDatas
    end
    function report:GetFightDefenceSoldierRoundData()
        return self.sectionSoldierRoundDatas
    end
    function report:IsFightWall()
        return false
    end
    function report:GetOrderedAttackSoldiers()
        return attack_soldiers
    end
    function report:GetOrderedDefenceSoldiers()
        return defence_soldiers
    end
    function report:GetReportResult()
        return self.playerSoldierRoundDatas[#self.playerSoldierRoundDatas].isWin
    end
    function report:GetAttackDragonLevel()
        return dragon:Level()
    end
    function report:GetDefenceDragonLevel()
        return level
    end
    function report:GetAttackTargetTerrain()
        return sections[pve_name].terrain
    end
    function report:IsAttackCamp()
        return true
    end
    return report
end

return GameUIPveAttack






























