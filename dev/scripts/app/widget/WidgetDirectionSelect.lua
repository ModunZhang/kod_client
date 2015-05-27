local WidgetDirectionSelect = class("WidgetDirectionSelect", function()
    return display.newNode()
end)


local L,R = 100, 2.39

function WidgetDirectionSelect:ctor()
	display.newSprite("pve_icon_circle.png"):addTo(self)

	self.left = display.newSprite("pve_move_icon_locked.png"):addTo(self):rotation(-90):pos(-L,0)
	self.right = display.newSprite("pve_move_icon_locked.png"):addTo(self):rotation(90):pos(L,0)
	self.up = display.newSprite("pve_move_icon_locked.png"):addTo(self):pos(0,L)
	self.down = display.newSprite("pve_move_icon_locked.png"):addTo(self):rotation(180):pos(0,-L)

	self.left_area = display.newSprite("pve_move_icon_area.png"):addTo(self):rotation(-90):pos(-L*R,0)
	self.right_area = display.newSprite("pve_move_icon_area.png"):addTo(self):rotation(90):pos(L*R,0)
	self.up_area = display.newSprite("pve_move_icon_area.png"):addTo(self):pos(0,L*R)
	self.down_area = display.newSprite("pve_move_icon_area.png"):addTo(self):rotation(180):pos(0,-L*R)
end
function WidgetDirectionSelect:EnableDirection(left, right, up, down)
	self:RefreshTexture(left, right, up, down)
	self.left_area:hide()
	self.right_area:hide()
	self.up_area:hide()
	self.down_area:hide()
	return self
end
function WidgetDirectionSelect:ShowEnableDirection(left, right, up, down)
	self:RefreshTexture(left, right, up, down)

	self.left_area:setVisible(left)
	self.left:setVisible(not left)

	self.right_area:setVisible(right)
	self.right:setVisible(not right)

	self.up_area:setVisible(up)
	self.up:setVisible(not up)

	self.down_area:setVisible(down)
	self.down:setVisible(not down)
	return self
end
function WidgetDirectionSelect:ShowDirection(left, right, up, down)
	self:RefreshTexture(left, right, up, down)
	self.left_area:hide()
	self.right_area:hide()
	self.up_area:hide()
	self.down_area:hide()
	self.left:setVisible(left)
	self.right:setVisible(right)
	self.up:setVisible(up)
	self.down:setVisible(down)
	return self
end
function WidgetDirectionSelect:RefreshTexture(left, right, up, down)
	self.left:setTexture(left and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")
	self.right:setTexture(right and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")
	self.up:setTexture(up and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")
	self.down:setTexture(down and "pve_move_icon_unlock.png" or "pve_move_icon_locked.png")
	return self
end





return WidgetDirectionSelect