--
-- Author: dannyhe
-- Date: 2014-08-01 16:18:16
-- GameUIBase is a CCLayer
local cocos_promise = import("..utils.cocos_promise")
local window = import("..utils.window")
local UIListView = import(".UIListView")
local WidgetBackGroundTabButtons = import('..widget.WidgetBackGroundTabButtons')
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
-- local TabButtons = import('.TabButtons')
local GameUIBase = class('GameUIBase', function()
    return display.newLayer()
end)

function GameUIBase:ctor()
    -- app:lockInput(true)
    self:setNodeEventEnabled(true)
    return true
end

-- local visible_count = 1
-- Node Event
--------------------------------------
function GameUIBase:onEnter()
    print("onEnter->")
    UIKit:CheckOpenUI(self)
end

function GameUIBase:onEnterTransitionFinish()
    print("onEnterTransitionFinish->")
end

function GameUIBase:onExitTransitionStart()
    print("onExitTransitionStart->")
end

function GameUIBase:onExit()
    print("onExit--->")
end


function GameUIBase:onCleanup()
    print("onCleanup->",self.__cname)
    UIKit:getRegistry().removeObject(self.__cname)
    -- app:lockInput(false)
end


-- overwrite in subclass
--------------------------------------
function GameUIBase:rightButtonClicked()
end

function GameUIBase:onMoveInStage()
-- app:lockInput(false)
end

function GameUIBase:onMoveOutStage()
    self:removeFromParent(true)
end


-- public methods
--------------------------------------

function GameUIBase:leftButtonClicked()
    if self:isVisible() then
        if self.moveInAnima then
            self:UIAnimationMoveOut()
        else
            self:onMoveOutStage() -- fix
        end
    end
end

function GameUIBase:addToScene(scene,anima)
    print("addToScene->",tolua.type(scene))
    anima = false
    if scene and tolua.type(scene) == 'cc.Scene' then
        scene:addChild(self, 2000)
        self.moveInAnima = anima == nil and false or anima
        if self.moveInAnima then
            self:UIAnimationMoveIn()
        else
            self:onMoveInStage()
        end
    end
    return self
end

function GameUIBase:addToCurrentScene(anima)
    return self:addToScene(display.getRunningScene(),anima)
end

-- ui入场动画
function GameUIBase:UIAnimationMoveIn()
    -- app:lockInput(true)
    self:pos(0,-self:getContentSize().height)
    transition.execute(self, cc.MoveTo:create(0.5, cc.p(0, 0)),
        {
            easing = "sineIn",
            onComplete = function()
                self:onMoveInStage()
            end
        })
end

-- ui 出场动画
function GameUIBase:UIAnimationMoveOut()
    print("UIAnimationMoveOut->",self,tolua.type(self))
    -- app:lockInput(true)
    transition.execute(self, cc.MoveTo:create(0.5, cc.p(0, -self:getContentSize().height)),
        {
            easing = "sineIn",
            onComplete = function()
                -- app:lockInput(false)
                self:onMoveOutStage()
            end
        })
end

-- Private Methods
--------------------------------------

--

function GameUIBase:CreateBackGround()
    -- local node = display.newNode()
    -- local bg = display.newScale9Sprite("common_bg_center.png")
    --     :pos(display.cx,display.cy)
    --     :addTo(node)
    -- bg:setContentSize(cc.size(bg:getContentSize().width,display.height))
    -- display.newSprite("common_bg_top.png")
    --     :align(display.CENTER, display.cx, display.top - 72)
    --     :addTo(node)
    -- display.newSprite("common_bg_top.png")
    --     :align(display.CENTER, display.cx, display.bottom)
    --     :addTo(node)
    -- return node:addTo(self)
    return display.newSprite("common_bg_center.png"):align(display.CENTER_TOP, window.cx,window.top-40):addTo(self)
end
function GameUIBase:CreateTitle(title)
    local head_bg = cc.ui.UIImage.new("head_bg.png")
        :align(display.TOP_CENTER, window.cx, window.top)
        :addTo(self)
    return UIKit:ttfLabel({
        text = title,
        size = 30,
        color = 0xffedae,
        align = cc.TEXT_ALIGNMENT_LEFT,
        bold  = true
    })
        :addTo(head_bg)
        :align(display.CENTER, head_bg:getContentSize().width / 2, head_bg:getContentSize().height - 35)
end
function GameUIBase:CreateHomeButton(on_clicked)
    local home_button = cc.ui.UIPushButton.new(
        {normal = "home_btn_up.png",pressed = "home_btn_down.png"})
        :onButtonClicked(function(event)
            if on_clicked then
                on_clicked()
            else
                self:leftButtonClicked()
            end
        end)
        :align(display.LEFT_TOP, window.cx-314 , window.top-5)
        :addTo(self)

    cc.ui.UIImage.new("home_icon.png")
        :pos(34, -50)
        :addTo(home_button)
        :scale(0.8)
    return home_button
end
function GameUIBase:CreateShopButton(on_clicked)
    local gem_button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up.png", pressed = "gem_btn_down.png"}
    ):onButtonClicked(function(event)
        if on_clicked then
            on_clicked()
        else
            self:leftButtonClicked()
        end
    end):addTo(self)
    gem_button:align(display.RIGHT_TOP, window.cx+314, window.top-5)
    cc.ui.UIImage.new("home/gem_1.png")
        :addTo(gem_button)
        :pos(-55, -52)

    return UIKit:ttfLabel({
        -- text = ""..string.formatnumberthousands(City.resource_manager:GetGemResource():GetValue()),
        size = 20,
        color = 0xffd200,
        shadow = true
    })
        :addTo(gem_button)
        :align(display.CENTER, -102, -32)
end
function GameUIBase:CreateTabButtons(param, func)
    return WidgetBackGroundTabButtons.new(param,
        func)
        :addTo(self)
end

function GameUIBase:CreateVerticalListView(...)
    return self:CreateVerticalListViewDetached(...):addTo(self)
end
function GameUIBase:CreateVerticalListViewDetached(left_bottom_x, left_bottom_y, right_top_x, right_top_y)
    local width, height = right_top_x - left_bottom_x, right_top_y - left_bottom_y
    return UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(left_bottom_x, left_bottom_y, width, height),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL
    }
end
function GameUIBase:CreatePopupBg(height)
    return WidgetUIBackGround.new({height=height})
end
function GameUIBase:CreateTutorialLayer()
    local node = display.newNode():addTo(self, 3000)
    local left = display.newColorLayer(cc.c4b(255, 0, 0, 50)):addTo(node, 0)
    local right = display.newColorLayer(cc.c4b(255, 0, 0, 50)):addTo(node, 0)
    local top = display.newColorLayer(cc.c4b(255, 0, 0, 50)):addTo(node, 0)
    local bottom = display.newColorLayer(cc.c4b(255, 0, 0, 50)):addTo(node, 0)
    -- local left = display.newLayer():addTo(node, 0)
    -- local right = display.newLayer():addTo(node, 0)
    -- local top = display.newLayer():addTo(node, 0)
    -- local bottom = display.newLayer():addTo(node, 0)
    for _, v in pairs{ left, right, top, bottom } do
        v:setContentSize(cc.size(display.width, display.height))
        v:setTouchEnabled(true)
    end
    local count = 0
    function node:Enable()
        count = count + 1
        if count > 0 then
            for _, v in pairs{ left, right, top, bottom } do
                v:setTouchEnabled(true)
            end
        end
        return self
    end
    function node:Disable()
        count = count - 1
        if count <= 0 then
            for _, v in pairs{ left, right, top, bottom } do
                v:setTouchEnabled(false)
            end
        end
        return self
    end
    function node:Reset()
        count = 0
        for _, v in pairs{ left, right, top, bottom } do
            v:setTouchEnabled(false)
        end
        self.object = nil
        self.world_rect = nil
        return self
    end
    function node:SetTouchObject(obj)
        self.object = obj
        self:UpdateClickedRegion(self:GetClickedRect())
        return self
    end
    function node:SetTouchRect(world_rect)
        self.world_rect = world_rect
        return self
    end
    function node:UpdateClickedRegion(rect)
        left:pos(rect.x - display.width, 0)
        right:pos(rect.x + rect.width, 0)
        top:pos(0, rect.y + rect.height)
        bottom:pos(0, rect.y - display.height)
    end
    function node:GetClickedRect()
        if self.world_rect then
            return self.world_rect
        elseif self.object then
            return self.object:getCascadeBoundingBox()
        else
            return cc.rect(0, 0, display.width, display.height)
        end
    end
    return node:Reset()
end

function GameUIBase:Lock()
    return cocos_promise.deffer(function()
        return self
    end)
end
function GameUIBase:Find()
    assert(false)
end

return GameUIBase

