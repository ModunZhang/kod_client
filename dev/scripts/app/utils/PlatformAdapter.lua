--
-- Author: dannyhe
-- Date: 2014-08-21 20:49:46
--
-- 适配Android的本地api
if device.platform == 'android' then
-------------------------------------------------
--openudid
	if ext.getOpenUDID then
 		device.getOpenUDID = function ()
            return ext.getOpenUDID()
        end
    end

-------------------------------------------------
elseif device.platform == 'mac' then
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


--这里重写菊花显示的时候锁住事件

local showActivityIndicator = device.showActivityIndicator
local hideActivityIndicator = device.hideActivityIndicator

device.showActivityIndicator = function()
    showActivityIndicator()
    -- cc.Director:getInstance():getTouchDispatcher():setDispatchEvents(false)
end

device.hideActivityIndicator = function()
    hideActivityIndicator()
    -- cc.Director:getInstance():getTouchDispatcher():setDispatchEvents(true)
end