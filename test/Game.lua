require "framework.functions"
require "framework.debug"
require "framework.json"
package.path = package.path .. ";../dev/scripts/?.lua;"
_ = function(txt) return txt end
local _ = import("app.datas.GameDatas")
local _ = import("app.utils.LuaUtils")
local Game = class("Game")
table.foreach = function(t, func)
    for k, v in pairs(t) do
        if func(k, v) then
            return
        end
    end
end
table.foreachi = function(t, func)
    for k, v in ipairs(t) do
        if func(k, v) then
            return
        end
    end
end
function Game:CurrentTime()
    return os.clock() * 1000
end
function Game:Sleep(t)
    local p = self:CurrentTime()
    repeat
    until self:CurrentTime() - p > t * 1000
end
function Game:OnUpdate(func, dt)
    local g_time = 0
    while true do
        if not func(g_time) then
            break
        end
        self:Sleep(dt and dt or 0.001)
        g_time = g_time + 1
    end
end

return Game