local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local window = import("..utils.window")
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local GameUIPveSelect = class("GameUIPveSelect", WidgetPopDialog)

function GameUIPveSelect:ctor()
    GameUIPveSelect.super.ctor(self,700,_("选择关卡"),window.top - 150)
end
function GameUIPveSelect:onEnter()
    GameUIPveSelect.super.onEnter(self)
    local size = self:GetBody():getContentSize()

    local list,list_node = UIKit:commonListView_1({
        viewRect = cc.rect(0, 0, 550, 600),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
    })
    list_node:addTo(self:GetBody()):pos(20, size.height - 660)



    for i = 1, 20 do
        local item = list:newItem()
        local content = self:GetListItem(i)
        item:addContent(content)
        item:setItemSize(600,100)
        list:addItem(item)
    end
    list:reload()
end
function GameUIPveSelect:GetListItem(index)
    local bg = display.newScale9Sprite(string.format("back_ground_548x40_%d.png", index % 2 == 0 and 1 or 2)):size(600,100)
    return bg
end


return GameUIPveSelect







