--
-- Author: Danny He
-- Date: 2014-09-15 08:59:42
--
local GameListViewDemo = UIKit:createUIClass("GameListViewDemo")
local TabButtons = import(".TabButtons")
local UIListView = import(".UIListView")

function GameListViewDemo:ctor()
	 GameListViewDemo.super.ctor(self)
end


function GameListViewDemo:onEnter()
    GameListViewDemo.super.onEnter(self)
	self:CreateUI()
end

function GameListViewDemo:CreateUI()
	self.listView = UIListView.new {
        bg = "chat_list_bg.png",
        bgScale9 = true,
        viewRect = cc.rect(display.left+45, display.bottom+100, 549,900),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        alignment = cc.ui.UIListView.ALIGNMENT_LEFT
    	}
        :onTouch(handler(self, self.listviewListener))
        :addTo(self)
  
   
    self:createTabButtons()
end
function GameListViewDemo:listviewListener( event)
end

function GameListViewDemo:createTabButtons()
	local tab_buttons = TabButtons.new({
        {
            label ="添加",
            tag = "add",
            default = true,
        },
        {
            label = "清空",
            tag = "clean",
        },
        {
            label = "清除最后一个",
            tag = "removeLastItem",
        }
    },
    {
        gap = -4,
        margin_left = -2,
        margin_right = -2,
        margin_up = -6,
        margin_down = 1
    },
    function(tag)
    	if tag == 'clean' then
    		dump(self.listView:getItem(1):getTag(),"获取item 1的Tag")
    		self.listView:removeAllItems()
    	elseif  tag == 'removeLastItem' then
    		self.listView:removeLastItem(false)
    	else
	    	for i=1,10 do
			     local item = self.listView:newItem()
			     local content = cc.ui.UILabel.new(
			                    {text = "item"..item.id,
			                    size = 20,
			                    align = cc.ui.TEXT_ALIGN_CENTER,
			                    color = display.COLOR_BLACK})
			    item:addContent(content)
			    item:setItemSize(549, 80)
				self.listView:addItem(item)
	    	end
	    	 self.listView:reload()
    	end
    end):addTo(self):pos(display.cx, display.bottom + 50)
end

return GameListViewDemo