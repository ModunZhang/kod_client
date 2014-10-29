local promise = import(".promise")
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
return {
    delay = delay,
    timeOut = timeOut,
    promiseWithTimeOut = promiseWithTimeOut,
}




