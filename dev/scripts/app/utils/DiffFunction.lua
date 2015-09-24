local unpack = unpack
local ipairs = ipairs
local insert = table.insert
local tonumber = tonumber
local split = string.split
local find = string.find
local format = string.format
local gsub = string.gsub
local null = json.null

local deltameta = {
    __call = function(root, indexstr, value)
        if not (find(indexstr, '[^%w_%.]')) then
            for i,key in ipairs(split(indexstr, ".")) do
                if not root then
                    return false
                end
                root = root[key]
            end
            if value then
                return root == value
            end
            return true, root
        end

        local indexarray = split(indexstr, ".")
        local reg = format("^%s", gsub(indexstr or "", "%.", "%%%."))
        local results = {}
        for _,v in ipairs(root.__difftable) do
            if find(v[1], reg) then
                local base = root
                local values = {}
                local count = #indexarray
                for i,key in ipairs(split(v[1], ".")) do
                    local nk = tonumber(key)
                    key = nk == nil and key or nk + 1
                    base = base[key]
                    if nk and not tonumber(indexarray[i]) then
                        insert(values, key)
                    end
                    count = count - 1
                    if count == 0 then 
                        insert(values, base)
                        break
                    end
                end
                insert(results, values)
            end
        end
        if #results > 0 then
            local values = results[1]
            if #results == 1 and #values == 1 and value then
                return values[1] == value
            else
                assert(not value)
                return true, results
            end
        end
    end,
}


return function(base, delta)
    local edit = {}
    for _,v in ipairs(delta) do
        if type(v) == "string" and GameUtils then
            GameUtils:UploadErrors(v)
        end
        local origin_key,value = unpack(v)
        local is_json_null = value == null
        local keys = split(origin_key, ".")
        if #keys == 1 then
            local k = unpack(keys)
            k = tonumber(k) or k
            if type(k) == "number" then -- 索引更新
                k = k + 1
                if is_json_null then            -- 认为是删除
                    edit[k].remove = edit[k].remove or {}
                    insert(edit[k].remove, base[k])
                elseif base[k] then         -- 认为更新
                    edit[k].edit = edit[k].edit or {}
                    insert(edit[k].edit, value)
                else                            -- 认为添加
                    edit[k].add = edit[k].add or {}
                    insert(edit[k].add, value)
                end
            elseif base[k] then
                edit[k] = value
            end
            if base[k] then
                base[k] = value
            end
        else
            local tmp = edit
            local curRoot = base
            local len = #keys
            for i = 1,len do
                local v = keys[i]
                local k = tonumber(v) or v
                if type(k) == "number" then k = k + 1 end
                local parent_root = tmp
                if i ~= len then
                    if type(k) == "number" then
                        tmp.edit = tmp.edit or {}
                        insert(tmp.edit, curRoot[k])
                    elseif not curRoot[k] then
                        break
                    end
                    curRoot[k] = curRoot[k] or {}
                    curRoot = curRoot[k]
                    tmp[k] = tmp[k] or {}
                    tmp = tmp[k]
                else
                    if type(k) == "number" then
                        if is_json_null then
                            tmp.remove = tmp.remove or {}
                            insert(tmp.remove, curRoot[k])
                            table.remove(curRoot, k)
                        elseif curRoot[k] then
                            tmp.edit = tmp.edit or {}
                            insert(tmp.edit, value)
                            curRoot[k] = value
                            tmp[k] = value
                        else
                            tmp.add = tmp.add or {}
                            insert(tmp.add, value)
                            curRoot[k] = value
                            tmp[k] = value
                        end
                    else
                        tmp[k] = value
                        curRoot[k] = value
                    end
                end
            end
        end
    end
    edit.__difftable = delta
    return setmetatable(edit, deltameta)
end



