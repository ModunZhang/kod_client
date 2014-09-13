--
-- Author: dannyhe
-- Date: 2014-08-01 16:18:16
-- GameUIBase is a CCLayer
local TabButtons = import('.TabButtons')
local GameUIBase = class('GameUIBase', function()
    return display.newLayer()
end)

function GameUIBase:ctor(param)
    self:setNodeEventEnabled(true)
    if param then return self:_initCommonUI(param) end
    return true
end


-- Node Event
--------------------------------------
function GameUIBase:onEnter()
    print("onEnter->")
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
    print("onCleanup->")
end


-- overwrite in subclass
--------------------------------------
function GameUIBase:rightButtonClicked()
end

function GameUIBase:onMovieInStage()
end

function GameUIBase:onMovieOutStage()
    self:removeFromParent(true)
end


-- public methods
--------------------------------------

function GameUIBase:leftButtonClicked()
    if self:isVisible() then
        if self.moveInAnima then
            self:UIAnimationMoveOut()
        else
            self:removeFromParent(true) -- 没有动画就直接删除
        end
    end
end

function GameUIBase:addToScene(scene,anima)
    print("addToScene->",tolua.type(scene))
    if scene and tolua.type(scene) == 'cc.Scene' then
        scene:addChild(self, 2000)
        self.moveInAnima = anima == nil and false or anima
        if self.moveInAnima then
            self:UIAnimationMoveIn()
        else
            self:onMovieInStage()
        end
    end
    return self
end

function GameUIBase:addToCurrentScene(anima)
    return self:addToScene(display.getRunningScene(),anima)
end

-- ui入场动画
function GameUIBase:UIAnimationMoveIn()
    self:pos(0,-self:getContentSize().height)
    transition.execute(self, cc.MoveTo:create(0.5, cc.p(0, 0)),
        {
            easing = "sineIn",
            onComplete = function()
                self:onMovieInStage()
            end
        })
end

-- ui 出场动画
function GameUIBase:UIAnimationMoveOut()
    print("UIAnimationMoveOut->",self,tolua.type(self))
    transition.execute(self, cc.MoveTo:create(0.5, cc.p(0, -self:getContentSize().height)),
        {
            easing = "sineIn",
            onComplete = function()
                self:onMovieOutStage()
            end
        })
end

-- Private Methods
--------------------------------------
function GameUIBase:_initCommonUI(param)

end


--

function GameUIBase:CreateBackGround()
    return display.newSprite("back_ground.png")
        :align(display.LEFT_TOP, display.left, display.top - 40)
        :addTo(self)
end
function GameUIBase:CreateTitle(title)
    local head_bg = cc.ui.UIImage.new("head_bg.png")
        :align(display.TOP_CENTER, display.cx, display.top)
        :addTo(self)
    return ui.newTTFLabel({
        text = title,
        font = UIKit:getFontFilePath(),
        size = 30,
        align = ui.TEXT_ALIGN_CENTER,
        color = UIKit:hex2c3b(0xffedae),
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
        :align(display.LEFT_TOP, display.left , display.top)
        :addTo(self)
    cc.ui.UIImage.new("home_icon.png")
        :pos(27, -72)
        :addTo(home_button)
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
    gem_button:align(display.RIGHT_TOP, display.right, display.top)
    cc.ui.UIImage.new("home/gem.png")
        :addTo(gem_button)
        :pos(-75, -65)

    local gem_num_bg = cc.ui.UIImage.new("gem_num_bg.png"):addTo(gem_button):pos(-85, -85)
    local pos = gem_num_bg:getAnchorPointInPoints()
    return ui.newTTFLabel({
            text = ""..City.resource_manager:GetGemResource():GetValue(),
            font = UIKit:getFontFilePath(),
            size = 14,
            color = UIKit:hex2c3b(0xfdfac2)})
            :addTo(gem_num_bg)
            :align(display.CENTER, 40, 15)
end
function GameUIBase:CreateTabButtons(param, func)
    return TabButtons.new(param,
        {
            gap = -4,
            margin_left = -2,
            margin_right = -2,
            margin_up = -6,
            margin_down = 1
        },
        func)
        :addTo(self)
end

function GameUIBase:CreateVerticalListView(left_bottom_x, left_bottom_y, right_top_x, right_top_y)
    local width, height = right_top_x - left_bottom_x, right_top_y - left_bottom_y
    return cc.ui.UIListView.new{
        -- bgColor = UIKit:hex2c4b(0x7a000000),
        viewRect = cc.rect(left_bottom_x, left_bottom_y, width, height),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :addTo(self)
end
return GameUIBase



