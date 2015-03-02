--TODO:这里需要把此类继承GameUIBase 方便统一管理(后台统一关闭界面,半透明背景效果,提示框管理 etc)

local GameUIBase = import('.GameUIBase')

local UIAutoClose = class('UIAutoClose', GameUIBase)

function UIAutoClose:ctor(params)
    UIAutoClose.super.ctor(self,params)
    local node = display.newColorLayer(UIKit:hex2c4b(0x7a000000))
    node:setNodeEventEnabled(true)
    node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "ended" then
            if node.disable then
                return
            end
            self:leftButtonClicked()
        end
        return true
    end)
    node:addTo(self)
end

function UIAutoClose:addTouchAbleChild(body)
    body:setTouchEnabled(true)
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

