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
    display.newSprite("#login_bkg.png", display.cx, display.cy):addTo(self)
end

function MainScene:checkLogin()
    self:showText(_("连接网关服务器...."))
    NetManager:connectGateServer(function(success)
        if not success then
            self:showText(_("连接网关服务器失败!"))
            return
        end

        self:showText(_("获取游戏服务器信息...."))
        NetManager:getConnectorServerInfo(function(success)
            if not success then
                self:showText(_("获取游戏服务器信息失败!"))
                return
            end

            self:showText(_("连接游戏服务器...."))
            NetManager:connectConnectorServer(function(success)
                if not success then
                    self:showText(_("连接游戏服务器失败!"))
                    return
                end

                self:showText(_("获取玩家信息...."))
                NetManager:getUserInfo(function(success, msg)
                    if msg.user and msg.user ~= json.null then
                        self:showText(_("欢迎你,") .. msg.user.name)
                        self:showLogin()
                    else
                        self:showText(_("玩家信息不存在，请注册!"))
                        self:showRegister()
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
        size = 20,
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

function MainScene:showRegister()
    local loginBgSprite = display.newSprite("#login_input.png", display.cx, display.cy - (136 / 2) - 20)
    loginBgSprite:addTo(self)

    local nameField = ui.newEditBox({
        image = "images/login/emptyhuoli.png",
        size = CCSize(280, 40),
        x = 250,
        y = loginBgSprite:getContentSize().height - 42,
        listener = function(event, sender)
        end
    })
    nameField:setMaxLength(15)
    nameField:setFont("fonts/Arial.ttf", 22)
    nameField:setPlaceHolder(_("请输入账号"))
    nameField:addTo(loginBgSprite)

    local registerButton = ui.newImageMenuItem({
        image = "#login_login_1.png",
        imageSelected = "#login_login_2.png",
        imageDisabled = "#login_login_2.png",
        x = loginBgSprite:getContentSize().width / 2,
        y = 49 / 2 + 20,
        listener = function()
            local name = nameField:getText()
            if name == "" then return end

            self:showText(_("注册中...."))
            NetManager:register(name, function(success, msg)
                if msg.code == Response.OK then
                    self:showText(_("欢迎你," .. msg.user.name))
                    loginBgSprite:removeSelf()
                    self:showLogin()
                elseif msg.code == Response.CLIENT.CONNECTOR_USER_ALREADY_EXIST then
                    self:showText(_("账号已存在!"))
                else
                    self:showText(_("服务器错误!"))
                end
            end)
        end
    })

    loginBgSprite:addChild(ui.newMenu({ registerButton }))
end

function MainScene:showLogin()
    cc.ui.UIPushButton.new({
        normal = "#login_start_1.png",
        pressed = "#login_start_2.png",
        disabled = "#login_start_2.png",
    })
    :setButtonLabel(ui.newTTFLabel({
        text = _("进入聊天"),
        size = 24,
    }))
    :onButtonClicked(function(event)
        NetManager:login(function(success, msg)
            if msg.code == Response.OK then
                DataManager:setUserData(msg.user)
                app:enterScene("ChatScene")
            end
        end)
    end)
    :align(
        display.CENTER,
        display.cx,
        display.cy - 60
    )
    :addTo(self)

    cc.ui.UIPushButton.new({
        normal = "#login_start_1.png",
        pressed = "#login_start_2.png",
        disabled = "#login_start_2.png",
    })
    :setButtonLabel(ui.newTTFLabel({
        text = _("三消游戏"),
        size = 24,
    }))
    :onButtonClicked(function(event)
        app:enterScene("SushiScene")
    end)
    :align(
        display.CENTER,
        display.cx,
        display.cy - 120
    )
    :addTo(self)

--    local loginButton = ui.newImageMenuItem({
--        image = "#login_start_1.png",
--        imageSelected = "#login_start_2.png",
--        imageDisabled = "#login_start_2.png",
--        x = display.cx,
--        y = display.cy - 60,
--        listener = function()
--            NetManager:login(function(success, msg)
--                if msg.code == Response.OK then
--                    DataManager:setUserData(msg.user)
--                    app:enterScene("ChatScene")
--                end
--            end)
--        end
--    })
--
--    self:addChild(ui.newMenu({ loginButton }))
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