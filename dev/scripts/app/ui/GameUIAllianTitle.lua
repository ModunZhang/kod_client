--
-- Author: Danny He
-- Date: 2014-10-23 20:46:22
--
local GameUIAllianTitle = UIKit:createUIClass("GameUIAllianTitle")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local window = import("..utils.window")
local Localize = import("..utils.Localize")

function GameUIAllianTitle:ctor(title)
	GameUIAllianTitle.super.ctor(self)
	self.title_ = title
end

function GameUIAllianTitle:onMoveInStage()
	GameUIAllianTitle.super.onMoveInStage(self)
	self:BuildUI()
end

function GameUIAllianTitle:BuildUI()
	local shadowLayer = UIKit:shadowLayer():addTo(self)
	local bg = WidgetUIBackGround.new(634):addTo(shadowLayer):pos(window.left+20,window.bottom+150)

	local title_bar = display.newSprite("alliance_blue_title_600x42.png")
		:addTo(bg)
		:align(display.LEFT_BOTTOM, 0, 619)
	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(title_bar)
	   	:align(display.BOTTOM_RIGHT,title_bar:getContentSize().width+10, 0)
	   	:onButtonClicked(function ()
	   		self:leftButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)
	self.title_label = UIKit:ttfLabel({
		text = Localize.alliance_title[self.title_],
		size = 24,
		color = 0xffedae,
	}):align(display.CENTER,title_bar:getContentSize().width/2, title_bar:getContentSize().height/2)
		:addTo(title_bar)
	local prePageButton = cc.ui.UIPushButton.new({normal="alliance_page_button_normal_48x90.png",pressed = "alliance_page_button_highlight_48x90.png"})
	:align(display.LEFT_TOP,0,title_bar:getPositionY()-10):addTo(bg)

	local nextPageButton = cc.ui.UIPushButton.new({normal="alliance_page_button_normal_48x90.png",pressed = "alliance_page_button_highlight_48x90.png"})
	nextPageButton:setRotation(180)
	nextPageButton:align(display.LEFT_BOTTOM,608,title_bar:getPositionY()-10):addTo(bg)

	local icon = display.newSprite("alliance_item_leader_39x39.png"):addTo(bg):align(display.LEFT_CENTER,60,title_bar:getPositionY()-52)

	local function onEdit(event, editbox)
        if event == "return" then
           	self:OnEditAllianceTitle()
        end
    end
	local editbox = cc.ui.UIInput.new({
    	UIInputType = 1,
        image = "input_box.png",
        size = cc.size(427,51),
        listener = onEdit,
    })
    editbox:setPlaceHolder(_("联盟盟主"))
    editbox:setMaxLength(140)
    editbox:setFont(UIKit:getFontFilePath(),22)
    editbox:setFontColor(cc.c3b(0,0,0))
    editbox:setPlaceholderFontColor(cc.c3b(204,196,158))
    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editbox:align(display.LEFT_TOP,icon:getPositionX()+50,icon:getPositionY()+20):addTo(bg)
end

function GameUIAllianTitle:OnEditAllianceTitle()

end

return GameUIAllianTitle