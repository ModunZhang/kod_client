GameUtils = {

    }
local NORMAL = GameDatas.Soldiers.normal
local SPECIAL = GameDatas.Soldiers.special
local soldier_vs = GameDatas.ClientInitGame.soldier_vs
local pow = math.pow
local ceil = math.ceil
local sqrt = math.sqrt
local floor = math.floor
local round = function(v)
    return floor(v + 0.5)
end
function GameUtils:GetVSFromSoldierName(name1, name2)
    return soldier_vs[self:GetSoldierTypeByName(name1)][self:GetSoldierTypeByName(name2)]
end
function GameUtils:GetSoldierTypeByType(type_)
    for k, v in pairs(NORMAL) do
        if k == type_ then
            return v.type
        end
    end
    for k, v in pairs(SPECIAL) do
        if k == type_ then
            return v.type
        end
    end
end
function GameUtils:GetSoldierTypeByName(name)
    for k, v in pairs(NORMAL) do
        if v.name == name then
            return v.type
        end
    end
    for k, v in pairs(SPECIAL) do
        if v.name == name then
            return v.type
        end
    end
end
function GameUtils:formatTimeStyle1(time)
    local seconds = floor(time) % 60
    time = time / 60
    local minutes = floor(time)% 60
    time = time / 60
    local hours = floor(time)
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function GameUtils:formatTimeStyle2(time)
    return os.date("%Y-%m-%d %H:%M:%S",time)
end

function GameUtils:formatTimeStyle3(time)
    return os.date("%Y/%m/%d/ %H:%M:%S",time)
end

function GameUtils:formatTimeStyle4(time)
    return os.date("%y-%m-%d %H:%M",time)
end
function GameUtils:formatTimeStyle5(time)
    time = time / 60
    local minutes = floor(time)% 60
    time = time / 60
    local hours = floor(time)
    return string.format("%02d:%02d", hours, minutes)
end

function GameUtils:formatNumber(number)
    local num = tonumber(number)
    local r = 0
    local format = "%d"
    if num >= math.pow(10,9) then
        r = num/math.pow(10,9)
        local _,decimals = math.modf(r)
        if decimals ~= 0 then
            format = "%.1fB"
        else
            format = "%dB"
        end
    elseif num >= math.pow(10,6) then
        r = num/math.pow(10,6)
        local _,decimals = math.modf(r)
        if decimals ~= 0 then
            format = "%.1fM"
        else
            format = "%dM"
        end
    elseif num >=  math.pow(10,3) then
        r = num/math.pow(10,3)
        local _,decimals = math.modf(r)
        if decimals ~= 0 then
            format = "%.1fK"
        else
            format = "%dK"
        end
    else
        r = num
    end
    return string.format(format,r)
end

function GameUtils:formatTimeAsTimeAgoStyle( time )
    local timeText = nil
    if(time <= 0) then
        timeText = _("刚刚")
    elseif(time == 1) then
        timeText = _("1秒前")
    elseif(time < 60) then
        timeText = string.format(_("%d秒前"), time)
    elseif(time == 60) then
        timeText = _("1分钟前")
    elseif(time < 3600) then
        time = math.ceil(time / 60)
        timeText = string.format(_("%d分钟前"), time)
    elseif(time == 3600) then
        timeText = _("1小时前")
    elseif(time < 86400) then
        time = math.ceil(time / 3600)
        timeText = string.format(_("%d小时前"), time)
    elseif(time == 86400) then
        timeText = _("1天前")
    else
        time = math.ceil(time / 86400)
        timeText = string.format(_("%d天前"), time)
    end

    return timeText
end

function GameUtils:getUpdatePath(  )
    return device.writablePath .. "update/" .. CONFIG_APP_VERSION .. "/"
end

---------------------------------------------------------- Google Translator
-- text :将要翻译的文本
-- cb :回调函数,有两个参数 function(result,errText) 如果翻译成功 result将返回翻译后的结果errText为nil，如果失败result为nil，errText为错误描述
-- 设置vpn测试！
function GameUtils:Google_Translate(text,cb)
    local params = {
        client="p",
        sl="auto",
        tl=self:ConvertLocaleToGoogleCode(),
        ie="UTF-8",
        oe="UTF-8",
        q=text
    }
    local request = network.createHTTPRequest(function(event)
        local request = event.request
        local eventName = event.name
        if eventName == "completed" then
            if request:getResponseStatusCode() ~= 200 then
                cb(nil,request:getResponseString())
                return
            end
            local content = json.decode(request:getResponseData())
            local r = ""
            if content.sentences and type(content.sentences) == 'table' then
                for _,v in ipairs(content.sentences) do
                    r = r .. v.trans
                end
                print("Google Translator::::::-------------------------------------->",r)
                cb(r,nil)
            else
                cb(nil,"")
            end
        elseif eventName == "progress" then
        else
            cb(nil,eventName)
        end
    end, "http://translate.google.com/translate_a/t", "POST")
    for k,v in pairs(params) do
        local val = string.urlencode(v)
        request:addPOSTValue(k, val)
    end
    request:start()
end

-- https://sites.google.com/site/tomihasa/google-language-codes
function GameUtils:ConvertLocaleToGoogleCode()
    local locale = self:getCurrentLanguage()
    if  locale == 'en_US' then
        return "en"
    elseif locale == 'zh_Hans' then
        return "zh-CN"
    elseif locale == 'pt' then
        return "pt-BR"
    elseif locale == 'zh_Hant' then
        return "zh-TW"
    else
        return locale
    end
end

-----------------------
-- get method
function GameUtils:Baidu_Translate(text,cb)
    local params = {
        from="auto",
        to='zh',
        client_id='FTxAZwkrHChliZjT3g2ZYpHr',
        q=text
    }
    local str = ""
    for k,v in pairs(params) do
        local  val = string.urlencode(v)
        str = str .. k .. "=" .. val .. "&"
    end
    local request = network.createHTTPRequest(function(event)
        local request = event.request
        local eventName = event.name
        if eventName == "completed" then
            if request:getResponseStatusCode() ~= 200 then
                print("Baidu Translator::::::-------------------------------------->StatusCode error!")
                cb(nil,request:getResponseString())
                return
            end
            local content = json.decode(request:getResponseData())
            local r = ""
            if content.trans_result and type(content.trans_result) == 'table' then
                for _,v in ipairs(content.trans_result) do
                    r = r .. v.dst
                end
                print("Baidu Translator::::::-------------------------------------->",r)
                cb(r,nil)
            else
                print("Baidu Translator::::::-------------------------------------->format error!")
                cb(nil,"")
            end
        elseif eventName == "progress" then
        else
            cb(nil,eventName)
        end
    end, "http://openapi.baidu.com/public/2.0/bmt/translate?" .. str, "GET")
    request:setTimeout(10)
    request:start()
end

function GameUtils:ConvertLocaleToBaiduCode()
    --[[
    中文  zh  英语  en
    日语  jp  韩语  kor
    西班牙语    spa 法语  fra
    泰语  th  阿拉伯语    ara
    俄罗斯语    ru  葡萄牙语    pt
    粤语  yue 文言文 wyw
    白话文 zh  自动检测    auto
    德语  de  意大利语    it
    ]]--

    local localCode  = self:getCurrentLanguage()
    if localCode == 'en_US'  or localCode == 'zh_Hant' then
        localCode = 'en'
    elseif localCode == 'zh_Hans' then
        localCode = 'zh'
    elseif localCode == 'fr' then
        localCode = 'fra'
    elseif localCode == 'es' then
        localCode = 'spa'
    elseif localCode == 'ko' then
        localCode = 'kor'
    elseif localCode == 'ja' then
        localCode = 'jp'
    elseif localCode == 'ar' then
        localCode = 'ara'
    end
    return localCode

end

-- Translate Main
function GameUtils:Translate(text,cb)
    local language = self:getCurrentLanguage()
    if language == 'zh_Hant' or language == 'zh_Hans' then
        self:Baidu_Translate(text,cb)
    else
        if type(self.reachableGoogle)  == nil then
            if network.isHostNameReachable("www.google.com") then
                self.reachableGoogle = true
                self:Google_Translate(text,cb)
            else
                self.reachableGoogle = false
                self:Baidu_Translate(text,cb)
            end
        elseif self.reachableGoogle then
            self:Google_Translate(text,cb)
        else
            self:Baidu_Translate(text,cb)
        end
    end
end


--ver 2.2.4
function GameUtils:getCurrentLanguage()
    local mapping = {
        "en_US",
        "zh_Hans",
        "fr",
        "it",
        "de",
        "es",
        "nl", -- dutch
        "ru",
        "ko",
        "ja",
        "hu",
        "pt",
        "ar",
        "zh_Hant"
    }
    return mapping[cc.Application:getInstance():getCurrentLanguage() + 1]
end

function GameUtils:Event_Handler_Func(events,add_func,edit_func,remove_func)
    local not_hanler = function(...)end
    add_func = add_func or not_hanler
    remove_func = remove_func or not_hanler
    edit_func = edit_func or not_hanler

    local added,edited,removed = {},{},{}
    for _,event in ipairs(events) do
        if event.type == 'add' then
            local result = add_func(event.data)
            if result then table.insert(added,result) end
        elseif event.type == 'edit' then
            local result = edit_func(event.data)
            if result then table.insert(edited,result) end
        elseif event.type == 'remove' then
            local result = remove_func(event.data)
            if result then  table.insert(removed,result) end
        end
    end
    return {added,edited,removed} -- each of return is a table
end


function GameUtils:pack_event_table(t)
    local ret = {}
    local added,edited,removed = unpack(t)
    if #added > 0 then ret.added = checktable(added) end
    if #edited > 0 then ret.edited = checktable(edited) end
    if #removed > 0 then ret.removed = checktable(removed) end
    return ret
end
-- DeltaData--> entity
function GameUtils:Handler_DeltaData_Func(data,add_func,edit_func,remove_func)
    local not_hanler = function(...)end
    add_func = add_func or not_hanler
    remove_func = remove_func or not_hanler
    edit_func = edit_func or not_hanler
    local added,edited,removed = {},{},{}
    for data_type,item in pairs(data) do
        if data_type == 'add' then
            for __,v in ipairs(item) do
                local result = add_func(v)
                if result then table.insert(added,result) end
            end
        elseif data_type == 'edit' then
            for __,v in ipairs(item) do
                local result = edit_func(v)
                if result then table.insert(edited,result) end
            end
        elseif data_type == 'remove' then
            for __,v in ipairs(item) do
                local result = remove_func(v)
                if result then table.insert(removed,result) end
            end
        end
    end
     return {added,edited,removed} -- each of return is a table
end


function GameUtils:parseRichText(str)
    str = string.gsub(str, "\n", "\\n")
    str = string.gsub(str, '"', "\"")
    str = string.gsub(str, "'", "\'")
    local items = {}
    local str_array = string.split(str, "{")
    for i, v in ipairs(str_array) do
        if #v > 0 then
            local inner_str_array = string.split(v, "}")
            if #inner_str_array > 1 then
                for i, v in ipairs(inner_str_array) do
                    if #v > 0 then
                        table.insert(items, v)
                        if #inner_str_array ~= i then
                            table.insert(items, "}")
                        end
                    end
                end
            else
                table.insert(items, v)
            end
        end
        if i ~= #str_array then
            table.insert(items, "{")
        end
    end
    for i, v in ipairs(items) do
        if v == "{" then
            local str_func = {}
            table.insert(str_func, v)
            local next_char = table.remove(items, i + 1)
            while next_char do
                table.insert(str_func, next_char)
                if next_char == "}" then
                    break
                end
                next_char = table.remove(items, i + 1)
            end
            table.insert(str_func, 1, "return ")
            local f, err_msg = loadstring(table.concat(str_func, ""))
            local success, result = pcall(f)
            if not success then
                print(err_msg)
            else
                items[i] = result
            end
        end
    end
    return items
end

function GameUtils:formatTimeStyleDayHour(time,min_day)
    min_day = min_day or 1
    if time > 86400*min_day then
        return string.format(_("%d天%d小时"),math.floor(time/86400),math.floor(time%86400/3600))
    else
        return GameUtils:formatTimeStyle1(time)
    end
end



local normal_soldier = GameDatas.Soldiers.normal
local special_soldier = GameDatas.Soldiers.special
local function createSoldiers(name, star, count)
    return {name = name, star = star, morale = 100, currentCount = count, totalCount = count, woundedCount = 0, round = 0}
end
function GameUtils:SoldierSoldierBattle(attackSoldiers, attackWoundedSoldierPercent, defenceSoldiers, defenceWoundedSoldierPercent)
    local attackResults = {}
    local defenceResults = {}
    while #attackSoldiers > 0 and #defenceSoldiers > 0 do
        local attackSoldier = attackSoldiers[1]
        local attackSoldierType = string.format("%s_%d", attackSoldier.name, attackSoldier.star)
        local attackSoldierConfig = normal_soldier[attackSoldierType]

        local defenceSoldier = defenceSoldiers[1]
        local defenceSoldierType = string.format("%s_%d", defenceSoldier.name, defenceSoldier.star)
        local defenceSoldierConfig = normal_soldier[defenceSoldierType]
        --
        local attackSoldierHp = attackSoldierConfig.hp
        local attackTotalPower = attackSoldierConfig[defenceSoldierConfig.type] * attackSoldier.currentCount

        local defenceSoldierHp = defenceSoldierConfig.hp
        local defenceTotalPower = defenceSoldierConfig[attackSoldierConfig.type] * defenceSoldier.currentCount
        --计算
        local attackDamagedSoldierCount
        local defenceDamagedSoldierCount
        if attackTotalPower >= defenceTotalPower then
            attackDamagedSoldierCount = round(defenceTotalPower * 0.5 / attackSoldierHp)
            defenceDamagedSoldierCount = round(sqrt(attackTotalPower * defenceTotalPower) * 0.5 / defenceSoldierHp)
        else
            attackDamagedSoldierCount = round(sqrt(attackTotalPower * defenceTotalPower) * 0.5 / attackSoldierHp)
            defenceDamagedSoldierCount = round(attackTotalPower * 0.5 / defenceSoldierHp)
        end
        -- 修正
        if attackDamagedSoldierCount > attackSoldier.currentCount * 0.7 then
            attackDamagedSoldierCount = floor(attackSoldier.currentCount * 0.7)
        end
        if defenceDamagedSoldierCount > defenceSoldier.currentCount * 0.7 then
            defenceDamagedSoldierCount = floor(defenceSoldier.currentCount * 0.7)
        end
        --
        local attackMoraleDecreased = ceil(attackDamagedSoldierCount * pow(2, attackSoldier.round - 1) / attackSoldier.totalCount * 100)
        local attackWoundedSoldierCount = ceil(attackDamagedSoldierCount * attackWoundedSoldierPercent)
        table.insert(attackResults, {
            soldierName = attackSoldier.name,
            soldierStar = attackSoldier.star,
            soldierCount = attackSoldier.currentCount,
            soldierDamagedCount = attackDamagedSoldierCount,
            soldierWoundedCount = attackWoundedSoldierCount,
            morale = attackSoldier.morale,
            moraleDecreased = attackMoraleDecreased > attackSoldier.morale and attackSoldier.morale or attackMoraleDecreased,
            isWin = attackTotalPower >= defenceTotalPower
        })
        attackSoldier.round = attackSoldier.round + 1
        attackSoldier.currentCount = attackSoldier.currentCount - attackDamagedSoldierCount
        attackSoldier.woundedCount = attackSoldier.woundedCount + attackWoundedSoldierCount
        attackSoldier.morale = attackSoldier.morale - attackMoraleDecreased


        local dfenceMoraleDecreased = ceil(defenceDamagedSoldierCount * pow(2, attackSoldier.round - 1) / defenceSoldier.totalCount * 100)
        local defenceWoundedSoldierCount = ceil(defenceDamagedSoldierCount * defenceWoundedSoldierPercent)
        table.insert(defenceResults, {
            soldierName = defenceSoldier.name,
            soldierStar = defenceSoldier.star,
            soldierCount = defenceSoldier.currentCount,
            soldierDamagedCount = defenceDamagedSoldierCount,
            soldierWoundedCount = defenceWoundedSoldierCount,
            morale = defenceSoldier.morale,
            moraleDecreased = dfenceMoraleDecreased > defenceSoldier.morale and defenceSoldier.morale or dfenceMoraleDecreased,
            isWin = attackTotalPower < defenceTotalPower
        })
        defenceSoldier.round = defenceSoldier.round + 1
        defenceSoldier.currentCount = defenceSoldier.currentCount - defenceDamagedSoldierCount
        defenceSoldier.woundedCount = defenceSoldier.woundedCount + defenceWoundedSoldierCount
        defenceSoldier.morale = defenceSoldier.morale - dfenceMoraleDecreased


        if attackTotalPower < defenceTotalPower or attackSoldier.morale <= 20 or attackSoldier.currentCount == 0 then
            table.remove(attackSoldiers, 1)
        end
        if attackTotalPower >= defenceTotalPower or defenceSoldier.morale <= 20 or defenceSoldier.currentCount == 0 then
            table.remove(defenceSoldiers, 1)
        end
    end
    return attackResults, defenceResults
end

function GameUtils:DragonDragonBattle(attackDragon, defenceDragon, effect)
    assert(attackDragon.hpMax)
    assert(attackDragon.strength)
    assert(attackDragon.vitality)
    assert(attackDragon.totalHp)
    assert(attackDragon.currentHp)
    assert(defenceDragon.hpMax)
    assert(defenceDragon.strength)
    assert(defenceDragon.vitality)
    assert(defenceDragon.totalHp)
    assert(defenceDragon.currentHp)
    local attackDragonPower = attackDragon.strength
    local defenceDragonPower = defenceDragon.strength
    if effect >= 0 then
        defenceDragonPower = defenceDragonPower * (1 - effect)
    else
        attackDragonPower = attackDragonPower * (1 + effect)
    end
    local attackDragonHpDecreased
    local defenceDragonHpDecreased
    if attackDragonPower >= defenceDragonPower then
        attackDragonHpDecreased = floor(defenceDragonPower * 0.5)
        defenceDragonHpDecreased = floor(pow(attackDragonPower * defenceDragonPower, 2) * 0.5)
    else
        attackDragonHpDecreased = floor(pow(attackDragonPower * defenceDragonPower, 2) * 0.5)
        defenceDragonHpDecreased = floor(attackDragonPower * 0.5)
    end

    attackDragon.currentHp = attackDragonHpDecreased > attackDragon.currentHp and 0 or attackDragon.currentHp - attackDragonHpDecreased
    defenceDragon.currentHp = defenceDragonHpDecreased > defenceDragon.currentHp and 0 or defenceDragon.currentHp - defenceDragonHpDecreased
    attackDragon.isWin = attackDragonPower >= defenceDragonPower
    defenceDragon.isWin = attackDragonPower < defenceDragonPower

    return {
        hp = attackDragon.totalHp,
        hpDecreased = attackDragon.totalHp - attackDragon.currentHp,
        hpMax = attackDragon.hpMax,
        isWin = attackDragonPower >= defenceDragonPower
    }, {
        hp = defenceDragon.totalHp,
        hpDecreased = defenceDragon.totalHp - defenceDragon.currentHp,
        hpMax = defenceDragon.hpMax,
        isWin = attackDragonPower < defenceDragonPower
    }
end

local floatInit = GameDatas.AllianceInitData.floatInit
function GameUtils:DoBattle(attacker, defencer)
    local clone_attacker_soldiers = clone(attacker.soldiers)
    local clone_defencer_soldiers = clone(defencer.soldiers)
    local attack_dragon, defence_dragon = GameUtils:DragonDragonBattle(attacker.dragon, defencer.dragon, 0)
    local attack_soldier, defence_soldier = GameUtils:SoldierSoldierBattle(attacker.soldiers, 0.4, defencer.soldiers, 0.4)

    local report = {}
    function report:GetAttackKDA()
        -- 龙战损
        local r = {}
        for _, v in ipairs(defence_soldier) do
            local key = string.format("%s_%d", v.soldierName, v.soldierStar)
            r[key] = 0
        end
        for _, v in ipairs(defence_soldier) do
            local key = string.format("%s_%d", v.soldierName, v.soldierStar)
            r[key] = r[key] + v.soldierDamagedCount
        end
        local killed = 0
        for k, v in pairs(r) do
            local config = normal_soldier[k] or special_soldier[k]
            assert(config, "查无此类兵种。")
            killed = killed + v * config.citizen
        end
        local dragon = {
            type = attacker.dragon.dragonType,
            hpDecreased = attack_dragon.hpDecreased,
            expAdd = floor(killed * floatInit.dragonExpByKilledCitizen.value)
        }
        -- 兵种战损
        local r = {}
        for _, v in ipairs(attack_soldier) do
            r[v.soldierName] = {damagedCount = 0, woundedCount = 0}
        end
        for _, v in ipairs(attack_soldier) do
            local soldier = r[v.soldierName]
            soldier.damagedCount = soldier.damagedCount + v.soldierDamagedCount
            soldier.woundedCount = soldier.woundedCount + v.soldierWoundedCount
        end
        local soldiers = {}
        for k, v in pairs(r) do
            table.insert(soldiers, {name = k, damagedCount = v.damagedCount, woundedCount = v.woundedCount})
        end
        return {dragon = dragon, soldiers = soldiers}
    end
    function report:GetFightAttackName()
        return "进攻方"
    end
    function report:GetFightDefenceName()
        return "防守方"
    end
    function report:IsDragonFight()
        return true
    end
    function report:GetFightAttackDragonRoundData()
        return attack_dragon
    end
    function report:GetFightDefenceDragonRoundData()
        return defence_dragon
    end
    function report:GetFightAttackSoldierRoundData()
        return attack_soldier
    end
    function report:GetFightDefenceSoldierRoundData()
        return defence_soldier
    end
    function report:GetOrderedAttackSoldiers()
        return clone_attacker_soldiers
    end
    function report:GetOrderedDefenceSoldiers()
        return clone_defencer_soldiers
    end
    function report:IsFightWall()
        return false
    end
    function report:IsAttackWin()
        local round = self:GetFightAttackSoldierRoundData()
        return round[#round].isWin
    end
    return report
end


return GameUtils











