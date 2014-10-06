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
    --CCTableView
    cc.TABLEVIEW_FILL_TOPDOWN = 0
    cc.TABLEVIEW_FILL_BOTTOMUP = 1

    cc.SCROLLVIEW_SCRIPT_SCROLL = 0
    cc.SCROLLVIEW_SCRIPT_ZOOM   = 1
    cc.TABLECELL_TOUCHED        = 2
    cc.TABLECELL_HIGH_LIGHT     = 3
    cc.TABLECELL_UNHIGH_LIGHT   = 4
    cc.TABLECELL_WILL_RECYCLE   = 5
    cc.TABLECELL_SIZE_FOR_INDEX = 6
    cc.TABLECELL_SIZE_AT_INDEX  = 7
    cc.NUMBER_OF_CELLS_IN_TABLEVIEW = 8
    cc.SCROLLVIEW_BOUND_TOP = 9
    cc.SCROLLVIEW_BOUND_BOTTOM = 10

    cc.SCROLLVIEW_DIRECTION_NONE = -1
    cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
    cc.SCROLLVIEW_DIRECTION_VERTICAL = 1
    cc.SCROLLVIEW_DIRECTION_BOTH  = 2
end

--------------------------------------------------------------------
if PlatformAdapter[device.platform] then
    PlatformAdapter[device.platform]()
end
PlatformAdapter:common()