
local function get_number(c)
    local code = string.byte(c)
    if code <= string.byte('9') then
        return code - string.byte('0')
    elseif code <= string.byte('Z') then
        return code - string.byte('A') + 10
    elseif code <= string.byte('z') then
        return code - string.byte('a') + 36
    else
        return code - string.byte('{') + 62
    end
end
local function get_char(n)
    if n >= 62 then
        return string.char(string.byte('{') + n - 62)
    elseif n >= 36 then
        return string.char(string.byte('a') + n - 36)
    elseif n >= 10 then
        return string.char(string.byte('A') + n - 10)
    else
        return string.char(string.byte('0') + n)
    end
end
local m = {
    __index = function(a, k)
        assert(type(k) == "number")
        local N = rawget(a, "N")
        local index = math.ceil(k / N)
        local c = a.char_arr[index]
        local sub_i = (k-1) % N
        return math.floor(get_number(c) / (2^sub_i)) % 2 == 1
    end,
    __newindex = function(a, k, v)
        assert(type(k) == "number")
        local N = rawget(a, "N")
        local index = math.ceil(k / N)
        local c = a.char_arr[index]
        local sub_i = (k-1) % N
        if v and not a[k] then
            a.char_arr[index] = get_char(get_number(c) + 2^sub_i)
        elseif not v and a[k] then
            a.char_arr[index] = get_char(get_number(c) - 2^sub_i)
        end
    end,
}
local BitBaseN = class("BitBaseN")
function BitBaseN:ctor(len, N)
    assert(len > 0)
    self.len = len
    self.N = N or 6
    local char_arr = {}
    for i = 1, math.ceil(len / self.N) do
        char_arr[i] = '0'
    end
    self.char_arr = char_arr
    function self.length(self)
        return self.len
    end
    function self.encode(self)
        return table.concat(self.char_arr, "")
    end
    function self.decode(self, str)
        if type(str) == "string" then
            local char_arr = self.char_arr
            for i = 1, #char_arr do
                char_arr[i] = string.sub(str, i, i) or "0"
            end
            assert(str == self:encode())
        end
    end
    setmetatable(self, m)
end

-- local m = {}
-- for i = 0, 63 do
--     m[i] = get_char(i)
-- end

-- for i = 0, 63 do
--     print(i, m[i], get_number(m[i]))
--     -- assert(i == get_number(v))
-- end



return BitBaseN

