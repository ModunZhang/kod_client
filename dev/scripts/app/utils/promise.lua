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
    return unpack(table.remove(array, 1))
end
function promise.new(...)
    local r = {}
    setmetatable(r, promise)
    r:ctor(...)
    return r
end
function promise:ctor(resolver)
    self.state_ = PENDING
    self.thens = {}
    self.dones = {}
    self:next(resolver or empty_func)
end
function promise:state()
    return self.state_
end
function promise:resolve(...)
    assert(self.state_ == PENDING)
    self.state_ = RESOLVED
    local thens = self.thens
    local dones = self.dones
    local result = #{...} > 1 and {...} or ...
    -- dump(result)
    repeat
        repeat
            --------------------------------------------
            -- 弹出任务列表的第一个任务,并执行,捕获到错误后传递给下一个failed_func
            local success_func, failed_func = pop_head(thens)
            local status, next_result, err
            if type(success_func) == "function" then
                status, next_result = pcall(success_func, result)
            end
            -- 如果当前任务没有出现错误,继续传入下一个任务
            if status then
                -- 如果是promise对象
                -- 将主任务列表挂接在子任务列表后面
                -- 将完成列表挂接在子任务列表后面
                if is_promise(next_result) then
                    for _, v in ipairs(thens) do
                        table.insert(next_result.thens, v)
                    end
                    thens = {}

                    for _, v in ipairs(dones) do
                        table.insert(next_result.dones, v)
                    end
                    dones = {}
                    return self
                else
                    -- 传递结果
                    result = next_result
                end
            else
                -- 如果当前任务有错误处理函数,捕获并继续传入下一个任务进行处理
                if type(failed_func) == "function" then
                    self.state_ = REJECTED
                    result = failed_func(next_result)
                    break
                else
                    -- 否则查找下一个最近的错误处理函数,进行处理
                    local _, failed_func
                    repeat
                        _, failed_func = pop_head(thens)
                    until failed_func ~= nil or #thens == 0
                    if type(failed_func) == "function" then
                        result = failed_func(next_result)
                    else
                        assert(false, "你应该捕获这个错误!")
                    end
                end
            end
        until true
    until #thens == 0
    for _, v in ipairs(dones) do
        v(result)
    end
    return self
end
function promise:next(success_func, failed_func)
    assert(type(success_func) == "function", "必须要有成功处理函数,如果不想要,请调用catch(func(err)end)")
    assert(self.state_ == PENDING)
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
function promise.when(...)
    assert(false, "还未实现")
end
function promise.all(...)
    assert(...)
    local p = promise.new()
    local resolve = p.resolve
    p.resolve = nil
    local task_count = #{...}
    local count = 0
    local results = {}
    for i, v in ipairs{...} do
        v:done(function(...)
            results[i] = ...
            count = count + 1
            if task_count == count then
                resolve(p, unpack(results))
            end
        end)
    end
    return p
end




return promise





















