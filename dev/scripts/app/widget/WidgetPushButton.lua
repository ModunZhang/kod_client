local MOVE_EVENT = "MOVE_EVENT"
local UIPushButton = cc.ui.UIPushButton
local WidgetPushButton = class("WidgetPushButton", UIPushButton)
local my_filter = filter
function WidgetPushButton:ctor(images, options, filters)
    self.pre_pos = nil
    self.filters = filters ~= nil and filters or nil

    WidgetPushButton.super.ctor(self, images, options)
    self:onButtonPressed(function(event)
        self.pre_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
    end)
    self:addEventListener(MOVE_EVENT, function(event)
        local cur_pos = event.target:convertToWorldSpace(cc.p(event.target:getPosition()))
        if event.touchInTarget and cc.pGetDistance(cur_pos, self.pre_pos) > 10 then
            if event.target.fsm_:canDoEvent("release") then
                event.target.fsm_:doEvent("release")
                self:dispatchEvent({name = UIPushButton.RELEASE_EVENT, x = cur_pos.x, y = cur_pos.y, touchInTarget = event.touchInTarget})
            end
        end
    end)
    self:setTouchSwallowEnabled(false)
    self:setNodeEventEnabled(true)
end
function WidgetPushButton:onEnter()
    if self:HasFilters() then
        self:UpdateFilters()
    end
end
function WidgetPushButton:onChangeState_()
    if self:isRunning() then
        self:updateButtonImage_()
        self:updateButtonLable_()
        if self:HasFilters() then
            self:UpdateFilters()
        end
    end
    return self
end
function WidgetPushButton:updateButtonImage_()
    local state = self.fsm_:getState()
    local image = self.images_[state]

    if not image then
        for _, s in pairs(self:getDefaultState_()) do
            image = self.images_[s]
            if image then break end
        end
    end
    if image then
        if self.currentImage_ ~= image then
            for i,v in ipairs(self.sprite_) do
                v:removeFromParent(true)
            end
            self.sprite_ = {}
            self.currentImage_ = image

            if "table" == type(image) then
                for i,v in ipairs(image) do
                    if self.scale9_ then
                        self.sprite_[i] = display.newScale9Sprite(v)
                        if not self.scale9Size_ then
                            local size = self.sprite_[i]:getContentSize()
                            self.scale9Size_ = {size.width, size.height}
                        else
                            self.sprite_[i]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                        end
                    else
                        self.sprite_[i] = self:NewSprite(image, self.filters ~= nil and self.filters[state] or nil)
                    end
                    self:addChild(self.sprite_[i], UIPushButton.IMAGE_ZORDER)
                    if self.sprite_[i].setFlippedX then
                        self.sprite_[i]:setFlippedX(self.flipX_ or false)
                        self.sprite_[i]:setFlippedY(self.flipY_ or false)
                    end
                end
            else
                if self.scale9_ then
                    self.sprite_[1] = display.newScale9Sprite(image)
                    if not self.scale9Size_ then
                        local size = self.sprite_[1]:getContentSize()
                        self.scale9Size_ = {size.width, size.height}
                    else
                        self.sprite_[1]:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                    end
                else
                    self.sprite_[1] = self:NewSprite(image, self.filters ~= nil and self.filters[state] or nil)
                end
                if self.sprite_[1].setFlippedX then
                    self.sprite_[1]:setFlippedX(self.flipX_ or false)
                    self.sprite_[1]:setFlippedY(self.flipY_ or false)
                end
                self:addChild(self.sprite_[1], UIPushButton.IMAGE_ZORDER)
            end
        end

        for i,v in ipairs(self.sprite_) do
            v:setAnchorPoint(self:getAnchorPoint())
            v:setPosition(0, 0)
        end
    elseif not self.labels_ then
        printError("UIButton:updateButtonImage_() - not set image for state %s", state)
    end
end
function WidgetPushButton:NewSprite(image, filter)
    if self:HasFilters() then
        local sprite = display.newSprite(image, nil, nil, {class=cc.FilteredSpriteWithOne})
        self:SetFilterOnSprite(sprite, filter)
        return sprite
    else
        return display.newSprite(image)
    end
end
function WidgetPushButton:SetFilter(filters)
    if not self:HasFilters() then
        assert("你需要在初始化时就确定是否需要传入shader")
    end
    for k, v in pairs(self.filters) do
        self.filters[k] = filters[k]
    end
    self:UpdateFilters()
    return self
end
function WidgetPushButton:UpdateFilters()
    self:SetFilterOnSprite(self.sprite_[1], self.filters[self.fsm_:getState()])
end
function WidgetPushButton:SetFilterOnSprite(sprite, filter)
    if filter then
        local filters = my_filter.newFilter(filter.name, filter.params)
        sprite:setFilter(filters)
    else
        sprite:clearFilter()
    end
end
function WidgetPushButton:HasFilters()
    return self.filters
end
function WidgetPushButton:onTouch_(event)
    -- print("----UIPushButton:onTouch_")
    local name, x, y = event.name, event.x, event.y
    -- print("----name, x, y = ", name, x, y)
    if name == "began" then
        -- print("----began")
        if not self:checkTouchInSprite_(x, y) then return false end
        -- print("----doEvent('press')")
        self.fsm_:doEvent("press")
        self:dispatchEvent({name = UIPushButton.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        return true
    end

    local touchInTarget = self:checkTouchInSprite_(x, y)
    if name == "moved" then
        if touchInTarget then
            self:dispatchEvent({name = MOVE_EVENT, x = x, y = y, touchInTarget = true})
        elseif not touchInTarget and self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIPushButton.RELEASE_EVENT, x = x, y = y, touchInTarget = false})
        end
    else
        local is_pressed = self.fsm_:isState("pressed")
        if self.fsm_:canDoEvent("release") then
            self.fsm_:doEvent("release")
            self:dispatchEvent({name = UIPushButton.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
        end
        if name == "ended" and is_pressed and touchInTarget then
            self:dispatchEvent({name = UIPushButton.CLICKED_EVENT, x = x, y = y, touchInTarget = true})
        end
    end
end



return WidgetPushButton













