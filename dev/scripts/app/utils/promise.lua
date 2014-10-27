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
--------------------------------------------
-- 弹出任务列表的第一个任务,并执行,返回错误码和结果
local function do_promise(p)
    local head = pop_head(p.thens)
    local success_func, failed_func = unpack(head or {})
    local success, result
    if type(success_func) == "function" then
        success, result = pcall(success_func, p.result)
    end
    return success, result, failed_func
end
local function next_failed_func(p, error_code)
    local thens = p.thens
    local _, failed_func
    repeat
        local head = pop_head(thens)
        _, failed_func = unpack(head or {})
    until failed_func ~= nil or #thens == 0

    if type(failed_func) == "function" then
        return failed_func(error_code)
    end

    -- 在子任务里面找
    local next_promise = pop_head(p.next_promises)
    if next_promise == nil then
        assert(false, "你应该捕获这个错误!")
    end
    return next_failed_func(next_promise, error_code)
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
        if type(failed_func) == "function" then
            p.result = failed_func(result)
        else
            p.result = next_failed_func(p, result)
        end
    end
end
local function done_promise(p)
    local result = p.result
    table.foreachi(p.dones, function(_, v) v(result) end)
end
local function fail_promise(p)
    table.foreachi(p.fails, function(_, v) v() end)
end
local function always_promise(p)
    table.foreachi(p.always_, function(_, v) v() end)
end
local function complete_promise(p)
    p.full_filled = true
    if p:state() == REJECTED then
        fail_promise(p)
    else
        done_promise(p)
    end
    always_promise(p)
    return pop_head(p.next_promises)
end
local function repeat_resolve(p)
    repeat
        if handle_result(p, do_promise(p)) then
            return p
        end
    until is_complete(p)


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
function promise.new(...)
    local r = {}
    setmetatable(r, promise)
    r:ctor(...)
    return r
end
function promise:ctor(resolver)
    self.full_filled = false
    self.state_ = PENDING
    self.thens = {}
    self.dones = {}
    self.fails = {}
    self.always_ = {}
    self.next_promises = {}
    self:next(resolver or empty_func)
end
function promise:state()
    return self.state_
end
function promise:resolve(...)
    assert(self.state_ == PENDING)
    self.state_ = RESOLVED
    self.result = #{...} > 1 and {...} or ...
    repeat_resolve(self)
    return self
end
function promise:next(success_func, failed_func)
    assert(type(success_func) == "function", "必须要有成功处理函数,如果不想要,请调用catch(func(err)end)")
    assert(self.state_ == PENDING, "暂不支持完成之后再次添加任务!")
    table.insert(self.thens, {success_func, failed_func})
    return self
end
function promise:reject()
    assert(false, "还未实现")
    assert(self.state_ ~= REJECTED)
    self.state_ = REJECTED
    return "reason"
end
function promise:catch(func)
    assert(type(func) == "function")
    self:next(empty_func, function(...)
        return func(...)
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
local function foreach_promise(func, ...)
    assert(type(func) == "function")
    local p = promise.new()
    local resolve = p.resolve
    p.resolve = nil
    for i, v in ipairs{...} do
        func(i, v, p, resolve)
    end
    return p
end
function promise.all(...)
    assert(...)
    local task_count = #{...}
    local count = 0
    local results = {}
    return foreach_promise(function(i, v, p, resolve)
        v:done(function(...)
            results[i] = {...}
            count = count + 1
            if task_count == count then
                resolve(p, unpack(results))
            end
        end)
    end, ...)
end
function promise.any(...)
    assert(...)
    return foreach_promise(function(_, v, p, resolve)
        v:done(function(...)
            resolve(p, ...)
        end)
    end, ...)
end




return promise













































