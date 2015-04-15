--TODO:这里需要把此类继承GameUIBase 方便统一管理(后台统一关闭界面,半透明背景效果,提示框管理 etc)

local GameUIBase = import('.GameUIBase')

local UIAutoClose = class('UIAutoClose', GameUIBase)

function UIAutoClose:ctor(params)
    UIAutoClose.super.ctor(self,params)
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            if self.disable then
                return
            end
            self:LeftButtonClicked()
        end
        return true
    end)
    node:addTo(self)
end

function UIAutoClose:addTouchAbleChild(body)
    body:setTouchEnabled(true)
    function body:isTouchInViewRect( event)
        for k,v in pairs(self:getChildren()) do
            if v:getCascadeBoundingBox():containsPoint(cc.p(event.x, event.y)) then
                return true
            end
        end
        local viewRect = self:convertToWorldSpace(cc.p(0, 0))
        viewRect.width = self:getContentSize().width
        viewRect.height = self:getContentSize().height
        return cc.rectContainsPoint(viewRect, cc.p(event.x, event.y))
    end
    body:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        if ("began" == event.name or "moved" == event.name or "ended" == event.name)
            and body:isTouchInViewRect(event) then
            return true
        else
            return false
        end
    end)
    self:addChild(body)
end

function UIAutoClose:onCleanup()
    UIAutoClose.super.onCleanup(self)
    if self.clean_func then
        self.clean_func()
    end
end

function UIAutoClose:DisableAutoClose()
    self.disable = true
end

function UIAutoClose:addCloseCleanFunc(func)
    self.clean_func=func
end
return UIAutoClose



