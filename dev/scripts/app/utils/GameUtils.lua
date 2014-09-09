GameUtils = {
	
}

function GameUtils:formatTimeStyle1(time)
    local seconds = time % 60
    time = time / 60
    local minutes = time % 60
    time = time / 60
    local hours = time
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
    	elseif eventName == "inprogress" then
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
    	elseif eventName == "inprogress" then
		else
			cb(nil,eventName)
    	end
    end, "http://openapi.baidu.com/public/2.0/bmt/translate?" .. str, "GET")
    request:setTimeout(10)
    request:start()
end

function GameUtils:ConvertLocaleToBaiduCode()
	--[[ 
	中文	zh	英语	en
	日语	jp	韩语	kor
	西班牙语	spa	法语	fra
	泰语	th	阿拉伯语	ara
	俄罗斯语	ru	葡萄牙语	pt
	粤语	yue	文言文	wyw
	白话文	zh	自动检测	auto
	德语	de	意大利语	it
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