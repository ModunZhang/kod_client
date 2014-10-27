-- error类
local err_class = {}
err_class.__index = err_class
function err_class.new(...)
    local r = {}
    setmetatable(r, err_class)
    r:ctor(...)
    return r
end
function err_class:ctor(...)
    self.errcode = {...}
end
function err_class:reason()
    return unpack(self.errcode)
end
local function is_error(obj)
    return getmetatable(obj) == err_class
end
------
local promise = {}
promise.__index = promise
local PENDING = 1
local RESOLVED = 2
local REJECTED = 3
local empty_func = function(...) return ... end
local function is_promise(obj)
    return getmetatable(obj) == promise
end
local function pop_head(array)
    assert(type(array) == "table")
    return table.remove(array, 1)
end
local function is_complete(p)
    return #p.thens == 0
end
local function is_not_complete(p)
    return #p.thens > 0
end
local function do_promise(p)
    local head = pop_head(p.thens)
    local success_func, failed_func = unpack(head or {})
    local success, result
    if type(success_func) == "function" then
        success, result = pcall(success_func, p.result)
    end
    return success, result, failed_func
end
local function handle_next_failed_func(p, err)
    local thens = p.thens
    local _, failed_func
    repeat
        local head = pop_head(thens)
        _, failed_func = unpack(head or {})
    until failed_func ~= nil or #thens == 0

    if type(failed_func) == "function" then
        return failed_func(err)
    end

    -- 在子任务里面找
    local next_promise = pop_head(p.next_promises)
    if next_promise == nil then
        if p.ignore_error then
            return err
        end
        dump(err)
        assert(false, "你应该捕获这个错误!")
    end
    return handle_next_failed_func(next_promise, err)
end
local function handle_result(p, success, result, failed_func)
    if success then
        p.result = result
        if is_promise(result) then
            table.insert(result.next_promises, p)
            return true
        end
    else
        -- 如果当前任务有错误处理函数,捕获并继续传入下一个任务进行处理
        p.state_ = REJECTED
        if not is_error(result) then
            result = err_class.new(result)
        end
        if type(failed_func) == "function" then
            p.result = failed_func(result)
        else
            p.result = handle_next_failed_func(p, result)
        end
    end
end
local function done_promise(p)
    local result = p.result
    table.foreachi(p.dones, function(_, v) v(result) end)
end
local function fail_promise(p)
    local result = p.result
    table.foreachi(p.fails, function(_, v) v(result) end)
end
local function always_promise(p)
    local result = p.result
    table.foreachi(p.always_, function(_, v) v(result) end)
end
local function complete_promise(p)
    if p:state() == REJECTED then
        fail_promise(p)
    else
        done_promise(p)
    end
    always_promise(p)
    return pop_head(p.next_promises)
end
local function repeat_resolve(p)
    while is_not_complete(p) do
        if handle_result(p, do_promise(p)) then
            return
        end
    end

    local next_promise = complete_promise(p)
    while true do
        if not next_promise then
            return
        end
        if not is_complete(next_promise) then
            break
        end
        next_promise = complete_promise(next_promise)
    end
    next_promise.result = p.result
    return repeat_resolve(next_promise)
end
local function failed_resolve(p, data)
    assert(p.state_ == PENDING)
    p.state_ = REJECTED
    p.result = handle_next_failed_func(p, data)
    repeat_resolve(p)
    return p
end
local function resolve(p, data)
    assert(p.state_ == PENDING)
    p.state_ = RESOLVED
    p.result = data
    repeat_resolve(p)
    return p
end
local function clear_promise(p)
    p.thens = {}
    p.dones = {}
    p.fails = {}
    p.always_ = {}
    p.next_promises = {}
end
-- 因为某种原因取消了promise对象
local function cancel_promise(p)
    clear_promise(p)
end
local function ignore_error(p)
    p.ignore_error = true
end
function promise.new(data)
    local r = {}
    setmetatable(r, promise)
    r:ctor(data)
    return r
end
function promise:ctor(resolver)
    self.ignore_error = false
    self.state_ = PENDING
    clear_promise(self)
    self:next(resolver or empty_func)
end
function promise:state()
    return self.state_
end
function promise:resolve(data)
    return resolve(self, data)
end
function promise:next(success_func, failed_func)
    assert(type(success_func) == "function", "必须要有成功处理函数,如果不想要,请调用catch(func(err)end)")
    assert(self.state_ == PENDING, "暂不支持完成之后再次添加任务!")
    table.insert(self.thens, {success_func, failed_func})
    return self
end
function promise:catch(func)
    assert(type(func) == "function")
    self:next(empty_func, function(err)
        return func(err)
    end)
    return self
end
function promise:done(func)
    assert(type(func) == "function", "done的函数不能为空!")
    table.insert(self.dones, func)
    return self
end
function promise:fail(func)
    assert(type(func) == "function", "fail的函数不能为空!")
    table.insert(self.fails, func)
    return self
end
function promise:always(func)
    assert(type(func) == "function", "always的函数不能为空!")
    table.insert(self.always_, func)
    return self
end
function promise.reject(...)
    error(err_class.new(...))
end
local function foreach_promise(func, ...)
    assert(type(func) == "function")
    local p = promise.new()
    local promises = {...}
    for i, v in ipairs(promises) do
        local other_promises = {}
        for _, ov in ipairs(promises) do
            if ov ~= v then
                table.insert(other_promises, ov)
            end
        end
        ignore_error(v)
        func(i, v, p, other_promises)
    end
    return p
end
function promise.all(...)
    assert(...)
    local task_count = #{...}
    local count = 0
    local results = {}
    local not_resolved = true
    return foreach_promise(function(i, v, p)
        v:always(function(result)
            if not_resolved then
                if is_error(result) then
                    not_resolved = false
                    failed_resolve(p, result)
                end
                results[i] = result
                count = count + 1
                if task_count == count then
                    p:resolve(results)
                end
            end
        end)
    end, ...)
end
function promise.any(...)
    assert(...)
    local not_resolved = true
    return foreach_promise(function(_, v, p, other_promises)
        v:always(function(result)
            if not_resolved then
                not_resolved = false
                if is_error(result) then
                    failed_resolve(p, result)
                else
                    p:resolve(result)
                end
                for _, v in ipairs(other_promises) do
                    cancel_promise(v)
                end
            end
        end)
    end, ...)
end
-- 一个完成的promise不管结果都会发送给下一个任务
function promise.race(...)
    assert(...)
    local not_resolved = true
    return foreach_promise(function(_, v, p, other_promises)
        v:always(function(result)
            if not_resolved then
                not_resolved = false
                p:resolve(result)
                for _, v in ipairs(other_promises) do
                    cancel_promise(v)
                end
            end
        end)
    end, ...)
end
function promise.isError(obj)
    return is_error(obj)
end



return promise



















































