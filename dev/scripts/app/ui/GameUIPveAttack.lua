local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
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
        GameUIPveAttack.super.ctor(self,480,_("关卡")..pve_name,window.top - 150)
    else
        GameUIPveAttack.super.ctor(self,570,_("关卡")..pve_name,window.top - 150)
    end
    display.newNode():addTo(self):schedule(function()
        self:RefreshUI()
    end, 1)
end
function GameUIPveAttack:onEnter()
    GameUIPveAttack.super.onEnter(self)
    if self.user:IsPveBoss(self.pve_name) then
        self:BuildBossUI()
    else
        self:BuildNormalUI()
    end
end
function GameUIPveAttack:BuildNormalUI()
    local size = self:GetBody():getContentSize()

    display.newSprite("tmp_label_line.png"):addTo(self:GetBody()):align(display.RIGHT_CENTER, size.width/2 - 85, size.height - 40):flipX(true)
    display.newSprite("tmp_label_line.png"):addTo(self:GetBody()):align(display.LEFT_CENTER, size.width/2 + 85, size.height - 40)
    UIKit:ttfLabel({
        text = _("几率掉落"),
        size = 20,
        color = 0x403c2f,
    }):addTo(self:GetBody()):align(display.CENTER, size.width/2, size.height - 40)

    WidgetUIBackGround.new({width = 568,height = 140},
        WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :addTo(self:GetBody()):pos((size.width - 568) / 2, size.height - 200)

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
                    :pos(size.width*(skipw + (i-1) * w) / count, size.height - 130)
            ):pos(118/2, 118/2):scale(100/128)
    end

    local star = self.user:GetPveSectionStarByName(self.pve_name)
    local list,list_node = UIKit:commonListView_1({
        viewRect = cc.rect(0, 0, 550, 120),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list.touchNode_:setTouchEnabled(false)
    list_node:addTo(self:GetBody()):pos(20, size.height - 350)
    for i = 1, 3 do
        local item = list:newItem()
        local content = self:GetListItem(i,titles[i], star)
        item:addContent(content)
        item:setItemSize(600,40)
        list:addItem(item)
    end
    list:reload()
    self.list = list

    self.label = UIKit:ttfLabel({
        text = string.format(_("今日可挑战次数: %d/%d"), self.user:GetFightCountByName(self.pve_name), sections[self.pve_name].maxFightCount),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 380)


    local w = UIKit:ttfLabel({
        text = _("每次消耗体力:"),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 420):getContentSize().width



    UIKit:ttfLabel({
        text = string.format("-%d", sections[self.pve_name].staminaUsed),
        size = 20,
        color = 0x7e0000,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20 + w + 20,size.height - 420)

    UIKit:ttfLabel({
        text = _("关卡三星通关后，可使用扫荡"),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 460)


    self.sweep = cc.ui.UIPushButton.new(
        {normal = "blue_btn_up_148x58.png", pressed = "blue_btn_down_148x58.png", disabled = 'gray_btn_148x58.png'},
        {scale9 = false}
    ):addTo(self:GetBody())
        :align(display.LEFT_CENTER, 20,size.height - 510)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("扫荡") ,
            size = 22,
            color = 0xffedae,
            shadow = true
        })):onButtonClicked(function(event)
        UIKit:newGameUI('GameUIPveSweep', self.user, self.pve_name):AddToCurrentScene(true)
        end):setButtonEnabled(star >= 3)

    self:CreateAttackButton():align(display.RIGHT_CENTER, size.width - 20,size.height - 510)
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

    self.button = self:CreateAttackButton():align(display.RIGHT_CENTER, size.width - 20,size.height - 420)

    self:RefreshUI()
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
        for i,v in ipairs(self.list.items_) do
            v:getContent().star:setTexture(i <= star and "alliance_shire_star_60x58_1.png" or "alliance_shire_star_60x58_0.png")
        end
        self.label:setString(string.format(_("今日可挑战次数: %d/%d"), self.user:GetFightCountByName(self.pve_name), sections[self.pve_name].maxFightCount))
        self.sweep:setButtonEnabled(star >= 3)
    end
end
function GameUIPveAttack:CreateAttackButton()
    local size = self:GetBody():getContentSize()
    return cc.ui.UIPushButton.new(
        {normal = "red_btn_up_148x58.png", pressed = "red_btn_down_148x58.png"},
        {scale9 = false}
    ):addTo(self:GetBody())
        :align(display.RIGHT_CENTER, size.width - 20,size.height - 510)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("进攻") ,
            size = 22,
            color = 0xffedae,
            shadow = true
        })):onButtonClicked(function(event)
        local soldiers = string.split(sections[self.pve_name].troops, ",")
        table.remove(soldiers, 1)
        UIKit:newGameUI('GameUIPVESendTroop',
            LuaUtils:table_map(soldiers, function(k,v)
                local name,star = unpack(string.split(v, "_"))
                return k, {name = name, star = tonumber(star)}
            end),
            function(dragonType, soldiers)
                NetManager:getAttackPveSectionPromise(self.pve_name, dragonType, soldiers):done(function()
                    display.getRunningScene():GetSceneLayer():RefreshPve()
                end):done(function(response)
                    local dragon = City:GetFirstBuildingByType("dragonEyrie"):GetDragonManager():GetDragon(dragonType)
                    UIKit:newGameUI("GameUIReplayNew", self:DecodeReport(response.msg.fightReport, dragon, soldiers), function()
                        if response.reward_func then
                            response.reward_func()
                        end
                        self:performWithDelay(function()
                            self:LeftButtonClicked()
                        end, 0)
                    end):AddToCurrentScene(true)
                end)
            end):AddToCurrentScene(true)
        end)
end
function GameUIPveAttack:GetListItem(index,title, star)
    local bg = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(600,40)
    UIKit:ttfLabel({
        text = title,
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(bg):align(display.LEFT_CENTER,30,20)

    bg.star = display.newSprite(index <= star and "alliance_shire_star_60x58_1.png" or "alliance_shire_star_60x58_0.png")
        :addTo(bg):pos(bg:getContentSize().width - 50, 20):scale(0.6)
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


















