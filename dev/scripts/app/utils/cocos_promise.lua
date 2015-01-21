local promise = import(".promise")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local function delay_(time, func)
    local p = promise.new(func)
    scheduler.performWithDelayGlobal(function()
        p:resolve()
    end, time)
    return p
end
local function defer(func)
    return delay_(0, func)
end
local function defferPromise(p)
    defer(function() p:resolve() end)
    return p
end
local function delay(time)
    return function(obj)
        return delay_(time, function() return obj end)
    end
end
local function timeOut(time)
    local time = time or 0
    return delay_(time):next(function()
        promise.reject(time, "timeout")
    end)
end
local function promiseWithTimeOut(p, time)
    return promise.any(p, timeOut(time))
end
local function promiseWithCatchError(p)
    return p:catch(function(err)
        dump(err)
        local dialog = FullScreenPopDialogUI.new():AddToCurrentScene():VisibleXButton(false):CreateOKButton(
            {
                btn_name = _("确定"),
                listener = function()
                    app:retryConnectServer()
                end
            })
        local content, title = err:reason()
        dialog:SetTitle(title or "")
        dialog:SetPopMessage(content)
    end)
end

local function promiseFilterNetError(p,need_catch)
    return p:catch(function(err)
        dump(err)
        local dialog = FullScreenPopDialogUI.new():AddToCurrentScene()
        local content, title = err:reason()
        title = title or ""
        if title == 'timeout' then
            content = _("请求超时")
            dialog:DisableAutoClose()
            dialog:VisibleXButton(false)
        end
        dialog:SetTitle(title == 'timeout' and _("错误") or title)
        dialog:SetPopMessage(content):CreateOKButton(
            {
                btn_name = _("确定"),
                listener = function()
                    if title == 'timeout' then
                        app:retryConnectServer()
                    end
                end
            })
        if need_catch then
            promise.reject {"",{msg=err.errcode[1]}}
        else
            return {"",{msg=err.errcode[1]}}
        end
    end)
end

local function promiseOfMoveTo(node, x, y, time, easing)
    local p = promise.new()
    transition.moveTo(node, {
        x = x, y = y, time = time or 0, easing = easing,
        onComplete = function()
            p:resolve(node)
        end
    })
    return p
end

return {
    defer = defer,
    defferPromise = defferPromise,
    Delay = delay_,
    delay = delay,
    timeOut = timeOut,
    promiseWithTimeOut = promiseWithTimeOut,
    promiseWithCatchError = promiseWithCatchError,
    promiseFilterNetError = promiseFilterNetError,
    promiseOfMoveTo = promiseOfMoveTo,
}














