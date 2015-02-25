local Localize_item = import("..utils.Localize_item")
local Localize = import("..utils.Localize")
local function unique_key(item)
    return string.format("%s_%s_%d", item.type, item.name, item.count)
end
local m = {
    __add = function(a, b)
        local r = {}
        for _, v in ipairs(a) do
            r[unique_key(v)] = v
        end
        for _, v in ipairs(b) do
            local av = r[unique_key(v)]
            if av then
                av.count = av.count + v.count
            else
                r[unique_key(v)] = v
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
        end), ", ")
    end,
    __concat = function(a, b)
        return string.format("%s%s", tostring(a), tostring(b))
    end,
}
NotifyItem = {}
function NotifyItem.new(type_, name_, count_)
    assert(type_ and name_ and count_)
    return setmetatable({
        { 
            type = type_,
            name = name_,
            count = count_,
        }
    }, m)
end
return setmetatable(NotifyItem, m)









