--
-- Author: Danny He
-- Date: 2014-09-24 22:37:58
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIDragonSkill = UIKit:createUIClass("GameUIDragonSkill")
local config_dragonSkill = GameDatas.DragonEyrie.dragonSkill
local BODY_HEIGHT = 664
local LISTVIEW_WIDTH = 547
local UIListView = import(".UIListView")
local Localize = import("..utils.Localize")

function GameUIDragonSkill:ctor(owner,skillLocation)
	GameUIDragonSkill.super.ctor(self)
  self.owner = owner
  self.skillLocation = skillLocation
  self.dragon = self.owner:GetCurrentDragon()
	self.skill = self.dragon.skills["skill_" .. skillLocation]
end

function GameUIDragonSkill:onEnter()
	GameUIDragonSkill.super.onEnter(self)
	self.backgroundImage = WidgetUIBackGround.new(BODY_HEIGHT):addTo(self)
	self.backgroundImage:pos((display.width-self.backgroundImage:getContentSize().width)/2,display.height - self.backgroundImage:getContentSize().height - 80)
	local titleBar = display.newSprite("title_blue_596x49.png")
		:align(display.TOP_LEFT, 6,self.backgroundImage:getContentSize().height - 6)
		:addTo(self.backgroundImage)
	self.mainTitleLabel =  cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("技能升级"),
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0xffedae)
	})
    :addTo(titleBar)
    :align(display.LEFT_BOTTOM, 10, 10)
    self.titleBar = titleBar

  	local closeButton = cc.ui.UIPushButton.new({normal = "X_2.png",pressed = "X_1.png"}, {scale9 = false})
	   	:addTo(titleBar)
	   	:align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+25, 10)
	   	:onButtonClicked(function ()
	   		self:CloseButtonClicked()
	   	end)
	display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)

  local skillBg = display.newSprite("dragonskill_84x86.png")
        :addTo(self.backgroundImage):align(display.LEFT_TOP,30,titleBar:getPositionY()-titleBar:getContentSize().height - 20)
    display.newSprite("dragonskill_70x70.png"):addTo(skillBg):pos(skillBg:getContentSize().width/2,skillBg:getContentSize().height/2)

  local titleLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = Localize.dragon_skill[self.skill.name] .. " (LV" .. self.skill.level .. ")",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
	}):addTo(self.backgroundImage):align(display.LEFT_TOP,skillBg:getPositionX()+skillBg:getContentSize().width+20,skillBg:getPositionY()-10)
  self.titleLabel = titleLabel
	local descLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = self:GetSkillEffection(self.skill),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
	}):addTo(self.backgroundImage):align(display.LEFT_TOP, skillBg:getPositionX()+skillBg:getContentSize().width+20, titleLabel:getPositionY()- titleLabel:getContentSize().height - 10)
  self.descLabel = descLabel
	local upgradeButton = cc.ui.UIPushButton.new({
    normal = "dragon_yellow_button.png",
    pressed = "dragon_yellow_button_h.png",
    disabled="yellow_disable_185x65.png"}, {scale9 = false})
      :setButtonLabel("normal",cc.ui.UILabel.new({
          UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
          text = _("升级"),
          font = UIKit:getFontFilePath(),
          size = 24,
          align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
          color = UIKit:hex2c3b(0xfff3c7)
      }))
      :addTo(self.backgroundImage)
      :align(display.LEFT_BOTTOM,skillBg:getPositionX()+skillBg:getContentSize().width+260,skillBg:getPositionY()-skillBg:getContentSize().height)
      :onButtonClicked(function(event)
      		self:UpgradeButtonClicked()
      end)
    upgradeButton:setButtonEnabled(self:CanUpgrade())
    self.upgradeButton = upgradeButton
  	local requirementLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = _("升级条件"),
        font = UIKit:getFontFilePath(),
        size = 22,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFTCENTER, 
        color = UIKit:hex2c3b(0x403c2f)
	}):addTo(self.backgroundImage):pos(self.backgroundImage:getContentSize().width/2 - 60,upgradeButton:getPositionY()- 40)

	self.listView = UIListView.new {
      viewRect = cc.rect((self.backgroundImage:getContentSize().width-LISTVIEW_WIDTH)/2, 180, LISTVIEW_WIDTH, 250),
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
  	}
  	:addTo(self.backgroundImage)
  	self:RefreshUI()
end

function GameUIDragonSkill:RefreshUI()
  self.titleLabel:setString(Localize.dragon_skill[self.skill.name] .. " (LV" .. self.skill.level .. ")")
  self.descLabel:setString(self:GetSkillEffection(self.skill))
	local requires = self:GetUpgradeSkillCost(self.skill.name,self.skill.level)
  self.listView:removeAllItems()
	for i,v in ipairs(requires) do
		local newItem = self.listView:newItem()
  		local content = self:GetListItem(i,v[1],v[2])
  		newItem:addContent(content)
  		newItem:setItemSize(content:getContentSize().width,content:getContentSize().height)
  		self.listView:addItem(newItem)
	end
  self.listView:reload()
  self.upgradeButton:setButtonEnabled(self:CanUpgrade())
end


function GameUIDragonSkill:CloseButtonClicked()
	self:removeFromParentAndCleanup(true)
  self.owner.dragonEquipment = nil
end

function GameUIDragonSkill:UpgradeButtonClicked()
  PushService:upgradeDragonDragonSkill(self.dragon.type,self.skillLocation,function ( ... )

  end)
end

function GameUIDragonSkill:GetListItem(index,key,val)
	local bg = display.newSprite(string.format("resource_item_bg%d.png",index%2))
	local imageIcon = "dragon_energy_45x38.png"
	local title = _("能量")
	if key == "blood" then
		title = _("英雄之血")
		imageIcon = "dragonskill_blood_51x63.png"
	elseif key == "dragonLevel" then
		title = _("龙的等级")
		imageIcon = "dragonskill_xp_51x63.png"
	end
	local icon = display.newSprite(imageIcon):addTo(bg):pos(30,bg:getContentSize().height/2)
	icon:setScale(0.5)
	local titleLable = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = title,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x615b44)
	}):addTo(bg):pos(icon:getPositionX()+30,bg:getContentSize().height/2)

	local valLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = val,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT, 
        color = UIKit:hex2c3b(0x403c2f)
	}):pos(bg:getContentSize().width - 50,bg:getContentSize().height/2):addTo(bg)
	return bg
end

function GameUIDragonSkill:GetUpgradeSkillCost( dragonSkill,level)
    local config = self:GetSkillConfig(dragonSkill)
    local r = {
        {"energy",config.energyCostPerLevel},
        {"blood",math.pow(level+1,2) * config.heroBloodCostPerLevel},
        {"dragonLevel",1}, -- 配置表未配置暂时写死
    }
    return r
end

function GameUIDragonSkill:CanUpgrade()
  local requires = self:GetUpgradeSkillCost(self.skill.name,self.skill.level)
  local flag = City:GetResourceManager():GetEnergyResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()) >= requires[1][2]
    and City:GetResourceManager():GetBloodResource():GetValue() >= requires[2][2]
    and self.dragon.level >= requires[3][2]
  return flag
end

function GameUIDragonSkill:GetSkillEffection(skill)
  local config = self:GetSkillConfig(skill.name)
  local count  = string.format("%d%%",skill.level * config.effection * 100)
  return Localize.dragon_skill_effection[self.skill.name] .. " " .. count
end

function GameUIDragonSkill:GetSkillConfig(dragonSkill)
  return config_dragonSkill[dragonSkill]
end

function GameUIDragonSkill:DragonDataChanged()
  self.dragon = self.owner:GetCurrentDragon()
  self.skill = self.dragon.skills["skill_" .. self.skillLocation]  
  self:RefreshUI()
end

return GameUIDragonSkill