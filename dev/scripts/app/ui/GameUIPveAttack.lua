local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
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
    GameUIPveAttack.super.ctor(self,560,_("关卡")..pve_name,window.top - 150)
end
function GameUIPveAttack:onEnter()
    GameUIPveAttack.super.onEnter(self)

    local size = self:GetBody():getContentSize()
    UIKit:ttfLabel({
        text = _("几率掉落"),
        size = 20,
        color = 0x403c2f,
    }):addTo(self:GetBody()):align(display.CENTER, size.width/2, size.height - 40)


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
                    :pos(size.width*(skipw + (i-1) * w) / count, size.height - 120)
            ):pos(118/2, 118/2):scale(100/128)
    end

    local star = self.user:GetPveSectionStarByName(self.pve_name)
    local list,list_node = UIKit:commonListView_1({
        viewRect = cc.rect(0, 0, 550, 120),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list.touchNode_:setTouchEnabled(false)
    list_node:addTo(self:GetBody()):pos(20, size.height - 340)
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
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 370)


    local w = UIKit:ttfLabel({
        text = _("每次消耗体力:"),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 410):getContentSize().width



    UIKit:ttfLabel({
        text = string.format("-%d", sections[self.pve_name].staminaUsed),
        size = 20,
        color = 0x7e0000,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20 + w + 20,size.height - 410)

    UIKit:ttfLabel({
        text = _("关卡三星通关后，可使用扫荡"),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 450)


    self.sweep = cc.ui.UIPushButton.new(
        {normal = "blue_btn_up_148x58.png", pressed = "blue_btn_down_148x58.png", disabled = 'gray_btn_148x58.png'},
        {scale9 = false}
    ):addTo(self:GetBody())
        :align(display.LEFT_CENTER, 20,size.height - 500)
        :setButtonLabel(UIKit:ttfLabel({
            text = _("扫荡") ,
            size = 22,
            color = 0xffedae,
            shadow = true
        })):onButtonClicked(function(event)
        UIKit:newGameUI('GameUIPveSweep', self.pve_name):AddToCurrentScene(true)
        end):setButtonEnabled(star >= 3)


    cc.ui.UIPushButton.new(
        {normal = "red_btn_up_148x58.png", pressed = "red_btn_down_148x58.png"},
        {scale9 = false}
    ):addTo(self:GetBody())
        :align(display.RIGHT_CENTER, size.width - 20,size.height - 500)
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
                    self:RefreshUI()
                    display.getRunningScene():GetSceneLayer():RefreshPve()
                end)
            end):AddToCurrentScene(true)
        end)
end
function GameUIPveAttack:RefreshUI()
    local star = self.user:GetPveSectionStarByName(self.pve_name)
    for i,v in ipairs(self.list.items_) do
        v:getContent().star:setTexture(i <= star and "alliance_shire_star_60x58_1.png" or "alliance_shire_star_60x58_0.png")
    end
    self.label:setString(string.format(_("今日可挑战次数: %d/%d"), self.user:GetFightCountByName(self.pve_name), 5))
    self.sweep:setButtonEnabled(star >= 3)
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


return GameUIPveAttack












