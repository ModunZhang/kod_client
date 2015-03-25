local cocos_promise = import("..utils.cocos_promise")
local window = import("..utils.window")
local Flag = import("..entity.Flag")
local UIListView = import("..ui.UIListView")
local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetAllianceUIHelper = import(".WidgetAllianceUIHelper")
local WidgetDropList = import("..widget.WidgetDropList")
local WidgetRankingList = class("WidgetRankingList", WidgetPopDialog)

local ui_helper = WidgetAllianceUIHelper.new()


function WidgetRankingList:ctor(type_)
    self.type_ = type_
    local str = type_ == "player" and _("个人排行榜") or _("联盟排行榜")
    WidgetRankingList.super.ctor(self, 762, str, display.cy + 350)
end
function WidgetRankingList:onEnter()
    WidgetRankingList.super.onEnter(self)

    local body = self:GetBody()
    local size = body:getContentSize()

    local bg = display.newSprite("background_548x52.png"):addTo(body)
        :align(display.TOP_CENTER, size.width / 2, size.height - 110)

    self.my_ranking = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, bg:getContentSize().width/2, bg:getContentSize().height/2)
        :addTo(bg)


    display.newSprite("background_568x556.png"):addTo(body):align(display.CENTER, size.width / 2, size.height / 2 - 80)

    self.listview = UIListView.new{
        async = true, --异步加载
        -- bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(30, 35, size.width - 60, size.height - 230),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    }:onTouch(handler(self, self.touchListener)):addTo(body)

    self.listview:setRedundancyViewVal(self.listview:getViewRect().height + 76 * 2)
    self.listview:setDelegate(handler(self, self.sourceDelegate))

    self.rank_map = {}
    WidgetDropList.new(
        {
            {tag = "power",label = _("战斗力排行榜"),default = true},
            {tag = "kill",label = _("击杀排行榜")},
        },
        function(tag)
            if tag == 'power' then
                if not self.rank_map.power then
                    if self.type_ == "player" then
                        NetManager:getPlayerRankPromise("power"):next(function(response)
                            self.rank_map.power = response.msg
                            self:ReloadRank(self.rank_map.power)
                        end)
                    else
                        NetManager:getAllianceRankPromise("power"):next(function(response)
                            self.rank_map.power = response.msg
                            self:ReloadRank(self.rank_map.power)
                        end)
                    end
                else
                    self:ReloadRank(self.rank_map.power)
                end
            elseif tag == 'kill' then
                if not self.rank_map.kill then
                    if self.type_ == "player" then
                        NetManager:getPlayerRankPromise("kill"):next(function(response)
                            self.rank_map.power = response.msg
                            self:ReloadRank(self.rank_map.power)
                        end)
                    else
                        NetManager:getAllianceRankPromise("kill"):next(function(response)
                            self.rank_map.power = response.msg
                            self:ReloadRank(self.rank_map.power)
                        end)
                    end
                else
                    self:ReloadRank(self.rank_map.kill)
                end
            end
        end
    ):align(display.TOP_CENTER, size.width / 2, size.height - 30):addTo(body)
end
function WidgetRankingList:onExit()
    WidgetRankingList.super.onExit(self)
end
function WidgetRankingList:ReloadRank(rank)
    if self.rank_map.power == rank then
        local str = self.type_ == "player" and _("我的战斗力排行") or _("我的联盟战斗力排行")
        self.my_ranking:setString(string.format("%s : %d", str, rank.myRank + 1))
    elseif self.rank_map.kill == rank then
        local str = self.type_ == "player" and _("我的击杀排行") or _("我的联盟击杀排行")
        self.my_ranking:setString(string.format("%s : %d", str, rank.myRank + 1))
    end
    self.current_rank = rank
    self.listview:reload()
end
function WidgetRankingList:touchListener(event)
    local listView = event.listView
    if "clicked" == event.name then
        print("async list view clicked idx:" .. event.itemPos)
    end
end
function WidgetRankingList:sourceDelegate(listView, tag, idx)
    if cc.ui.UIListView.COUNT_TAG == tag then
        if self.current_rank then
            return #self.current_rank.rankData
        end
        return 0
    elseif cc.ui.UIListView.CELL_TAG == tag then
        local item
        local content
        item = self.listview:dequeueItem()
        if not item then
            item = self.listview:newItem()
            content = self.type_ == "player" 
            and self:CreatePlayerContentByIndex(idx) 
            or self:CreateAllianceContentByIndex(idx)

            item:addContent(content)
        else
            content = item:getContent()
            content:SetIndex(idx)
        end
        content:SetData(self.current_rank.rankData[idx])
        local size = content:getContentSize()
        item:setItemSize(size.width, size.height)
        return item
    else
    end
end
function WidgetRankingList:CreatePlayerContentByIndex(idx)
    local item = display.newSprite("background2_548x76.png")
    local size = item:getContentSize()
    item.bg2 = display.newSprite("background1_548x76.png"):addTo(item)
        :pos(size.width/2, size.height/2)
    display.newSprite("background_57x57.png"):addTo(item):pos(120, 40)
    display.newSprite("playerIcon_default.png"):addTo(item, 1):pos(120, 40):scale(0.5)
    display.newSprite("dragon_strength_27x31.png"):addTo(item):pos(400, 40)

    item.rank = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, 50, 40):addTo(item)

    item.name = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 160, 40):addTo(item)

    item.value = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 400 + 20, 40):addTo(item)


    function item:SetData(data)
        self.name:setString(data.name)
        self.value:setString(data.value)
        return self
    end
    function item:SetIndex(index)
        self.bg2:setVisible(index % 2 == 0)
        if index <= 3 then
            self.rank:hide()
            if index == 1 and not self.crown_gold then
                if self.crown_silver then
                    self.crown_silver:removeFromParent()
                    self.crown_silver = nil
                end
                if self.crown_brass then
                    self.crown_brass:removeFromParent()
                    self.crown_brass = nil
                end
                self.crown_gold = display.newSprite("crown_gold_46x40.png"):addTo(self, 10):pos(50, 40)
            elseif index == 2 and not self.crown_silver then
                if self.crown_gold then
                    self.crown_gold:removeFromParent()
                    self.crown_gold = nil
                end
                if self.crown_brass then
                    self.crown_brass:removeFromParent()
                    self.crown_brass = nil
                end
                self.crown_silver = display.newSprite("crown_silver_46x40.png"):addTo(self, 10):pos(50, 40)
            elseif not self.crown_brass then
                if self.crown_gold then
                    self.crown_gold:removeFromParent()
                    self.crown_gold = nil
                end
                if self.crown_silver then
                    self.crown_silver:removeFromParent()
                    self.crown_silver = nil
                end
                self.crown_brass = display.newSprite("crown_brass_46x40.png"):addTo(self, 10):pos(50, 40)
            end
        else
            if self.crown_gold then
                self.crown_gold:removeFromParent()
                self.crown_gold = nil
            end
            if self.crown_silver then
                self.crown_silver:removeFromParent()
                self.crown_silver = nil
            end
            if self.crown_brass then
                self.crown_brass:removeFromParent()
                self.crown_brass = nil
            end
            self.rank:show():setString(index)
        end
        return self
    end
    return item:SetIndex(idx)
end
function WidgetRankingList:CreateAllianceContentByIndex(idx)
    local item = display.newSprite("background2_548x76.png")
    local size = item:getContentSize()
    
    item.bg2 = display.newSprite("background1_548x76.png"):addTo(item)
        :pos(size.width/2, size.height/2)

    

    display.newSprite("dragon_strength_27x31.png"):addTo(item):pos(400, 40)

    item.rank = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, 50, 40):addTo(item)

    item.name = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 160, 40):addTo(item)

    item.tag = UIKit:ttfLabel({
        text = "",
        size = 18,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 160, 20):addTo(item)

    item.value = UIKit:ttfLabel({
        text = "",
        size = 22,
        color = 0x403c2f,
    }):align(display.LEFT_CENTER, 400 + 20, 40):addTo(item)


    function item:SetData(data)
        self.name:setString(data.name)
        self.tag:setString(string.format("(%s)", data.tag))
        self.value:setString(data.value)
        if self.flag then
            self.flag:removeFromParent()
        end
        self.flag = ui_helper:CreateFlagContentSprite(Flag:DecodeFromJson(data.flag))
        :addTo(self):align(display.CENTER, 80, 5):scale(0.5)
        return self
    end
    function item:SetIndex(index)
        self.bg2:setVisible(index % 2 == 0)
        if index <= 3 then
            self.rank:hide()
            if index == 1 and not self.crown_gold then
                if self.crown_silver then
                    self.crown_silver:removeFromParent()
                    self.crown_silver = nil
                end
                if self.crown_brass then
                    self.crown_brass:removeFromParent()
                    self.crown_brass = nil
                end
                self.crown_gold = display.newSprite("crown_gold_46x40.png"):addTo(self, 10):pos(50, 40)
            elseif index == 2 and not self.crown_silver then
                if self.crown_gold then
                    self.crown_gold:removeFromParent()
                    self.crown_gold = nil
                end
                if self.crown_brass then
                    self.crown_brass:removeFromParent()
                    self.crown_brass = nil
                end
                self.crown_silver = display.newSprite("crown_silver_46x40.png"):addTo(self, 10):pos(50, 40)
            elseif not self.crown_brass then
                if self.crown_gold then
                    self.crown_gold:removeFromParent()
                    self.crown_gold = nil
                end
                if self.crown_silver then
                    self.crown_silver:removeFromParent()
                    self.crown_silver = nil
                end
                self.crown_brass = display.newSprite("crown_brass_46x40.png"):addTo(self, 10):pos(50, 40)
            end
        else
            if self.crown_gold then
                self.crown_gold:removeFromParent()
                self.crown_gold = nil
            end
            if self.crown_silver then
                self.crown_silver:removeFromParent()
                self.crown_silver = nil
            end
            if self.crown_brass then
                self.crown_brass:removeFromParent()
                self.crown_brass = nil
            end
            self.rank:show():setString(index)
        end
        return self
    end
    return item:SetIndex(idx)
end



return WidgetRankingList







