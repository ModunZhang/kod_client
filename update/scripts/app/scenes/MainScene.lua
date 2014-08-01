local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)


function MainScene:ctor()
    self.m_currentLabel = nil
end

function MainScene:onEnter()
    self:createBgLayer()
    self:showVersion()
    self:checkLogin()
end

function MainScene:onExit()
end

function MainScene:createBgLayer()
    display.newSprite("images/bg.png", display.cx, display.cy):addTo(self)
end

function MainScene:checkLogin()
    self:showText(_("连接网关服务器...."))
    NetManager:connectGateServer(function(success)
        if not success then
            self:showText(_("连接网关服务器失败!"))
            return
        end

        self:showText(_("获取游戏服务器信息...."))
        NetManager:getLogicServerInfo(function(success)
            if not success then
                self:showText(_("获取游戏服务器信息失败!"))
                return
            end

            self:showText(_("连接游戏服务器...."))
            NetManager:connectLogicServer(function(success)
                if not success then
                    self:showText(_("连接游戏服务器失败!"))
                    return
                end

                NetManager:login(function ( success, msg )
                    if not success then
                        self:showText(_("登录游戏失败!"))
                        return
                    else
                        self:showText(_("登录游戏成功!"))
                        LuaUtils:outputTable(msg)
                    end
                end)
            end)
        end)
    end)
end


function MainScene:showText(text)
    self:removeText()

    local label = ui.newTTFLabel({
        text = text,
        font = "fonts/Arial.ttf",
        size = 35,
        aligh = ui.TEXT_ALIGN_CENTER,
        valigh = ui.TEXT_VALIGN_CENTER,
        color = ccc3(255, 255, 255)
    })
    label:setPosition(display.cx, display.cy)
    label:addTo(self)

    self.m_currentLabel = label
end

function MainScene:removeText()
    if self.m_currentLabel then
        self.m_currentLabel:removeSelf()
        self.m_currentLabel = nil
    end
end

function MainScene:showVersion()
    local jsonPath = CCFileUtils:sharedFileUtils():fullPathForFilename("fileList.json")
    local file = io.open(jsonPath)
    local jsonString = file:read("*a")
    file:close()

    local tag = json.decode(jsonString).tag
    local version = string.format("Version:%s(%s)", CONFIG_APP_VERSION, tag)
    local label = ui.newTTFLabel({
        text = version,
        font = "fonts/Arial.ttf",
        size = 18,
        aligh = ui.TEXT_ALIGN_RIGHT,
        valigh = ui.TEXT_VALIGN_CENTER,
        color = ccc3(255, 255, 255)
    })

    label:setPosition(display.right - label:getContentSize().width / 2, display.bottom + label:getContentSize().height / 2)
    label:addTo(self)
end

return MainScene