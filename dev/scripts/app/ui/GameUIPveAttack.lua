local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local GameUIPveAttack = class("GameUIPveAttack", WidgetPopDialog)

local titles = {
	_("战斗胜利"),
	_("龙在战斗中胜利"),
	_("一个兵种击败敌军"),
}


function GameUIPveAttack:ctor()
    GameUIPveAttack.super.ctor(self,600,_("关卡"),window.top - 200)
end
function GameUIPveAttack:onEnter()
    GameUIPveAttack.super.onEnter(self)

    local size = self:GetBody():getContentSize()
    UIKit:ttfLabel({
        text = _("几率掉落"),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.CENTER, size.width/2, size.height - 40)


    local list,list_node = UIKit:commonListView_1({
        viewRect = cc.rect(0, 0, 550, 120),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
	list.touchNode_:setTouchEnabled(false)
    list_node:addTo(self:GetBody()):pos(20, size.height - 320)
    for i = 1, 3 do
        local item = list:newItem()
        local content = self:GetListItem(i,titles[i])
        item:addContent(content)
        item:setItemSize(600,40)
        list:addItem(item)
    end
    list:reload()

    UIKit:ttfLabel({
        text = string.format(_("今日可挑战次数: %d/%d"), 1, 5),
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(self:GetBody()):align(display.LEFT_CENTER,20,size.height - 350)

end
function GameUIPveAttack:GetListItem(index,title)
    local bg = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(600,40)
    UIKit:ttfLabel({
        text = title,
        size = 20,
        color = 0x403c2f,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT,
    }):addTo(bg):align(display.LEFT_CENTER,30,20)

    local ax = bg:getContentSize().width - 50
    for i = 1, 3 do
    	display.newSprite(index >= i and "alliance_shire_star_60x58_1.png" or "alliance_shire_star_60x58_0.png")
    	:addTo(bg):pos(ax - (i-1) * 45, 20):scale(0.7)
    end
    return bg
end


return GameUIPveAttack



