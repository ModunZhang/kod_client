--
-- Author: Danny He
-- Date: 2014-09-23 17:03:17
--
local Button = import(".WidgetPushButton")
local config_equipments = GameDatas.DragonEquipments.equipments
local WidgetDragonEquipIntensify = class("WidgetDragonEquipIntensify",Button)
local UILib = import("..ui.UILib")
-- equipment 为配置表 count为服务器拥有值
function WidgetDragonEquipIntensify:ctor(delegate,equipmentName,current_count,maxCount,resolveEquipmentName)
	local super_ = WidgetDragonEquipIntensify.super
    self.delegate_ = delegate
    self.count_ = count
    self.equipment_ = equipmentName 
    self.current_count = current_count or 0
    self.maxCount = maxCount or 0
    self.resolveEquipmentName = resolveEquipmentName
    --ui
	super_.ctor(self,{normal = "eq_bg_1_146x146.png"}, {scale9 = true})
	self:setButtonSize(105, 104)
	local icon_ = display.newSprite(self:GetEqIcon(equipmentName))
	icon_:addTo(self):setScale(0.7)

	local labelbg = display.newSprite("back_ground_97x20.png"):addTo(self):pos(0,-70)
	local label = cc.ui.UILabel.new({
      UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
      text = self.current_count .. "/" .. self.maxCount,
      font = UIKit:getFontFilePath(),
      size = 18,
      align = cc.ui.UILabel.TEXT_ALIGN_CENTER, 
      color = UIKit:hex2c3b(0x403c2f)
    }):addTo(labelbg):align(display.CENTER, labelbg:getContentSize().width/2, labelbg:getContentSize().height/2)
    self.textLabel = label
	self:onButtonClicked(function(event)
		self:Action(1)
    end)
	local cancel = cc.ui.UIPushButton.new("cancel_39x39.png",{scale9 = falses}):addTo(self):pos(45,45)
	cancel:setScale(0.8)
	cancel:onButtonClicked(function(event)
		self:Action(2)
	end)
	cancel:hide()
	self.cancelButton = cancel
end

function WidgetDragonEquipIntensify:Action(type)
	if type == 1 then
		local r = self.current_count + 1
		if r <= self.maxCount then
			self.current_count = r
		end
	else
		local r = self.current_count - 1
		if r > 0 or r == 0 then 
			self.current_count = r
		end
	end

	if self.delegate_ and self.delegate_.WidgetDragonEquipIntensifyEvent then
		local back = self.delegate_.WidgetDragonEquipIntensifyEvent(self.delegate_,self)
		if back then
			if type == 1 then
				self.current_count = self.current_count - 1
			else
				self.current_count = self.current_count + 1
			end
		end
	end
	self.textLabel:setString(self.current_count .. "/" .. self.maxCount)
	self.cancelButton:setVisible(self.current_count>0)
end


function WidgetDragonEquipIntensify:Reset()
	self.current_count = 0
	self.cancelButton:hide()
	self.textLabel:setString(self.current_count .. "/" .. self.maxCount)
end

function WidgetDragonEquipIntensify:GetEquipmetFromConfig( equipmentName )
	return config_equipments[equipmentName]
end

function WidgetDragonEquipIntensify:GetEqIcon(equipmentName)
 	return UILib.equipment[equipmentName]
end

function WidgetDragonEquipIntensify:GetEqCategory(equipment)
	local category = equipment["category"]
	if  category == "armguardLeft,armguardRight" or category == "armguardRight,armguardLeft" then
		category = "armguardLeft"
	end
	return category
end
function WidgetDragonEquipIntensify:GetNameAndCount()
	return self.equipment_,self.current_count
end

function WidgetDragonEquipIntensify:GetExpPerEq()
	local resolveEquipment = self:GetEquipmetFromConfig(self.resolveEquipmentName)
	local selfEquipment = self:GetEquipmetFromConfig(self.equipment_)
	if resolveEquipment.usedFor == selfEquipment.usedFor then
		if resolveEquipment.name == selfEquipment.name then
			return selfEquipment.resolveLExp
		else
			return selfEquipment.resolveMExp
		end
	else
		return selfEquipment.resolveSExp
	end
end

function WidgetDragonEquipIntensify:GetTotalExp()
	return self.current_count * self:GetExpPerEq()
end

return WidgetDragonEquipIntensify