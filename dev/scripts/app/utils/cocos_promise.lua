local promise = import(".promise")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local function delay_(time)
    local p = promise.new()
    scheduler.performWithDelayGlobal(function()
        p:resolve()
    end, time)
    return p
end
local function delay(time)
    return function()
        return delay_(time)
    end
end
local function timeOut(time)
    local time = time or 0
    return delay_(time):next(function()
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

local function promiseFilterNetError(p,need_catch)
    return p:catch(function(err)
        dump(err)
        local dialog = FullScreenPopDialogUI.new():AddToCurrentScene()
        local content, title = err:reason()
        dialog:SetTitle(title or "")
        dialog:SetPopMessage(content)
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
    delay = delay,
    timeOut = timeOut,
    promiseWithTimeOut = promiseWithTimeOut,
    promiseWithCatchError = promiseWithCatchError,
    promiseFilterNetError = promiseFilterNetError,
    promiseOfMoveTo = promiseOfMoveTo,
}











