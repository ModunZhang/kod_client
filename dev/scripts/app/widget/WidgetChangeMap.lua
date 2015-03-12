local Enum = import("..utils.Enum")

local WidgetPushButton = import(".WidgetPushButton")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")

local window = import("..utils.window")



local WidgetChangeMap = class("WidgetChangeMap", function ()
    local layer = display.newLayer()
    layer:setTouchSwallowEnabled(false)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        if event.name == "began" then
        -- layer:Retraction()
        end
        return true
    end)
    return layer
end)
WidgetChangeMap.MAP_TYPE = Enum("OUR_CITY","OUR_ALLIANCE","OTHER_ALLIANCE")

function WidgetChangeMap:ctor(map_type)
    -- 设置位置位移参数
    local scale_x = 1
    if display.width >640 then
        scale_x = display.width/768
    end

    -- 遮罩效果
    -- 模板
    local stencil = display.newNode()
    local child_layer = display.newColorLayer(cc.c4b(100,255,255,255))
    child_layer:setContentSize(cc.size(100,384))
    child_layer:pos(-50,0)
    stencil:addChild(child_layer)

    -- stencil

    -- 初始化一个裁剪节点
    local clippingNode = cc.ClippingNode:create(stencil)
        :pos(window.cx-260*scale_x, 90*scale_x)
    if device.platform ~= "mac" then
        clippingNode:setInverted(true)
    end
    clippingNode:setAlphaThreshold(0.5)
    clippingNode:scale(scale_x)
    -- 底板
    -- clippingNode:addChild(display.newSprite("world_map_2000x200.jpg"))
    self:addChild(clippingNode)
    child_layer:setTouchSwallowEnabled(false)



    self.map_bg = display.newSprite("select_map_bg_100X384.png")
        :align(display.BOTTOM_CENTER, 0,-380)
        :addTo(clippingNode)
    self.map_bg:setTouchEnabled(true)
    self.map_bg:setTouchSwallowEnabled(true)


    local map_bg = self.map_bg



    self.enemy_btn = WidgetPushButton.new(
        {normal = "change_map_icon.png", pressed = "change_map_icon.png"}
    ):addTo(map_bg)
        :pos(50, 300)
        :setButtonLabel("normal",UIKit:ttfLabel({text = _("敌方领地"),
            size = 16,
            color = 0xf3f0b6,
            shadow = true
        })
        )
        :setButtonLabelOffset(0, -48)


    self.our_alliance_btn = WidgetPushButton.new(
        {normal = "change_map_icon.png", pressed = "change_map_icon.png"}
    ):addTo(map_bg)
        :pos(50, 190)
        :setButtonLabel("normal",UIKit:ttfLabel({text = _("我方领地"),
            size = 16,
            color = 0xf3f0b6,
            shadow = true
        })
        )
        :setButtonLabelOffset(0, -48)

    self.our_city_btn =WidgetPushButton.new(
        {normal = "change_map_icon.png", pressed = "change_map_icon.png"}
    ):addTo(map_bg)
        :pos(50, 80)
        :setButtonLabel("normal",UIKit:ttfLabel({text = _("我的城市"),
            size = 16,
            color = 0xf3f0b6,
            shadow = true
        })
        )
        :setButtonLabelOffset(0, -48)

    local btn = WidgetPushButton.new(
        {normal = "map_bg_145X146.png", pressed = "map_bg_145X146.png"}
    ):addTo(self)
        :align(display.LEFT_CENTER,window.cx-335*scale_x, 50*scale_x)
        :onButtonClicked(function(event)
            -- dump(event)
            -- self:Move()
            if map_type == WidgetChangeMap.MAP_TYPE.OUR_CITY then
                if Alliance_Manager:GetMyAlliance()

                    :IsDefault() then
                    local dialog = FullScreenPopDialogUI.new():AddToCurrentScene()
                    dialog:SetTitle("提示")
                    dialog:SetPopMessage("未加入联盟!")
                    return
                end
                app:EnterMyAllianceScene()
            elseif map_type == WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE then
                app:EnterMyCityScene()
            elseif map_type == WidgetChangeMap.MAP_TYPE.OTHER_ALLIANCE then
                app:EnterMyAllianceScene()
            end
        end)
        :scale(scale_x)
    display.newSprite("change_map_icon.png"):addTo(btn):align(display.CENTER, 73, 0)
    btn:setTouchSwallowEnabled(true)

    -- self:SetMapType(map_type)
end

function WidgetChangeMap:Move()
    if self.map_bg:getNumberOfRunningActions()>0 then
        return
    end
    local target_y = self.map_bg:getPositionY()==0 and -380 or 0

    transition.moveTo(self.map_bg, {
        x = 0,
        y = target_y,
        time = 0.2,
        onComplete = function()
        end}
    )
end
function WidgetChangeMap:Retraction()
    if self.map_bg:getPositionY()==0 then
        self:Move()
    end
end
function WidgetChangeMap:SetMapType( map_type )
    self.map_type = map_type
    local y = 0
    if map_type == WidgetChangeMap.MAP_TYPE.OUR_CITY then

        -- 设置按钮事件
        self.our_city_btn:onButtonClicked(function(event)
            self:Retraction()
        end)

        self.our_alliance_btn:onButtonClicked(function(event)
            if Alliance_Manager:GetMyAlliance()

                :IsDefault() then
                local dialog = FullScreenPopDialogUI.new():AddToCurrentScene()
                dialog:SetTitle("提示")
                dialog:SetPopMessage("未加入联盟!")
                return
            end
            self.map_frame:setPositionY(179)
            self:Retraction()

            -- app:enterScene("AllianceBattleScene", nil, "custom", -1,handler(self, self.CloudArmature) )
            -- app:enterScene("AllianceScene", nil, "custom", -1,handler(self, self.CloudArmature) )
            app:EnterMyAllianceScene()
        end)

        -- self.enemy_btn:onButtonClicked(function(event)
        -- local enemy_alliance_id = Alliance_Manager:GetMyAlliance():GetAllianceMoonGate():GetEnemyAlliance().id
        -- if enemy_alliance_id and string.trim(enemy_alliance_id) ~= "" then
        --     self.map_frame:setPositionY(289)
        --  self:Retraction()
            -- NetManager:getFtechAllianceViewDataPromose(enemy_alliance_id):next(function(msg)
            --     local enemyAlliance = Alliance_Manager:DecodeAllianceFromJson(msg)
            --     app:lockInput(false)
            --     app:enterScene("EnemyAllianceScene", {enemyAlliance,GameUIAllianceEnter.Enemy}, "custom", -1, handler(self, self.CloudArmature))
            -- end)
        -- else
        --     FullScreenPopDialogUI.new():SetTitle(_("提示"))
        --         :SetPopMessage(_("当前是和平期"))
        --         :AddToCurrentScene()
        -- end
        -- end)

        y = 69
    elseif map_type == WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE then

        -- 设置按钮事件
        self.our_city_btn:onButtonClicked(function(event)
            self.map_frame:setPositionY(69)
            self:Retraction()
            -- app:enterScene("MyCityScene", {City}, "custom", -1, handler(self, self.CloudArmature))
            app:EnterMyCityScene()
        end)

        self.our_alliance_btn:onButtonClicked(function(event)
            self:Retraction()
        end)

        self.enemy_btn:onButtonClicked(function(event)
            -- local enemy_alliance_id = Alliance_Manager:GetMyAlliance():GetAllianceMoonGate():GetEnemyAlliance().id
            -- if enemy_alliance_id and string.trim(enemy_alliance_id) ~= "" then
            --     self.map_frame:setPositionY(289)
            --  self:Retraction()
            --     NetManager:getFtechAllianceViewDataPromose(enemy_alliance_id):next(function(msg)
            --         local enemyAlliance = Alliance_Manager:DecodeAllianceFromJson(msg)
            --         app:lockInput(false)
            --         app:enterScene("EnemyAllianceScene", {enemyAlliance,GameUIAllianceEnter.Enemy}, "custom", -1, handler(self, self.CloudArmature))
            --     end)
            -- else
            --     FullScreenPopDialogUI.new():SetTitle(_("提示"))
            --         :SetPopMessage(_("当前是和平期"))
            --         :AddToCurrentScene()
            -- end
            end)


        y = 179
    elseif map_type == WidgetChangeMap.MAP_TYPE.ENEMY_ALLIANCE then
        -- 设置按钮事件
        -- self.our_city_btn:onButtonClicked(function(event)
        --     self.map_frame:setPositionY(69)
        --     self:Retraction()
        --     app:enterScene("MyCityScene", {City}, "custom", -1, handler(self, self.CloudArmature))
        -- end)

        -- self.our_alliance_btn:onButtonClicked(function(event)
        --     if Alliance_Manager:GetMyAlliance():IsDefault() then
        --         local dialog = FullScreenPopDialogUI.new():AddToCurrentScene()
        --         dialog:SetTitle("提示")
        --         dialog:SetPopMessage("未加入联盟!")
        --         return
        --     end
        --     self.map_frame:setPositionY(179)
        --     self:Retraction()
        --     app:enterScene("AllianceScene", nil, "custom", -1,handler(self, self.CloudArmature) )
        -- end)

        -- self.enemy_btn:onButtonClicked(function(event)
        --     self:Retraction()
        -- end)

        y = 289
    end

    -- self.map_frame = display.newSprite("map_frame.png"):addTo(self.map_bg):align(display.CENTER,50, y)
end

return WidgetChangeMap

















