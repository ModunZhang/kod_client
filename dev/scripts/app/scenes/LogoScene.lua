--
-- Author: dannyhe
-- Date: 2014-08-05 17:34:54
--
local LogoScene = class("LogoScene", function()
    return display.newScene("LogoScene")
end)
function LogoScene:ctor()
    self:loadSplashResources()
end
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local UIListView = import("..ui.UIListView")
local UIPageView = import("..ui.UIPageView")
function LogoScene:onEnter()
    self.layer = cc.LayerColor:create(cc.c4b(255,255,255,255)):addTo(self)
    self.sprite = display.newSprite("batcat_logo_368x507.png", display.cx, display.cy):addTo(self.layer)
    self:performWithDelay(function() self:beginAnimate() end,0.5)
   


    -- local bg_width, bg_height = 250 , 534
    

    -- local pv = UIPageView.new {
    --     viewRect = cc.rect(display.cx - bg_width / 2, display.cy - bg_height / 2 , bg_width, bg_height),
    --     row = 1,
    --     padding = {left = 0, right = 0, top = 10, bottom = 0},
    --     nBounce = true
    -- }:onTouch(function (event)
    --     dump(event)
    --     if event.name == "pageChange" then
           
    --     end
    -- end):addTo(self)

    -- local item = pv:newItem()
    -- local content_bg = WidgetUIBackGround.new({width=250,height = 534},WidgetUIBackGround.STYLE_TYPE.STYLE_6)
    -- local content_listview = UIListView.new{
    --     bgColor = UIKit:hex2c4b(0x7a10aa00),
    --     viewRect = cc.rect(10, 10, bg_width - 20, bg_height - 20),
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    -- }:addTo(content_bg)
    -- content_listview.touchNode_:setTouchSwallowEnabled(false)
    -- local content = WidgetUIBackGround.new({width=230,height = 100},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
    -- local list_item = content_listview:newItem()
    -- list_item:setItemSize(230,100)
    -- list_item:addContent(content)
    -- content_listview:addItem(list_item)
    -- content_listview:reload()

    -- item:addChild(content_bg)
    -- pv:addItem(item)

    --  local item = pv:newItem()
    -- local content_listview = UIListView.new{
    --     bgColor = UIKit:hex2c4b(0x7a10ff00),
    --     viewRect = cc.rect(10, 10, bg_width - 20, bg_height - 20),
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    -- }
    -- content_listview.touchNode_:setTouchSwallowEnabled(false)
    -- local content = WidgetUIBackGround.new({width=250,height = 534},WidgetUIBackGround.STYLE_TYPE.STYLE_6)
    -- local list_item = content_listview:newItem()
    -- list_item:setItemSize(250,534)
    -- list_item:addContent(content)
    -- content_listview:addItem(list_item)
    -- content_listview:reload()

    -- item:addChild(content_listview)
    -- pv:addItem(item)

    --  local item = pv:newItem()
    -- local content_bg = WidgetUIBackGround.new({width=250,height = 534},WidgetUIBackGround.STYLE_TYPE.STYLE_6)
    -- local content_listview = UIListView.new{
    --     bgColor = UIKit:hex2c4b(0x7a101100),
    --     viewRect = cc.rect(10, 10, bg_width - 20, bg_height - 20),
    --     direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    -- }:addTo(content_bg)
    -- content_listview.touchNode_:setTouchSwallowEnabled(false)
    -- local content = WidgetUIBackGround.new({width=230,height = 100},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
    -- local list_item = content_listview:newItem()
    -- list_item:setItemSize(230,100)
    -- list_item:addContent(content)
    -- content_listview:addItem(list_item)
    -- content_listview:reload()

    -- item:addChild(content_bg)
    -- pv:addItem(item)
    -- pv:reload()
end

function LogoScene:beginAnimate()
    local action = cc.Spawn:create({cc.ScaleTo:create(checknumber(2),1.5),cca.fadeTo(1.5,255/2)})
    self.sprite:runAction(action)
    local sequence = transition.sequence({
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            self:performWithDelay(function()
                self.sprite:removeFromParent(true)
                app:enterScene("MainScene")
            end, 0.5)
        end),
    })
    self.layer:runAction(sequence)
end
--预先加载登录界面使用的大图
function LogoScene:loadSplashResources()
    --加载splash界面使用的图片
    display.addImageAsync("splash_logo_515x92.png",function()
        display.addImageAsync("splash_beta_bg_3987x1136.jpg",function()end)
    end)
end



function LogoScene:onExit()
    cc.Director:getInstance():getTextureCache():removeTextureForKey("batcat_logo_368x507.png")
end

return LogoScene







