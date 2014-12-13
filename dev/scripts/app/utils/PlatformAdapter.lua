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
    -- ext.localpush = {
    --     switchNotification = function(...)
    --     end,
    --     addNotification = function(...)
    --     end,
    --     cancelAll = function(...)
    --     end,
    --     cancelNotification = function(...)
    --     end
    -- }
    cc.DTextView = {}
    setmetatable(cc.DTextView,{
        __index= function( ... )
            assert(false,"\n--- cc.DTextView not support for Player!\n")
        end
    })
end

--[[
    模拟器和真机支持cc.DTextView 
    函数名和参数同EditBox 构造函数不同
    player/android 不支持
    
    local textView = cc.DTextView:create(cc.size(549,379),display.newScale9Sprite("chat_setting_listview_bg.png"))
    textView:addTo(self):center()
    textView:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)    
    textView:setFont(UIKit:getFontFilePath(), 24)
    textView:registerScriptTextViewHandler(function(event,textView)

 end)
]]--


function PlatformAdapter:common()
    --重写菊花显示的时候锁住事件
    local showActivityIndicator = device.showActivityIndicator
    local hideActivityIndicator = device.hideActivityIndicator

    device.showActivityIndicator = function()
        showActivityIndicator()
        app:lockInput(true)
    end

    device.hideActivityIndicator = function()
        hideActivityIndicator()
        app:lockInput(false)
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