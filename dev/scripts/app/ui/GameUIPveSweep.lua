local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetUseItems = import("..widget.WidgetUseItems")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local GameUIPveSweep = class("GameUIPveSweep", WidgetPopDialog)
local sections = GameDatas.PvE.sections
function GameUIPveSweep:ctor(user, pve_name)
    self.user = user
    self.pve_name = pve_name
    GameUIPveSweep.super.ctor(self,700,_("扫荡")..self.pve_name,window.top - 150)
end
function GameUIPveSweep:onEnter()
    GameUIPveSweep.super.onEnter(self)
    local size = self:GetBody():getContentSize()
    local bg = display.newScale9Sprite("dividing_line.png",size.width/2,size.height - 80,cc.size(550,2),cc.rect(10,2,382,2)):addTo(self:GetBody())
    display.newSprite("sweep_128x128.png"):addTo(bg):scale(0.35):pos(35, 25)

    UIKit:ttfLabel({
        text = _("扫荡劵"),
        size = 22,
        color = 0x615b44,
    }):addTo(bg):align(display.LEFT_CENTER,70,20)

    self.sweepscroll = UIKit:ttfLabel({
        text = ItemManager:GetItemByName("sweepScroll"):Count(),
        size = 22,
        color = 0x615b44,
    }):addTo(bg):align(display.LEFT_CENTER,550 - 30,20)

    local bg = display.newScale9Sprite("dividing_line.png",size.width/2,size.height - 130,cc.size(550,2),cc.rect(10,2,382,2)):addTo(self:GetBody())
    display.newSprite("fight_62x70.png"):addTo(bg):scale(0.5):pos(35, 25)

    UIKit:ttfLabel({
        text = _("剩余次数"),
        size = 22,
        color = 0x615b44,
    }):addTo(bg):align(display.LEFT_CENTER,70,20)

    self.left_count = UIKit:ttfLabel({
        text = self.user:GetPveLeftCountByName(self.pve_name),
        size = 22,
        color = 0x615b44,
    }):addTo(bg):align(display.LEFT_CENTER,550 - 30,20)




    local list,list_node = UIKit:commonListView_1({
        viewRect = cc.rect(0, 0, 550, 400),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    -- list.touchNode_:setTouchEnabled(false)
    list_node:addTo(self:GetBody()):pos(20, size.height - 570)
    for i = 1, self.user:GetPveLeftCountByName(self.pve_name) do
        local item = list:newItem()
        local content = self:GetListItem(i)
        item:addContent(content)
        item:setItemSize(600,80)
        list:addItem(item)
    end
    list:reload()
    self.list = list


    self.sweep_all = self:CreateSweepButton(string.format("-%d", self.user:GetPveLeftCountByName(self.pve_name)))
        :addTo(self:GetBody())
        :align(display.CENTER, 100,size.height - 630)
        :onButtonClicked(function()
            if not self.user:HasAnyStength(sections[self.pve_name].staminaUsed * self.user:GetPveLeftCountByName(self.pve_name)) then
                WidgetUseItems.new():Create({
                    item_type = WidgetUseItems.USE_TYPE.STAMINA
                }):AddToCurrentScene()
                return
            end
            if ItemManager:GetItemByName("sweepScroll"):Count() >= self.user:GetPveLeftCountByName(self.pve_name) then
                self:UseSweepScroll(self.user:GetPveLeftCountByName(self.pve_name))
            else
                self:BuyAndUseSweepScroll(self.user:GetPveLeftCountByName(self.pve_name))
            end
        end)

    self.sweep_once = self:CreateSweepButton("-1")
        :addTo(self:GetBody())
        :align(display.CENTER, size.width - 100,size.height - 630)
        :onButtonClicked(function()
            if not self.user:HasAnyStength(sections[self.pve_name].staminaUsed) then
                WidgetUseItems.new():Create({
                    item_type = WidgetUseItems.USE_TYPE.STAMINA
                }):AddToCurrentScene()
                return
            end
            if ItemManager:GetItemByName("sweepScroll"):Count() >= 1 then
                self:UseSweepScroll(1)
            else
                self:BuyAndUseSweepScroll(1)
            end
        end)
end
function GameUIPveSweep:RefreshUI()
    self.sweepscroll:setString(ItemManager:GetItemByName("sweepScroll"):Count())
    self.left_count:setString(self.user:GetPveLeftCountByName(self.pve_name))
    self.sweep_all.label:setString(string.format("-%d", self.user:GetPveLeftCountByName(self.pve_name)))
    self.sweep_all:setVisible(self.user:GetPveLeftCountByName(self.pve_name) > 0)
    self.sweep_once:setVisible(self.user:GetPveLeftCountByName(self.pve_name) > 0)
end
function GameUIPveSweep:BuyAndUseSweepScroll(count)
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
                    NetManager:getBuyItemPromise("sweepScroll", need_buy):done(function()
                        self:UseSweepScroll(count)
                    end)
                end
            end,
            btn_images = {normal = "green_btn_up_148x58.png",pressed = "green_btn_down_148x58.png"},
            price = required_gems
        }
    ):CreateCancelButton()
end
function GameUIPveSweep:UseSweepScroll(count)
    NetManager:getUseItemPromise("sweepScroll", {sweepScroll = {sectionName = self.pve_name, count = count}}):done(function(response)
        for i,v in ipairs(response.msg.playerData) do
            if v[1] == "__rewards" then
                self:InsertSweepResult(v[2])
                return
            end
        end
    end):done(function()
        self:RefreshUI()
    end)
end
function GameUIPveSweep:CreateSweepButton(title)
    local s = cc.ui.UIPushButton.new(
        {normal = "yellow_btn_up_148x58.png", pressed = "yellow_btn_down_148x58.png"},
        {scale9 = false}
    ):setButtonLabel(UIKit:ttfLabel({
        text = _("扫荡") ,
        size = 20,
        color = 0xffedae,
        shadow = true
    })):setButtonLabelOffset(0, 15)

    local num_bg = display.newSprite("alliance_title_gem_bg_154x20.png"):addTo(s):align(display.CENTER, 0, -10):scale(0.8)
    local size = num_bg:getContentSize()
    display.newSprite("sweep_128x128.png"):addTo(num_bg):align(display.CENTER, 20, size.height/2):scale(0.4)
    s.label = UIKit:ttfLabel({
        text = title,
        size = 18,
        color = 0xffd200,
    }):align(display.CENTER, size.width/2, size.height/2):addTo(num_bg)
    return s
end
function GameUIPveSweep:GetListItem(index)
    local bg = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(600,80)
    -- UIKit:ttfLabel({
    --     text = string.format(_("第%d战"), index),
    --     size = 20,
    --     color = 0x403c2f,
    -- }):addTo(bg):align(display.LEFT_CENTER,50,40)

    -- local ax = bg:getContentSize().width - 50
    -- for i = 1, 3 do
    --     display.newSprite(index >= i and "alliance_shire_star_60x58_1.png" or "alliance_shire_star_60x58_0.png")
    --         :addTo(bg):pos(ax - (i-1) * 35, 20):scale(0.6)
    -- end
    return bg
end
function GameUIPveSweep:InsertSweepResult(rewards)
    local index = 1
    for ii,r in ipairs(rewards) do
        for i,v in ipairs(self.list.items_) do
            if not v.is_rewarded then
                local content = v:getContent()
                local png
                if r.type == "items" then
                    png = UILib.item[r.name]
                elseif r.type == "soldierMaterials" then
                    png = UILib.soldier_metarial[r.name]
                end
                UIKit:ttfLabel({
                    text = string.format(_("第%d战"), i),
                    size = 20,
                    color = 0x403c2f,
                }):addTo(content):align(display.LEFT_CENTER,50,40)

                local icon = display.newSprite(png):addTo(
                    display.newSprite("box_118x118.png"):addTo(content)
                        :pos(600 - 80, 40):scale(0.6)
                ):pos(118/2, 118/2):scale(100/128)

                display.newColorLayer(cc.c4b(0,0,0,128)):addTo(icon)
                    :setContentSize(128, 40)

                UIKit:ttfLabel({
                    text = "x"..r.count,
                    size = 18,
                    color = 0xffedae,
                }):addTo(content):align(display.CENTER,600 - 80, 20)

                v.is_rewarded = true
                index = i
                break
            end
        end
    end

    if 5 * 80 < #self.list.items_ * 80 then
        local x,y = self.list.scrollNode:getPosition()
        local ny = (index + 4) * 80 - #self.list.items_ * 80
        self.list.scrollNode:moveBy(0.5, 0, (ny > 0 and 0 or ny) - y)
    end
end


return GameUIPveSweep





















