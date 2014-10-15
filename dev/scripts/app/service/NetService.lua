local NetService = {}


function NetService:init(  )
    self.m_pomelo = CCPomelo:getInstance()
    self.m_deltatime = 0
    self.m_urlcode = import("app.utils.urlcode")
end

function NetService:connect(host, port, cb)
    self.m_pomelo:asyncConnect(host, port, function ( success )
        cb(success)
    end)
end

function NetService:disconnect( )
    self.m_pomelo:cleanup() -- clean the callback in pomelo thread
    self.m_pomelo:stop()
end


function NetService:getServerTime()
    return ext.now() + self.m_deltatime
end

function NetService:setDeltatime(deltatime)
    self.m_deltatime = deltatime
end

function NetService:request(route, lmsg, cb, blocking)
    blocking = blocking == nil and true or blocking
    lmsg = lmsg or {}
    lmsg.__time__ = ext.now() + self.m_deltatime
    if blocking then
        -- device.showActivityIndicator()
        local loading = UIKit:newGameUI("GameUIWatiForNetWork"):addToCurrentScene(true)
        self.m_pomelo:request(route, json.encode(lmsg), function ( success, jmsg )
            -- device.hideActivityIndicator()
            loading:removeFromParent()
            cb(success, jmsg and json.decode(jmsg) or nil)
        end)
    else
        self.m_pomelo:request(route, json.encode(lmsg), function ( success, jmsg )
            cb(success, jmsg and json.decode(jmsg) or nil)
        end)
    end
end

function NetService:notify( route, lmsg, cb )
    lmsg = lmsg or {}
    lmsg.__time__ = ext.now() + self.m_deltatime
    self.m_pomelo:notify(route, json.encode(lmsg), function ( success )
        cb(success)
    end)
end

function NetService:addListener( event, cb )
    self.m_pomelo:addListener(event, function ( success, jmsg )
        cb(success, jmsg and json.decode(jmsg) or nil)
    end)
end

function NetService:removeListener( event )
    self.m_pomelo:removeListener(event)
end

function NetService:get(url, args, cb, progressCb)
    local urlString = url
    if param then
        urlString = urlString .. "?" .. self.m_urlcode.encodetable(args)
    end

    local request = network.createHTTPRequest(function(event)
        local request = event.request
        local eventName = event.name

        if eventName == "completed" then
            cb(true, request:getResponseStatusCode(), request:getResponseData())
        elseif eventName == "cancelled" then

        elseif eventName == "failed" then
            cb(false, request:getErrorCode(), request:getErrorMessage())
        elseif eventName == "inprogress" then
            local totalLength = event.dltotal
            local currentLength = event.dlnow
            if progressCb then progressCb(totalLength, currentLength) end
        end
    end, urlString)

    request:setTimeout(180) -- 3 min
    request:start()

    return request
end

function NetService:cancelGet(request)
    request:cancel()
end

function NetService:formatTimeAsTimeAgoStyleByServerTime( time )
    time =  math.floor(math.abs(self:getServerTime() - time) / 1000)
    return GameUtils:formatTimeAsTimeAgoStyle(time)
end

return NetService

