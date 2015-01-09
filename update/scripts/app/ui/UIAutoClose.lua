local UIAutoClose = class("UIAutoClose", function()
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            node:leftButtonClicked()
        end
        return true
    end)
    if ext.closeKeyboard then
        ext.closeKeyboard()
    end
    return node
end)

function UIAutoClose:addTouchAbleChild(body)
    body:setTouchEnabled(true)
    self:addChild(body)
end
function UIAutoClose:addToScene(scene,anima)
    print("addToScene->",tolua.type(scene),scene)
    anima = false
    if scene and tolua.type(scene) == 'cc.Scene' then
        scene:addChild(self, 2000)
    end
    return self
end
function UIAutoClose:onEnter()
    
end
function UIAutoClose:onExit()
   
end
function UIAutoClose:onCleanup()
    if UIKit:getRegistry().isObjectExists(self.__cname) then
        UIKit:getRegistry().removeObject(self.__cname)
    end
end
function UIAutoClose:addToCurrentScene( anima )
    return self:addToScene(display.getRunningScene(),anima)
end
function UIAutoClose:leftButtonClicked()
    if self:isVisible() then
        if self.moveInAnima then
            self:UIAnimationMoveOut()
        else
            self:onMoveOutStage() -- fix
        end
    end
end
-- ui入场动画
function UIAutoClose:UIAnimationMoveIn()
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
function UIAutoClose:UIAnimationMoveOut()
    transition.execute(self, cc.MoveTo:create(0.5, cc.p(0, -self:getContentSize().height)),
        {
            easing = "sineIn",
            onComplete = function()
                self:onMoveOutStage()
            end
        })
end
function UIAutoClose:onMoveOutStage()
    self:removeFromParent(true)
end
return UIAutoClose