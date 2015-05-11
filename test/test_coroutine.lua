local Game = require("Game")
-- function send(x)
--     coroutine.yield(x)
-- end
-- function receive(prod)
--     local status, value = coroutine.resume(prod)
--     return value
-- end
-- function producer()
--     return coroutine.create(function()
--         while true do
--             local x = io.read()
--             send(x)
--         end
--     end)
-- end
-- function filter(prod)
--     return coroutine.create(function()
--         while true do
--             local x = receive(prod)
--             x = string.format("%5d %s", 1, x)
--             send(x)
--         end
--     end)
-- end
-- function consumer(prod)
--     while true do
--         local x = receive(prod)
--         io.write(x, "\n")
--         -- assert(false)
--     end
-- end
-- consumer(filter(producer()))

-- function printResult(a)
--     for i = 1, #a do
--         io.write(a[i], " ")
--     end
--     io.write("\n")
-- end
-- function permgen(a, n)
--     n = n or #a
--     if n <= 1 then
--         coroutine.yield(a)
--     else
--         for i = 1, n do
--             a[n], a[i] = a[i], a[n]
--             permgen(a, n - 1)
--             a[n], a[i] = a[i], a[n]
--         end
--     end
-- end
-- function permutations(a)
--     local co = coroutine.create(function() permgen(a) end)
--     return function()
--         local code, res = coroutine.resume(co)
--         return res
--     end
-- end

-- for p in permutations{1, 2, 3, 4, 5, 6, 7, 8} do
--     printResult(p)
-- end


-- require "socket"
-- host = "www.w3.org"
-- file = "/TR/REC-html32.html"
-- c = assert(socket.connect(host, 80))
-- c:send("GET" .. file .. " HTTP/1.0\r\n\r\n")
-- while true do
--     local s, status, partial = c:receive(2^10)
--     io.write(s or partial)
--     if status == "closed" then break end
-- end
-- c:close()


-- function download(host, file)


--[[
local socket = require("socket")
local host = "www.baidu.com"
local file = "/"
-- 创建一个 TCP 连接，连接到 HTTP 连接的标准端口 -- 80 端口上
local sock = assert(socket.connect(host, 80))
sock:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
repeat
    -- 以 1K 的字节块来接收数据，并把接收到字节块输出来
    local chunk, status, partial = sock:receive(1024)
    print(chunk or partial)
until status ~= "closed"
-- 关闭 TCP 连接
sock:close()
--]]

--[[
local http = require("socket.http")
local response = http.request("http://www.baidu.com/")
print(response)
--]]





-- for_ = coroutine.create(function(arg)
--  print(arg)
--  while true do
--      local index, is_loop_end = coroutine.yield()
--      print(index)
--      if is_loop_end then
--          break
--      end
--  end
-- end)

-- for i = 1, 100 do
--  coroutine.resume(for_, i, i == 100)
-- end

-- for k, v in pairs(coroutine) do
--  print(k, v)
-- end

-- coroutine.wrap(function(arg)
--  print(arg)
--  while true do
--      local index = coroutine.yield()
--      print(index)
--  end
-- end)

-- print("status", coroutine.status(for_))
-- print("resume", coroutine.resume(for_, 1))
-- print("status", coroutine.status(for_))
-- print("resume", coroutine.resume(for_, 2))
-- print("status", coroutine.status(for_))
-- print("resume", coroutine.resume(for_, 1))

local function zip(...)
    local t = {...}
    local val = {}
    local cur_i = 1
    return function()
        if cur_i > #t[1] then return nil end
        for index, v in ipairs(t) do
            val[index] = v[cur_i]
        end
        cur_i = cur_i + 1
        return cur_i - 1, unpack(val)
    end
end

local function kjoin(...)
    local t = {...}
    local val = {}
    local cur_i = 1
    return function()
        -- if cur_i > #t[1] then return nil end
        for k, v in pairs(t) do
            val[index] = v[cur_i]
        end
        cur_i = cur_i + 1
        return cur_i - 1, unpack(val)
    end
end

local function cat(...)
    local t = {...}
    local cursor = 1
    return function()
        local len = 0
        for _,v in ipairs(t) do
            if cursor < len + #v then
                next(v, cursor - len)
                cursor = cursor + 1
            else
                len = len + #v
            end
        end
        return cursor, v
    end
end

for i, v in ipairs({1,2,3,4}) do
    print(i, v)
end
-- print(next)
a = {1, 2, 3, 4}
-- print(next(a))
-- print(next(a, 3))
-- for i,v in next(a) do
--     print(i,v)
-- end
-- for i,v in cat({1, 2, 3, 4}, {1,1, 2, 3}, {1, 2, 3, 4}) do
--     print(i, v)
-- end

-- for i, v1, v2, v3 in zip({1, 2, 3, 4}, {1,1, 2, 3}, {1, 2, 3, 4}) do
--  print(i, v1, v2, v3)
-- end
local Localize = import("app.utils.Localize")
local m = {
    __add = function(a, b)
        local r = {}
        for _, v in ipairs(a) do
            r[v.type] = v
        end
        for _, v in ipairs(b) do
            local av = r[v.type]
            if av then
                av.count = av.count + v.count
            else
                r[v.type] = v
            end
        end
        local r1 = {}
        for _, v in pairs(r) do
            r1[#r1 + 1] = v
        end
        setmetatable(r1, getmetatable(a))
        return r1
    end,
    __tostring = function(a)
        return table.concat(LuaUtils:table_map(a, function(k, v)
            local txt
            if v.type == "items" then
                txt = string.format("%s x%d", Localize_item.item_name[v.name], v.count)
            elseif v.type == "resources" then
                txt = string.format("%s x%d", Localize.fight_reward[v.name], v.count)
            end
            return k, txt
        end), ",")
    end,
    __concat = function(a, b)
        return string.format("%s%s", tostring(a), tostring(b))
    end,
}
local r = {
    {
        type = "resources",
        name = "wood",
        count = 1000
    }
}
local r2 = {
    {
        type = "resources",
        name = "food",
        count = 1000
    }
}
setmetatable(r, m)
setmetatable(r2, m)
-- print((r + r2).."a")
-- GameUtils:GetSoldierTypeByType("type_")


-- print(string.format("%x", 1))
-- print(string.format("%x", 31))
-- print(string.format("%x", 10))


local BitBaseN = import("app.utils.BitBaseN")


local b = BitBaseN.new(10)
b[1] = true
b[2] = true
b[5] = true
b[6] = true
b[7] = true
b[10] = true
b:decode(b:encode())
assert(b[1] == true)
assert(b[2] == true)
assert(b[5] == true)
assert(b[6] == true)
assert(b[7] == true)
assert(b[10] == true)




local w = 25
function get_index(x, y)
    return x + w * y + 1
end
function get_xy(index)
    return (index - 1) % w, math.floor((index - 1) / w)
end
local bitArr = BitBaseN.new(w * w)
-- bitArr[get_index(0,0)] = true
-- bitArr[bitArr:length()] = true


bitArr[get_index(11, 11)] = true
bitArr[get_index(12, 11)] = true
bitArr[get_index(13, 11)] = true

bitArr[get_index(11, 12)] = true
bitArr[get_index(12, 12)] = true
bitArr[get_index(13, 12)] = true

bitArr[get_index(11, 13)] = true
bitArr[get_index(12, 13)] = true
bitArr[get_index(13, 13)] = true

bitArr[get_index(11, 14)] = true
bitArr[get_index(12, 14)] = true
bitArr[get_index(13, 14)] = true

bitArr[get_index(11, 15)] = true
bitArr[get_index(12, 15)] = true
bitArr[get_index(13, 15)] = true

bitArr:decode(bitArr:encode())

assert(bitArr[get_index(11, 11)] == true)
assert(bitArr[get_index(12, 11)] == true)
assert(bitArr[get_index(13, 11)] == true)

assert(bitArr[get_index(11, 12)] == true)
assert(bitArr[get_index(12, 12)] == true)
assert(bitArr[get_index(13, 12)] == true)

assert(bitArr[get_index(11, 13)] == true)
assert(bitArr[get_index(12, 13)] == true)
assert(bitArr[get_index(13, 13)] == true)

assert(bitArr[get_index(11, 14)] == true)
assert(bitArr[get_index(12, 14)] == true)
assert(bitArr[get_index(13, 14)] == true)

assert(bitArr[get_index(11, 15)] == true)
assert(bitArr[get_index(12, 15)] == true)
assert(bitArr[get_index(13, 15)] == true)


-- for i = 1, bitArr:length() do
--     if bitArr[get_index(get_xy(i))] then
--         print(get_index(get_xy(i)), get_xy(i))
--     end
-- end

-- print(bitArr:encode())
-- 11  11  287
-- 11  12  312
-- 11  13  337
-- 12  11  288
-- 12  12  313
-- 12  13  338
-- 13  11  289
-- 13  12  314
-- 13  13  339
-- 11  14  362
-- 12  14  363
-- 13  14  364

-- local function hexToBinary(h)
--     h = string.upper(h)
-- end

-- a = {1,2,3,4,5}
-- b = {6,7,8,9,10}

-- dump({unpack(a), unpack(b)})


m = {}
m.__add = function(...) print("add","+",...) end
m.__sub = function(...) print("sub","-",...) end
m.__mul = function(...) print("mul","*",...) end
m.__div = function(...) print("div","/",...) end
m.__mod = function(...) print("mod","%",...) end
m.__pow = function(...) print("pow","^",...) end
m.__unm = function(...) print("unm","-",...) end
m.__concat = function(...) print("concat","..",...) end
m.__len = function(...) print("len","#",...) end --only func on obj is not string or table
m.__eq = function(...) print("eq","==",...) end
m.__lt = function(...) print("lt","<",...) end
m.__le = function(...) print("le","<=",...) end
m.__index = function(...) print("index",...) end
m.__newindex = function(...) print("newindex",...) end
m.__call = function(...) print("call","()",...) end


o = {1,2}
o2 = {}
setmetatable(o,m)
setmetatable(o2,m)
-- t=o+1
-- t=o-2
-- t=o*3
-- t=o/4
-- t=o%5
-- t=o^6
-- t=-o
-- t=o..8
t=#o --cause o is table,__len not be used
-- t=(o==o2) --must same type and can not be number or string
-- t=(o<o2)
-- t=(o<=o2)
-- t=o[9]
-- o[10] = 10
-- t=o(11)



-- local function clamp(a,b,x)
--     return x < a and a or (x > b and b or x)
-- end
-- print(clamp(1,2,1))



-- local NotifyItem = import("app.entity.NotifyItem")

-- print(NotifyItem.new({type = "resources", name = "food", count = 100}) -
--     NotifyItem.new({type = "resources", name = "food", count = 99}))

-- print(NotifyItem.new({type = "resources", name = "food", count = 100}, {type = "resources", name = "food", count = 100}) -
--     NotifyItem.new({type = "resources", name = "food", count = 99}))



-- function Utf8to32(utf8str)
--     assert(type(utf8str) == "string")
--     local res, seq, val = {}, 0, nil
--     for i = 1, #utf8str do
--         local c = string.byte(utf8str, i)
--         if seq == 0 then
--             table.insert(res, val)
--             seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
--                   c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
--                   error("invalid UTF-8 character sequence")
--             val = bit32.band(c, 2^(8-seq) - 1)
--         else
--             val = bit32.bor(bit32.lshift(val, 6), bit32.band(c, 0x3F))
--         end
--         seq = seq - 1
--     end
--     table.insert(res, val)
--     table.insert(res, 0)
--     return res
-- end


-- print(Utf8to32("你"))


local m = {}
m.__index = m

function m:hello()
    print("hello", self.b)
end

local a = {
    b = 1
}

setmetatable(a, m)


-- a:hello()



-- local memberMeta = import("app.entity.memberMeta")


-- local t = memberMeta:DecodeFromJson({
--     id = 1
--     })


a = {
    [1] = {
        [1] = "resources",
        [2] = {
            ["stone"] = 73400,
            ["cart"] = 0,
            ["coin"] = 50000,
            ["food"] = 25000,
            ["citizen"] = 0,
            ["casinoToken"] = 5000,
            ["refreshTime"] = 1426561853895,
            ["gem"] = 655,
            ["iron"] = 73400,
            ["stamina"] = 100,
            ["wood"] = 73400,
            ["wallHp"] = 1000,
            ["blood"] = 1000,
        }
    ,
    }
    ,
    [2] = {
        [1] = "buildingMaterials",
        [2] = {
            ["tools"] = 1000,
            ["blueprints"] = 1000,
            ["tiles"] = 1000,
            ["pulley"] = 1000,
        }
    ,
    }
    ,
    [3] = {
        [1] = "buildings.location_4.level",
        [2] = 2,
    }
    ,
    [4] = {
        [1] = "basicInfo.power",
        [2] = 430,
    }
    ,
    [5] = {
        [1] = "growUpTasks.cityBuild.5",
        [2] = {
            ["id"] = 117,
            ["rewarded"] = false,
            ["index"] = 1,
            ["name"] = "dragonEyrie",
        }
    ,
    }
,
}

b = {
    ["technologyMaterials"] = {
        ["bowTarget"] = 1000,
        ["ironPart"] = 1000,
        ["saddle"] = 1000,
        ["trainingFigure"] = 1000,
    }
    ,
    ["dailyQuestEvents"] = {
    }
    ,
    ["soldierStarEvents"] = {
    }
    ,
    ["mailStatus"] = {
        ["unreadReports"] = 0,
        ["unreadMails"] = 0,
    }
    ,
    ["sendMails"] = {
    }
    ,
    ["userId"] = "m1-PHNaFY",
    ["dailyTasks"] = {
        ["brotherClub"] = {
        }
        ,
        ["growUp"] = {
        }
        ,
        ["empireRise"] = {
            [1] = 1,
        }
        ,
        ["conqueror"] = {
        }
        ,
        ["rewarded"] = {
        }
    ,
    }
    ,
    ["serverId"] = "World-1",
    ["helpToTroops"] = {
    }
    ,
    ["savedMails"] = {
    }
    ,
    ["selected"] = true,
    ["reports"] = {
    }
    ,
    ["savedReports"] = {
    }
    ,
    ["_id"] = "7kewSNTtF",
    ["soldierEvents"] = {
    }
    ,
    ["dragonDeathEvents"] = {
    }
    ,
    ["isActive"] = true,
    ["deviceId"] = "932499284",
    ["items"] = {
    }
    ,
    ["alliance"] = {
    }
    ,
    ["dragonEquipmentEvents"] = {
    }
    ,
    ["logicServerId"] = "logic-server-4",
    ["serverTime"] = 1426561839375,
    ["dragonEquipments"] = {
        ["greenArmguard_s4"] = 0,
        ["blueOrd_s3"] = 0,
        ["redOrd_s3"] = 0,
        ["greenChest_s4"] = 0,
        ["blueArmguard_s4"] = 0,
        ["greenChest_s2"] = 0,
        ["blueCrown_s3"] = 0,
        ["greenOrd_s3"] = 0,
        ["redArmguard_s1"] = 0,
        ["blueChest_s5"] = 0,
        ["redOrd_s4"] = 0,
        ["blueOrd_s5"] = 0,
        ["redCrown_s5"] = 0,
        ["redCrown_s1"] = 0,
        ["blueArmguard_s2"] = 0,
        ["greenCrown_s1"] = 0,
        ["greenCrown_s4"] = 0,
        ["redOrd_s5"] = 0,
        ["blueChest_s4"] = 0,
        ["redOrd_s2"] = 0,
        ["redSting_s4"] = 0,
        ["redChest_s2"] = 0,
        ["blueChest_s2"] = 0,
        ["greenSting_s2"] = 0,
        ["blueArmguard_s3"] = 0,
        ["greenChest_s3"] = 0,
        ["blueCrown_s1"] = 0,
        ["redCrown_s3"] = 0,
        ["greenArmguard_s5"] = 0,
        ["blueSting_s5"] = 0,
        ["redSting_s5"] = 0,
        ["greenArmguard_s2"] = 0,
        ["greenSting_s3"] = 0,
        ["greenOrd_s5"] = 0,
        ["redArmguard_s4"] = 0,
        ["redChest_s4"] = 0,
        ["blueCrown_s2"] = 0,
        ["blueCrown_s5"] = 0,
        ["blueSting_s4"] = 0,
        ["redArmguard_s3"] = 0,
        ["blueCrown_s4"] = 0,
        ["redChest_s3"] = 0,
        ["greenArmguard_s1"] = 0,
        ["redCrown_s2"] = 0,
        ["greenChest_s5"] = 0,
        ["blueSting_s2"] = 0,
        ["blueOrd_s2"] = 0,
        ["greenCrown_s2"] = 0,
        ["greenOrd_s2"] = 0,
        ["redArmguard_s2"] = 0,
        ["greenCrown_s3"] = 0,
        ["redSting_s2"] = 0,
        ["redArmguard_s5"] = 0,
        ["blueSting_s3"] = 0,
        ["redCrown_s4"] = 0,
        ["greenOrd_s4"] = 0,
        ["blueOrd_s4"] = 0,
        ["redSting_s3"] = 0,
        ["greenSting_s4"] = 0,
        ["greenCrown_s5"] = 0,
        ["blueArmguard_s1"] = 0,
        ["greenArmguard_s3"] = 0,
        ["blueChest_s3"] = 0,
        ["redChest_s5"] = 0,
        ["blueArmguard_s5"] = 0,
        ["greenSting_s5"] = 0,
    }
    ,
    ["itemEvents"] = {
    }
    ,
    ["helpedByTroops"] = {
    }
    ,
    ["basicInfo"] = {
        ["kill"] = 0,
        ["power"] = 420,
        ["terrain"] = "grassLand",
        ["levelExp"] = 0,
        ["strikeWin"] = 0,
        ["attackWin"] = 0,
        ["cityName"] = "city_XyDSVpFF",
        ["marchQueue"] = 1,
        ["icon"] = "playerIcon_default.png",
        ["vipExp"] = 100,
        ["buildQueue"] = 1,
        ["language"] = "cn",
        ["name"] = "player_XyDSVpFF",
    }
    ,
    ["inviteToAllianceEvents"] = {
    }
    ,
    ["woundedSoldiers"] = {
        ["swordsman"] = 0,
        ["crossbowman"] = 0,
        ["lancer"] = 0,
        ["sentinel"] = 0,
        ["ballista"] = 0,
        ["ranger"] = 0,
        ["catapult"] = 0,
        ["horseArcher"] = 0,
    }
    ,
    ["pve"] = {
        ["location"] = {
            ["y"] = 12,
            ["x"] = 12,
            ["z"] = 1,
        }
        ,
        ["floors"] = {
        }
        ,
        ["totalStep"] = 0,
    }
    ,
    ["resources"] = {
        ["stone"] = 65120,
        ["cart"] = 0,
        ["coin"] = 50000,
        ["food"] = 25000,
        ["citizen"] = 0,
        ["casinoToken"] = 5000,
        ["refreshTime"] = 1426561839343,
        ["gem"] = 790,
        ["iron"] = 65120,
        ["stamina"] = 100,
        ["wood"] = 65120,
        ["wallHp"] = 1000,
        ["blood"] = 1000,
    }
    ,
    ["dragons"] = {
        ["blueDragon"] = {
            ["equipments"] = {
                ["chest"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["armguardRight"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["armguardLeft"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["sting"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["orb"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["crown"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
            ,
            }
            ,
            ["exp"] = 0,
            ["hp"] = 0,
            ["hpRefreshTime"] = 1426561839344,
            ["level"] = 0,
            ["status"] = "free",
            ["skills"] = {
                ["skill_3"] = {
                    ["name"] = "dragonBlood",
                    ["level"] = 0,
                }
                ,
                ["skill_4"] = {
                    ["name"] = "cavalryEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_2"] = {
                    ["name"] = "archerEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_7"] = {
                    ["name"] = "leadership",
                    ["level"] = 0,
                }
                ,
                ["skill_9"] = {
                    ["name"] = "insensitive",
                    ["level"] = 0,
                }
                ,
                ["skill_5"] = {
                    ["name"] = "siegeEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_8"] = {
                    ["name"] = "recover",
                    ["level"] = 0,
                }
                ,
                ["skill_1"] = {
                    ["name"] = "infantryEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_6"] = {
                    ["name"] = "dragonBreath",
                    ["level"] = 0,
                }
            ,
            }
            ,
            ["star"] = 0,
            ["type"] = "blueDragon",
        }
        ,
        ["redDragon"] = {
            ["equipments"] = {
                ["chest"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["armguardRight"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["armguardLeft"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["sting"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["orb"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["crown"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
            ,
            }
            ,
            ["exp"] = 0,
            ["hp"] = 0,
            ["hpRefreshTime"] = 1426561839344,
            ["level"] = 0,
            ["status"] = "free",
            ["skills"] = {
                ["skill_3"] = {
                    ["name"] = "dragonBlood",
                    ["level"] = 0,
                }
                ,
                ["skill_4"] = {
                    ["name"] = "cavalryEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_2"] = {
                    ["name"] = "archerEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_7"] = {
                    ["name"] = "leadership",
                    ["level"] = 0,
                }
                ,
                ["skill_9"] = {
                    ["name"] = "frenzied",
                    ["level"] = 0,
                }
                ,
                ["skill_5"] = {
                    ["name"] = "siegeEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_8"] = {
                    ["name"] = "greedy",
                    ["level"] = 0,
                }
                ,
                ["skill_1"] = {
                    ["name"] = "infantryEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_6"] = {
                    ["name"] = "dragonBreath",
                    ["level"] = 0,
                }
            ,
            }
            ,
            ["star"] = 0,
            ["type"] = "redDragon",
        }
        ,
        ["greenDragon"] = {
            ["equipments"] = {
                ["chest"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["armguardRight"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["armguardLeft"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["sting"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["orb"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
                ,
                ["crown"] = {
                    ["star"] = 0,
                    ["buffs"] = {
                    }
                    ,
                    ["name"] = "",
                    ["exp"] = 0,
                }
            ,
            }
            ,
            ["exp"] = 0,
            ["hp"] = 0,
            ["hpRefreshTime"] = 1426561839344,
            ["level"] = 0,
            ["status"] = "free",
            ["skills"] = {
                ["skill_3"] = {
                    ["name"] = "dragonBlood",
                    ["level"] = 0,
                }
                ,
                ["skill_4"] = {
                    ["name"] = "cavalryEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_2"] = {
                    ["name"] = "archerEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_7"] = {
                    ["name"] = "leadership",
                    ["level"] = 0,
                }
                ,
                ["skill_9"] = {
                    ["name"] = "battleHunger",
                    ["level"] = 0,
                }
                ,
                ["skill_5"] = {
                    ["name"] = "siegeEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_8"] = {
                    ["name"] = "earthquake",
                    ["level"] = 0,
                }
                ,
                ["skill_1"] = {
                    ["name"] = "infantryEnhance",
                    ["level"] = 0,
                }
                ,
                ["skill_6"] = {
                    ["name"] = "dragonBreath",
                    ["level"] = 0,
                }
            ,
            }
            ,
            ["star"] = 0,
            ["type"] = "greenDragon",
        }
    ,
    }
    ,
    ["dragonHatchEvents"] = {
    }
    ,
    ["vipEvents"] = {
        [1] = {
            ["id"] = "QkzvHV6FF",
            ["startTime"] = 1426561793967,
            ["finishTime"] = 1426648193967,
        }
    ,
    }
    ,
    ["buildings"] = {
        ["location_14"] = {
            ["location"] = 14,
            ["type"] = "townHall",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_22"] = {
            ["location"] = 22,
            ["type"] = "tower",
            ["level"] = 1,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_12"] = {
            ["location"] = 12,
            ["type"] = "lumbermill",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_17"] = {
            ["location"] = 17,
            ["type"] = "workshop",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_20"] = {
            ["location"] = 20,
            ["type"] = "stable",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_18"] = {
            ["location"] = 18,
            ["type"] = "trainingGround",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_21"] = {
            ["location"] = 21,
            ["type"] = "wall",
            ["level"] = 1,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_1"] = {
            ["location"] = 1,
            ["type"] = "keep",
            ["level"] = 5,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_13"] = {
            ["location"] = 13,
            ["type"] = "mill",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_4"] = {
            ["location"] = 4,
            ["type"] = "dragonEyrie",
            ["level"] = 1,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_7"] = {
            ["location"] = 7,
            ["type"] = "academy",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_15"] = {
            ["location"] = 15,
            ["type"] = "toolShop",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_2"] = {
            ["location"] = 2,
            ["type"] = "watchTower",
            ["level"] = 1,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_9"] = {
            ["location"] = 9,
            ["type"] = "blackSmith",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_16"] = {
            ["location"] = 16,
            ["type"] = "tradeGuild",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_19"] = {
            ["location"] = 19,
            ["type"] = "hunterHall",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_3"] = {
            ["location"] = 3,
            ["type"] = "warehouse",
            ["level"] = 2,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_5"] = {
            ["location"] = 5,
            ["type"] = "barracks",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_6"] = {
            ["location"] = 6,
            ["type"] = "hospital",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_11"] = {
            ["location"] = 11,
            ["type"] = "stoneMason",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_8"] = {
            ["location"] = 8,
            ["type"] = "materialDepot",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
        ,
        ["location_10"] = {
            ["location"] = 10,
            ["type"] = "foundry",
            ["level"] = 0,
            ["houses"] = {
            }
        ,
        }
    ,
    }
    ,
    ["productionTechs"] = {
        ["negotiation"] = {
            ["index"] = 12,
            ["level"] = 0,
        }
        ,
        ["cropResearch"] = {
            ["index"] = 6,
            ["level"] = 0,
        }
        ,
        ["healingAgent"] = {
            ["index"] = 16,
            ["level"] = 0,
        }
        ,
        ["seniorTower"] = {
            ["index"] = 8,
            ["level"] = 0,
        }
        ,
        ["reinforcing"] = {
            ["index"] = 7,
            ["level"] = 0,
        }
        ,
        ["stoneCarving"] = {
            ["index"] = 2,
            ["level"] = 0,
        }
        ,
        ["logistics"] = {
            ["index"] = 15,
            ["level"] = 0,
        }
        ,
        ["forestation"] = {
            ["index"] = 3,
            ["level"] = 0,
        }
        ,
        ["colonization"] = {
            ["index"] = 11,
            ["level"] = 0,
        }
        ,
        ["beerSupply"] = {
            ["index"] = 9,
            ["level"] = 0,
        }
        ,
        ["crane"] = {
            ["index"] = 1,
            ["level"] = 0,
        }
        ,
        ["trap"] = {
            ["index"] = 13,
            ["level"] = 0,
        }
        ,
        ["sketching"] = {
            ["index"] = 17,
            ["level"] = 0,
        }
        ,
        ["hideout"] = {
            ["index"] = 14,
            ["level"] = 0,
        }
        ,
        ["ironSmelting"] = {
            ["index"] = 5,
            ["level"] = 0,
        }
        ,
        ["fastFix"] = {
            ["index"] = 4,
            ["level"] = 0,
        }
        ,
        ["mintedCoin"] = {
            ["index"] = 18,
            ["level"] = 0,
        }
        ,
        ["rescueTent"] = {
            ["index"] = 10,
            ["level"] = 0,
        }
    ,
    }
    ,
    ["militaryTechEvents"] = {
    }
    ,
    ["allianceInfo"] = {
        ["foodExp"] = 0,
        ["coinExp"] = 0,
        ["loyalty"] = 0,
        ["stoneExp"] = 0,
        ["woodExp"] = 0,
        ["ironExp"] = 0,
    }
    ,
    ["treatSoldierEvents"] = {
    }
    ,
    ["dragonMaterials"] = {
        ["ingo_4"] = 1000,
        ["blueSoul_3"] = 1000,
        ["redCrystal_4"] = 1000,
        ["blueCrystal_4"] = 1000,
        ["greenCrystal_1"] = 1000,
        ["ingo_1"] = 1000,
        ["redCrystal_3"] = 1000,
        ["greenCrystal_4"] = 1000,
        ["ingo_2"] = 1000,
        ["blueCrystal_3"] = 1000,
        ["blueSoul_2"] = 1000,
        ["greenCrystal_2"] = 1000,
        ["redSoul_4"] = 1000,
        ["greenSoul_3"] = 1000,
        ["ingo_3"] = 1000,
        ["redCrystal_1"] = 1000,
        ["greenSoul_2"] = 1000,
        ["redCrystal_2"] = 1000,
        ["greenCrystal_3"] = 1000,
        ["blueSoul_4"] = 1000,
        ["runes_2"] = 1000,
        ["blueCrystal_2"] = 1000,
        ["greenSoul_4"] = 1000,
        ["runes_4"] = 1000,
        ["blueCrystal_1"] = 1000,
        ["runes_3"] = 1000,
        ["runes_1"] = 1000,
        ["redSoul_3"] = 1000,
        ["redSoul_2"] = 1000,
    }
    ,
    ["buildingEvents"] = {
    }
    ,
    ["growUpTasks"] = {
        ["militaryTech"] = {
        }
        ,
        ["soldierStar"] = {
        }
        ,
        ["pveCount"] = {
        }
        ,
        ["strikeWin"] = {
        }
        ,
        ["dragonLevel"] = {
        }
        ,
        ["dragonStar"] = {
        }
        ,
        ["attackWin"] = {
        }
        ,
        ["dragonSkill"] = {
        }
        ,
        ["productionTech"] = {
        }
        ,
        ["playerPower"] = {
        }
        ,
        ["playerKill"] = {
        }
        ,
        ["cityBuild"] = {
            [1] = {
                ["id"] = 0,
                ["rewarded"] = false,
                ["index"] = 1,
                ["name"] = "keep",
            }
            ,
            [2] = {
                ["id"] = 1,
                ["rewarded"] = false,
                ["index"] = 2,
                ["name"] = "keep",
            }
            ,
            [3] = {
                ["id"] = 2,
                ["rewarded"] = false,
                ["index"] = 3,
                ["name"] = "keep",
            }
            ,
            [4] = {
                ["id"] = 3,
                ["rewarded"] = false,
                ["index"] = 4,
                ["name"] = "keep",
            }
            ,
            [5] = {
                ["id"] = 78,
                ["rewarded"] = false,
                ["index"] = 1,
                ["name"] = "warehouse",
            }
        ,
        }
        ,
        ["soldierCount"] = {
        }
    ,
    }
    ,
    ["productionTechEvents"] = {
    }
    ,
    ["requestToAllianceEvents"] = {
    }
    ,
    ["dailyQuests"] = {
        ["quests"] = {
        }
        ,
        ["refreshTime"] = 0,
    }
    ,
    ["countInfo"] = {
        ["todayFreeNormalGachaCount"] = 0,
        ["day14"] = 1,
        ["day60RewardsCount"] = 0,
        ["lastLoginTime"] = 1426561839340,
        ["registerTime"] = 1426557559957,
        ["day60"] = 1,
        ["todayOnLineTimeRewards"] = {
        }
        ,
        ["day14RewardsCount"] = 0,
        ["gemUsed"] = 0,
        ["iapCount"] = 0,
        ["todayOnLineTime"] = 2872244,
        ["levelupRewards"] = {
        }
        ,
        ["isFirstIAPRewardsGeted"] = false,
        ["vipLoginDaysCount"] = 1,
        ["loginCount"] = 19,
    }
    ,
    ["soldiers"] = {
        ["deathKnight"] = 0,
        ["paladin"] = 0,
        ["meatWagon"] = 0,
        ["sentinel"] = 0,
        ["ballista"] = 0,
        ["swordsman"] = 0,
        ["horseArcher"] = 0,
        ["demonHunter"] = 0,
        ["crossbowman"] = 0,
        ["skeletonArcher"] = 0,
        ["lancer"] = 0,
        ["skeletonWarrior"] = 0,
        ["priest"] = 0,
        ["ranger"] = 0,
        ["catapult"] = 0,
        ["steamTank"] = 0,
    }
    ,
    ["soldierStars"] = {
        ["swordsman"] = 1,
        ["crossbowman"] = 1,
        ["lancer"] = 1,
        ["sentinel"] = 1,
        ["ballista"] = 1,
        ["ranger"] = 1,
        ["catapult"] = 1,
        ["horseArcher"] = 1,
    }
    ,
    ["militaryTechs"] = {
        ["siege_cavalry"] = {
            ["building"] = "workshop",
            ["level"] = 0,
        }
        ,
        ["infantry_archer"] = {
            ["building"] = "trainingGround",
            ["level"] = 0,
        }
        ,
        ["cavalry_archer"] = {
            ["building"] = "stable",
            ["level"] = 0,
        }
        ,
        ["cavalry_infantry"] = {
            ["building"] = "stable",
            ["level"] = 0,
        }
        ,
        ["infantry_cavalry"] = {
            ["building"] = "trainingGround",
            ["level"] = 0,
        }
        ,
        ["archer_siege"] = {
            ["building"] = "hunterHall",
            ["level"] = 0,
        }
        ,
        ["archer_infantry"] = {
            ["building"] = "hunterHall",
            ["level"] = 0,
        }
        ,
        ["siege_siege"] = {
            ["building"] = "workshop",
            ["level"] = 0,
        }
        ,
        ["cavalry_cavalry"] = {
            ["building"] = "stable",
            ["level"] = 0,
        }
        ,
        ["infantry_infantry"] = {
            ["building"] = "trainingGround",
            ["level"] = 0,
        }
        ,
        ["archer_cavalry"] = {
            ["building"] = "hunterHall",
            ["level"] = 0,
        }
        ,
        ["archer_archer"] = {
            ["building"] = "hunterHall",
            ["level"] = 0,
        }
        ,
        ["infantry_siege"] = {
            ["building"] = "trainingGround",
            ["level"] = 0,
        }
        ,
        ["siege_infantry"] = {
            ["building"] = "workshop",
            ["level"] = 0,
        }
        ,
        ["cavalry_siege"] = {
            ["building"] = "stable",
            ["level"] = 0,
        }
        ,
        ["siege_archer"] = {
            ["building"] = "workshop",
            ["level"] = 0,
        }
    ,
    }
    ,
    ["houseEvents"] = {
    }
    ,
    ["buildingMaterials"] = {
        ["tools"] = 1000,
        ["blueprints"] = 1000,
        ["tiles"] = 1000,
        ["pulley"] = 1000,
    }
    ,
    ["__v"] = 0,
    ["materialEvents"] = {
    }
    ,
    ["deals"] = {
    }
    ,
    ["soldierMaterials"] = {
        ["heroBones"] = 1000,
        ["holyBook"] = 1000,
        ["brightRing"] = 1000,
        ["soulStone"] = 1000,
        ["brightAlloy"] = 1000,
        ["confessionHood"] = 1000,
        ["deathHand"] = 1000,
        ["magicBox"] = 1000,
    }
    ,
    ["mails"] = {
    }
,
}
local function decode2userData(a)
    for k,v in pairs(a) do

    end
end


-- a = {
--     r = {
--         [1] = 1
--     }
-- }
-- b = {
--     r = {
--         [2] = 2
--     }
-- }

local function recursiveData(data, func)
    for k,v in pairs(data) do
        if type(v) == "table" then
            func(k,v)
            recursiveData(v, func)
        else
            func(k,v)
        end
    end
end
json = {}
json.null = function(v)
    return type(v) == "userdata"
end
local unpack = unpack
local ipairs = ipairs
local table = table
local function decodeInUserDataFromDeltaData(userData, deltaData)
    local edit = {}
    for _,v in ipairs(deltaData) do
        local origin_key,value = unpack(v)
        local is_json_null = value == json.null
        local keys = string.split(origin_key, ".")
        if #keys == 1 then
            local k = unpack(keys)
            k = tonumber(k) or k
            if type(k) == "number" then -- 索引更新
                k = k + 1
                if is_json_null then            -- 认为是删除
                    edit[k].remove = edit[k].remove or {}
                    table.insert(edit[k].remove, userData[k])
                elseif userData[k] then         -- 认为更新
                    edit[k].edit = edit[k].edit or {}
                    table.insert(edit[k].edit, value)
                else                            -- 认为添加
                    edit[k].add = edit[k].add or {}
                    table.insert(edit[k].add, value)
                end
            else -- key更新
                edit[k] = value
            end
            userData[k] = value
        else
            local tmp = edit
            local curRoot = userData
            local len = #keys
            for i = 1,len do
                local v = keys[i]
                local k = tonumber(v) or v
                if type(k) == "number" then k = k + 1 end
                local parent_root = tmp
                if i ~= len then
                    curRoot = curRoot[k]
                    tmp[k] = tmp[k] or {}
                    tmp = tmp[k]
                    assert(curRoot)
                else
                    if type(k) == "number" then
                        if is_json_null then
                            tmp.remove = tmp.remove or {}
                            table.insert(tmp.remove, table.remove(curRoot, k))
                        elseif curRoot[k] then
                            tmp.edit = tmp.edit or {}
                            table.insert(tmp.edit, value)
                            curRoot[k] = value
                        else
                            tmp.add = tmp.add or {}
                            table.insert(tmp.add, value)
                            curRoot[k] = value
                        end
                    else
                        tmp[k] = value
                        curRoot[k] = value
                    end
                end
            end
        end
    end
    return edit
end


-- LuaUtils:outputTable("a", decodeInUserDataFromDeltaData(b, a))




-- for k,v in pairs(table) do
--     print(k,v)
-- end


local type = type
local function table_equal(t1, t2)
    if t1 ~= t2 and type(t1) == "table" and type("table") then
        for k,v in pairs(t1) do
            if t2[k] ~= v then
                return false
            end
        end
    end
    return true
end
-- print(table_equal({}, {}))
-- print(table_equal({a = 1}, {a = 1}))


local property = import("app.utils.property")


local A = class("A")
property(A, "id1", 1)
property(A, "id2", 2)
property(A, "id3", 3)
property(A, "id4", {})

local a = A.new()

a:SetId1(11)
a:SetId2(22)
a:SetId3(33)
a:SetId4(44)
print(a:Id1())
print(a:Id2())
print(a:Id3())
print(a:Id4())

property(a, "RESET")


print(a:Id1())
print(a:Id2())
print(a:Id3())
print(a:Id4())




-- for k,v in pairs(string) do
--     print(k,v)
-- end


print(string.gsub("hello, up-down!", "%A", "."))
s = "Deadline is 30/05/1999, firm"
date = "%d%d/%d%d/%d%d%d%d"
print(string.sub(s, string.find(s, date)))
print(string.gsub("a", "%a+", "word | "))


print(string.gsub("a (enclosed (in) parentheses) line",
    "%b()", ""))


-- 1. 替换json里面的null
-- null ->json.null
-- 2. 替换json里面的key
-- (\")(.*)(\")(\s*)(\:) ->$2$4 =
-- 3. 替换json里面的 []
-- (=\s*\[)([\s\w\d{}=,"'|\[]*)(\]\s*,?)  ->= {$2},



a = {11,12,13,4,5,6,7,8,9,10}

    function iter(a, i)
      local v1 = a[i]
      i = i + 1
      local v2 = a[i]
      if v2 then
        return i, v1, v2
      end
    end
    
    function tuple_ipairs (a)
      return iter, a, 0
    end

for i,v1,v2 in tuple_ipairs(a) do
    print(i,v1,v2)
end










