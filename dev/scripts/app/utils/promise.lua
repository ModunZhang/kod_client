local promise = {}
promise.__index = promise
local function is_promise(obj)
    return getmetatable(obj) == promise
end
local function pop_head(array)
    assert(type(array) == "table")
    return table.remove(array, 1)
end
function promise.new(...)
    local r = {}
    setmetatable(r, promise)
    r:ctor(...)
    return r
end
function promise:ctor(resolver)
    self.state_ = "pending"
    self.thens = {}
    self.catches = {}
    self:next(resolver)
end
function promise:state()
    return self.state_
end
function promise:resolve(...)
    assert(self.state_ == "pending")
    self.state_ = "resolved"
    local thens = self.thens
    local result = ...
    repeat
        local event, func = unpack(pop_head(thens))
        local status, next_result
        if type(func) == "function" then
            status, next_result = pcall(func, result)
            if not status then
                dump(next_result)
                return
            end
        end
        if is_promise(next_result) then
            for _, v in ipairs(thens) do
                table.insert(next_result.thens, v)
            end
            thens = {}
            return self
        else
            result = next_result
        end
    until #thens == 0
    return self
end
function promise:next(next_func)
    table.insert(self.thens, {"then", next_func})
    return self
end
function promise:reject()
    self.state_ = "rejected"
    return "reason"
end
function promise:catch(e)
    dump(e)
    return self
end




return promise


