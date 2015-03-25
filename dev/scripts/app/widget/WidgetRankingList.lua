local cocos_promise = import("..utils.cocos_promise")
local window = import("..utils.window")
local UIListView = import("..ui.UIListView")
local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetDropList = import("..widget.WidgetDropList")
local WidgetRankingList = class("WidgetRankingList", WidgetPopDialog)
function WidgetRankingList:ctor()
    WidgetRankingList.super.ctor(self, 762, _("个人排行榜"), display.cy + 350)
end
function WidgetRankingList:onEnter()
    WidgetRankingList.super.onEnter(self)

    local body = self:GetBody()
    local size = body:getContentSize()
    
    local bg = display.newSprite("background_548x52.png"):addTo(body):align(display.TOP_CENTER, size.width / 2, size.height - 95)
    self.my_ranking = UIKit:ttfLabel({
        text = _("我的战斗力排行:44"),
        size = 22,
        color = 0x403c2f,
    }):align(display.CENTER, bg:getContentSize().width/2, bg:getContentSize().height/2)
        :addTo(bg)
    
    self.listview = UIListView.new{
        bgColor = UIKit:hex2c4b(0x7a100000),
        viewRect = cc.rect(0, 20, size.width, size.height - 170),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }:addTo(body)

    WidgetDropList.new(
        {
            {tag = "power",label = _("战斗力排行榜"),default = true},
        },
        function(tag)
            if tag == 'power' then
                print("hello")
            end
        end
    ):align(display.TOP_CENTER, size.width / 2, size.height - 20):addTo(body)
end
function WidgetRankingList:onExit()
    WidgetRankingList.super.onExit(self)
end
-- function WidgetRankingList:RefreshItems()
--     self.listview:removeAllItems()
--     for _,v in ipairs(self.category.tasks) do
--         self.listview:addItem(self:CreateItem(self.listview, v))
--     end
--     self.listview:reload()
--     if self.listview.items_[1] then
--         self.listview.items_[1]:getContent():OnOpen(false)
--     end
-- end



return WidgetRankingList















