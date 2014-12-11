local UIAutoClose = class("UIAutoClose", function()
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            node:removeFromParent()
        end
        return true
    end)
    return node
end)

function UIAutoClose:addTouchAbleChild(body)
    body:setTouchEnabled(true)
    self:addChild(body)
end
function UIAutoClose:addToScene(scene,anima)
    print("addToScene->",tolua.type(scene))
    anima = false
    if scene and tolua.type(scene) == 'cc.Scene' then
        scene:addChild(self, 2000)
    end
    return self
end

function UIAutoClose:addToCurrentScene( anima )
    return self:addToScene(display.getRunningScene(),anima)
end
return UIAutoClose