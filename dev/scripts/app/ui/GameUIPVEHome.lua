local WidgetChangeMap = import("..widget.WidgetChangeMap")
local FullScreenPopDialogUI = import("..ui.FullScreenPopDialogUI")
local UIPageView = import("..ui.UIPageView")
local window = import("..utils.window")
local GameUIPVEHome = UIKit:createUIClass('GameUIPVEHome')
local WidgetUseItems = import("..widget.WidgetUseItems")
local RichText = import("..widget.RichText")
local ChatManager = import("..entity.ChatManager")
local WidgetChat = import("..widget.WidgetChat")
local timer = app.timer
function GameUIPVEHome:ctor(user, scene)
    self.user = user
    self.scene = scene
    self.layer = scene:GetSceneLayer()
    GameUIPVEHome.super.ctor(self)
end
function GameUIPVEHome:onEnter()
    self:CreateTop()
    self:CreateBottom()
    self.user:AddListenOnType(self, self.user.LISTEN_TYPE.RESOURCE)
    self:OnResourceChanged(self.user)
    self.layer:AddPVEListener(self)
    self.layer:NotifyExploring()
end
function GameUIPVEHome:onExit()
    self.layer:RemovePVEListener(self)
    self.user:RemoveListenerOnType(self, self.user.LISTEN_TYPE.RESOURCE)
end
function GameUIPVEHome:OnResourceChanged(user)
    local strength_resouce = user:GetStrengthResource()
    local current_strength = strength_resouce:GetResourceValueByCurrentTime(timer:GetServerTime())
    local limit = strength_resouce:GetValueLimit()
    self.strenth:setString(string.format("%d/%d", current_strength, limit))
    self.gem_label:setString(string.formatnumberthousands(user:GetGemResource():GetValue()))
end
function GameUIPVEHome:OnExploreChanged(pve_layer)
    self.exploring:setString(string.format("探索度 %.2f%%", pve_layer:ExploreDegree() * 100))
end
function GameUIPVEHome:CreateTop()
    local top_bg = display.newSprite("head_bg.png")
        :align(display.TOP_CENTER, window.cx, window.top)
        :addTo(self)
    local size = top_bg:getContentSize()
    top_bg:setTouchEnabled(true)

    cc.ui.UIPushButton.new(
        {normal = "return_btn_up_202x93.png", pressed = "return_btn_down_202x93.png"}
    ):addTo(top_bg)
        :align(display.LEFT_CENTER, 20, -5)
        :onButtonClicked(function()
            FullScreenPopDialogUI.new():SetTitle(_("返回起点"))
                :SetPopMessage(_("返回当前关卡的起点需要消耗您10个金龙币,您是否同意?"))
                :CreateOKButton({
                    listener =  function()
                        self.user:SetPveData(nil, nil, 10)
                        self.layer:ResetCharPos()
                        NetManager:getSetPveDataPromise(self.user:EncodePveDataAndResetFightRewardsData())
                    end
                }):CreateCancelButton():AddToCurrentScene()
            
        end):setButtonLabel(cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("返回起点"),
        size = 18,
        font = UIKit:getFontFilePath(),
        color = UIKit:hex2c3b(0xffedae)})):setButtonLabelOffset(-20, 0)


    -- 金龙币按钮
    local button = cc.ui.UIPushButton.new(
        {normal = "gem_btn_up_196x68.png", pressed = "gem_btn_down_196x68.png"},
        {scale9 = false}
    ):onButtonClicked(function(event)
        UIKit:newGameUI('GameUIShop', City):AddToCurrentScene(true)
    end):addTo(top_bg):pos(top_bg:getContentSize().width - 130, -16)
    display.newSprite("gem_icon_62x61.png"):addTo(button):pos(60, 3)
    self.gem_label = UIKit:ttfLabel({
        size = 20,
        color = 0xffd200,
        shadow = true,
    }):addTo(button):align(display.CENTER, -30, 8)


    self.title = UIKit:ttfLabel({
        text = string.format("%d, %s", self.layer:CurrentPVEMap():GetIndex(), self.layer:CurrentPVEMap():Name()),
        size = 26,
        color = 0xffedae,
    }):addTo(top_bg):align(display.LEFT_CENTER, 60, 60)

    self.exploring = UIKit:ttfLabel({
        size = 20,
        color = 0xffedae,
    }):addTo(top_bg):align(display.RIGHT_CENTER, size.width - 60, 60)
end

function GameUIPVEHome:CreateBottom()
    -- 底部背景
    local bottom_bg = display.newSprite("bottom_bg_768x136.png")
        :align(display.BOTTOM_CENTER, display.cx, display.bottom)
        :addTo(self)
    bottom_bg:setTouchEnabled(true)
    if display.width >640 then
        bottom_bg:scale(display.width/768)
    end


    local char_bg = display.newSprite("chat_hero_background.png")
        :addTo(bottom_bg, 1):pos(250, display.bottom + 50):scale(0.65)
    display.newSprite("playerIcon_default.png"):addTo(char_bg):pos(55, 55):scale(0.9)
    local alliance_name = Alliance_Manager:GetMyAlliance():IsDefault() and "" or Alliance_Manager:GetMyAlliance():Name()
    self.tag = UIKit:ttfLabel({text = string.format("[%s] %s", alliance_name, self.user:Name()),
        size = 20,
        color = 0xffedae,
    }):addTo(bottom_bg):align(display.LEFT_CENTER, 300, display.bottom + 65)

    display.newSprite("dragon_strength_27x31.png")
        :addTo(bottom_bg):align(display.CENTER, 310, display.bottom + 25)

    local label_bg = display.newSprite("label_background_146x25.png")
        :addTo(bottom_bg):align(display.LEFT_CENTER, 315, display.bottom + 25)

    self.gem = UIKit:ttfLabel({
        text = self.user:Power(),
        size = 20,
        color = 0xbdb582,
    }):addTo(label_bg):align(display.LEFT_CENTER, 20, 13)



    display.newSprite("dragon_lv_icon.png"):scale(0.8)
        :addTo(bottom_bg, 1):align(display.CENTER, 510, display.bottom + 25)

    local label_bg = display.newSprite("label_background_146x25.png")
        :addTo(bottom_bg):align(display.LEFT_CENTER, 515, display.bottom + 25)

    self.strenth = UIKit:ttfLabel({text = "",
        size = 20,
        color = 0xbdb582,
    }):addTo(label_bg):align(display.LEFT_CENTER, 20, 13)

    cc.ui.UIPushButton.new(
        {normal = "add_btn_up_50x50.png",pressed = "add_btn_down_50x50.png"}
        ,{}
        ,{
            disabled = { name = "GRAY", params = {0.2, 0.3, 0.5, 0.1} }
        })
        :addTo(label_bg)
        :align(display.CENTER, 131, 13)
        :onButtonClicked(function ( event )
            WidgetUseItems.new():Create({
                item_type = WidgetUseItems.USE_TYPE.STAMINA
            }):AddToCurrentScene()
        end):scale(0.6)

    WidgetChat.new():addTo(bottom_bg)
    :align(display.CENTER, bottom_bg:getContentSize().width/2, bottom_bg:getContentSize().height-11)
    
    local map_node = WidgetChangeMap.new(WidgetChangeMap.MAP_TYPE.OUR_ALLIANCE):addTo(self)
end



return GameUIPVEHome







