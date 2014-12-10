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

function UIAutoClose:ctor(body)
    body:setTouchEnabled(true)
    self.body = body
end

return UIAutoClose