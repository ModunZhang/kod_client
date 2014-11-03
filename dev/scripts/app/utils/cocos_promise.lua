local promise = import(".promise")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local function delay(time)
    local p = promise.new()
    scheduler.performWithDelayGlobal(function()
        p:resolve()
    end, time)
    return p
end
local function timeOut(time)
    local time = time or 0
    return delay(time):next(function()
        promise.reject("timeout", time)
    end)
end
local function promiseWithTimeOut(p, time)
    return promise.any(p, timeOut(time))
end
local function promiseWithCatchError(p)
    return p:catch(function(err)
        dump(err)
        local dialog = FullScreenPopDialogUI.new():AddToCurrentScene()
        local content, title = err:reason()
        dialog:SetTitle(title or "")
        dialog:SetPopMessage(content)
    end)
end

return {
    delay = delay,
    timeOut = timeOut,
    promiseWithTimeOut = promiseWithTimeOut,
    promiseWithCatchError = promiseWithCatchError
}






