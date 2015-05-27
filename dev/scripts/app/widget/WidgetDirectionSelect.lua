local WidgetDirectionSelect = class("WidgetDirectionSelect", function()
    return display.newNode()
end)



function WidgetDirectionSelect:ctor()
	self.left = display.newSprite("pve_move_icon_locked.png"):addTo(self):rotation(-90)
	self.left_area = display.newSprite("pve_move_icon_area.png"):addTo(self):rotation(-90)
	self.right = display.newSprite("pve_move_icon_locked.png"):addTo(self):rotation(90)
	self.right_area = display.newSprite("pve_move_icon_area.png"):addTo(self):rotation(90)
	self.up = display.newSprite("pve_move_icon_locked.png"):addTo(self):setAnchorPoint(cc.p(0.5, 0.25))
	self.up_area = display.newSprite("pve_move_icon_area.png"):addTo(self):setAnchorPoint(cc.p(0.5, 0.121))
	self.down = display.newSprite("pve_move_icon_locked.png"):addTo(self):rotation(180)
	self.down_area = display.newSprite("pve_move_icon_area.png"):addTo(self):rotation(180)

	self.left_area:setAnchorPoint(cc.p(0.5, 0.121))
	self.right_area:setAnchorPoint(cc.p(0.5, 0.121))
	self.up_area:setAnchorPoint(cc.p(0.5, 0.121))
	self.down_area:setAnchorPoint(cc.p(0.5, 0.121))

	self.left:setAnchorPoint(cc.p(0.5, 0.29))
	self.right:setAnchorPoint(cc.p(0.5, 0.29))
	self.up:setAnchorPoint(cc.p(0.5, 0.29))
	self.down:setAnchorPoint(cc.p(0.5, 0.29))
end
function WidgetDirectionSelect:EnableDirection(left, right, up, down)
	self.left:zorder(left and 1 or 0)
	:setTexture(left and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")

	self.right:zorder(right and 1 or 0)
	:setTexture(right and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")

	self.up:zorder(up and 1 or 0)
	:setTexture(up and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")
	
	self.down:zorder(down and 1 or 0)
	:setTexture(down and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")
	return self
end
function WidgetDirectionSelect:ShowDirection(left, right, up, down)
	self.left_area:zorder(left and 1 or 0)
	self.left_area:setVisible(left)
	self.left:setVisible(not left)

	self.right_area:zorder(left and 1 or 0)
	self.right_area:setVisible(right)
	self.right:setVisible(not right)

	self.up_area:zorder(left and 1 or 0)
	self.up_area:setVisible(up)
	self.up:setVisible(not up)

	self.down_area:zorder(left and 1 or 0)
	self.down_area:setVisible(down)
	self.down:setVisible(not down)
	return self
end





return WidgetDirectionSelect