--
-- Author: dannyhe
-- Date: 2014-08-21 20:49:46
--
-- 适配相应平台的Lua接口
local PlatformAdapter = {}

function PlatformAdapter:android()
    --openudid
    if ext.getOpenUDID then
        device.getOpenUDID = function ()
            return ext.getOpenUDID()
        end
    end
end

function PlatformAdapter:mac()
    ext.localpush = {
        switchNotification = function(...)
        end,
        addNotification = function(...)
        end,
        cancelAll = function(...)
        end,
        cancelNotification = function(...)
        end
    }
end

function PlatformAdapter:common()
    --重写菊花显示的时候锁住事件
    local showActivityIndicator = device.showActivityIndicator
    local hideActivityIndicator = device.hideActivityIndicator

    device.showActivityIndicator = function()
        showActivityIndicator()
        cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    end

    device.hideActivityIndicator = function()
        hideActivityIndicator()
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
    end
end

--------------------------------------------------------------------
if PlatformAdapter[device.platform] then
    PlatformAdapter[device.platform]()
end
PlatformAdapter:common()