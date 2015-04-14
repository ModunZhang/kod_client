--
-- Author: Kenny Dai
-- Date: 2015-03-03 15:40:53
--
local UILib = import("..ui.UILib")
local Localize_item = import("..utils.Localize_item")

local WidgetGachaItemBox = class("WidgetGachaItemBox",function ()
    return display.newNode()
end)
function WidgetGachaItemBox:ctor(gacha_item,isSenior)
    self:setContentSize(cc.size(92,92))
    self:align(display.CENTER)
    self.gacha_item = gacha_item
    self.isSenior = isSenior
    local gacha_box = display.newSprite("box_gacha_92x92.png"):addTo(self)
    -- item icon
    local item_icon = display.newScale9Sprite(self:GetGachaItemIcon()):addTo(self)
    item_icon:scale(74/item_icon:getContentSize().width)
    self:SetNodeEvent(gacha_box)
end
function WidgetGachaItemBox:SetNodeEvent(gacha_box)
    gacha_box:setTouchEnabled(true)
    gacha_box:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            local tip_x = 0
            if self:getPositionX() < display.cx then
                tip_x = 70
            else
                tip_x = -70
            end
            local tips_bg = display.newScale9Sprite("back_ground_240x73.png",tip_x,0,cc.size(240,73),cc.rect(10,10,220,53))
                :addTo(self):align(display.CENTER)
            tips_bg:setTag(100)
            local text_1 = UIKit:ttfLabel({text = Localize_item.item_name[self.gacha_item.itemName],size = 20 ,color = 0xfff2b3})
                :addTo(tips_bg)
            text_1:setGlobalZOrder(100)
            local text_2 = UIKit:ttfLabel({text = "X "..self.gacha_item.itemCount,size = 20 ,color = 0xfff2b3})
                :addTo(tips_bg)
            text_2:setGlobalZOrder(100)
            tips_bg:size(math.max(text_1:getContentSize().width,text_2:getContentSize().width)+20,73)
            local t_size = tips_bg:getContentSize()
            text_1:align(display.CENTER, t_size.width/2, 50)

            text_2:align(display.CENTER, t_size.width/2, 20)
            tips_bg:setGlobalZOrder(100)
        elseif event.name == "ended" then
            if self:getChildByTag(100) then
                self:removeChildByTag(100, true)
            end
        elseif event.name == "moved" then
            local rect = self:convertToNodeSpace(cc.p(event.x,event.y))
            local box = self:getContentSize()
            if box.width/2 < rect.x or rect.x<-box.width/2 or box.height/2 < rect.y or rect.y < -box.height/2 then
                if self:getChildByTag(100) then
                    self:removeChildByTag(100, true)
                end
            end
        end
        return true
    end)
end
-- 设置起点或取消起点状态
function WidgetGachaItemBox:SetOrginStatus()
    local img_1,img_2
    if self.isSenior then
        img_1,img_2="box_gacha_senior_136x136_1.png","box_gacha_senior_136x136_2.png"
    else
        img_1,img_2="box_gacha_112x112_1.png","box_gacha_112x112_2.png"
    end
    if self.light_box then
        self:removeChild(self.light_box, true)
        self.light_box = nil
    else
        local patten , size
        if self.isSenior then
            patten = "box_gacha_senior_136x136_%d.png"
            size = 136
        else
            patten = "box_gacha_112x112_%d.png"
            size= 112
        end
        local srpite_frame_1 = cc.SpriteFrame:create(img_1,cc.rect(0,0,size,size))
        local srpite_frame_2 = cc.SpriteFrame:create(img_2,cc.rect(0,0,size,size))
        local light_box = display.newSprite(img_1)
        self:addChild(light_box)

        cc.SpriteFrameCache:getInstance():addSpriteFrame(srpite_frame_1,img_1)
        cc.SpriteFrameCache:getInstance():addSpriteFrame(srpite_frame_2,img_2)
        local frames = display.newFrames(patten, 1, 2)
        local animation = display.newAnimation(frames, 0.2)
        light_box:playAnimationForever(animation)
        self.light_box = light_box

    end
end
-- 设置选中点或取消选中点状态 ，针对3连抽
function WidgetGachaItemBox:SetSelectedStatus()
    local img_1,img_2
    if self.isSenior then
        img_1,img_2="box_gacha_senior_136x136_1.png","box_gacha_senior_136x136_2.png"
    else
        img_1,img_2="box_gacha_112x112_1.png","box_gacha_112x112_2.png"
    end
    if self.select_box then
        self:removeChild(self.select_box, true)
        self.select_box = nil
    else
        local patten , size
        if self.isSenior then
            patten = "box_gacha_senior_136x136_%d.png"
            size = 136
        else
            patten = "box_gacha_112x112_%d.png"
            size= 112
        end
        local srpite_frame_1 = cc.SpriteFrame:create(img_1,cc.rect(0,0,size,size))
        local srpite_frame_2 = cc.SpriteFrame:create(img_2,cc.rect(0,0,size,size))
        local select_box = display.newSprite(img_1)
        self:addChild(select_box)

        cc.SpriteFrameCache:getInstance():addSpriteFrame(srpite_frame_1,img_1)
        cc.SpriteFrameCache:getInstance():addSpriteFrame(srpite_frame_2,img_2)
        local frames = display.newFrames(patten, 1, 2)
        local animation = display.newAnimation(frames, 0.2)
        select_box:playAnimationForever(animation)
        self.select_box = select_box

    end
end
-- 设置经过状态或取消经过状态
function WidgetGachaItemBox:SetPassStatus()
    if self.pass_box then
        self:removeChild(self.pass_box, true)
        self.pass_box = nil
    else
        local img
        if self.isSenior then
            img="box_gacha_senior_136x136_1.png"
        else
            img="box_gacha_112x112_1.png"
        end
        local pass_box = display.newSprite(img):addTo(self)
        self.pass_box = pass_box
    end
end
function WidgetGachaItemBox:ResetLigt()
    if self.pass_box then
        self:removeChild(self.pass_box, true)
        self.pass_box = nil
    end
    if self.light_box then
        self:removeChild(self.light_box, true)
        self.light_box = nil
    end

end
function WidgetGachaItemBox:GetGachaItemName( )
    return self.gacha_item.itemName
end
function WidgetGachaItemBox:GetGachaItemIcon( )
    return UILib.item[self:GetGachaItemName()]
end
function WidgetGachaItemBox:RemoveSelectStatus( )
    if self.select_box then
        self:removeChild(self.select_box, true)
        self.select_box = nil
    end
end
return WidgetGachaItemBox











