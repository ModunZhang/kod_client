--
-- Author: Danny He
-- Date: 2015-01-27 10:37:38
--
local GameUIEmojiSelect = UIKit:createUIClass("GameUIEmojiSelect")
local EmojiTable = import("..utils.EmojiTable")
local WidgetPushButton = import("..widget.WidgetPushButton")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local WidgetDropList = import("..widget.WidgetDropList")
local window = import("..utils.window")
local UIScrollView = import(".UIScrollView")

function GameUIEmojiSelect:ctor(func)
	GameUIEmojiSelect.super.ctor(self)
	self.selectFunc_ = func
end

function GameUIEmojiSelect:onEnter()
	GameUIEmojiSelect.super.onEnter(self)
	local shieldView = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
        :addTo(self,self.PLAYERMENU_ZORDER)
    local bg =  WidgetUIBackGround.new({height=658}):addTo(shieldView):pos(window.left+20,window.bottom+100)
    local header = display.newSprite("alliance_blue_title_600x42.png")
        :addTo(bg)
        :align(display.CENTER_BOTTOM, 304, 644)
    UIKit:closeButton():addTo(header)
        :align(display.BOTTOM_RIGHT,header:getContentSize().width, 0)
        :onButtonClicked(function ()
            self:leftButtonClicked()
        end)
    local title_label = UIKit:ttfLabel({
        text = _("表情"),
        size = 24,
        color = 0xffedae,
    }):align(display.CENTER,header:getContentSize().width/2, header:getContentSize().height/2):addTo(header)
    self.bg = bg

    local dropList = WidgetDropList.new(
		{
			{tag = "Smiley",label = _("笑脸"),default = true},
			{tag = "Flower",label = _("花")},
		},
		function(tag)
			-- if tag == 'Smiley' then

			-- end
			self:DisplayEmojiWithCategory(tag)
		end
	)
	dropList:align(display.CENTER_TOP,bg:getContentSize().width/2,640):addTo(bg)
	self.scrollView = UIScrollView.new({
        	viewRect = cc.rect(30,20,bg:getContentSize().width - 60,560),
        	bgColor = UIKit:hex2c4b(0x7a000000),
    	}):setDirection(UIScrollView.DIRECTION_VERTICAL):addTo(bg)
        -- :addScrollNode(self:CreateScrollNode():pos(40, 0))
    -- local pv = UIPageView.new {
    --     viewRect = cc.rect(10, 4, size.width-80, size.height),
    --     row = 2,
    --     padding = {left = 0, right = 0, top = 10, bottom = 0}
    -- }:onTouch(function (event)
    --         dump(event,"UIPageView event")
    --         if event.name == "pageChange" then
    --             if 1 == event.pageIdx then
    --                 index_1:setPositionX(chat_bg:getContentSize().width/2-10)
    --                 index_2:setPositionX(chat_bg:getContentSize().width/2+10)
    --             elseif 2 == event.pageIdx then
    --                 index_1:setPositionX(chat_bg:getContentSize().width/2+10)
    --                 index_2:setPositionX(chat_bg:getContentSize().width/2-10)
    --             end
    --         elseif event.name == "clicked" then
    --             if event.pageIdx == 1 then
    --                 UIKit:newGameUI('GameUIChatChannel',"global"):addToCurrentScene(true)
    --             elseif event.pageIdx == 2 then
    --                 UIKit:newGameUI('GameUIChatChannel',"alliance"):addToCurrentScene(true)
    --             end
    --         end
    --     end)
    --     :addTo(chat_bg)
    -- pv:setTouchEnabled(true)
    -- pv:setTouchSwallowEnabled(false)
end

function GameUIEmojiSelect:DisplayEmojiWithCategory()

end

return GameUIEmojiSelect